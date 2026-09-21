# Profiles and user sessions

Use this reference for profile storage, user application state, REST handlers, and GraphQL resolvers. Contracts below were checked against `ActivityMaster/profiles` and `ActivityMaster/user-sessions` source on 2026-09-20. Recheck those modules when changing transport support.

## Modules and contracts

| Concern | Maven artifact (group `com.activity-master`) | JPMS module | Injected service |
|---|---|---|---|
| Profiles | `profile-master` | `com.guicedee.activitymaster.profiles` | `IProfileService<?>` |
| User application state | `session-master` | `com.guicedee.activitymaster.sessions` | `IUserSessionService<?>` |

Use the ActivityMaster BOM for versions. A profile is an FSDM involved party with name and classification links; `ComprehensiveProfileDTO.profileId` is its UUID. There is no separate `UserProfile` entity or `IProfilesService` API. User sessions are `SessionObject` resource-item relationships on an involved party, storing JSON, not a `user_sessions` JPA table or an authentication-token store.

At a transport boundary establish context with `SessionUtils.withActivityMaster(enterprise, system, tuple -> ...)`. The tuple supplies the caller's `Mutiny.StatelessSession`, enterprise, requesting system, and token array. Compose sequential `Uni` operations on that session; do not open nested sessions, block, or start detached persistence subscriptions. Authentication and authorization must resolve the allowed party server-side; a submitted profile/party UUID or system name is not proof of permission. Application session data does not authenticate a user or replace the application's identity provider.

## Profile service

Inject `com.guicedee.activitymaster.profiles.services.interfaces.IProfileService<?>` and use `com.guicedee.activitymaster.profiles.webdto.ComprehensiveProfileDTO`:

```java
return SessionUtils.<ComprehensiveProfileDTO>withActivityMaster(enterpriseName, systemName,
    ctx -> profileService.saveProfile(ctx.getItem1(), ctx.getItem2(), input)
        .chain(id -> profileService.getProfile(ctx.getItem1(), ctx.getItem2(), id)));
```

`saveProfile(session, enterprise, dto)` returns `Uni<UUID>`; `getProfile(session, enterprise, id)` returns `Uni<ComprehensiveProfileDTO>`. Omit `profileId` to generate a UUID; supply it to target an existing profile. Both REST write operations currently use this same save/readback chain. Names, contact details, demographics, occupation, education, identification, social fields, and preferences are DTO fields backed by FSDM relationships. Inspect `toNameValues()` and `toAttributeValues()` for supplied-field handling; do not assume null deletes a field or that every name write replaces an old value.

The concrete service resolves `Profiles Master` and its system token inside the supplied enterprise. The requesting system establishes entry context; do not claim separate profile storage per requesting system based solely on route arguments. `preppedParty(id)` constructs a detached ID-only reference, not an existence or authorization check. A read with no stored data can return a DTO containing only `profileId` and `enterpriseName`, rather than null/404.

### Existing REST API

Relative to the configured ActivityMaster host/base path (URL-encode path segments):

| Method | Path | Body / response |
|---|---|---|
| POST | `/{enterprise}/profile/{requestingSystemName}/create` | `ComprehensiveProfileDTO` / hydrated DTO |
| PUT | `/{enterprise}/profile/{requestingSystemName}/update` | DTO with `profileId` / hydrated DTO |
| GET | `/{enterprise}/profile/{requestingSystemName}/find/{profileId}` | No body / hydrated DTO |

Example create body:

```json
{"firstName":"Ada","surname":"Lovelace","occupation":"Mathematician","primaryEmail":"ada@example.test"}
```

Inject `ProfileRestClients` for outbound Java calls. Its `createProfile(systemName, dto)`, `updateProfile(systemName, dto)`, and `findProfile(systemName, UUID)` all return `Uni<ComprehensiveProfileDTO>`. Endpoints resolve `${ACTIVITY_MASTER_HOST}` and `ActivityMasterConfiguration.applicationEnterpriseName`. Return/chain the Uni; do not copy the blocking await in the client's Javadoc. These profile writes await persistence and hydration before responding; the generic immediate-response relationship pattern does not apply.

### Existing GraphQL API

`ProfileGraphQLSchemaProvider` contributes `ComprehensiveProfile` and two equivalent fields on the shared Query root:

```graphql
query ReadProfile($enterprise: String!, $system: String!, $id: String!) {
  profile(enterprise: $enterprise, system: $system, profileId: $id) {
    profileId
    enterpriseName
    firstName
    surname
    primaryEmail
    occupation
  }
}
```

