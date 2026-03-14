# ActivityMaster Feature Modules Reference

Complete reference for all ActivityMaster feature modules beyond the core FSDM services.

## Module Categories

### Core Infrastructure
- **core**: Base services, FSDM implementation, security
- **client**: Client-side libraries and utilities
- **bom**: Bill of Materials for dependency management
- **cerial**: Core serialization framework
- **cerial-client**: Client-side serialization

### Communication & Collaboration
- **conversations**: Threaded messaging and chat
- **mail**: Email integration and templates
- **notifications**: Multi-channel notification system

### Content Management
- **documents**: Document storage and versioning
- **files**: File upload, storage, and management
- **images**: Image processing and optimization

### Community & Social
- **forums**: Discussion boards and topics
- **profiles**: User profiles and preferences

### Task Management
- **tasks**: Task assignment and tracking
- **todo**: Personal todo lists

### Financial
- **payments**: Payment processing integration
- **wallet**: Digital wallet and balance management

### Specialized
- **geography**: Location services and spatial data
- **realtor**: Real estate specific functionality
- **user-sessions**: Session tracking and analytics

---

## Conversations Module

### Overview
Threaded messaging and real-time chat system with support for direct messages, group conversations, and channels.

### Entity Model

```java
@Entity
@Table(name = "conversations")
public class Conversation extends BaseEntity<Conversation, Conversation.ConversationQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "title")
    private String title;

    @Column(name = "conversation_type")
    @Enumerated(EnumType.STRING)
    private ConversationType type; // DIRECT, GROUP, CHANNEL

    @Column(name = "active_flag")
    @Enumerated(EnumType.STRING)
    private ActiveFlag activeFlag;

    @ManyToMany
    @JoinTable(name = "conversation_participants")
    private List<Enterprise> participants;

    @OneToMany(mappedBy = "conversation")
    private List<Message> messages;
}

@Entity
@Table(name = "messages")
public class Message extends BaseEntity<Message, Message.MessageQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    @Column(name = "edited_at")
    private LocalDateTime editedAt;

    @ManyToOne
    @JoinColumn(name = "conversation_id")
    private Conversation conversation;

    @ManyToOne
    @JoinColumn(name = "sender_id")
    private Enterprise sender;

    @ManyToOne
    @JoinColumn(name = "reply_to_message_id")
    private Message replyTo;
}
```

### Service API

```java
public interface IConversationsService {
    // Conversations
    Uni<Conversation> createConversation(Conversation conversation, List<String> participantIds);
    Uni<Conversation> addParticipant(String conversationId, String participantId, SecurityToken token);
    Uni<Conversation> removeParticipant(String conversationId, String participantId, SecurityToken token);
    Uni<List<Conversation>> listUserConversations(String userId, SecurityToken token);

    // Messages
    Uni<Message> sendMessage(String conversationId, String content, String senderId, SecurityToken token);
    Uni<Message> replyToMessage(String messageId, String content, String senderId, SecurityToken token);
    Uni<Message> editMessage(String messageId, String newContent, SecurityToken token);
    Uni<Void> deleteMessage(String messageId, SecurityToken token);
    Uni<List<Message>> getConversationMessages(String conversationId, int limit, int offset, SecurityToken token);
}
```

### Usage Example

```java
// Create group conversation
Conversation conversation = new Conversation()
    .setTitle("Project Team Chat")
    .setType(ConversationType.GROUP)
    .setActiveFlag(ActiveFlag.Active);

conversationsService.createConversation(conversation, List.of(userId1, userId2, userId3))
    .chain(created ->
        conversationsService.sendMessage(created.getId(), "Welcome to the team!", userId1, token)
    )
    .await().indefinitely();
```

---

## Documents Module

### Overview
Document management with versioning, metadata, and access control.

### Entity Model

```java
@Entity
@Table(name = "documents")
public class Document extends BaseEntity<Document, Document.DocumentQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "title")
    private String title;

    @Column(name = "description")
    private String description;

    @Column(name = "document_type")
    private String documentType;

    @Column(name = "version")
    private Integer version;

    @Column(name = "file_path")
    private String filePath;

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "mime_type")
    private String mimeType;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @ManyToOne
    @JoinColumn(name = "enterprise_id")
    private Enterprise owner;

    @ManyToOne
    @JoinColumn(name = "parent_document_id")
    private Document parentDocument;
}
```

### Service API

