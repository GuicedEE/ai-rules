# Events & Resource Delivery — FullCalendar Pro

## Overview
FullCalendar Pro relies on GuicedEE WebSocket listeners to push resource and event payloads to the Angular client before the view renders. The server registers `InitialResourceEventsReceiver` on the `listenerName + 'Resources'` channel and reuses the `FullCalendar` base listener for `listenerName` (events) and `listenerName + 'Options'` (options/flags). `FullCalendarPro.fetchData()` orchestrates these calls, so the client always requests options and resources together.

## Usage Patterns & Minimal Example
1. Override `FullCalendarPro.getInitialResources()` so the receiver can call `IGuiceContext.get(actionClass)` and ask for the serialized `FullCalendarResourceItemsList`.
2. Optionally override `FullCalendarPro.registerWebSocketListeners()` to add additional listeners (e.g., log hooks) but always call `super.registerWebSocketListeners()` so the default resource/event hooks stay wired.
3. Use `InitialResourceEventsReceiver.action()` as the template for any custom channels: parse `AjaxCall<?>` to pull `listenerName`, make domain calls, then `response.addDataResponse(listenerName, payload)` so the Angular event observer can hydrate `calendarOptions.resources`.

```java
public class ResourceEventsReceiver extends WebSocketAbstractCallReceiver<ResourceEventsReceiver> {
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        return Uni.createFrom().item(() -> {
            String listener = call.getUnknownFields().get("listenerName").toString();
            List<FullCalendarResource> resources = loadResourcesFor(listener);
            response.addDataResponse(listener, resources);
            return response;
        });
    }
}
```

## Inputs / Outputs / Events
- Requests originate from the Angular `fetchData()` method created by `FullCalendarPro.methods()`; it sends three messages: `listenerName + 'Options'`, `listenerName + 'Resources'`, and the base `listenerName` event stream.
- `InitialResourceEventsReceiver` uses reflection to recreate the action class, then calls `getInitialResources()` and serializes the return value before pushing it back on the WebSocket channel. If the payload is null, the client falls back to an empty `FullCalendarResourceItemsList` so rendering continues safely.
- The event bus subscriber (`this.eventBusService.listen(...)`) deserializes the data and assigns it to `calendarOptions.resources`, triggering `handleResourceEvents()` on the Angular side.

## Styling & Theming
- Resource updates carry `extendedProps`, `title`, `groupId`, and custom fields; document the expected field names in `implementation.md` if templates rely on them so the architecture diagrams remain accurate.

## Accessibility / Performance Constraints
- Keep the resource list lean; fetching hundreds of rows can slow down the Angular view because the payload must be serialized twice (options + resources). Consider paging or server filters if the dataset grows.
- Always guard the listener registration with `IGuicedWebSocket.isWebSocketReceiverRegistered(...)` so duplicate listeners are not added during redeployments.

## See also
- `rules/generative/frontend/jwebmp/fullcalendar-pro/angular-integration.rules.md`
- `rules/generative/backend/guicedee/client/README.md`
- Architecture: `docs/architecture/sequence-runtime-wiring.md`, `docs/architecture/c4-component-fullcalendar-pro.md`
