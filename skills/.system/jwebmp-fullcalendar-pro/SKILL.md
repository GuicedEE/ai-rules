---
name: jwebmp-fullcalendar-pro
description: "Add licensed FullCalendar Premium resource scheduling and timeline views to JWebMP calendars."
metadata:
  short-description: FullCalendar Premium features
---

# JWebMP FullCalendar Pro

FullCalendar Premium integration for JWebMP with advanced calendar features.

## Premium Features

- **Resource Scheduling** — Schedule across resources
- **Timeline Views** — Horizontal timeline
- **Vertical Resource View** — Vertical resource layout
- **Resource Timeline** — Combined resource + timeline
- **Premium Plugins** — Additional view types

## Resource Configuration

```java
options.setResources(List.of(
    new Resource()
        .setId("room-a")
        .setTitle("Conference Room A")
        .setEventColor("blue"),
    new Resource()
        .setId("room-b")
        .setTitle("Conference Room B")
        .setEventColor("green")
));
```

## Resource Timeline View

```java
options
    .setInitialView("resourceTimelineDay")
    .setResourceAreaHeaderContent("Rooms")
    .setResourceAreaWidth("20%")
    .setSlotDuration("00:15:00");
```

## Vertical Resource View

```java
options.setInitialView("resourceTimeGridDay");
```

## Resource Event Binding

```java
new Event()
    .setTitle("Meeting")
    .setStart("2025-03-15T10:00:00")
    .setEnd("2025-03-15T11:00:00")
    .setResourceId("room-a");
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>full-calendar-pro</artifactId>
</dependency>
```

**Note:** Requires valid FullCalendar Premium license.

## References

- Module: `com.jwebmp.plugins.fullcalendarpro`
- FullCalendar Premium: 6.1.19
- Java: 25+
- License: Apache 2.0 (code), FullCalendar Premium license required
- [FullCalendar Premium](https://fullcalendar.io/pricing)
