---
name: jwebmp-angular-graphql
description: Apollo GraphQL client generation for JWebMP. Exposes the @NgGraphQL annotation to generate typed apollo-angular services from Java for GraphQL queries, mutations, and subscriptions, with signal-based state, polling, fetch/error policies, and default variables via @NgGraphQLVariable. Use when working with GraphQL in JWebMP, generating Apollo Angular clients, mapping GraphQL operations to Angular services, or building reactive GraphQL-backed UIs in JWebMP applications.
metadata:
  short-description: Apollo GraphQL client generation for JWebMP
---

# JWebMP Angular Apollo GraphQL

Generates Apollo (`apollo-angular`) TypeScript services from Java annotations. Annotate a class with
`@NgGraphQL`, declare the GraphQL operation, and the framework emits a fully typed `@Injectable` Angular
service backed by Apollo and Angular signals — no handwritten TypeScript.

It mirrors the `@NgRestClient` pattern (see `jwebmp-tsclient`): one annotated Java class per GraphQL operation.

## Installation

```xml
<dependency>
    <groupId>com.jwebmp.plugins</groupId>
    <artifactId>angular-graphql</artifactId>
</dependency>
```

- Module: `com.jwebmp.angular.graphql`
- Requires the `angular` (`com.jwebmp.core.angular`) and `typescript-client` plugins.
- npm deps are declared automatically via `@TsDependency`: `apollo-angular` ^11, `@apollo/client` ^4, `graphql` ^16.

## Core pattern

Implement `INgGraphQLClient<Self>` and annotate with `@NgGraphQL`. The implementing class is empty —
all TypeScript is generated from the annotation.

```java
@NgGraphQL(
    operation = """
        query Users($active: Boolean) {
          users(active: $active) { id name email }
        }
        """,
    operationType = NgGraphQL.OperationType.QUERY,
    fetchOnCreate = true)
@NgGraphQLVariable(name = "active", value = "true")
public class UsersQuery implements INgGraphQLClient<UsersQuery> { }
```

## @NgGraphQL attributes

| Attribute | Default | Purpose |
|-----------|---------|---------|
| `operation` | (required) | Raw GraphQL document; embedded into a `gql` template literal |
| `operationType` | `QUERY` | `QUERY`, `MUTATION`, or `SUBSCRIPTION` |
| `value` | `""` | Optional service name base |
| `responseType` | `INgDataType.class` (→ `any`) | Typed result class; imported automatically |
| `responseArray` | `false` | Result is an array of `responseType` |
| `singleton` | `true` | `providedIn: 'root'` vs `'any'` |
| `fetchOnCreate` | `false` | Auto-run on inject (QUERY → `execute()`, SUBSCRIPTION → `subscribe()`; never mutations) |
| `pollingEnabled` | `false` | Query polling via Apollo `pollInterval` |
| `pollingIntervalMs` | `30000` | Polling interval |
| `fetchPolicy` | `CACHE_FIRST` | Apollo fetch policy (`CACHE_AND_NETWORK`, `NETWORK_ONLY`, `CACHE_ONLY`, `NO_CACHE`, `STANDBY`) |
| `errorPolicy` | `NONE` | Apollo error policy (`IGNORE`, `ALL`) |

`@NgGraphQLVariable(name, value)` is repeatable; `value` is emitted as a raw TypeScript expression
(e.g. `"true"`, `"42"`, `"'active'"`). Defaults merge with call-time variables (call-time wins).

## Generated service API

All operation types expose `data()`, `loading()`, `error()`, `success()` signals, plus `reset()`,
`handleResult()`, and `ngOnDestroy` cleanup. The trigger method depends on `operationType`:

- **QUERY** → `execute(variables?)`, `refetch(variables?)`, `startPolling(ms?)`, `stopPolling()`, `polling` signal (uses `apollo.watchQuery`)
- **MUTATION** → `mutate(variables?)` (uses `apollo.mutate`; never auto-executes)
- **SUBSCRIPTION** → `subscribe(variables?)` (uses `apollo.subscribe`)

## Examples

### Mutation

```java
@NgGraphQL(
    operation = """
        mutation CreateOrder($input: OrderInput!) {
          createOrder(input: $input) { id status }
        }
        """,
    operationType = NgGraphQL.OperationType.MUTATION,
    errorPolicy = NgGraphQL.ErrorPolicy.ALL)
public class CreateOrderMutation implements INgGraphQLClient<CreateOrderMutation> { }
```

### Subscription (array result, auto-start)

```java
@NgGraphQL(
    operation = """
        subscription OnNotification {
          notificationAdded { id message }
        }
        """,
    operationType = NgGraphQL.OperationType.SUBSCRIPTION,
    responseArray = true,
    fetchOnCreate = true)
public class NotificationSubscription implements INgGraphQLClient<NotificationSubscription> { }
```

## Authoring a new operation client

1. Create a class implementing `INgGraphQLClient<Self>` in a package scanned by GuicedEE.
2. Add `@NgGraphQL` with the `operation` text and matching `operationType`.
3. For typed results, set `responseType` to an `INgDataType` class and use `responseArray` for lists.
4. Add repeatable `@NgGraphQLVariable` for defaults.
5. Inject the generated service in an `@NgComponent` and read its signals in the template.

## JPMS notes

The plugin registers itself for scanning via `IGuiceScanModuleInclusions`
(`AngularGraphQLScanModule` → `com.jwebmp.angular.graphql`). New client classes only need to live in a
module that is itself scanned; no extra registration per client.

## Build registration

When adding the plugin to a multi-module build, register it in:
- `JWebMP/bom/pom.xml` dependency management (`angular-graphql`).
- The aggregator/profile that builds JWebMP plugins (module `JWebMP/plugins/angular-graphql`).