Variables: `{"enterprise":"acme","system":"Profiles Master","id":"<profile UUID>"}`. `comprehensiveProfile` accepts the same arguments and returns the same type. Use the application's configured GraphQL endpoint. The arguments are `String!`, including the UUID string, not GraphQL `ID!`. The provider calls `getProfile` inside `withActivityMaster` and returns `Future.fromCompletionStage(uni.subscribeAsCompletionStage())` for the GraphQL future adapter. Provider discovery uses `IGraphQLSchemaProvider`; preserve JPMS `provides` and classpath service metadata.

There are currently no profile GraphQL create/update mutations in this provider. Use REST for existing remote writes. If a task explicitly adds mutations, extend the shared schema and delegate to the same save/readback service chain, preserving authentication, authorization, and error propagation.

## User session service

Inject `com.guicedee.activitymaster.sessions.services.IUserSessionService<?>`. Its system constant is `SessionMasterSystemName = "Sessions Master"`.

| Method | Behavior |
|---|---|
| `getUserSession(session, party, system, tokens...)` | Load or create persisted state into a new `UserSession` |
| `getUserSession(session, party, original, system, tokens...)` | Load state into the supplied session object |
| `updateSession(session, party, userSession, system, tokens...)` | Persist the current values |
| `expireSession(session, party, original, system, tokens...)` | Expire the backing resource item |

All return `Uni<IUserSession<?>>`. Pass a resolved, authorized `IInvolvedParty<?, ?>`, a real system, and the context's tokens. Do not rely on partially null arguments being accepted. Load first so resource-item identifiers are established. `getUserSession` can write on first access: consider that behavior before exposing it as an HTTP GET or GraphQL query.

```java
// Inside withActivityMaster, after resolving and authorizing party in that context:
return userSessionService.getUserSession(ctx.getItem1(), party, ctx.getItem3(), ctx.getItem4())
    .invoke(state -> state.addValue("preferredView", "calendar"));
// addValue changes the in-memory object only; a write flow must then persist it.
```

`IUserSession` exposes `addValue`, `hasValue`, `removeValue`, `clear`, `as(key, type)`, and `getValues()`, plus resource/data IDs. `UserSession.addValue` preserves strings and JSON-encodes non-string objects; `as` deserializes them. Its JSON representation is the values map, not an envelope containing resource IDs. Removing/clearing values requires persistence; it does not expire a session or log out the identity provider.

### REST and GraphQL integration

The current user-sessions module has no dedicated REST resource, typed REST client, or GraphQL schema provider. Do not invent existing URLs or query/mutation names. For application endpoints/resolvers explicitly requested by a task:

1. Resolve authenticated identity to the allowed involved party server-side and establish the enterprise/system context.
2. Load state through `getUserSession` and project an explicit DTO containing only application-approved values; do not expose the whole map or internal resource IDs by default.
3. For writes, mutate the loaded state and chain `updateSession`; for expiry, chain `expireSession`. Return success only after persistence succeeds.
4. REST handlers return the composed `Uni<DTO>`. GraphQL providers define explicit output/input types, extend the existing root types, register through `IGraphQLSchemaProvider`, and bridge the final Uni to `Future` as in the profile provider. Declare a Mutation root only if none exists; otherwise extend it.
5. Test first access, write/readback, expiry, unauthorized/cross-party access, and failure propagation through both transports.

**Current implementation caveat:** `UserSessionService.updateSession` replaces the persistence result with the database session and casts that object to `IUserSession<?>`; the normal path can therefore fail with `ClassCastException` after the write. Fix and test that implementation before relying on successful REST/GraphQL session writes. Do not hide the failure with a successful response. The fake-system path skips persistence. Also verify existing-session resource/data ID handling when integrating expiry/readback; documentation alone does not establish runtime correctness.

## Source anchors

Paths relative to the DevSuite checkout:

- `ActivityMaster/profiles/src/main/java/com/guicedee/activitymaster/profiles/`: `services/interfaces/IProfileService.java`, `ProfileService.java`, `webdto/ComprehensiveProfileDTO.java`, `rest/ProfileRestService.java`, `rest/ProfileRestClients.java`, `implementations/graphql/ProfileGraphQLSchemaProvider.java`.
- `ActivityMaster/user-sessions/src/main/java/com/guicedee/activitymaster/sessions/`: `services/IUserSessionService.java`, `services/IUserSession.java`, `UserSession.java`, `UserSessionService.java`, `implementations/SessionMasterBinder.java`.
- Profile verification examples: `ActivityMaster/profiles/src/test/java/com/guicedee/activitymaster/profiles/test/ProfileComprehensiveProfileTest.java` and `ProfileGraphQLIntegrationTest.java`; session value serialization: `ActivityMaster/user-sessions/src/test/java/com/guicedee/activitymaster/sessions/test/UserSessionDataTest.java`.
