# 📘 Vert.x TCP EventBus Bridge Integration

## Purpose

This document outlines the rules, guidance, and implementation strategy for integrating the Vert.x TCP EventBus bridge into the AI Experiment architecture for secure, efficient, and lightweight asynchronous service communication.

---

# 📗 Rules

* The TCP bridge must be used for communicating between JVM and non-JVM systems asynchronously.
* Services using this bridge must register their permitted inbound and outbound addresses.
* Communications must conform to the bridge protocol format:

  ```
  <Length: uInt32><Message: JsonObject>
  ```
* Bridge messages must use the following types: `send`, `publish`, `register`, `unregister`, `ping`.
* The reply channel must match the `replyAddress` semantics defined by Vert.x.
* All addresses exposed over the TCP bridge must be documented and secured.
* Only minimal public addresses must be exposed to non-JVM clients.
* The use of domain sockets is encouraged in secure, resource-constrained environments.

---

# 📙 Guides

## Use Cases

* Cross-language service integration (e.g., Node.js or Go microservice communicating with Vert.x backend).
* Lightweight device integration where HTTP/WebSockets are not feasible.
* Internal high-throughput pub/sub without external brokers.

## TCP Message Frame Structure

```json
{
  "type": "send | publish | register | unregister | ping",
  "address": "service.address",
  "replyAddress": "optional.reply.address",
  "headers": { ... },
  "body": { ... }
}
```

* The frame must be prefixed with a 4-byte big-endian unsigned int for total JSON length.

## Permission Configuration

```java
new BridgeOptions()
  .addInboundPermitted(new PermittedOptions().setAddress("service.in"))
  .addOutboundPermitted(new PermittedOptions().setAddress("service.out"));
```

## Node.js Compatibility

* Compatible client exists in the Vert.x TCP EventBus Bridge repo.
* Reuse the same API as SockJS bridge for easy interoperability.

## GCP-Compatible Usage

* Expose via GCP internal TCP load balancer or domain sockets (GKE, Cloud Run VM connector).
* Use Cloud Armor and/or service mesh security for control over socket access.

---

# 📒 Implementation

## TCP Server Setup

```java
TcpEventBusBridge bridge = TcpEventBusBridge.create(
  vertx,
  new BridgeOptions()
    .addInboundPermitted(new PermittedOptions().setAddress("orders.queue"))
    .addOutboundPermitted(new PermittedOptions().setAddress("orders.response")));

bridge.listen(7000).onComplete(res -> {
  if (res.succeeded()) {
    System.out.println("TCP EventBus Bridge started on port 7000");
  } else {
    res.cause().printStackTrace();
  }
});
```

## Unix Domain Socket Example

```java
SocketAddress domainSocketAddress = SocketAddress.domainSocketAddress("/var/tmp/bridge.sock");
bridge.listen(domainSocketAddress).onComplete(res -> {
  if (res.succeeded()) {
    System.out.println("Bridge listening on domain socket");
  }
});
```

## Message Emission

```json
{
  "type": "send",
  "address": "orders.queue",
  "body": { "orderId": "12345" },
  "replyAddress": "client.response"
}
```

## Message Reception

Messages from the bridge use:

```json
{
  "type": "message",
  "address": "client.response",
  "body": { "status": "received" }
}
```

---
