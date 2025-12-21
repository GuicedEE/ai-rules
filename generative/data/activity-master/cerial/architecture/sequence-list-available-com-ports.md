# Sequence — List Available COM Ports

```mermaid
sequenceDiagram
  participant Caller
  participant Service as CerialMasterService
  participant SerialPorts as Serial Port Hardware
  participant SystemSvc as ActivityMasterSystemSvc
  participant ResourceItemSvc as ResourceItemService

  Caller->>Service: listAvailableComPorts(session, enterprise)
  Service->>SerialPorts: scan system ports (cached)
  SerialPorts-->>Service: [COMx...]
  Service->>SystemSvc: get system + token (CerialMaster)
  Service->>ResourceItemSvc: findByClassificationAll(SerialConnectionPort, ComPortNumber)
  ResourceItemSvc-->>Service: registered COM numbers
  Service-->>Caller: availablePorts = scanned - registered
```

Notes
- OS scan cached per process; refresh requires restart or explicit cache clearing.
- Registered ports derive from Activity Master resource items with `SerialConnectionPort` type and `ComPortNumber` classification.
