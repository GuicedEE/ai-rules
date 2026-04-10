---
name: jwebmp-fullcalendar
description: Full-featured calendar integration for JWebMP with FullCalendar 6.1.19 and Angular 21. Provides server-driven calendar configuration with drag-and-drop event scheduling, multiple calendar views (day, week, month, list, timeline), timezone support, localization, recurring events, resource management, and Bootstrap 5 theming. Use when working with FullCalendar, creating scheduling interfaces, building event calendars, managing resources, or implementing calendar features in JWebMP applications.
metadata:
  short-description: FullCalendar 6.1.19 calendar integration
---

# JWebMP FullCalendar

Full-featured calendar integration for JWebMP with FullCalendar 6.1.19 and Angular 21.

## Core Features

- **Full Calendar Views** — Day, Week, Month, List, Timeline
- **Drag & Drop Events** — Interactive scheduling
- **Timezone Support** — IANA timezone database via Moment Timezone
- **Localization** — 50+ locales
- **Event Sources** — JSON feeds, functions, Google Calendar
- **Recurring Events** — RRule support
- **Resource Management** — Resource timeline for scheduling
- **Bootstrap 5 Theming**
- **Mobile Adaptive** — Responsive with touch support

## Quick Start

### Basic Calendar Configuration

```java
public class CalendarConfig {
    public FullCalendarOptions getCalendarOptions() {
        return new FullCalendarOptions()
            .setInitialView("dayGridMonth")
            .setLocale("en")
            .setTimeZone("UTC")
            .setEditable(true)
            .setHeaderToolbar(new Toolbar()
                .setLeft("prev,next today")
                .setCenter("title")
                .setRight("dayGridMonth,timeGridWeek,timeGridDay,listWeek"))
            .setEvents(getEvents());
    }

    private List<Event> getEvents() {
        return List.of(
            new Event()
                .setTitle("Team Meeting")
                .setStart("2025-03-15T10:00:00")
                .setEnd("2025-03-15T11:00:00")
                .setBackgroundColor("#4285F4")
        );
    }
}
```

### Angular Integration

```typescript
import { Component, OnInit } from '@angular/core';
import { CalendarOptions } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';

@Component({
  selector: 'app-calendar',
  template: `<full-calendar [options]="calendarOptions"></full-calendar>`
})
export class CalendarComponent implements OnInit {
  calendarOptions?: CalendarOptions;

  ngOnInit() {
    this.calendarOptions = {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
      initialView: 'dayGridMonth',
      editable: true,
      selectable: true,
      dateClick: (arg) => this.handleDateClick(arg),
      eventClick: (arg) => this.handleEventClick(arg)
    };
  }
}
```

## Calendar Views

| View Type | Plugin | Description |
|---|---|---|
| `dayGridMonth` | daygrid | Month view with day cells |
| `dayGridWeek` | daygrid | Week view with day cells |
| `dayGridDay` | daygrid | Single day view |
| `timeGridWeek` | timegrid | Week view with time slots |
| `timeGridDay` | timegrid | Day view with time slots |
| `listWeek` | list | List view for week |
| `listMonth` | list | List view for month |
| `listYear` | list | List view for year |

## Configuration Options

### Display Options

```java
options
    .setInitialView("dayGridMonth")
    .setInitialDate("2025-03-15")
    .setWeekends(true)
    .setDayMaxEvents(3)
    .setNowIndicator(true);
```

### Interaction Options

```java
options
    .setEditable(true)
    .setSelectable(true)
    .setSelectMirror(true)
    .setEventStartEditable(true)
    .setEventDurationEditable(true);
```

### Localization

```java
options
    .setLocale("en")  // en, es, fr, de, etc.
    .setTimeZone("America/New_York")  // IANA timezone
    .setDirection("ltr");  // ltr/rtl
```

### Event Defaults

```java
options
    .setDefaultAllDay(false)
    .setDefaultTimedEventDuration("01:00")
    .setSlotDuration("00:30");
```

### Toolbars

```java
options
    .setHeaderToolbar(new Toolbar()
        .setLeft("prev,next today")
        .setCenter("title")
        .setRight("dayGridMonth,timeGridWeek,timeGridDay"))
    .setFooterToolbar(new Toolbar()
        .setLeft("customButton")
        .setCenter("")
        .setRight(""));
```

### Business Hours

```java
options.setBusinessHours(new BusinessHours()
    .setDaysOfWeek([1,2,3,4,5])
    .setStartTime("09:00")
    .setEndTime("17:00"));
```

## Event Model

