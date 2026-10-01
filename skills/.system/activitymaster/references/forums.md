# Forum Master usage

Use this reference for `ActivityMaster/forums` and hosts that consume Forum Master.
Verify contract changes against `ActivityMaster/forums/README.md`, `ForumApi`,
`IForumService`, `ForumModels`, `ForumIdentity`, and `rest/ForumRestService`.

## Module and FSDM ownership

Maven artifact: `com.activity-master:forum-master`, managed by the ActivityMaster BOM.
JPMS module and Java package: `com.guicedee.activitymaster.forums`.
The system is named `Forum Master`. `ForumInstall` installs taxonomy at sort order 1180;
JPMS providers and `META-INF/services` register the binder, inclusion, system, and update.
The module depends on core ActivityMaster and Notification Master.

A forum is a typed FSDM Arrangement. `ForumContext` and `ForumTitle` classifications
hold its context and title; `ForumModerator` and `ForumSubscriber` classifications
identify its InvolvedParty relationships. A post is a `Forum Post` Event linked to
the Arrangement and poster, with text in a private `Forum Post Body` ResourceItem.
Keep this model; do not introduce `forum_boards`, `forum_topics`, `forum_posts`, or
parallel membership tables. Relationship values are short discriminators; post text
belongs in resource data. Hosts must protect privileged generic FSDM row access.

## Verified host identity and context

The host binds `ForumIdentityProvider.current()` to a verified, call-scoped
`ForumIdentity(partyId, enterpriseId, context, identityToken)`. Its default denies.
For a delegated call, use the five-argument constructor with
`PluginModels.Invocation(pluginId, installationPartyId)` as its fifth component.
The four-argument compatibility constructor sets `plugin` to null for ordinary
host access; never clear it while forwarding an actual plugin invocation.
Forum/Notification services enforce the current declared target, installation,
user consent and administrator policy when invocation is present, alongside
subscriber/domain row access. `ForumApi` audits successful delegated writes;
lower-level callers compose `PluginService.audit`/`execute` in their transaction.
Post notification identity must preserve the same invocation, and the extension
must declare/obtain consent to each target it invokes. See [plugins](scoped-plugins.md).

Use the caller's ActivityMaster credential and current grants; neither path IDs,
subscriber IDs nor request context establishes the actor's authority.

Personal and Social context owners equal the verified party ID. Work context owner
equals the authorized enterprise ID. The `Create` realm and owner must match that
trusted context. A Social subscriber enters with their own verified Social context
and live subscription; the forum retains its creator's context owner.

The creator is the moderator and remains subscribed. This moderator is an organic
party, including in Work forums; the Work context owner is the enterprise. Do not
confuse those two IDs when replacing the subscriber list.

## Subscriber access and changes

Subscriptions grant both forum access and inclusion in future post notifications.
There is currently no separate notification-only subscription or mute setting.
Every new subscriber must be a live organic InvolvedParty in the same enterprise.
Current subscribers can read and post. Inaccessible forums return 404. The creator
alone can add, remove, or replace subscribers; an ordinary subscriber can leave only
their own membership. The creator cannot leave or be removed from the desired set.

Use `addSubscriber`, `removeSubscriber`, or `updateSubscribers`; the last takes the
complete desired audience and must include the creator. Adding an existing party
or removing an absent party makes no membership change. Removal ends the FSDM
relationship's effective date; re-adding creates a new relationship. Preserve
membership history and reference rows. Subscriber changes affect future notices;
already published notification recipients and read states remain intact.

At most 50 parties may subscribe, including the creator. Personal forums contain
only their creator. New forums accept at most 49 supplied subscriber IDs and add
the creator themselves. Duplicates collapse; null and unavailable targets fail.

## Calling the Java API

Inject `ForumApi` for host operations. Its methods return reactive `Uni` values:

```java
// verified comes from the authenticated host, never the request body.
ForumModels.Create create = new ForumModels.Create(
        verified.context().realm(), verified.context().ownerId(),
        "Harvest planning", List.of(invitedOrganicPartyId));
return forums.create(enterpriseName, create)
        .chain(forum -> forums.post(enterpriseName, forum.id(),
                new ForumModels.PublishPost("Discuss the next harvest.")));
```

