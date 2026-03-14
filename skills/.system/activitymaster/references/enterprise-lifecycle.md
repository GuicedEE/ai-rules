# ActivityMaster Enterprise Lifecycle Reference

Complete reference for enterprise creation, initialization, updates, and lifecycle management.

## Enterprise Lifecycle Overview

ActivityMaster uses a structured lifecycle for enterprise management with three main phases:

1. **Creation** - Initial enterprise entity creation
2. **Updates** - Loading and applying ISystemUpdate implementations
3. **Startup** - Final initialization and activation

```
createNewEnterprise() → loadUpdates() → startNewEnterprise()
```

---

## Phase 1: Enterprise Creation

### createNewEnterprise()

Initial creation of the enterprise entity with basic information.

```java
public class EnterpriseLifecycleManager {
    @Inject
    IEnterpriseService enterpriseService;

    public Uni<Enterprise> createNewEnterprise(EnterpriseCreationRequest request) {
        Enterprise enterprise = new Enterprise()
            .setId(UUID.randomUUID().toString())
            .setName(request.getName())
            .setDescription(request.getDescription())
            .setEnterpriseType(request.getType())
            .setActiveFlag(ActiveFlag.Unknown) // Start as Unknown
            .setCreatedAt(LocalDateTime.now())
            .setUpdatedAt(LocalDateTime.now());

        return enterpriseService.createEnterprise(enterprise);
    }
}
```

### Enterprise Creation Flow

```java
@Path("/enterprises")
@ApplicationScoped
public class EnterpriseResource {
    @Inject
    EnterpriseLifecycleManager lifecycleManager;

    @POST
    @Path("/create")
    public Uni<Enterprise> createEnterprise(EnterpriseCreationRequest request) {
        return lifecycleManager.createNewEnterprise(request)
            .invoke(created -> log.info("Enterprise created: {}", created.getId()));
    }
}
```

### Creation Request Model

```java
public class EnterpriseCreationRequest {
    @NotBlank
    private String name;

    private String description;

    @NotBlank
    private String type;

    private String parentEnterpriseId;

    private Map<String, String> metadata;

    // Getters and setters
}
```

---

## Phase 2: Loading Updates (ISystemUpdate)

### ISystemUpdate Interface

System updates are applied after enterprise creation to initialize modules, seed data, and configure features.

```java
public interface ISystemUpdate {
    /**
     * Applies this update to the enterprise
     *
     * @param enterprise The enterprise to update
     * @param token Security token for authorization
     * @return Uni completing when update is applied
     */
    Uni<Void> applyUpdate(Enterprise enterprise, SecurityToken token);

    /**
     * Gets the unique identifier for this update
     */
    String getUpdateId();

    /**
     * Gets the description of what this update does
     */
    String getDescription();

    /**
     * Checks if this update has already been applied
     *
     * @param enterprise The enterprise to check
     * @return true if already applied
     */
    Uni<Boolean> isApplied(Enterprise enterprise);
}
```

### Update Ordering with @SortedUpdate

Updates are executed in order specified by the `@SortedUpdate` annotation:

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface SortedUpdate {
    int priority() default 100;
}
```

### Example System Updates

#### 1. Default Roles Update

```java
@ApplicationScoped
@SortedUpdate(priority = 10)
public class DefaultRolesUpdate implements ISystemUpdate {
    @Inject
    IRolesService rolesService;

    @Override
    public Uni<Void> applyUpdate(Enterprise enterprise, SecurityToken token) {
        return createDefaultRoles(enterprise, token)
            .replaceWithVoid();
    }

    private Uni<List<Role>> createDefaultRoles(Enterprise enterprise, SecurityToken token) {
        List<Uni<Role>> roleCreations = List.of(
            rolesService.createRole(
                new Role()
                    .setName("ADMIN")
                    .setDescription("Administrator")
                    .setEnterpriseId(enterprise.getId()),
                token
            ),
            rolesService.createRole(
                new Role()
                    .setName("USER")
                    .setDescription("Standard User")
                    .setEnterpriseId(enterprise.getId()),
                token
            ),
            rolesService.createRole(
                new Role()
                    .setName("VIEWER")
                    .setDescription("Read-only Viewer")
                    .setEnterpriseId(enterprise.getId()),
                token
            )
        );

        return Uni.combine().all().unis(roleCreations).combinedWith(list -> (List<Role>) list);
    }

