# GuicedCerial Framework Guidelines

This document provides comprehensive guidelines for using the GuicedCerial framework, including package structure, configuration, usage patterns, and best practices.

## Table of Contents

1. [Overview](#overview)
2. [Package Structure](#package-structure)
3. [Serial Port Configuration](#serial-port-configuration)
4. [Connection Management](#connection-management)
5. [Data Transmission and Reception](#data-transmission-and-reception)
6. [Idle Monitoring](#idle-monitoring)
7. [Integration with Vert.x](#integration-with-vertx)
8. [Lifecycle Management](#lifecycle-management)
9. [Common Use Cases](#common-use-cases)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)

## Overview

GuicedCerial is a framework that provides a high-level API for serial port communication in Java applications. It is built on top of the jSerialComm library and integrates with the GuicedInjection framework for dependency injection and lifecycle management.

The framework simplifies serial port communication by providing:
- A fluent API for configuration and usage
- Integration with Guice for dependency injection
- Automatic lifecycle management
- Status monitoring and event handling
- Idle connection detection

## Package Structure

The GuicedCerial framework follows a modular package structure:

```
com.guicedee.cerial
├── CerialPortConnection.java    # Main class for serial port connections
├── CerialIdleMonitor.java       # Monitors connections for idle time
├── enumerations                 # Enumerations for configuration options
│   ├── BaudRate.java            # Available baud rates
│   ├── ComPortStatus.java       # Connection status values
│   ├── ComPortType.java         # Types of serial port devices
│   ├── DataBits.java            # Data bit options
│   ├── FlowControl.java         # Flow control methods
│   ├── FlowType.java            # Flow types
│   ├── Parity.java              # Parity checking methods
│   └── StopBits.java            # Stop bit options
└── implementations              # Implementation classes
    ├── ComPortEvents.java       # Event handling for serial ports
    ├── CerialPortConnectionProvider.java # Provider for dependency injection
    └── DataSerialPortMessageListener.java # Data listener implementation
```

## Serial Port Configuration

GuicedCerial provides several enumerations for configuring serial port connections:

- **BaudRate**: Determines the speed of data transmission (e.g., 9600, 115200)
- **DataBits**: Number of data bits in each character (5, 6, 7, 8)
- **Parity**: Error detection method (None, Odd, Even, Mark, Space)
- **StopBits**: Indicates the end of a character (1, 1.5, 2)
- **FlowControl**: Controls the rate of data transmission (None, XonXoff, RtsCts, DsrDtr)
- **FlowType**: Specific flow control type (None, XONXOFF, RTSCTS)

Example configuration:

```
// Create a connection to COM1 at 9600 baud
CerialPortConnection connection = new CerialPortConnection(1, BaudRate.$9600);

// Configure the connection
connection.setDataBits(DataBits.$8)
          .setParity(Parity.None)
          .setStopBits(StopBits.$1)
          .setFlowControl(FlowControl.None);
```

## Connection Management

### Creating a Connection

To create a serial port connection, use the `CerialPortConnection` constructor with the COM port number and baud rate. You can also specify an idle timeout in seconds.

### Connecting and Disconnecting

Use the `connect()` method to establish a connection and `disconnect()` to close it.

### Status Monitoring

Monitor the connection status using the `ComPortStatus` enumeration and status update callbacks:

- Set a status update callback with `onComPortStatusUpdate()`
- Set an error callback with `setComPortError()`
- Check the current status with `getComPortStatus()`

Available status values include:
- `Offline` - Port is disconnected
- `Idle` - Port is connected but inactive
- `Silent` - Port is connected but not receiving data
- `Running` - Port is actively communicating
- `Logging` - Port is logging data
- `Simulation` - Port is in simulation mode
- `Missing` - Port is not available
- `GeneralException` - An error occurred
- `OperationInProgress` - An operation is in progress
- `FileTransfer` - A file transfer is in progress
- `Opening` - Port is in the process of opening

## Data Transmission and Reception

### Sending Data

Send data through a serial port using the `write()` method, which automatically adds a newline character if needed.

### Receiving Data

Receive data by setting a data reception callback with `setComPortRead()`.

## Idle Monitoring

GuicedCerial includes an idle monitoring system that detects when a connection has been inactive for a specified period.

### Configuration

The idle monitor can be configured with:
- Initial delay: Time before monitoring starts
- Period: Time between checks
- Idle timeout: Time after which a connection is considered idle

### Starting and Stopping

The idle monitor is automatically started when a connection is established and stopped when the connection is closed. However, you can manually control it with the `begin()` and `end()` methods.

## Integration with Vert.x

GuicedCerial integrates with Vert.x for asynchronous operations, particularly for idle monitoring. The idle monitor uses Vert.x's periodic timer to check for idle connections.

## Lifecycle Management

GuicedCerial integrates with the GuicedInjection framework for lifecycle management. The `CerialPortConnection` class implements `IGuicePreDestroy`, ensuring that connections are properly closed when the application shuts down.

## Common Use Cases

### Device Communication

For general device communication, create and configure a connection, connect to the device, set up data reception, send commands, and disconnect when done.

### Scanner Integration

For barcode scanner integration, create a connection with the appropriate COM port type, connect to the scanner, and process scanned barcodes.

### Printer Control

For label printer control, create a connection with the appropriate COM port type, connect to the printer, and send print commands.

## Best Practices

1. **Always Close Connections**: Always disconnect from ports when they are no longer needed to free up resources.

2. **Handle Exceptions**: Implement error handling using the `setComPortError` method to catch and handle exceptions.

3. **Monitor Connection Status**: Use the `onComPortStatusUpdate` method to monitor and respond to status changes.

4. **Configure Appropriate Timeouts**: Set appropriate idle timeouts based on your application's requirements.

5. **Use Method Chaining**: Take advantage of the fluent API with method chaining for cleaner code.

6. **Log Communication**: Enable logging to track communication for debugging purposes.

7. **Check Port Availability**: Always check if a port is available before attempting to connect.

8. **Use Dependency Injection**: Leverage Guice dependency injection for managing connections in larger applications.

## Troubleshooting

### Common Issues

1. **Port Not Found**: Ensure the COM port number is correct and the device is properly connected.

2. **Permission Denied**: Ensure your application has the necessary permissions to access the serial port.

3. **Port Already in Use**: Check if another application is using the port.

4. **Communication Errors**: Verify that the baud rate, data bits, parity, stop bits, and flow control settings match the device requirements.

5. **Data Not Received**: Ensure the data reception callback is properly set up and the device is sending data in the expected format.

### Debugging Tips

1. **Enable Logging**: GuicedCerial automatically logs communication to files named "COMx.log" where x is the port number.

2. **Check Connection Status**: Monitor the connection status to identify issues.

3. **Test with Simple Commands**: Start with simple commands to verify basic communication before sending complex data.

4. **Use a Serial Port Monitor**: Use external tools to monitor serial port communication for verification.

5. **Verify Hardware**: Ensure cables are properly connected and the hardware is functioning correctly.