# Kotlin — Backend Consolidated Rules

Audience: JVM backend services and libraries written in Kotlin. Optimized for AI generation and human maintainability. Aligns with repository modularity and forward-only policy.

## Goals
- Establish enforceable Kotlin conventions for backend projects
- Ensure non-blocking, testable, observable services
- Maximize interop with Java and JSpecify rules

## Scope
- Language and style conventions
- Build configuration (Gradle Kotlin DSL)
- Coroutines and structured concurrency
- HTTP/reactive stacks (Ktor, Vert.x 5)
- Serialization, mapping, and persistence guidance
- Testing, logging, and observability

---

## Project setup — Gradle (Kotlin DSL)

Use a consistent Gradle baseline. Prefer explicit API for libraries and strict nullability interop.

```kotlin
plugins {
  kotlin("jvm") version "1.9.24"
  kotlin("plugin.serialization") version "1.9.24"
  // Static analysis (recommended):
  // id("io.gitlab.arturbosch.detekt") version "1.23.6"
}

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(21))
  }
}

kotlin {
  explicitApi() // 'explicitApi = ExplicitApiMode.Strict' for libraries
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
  kotlinOptions {
    jvmTarget = "21"
    freeCompilerArgs = freeCompilerArgs + listOf(
      "-Xjsr305=strict", // honor Java nullability annotations strictly
      "-Xjvm-default=all", // default interface methods for smoother interop
      "-Xcontext-receivers" // if your project uses them
    )
  }
}

dependencies {
  // Coroutines
  implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0")
  // Logging
  implementation("org.slf4j:slf4j-api:2.0.16")
  implementation("io.github.microutils:kotlin-logging-jvm:3.0.5")
  // JSON — prefer Kotlinx Serialization (native-first)
  implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")
  // Native data/time and collections (prefer KotlinX over third-party)
  implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.6.1")
  implementation("org.jetbrains.kotlinx:kotlinx-collections-immutable:0.3.7")
  // Alternative (use only when required by shared infra or 3rd-party SDKs): Jackson + Kotlin module
  // implementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.18.1")
  // Vert.x (optional)
  // implementation("io.vertx:vertx-web:5.0.0.CR4")
  // implementation("io.vertx:vertx-lang-kotlin:5.0.0.CR4")
  // implementation("io.vertx:vertx-lang-kotlin-coroutines:5.0.0.CR4")
  // Testing
  testImplementation("org.junit.jupiter:junit-jupiter:5.11.3")
  testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.9.0")
  // Kotest (optional)
  // testImplementation("io.kotest:kotest-runner-junit5:5.9.1")
  // Testcontainers (optional)
  // testImplementation("org.testcontainers:junit-jupiter:1.20.2")
}

tasks.test {
  useJUnitPlatform()
}
```

### Configuration recommendations
- Enable Detekt and ktlint; enforce formatting and complexity thresholds in CI.
- Prefer Gradle version catalogs to centralize versions.
- For multi-module builds, enable explicitApi only on library modules; apps may keep default.

---

## Source layout and naming
- Packages are lower.snake.case not allowed; use lowerCamel package segments: com.example.myapp
- Prefer one top-level type per file; related extensions may live in FooExtensions.kt
- Modules should be capability-oriented (api, core, web, persistence) rather than layer-only
- Public surface is minimal; internal for implementation details; avoid public data classes leaking persistence concerns

---

## Language conventions
- Prefer val over var; use data class for immutable DTOs
- Use sealed interfaces for constrained hierarchies; favor value classes for IDs
- Prefer top-level functions for pure utilities; avoid singletons unless object is justified
- KDoc public APIs; document nullability and thread expectations
- Native-first library policy: prefer Kotlin stdlib and kotlinx.* (serialization, coroutines, datetime) over third-party libraries. Use alternatives only when integration requires them or provides measurable benefits.

### Null-safety and Java interop
- Kotlin types are the source of truth; avoid platform types by adding @ParametersAreNonnullByDefault or JSpecify in Java code
- Configure compiler with -Xjsr305=strict so Java nullability is enforced
- When exposing APIs to Java, annotate with @JvmOverloads where reasonable and use @Throws for checked exceptions
- For Java modules, follow JSpecify rules — see ../../backend/jspecify/jspecify.rules.md

### Example — DTO and service contract

```kotlin
data class UserId(val value: String)
data class UserDto(
  val id: UserId,
  val email: String,
  val displayName: String?,
)

interface UserService {
  suspend fun create(input: CreateUserRequest): UserDto
  suspend fun get(id: UserId): UserDto?
}
```

---

## Coroutines and structured concurrency
- Use suspend functions for asynchronous boundaries; do not return Deferred from APIs
- Use SupervisorJob at application scope; create child scopes per request/operation
- Choose dispatcher deliberately:
  - Dispatchers.Default for CPU-bound
  - Dispatchers.IO for blocking IO only; prefer non-blocking clients
- Prefer withContext to shift dispatchers; never block (Thread.sleep, runBlocking in production paths)
- Propagate cancellation; avoid swallowing CancellationException

### Example — supervisor scope and exception handling

```kotlin
class App(private val logger: mu.KLogger) {
  private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

  fun start() {
    scope.launch {
      try {
        // startup tasks
      } catch (t: Throwable) {
        logger.error(t) { "Startup failed" }
        cancel("fatal", t)
      }
    }
  }

  fun stop() {
    scope.cancel()
  }
}
```

