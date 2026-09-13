# entityassist: Queries

Read this reference when working on the topics below. Commands run from the skill directory.

- [Query Builder DSL](#query-builder-dsl)
- [Operands](#operands)

## Query Builder DSL

### Persist (Create)

```java
sessionFactory.withSession(session ->
    session.withTransaction(tx ->
        entity.builder(session)
              .persist(entity)
    )
).replaceWithVoid();
```

### Find by ID

```java
sessionFactory.withSession(session ->
    new EntityClass()
        .builder(session)
        .find("test1")
        .get()                       // Uni<EntityClass>
);
```

### Where / Or / OrderBy

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClass().builder(session);
    return qb
        .where(qb.getAttribute("name"), Operand.Like, "A%")
        .or(qb.getAttribute("name"), Operand.Equals, "Bob")
        .orderBy(qb.getAttribute("name"), OrderByType.ASC)
        .setMaxResults(50)
        .getAll();                   // Uni<List<EntityClass>>
});
```

### Dot-Notation Path Filters

Traverse relationships without explicit joins:

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClassTwo().builder(session);
    return qb
        .where("entityClass.name", Operand.Equals, "Parent Entity")
        .where("value", Operand.GreaterThan, 10)
        .getAll();
});
```

`where(String path, ...)` splits the path on `.` and walks `path.get(segment)` for each segment
(`WhereExpression.buildPath`), creating the implicit joins. The filter is applied entirely inside the
single criteria query.

> **Reactive gotcha — filter on a joined column instead of resolving the related entity.**
> In a reactive (Hibernate Reactive / Mutiny) codebase you must **never** resolve a related entity
> synchronously just to use it in a `where(...)`. Calling another `find(...)` returns a `Uni`, and
> casting that `Uni` to the entity type throws `ClassCastException` at runtime
> (`UniOnItemTransformToUni cannot be cast to <Entity>`); awaiting/blocking it on the event loop is
> equally forbidden. Filter on the join path instead:
> ```java
> // ❌ BAD — blocks/casts a Uni to an entity to use it in where(...)
> ClassificationDataConcept dc = (ClassificationDataConcept) service.find(em, concept, system); // Uni!
> builder.where(Classification_.concept, Operand.Equals, dc);
>
> // ✅ GOOD — fully non-blocking: filter on the joined column directly
> builder.where("concept.name", Operand.Equals, concept.classificationValue());
> ```
> When the join key has a stable natural value (here the concept's persisted `name` equals
> `EnterpriseClassificationDataConcepts.classificationValue()`), the dot-notation filter is exactly
> equivalent to the entity-equality filter and stays on the reactive pipeline. This pattern fixed a
> real `ClassCastException` in `ClassificationQueryBuilder.withConcept`.

### Pagination

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClass().builder(session);
    return qb
        .where(qb.getAttribute("name"), Operand.Like, "A%")
        .orderBy(qb.getAttribute("name"), OrderByType.ASC)
        .setFirstResults(0)
        .setMaxResults(20)
        .getAll();
});
```

### Count

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClass().builder(session);
    return qb
        .where(qb.getAttribute("name"), Operand.Like, "A%")
        .getCount();                 // Uni<Long>
});
```

### Aggregate Projections

```java
sessionFactory.withSession(session -> {
    var qb = new EntityClassTwo().builder(session);
    return qb
        .selectMax(qb.getAttribute("value"))
        .get(Integer.class);         // Uni<Integer>
});
```

Available aggregates:
- `selectMin()`
- `selectMax()`
- `selectSum()`
- `selectSumAsDouble()`
- `selectSumAsLong()`
- `selectAverage()`
- `selectCount()`
- `selectCountDistinct()`
- `selectColumn()`

### Joins

```java
sessionFactory.withSession(session -> {
    var parent = new EntityClass().builder(session);
    var child = new EntityClassTwo().builder(session);
    return child
        .join(child.getAttribute("entityClass"), parent, JoinType.INNER)
        .where(parent.getAttribute("name"), Operand.Equals, "Parent Entity")
        .getAll();
});
```

### Common Table Expressions (CTEs)

CTEs compose in the same fluent builder pattern. A CTE is described by a normal
builder (its `where(...)` filters), registered with `with(...)`, and the outer
query is constrained to the CTE's rows via an `id IN (SELECT id FROM cte)`
predicate — so results are **real managed entities** and the entire DSL
(`where`, `orderBy`, `groupBy`, projections, `getAll`, `getCount`) keeps working.

