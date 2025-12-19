# C4 Level 2 — Containers

```mermaid
graph TD
  Clients[Cerial Client / Activity Master callers]
  CerialMasterLib[Cerial Master Library (GuicedEE module)]
  ActivityMasterCore[Activity Master Core + FSDM Services]
  VertxPersistence[Vertx Persistence + Mutiny Sessions]
  Postgres[PostgreSQL]
  SerialHardware[Serial Port Hardware]

  Clients --> CerialMasterLib
  CerialMasterLib --> ActivityMasterCore
  CerialMasterLib --> VertxPersistence
  VertxPersistence --> Postgres
  CerialMasterLib --> SerialHardware
  SerialHardware --> CerialMasterLib
```

Notes
- JPMS module `com.guicedee.activitymaster.cerialmaster`; Guice bindings expose `ICerialMasterService` and system/installers.
- Persistence uses Mutiny sessions from Activity Master/Vert.x persistence; no direct JDBC.
- Hardware enumeration relies on jSerialComm (nrjavaserial artifact).