    @Override
    public String getUpdateId() {
        return "default-roles-v1";
    }

    @Override
    public String getDescription() {
        return "Creates default roles (ADMIN, USER, VIEWER)";
    }

    @Override
    public Uni<Boolean> isApplied(Enterprise enterprise) {
        return rolesService.roleExists(enterprise.getId(), "ADMIN");
    }
}
```

#### 2. Default Classifications Update

```java
@ApplicationScoped
@SortedUpdate(priority = 20)
public class DefaultClassificationsUpdate implements ISystemUpdate {
    @Inject
    IClassificationService classificationService;

    @Override
    public Uni<Void> applyUpdate(Enterprise enterprise, SecurityToken token) {
        return createClassificationTree(enterprise, token)
            .replaceWithVoid();
    }

    private Uni<Classification> createClassificationTree(Enterprise enterprise, SecurityToken token) {
        // Create root
        Classification root = new Classification()
            .setName("Root")
            .setCode("ROOT")
            .setClassificationType("TAXONOMY")
            .setActiveFlag(ActiveFlag.Active);

        return classificationService.createClassification(root)
            .chain(created -> createChildClassifications(created, token));
    }

    private Uni<Classification> createChildClassifications(Classification parent, SecurityToken token) {
        List<Uni<Classification>> children = List.of(
            classificationService.createChildClassification(
                new Classification()
                    .setName("Products")
                    .setCode("PROD")
                    .setClassificationType("TAXONOMY"),
                parent.getId(),
                token
            ),
            classificationService.createChildClassification(
                new Classification()
                    .setName("Services")
                    .setCode("SERV")
                    .setClassificationType("TAXONOMY"),
                parent.getId(),
                token
            )
        );

        return Uni.combine().all().unis(children)
            .combinedWith(list -> parent);
    }

    @Override
    public String getUpdateId() {
        return "default-classifications-v1";
    }

    @Override
    public String getDescription() {
        return "Creates default classification taxonomy";
    }

    @Override
    public Uni<Boolean> isApplied(Enterprise enterprise) {
        return classificationService.getClassificationByCode("ROOT", null)
            .map(Optional::isPresent);
    }
}
```

#### 3. Default Address Update

```java
@ApplicationScoped
@SortedUpdate(priority = 30)
public class DefaultAddressUpdate implements ISystemUpdate {
    @Inject
    IAddressService addressService;

    @Override
    public Uni<Void> applyUpdate(Enterprise enterprise, SecurityToken token) {
        Address defaultAddress = new Address()
            .setStreetLine1("123 Default Street")
            .setCity("DefaultCity")
            .setStateProvince("DC")
            .setPostalCode("00000")
            .setCountry("USA")
            .setAddressType("HEADQUARTERS")
            .setActiveFlag(ActiveFlag.Active);

        return addressService.createAddress(defaultAddress, enterprise.getId())
            .replaceWithVoid();
    }

    @Override
    public String getUpdateId() {
        return "default-address-v1";
    }

    @Override
    public String getDescription() {
        return "Creates default headquarters address";
    }

    @Override
    public Uni<Boolean> isApplied(Enterprise enterprise) {
        return addressService.listAddresses(enterprise.getId(), null)
            .map(addresses -> !addresses.isEmpty());
    }
}
```

#### 4. Module Initialization Update

```java
@ApplicationScoped
@SortedUpdate(priority = 40)
public class ModuleInitializationUpdate implements ISystemUpdate {
    @Inject
    @ConfigProperty(name = "activitymaster.conversations.enabled")
    boolean conversationsEnabled;

    @Inject
    @ConfigProperty(name = "activitymaster.wallet.enabled")
    boolean walletEnabled;

    @Inject
    IConversationsService conversationsService;

    @Inject
    IWalletService walletService;

    @Override
    public Uni<Void> applyUpdate(Enterprise enterprise, SecurityToken token) {
        List<Uni<Void>> moduleInits = new ArrayList<>();

        if (conversationsEnabled) {
            moduleInits.add(initializeConversations(enterprise, token));
        }

        if (walletEnabled) {
            moduleInits.add(initializeWallet(enterprise, token));
        }

        return Uni.combine().all().unis(moduleInits)
            .discardItems();
    }