```java
public interface IDocumentsService {
    Uni<Document> createDocument(Document document, InputStream fileData, String enterpriseId);
    Uni<Document> updateDocument(String id, Document updates, SecurityToken token);
    Uni<Document> createNewVersion(String documentId, InputStream fileData, SecurityToken token);
    Uni<List<Document>> listDocumentVersions(String documentId, SecurityToken token);
    Uni<InputStream> downloadDocument(String id, SecurityToken token);
    Uni<Void> deleteDocument(String id, SecurityToken token);
    Uni<List<Document>> searchDocuments(String query, SecurityToken token);
}
```

---

## Files Module

### Overview
General file storage with cloud integration support (S3, Azure Blob, etc.).

### Entity Model

```java
@Entity
@Table(name = "files")
public class File extends BaseEntity<File, File.FileQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "filename")
    private String filename;

    @Column(name = "original_filename")
    private String originalFilename;

    @Column(name = "storage_path")
    private String storagePath;

    @Column(name = "storage_provider")
    private String storageProvider; // LOCAL, S3, AZURE_BLOB

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "mime_type")
    private String mimeType;

    @Column(name = "checksum")
    private String checksum;

    @Column(name = "uploaded_at")
    private LocalDateTime uploadedAt;

    @ManyToOne
    @JoinColumn(name = "uploaded_by")
    private Enterprise uploadedBy;
}
```

### Service API

```java
public interface IFilesService {
    Uni<File> uploadFile(String filename, InputStream data, String mimeType, String uploaderId);
    Uni<InputStream> downloadFile(String id, SecurityToken token);
    Uni<Void> deleteFile(String id, SecurityToken token);
    Uni<File> getFileMetadata(String id, SecurityToken token);
    Uni<List<File>> listUserFiles(String userId, SecurityToken token);
    Uni<String> generateDownloadUrl(String id, Duration expiration, SecurityToken token);
}
```

---

## Forums Module

### Overview
Discussion boards with topics, posts, and moderation features.

### Entity Model

```java
@Entity
@Table(name = "forum_boards")
public class ForumBoard extends BaseEntity<ForumBoard, ForumBoard.ForumBoardQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "name")
    private String name;

    @Column(name = "description")
    private String description;

    @OneToMany(mappedBy = "board")
    private List<ForumTopic> topics;
}

@Entity
@Table(name = "forum_topics")
public class ForumTopic extends BaseEntity<ForumTopic, ForumTopic.ForumTopicQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "title")
    private String title;

    @Column(name = "is_locked")
    private Boolean isLocked;

    @Column(name = "is_pinned")
    private Boolean isPinned;

    @ManyToOne
    @JoinColumn(name = "board_id")
    private ForumBoard board;

    @ManyToOne
    @JoinColumn(name = "created_by")
    private Enterprise createdBy;

    @OneToMany(mappedBy = "topic")
    private List<ForumPost> posts;
}

@Entity
@Table(name = "forum_posts")
public class ForumPost extends BaseEntity<ForumPost, ForumPost.ForumPostQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @ManyToOne
    @JoinColumn(name = "topic_id")
    private ForumTopic topic;

    @ManyToOne
    @JoinColumn(name = "author_id")
    private Enterprise author;
}
```

---

## Geography Module

### Overview
Geospatial services, location tracking, and proximity search.

### Entity Model

```java
@Entity
@Table(name = "locations")
public class Location extends BaseEntity<Location, Location.LocationQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "name")
    private String name;

    @Column(name = "latitude", nullable = false)
    private Double latitude;

    @Column(name = "longitude", nullable = false)
    private Double longitude;

    @Column(name = "altitude")
    private Double altitude;

    @Column(name = "accuracy")
    private Double accuracy;

    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;

    @ManyToOne
    @JoinColumn(name = "enterprise_id")
    private Enterprise enterprise;
}
```

### Service API

```java
public interface IGeographyService {
    Uni<Location> recordLocation(Location location, String enterpriseId);
    Uni<List<Location>> findNearbyLocations(Double lat, Double lng, Double radiusKm, SecurityToken token);
    Uni<Double> calculateDistance(String locationId1, String locationId2);
    Uni<List<Location>> getLocationHistory(String enterpriseId, LocalDateTime since, SecurityToken token);
}
```

---

## Images Module

### Overview
Image upload, processing, optimization, and thumbnail generation.

### Entity Model

