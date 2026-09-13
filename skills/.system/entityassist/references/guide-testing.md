# entityassist: Testing

Read this reference when working on the topics below. Commands run from the skill directory.

- [Testing with Testcontainers](#testing-with-testcontainers)

## Testing with Testcontainers

```java
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class EntityAssistReactiveTest {

    private Mutiny.SessionFactory sessionFactory;

    @BeforeAll
    public void setup() {
        IGuiceContext.instance();
        JtaPersistService ps = (JtaPersistService) IGuiceContext.get(
            Key.get(PersistService.class, Names.named("entityAssistReactive")));
        ps.start();

        sessionFactory = IGuiceContext.get(
            Key.get(Mutiny.SessionFactory.class, Names.named("entityAssistReactive")));
    }

    @Test
    void roundTrip() {
        EntityClass entity = new EntityClass()
            .setId("test1")
            .setName("Test Entity");

        sessionFactory.withSession(session ->
            session.withTransaction(tx ->
                entity.builder(session).persist(entity)
            ).chain(() ->
                new EntityClass().builder(session)
                    .find("test1").get()
            ).invoke(found -> {
                assertNotNull(found);
                assertEquals("test1", found.getId());
            })
        ).replaceWithVoid();
    }
}
```

