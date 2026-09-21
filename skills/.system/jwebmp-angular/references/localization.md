# Locale formatting and user preferences

Use the TypeScriptClient annotation on the `@NgApp` class or its boot component:

```java
import com.jwebmp.core.base.angular.client.annotations.angular.NgLocale;

@NgLocale(value = "en-ZA", supportedLocales = {"de", "fr"})
```

The app declaration takes precedence over the boot component; annotations are
inherited. `AngularLocaleConfiguration` in the Angular compiler setup registers
locale data in `app.config.ts` before bootstrap and supplies the app-wide
`LOCALE_ID`. No annotation leaves existing generation unchanged. Prefer this to
manual locale imports, constructor registration, and provider annotations.

`dataLocale` optionally selects a different Angular data file for the default ID.
`en-US` uses Angular's `en` file. `extraData = true` includes extended day-period
data for both the default and additional locales. Additional IDs use matching
Angular locale files and are deduplicated; check that the files exist in the
installed `@angular/common/locales` package.

For live user selection, reference the root-scoped service from each component
that selects or displays the preference:

```java
import com.jwebmp.core.base.angular.client.services.LocaleService;

@NgComponentReference(LocaleService.class)
@NgMethod("useGerman(): void { this.localeService.setLocale('de'); }")
```

This generates `public localeService: LocaleService` in the constructor.
The service exposes `defaultLocale`, the read-only `locale()` signal,
`setLocale(id)`, and `resetLocale()`. Pass the signal explicitly to formatting pipes:

```html
{{ orderDate | date:'longDate':undefined:localeService.locale() }}
{{ amount | number:'1.2-2':localeService.locale() }}
{{ amount | currency:'ZAR':'symbol':'1.2-2':localeService.locale() }}
{{ ratio | percent:'1.0-2':localeService.locale() }}
```

Signal-bound formatting updates without reload, including with OnPush.
`LOCALE_ID` remains the startup default: pipes without an explicit locale and
third-party controls do not automatically switch. Wire controls through their own
locale APIs. Currency code and timezone remain independent choices.

`setLocale` checks registered data before changing state; missing data throws and
preserves the current preference. Angular parent-language fallback still applies.
State belongs to the current Angular application instance. Persist and restore it
through the consumer's user-profile flow; reset on logout/user changes as needed.
The service does not persist cookies, browser storage, or backend records, and does
not translate application messages.

Change Java generator/consumer sources, then regenerate and rebuild Angular.
Relevant checks: `LocaleServiceRenderingTest` in tsclient,
`AngularLocaleConfigurationTest` in angular, and tsclient's
`src/test/scripts/locale-runtime.mjs` for generated TypeScript and Angular runtime
formatting. Distinguish these checks from live consumer/browser verification.

