# Runtime translations

Use `@NgTranslations` on the `@NgApp` class or boot component:

```java
@NgTranslations(defaultLanguage = "en", supportedLanguages = {"en", "de", "fr"}, namespaces = {"orders"})
@NgTranslationSource(namespace = "orders", resource = "META-INF/jwebmp/i18n/orders")
@NgTranslationSource(namespace = "orders", url = "/rest/translations/orders/{language}", priority = 200)
```

JAR libraries package defaults as `META-INF/jwebmp/i18n/<namespace>/<language>.json`.
The Angular generator reads those files from the shared ClassGraph scan and emits
merged `public/i18n/jwebmp/<language>.json` bundles plus a manifest. An empty
`namespaces` list includes all discovered namespaces. Library defaults have priority
`0`; classpath application sources and URL sources default to `100`. Higher priority
overrides lower priority. Equal-priority conflicting keys fail with both origins.
Nested JSON objects become dotted keys; duplicate and prototype-polluting keys fail.

When the annotation is present, package generation adds Transloco 8.4 and, unless
`messageFormat = false`, `@jsverse/transloco-messageformat`. The generated
`TranslationService` is root-scoped and referenced with:

```java
@NgComponentReference(TranslationService.class)
```

It loads the selected and default languages through Angular `HttpClient`, applies
HTTP interceptors, deduplicates requests, and rejects stale responses after a new
language or context wins. Optional URL sources preserve bundled values when they
fail; required sources reject the language change. Use `setLanguage`,
`setLanguageAndLocale`, `reload`, and `clearContext` for lifecycle control.

For dictionaries returned by an existing REST client, call
`applyTranslations(language, namespace, data)`. An optional context argument can
reject a response that belongs to an older tenant/user context. Use
`{{ 'orders.save' | transloco }}` or the `transloco` directive in generated templates.
ICU plural/select messages are enabled by default. Translation language and Angular
formatting locale remain independent; `clearContext()` should run on logout or a
tenant/user switch. Persistence is the consumer's responsibility.

Relevant validation is `AngularTranslationConfigurationTest`,
`LocaleServiceRenderingTest`, the tsclient `translation-runtime.mjs` script, and
`translation-aot.mjs`. These verify source discovery, merge precedence, conflict
diagnostics, runtime interpolation/plurals, custom dictionaries, stale-response
handling, context isolation, and Angular compiler output.