```java
@Entity
@Table(name = "images")
public class Image extends BaseEntity<Image, Image.ImageQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "filename")
    private String filename;

    @Column(name = "original_path")
    private String originalPath;

    @Column(name = "thumbnail_path")
    private String thumbnailPath;

    @Column(name = "width")
    private Integer width;

    @Column(name = "height")
    private Integer height;

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "format")
    private String format; // JPEG, PNG, WEBP

    @Column(name = "uploaded_at")
    private LocalDateTime uploadedAt;

    @ManyToOne
    @JoinColumn(name = "uploaded_by")
    private Enterprise uploadedBy;
}
```

### Service API

```java
public interface IImagesService {
    Uni<Image> uploadImage(String filename, InputStream data, String uploaderId);
    Uni<Image> generateThumbnail(String imageId, int width, int height);
    Uni<Image> resizeImage(String imageId, int width, int height);
    Uni<Image> optimizeImage(String imageId);
    Uni<InputStream> downloadImage(String id, SecurityToken token);
    Uni<InputStream> downloadThumbnail(String id, SecurityToken token);
}
```

---

## Mail Module

### Overview
Email sending, templates, and delivery tracking.

### Entity Model

```java
@Entity
@Table(name = "email_messages")
public class EmailMessage extends BaseEntity<EmailMessage, EmailMessage.EmailMessageQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "subject")
    private String subject;

    @Column(name = "body", columnDefinition = "TEXT")
    private String body;

    @Column(name = "from_address")
    private String fromAddress;

    @Column(name = "to_addresses")
    private String toAddresses;

    @Column(name = "cc_addresses")
    private String ccAddresses;

    @Column(name = "status")
    @Enumerated(EnumType.STRING)
    private EmailStatus status; // QUEUED, SENT, FAILED

    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    @Column(name = "error_message")
    private String errorMessage;
}
```

### Service API

```java
public interface IMailService {
    Uni<EmailMessage> sendEmail(String to, String subject, String body);
    Uni<EmailMessage> sendEmailFromTemplate(String to, String templateId, Map<String, Object> variables);
    Uni<EmailMessage> sendEmailWithAttachments(String to, String subject, String body, List<String> fileIds);
    Uni<EmailMessage> getEmailStatus(String id, SecurityToken token);
    Uni<List<EmailMessage>> listSentEmails(String enterpriseId, SecurityToken token);
}
```

---

## Notifications Module

### Overview
Multi-channel notification system (push, email, SMS, in-app).

### Entity Model

```java
@Entity
@Table(name = "notifications")
public class Notification extends BaseEntity<Notification, Notification.NotificationQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "title")
    private String title;

    @Column(name = "message")
    private String message;

    @Column(name = "notification_type")
    @Enumerated(EnumType.STRING)
    private NotificationType type; // PUSH, EMAIL, SMS, IN_APP

    @Column(name = "priority")
    @Enumerated(EnumType.STRING)
    private NotificationPriority priority; // LOW, MEDIUM, HIGH, URGENT

    @Column(name = "is_read")
    private Boolean isRead;

    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    @ManyToOne
    @JoinColumn(name = "recipient_id")
    private Enterprise recipient;
}
```

### Service API

```java
public interface INotificationsService {
    Uni<Notification> sendNotification(String recipientId, String title, String message, NotificationType type);
    Uni<Notification> markAsRead(String notificationId, SecurityToken token);
    Uni<Void> markAllAsRead(String userId, SecurityToken token);
    Uni<List<Notification>> listUnreadNotifications(String userId, SecurityToken token);
    Uni<List<Notification>> listAllNotifications(String userId, int limit, int offset, SecurityToken token);
    Uni<Long> getUnreadCount(String userId, SecurityToken token);
}
```

---

## Payments Module

### Overview
Payment processing with support for multiple payment providers (Stripe, PayPal, etc.).

### Entity Model

```java
@Entity
@Table(name = "payments")
public class Payment extends BaseEntity<Payment, Payment.PaymentQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "amount", nullable = false)
    private BigDecimal amount;

    @Column(name = "currency")
    private String currency;

    @Column(name = "payment_method")
    private String paymentMethod; // CARD, BANK_TRANSFER, PAYPAL

    @Column(name = "status")
    @Enumerated(EnumType.STRING)
    private PaymentStatus status; // PENDING, COMPLETED, FAILED, REFUNDED

    @Column(name = "provider_transaction_id")
    private String providerTransactionId;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @ManyToOne
    @JoinColumn(name = "payer_id")
    private Enterprise payer;

    @ManyToOne
    @JoinColumn(name = "payee_id")
    private Enterprise payee;
}
```