> Requires Hibernate ORM 7 (the builder uses `HibernateCriteriaBuilder` /
> `JpaCriteriaQuery` under the hood). In this Hibernate version a CTE is
> materialised as a tuple, so EntityAssist projects the entity `@Id` into the CTE
> and filters the outer entity query by membership rather than re-rooting it.

#### Non-recursive CTE

```java
sessionFactory.withSession(session -> {
    // CTE body — just another builder with its own filters
    var activeOnly = new EntityClass().builder(session)
            .where("description", Operand.Equals, "ACTIVE");

    // Outer entity query constrained by the CTE, then filtered normally
    return new EntityClass().builder(session)
            .with("active_entities", activeOnly)   // WITH active_entities AS (SELECT id ...)
            .where("name", Operand.Like, "A%")
            .getAll();                             // Uni<List<EntityClass>>
});
```

Generated SQL:

```sql
WITH active_entities (active_entities_id) AS (
    SELECT e.id FROM entity_class e WHERE e.description = ?
)
SELECT m.* FROM entity_class m
WHERE m.id IN (SELECT active_entities_id FROM active_entities)
  AND m.name LIKE ?
```

#### Recursive CTE (adjacency-list hierarchy)

`withRecursiveHierarchy(name, anchor, parentAttribute)` walks a self-referencing
hierarchy and returns the anchor row plus every descendant. `parentAttribute` is
the self-referencing attribute holding the parent identifier (a scalar FK column;
dot-paths such as `"parent.id"` are supported for associations).

```java
@Entity
@Table(name = "category_node")
public class CategoryNode
        extends BaseEntity<CategoryNode, CategoryNode.CategoryNodeQueryBuilder, String> {
    @Id private String id;
    private String name;
    @Column(name = "parent_id") private String parentId;   // self-reference
    // getters/setters + builder ...
}
```

```java
sessionFactory.withSession(session -> {
    var anchor = new CategoryNode().builder(session)
            .where("id", Operand.Equals, "1");           // start at node 1

    return new CategoryNode().builder(session)
            .withRecursiveHierarchy("subtree", anchor, "parentId")
            .getAll();                                   // node 1 + all descendants
});
```

Generated SQL:

```sql
WITH RECURSIVE subtree (subtree_id) AS (
    SELECT e.id FROM category_node e WHERE e.id = ?          -- anchor member
    UNION ALL
    SELECT c.id FROM category_node c, subtree                -- recursive member
    WHERE c.parent_id = subtree.subtree_id
)
SELECT m.* FROM category_node m
WHERE m.id IN (SELECT subtree_id FROM subtree)
```

#### Low-level recursive CTE

For non-hierarchy recursion, `withRecursive(name, anchor, recursiveProducer, unionAll)`
exposes Hibernate's recursive member directly as
`Function<JpaCteCriteria<Object>, AbstractQuery<Object>>` (the CTE projects the
entity id; `unionAll = false` switches to `UNION DISTINCT`).

**Notes:**
- Call `with(...)` / `withRecursiveHierarchy(...)` once per CTE; multiple CTEs accumulate.
- A unique CTE name is generated when `name` is `null`/blank.
- The CTE body builder must target the same entity type as the outer builder.
- The entity must expose a single `@Id` field.

#### Recursion over a link / join table (not just self-FK adjacency)

`withRecursiveHierarchy(...)` only fits an **adjacency list on one entity** (a self-referencing FK:
`child.parent_id = tree.id`). When the hierarchy is stored in a **separate link table** — a
`many-to-many` / association entity such as `ParentXChild(parentId, childId)` — `withRecursiveHierarchy`
**cannot** express it (its recursive member always re-roots on the same entity). Use the low-level
`withRecursive(...)` instead: its `recursiveProducer` is **raw Hibernate criteria**, so the recursive
member may root on a *different* mapped entity (the link table) and project a column back as the outer
entity's id.

