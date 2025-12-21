# C4 Level 1 — Context (Cerial Master Library)

```mermaid
graph TD
  Operator[Operator / Maintainer]
  ActivityMasterApps[Activity Master applications]
  CerialMasterLib[Cerial Master Library]
  ActivityMasterCore[Activity Master Core Services]
  Database[PostgreSQL via Vertx Persistence]
  SerialPorts[Serial Port Hardware]

  Operator --> ActivityMasterApps
  ActivityMasterApps --> CerialMasterLib
  CerialMasterLib --> ActivityMasterCore
  ActivityMasterCore --> Database
  CerialMasterLib --> SerialPorts
  SerialPorts --> CerialMasterLib
```

Scope
- Cerial Master is a service/framework addon that registers serial ports as Activity Master resource items/classifications and manages COM port lifecycle.
- It integrates GuicedEE modules, Mutiny/Hibernate Reactive sessions, and jSerialComm/nrjavaserial for hardware access.