### Service API

```java
public interface IPaymentsService {
    Uni<Payment> createPayment(String payerId, String payeeId, BigDecimal amount, String currency);
    Uni<Payment> processPayment(String paymentId, String paymentMethod, SecurityToken token);
    Uni<Payment> refundPayment(String paymentId, SecurityToken token);
    Uni<Payment> getPaymentStatus(String id, SecurityToken token);
    Uni<List<Payment>> listPayments(String enterpriseId, SecurityToken token);
}
```

---

## Profiles Module

### Overview
User profiles, preferences, and customization settings.

### Entity Model

```java
@Entity
@Table(name = "user_profiles")
public class UserProfile extends BaseEntity<UserProfile, UserProfile.UserProfileQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "display_name")
    private String displayName;

    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "timezone")
    private String timezone;

    @Column(name = "locale")
    private String locale;

    @Column(name = "theme")
    private String theme;

    @OneToOne
    @JoinColumn(name = "enterprise_id")
    private Enterprise enterprise;

    @ElementCollection
    @CollectionTable(name = "profile_preferences")
    private Map<String, String> preferences;
}
```

### Service API

```java
public interface IProfilesService {
    Uni<UserProfile> createProfile(UserProfile profile, String enterpriseId);
    Uni<UserProfile> updateProfile(String id, UserProfile updates, SecurityToken token);
    Uni<UserProfile> getProfile(String enterpriseId, SecurityToken token);
    Uni<UserProfile> uploadAvatar(String profileId, InputStream imageData, SecurityToken token);
    Uni<UserProfile> updatePreference(String profileId, String key, String value, SecurityToken token);
}
```

---

## Tasks Module

### Overview
Task assignment, tracking, and collaboration with dependencies and workflows.

### Entity Model

```java
@Entity
@Table(name = "tasks")
public class Task extends BaseEntity<Task, Task.TaskQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "title")
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "status")
    @Enumerated(EnumType.STRING)
    private TaskStatus status; // TODO, IN_PROGRESS, REVIEW, COMPLETED, CANCELLED

    @Column(name = "priority")
    @Enumerated(EnumType.STRING)
    private TaskPriority priority; // LOW, MEDIUM, HIGH, CRITICAL

    @Column(name = "due_date")
    private LocalDate dueDate;

    @Column(name = "estimated_hours")
    private Integer estimatedHours;

    @Column(name = "actual_hours")
    private Integer actualHours;

    @ManyToOne
    @JoinColumn(name = "assignee_id")
    private Enterprise assignee;

    @ManyToOne
    @JoinColumn(name = "created_by")
    private Enterprise createdBy;

    @ManyToMany
    @JoinTable(name = "task_dependencies")
    private List<Task> dependencies;
}
```

### Service API

```java
public interface ITasksService {
    Uni<Task> createTask(Task task, String assigneeId, String creatorId);
    Uni<Task> updateTask(String id, Task updates, SecurityToken token);
    Uni<Task> updateTaskStatus(String id, TaskStatus status, SecurityToken token);
    Uni<Task> assignTask(String id, String assigneeId, SecurityToken token);
    Uni<Task> addDependency(String taskId, String dependencyId, SecurityToken token);
    Uni<List<Task>> listUserTasks(String userId, SecurityToken token);
    Uni<List<Task>> listOverdueTasks(SecurityToken token);
}
```

---

## Todo Module

### Overview
Personal todo lists with priorities and due dates.

### Entity Model

```java
@Entity
@Table(name = "todo_items")
public class TodoItem extends BaseEntity<TodoItem, TodoItem.TodoItemQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "title")
    private String title;

    @Column(name = "notes")
    private String notes;

    @Column(name = "is_completed")
    private Boolean isCompleted;

    @Column(name = "due_date")
    private LocalDate dueDate;

    @Column(name = "priority")
    private Integer priority;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @ManyToOne
    @JoinColumn(name = "owner_id")
    private Enterprise owner;
}
```

---

## User Sessions Module

### Overview
Session tracking, analytics, and user activity monitoring.

### Entity Model