`Forum(id, realm, ownerId, title, subscribers)` describes the current forum.
`Post(id, forumId, posterId, text, createdAt)` describes a stored post.
`Page<T>(items, offset, limit, hasMore)` describes a bounded page.

`ForumApi` exposes `create`, `find`, `list`, `post`, `posts`, `addSubscriber`,
`removeSubscriber`, `updateSubscribers`, and `leave`. `UpdateSubscribers` contains
`subscribers`; `PublishPost` contains `text`. Chain the `Uni` operations rather
than blocking or starting detached writes.

The low-level `IForumService` accepts the caller's stateless session, resolved
Forum Master system, and verified identity. Writes require a caller-owned
transaction. Its `post` stores forum content only. Prefer `ForumApi.post` when
notification publication is required; direct service consumers must compose both
stores in their own transaction and start channel delivery after commit.

## REST operations and limits

Base: `/{enterprise}/forums`, beneath the consuming host's REST prefix.

| Method | Path | Body or query |
| --- | --- | --- |
| POST | `/` | `{realm, ownerId, title, subscribers}` |
| GET | `/` | `offset`, `limit` |
| GET | `/{id}` | Current forum and subscribers |
| POST | `/{id}/posts` | `{text}` |
| GET | `/{id}/posts` | `offset`, `limit`; posts in creation order |
| PUT | `/{id}/subscribers/{partyId}` | Add one organic party |
| DELETE | `/{id}/subscribers/{partyId}` | Remove one party |
| PUT | `/{id}/subscribers` | `{subscribers: [...]}`; full replacement |
| DELETE | `/{id}/membership` | Leave as the current subscriber |

Titles are single-line, 1..150 UTF-16 code units. Post text is nonblank plain Unicode,
at most 65,536 UTF-16 code units. Null characters and invalid surrogate pairs fail;
renderers must escape the text. Paging is offset 0..10,000 and limit 1..100, default
limit 50. Do not promise nested boards/topics, pinned or locked topics, post editing,
attachments, moderator transfer, or forum GraphQL operations without implementing
and testing those features.

## Notification publication and delivery

For a nonempty audience, the host must also bind `NotificationIdentityProvider`
to the same verified party, enterprise, context, and identifying credential.
The publisher needs Notification Master system and party-row read grants and a
current `notifications.publish` scoped behavior grant. Recipients need their own
Notification Master read grants to open the notices. Forum installation does not
grant notification publishing authority. Preserve grant checks at both boundaries.

`ForumApi.post` snapshots current subscribers and excludes the poster. It writes
the post and notification in one stateless FSDM transaction, resolving the
Notification Master system on the same session and calling `INotificationService`.
Do not call `NotificationApi.publish` to open a second transaction inside this flow.
Notification publication or identity failure rolls back the post and notice together.
This prevents an explicitly failed publication from leaving a saved post that a
retry would duplicate; it is not a general HTTP idempotency guarantee for an unknown
commit outcome. When the audience is empty, the post is stored without a notice.

The notice category is `forum.post`, severity `INFO`, subject the forum title, and
body the post text. Its JSON data contains `forumId` and `postId`. The stored notice
is durable before `NotificationDispatcher` attempts the `EVENT_BUS` channel after
commit. Channel failure does not roll back either record. The host transport must
verify a connected websocket or SSE session belongs to the addressed recipient
before forwarding `activitymaster.notifications.{enterpriseId}` events.

## Validation evidence

Run `mvn test` from `ActivityMaster/forums` without cleaning. `ForumStorageTest`
uses PostgreSQL Testcontainers and covers organic-party validation, moderator-only
changes, access removal/re-add/leave, current notification audience, and rollback
when notification publication is denied. Inspect Surefire's failure/error counts;
a successful Maven exit alone is insufficient with ignored test failures.
Database tests do not establish live consuming-host authentication, REST/browser
behavior, or recipient event-bus forwarding; verify those separately when requested.
