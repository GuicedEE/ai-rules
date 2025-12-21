# C4 Level 3 — Components (Cerial Master)

```mermaid
graph TD
  CerialMasterService[CerialMasterService (ICerialMasterService)]
  ResourceItemSvc[ResourceItemService]
  ClassificationSvc[ClassificationService]
  EventSvc[EventService]
  SystemSvc[SystemsService]
  SerialPorts[Serial Port Hardware]
  ComPortConnection[ComPortConnection domain object]

  CerialMasterService --> ResourceItemSvc
  CerialMasterService --> ClassificationSvc
  CerialMasterService --> ComPortConnection
  CerialMasterService --> SerialPorts
  CerialMasterService --> SystemSvc

  CerialMasterInstall[CerialMasterInstall (ISystemUpdate)]
  CerialMasterInstall --> ClassificationSvc
  CerialMasterInstall --> ResourceItemSvc
  CerialMasterInstall --> EventSvc
  CerialMasterInstall --> SystemSvc

  CerialMasterSystem[CerialMasterSystem (IActivityMasterSystem)]
  CerialMasterSystem --> SystemSvc

  CerialMasterModule[CerialMasterModule (Guice bindings)]
  CerialMasterModule --> CerialMasterService

  CerialMasterGuiceConfig[CerialMasterGuiceConfig (scan config)]
  CerialMasterInclusionModule[CerialMasterInclusionModule (module inclusion)]
```

Interfaces and SPI
- `ICerialMasterService` is exposed via Guice private module and JPMS exports.
- Installers register resource item types, classifications, and event types with Activity Master services.
- System registration integrates with Activity Master system lifecycle.
