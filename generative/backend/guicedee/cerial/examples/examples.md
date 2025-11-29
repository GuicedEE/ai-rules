# Examples — GuicedEE Cerial

Fluent configuration and connect
- Configure and open a port with CRTP chaining:
```java
connection.setBaudRate(BaudRate.$9600)
          .setDataBits(DataBits.$8)
          .setParity(Parity.None)
          .setFlowControl(FlowControl.None)
          .connect();
```

Attach listeners and route events
- Use centralized events and listeners:
```java
ComPortEvents events = new ComPortEvents();
connection.addMessageListener(new DataSerialPortMessageListener(events))
          .addBytesListener(new DataSerialPortBytesListener(events));

// Status/error callbacks
events.onComPortStatusUpdate(ComPortStatus.Online);
events.onConnectError(new SerialPortException("connect failed"));
```

Idle monitoring with Vert.x timers
- Schedule lightweight idle checks via `CerialIdleMonitor`:
```java
Vertx vertx = IGuiceContext.get(Vertx.class);
vertx.setPeriodic(idleIntervalMs, id -> idleMonitor.evaluate(connection, events));
```

Cleanup and teardown
- Respect lifecycle hooks:
```java
connection.disconnect(); // idempotent; also invoked via IGuicePreDestroy
```
