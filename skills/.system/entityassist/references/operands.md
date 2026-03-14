# EntityAssist Operands Reference

Complete reference of all query operands available in EntityAssist.

## Equality Operands

### Equals

```java
qb.where(qb.getAttribute("name"), Operand.Equals, "John")
```

Generates: `WHERE name = 'John'`

### NotEquals

```java
qb.where(qb.getAttribute("status"), Operand.NotEquals, "inactive")
```

Generates: `WHERE status != 'inactive'`

## String Operands

### Like

Pattern matching with wildcards:

```java
qb.where(qb.getAttribute("name"), Operand.Like, "A%")
```

Generates: `WHERE name LIKE 'A%'`

Wildcards:
- `%` — Zero or more characters
- `_` — Single character

Examples:
- `"A%"` — Starts with A
- `"%son"` — Ends with son
- `"%and%"` — Contains and
- `"J_hn"` — J, any char, hn

### NotLike

```java
qb.where(qb.getAttribute("email"), Operand.NotLike, "%@spam.com")
```

Generates: `WHERE email NOT LIKE '%@spam.com'`

## Null Checks

### Null

```java
qb.where(qb.getAttribute("deletedAt"), Operand.Null, null)
```

Generates: `WHERE deletedAt IS NULL`

### NotNull

```java
qb.where(qb.getAttribute("email"), Operand.NotNull, null)
```

Generates: `WHERE email IS NOT NULL`

## Comparison Operands

### LessThan

```java
qb.where(qb.getAttribute("age"), Operand.LessThan, 18)
```

Generates: `WHERE age < 18`

### LessThanEqualTo

```java
qb.where(qb.getAttribute("score"), Operand.LessThanEqualTo, 100)
```

Generates: `WHERE score <= 100`

### GreaterThan

```java
qb.where(qb.getAttribute("price"), Operand.GreaterThan, 0)
```

Generates: `WHERE price > 0`

### GreaterThanEqualTo

```java
qb.where(qb.getAttribute("quantity"), Operand.GreaterThanEqualTo, 1)
```

Generates: `WHERE quantity >= 1`

## List Operands

### InList

```java
qb.where(qb.getAttribute("status"), Operand.InList, List.of("active", "pending", "approved"))
```

Generates: `WHERE status IN ('active', 'pending', 'approved')`

Also works with numbers:

```java
qb.where(qb.getAttribute("categoryId"), Operand.InList, List.of(1, 2, 3, 5, 8))
```

Generates: `WHERE categoryId IN (1, 2, 3, 5, 8)`

### NotInList

```java
qb.where(qb.getAttribute("status"), Operand.NotInList, List.of("deleted", "banned"))
```

Generates: `WHERE status NOT IN ('deleted', 'banned')`

## Operand Usage Patterns

### Multiple Conditions (AND)

```java
qb.where(qb.getAttribute("age"), Operand.GreaterThanEqualTo, 18)
  .where(qb.getAttribute("country"), Operand.Equals, "US")
  .where(qb.getAttribute("active"), Operand.Equals, true)
```

Generates: `WHERE age >= 18 AND country = 'US' AND active = true`

### Multiple Conditions (OR)

```java
qb.where(qb.getAttribute("role"), Operand.Equals, "admin")
  .or(qb.getAttribute("role"), Operand.Equals, "moderator")
```

Generates: `WHERE role = 'admin' OR role = 'moderator'`

### Mixed AND/OR

```java
qb.where(qb.getAttribute("status"), Operand.Equals, "active")
  .where(qb.getAttribute("age"), Operand.GreaterThan, 18)
  .or(qb.getAttribute("verified"), Operand.Equals, true)
```

Generates: `WHERE status = 'active' AND age > 18 OR verified = true`

### Null-Safe Checks

```java
qb.where(qb.getAttribute("email"), Operand.NotNull, null)
  .where(qb.getAttribute("email"), Operand.NotEquals, "")
```

Generates: `WHERE email IS NOT NULL AND email != ''`

### Case-Insensitive Like (PostgreSQL)

For case-insensitive pattern matching, use ILIKE via native query or convert to lowercase:

```java
qb.where("LOWER(name)", Operand.Like, "john%")
```

### Date Comparisons

```java
qb.where(qb.getAttribute("createdAt"), Operand.GreaterThanEqualTo, LocalDate.of(2024, 1, 1))
  .where(qb.getAttribute("createdAt"), Operand.LessThan, LocalDate.of(2025, 1, 1))
```

Generates: `WHERE createdAt >= '2024-01-01' AND createdAt < '2025-01-01'`

### Relationship Path Filters

Use dot-notation for relationship traversal:

```java
qb.where("department.name", Operand.Equals, "Engineering")
  .where("department.location.city", Operand.Equals, "San Francisco")
```

Generates joins automatically and filters on related entities.

## Complete Operand List

| Operand | SQL | Description |
|---|---|---|
| `Equals` | `=` | Exact match |
| `NotEquals` | `!=` | Not equal |
| `Like` | `LIKE` | Pattern match with wildcards |
| `NotLike` | `NOT LIKE` | Inverse pattern match |
| `Null` | `IS NULL` | Null check |
| `NotNull` | `IS NOT NULL` | Not null check |
| `LessThan` | `<` | Less than |
| `LessThanEqualTo` | `<=` | Less than or equal |
| `GreaterThan` | `>` | Greater than |
| `GreaterThanEqualTo` | `>=` | Greater than or equal |
| `InList` | `IN (...)` | Value in list |
| `NotInList` | `NOT IN (...)` | Value not in list |

## Type Compatibility

Different operands work with different value types:

| Operand | Compatible Types |
|---|---|
| `Equals`, `NotEquals` | All types |
| `Like`, `NotLike` | String only |
| `Null`, `NotNull` | All types (pass null as value) |
| `LessThan`, `LessThanEqualTo`, `GreaterThan`, `GreaterThanEqualTo` | Comparable types (numbers, dates, strings) |
| `InList`, `NotInList` | List of any type |

## Error Handling

Invalid operand usage will throw `QueryBuilderException`:

```java
// ❌ Invalid: Like with non-string
qb.where(qb.getAttribute("age"), Operand.Like, 25)

// ✅ Valid: Equals with number
qb.where(qb.getAttribute("age"), Operand.Equals, 25)

// ❌ Invalid: InList with non-list
qb.where(qb.getAttribute("status"), Operand.InList, "active")

// ✅ Valid: InList with list
qb.where(qb.getAttribute("status"), Operand.InList, List.of("active"))
```
