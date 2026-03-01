# Services & SPI Registration — GuicedEE Inject Client

This guide documents the primary Service Provider Interfaces (SPIs) and how to register implementations. Policy: dual registration is mandatory — declare providers in BOTH META-INF/services AND JPMS provides clauses in module-info.java.

Relevant JPMS module name
- com.guicedee.client

Key SPIs (examples)
- com.guicedee.client.services.lifecycle.IGuicePreStartup
- com.guicedee.client.services.lifecycle.IGuicePostStartup
- com.guicedee.client.services.lifecycle.IGuiceModule
// Additional lifecycle SPIs
- com.guicedee.client.services.lifecycle.IGuicePreDestroy
- com.guicedee.client.services.lifecycle.IGuicePreDestroy
- com.guicedee.client.services.lifecycle.IGuiceConfigurator
- com.guicedee.client.services.lifecycle.IOnCallScopeEnter
- com.guicedee.client.services.lifecycle.IOnCallScopeExit
// WebSocket SPI surface (client-side)
- com.guicedee.client.services.websocket.IWebSocketMessageReceiver
- com.guicedee.client.services.websocket.IWebSocketAuthDataProvider
- com.guicedee.client.services.websocket.IWebSocketPreConfiguration
- com.guicedee.client.services.websocket.GuicedWebSocketOnAddToGroup
- com.guicedee.client.services.websocket.GuicedWebSocketOnRemoveFromGroup
- com.guicedee.client.services.websocket.GuicedWebSocketOnPublish

META-INF/services registration (mandatory)
Create a file for each SPI you implement under META-INF/services with the fully-qualified SPI name, containing the fully-qualified implementation class name(s), one per line.

Examples
1) Register a lifecycle module (IGuiceModule)
File: src/main/resources/META-INF/services/com.guicedee.client.services.lifecycle.IGuiceModule
```
com.example.MyClientModule
```

2) Register a pre-startup hook (IGuicePreStartup)
File: src/main/resources/META-INF/services/com.guicedee.client.services.lifecycle.IGuicePreStartup
```
com.example.BootstrapTasks
```

3) Register a WebSocket message receiver (IWebSocketMessageReceiver)
File: src/main/resources/META-INF/services/com.guicedee.client.services.websocket.IWebSocketMessageReceiver
```
com.example.ChatMessageReceiver
```

4) Register WebSocket hooks (optional)
Files and example entries:
- src/main/resources/META-INF/services/com.guicedee.client.services.websocket.GuicedWebSocketOnAddToGroup
```
com.example.WsAddToGroupHook
```
- src/main/resources/META-INF/services/com.guicedee.client.services.websocket.GuicedWebSocketOnRemoveFromGroup
```
com.example.WsRemoveFromGroupHook
```
- src/main/resources/META-INF/services/com.guicedee.client.services.websocket.GuicedWebSocketOnPublish
```
com.example.WsPublishHook
```

JPMS provides clauses (mandatory — in addition to META-INF/services)
Declare providers using provides ... with ... clauses in your module-info.java. This is required for test cases and whenever any dependency or your own artifact participates on the module-path (including automatic modules). Always specify providers in module-info.java AND in META-INF/services.

Example module-info.java snippet
```java
module com.example.app {
  requires com.guicedee.client;

  provides com.guicedee.client.services.lifecycle.IGuiceModule
      with com.example.MyClientModule;
  provides com.guicedee.client.services.lifecycle.IGuicePreStartup
      with com.example.BootstrapTasks;
  // WebSocket SPIs (client-side)
  provides com.guicedee.client.services.websocket.IWebSocketMessageReceiver
      with com.example.ChatMessageReceiver;
  provides com.guicedee.client.services.websocket.GuicedWebSocketOnAddToGroup
      with com.example.WsAddToGroupHook;
  provides com.guicedee.client.services.websocket.GuicedWebSocketOnRemoveFromGroup
      with com.example.WsRemoveFromGroupHook;
  provides com.guicedee.client.services.websocket.GuicedWebSocketOnPublish
      with com.example.WsPublishHook;
}
```

Test modules policy
- If you have a test module (src/test/java/module-info.java), repeat the provides clauses there as appropriate for test-only implementations, and keep META-INF/services in src/test/resources/META-INF/services synchronized. Dual registration ensures consistent discovery on both class-path and module-path.

Coordinates and dependencies (Maven)
- Add the client library via the GuicedEE BOMs to align versions. Example:
```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.guicedee</groupId>
      <artifactId>standalone-bom</artifactId>
      <version>${guicedee.version}</version>
      <scope>import</scope>
      <type>pom</type>
    </dependency>
  </dependencies>
  </dependencyManagement>

<dependencies>
  <dependency>
    <groupId>com.guicedee</groupId>
    <artifactId>client</artifactId>
  </dependency>
  <!-- Optional: JSpecify and Mutiny if you implement reactive or nullness-annotated APIs -->
  <dependency>
    <groupId>org.jspecify</groupId>
    <artifactId>jspecify</artifactId>
    <scope>provided</scope>
  </dependency>
  <dependency>
    <groupId>io.smallrye.reactive</groupId>
    <artifactId>mutiny</artifactId>
  </dependency>
 </dependencies>
```

See also
- Topic index — ../README.md
- Examples — ../examples/examples.md
- Nullness & Reactive Rules — ../rules/nullness-reactive.md
