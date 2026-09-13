# entityassist: Entities

Read this reference when working on the topics below. Commands run from the skill directory.

- [Quick Start](#quick-start)
- [ActiveFlag Lifecycle Enum](#activeflag-lifecycle-enum)
- [Converters](#converters)

## Quick Start

### Define a CRTP Entity

```java
@Entity
@Accessors(chain = true)
@Table(name = "entity_class")
public class EntityClass
        extends BaseEntity<EntityClass, EntityClass.EntityClassQueryBuilder, String> {

    @Id
    @Column(name = "id", nullable = false)
    @Getter @Setter
    private String id;

    @Column(name = "name")
    @Getter @Setter
    private String name;

    @Override
    public String getId() { return id; }

    @Override
    public EntityClass setId(String id) {
        this.id = id;
        return this;
    }

    public static class EntityClassQueryBuilder
            extends QueryBuilder<EntityClassQueryBuilder, EntityClass, String> {

        @Override
        public boolean isIdGenerated() {
            return false;
        }
    }
}
```

### Entity with Relationships

```java
@Entity
@Accessors(chain = true)
@Table(name = "entity_class_two")
public class EntityClassTwo
        extends BaseEntity<EntityClassTwo, EntityClassTwo.EntityClassTwoQueryBuilder, String> {

    @Id
    @Getter @Setter
    private String id;

    @Column(name = "value")
    @Getter @Setter
    private Integer value;

    @ManyToOne
    @JoinColumn(name = "entity_class_id")
    @Getter @Setter
    private EntityClass entityClass;

    @Override
    public String getId() { return id; }

    @Override
    public EntityClassTwo setId(String id) {
        this.id = id;
        return this;
    }

    public static class EntityClassTwoQueryBuilder
            extends QueryBuilder<EntityClassTwoQueryBuilder, EntityClassTwo, String> {

        @Override
        public boolean isIdGenerated() {
            return false;
        }
    }
}
```

## ActiveFlag Lifecycle Enum

Rich status model with ranged queries:

```java
public enum ActiveFlag {
    Unknown,
    Deleted,
    Active,
    Permanent
}
```

Helpers:
- `getActiveRange()` — Active to Permanent
- `getVisibleRangeAndUp()` — Active and above
- And more status range helpers

## Converters

Built-in JPA attribute converters:
- `LocalDateAttributeConverter` — `LocalDate` ↔ `java.sql.Date`
- `LocalDateTimeAttributeConverter` — `LocalDateTime` ↔ `java.sql.Timestamp`
- `LocalDateTimestampAttributeConverter` — `LocalDate` ↔ `java.sql.Timestamp`