    private Uni<Void> initializeConversations(Enterprise enterprise, SecurityToken token) {
        // Create system conversation for announcements
        Conversation systemConversation = new Conversation()
            .setTitle("System Announcements")
            .setType(ConversationType.CHANNEL)
            .setActiveFlag(ActiveFlag.Active);

        return conversationsService.createConversation(systemConversation, List.of())
            .replaceWithVoid();
    }

    private Uni<Void> initializeWallet(Enterprise enterprise, SecurityToken token) {
        return walletService.createWallet(enterprise.getId(), "USD")
            .replaceWithVoid();
    }

    @Override
    public String getUpdateId() {
        return "module-initialization-v1";
    }

    @Override
    public String getDescription() {
        return "Initializes enabled feature modules";
    }

    @Override
    public Uni<Boolean> isApplied(Enterprise enterprise) {
        // Check if at least one module is initialized
        return walletService.getWallet(enterprise.getId(), null)
            .map(wallet -> true)
            .onFailure().recoverWithItem(false);
    }
}
```

### loadUpdates() Implementation

```java
@ApplicationScoped
public class EnterpriseLifecycleManager {
    @Inject
    Instance<ISystemUpdate> allUpdates;

    public Uni<Void> loadUpdates(Enterprise enterprise, SecurityToken token) {
        // Get all updates and sort by priority
        List<ISystemUpdate> sortedUpdates = allUpdates.stream()
            .sorted(Comparator.comparingInt(this::getUpdatePriority))
            .toList();

        log.info("Loading {} system updates for enterprise {}", sortedUpdates.size(), enterprise.getId());

        // Apply updates sequentially
        Uni<Void> chain = Uni.createFrom().voidItem();

        for (ISystemUpdate update : sortedUpdates) {
            chain = chain.chain(() -> applyUpdateIfNeeded(update, enterprise, token));
        }

        return chain;
    }

    private Uni<Void> applyUpdateIfNeeded(ISystemUpdate update, Enterprise enterprise, SecurityToken token) {
        return update.isApplied(enterprise)
            .chain(applied -> {
                if (applied) {
                    log.info("Update {} already applied, skipping", update.getUpdateId());
                    return Uni.createFrom().voidItem();
                } else {
                    log.info("Applying update {}: {}", update.getUpdateId(), update.getDescription());
                    return update.applyUpdate(enterprise, token)
                        .invoke(() -> log.info("Update {} completed", update.getUpdateId()));
                }
            });
    }

    private int getUpdatePriority(ISystemUpdate update) {
        SortedUpdate annotation = update.getClass().getAnnotation(SortedUpdate.class);
        return annotation != null ? annotation.priority() : 100;
    }
}
```

---

## Phase 3: Enterprise Startup

### startNewEnterprise()

Final activation and initialization after all updates are applied.

```java
@ApplicationScoped
public class EnterpriseLifecycleManager {
    @Inject
    IEnterpriseService enterpriseService;

    public Uni<Enterprise> startNewEnterprise(Enterprise enterprise, SecurityToken token) {
        log.info("Starting enterprise: {}", enterprise.getId());

        return validateEnterpriseReady(enterprise, token)
            .chain(() -> activateEnterprise(enterprise, token))
            .chain(activated -> performStartupTasks(activated, token))
            .invoke(started -> log.info("Enterprise {} started successfully", started.getId()));
    }

    private Uni<Void> validateEnterpriseReady(Enterprise enterprise, SecurityToken token) {
        // Ensure all required updates are applied
        // Validate data integrity
        return Uni.createFrom().voidItem();
    }

    private Uni<Enterprise> activateEnterprise(Enterprise enterprise, SecurityToken token) {
        enterprise.setActiveFlag(ActiveFlag.Active);
        enterprise.setUpdatedAt(LocalDateTime.now());

        return enterpriseService.updateEnterprise(enterprise, token);
    }

