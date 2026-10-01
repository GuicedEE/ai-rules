# Geography country flags and Image Master

Use this contract for country flags, `CountryFlagCatalog`, geography-linked images,
and Image Master serving. Flags belong to Geography countries whose names are
two-letter codes such as `ZA`, rather than numeric country identifiers.

## Modules and host integration

| Purpose | Maven artifact | JPMS module |
| --- | --- | --- |
| Country geography and optional resource SPI | `com.activity-master:geography-master` | `com.guicedee.activitymaster.geography` |
| Binary image storage and retrieval | `com.activity-master:image-master` | `com.guicedee.activitymaster.imagemaster` |
| Bundled flags, country links, installer | `com.activity-master:geo-country-flags` | `com.guicedee.activitymaster.geography.flags` |

Add `geo-country-flags` to the consuming host. Use matching ActivityMaster versions
so Geography includes `IGeographyCountryResourceProvider`. The flags module depends
on Geography and Images. A named host module that directly calls its classes uses
`requires com.guicedee.activitymaster.geography.flags;`.

```xml
<dependency>
    <groupId>com.activity-master</groupId>
    <artifactId>geo-country-flags</artifactId>
    <version>${activitymaster.version}</version>
</dependency>
```

The module registers its country resource provider, system update and Guice scan
inclusion through JPMS `provides` and classpath `META-INF/services`. Geography
declares `uses IGeographyCountryResourceProvider`; it remains usable without flags.
SPI discovery provides integration, while the host's authorized enterprise/system
context and current tokens determine access.

## Catalog contract

`CountryFlagCatalog` is a Guice singleton in
`com.guicedee.activitymaster.geography.flags`. It loads the bundled index
`/country-flags/country-codes.txt` and `/country-flags/{lowercase-code}.png` into an
unmodifiable map. Loading does not contact a CDN or the database. A missing index,
missing indexed file or I/O failure fails construction with `IllegalStateException`.

| Method | Behavior |
| --- | --- |
| `static String normalize(String code)` | Accepts exactly two ASCII letters, case-insensitively; returns uppercase using `Locale.ROOT`. Null, digits, whitespace, longer codes and paths throw `IllegalArgumentException`. It does not trim input. |
| `Set<String> countryCodes()` | Returns the immutable set of bundled uppercase codes. |
| `byte[] image(String code)` | Returns a defensive copy of the PNG bytes. A valid code absent from the bundle returns null; malformed input throws. |

The current bundle contains 250 PNGs at 320px width with natural aspect ratios and
transparency, including `XK` for Kosovo. GB subdivision codes are excluded. Preserve
the source images rather than generating approximations, stretching square or
nonrectangular flags, or substituting a different country for a missing flag.
The bundle's recorded source is Flagpedia's public-domain PNG package; retain
provenance and update the recorded checksum when changing the assets.

```java
CountryFlagCatalog catalog = IGuiceContext.get(CountryFlagCatalog.class);
byte[] southAfrica = catalog.image("za"); // Same bytes as "ZA"; independent array.
byte[] unknown = catalog.image("ZZ");    // null, with no fallback image.
```

Cache bundled image bytes if useful. Resolve persisted links, row state and
authorization from ActivityMaster; never use a catalog hit or cached resource UUID
as permission to serve an image. Consumer URLs use Image Master after persistence.

## FSDM storage and service usage

`CountryFlagService.ensureFlag(Mutiny.StatelessSession session,
IGeography<?, ?> country, ISystems<?, ?> system, UUID... identityToken)` returns
`Uni<UUID>` containing the image resource UUID, or null when the valid country code
has no bundled image. A country from another enterprise fails with
`IllegalArgumentException` before persistence.

| Row or relationship | Type / classification | Name or value |
| --- | --- | --- |
| Country `Geography` | Existing country classification | Country name `ZA` |
| Flag `ResourceItem` | Image Master's `Image` resource type | Image name `ZA.png`, PNG binary data |
| `GeographyXResourceItem` | `CountryFlag`, concept `GeographyXResourceItem` | Value `ZA`; country points to the image |
| `ResourceItemXClassification` | `CountryFlagCountryCode`, concept `ResourceItemXClassification` | Value `ZA`; enables image lookup by code |

The service finds an active readable country flag link first and reuses its image
UUID. Otherwise it calls `IImageService.storeImage`, classifies that image and adds
the geography resource link sequentially. All rows inherit the supplied Geography
System scope and tokens. There are no additional flag or image tables.

```java
CountryFlagService flags = IGuiceContext.get(CountryFlagService.class);
// Run inside the host's existing authorized stateless transaction:
return flags.ensureFlag(session, country, system, identityTokens);
```

The caller owns the transaction and passes its stateless session throughout the
chain. Await the complete chain before reporting success. Repeated sequential
imports/updates reuse the link; concurrent writes for the same country must be
serialized by the caller. Do not claim that a cache or sequential idempotence
guarantees uniqueness across concurrent transactions.

## Installation and later imports

`CountryFlagsInstall` is an `ISystemUpdate` at `@SortedUpdate(sortOrder = 1110,
taskCount = 1)`, following Geography (1000) and Images (1100). It creates the two
classifications and backfills active countries already installed in that enterprise.
It uses the supplied stateless session and transaction, resolves the Geography
System and system token, and does not download GeoNames or image data.

After adding the module to an existing host, run its normal enterprise updates.
For a manual backfill, invoke `CountryFlagsInstall.update(session, enterprise)`
inside the host's installation transaction. Enterprise creation alone is not proof
that the Geography, Image and flag taxonomy updates have run.

`CountryService.createCountry` invokes each `IGeographyCountryResourceProvider`
sequentially after resolving or creating the country. `CountryFlagProvider` delegates
to `CountryFlagService`; later GeoNames country-info imports therefore attach flags
in their country transaction. Installer backfill handles countries that predate
the module. Countries without a bundled flag remain usable without a flag link.

## Serving and cache behavior

Image Master owns the image REST surface. Use the Geography System scope for these
flags and uppercase classification values. The host chooses its REST prefix;
examples below use `/rest`.

```text
GET /rest/{enterprise}/image/Geography%20System/{imageResourceUuid}
GET /rest/{enterprise}/image/Geography%20System/classification/CountryFlagCountryCode?value=ZA
GET /rest/{enterprise}/image/Geography%20System/classification/CountryFlagCountryCode?value=ZA&w=32&h=32
```

These use the existing `ImageRestService` and `IImageService<?>` contract in
`com.guicedee.activitymaster.imagemaster.services`, rather than introducing a flags
controller. The service supports `storeImage`, `getImage`, `getOptimizedImage`,
`getImageByClassification` and `getOptimizedImageByClassification`, with stateless
session, system and token arguments.

Image reads honor current resource security. Missing or unreadable data returns
404. The response detects PNG media type from its bytes. Positive `w`/`h` request
bounded scaling while preserving aspect ratio; zero leaves the corresponding axis
unbounded. Existing responses use private cache headers with `max-age=31536000`.
Caching does not make scoped images public or bypass authorization. Serving stored
flags has no runtime Flagpedia/CDN dependency.

## Validation boundaries

Decode every bundled PNG and check country-code validation, defensive copies,
natural aspect ratios, transparency and missing-image behavior. Against PostgreSQL,
verify automatic links, backfill of an existing unlinked country, repeated imports
and updates, Image Master retrieval by UUID and classification, scaling and caching.

Catalog tests prove asset behavior. PostgreSQL tests that directly call REST service
methods prove persistence and service responses; they do not establish deployed
HTTP routing, host authentication or browser rendering. Verify those separately
when the task requests live host proof.
