# ERD — Serial Connection Model (Activity Master Cerial)

```mermaid
erDiagram
  Enterprise ||--o{ System : owns
  System ||--o{ ResourceItemType : defines
  ResourceItemType ||--o{ ResourceItem : instantiates
  ResourceItem ||--o{ ClassificationValue : stores
  ResourceItem ||--|| ComPortConnection : projects
  System ||--o{ EventType : publishes

  Enterprise {
    uuid id
    string name
  }

  System {
    uuid id
    string name
    string description
  }

  ResourceItemType {
    uuid id
    string name
    string description
  }

  ResourceItem {
    uuid id
    string value
    uuid typeId
  }

  ClassificationValue {
    uuid id
    string key
    string value
  }

  ComPortConnection {
    uuid id
    int comPort
    string comPortType
    string comPortStatus
    int baudRate
    int bufferSize
    int dataBits
    int stopBits
    string parity
  }

  EventType {
    uuid id
    string name
    string description
  }
```

Mapping to rules
- Classification keys and resource item types: see topic enums (ComPort, ComPortNumber, ComPortDeviceType, ComPortStatus, BaudRate, BufferSize, DataBits, StopBits, Parity, ComPortAllowedCharacters, ComPortEndOfMessage, SerialConnectionPort).
- Event types: RegisteredANewConnection, ClosedANewConnection, SendMessageToComPort, Message, MessageReceivedFromComPort.
- Projection: `ComPortConnection` domain object maps classification values to runtime port configuration.