    private Uni<Enterprise> performStartupTasks(Enterprise enterprise, SecurityToken token) {
        // Send welcome notifications
        // Initialize background jobs
        // Set up default configurations
        return Uni.createFrom().item(enterprise);
    }
}
```

---

## Complete Lifecycle Flow

### Full Enterprise Creation Flow

```java
@Path("/enterprises")
@ApplicationScoped
public class EnterpriseResource {
    @Inject
    EnterpriseLifecycleManager lifecycleManager;

    @POST
    @Path("/complete-setup")
    public Uni<Enterprise> completeEnterpriseSetup(EnterpriseCreationRequest request, @Context SecurityToken token) {
        return lifecycleManager.createNewEnterprise(request)
            .invoke(created -> log.info("Phase 1: Enterprise created"))
            .chain(created -> lifecycleManager.loadUpdates(created, token)
                .invoke(() -> log.info("Phase 2: Updates loaded"))
                .replaceWith(created))
            .chain(created -> lifecycleManager.startNewEnterprise(created, token)
                .invoke(started -> log.info("Phase 3: Enterprise started")));
    }
}
```

### With Error Handling

```java
public Uni<Enterprise> completeEnterpriseSetupWithErrorHandling(
        EnterpriseCreationRequest request,
        SecurityToken token) {

    return lifecycleManager.createNewEnterprise(request)
        .invoke(created -> log.info("Created enterprise: {}", created.getId()))
        .onFailure().invoke(ex -> log.error("Failed to create enterprise", ex))
        .onFailure().recoverWithUni(ex -> {
            // Handle creation failure
            return Uni.createFrom().failure(new EnterpriseCreationException("Creation failed", ex));
        })
        .chain(created -> lifecycleManager.loadUpdates(created, token)
            .invoke(() -> log.info("Loaded updates for: {}", created.getId()))
            .onFailure().invoke(ex -> log.error("Failed to load updates", ex))
            .onFailure().recoverWithUni(ex -> {
                // Rollback: mark enterprise as failed
                created.setActiveFlag(ActiveFlag.Deleted);
                return enterpriseService.updateEnterprise(created, token)
                    .chain(() -> Uni.createFrom().failure(
                        new EnterpriseUpdateException("Update failed", ex)));
            })
            .replaceWith(created))
        .chain(created -> lifecycleManager.startNewEnterprise(created, token)
            .invoke(started -> log.info("Started enterprise: {}", started.getId()))
            .onFailure().invoke(ex -> log.error("Failed to start enterprise", ex)));
}
```

---

## ActiveFlag Lifecycle

### ActiveFlag States

```java
public enum ActiveFlag {
    Unknown,    // Initial state before startup
    Deleted,    // Soft deleted
    Active,     // Fully operational
    Permanent   // Cannot be deleted
}
```

### State Transitions

```
Unknown → Active    (via startNewEnterprise)
Active → Deleted    (via soft delete)
Active → Permanent  (via admin action)
Any → Deleted       (via force delete)
```

### State Transition Implementation

```java
@ApplicationScoped
public class EnterpriseStateManager {
    @Inject
    IEnterpriseService enterpriseService;

    public Uni<Enterprise> transitionToActive(Enterprise enterprise, SecurityToken token) {
        if (enterprise.getActiveFlag() != ActiveFlag.Unknown) {
            return Uni.createFrom().failure(
                new IllegalStateException("Can only activate Unknown enterprises"));
        }

        enterprise.setActiveFlag(ActiveFlag.Active);
        return enterpriseService.updateEnterprise(enterprise, token);
    }

    public Uni<Enterprise> transitionToDeleted(Enterprise enterprise, SecurityToken token) {
        if (enterprise.getActiveFlag() == ActiveFlag.Permanent) {
            return Uni.createFrom().failure(
                new IllegalStateException("Cannot delete Permanent enterprises"));
        }

        enterprise.setActiveFlag(ActiveFlag.Deleted);
        return enterpriseService.updateEnterprise(enterprise, token);
    }