---

## Vert.x 5 with Kotlin coroutines (optional)
- Add vertx-lang-kotlin and vertx-lang-kotlin-coroutines
- Use CoroutineRouter / route.blocking avoided; prefer suspend handlers
- Never call blocking DB drivers on event loop; use reactive clients or offload to worker pool with withContext(Dispatchers.IO)

### Example — suspend route handler

```kotlin
fun Router.routes(userService: UserService) {
  post("/users").coroutineHandler { ctx ->
    val request = kotlinx.serialization.json.Json.decodeFromString<CreateUserRequest>(ctx.bodyAsString())
    val created = userService.create(request)
    ctx.response().putHeader("content-type", "application/json")
      .end(kotlinx.serialization.json.Json.encodeToString(created))
  }
}
```

See also: Vert.x OAuth2 flow — ../../backend/vertx/vertx-5-oauth2-flow-guide.md and Security (Reactive) rules — ../../backend/security-reactive/security-reactive.rules.md

---

## Ktor with coroutines (server and client)
- Prefer Ktor for coroutine-native HTTP services and clients; use suspend handlers and avoid blocking calls.
- Install ContentNegotiation with kotlinx.serialization; avoid Jackson unless required by integration constraints.
- Use CallLogging and structured logging; never log secrets or tokens.

### Server example

```kotlin
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.plugins.calllogging.*
import io.ktor.server.response.*
import io.ktor.server.request.*
import io.ktor.server.routing.*
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class CreateUserRequest(val email: String, val displayName: String?)

fun Application.module(userService: UserService) {
  install(ContentNegotiation) {
    json(Json { ignoreUnknownKeys = true })
  }
  install(CallLogging)
  routing {
    post("/users") {
      val req = call.receive<CreateUserRequest>()
      val created = userService.create(req)
      call.respond(created)
    }
  }
}
```

### Client example

```kotlin
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.client.request.*
import io.ktor.client.call.*
import kotlinx.serialization.json.Json

val client = HttpClient(CIO) {
  install(ContentNegotiation) {
    json(Json { ignoreUnknownKeys = true })
  }
}

suspend fun createUser(baseUrl: String, req: CreateUserRequest): UserDto =
  client.post("$baseUrl/users") { setBody(req) }.body()
```

Notes:
- Use structured concurrency; propagate cancellation and avoid swallowing CancellationException.
- For auth, follow Security (Reactive) rules; attach Authorization headers and avoid logging tokens.
- For testing, use Ktor testApplication {} utilities and assert status/body via the test client.

---

## Serialization
- Native-first policy: prefer kotlinx.serialization for all JSON and data encoding in Kotlin services.
- Choose one stack per service to avoid impedance:
  - Preferred: kotlinx.serialization for sealed hierarchies, value classes, and multiplatform alignment.
  - Alternative (only when required by shared infra or 3rd-party SDKs): Jackson + Kotlin module.
- Do not expose internal domain types directly; map to transport DTOs.

### kotlinx.serialization example (preferred)

```kotlin
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class CreateUserRequest(val email: String, val displayName: String?)

val json = Json { ignoreUnknownKeys = true }
val req = json.decodeFromString<CreateUserRequest>(body)
val out = json.encodeToString(req)
```

---

## Mapping
- Prefer explicit mappers and data class copy(...) over magic
- If using MapStruct, enable Kotlin support (1.6+) and keep mappers in Java for best tooling until fully stable
- Keep mapping at the boundary; avoid leaking persistence entities into web layer

## Persistence notes
- For Hibernate Reactive, prefer non-null fields; optional columns mirrored as nullable Kotlin properties
- Wrap Mutiny types behind suspend APIs; keep transaction boundaries in service/application layer
- Ensure thread-context rules per Vert.x; avoid blocking the event loop

## Logging
- Use kotlin-logging with slf4j; do not use println
- Log structured key/value where possible; never log secrets or tokens

## Observability
- Emit metrics and traces per platform guides; propagate trace context across coroutine boundaries
- Wrap external calls with timing and error tags; prefer OpenTelemetry

## API design
- Prefer Result types or sealed outcomes for recoverable errors
- Use http-friendly error models; keep exceptions exceptional

## Testing
- Use JUnit 5 with kotlinx-coroutines-test runTest
- Provide negative tests for cancellation and timeouts
- Use Testcontainers for integration; isolate external dependencies

### Example — coroutine test

```kotlin
class UserServiceTest {
  @Test
  fun runSuspend() = runTest {
    // given
    // when
    // then
  }
}
```

## Anti-patterns
- Returning Deferred/Job from public APIs
- Running blocking calls on Default or event loop
- Sprinkling runBlocking in production paths
- Leaking internal entities to transport
- Platform types from Java due to missing nullability metadata

---

## See also
- Backend index — ../../backend/README.md
- Vert.x 5 — ../../backend/vertx/README.md
- Security (Reactive) — ../../backend/security-reactive/README.md
- Logging — ../../backend/logging/README.md
- MapStruct — ../../backend/mapstruct/README.md
- JSpecify rules — ../../backend/jspecify/jspecify.rules.md
- Platform: Secrets & Config — ../../platform/secrets-config/README.md
- Platform: Security & Auth — ../../platform/security-auth/README.md

## Versioning and forward-only policy
- Apply edits forward-only; update all references in the same change
- Keep this file modular and concise; link to deeper topics rather than duplicating

End.