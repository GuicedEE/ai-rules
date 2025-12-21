# Sequence — Add or Update COM Port

```mermaid
sequenceDiagram
  participant Caller
  participant Service as CerialMasterService
  participant ResourceItemSvc as ResourceItemService
  participant ClassificationSvc as ClassificationService
  participant SystemSvc as ActivityMasterSystemSvc
  participant SerialPorts as Serial Port Hardware

  Caller->>Service: addOrUpdateConnection(session, comPort, system, token)
  Service->>ResourceItemSvc: findResourceItemType(SerialConnectionPort)
  ResourceItemSvc-->>Service: resourceItemType
  Service->>ResourceItemSvc: create(resource item with COM port value)
  ResourceItemSvc-->>Service: resourceItem persisted
  Service->>ClassificationSvc: add ComPort, ComPortNumber, DeviceType, Status
  Service->>ClassificationSvc: add BaudRate, BufferSize, DataBits, StopBits, Parity
  ClassificationSvc-->>Service: classifications applied
  Service-->>Caller: ComPortConnection with id and classifications
```

Notes
- Mutiny session provided by caller; no internal session creation.
- Hardware identity originates from `ComPortConnection` supplied by caller (built from jSerialComm scan).
