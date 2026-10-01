# Marketplace and product-loading plugins

Marketplace Master and Marketplace Products are independently registered
`IMasterPlugin` capabilities. Neither implements `IMasterSystem`, neither belongs
under the Systems security folder, and neither can use its own credential for
user data. Both use the existing FSDM model, without marketplace-specific tables.

## Separate capabilities

| Plugin | Declared dependencies | Responsibility |
|---|---|---|
| Marketplace Master | Activity Master System | Seller applications/review, publication, catalogue, carts, orders and verified settlement |
| Marketplace Products | Activity Master System, Marketplace Master | Load seller product data through the authorized Marketplace service |

Registering these capabilities loads no products. Install Marketplace Master on
the authorized party and obtain individual user consent for its Core dependency.
A seller loading products additionally needs a separate Marketplace Products
installation and consent to both Core and Marketplace Master. Buyers do not need
the producer installed. Removing or denying the producer prevents new loads while
existing authorized catalogue/order operations remain available through Marketplace.

The product producer is shipped in `marketplace-master` as a separate capability;
packaging does not merge the two security registrations. A host can expose the
producer separately or use its compatibility route. It must never call raw FSDM
product writes in place of this boundary.

## Verified host and service boundaries

Bind `MarketplaceIdentityProvider.current()` to a verified, call-scoped
`MarketplaceIdentity(partyId, enterpriseId, context, identityToken, installationPartyId)`.
The four-argument constructor defaults installationPartyId to partyId. Work
context owner is the authorized enterprise; Personal/Social owners are the
verified organic party. The host verifies membership before using an organization
installation. The default provider denies access; browser IDs are domain targets.

`MarketplaceService.actor` checks current built-in plugin admission for all
operations, then normal user/row/context authority and the existing reviewed
`marketplace` provider installation and behavior grants. These behavior grants
are an additional FSDM policy layer, not plugin consent:

- `marketplace.apply`: seller application.
- `marketplace.review`: privileged reviewer; self-review is denied.
- `marketplace.sell`: currently approved seller, drafting and publication.
- `marketplace.browse`: catalogue reads with independent Product/image row access.
- `marketplace.buy`: carts, order reads and checkout.
- `marketplace.settle`: trusted Work-scoped settlement actor.

Inject `MarketplaceApi` for application, review, publish, find, catalog, createCart,
cart, putItem, checkout, order and confirmSettlement. It binds identity once and
awaits the full transaction. REST is `/{enterprise}/marketplace`.

Inject `MarketplaceProductsApi` and call `load(enterprise, ListingInput)` to load
a product. REST is `POST /{enterprise}/marketplace-products`.
`MarketplaceApi.draft` and the existing `POST /{enterprise}/marketplace/products`
are compatibility paths that pass through the same producer boundary; they grant
no bypass. Lower-level `MarketplaceService.draft` also delegates to the producer.
The package-private domain writer cannot be called as a public product-load API.

`MarketplaceProductsService.load(session, marketplaceRegistration, identity, input)`
checks the producer's current dependencies, then delegates with a bound
`Invocation(producerId, installationPartyId)` to Marketplace Master using the
same verified user. Marketplace re-checks its own admission, seller approval and
row/context grants. Domain records and invocation audit commit atomically.
Marketplace is the last writing service, so Product/relationship
OriginalSourceSystemID records its durable registration ID; the initiating
producer is recorded separately in the invocation audit. Never stamp a downstream
writer with the producer's ID merely because the producer initiated the request.

## Products, checkout and payment

`ListingInput(name, description, imageUrls, currency, price, minQuantity, maxQuantity)`
creates an unpublished Product. Price is a positive decimal without exponent
notation and at most two decimal places; quantity bounds must be valid. Up to
eight HTTPS image references are typed ResourceItems linked through
ProductXResourceItem; the module fetches no image binaries. Existing legacy
MarketplaceImages values remain readable. Only published listings appear to
buyers; publication still needs the approved seller and marketplace.sell grant.

Carts and orders are typed Arrangements. PutItem accepts quantity zero to remove
an item. Checkout serializes the cart, re-checks published Products and current
prices/quantities, requires one currency and creates snapshot order lines plus a
Checkout Event once. The result is PENDING_PAYMENT with HOST_AUTHORIZATION_REQUIRED;
it does not charge Wallet or Payments and does not establish paid fulfillment.

The host performs separately authorized Wallet/Payment integration, correlates
durable settlement to the exact order, amount, currency and reference, and binds
`MarketplaceSettlementVerifier`. Its default denies confirmation. Reference text
alone is insufficient; marketplace.settle and current order row authority remain
required. Provider calls do not substitute for fresh user authorization.

## Age ratings

`ListingInput` has an optional eighth `ageRating` component (the seven-argument
constructor and an omitted JSON field mean `All`); `Listing.ageRating()` returns it.
Codes and decisions come from core `AgeRating`/`AgeRestrictionService`:

- `All`: anyone, no date of birth needed. Unrated legacy listings are `All`.
- `FamilyFriendly`, `ParentalGuidance`: require a profile date of birth, any age.
- `N+` (e.g. `18+`): require a date of birth and at least N completed years (UTC).

A seller may assign `All`, `FamilyFriendly`, `ParentalGuidance` or a numeric rating
from their residential profile country's set (default `13+/16+/18+`); other
numeric codes are `BadRequestException`. `GET /{enterprise}/marketplace/age-ratings`
(`MarketplaceApi.ageRatingOptions`) lists them. Non-`All` ratings are stored as the
`MarketplaceAgeRating` ProductXClassification (forward update 1189 for existing
enterprises). `find`, `putItem` (quantity > 0) and `checkout` deny buyers with
`SecurityException("Age restricted…")`; `catalog` omits listings the buyer cannot
access. Sellers always read their own listings.

## Categories and search

The category hierarchy is shared by every seller and context on the Marketplace
system and lives only in FSDM tables:

- A category is a `classification.classification` row in the `MarketplaceCategory`
  data concept. Its name is the slash path code (for example `electronics/phones`,
  lowercase segments, at most 5 levels and 100 characters). Its description is the
  display name and its sequence number sets the order.
- Parent to child links are `classification.classificationxclassification` rows,
  created with `IClassificationService.createInConcept(..., parent, ...)`.
- A listing is filed with `product.productxclassification` rows whose
  `classificationid` is the category itself and whose `value` is the position
  (`01` is primary). `listing()` excludes this concept from the scalar field map.

Forward update 1190 (`MarketplaceCategoryInstall`) idempotently seeds
`MarketplaceCategories.DEFAULTS`: 17 roots (Electronics, Fashion, Home & Garden,
Digital Products, Services, Vehicles & Parts, Other and so on) with basic children.

Data concepts (`MarketplaceConcepts`):

- `MarketplaceCategory` holds the categories themselves (their direct
  `classificationdataconceptid`).
- `Marketplace` is the umbrella concept for every Marketplace classification: field,
  event, arrangement and party roles, age ratings and categories. Each one is
  linked through `classification.classificationdataconceptxclassification`, with
  `value` set to the classification's own concept name. Roles keep their standard
  relationship concepts (for example `ProductXClassification`) so that
  data-concept-scoped role lookups still resolve.
- `ensure` find-or-creates both concepts. `associate` adds the missing links
  idempotently, only for live rows on the Marketplace system that are named
  `Marketplace%` or are in `MarketplaceCategory`. Link rows get scope-restricted
  default security. Update 1190 and `createCategory` both run `associate`, so a
  curated category is in the umbrella concept as soon as it commits.

Rules:

- `ListingInput.categories` (ninth component) needs 1 to 5 distinct, live **leaf**
  codes. Missing, unknown, duplicate or parent-only codes are `BadRequestException`.
  The older constructors produce no categories, so they are rejected.
- `categorize(product, codes)` lets the seller re-file their own listing. It sets
  `effectivetodate` on the old links instead of deleting them.
- `marketplace.curate` covers `createCategory(CategoryInput(parentCode, segment,
  name, sequence))`, `updateCategory(id, CategoryUpdate(name, sequence))` and
  `retireCategory(id)`. Only an unused leaf can be retired.
- `categories()` (`marketplace.browse`) returns `Category(id, code, name,
  parentCode, depth, sequence, leaf)` in depth-first order.
- `search(SearchQuery)` (`marketplace.browse`) filters published listings in the
  actor's context. Filters: optional text (case-insensitive, with `%`/`_` matched
  literally) against name and description, a category subtree (a recursive CTE
  over ClassificationXClassification; `includeSubcategories=false` matches only the
  category itself), currency, and a price range (needs a currency). Sorts: `newest`,
  `oldest`, `price_asc`, `price_desc`, `name`. It applies the same age filter as
  `catalog` and returns `SearchResult(items, total, categories)`. The facets count
  listings under each child of the searched category, or under each root.
- REST: `GET search?q&category&subcategories&currency&minPrice&maxPrice&sort&offset&limit`,
  `GET|POST categories`, `PUT|DELETE categories/{id}`, `PUT products/{id}/categories`.

## Forward provisioning and validation

Core update 1030 converts discovered built-ins. Module update 1187
(`MarketplacePluginInstall`) also provisions both Marketplace and its producer for
late-added modules or previously recorded domain updates. Domain update 1188
(`MarketplaceInstall`, previously order 1185) seeds taxonomy only, using Core's
actual bootstrap credential. Its unique order avoids collision with Documents
1185 when both modules are present. Existing update receipts are retained.

Run `mvn -f ActivityMaster/marketplace-master/pom.xml test` without clean. Real
PostgreSQL tests cover separate producer admission/removal, last-writer provenance,
seller decisions, row grants, image access, age ratings, category curation and search, concurrent checkout and settlement
proof. These tests do not prove a real payment provider, delivery or deployment.