Requirements / shape:
- The **outer** builder and the **anchor** builder are rooted on the target entity `E` (the CTE
  projects `E`'s `@Id`, and the outer query is trimmed by `id IN (SELECT … FROM cte)`).
- The **link table must be a mapped EntityAssist entity** (it needs a query builder / metamodel).
- The recursive member selects the link column that yields the next `E` id (e.g.
  `select x.parentId from ParentXChild x, cte a where x.childId = a.<cteIdAlias>` + any edge filters),
  aliased to the CTE id alias and typed as `E`'s id type.

```java
// Climb a parent/child hierarchy stored in a link table (childId → parentId), seeded from an anchor.
var anchor = new SecurityToken().builder(session)
        .where("securityToken", Operand.InList, tokenStrings)
        .where("enterpriseId", Operand.Equals, enterpriseId);

return new SecurityToken().builder(session)
        .withRecursive("applicable", anchor, cteRef -> {
            var cb        = (HibernateCriteriaBuilder) builder.getCriteriaBuilder();
            var recursive = cb.createQuery(UUID.class);
            var x         = recursive.from(SecurityTokenXSecurityToken.class);  // the LINK entity
            var a         = recursive.from(cteRef);
            var parentId  = x.get("parentSecurityTokenId");
            parentId.alias("applicable_id");
            recursive.select(parentId);
            recursive.where(cb.and(
                    cb.equal(x.get("childSecurityTokenId"), a.get("applicable_id")),
                    /* edge filters: enterprise, SCD in-range, active-flag visible … */));
            return recursive;
        }, /* unionAll */ false)            // UNION DISTINCT dedupes diamond hierarchies
        .getAll();                          // every SecurityToken reachable by climbing parents
```

**Why this matters (CTE fusion).** Because the climb constrains a *real* `E` builder via
`id IN (SELECT … FROM cte)`, it composes with the rest of the DSL in the **same statement** — so a
recursive expansion and a downstream membership/security trim (e.g. an `id IN (readableIds)` /
`canRead(...)` filter) run as **one CTE-backed query** instead of: native recursive query → collect a
`Set<UUID>` → second `IN (…)` query. It is also fully portable (no vendor SQL string) and goes through
Hibernate Reactive, which **auto-flushes before the query** — removing any "pin `:now` to a logical
clock because the native query doesn't flush" visibility workarounds. Trade-off: the `recursiveProducer`
is raw criteria (more verbose than fluent `where(...)`), so the win is portability + composition/fusion,
not fewer lines.

### Bulk Delete

```java
sessionFactory.withSession(session ->
    session.withTransaction(tx -> {
        var qb = new EntityClass().builder(session);
        return qb
            .where(qb.getAttribute("name"), Operand.Equals, "obsolete")
            .delete();               // Uni<Integer> — rows affected
    })
);
```

**Safety guard:** Bulk `delete()` requires at least one filter. Use `truncate()` to remove all rows.

### Entity Delete

```java
sessionFactory.withSession(session ->
    session.withTransaction(tx ->
        entity.builder(session)
              .delete(entity)        // Uni<EntityClass>
    )
);
```

### Update (Merge)

```java
entity.setName("Updated Name");
sessionFactory.withSession(session ->
    session.withTransaction(tx ->
        entity.builder(session)
              .update()              // Uni<EntityClass>
    )
);
```

### Stateless Sessions

For high-throughput bulk operations:

```java
sessionFactory.withStatelessSession(session ->
    entity.builder(session)           // uses Mutiny.StatelessSession
          .persist(entity)
);
```

**Bulk-insert pattern (resolve-once + one stateless transaction).** When securing/post-processing many just-created rows, do NOT loop a per-row operation that re-resolves shared references and round-trips for every row. Resolve the shared values **once** on the live session, then write all rows in a single `withStatelessTransaction` so the persistence context never grows and inserts can be JDBC-batched:

```java
// ❌ BAD — per row: N × (re-resolve shared refs + find + persist) round-trips
for (var row : rows) row.createSecurity(session, ...).await()...;

// ✅ GOOD — resolve shared refs once, batch all inserts in ONE stateless tx
return resolveSharedRefs(session, system)                 // 1 pass on the live session
    .chain(refs -> sessionFactory.withStatelessTransaction(st -> {
        Uni<Long> chain = Uni.createFrom().item(0L);
        for (var row : rows)
            chain = chain.chain(n -> row.persistDerived(st, refs).map(k -> n + k));
        return chain;                                     // pure inserts, no growing context
    }));
```

For just-created rows skip any per-row existence gate entirely (the caller already knows they are new); only use a `count == 0` gate when the pass must be idempotent over a whole table (re-installs).

## Operands

See [references/operands.md](../references/operands.md) for complete list.

Common operands:
- `Equals`, `NotEquals`
- `Like`, `NotLike`
- `LessThan`, `LessThanEqualTo`
- `GreaterThan`, `GreaterThanEqualTo`
- `Null`, `NotNull`
- `InList`, `NotInList`