```java
Event event = new Event()
    .setId("evt-1")
    .setTitle("Team Meeting")
    .setStart("2025-03-15T10:00:00")
    .setEnd("2025-03-15T11:00:00")
    .setAllDay(false)
    .setUrl("https://example.com/meeting")
    .setBackgroundColor("#4285F4")
    .setBorderColor("#1967D2")
    .setTextColor("#FFFFFF")
    .setClassNames("important", "team-event")
    .setEditable(true)
    .setExtendedProps(Map.of(
        "department", "Engineering",
        "room", "Conference A"
    ));
```

## Event Sources

### Static Events

```java
options.setEvents(List.of(event1, event2, event3));
```

### JSON Feed

```java
options.setEventSources(List.of(
    new EventSource()
        .setUrl("/api/events")
        .setMethod("GET"),
    new EventSource()
        .setUrl("/api/holidays")
        .setColor("red")
        .setBackgroundColor("#FFEBEE")
));
```

## REST API Example

```java
@Path("/api/calendar")
@Produces(MediaType.APPLICATION_JSON)
public class CalendarResource {

    @GET
    @Path("/options")
    public FullCalendarOptions getOptions() {
        return new FullCalendarOptions()
            .setInitialView("dayGridMonth")
            .setEditable(true)
            .setSelectable(true);
    }

    @GET
    @Path("/events")
    public List<Event> getEvents() {
        return eventService.findAll().stream()
            .map(e -> new Event()
                .setId(e.getId())
                .setTitle(e.getTitle())
                .setStart(e.getStartTime())
                .setEnd(e.getEndTime()))
            .collect(Collectors.toList());
    }

    @POST
    @Path("/events")
    public Event createEvent(Event event) {
        return eventService.save(event);
    }

    @PUT
    @Path("/events/{id}")
    public Event updateEvent(@PathParam("id") String id, Event event) {
        return eventService.update(id, event);
    }

    @DELETE
    @Path("/events/{id}")
    public Response deleteEvent(@PathParam("id") String id) {
        eventService.delete(id);
        return Response.noContent().build();
    }
}
```

## Common Use Cases

### Employee Scheduling

```java
new FullCalendarOptions()
    .setInitialView("timeGridWeek")
    .setSlotMinTime("06:00:00")
    .setSlotMaxTime("22:00:00")
    .setSlotDuration("00:30:00")
    .setBusinessHours(new BusinessHours()
        .setDaysOfWeek([1,2,3,4,5])
        .setStartTime("09:00")
        .setEndTime("17:00"));
```

### Event Dashboard

```java
new FullCalendarOptions()
    .setInitialView("dayGridMonth")
    .setEditable(true)
    .setSelectable(true)
    .setEventSources(List.of(
        new EventSource().setUrl("/api/events"),
        new EventSource().setUrl("/api/holidays").setColor("red")
    ));
```

### Multi-Timezone Conference

```java
new FullCalendarOptions()
    .setInitialView("timeGridWeek")
    .setTimeZone(userTimezone)
    .setLocale(getUserLocale())
    .setNowIndicator(true)
    .setSlotLabelFormat(Map.of(
        "hour", "2-digit",
        "minute", "2-digit",
        "meridiem", "short"
    ));
```

### Resource Timeline

```java
new FullCalendarOptions()
    .setInitialView("resourceTimeGridDay")
    .setResources(loadRooms())
    .setEvents(loadBookings())
    .setEditable(true)
    .setResourceAreaHeaderContent("Conference Rooms")
    .setSlotMinTime("08:00:00")
    .setSlotMaxTime("20:00:00");
```

## NPM Dependencies

```json
{
  "dependencies": {
    "@fullcalendar/angular": "^6.1.19",
    "@fullcalendar/daygrid": "^6.1.19",
    "@fullcalendar/timegrid": "^6.1.19",
    "@fullcalendar/list": "^6.1.19",
    "@fullcalendar/interaction": "^6.1.19",
    "@fullcalendar/bootstrap5": "^6.1.19",
    "@fullcalendar/moment-timezone": "^6.1.19"
  }
}
```

## JPMS Module

```java
module com.jwebmp.plugins.fullcalendar {
    requires transitive com.jwebmp.core;
    requires transitive com.jwebmp.plugins.angular;
    requires jakarta.validation;

    exports com.jwebmp.plugins.fullcalendar;
    exports com.jwebmp.plugins.fullcalendar.options;
}
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>full-calendar</artifactId>
</dependency>
```

## Key Classes

- `FullCalendarOptions` — Main calendar configuration
- `Event` — Event data model
- `EventSource` — Event source configuration
- `Toolbar` — Toolbar configuration
- `BusinessHours` — Business hours configuration
- `View` — View configuration

## References

- Module: `com.jwebmp.plugins.fullcalendar`
- FullCalendar: 6.1.19
- Angular: 20
- Java: 25+
- License: Apache 2.0
- [FullCalendar Docs](https://fullcalendar.io/docs)
- [Angular FullCalendar](https://github.com/fullcalendar/fullcalendar-angular)