    public Uni<Enterprise> transitionToPermanent(Enterprise enterprise, SecurityToken token) {
        if (enterprise.getActiveFlag() != ActiveFlag.Active) {
            return Uni.createFrom().failure(
                new IllegalStateException("Can only make Active enterprises Permanent"));
        }

        enterprise.setActiveFlag(ActiveFlag.Permanent);
        return enterpriseService.updateEnterprise(enterprise, token);
    }
}
```

---

## Update Tracking

### System Update Audit Table

```sql
CREATE TABLE system_update_audit (
    id VARCHAR(255) PRIMARY KEY,
    enterprise_id VARCHAR(255) REFERENCES enterprises(id),
    update_id VARCHAR(255) NOT NULL,
    description TEXT,
    applied_at TIMESTAMP NOT NULL,
    applied_by VARCHAR(255),
    success BOOLEAN NOT NULL,
    error_message TEXT
);

CREATE INDEX idx_update_audit_enterprise ON system_update_audit(enterprise_id);
CREATE INDEX idx_update_audit_update_id ON system_update_audit(update_id);
```

### Audit Entity

```java
@Entity
@Table(name = "system_update_audit")
public class SystemUpdateAudit extends BaseEntity<SystemUpdateAudit, SystemUpdateAudit.SystemUpdateAuditQueryBuilder, String> {
    @Id
    private String id;

    @ManyToOne
    @JoinColumn(name = "enterprise_id")
    private Enterprise enterprise;

    @Column(name = "update_id")
    private String updateId;

    @Column(name = "description")
    private String description;

    @Column(name = "applied_at")
    private LocalDateTime appliedAt;

    @Column(name = "applied_by")
    private String appliedBy;

    @Column(name = "success")
    private Boolean success;

    @Column(name = "error_message")
    private String errorMessage;
}
```

### Audit Service

```java
@ApplicationScoped
public class UpdateAuditService {
    @Inject
    Mutiny.SessionFactory sessionFactory;

    public Uni<Void> recordUpdate(
            Enterprise enterprise,
            ISystemUpdate update,
            boolean success,
            String errorMessage,
            String appliedBy) {

        SystemUpdateAudit audit = new SystemUpdateAudit()
            .setId(UUID.randomUUID().toString())
            .setEnterprise(enterprise)
            .setUpdateId(update.getUpdateId())
            .setDescription(update.getDescription())
            .setAppliedAt(LocalDateTime.now())
            .setAppliedBy(appliedBy)
            .setSuccess(success)
            .setErrorMessage(errorMessage);

        return sessionFactory.withTransaction(session -> session.persist(audit));
    }

    public Uni<List<SystemUpdateAudit>> getEnterpriseUpdateHistory(String enterpriseId) {
        return sessionFactory.withSession(session ->
            new SystemUpdateAudit()
                .builder(session)
                .where("enterprise.id", Operand.Equals, enterpriseId)
                .orderBy("appliedAt", false)
                .getAll()
        );
    }
}
```

---

## Best Practices

### 1. Idempotent Updates

Always check if update is already applied:

```java
@Override
public Uni<Boolean> isApplied(Enterprise enterprise) {
    return service.checkExistence(enterprise.getId())
        .map(exists -> exists);
}
```

### 2. Transactional Updates

Wrap updates in transactions:

```java
@Override
public Uni<Void> applyUpdate(Enterprise enterprise, SecurityToken token) {
    return sessionFactory.withTransaction(session ->
        performUpdate(enterprise, session, token)
    );
}
```

### 3. Update Dependencies

Higher priority updates run first:

```java
@SortedUpdate(priority = 10)  // Runs first
public class RolesUpdate implements ISystemUpdate { }

@SortedUpdate(priority = 20)  // Runs second (can depend on roles)
public class PermissionsUpdate implements ISystemUpdate { }
```

### 4. Rollback Support

Implement cleanup for failed updates:

```java
@Override
public Uni<Void> applyUpdate(Enterprise enterprise, SecurityToken token) {
    return performUpdate(enterprise, token)
        .onFailure().call(ex -> rollback(enterprise, token));
}

private Uni<Void> rollback(Enterprise enterprise, SecurityToken token) {
    // Cleanup any partial changes
    return Uni.createFrom().voidItem();
}
```

### 5. Logging and Monitoring

Log all lifecycle events:

```java
log.info("Lifecycle Event: {}, Enterprise: {}, Status: {}",
    event, enterprise.getId(), enterprise.getActiveFlag());
```
