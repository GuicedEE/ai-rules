# Vert.x Upgrade Guide

Migration from Vert.x 4 to 5:

* Use Future-based APIs.
* Replace deprecated RxJava2 with Mutiny.
* Replace CLI and OpenTracing with Picocli and OpenTelemetry.
* Upgrade HTTP/WebSocket clients to use builder-based patterns.
* Use `Vertx.builder()` to compose runtime.