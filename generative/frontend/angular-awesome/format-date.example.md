# Format Date Examples

## Basic Usage

```html
<wa-format-date [date]="myDate"></wa-format-date>
```

```typescript
// In your component
export class FormatDateExampleComponent {
  myDate = new Date();
}
```

## With Two-Way Binding

```html
<wa-format-date [(ngModel)]="selectedDate"></wa-format-date>
```

```typescript
// In your component
export class FormatDateExampleComponent {
  selectedDate = new Date();
}
```

## Date Formatting Options

### Year, Month, Day Formatting

```html
<!-- Full date (e.g., "January 1, 2023") -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric">
</wa-format-date>

<!-- Short date (e.g., "Jan 1, 2023") -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="short"
  day="numeric">
</wa-format-date>

<!-- Numeric date (e.g., "1/1/2023") -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="numeric"
  day="numeric">
</wa-format-date>

<!-- 2-digit date (e.g., "01/01/23") -->
<wa-format-date 
  [date]="myDate"
  year="2-digit"
  month="2-digit"
  day="2-digit">
</wa-format-date>
```

### Time Formatting

```html
<!-- Time only (e.g., "3:30 PM") -->
<wa-format-date 
  [date]="myDate"
  hour="numeric"
  minute="numeric">
</wa-format-date>

<!-- Time with seconds (e.g., "3:30:45 PM") -->
<wa-format-date 
  [date]="myDate"
  hour="numeric"
  minute="numeric"
  second="numeric">
</wa-format-date>

<!-- 24-hour time (e.g., "15:30") -->
<wa-format-date 
  [date]="myDate"
  hour="2-digit"
  minute="2-digit"
  hourFormat="24">
</wa-format-date>
```

### Full Date and Time

```html
<!-- Full date and time (e.g., "January 1, 2023, 3:30 PM") -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  hour="numeric"
  minute="numeric">
</wa-format-date>

<!-- With seconds and timezone (e.g., "January 1, 2023, 3:30:45 PM EST") -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  hour="numeric"
  minute="numeric"
  second="numeric"
  timeZoneName="short">
</wa-format-date>
```

### Weekday and Era

```html
<!-- With weekday (e.g., "Sunday, January 1, 2023") -->
<wa-format-date 
  [date]="myDate"
  weekday="long"
  year="numeric"
  month="long"
  day="numeric">
</wa-format-date>

<!-- With era (e.g., "January 1, 2023 AD") -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  era="short">
</wa-format-date>
```

## Localization

```html
<!-- German format -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  lang="de">
</wa-format-date>

<!-- French format -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  lang="fr">
</wa-format-date>

<!-- Japanese format -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  lang="ja">
</wa-format-date>
```

## Time Zones

```html
<!-- New York time -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  hour="numeric"
  minute="numeric"
  timeZone="America/New_York"
  timeZoneName="long">
</wa-format-date>

<!-- London time -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  hour="numeric"
  minute="numeric"
  timeZone="Europe/London"
  timeZoneName="long">
</wa-format-date>

<!-- Tokyo time -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  hour="numeric"
  minute="numeric"
  timeZone="Asia/Tokyo"
  timeZoneName="long">
</wa-format-date>
```

## Styling Examples

```html
<!-- Custom color -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  color="#3f51b5">
</wa-format-date>

<!-- Custom font size -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  fontSize="1.5rem">
</wa-format-date>

<!-- Bold text -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  fontWeight="bold">
</wa-format-date>

<!-- With background -->
<wa-format-date 
  [date]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  backgroundColor="#f0f0f0"
  padding="0.5rem">
</wa-format-date>

<!-- Inline display -->
<p>
  Today is 
  <wa-format-date 
    [date]="myDate"
    year="numeric"
    month="long"
    day="numeric"
    display="inline">
  </wa-format-date>
  and the time is
  <wa-format-date 
    [date]="myDate"
    hour="numeric"
    minute="numeric"
    display="inline">
  </wa-format-date>.
</p>
```

## In a Form

```html
<form>
  <div class="form-group">
    <label for="eventDate">Event Date:</label>
    <input 
      type="datetime-local" 
      id="eventDate" 
      [(ngModel)]="eventDate" 
      name="eventDate">
  </div>
  
  <div class="form-group">
    <label>Formatted Date:</label>
    <wa-format-date 
      [date]="eventDate"
      year="numeric"
      month="long"
      day="numeric"
      hour="numeric"
      minute="numeric">
    </wa-format-date>
  </div>
</form>
```

## In a Table

```html
<!-- Example of using format-date in a table -->
<table>
  <thead>
    <tr>
      <th>Event Name</th>
      <th>Date</th>
      <th>Formatted Date</th>
    </tr>
  </thead>
  <tbody>
    <!-- Using ngFor to iterate through events -->
    <tr *ngFor="let event of events">
      <td>{{ event.name }}</td>
      <td>{{ event.date }}</td>
      <td>
        <wa-format-date 
          [date]="event.date"
          year="numeric"
          month="long"
          day="numeric"
          hour="numeric"
          minute="numeric">
        </wa-format-date>
      </td>
    </tr>
  </tbody>
</table>
```

```typescript
// In your component
export class FormatDateExampleComponent {
  events = [
    { name: 'Conference', date: new Date('2023-06-15T09:00:00') },
    { name: 'Meeting', date: new Date('2023-06-20T14:30:00') },
    { name: 'Workshop', date: new Date('2023-07-05T10:00:00') },
    { name: 'Webinar', date: new Date('2023-07-12T16:00:00') }
  ];
}
```

## Relative Time Example

```html
<div>
  <p>
    Event: {{ eventName }}
  </p>
  <p>
    Date: 
    <wa-format-date 
      [date]="eventDate"
      year="numeric"
      month="long"
      day="numeric"
      hour="numeric"
      minute="numeric">
    </wa-format-date>
  </p>
  <p>
    <!-- You can combine with your own relative time logic -->
    {{ getRelativeTimeString(eventDate) }}
  </p>
</div>
```

```typescript
// In your component
export class FormatDateExampleComponent {
  eventName = 'Annual Conference';
  eventDate = new Date('2023-12-15T09:00:00');
  
  getRelativeTimeString(date: Date): string {
    const now = new Date();
    const diffMs = date.getTime() - now.getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    
    if (diffDays > 0) {
      return `Starts in ${diffDays} days`;
    } else if (diffDays < 0) {
      return `Ended ${Math.abs(diffDays)} days ago`;
    } else {
      return 'Happening today!';
    }
  }
}
```

## Date Range Example

```html
<div class="date-range">
  <div>
    <label>From:</label>
    <wa-format-date 
      [date]="startDate"
      year="numeric"
      month="long"
      day="numeric">
    </wa-format-date>
  </div>
  <div>
    <label>To:</label>
    <wa-format-date 
      [date]="endDate"
      year="numeric"
      month="long"
      day="numeric">
    </wa-format-date>
  </div>
</div>
```

```typescript
// In your component
export class FormatDateExampleComponent {
  startDate = new Date('2023-08-01');
  endDate = new Date('2023-08-15');
}
```