```java
@Entity
@Table(name = "user_sessions")
public class UserSession extends BaseEntity<UserSession, UserSession.UserSessionQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "session_token")
    private String sessionToken;

    @Column(name = "ip_address")
    private String ipAddress;

    @Column(name = "user_agent")
    private String userAgent;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "last_activity_at")
    private LocalDateTime lastActivityAt;

    @Column(name = "ended_at")
    private LocalDateTime endedAt;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private Enterprise user;
}
```

---

## Wallet Module

### Overview
Digital wallet for balance management, transactions, and credits.

### Entity Model

```java
@Entity
@Table(name = "wallets")
public class Wallet extends BaseEntity<Wallet, Wallet.WalletQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "balance", nullable = false)
    private BigDecimal balance;

    @Column(name = "currency")
    private String currency;

    @OneToOne
    @JoinColumn(name = "enterprise_id")
    private Enterprise owner;

    @OneToMany(mappedBy = "wallet")
    private List<WalletTransaction> transactions;
}

@Entity
@Table(name = "wallet_transactions")
public class WalletTransaction extends BaseEntity<WalletTransaction, WalletTransaction.WalletTransactionQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "amount")
    private BigDecimal amount;

    @Column(name = "transaction_type")
    @Enumerated(EnumType.STRING)
    private TransactionType type; // CREDIT, DEBIT

    @Column(name = "description")
    private String description;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @ManyToOne
    @JoinColumn(name = "wallet_id")
    private Wallet wallet;
}
```

### Service API

```java
public interface IWalletService {
    Uni<Wallet> createWallet(String enterpriseId, String currency);
    Uni<Wallet> getWallet(String enterpriseId, SecurityToken token);
    Uni<Wallet> creditWallet(String walletId, BigDecimal amount, String description, SecurityToken token);
    Uni<Wallet> debitWallet(String walletId, BigDecimal amount, String description, SecurityToken token);
    Uni<List<WalletTransaction>> getTransactionHistory(String walletId, SecurityToken token);
    Uni<BigDecimal> getBalance(String walletId, SecurityToken token);
}
```

---

## Realtor Module

### Overview
Real estate specific functionality including property listings, showings, and offers.

### Entity Model

```java
@Entity
@Table(name = "properties")
public class Property extends BaseEntity<Property, Property.PropertyQueryBuilder, String> {
    @Id
    private String id;

    @Column(name = "listing_type")
    private String listingType; // SALE, RENT

    @Column(name = "property_type")
    private String propertyType; // HOUSE, APARTMENT, CONDO

    @Column(name = "price")
    private BigDecimal price;

    @Column(name = "bedrooms")
    private Integer bedrooms;

    @Column(name = "bathrooms")
    private Integer bathrooms;

    @Column(name = "square_feet")
    private Integer squareFeet;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @ManyToOne
    @JoinColumn(name = "address_id")
    private Address address;

    @ManyToOne
    @JoinColumn(name = "agent_id")
    private Enterprise agent;
}
```

### Service API

```java
public interface IRealtorService {
    Uni<Property> createListing(Property property, String addressId, String agentId);
    Uni<List<Property>> searchProperties(PropertySearchCriteria criteria, SecurityToken token);
    Uni<List<Property>> findPropertiesNearby(Double lat, Double lng, Double radiusKm, SecurityToken token);
    Uni<Property> updateListing(String id, Property updates, SecurityToken token);
}
```

---

## Module Integration Patterns

### Cross-Module Communication

```java
// Example: Task with document attachments
tasksService.createTask(task, assigneeId, creatorId)
    .chain(created ->
        documentsService.uploadDocument(document, fileData, creatorId)
            .chain(doc -> {
                // Link document to task (via custom join table)
                return taskDocumentService.linkDocument(created.getId(), doc.getId(), token);
            })
    )
    .await().indefinitely();
```

### Event-Driven Integration

```java
// Notification on task assignment
@ApplicationScoped
public class TaskEventHandler {
    @Inject
    INotificationsService notificationsService;

    public Uni<Void> onTaskAssigned(Task task) {
        return notificationsService.sendNotification(
            task.getAssignee().getId(),
            "New Task Assigned",
            "You have been assigned: " + task.getTitle(),
            NotificationType.PUSH
        ).replaceWithVoid();
    }
}
```

### Module Dependencies

Common dependency chains:
- **Tasks** → **Notifications** → **Mail**
- **Conversations** → **Notifications** → **Profiles**
- **Payments** → **Wallet** → **Notifications**
- **Documents** → **Files** → **Images**
- **Forums** → **Profiles** → **Images**
