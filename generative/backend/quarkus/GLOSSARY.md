# Quarkus Glossary

| Term | Definition | LLM Guidance |
| --- | --- | --- |
| Quarkus 3.x | Supersonic Subatomic Java framework targeting Java 21/Jakarta EE 10 with fast-jar and native builds. | Assume Quarkus 3.10+, cite core rules; mention JVM + native packaging when relevant. |
| Dev Services | Quarkus feature that spins up ephemeral containers (DB, Kafka, Keycloak) during dev/test. | Reference `./dev-services.rules.md`; enable only in `%dev/%test`, document images/ports. |
| RESTEasy Reactive | Reactive JAX-RS implementation used for HTTP APIs in Quarkus. | Reference `./resteasy-reactive.rules.md`; prefer DTOs + Uni return types. |
| Panache | Quarkus abstraction for Hibernate ORM repositories/entities. | Use `./panache-persistence.rules.md`; choose repository vs active record explicitly. |
| SmallRye Reactive Messaging | Quarkus integration for Kafka/AMQP messaging. | Follow `./reactive-messaging.rules.md`; configure channels via `mp.messaging.*`. |
| QuarkusTest / QuarkusIntegrationTest | Testing annotations to bootstrap CDI or native binaries. | Reference `./testing.rules.md`; map to CI stages and harness flows. |
| Native build | GraalVM/mandrel compiled binary for minimal footprint. | Cite `./native-build.rules.md`; ensure reflection config + tests align. |

See also
- Topic index — ./README.md
- Testing & Coverage glossary — ../../platform/testing/GLOSSARY.md
