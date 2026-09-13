# activitymaster: Development

Read this reference when working on the topics below. Commands run from the skill directory.

- [Testing with Testcontainers](#testing-with-testcontainers)
- [CRTP Fluent Builders](#crtp-fluent-builders)
- [Configuration & Environment](#configuration--environment)

## Testing with Testcontainers

### PostgreSQL Test Module

```java
@EntityManager(value = "activityMasterTest", defaultEm = true)
public class PostgreSQLTestDBModule
        extends DatabaseModule<PostgreSQLTestDBModule>
        implements IGuiceModule<PostgreSQLTestDBModule> {

    private static final PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>(com.guicedee.client.Environment.getSystemPropertyOrEnvironment("TEST_DB_CONTAINER_IMAGE", null))
            .withDatabaseName("activitymaster_test")
            .withUsername("postgres")
            .withPassword("postgres");

    static { postgres.start(); }

    @Override
    protected ConnectionBaseInfo getConnectionBaseInfo(
            PersistenceUnitDescriptor unit, Properties filteredProperties) {
        PostgresConnectionBaseInfo info = new PostgresConnectionBaseInfo();
        info.setServerName(postgres.getHost());
        info.setPort(String.valueOf(postgres.getFirstMappedPort()));
        info.setDatabaseName(postgres.getDatabaseName());
        info.setUsername(postgres.getUsername());
        info.setPassword(postgres.getPassword());
        info.setReactive(true);
        return info;
    }
}
```

### Test Harness

```java
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class ActivityMasterTest {

    @Inject
    private IEnterpriseService enterpriseService;

    private Mutiny.SessionFactory sessionFactory;

    @BeforeAll
    public void setup() {
        IGuiceContext.instance();
        sessionFactory = IGuiceContext.get(
            Key.get(Mutiny.SessionFactory.class, Names.named("activityMaster")));
    }

    @Test
    void testEnterpriseLifecycle() {
        Enterprise enterprise = new Enterprise()
            .setName("Test Corp")
            .setActiveFlag(ActiveFlag.Active);

        sessionFactory.withSession(session ->
            session.withTransaction(tx ->
                enterpriseService.createEnterprise(enterprise)
                    .chain(created ->
                        enterpriseService.getEnterprise(created.getId(), null)
                    )
                    .invoke(retrieved -> {
                        assertNotNull(retrieved);
                        assertEquals("Test Corp", retrieved.get().getName());
                    })
            )
        ).replaceWithVoid();
    }
}
```

## CRTP Fluent Builders

### Request Builders

```java
// Enterprise creation with fluent builder
EnterpriseCreateRequest request = new EnterpriseCreateRequest()
    .setName("ACME Corp")
    .setDescription("Widget manufacturer")
    .setActiveFlag(ActiveFlag.Active)
    .setSecurityToken(token);

enterpriseService.create(request)
    .replaceWithVoid();
```

### Query Builders

```java
// Type-safe query building
var qb = new Enterprise().builder(session);
Uni<List<Enterprise>> results = qb
    .where(qb.getAttribute("name"), Operand.Like, "ACME%")
    .where(qb.getAttribute("activeFlag"), Operand.Equals, ActiveFlag.Active)
    .orderBy(qb.getAttribute("name"), OrderByType.ASC)
    .setMaxResults(50)
    .getAll();
```

### WarehouseQuerySpec (GraphQL/REST shared)

For dynamic queries (GraphQL, pivot endpoints):

```java
WarehouseQuerySpec spec = new WarehouseQuerySpec();
spec.setOrderBy("name");
spec.setDescending(false);
spec.setActiveOnly(true);
spec.setInDateRange(true);
spec.setMax(50);
spec.addFilter(new WarehouseQueryFilter()
    .setPath("name")
    .setOperand(Operand.Like)
    .setValue("ACME%"));

QueryBuilderSCD queryBuilder = new InvolvedParty().builder(session).applyQuerySpec(spec);
queryBuilder.getAll();
```

## Configuration & Environment

### Environment Variables

See [references/configuration.md](../references/configuration.md) for complete reference.

| Variable | Purpose | Required |
|---|---|---|
| `DB_URL` | PostgreSQL JDBC URL | Yes |
| `DB_USER` | Database username | Yes |
| `DB_PASS` | Database password | Yes |
| `DB_HOST` | Database hostname | Yes |
| `DB_PORT` | Database port | Yes |
| `DB_NAME` | Database name | Yes |
| `JWT_TEST_TOKEN` | Test JWT token | Test only |
| `OAUTH2_ISSUER_URL` | OAuth2 issuer URL | Yes |
| `JWKS_URI` | JWKS endpoint | Yes |
| `TEST_DB_CONTAINER_IMAGE` | Testcontainers image | Test only |
| `ENVIRONMENT` | Runtime environment | No |
| `TRACING_ENABLED` | Enable distributed tracing | No |
| `ENABLE_DEBUG_LOGS` | Enable debug logging | No |

### CI Secrets (GitHub Actions)

- `USERNAME` — GitHub username for publishing
- `USER_TOKEN` — GitHub token
- `SONA_USERNAME` — Sonatype username
- `SONA_PASSWORD` — Sonatype password
- `POSTGRES_APP_PASSWORD` — PostgreSQL application password
- `KEYCLOAK_ADMIN_PASSWORD` — Keycloak admin password

