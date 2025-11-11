## Format Date Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Component Summary

This Angular wrapper enables declarative use of the `<wa-format-date>` Web Awesome component, exposing inputs and binding features in Angular style.

### Selector

```ts
waFormatDate
```

### Inputs

| Input          | Type                                                      | Description                                                                                                                               |
| -------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `date`         | `Date \| string`                                          | Date/time to format. Accepts ISO 8601 or a JS `Date` object. Defaults to current date/time. Supports `ngModel` via binding to this input. |
| `weekday`      | `'narrow' \| 'short' \| 'long'`                           | Format of the weekday.                                                                                                                    |
| `era`          | `'narrow' \| 'short' \| 'long'`                           | Format of the era.                                                                                                                        |
| `year`         | `'numeric' \| '2-digit'`                                  | Format of the year.                                                                                                                       |
| `month`        | `'numeric' \| '2-digit' \| 'narrow' \| 'short' \| 'long'` | Format of the month.                                                                                                                      |
| `day`          | `'numeric' \| '2-digit'`                                  | Format of the day.                                                                                                                        |
| `hour`         | `'numeric' \| '2-digit'`                                  | Format of the hour.                                                                                                                       |
| `minute`       | `'numeric' \| '2-digit'`                                  | Format of the minute.                                                                                                                     |
| `second`       | `'numeric' \| '2-digit'`                                  | Format of the second.                                                                                                                     |
| `timeZoneName` | `'short' \| 'long'`                                       | Format for the time zone name.                                                                                                            |
| `timeZone`     | `string`                                                  | IANA time zone name (e.g. "America/New\_York").                                                                                           |
| `hourFormat`   | `'auto' \| '12' \| '24'`                                  | Enforces 12- or 24-hour format or lets the browser decide. Default: `'auto'`.                                                             |
| `lang`         | `string`                                                  | Sets the locale for formatting (e.g. "en", "fr").                                                                                         |

### Styling Inputs

These Angular-style inputs reflect Web Awesome's CSS custom properties and apply to the host element:

* `color`
* `fontSize`
* `fontWeight`
* `backgroundColor`
* `padding`
* `margin`
* `display`

If more CSS properties are exposed in the Web Awesome spec for this component, they must also be reflected here.

### Outputs

None.

### Notes

* This component is display-only. It is not interactive and does not emit events.
* Supports `ngModel` for binding date values in template-driven forms by binding to the `date` attribute of the Web Awesome component.
* Reactive forms are not supported and should not be used.
* Date parsing follows `Date.parse()` and should use ISO 8601 strings for maximum compatibility.

### Example Usage

```html
<wa-format-date
  waFormatDate
  [(ngModel)]="myDate"
  year="numeric"
  month="long"
  day="numeric"
  hour="numeric"
  minute="numeric"
  hourFormat="24"
  lang="fr">
</wa-format-date>
```

This will render the provided `myDate` value localized in French using full numeric date and 24-hour time.
