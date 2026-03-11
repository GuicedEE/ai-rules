---
name: guicedee-cerial
description: "Lifecycle-aware serial port connectivity for GuicedEE using jSerialComm and Vert.x 5: @Named CerialPortConnection injection by port number, CRTP-fluent configuration, automatic reconnect with exponential backoff, idle monitoring, MicroProfile Health reporting, status lifecycle (12 states), message-delimited reads, per-port logging, and optional OpenTelemetry tracing. Use when connecting to serial ports, configuring baud rate and flow control, handling serial data, or monitoring serial device health."
metadata:
  short-description: Serial port connectivity with jSerialComm inside GuicedEE
---

# GuicedEE Cerial

Lifecycle-aware serial port connectivity for GuicedEE using jSerialComm and Vert.x 5.

## Core Concept

Inject `@Named` `CerialPortConnection` singletons by port number, configure with CRTP-fluent setters, and let the framework handle connection lifecycle, idle monitoring, automatic reconnect with exponential backoff, MicroProfile Health reporting, and optional OpenTelemetry tracing.

## Required Flow

1. Add `com.guicedee:cerial` dependency.
2. Inject a named connection by port number:
   ```java
   @Inject @Named("1")
   private CerialPortConnection connection;
   ```
3. Configure and connect:
   ```java
   connection.setBaudRate(BaudRate.$9600)
             .setDataBits(DataBits.$8)
             .setParity(Parity.None)
             .setStopBits(StopBits.$1)
             .setFlowControl(FlowControl.None)
             .connect();
   ```
4. Send and receive data:
   ```java
   // Write
   connection.write("Hello, device!");

   // Read (callback on Vert.x worker thread)
   connection.setComPortRead((data, port) -> {
       String message = new String(data).trim();
       System.out.println("Received: " + message);
   });
   ```
5. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.cerial;
       opens my.app.serial to com.google.guice;
   }
   ```

## Port Configuration

| Method | Default | Values |
|---|---|---|
| `setBaudRate()` | `BaudRate.$9600` | `$300` to `$256000` |
| `setDataBits()` | `DataBits.$8` | `$5`, `$6`, `$7`, `$8` |
| `setParity()` | `Parity.None` | `None`, `Odd`, `Even`, `Mark`, `Space` |
| `setStopBits()` | `StopBits.$1` | `$1`, `$1_5`, `$2` |
| `setFlowControl()` | `FlowControl.None` | `None`, `RtsCtsIn`, `RtsCtsOut`, `XonXoffIn`, `XonXoffOut` |

## Connection Status

12 states grouped into Exception, Transitional, and Active sets:
- **Active:** `Silent`, `Running`, `Logging`, `Simulation`
- **Transitional:** `Opening`, `OperationInProgress`, `FileTransfer`
- **Exception:** `Offline`, `Missing`, `Failed`, `InUse`, `GeneralException`

## Reconnect with Exponential Backoff

- Starts at 1 s, doubles each attempt, capped at 60 s
- Resets on successful reconnect
- Configurable: `setInitialReconnectDelaySeconds()`, `setMaxReconnectDelaySeconds()`

## Idle Monitoring

`CerialIdleMonitor` detects silent connections via Vert.x periodic timer. Status transitions to `Silent` when idle beyond threshold.

## Health Check

`CerialHealthCheck` implements `@Liveness`, `@Readiness`, `@Startup` and reports status of all active connections (requires `health` module).

## Non-Negotiable Constraints

- Module must `requires com.guicedee.cerial;`.
- Ports 0–999 are pre-bound as `@Named("0")` through `@Named("999")` singletons.
- Serial packages must `opens` to `com.google.guice`.
- The module is registered automatically — no `provides` needed.
- Graceful shutdown via `IGuicePreDestroy` closes all open ports.

