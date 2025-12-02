# Validation Rules

**Validate grid requests and user input**

---

## Overview

Validation ensures data integrity and security. Server-side validation is mandatory; client-side validation improves UX.

---

## Server-Side Validation

### Validating Grid Requests

```java
@Log4j2
public class GridDataUpdateReceiver extends WebSocketAbstractCallReceiver<...> {
    
    @Inject
    private Validator validator;
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        try {
            // Extract and validate parameters
            GridRequest request = extractRequest(call);
            
            Set<ConstraintViolation<GridRequest>> violations = validator.validate(request);
            if (!violations.isEmpty()) {
                response.setStatus(400);
                List<String> errors = violations.stream()
                    .map(ConstraintViolation::getMessage)
                    .collect(Collectors.toList());
                response.addDataResponse("validationErrors", errors);
                log.warn("Grid request validation failed: {}", errors);
                return Uni.createFrom().item(response);
            }
            
            // Request valid, proceed
            var data = fetchData(request);
            response.addDataResponse("rowData", data);
            return Uni.createFrom().item(response);
        } catch (Exception e) {
            log.error("Error in grid request handler", e);
            response.setStatus(500);
            return Uni.createFrom().item(response);
        }
    }
}
```

### GridRequest with Validation Annotations

```java
public class GridRequest {
    
    @NotNull(message = "Page index required")
    @Min(value = 0, message = "Page index must be non-negative")
    private Integer pageIndex;
    
    @NotNull(message = "Page size required")
    @Min(value = 1, message = "Page size must be at least 1")
    @Max(value = 1000, message = "Page size cannot exceed 1000")
    private Integer pageSize;
    
    @Size(max = 500, message = "Filter text too long")
    private String filterText;
    
    @Pattern(regexp = "^(asc|desc)$", message = "Sort direction must be 'asc' or 'desc'")
    private String sortDirection;
    
    @NotBlank(message = "Sort column required")
    @Size(max = 100, message = "Column name too long")
    private String sortColumn;
    
    // Getters/setters
    public Integer getPageIndex() { return pageIndex; }
    public void setPageIndex(Integer index) { this.pageIndex = index; }
    
    public Integer getPageSize() { return pageSize; }
    public void setPageSize(Integer size) { this.pageSize = size; }
    
    public String getFilterText() { return filterText; }
    public void setFilterText(String text) { this.filterText = text; }
    
    public String getSortDirection() { return sortDirection; }
    public void setSortDirection(String dir) { this.sortDirection = dir; }
    
    public String getSortColumn() { return sortColumn; }
    public void setSortColumn(String col) { this.sortColumn = col; }
}
```

---

## Cell Data Validation

### Validating Cell Updates

```java
@Log4j2
public class CellUpdateReceiver extends WebSocketAbstractCallReceiver<...> {
    
    @Inject
    private Validator validator;
    
    @Inject
    private RecordRepository repository;
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        try {
            String recordId = (String) call.getParameters().get("recordId");
            String fieldName = (String) call.getParameters().get("fieldName");
            Object newValue = call.getParameters().get("newValue");
            
            // Validate the new value
            ConstraintViolation<?>[] violations = validateCellUpdate(
                fieldName,
                newValue
            );
            
            if (violations.length > 0) {
                response.setStatus(422);  // Unprocessable Entity
                response.addDataResponse("validationError", violations[0].getMessage());
                log.warn("Cell update validation failed: field={}, error={}",
                    fieldName, violations[0].getMessage());
                return Uni.createFrom().item(response);
            }
            
            // Update record
            return repository.updateField(recordId, fieldName, newValue)
                .map(updated -> {
                    response.addDataResponse("updated", updated);
                    return response;
                });
        } catch (Exception e) {
            log.error("Error updating cell", e);
            response.setStatus(500);
            return Uni.createFrom().item(response);
        }
    }
    
    private ConstraintViolation<?>[] validateCellUpdate(String field, Object value) {
        // Field-specific validation
        return switch (field) {
            case "email" -> validateEmail((String) value);
            case "phone" -> validatePhone((String) value);
            case "age" -> validateAge((Integer) value);
            case "salary" -> validateSalary((BigDecimal) value);
            default -> new ConstraintViolation[0];
        };
    }
    
    private ConstraintViolation<?>[] validateEmail(String email) {
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            return new ConstraintViolation[]{
                createViolation("Invalid email format")
            };
        }
        return new ConstraintViolation[0];
    }
    
    private ConstraintViolation<?>[] validatePhone(String phone) {
        if (phone == null || !phone.matches("^\\d{10,15}$")) {
            return new ConstraintViolation[]{
                createViolation("Phone must be 10-15 digits")
            };
        }
        return new ConstraintViolation[0];
    }
    
    private ConstraintViolation<?>[] validateAge(Integer age) {
        if (age == null || age < 0 || age > 150) {
            return new ConstraintViolation[]{
                createViolation("Age must be between 0 and 150")
            };
        }
        return new ConstraintViolation[0];
    }
    
    private ConstraintViolation<?>[] validateSalary(BigDecimal salary) {
        if (salary == null || salary.signum() <= 0) {
            return new ConstraintViolation[]{
                createViolation("Salary must be positive")
            };
        }
        return new ConstraintViolation[0];
    }
}
```

---

## Client-Side Validation

### Angular Template Validation

```html
<input type="email" 
       [(ngModel)]="cellValue" 
       (blur)="validateCell()"
       [class.is-invalid]="cellError !== null">
<div *ngIf="cellError" class="error-message">{{ cellError }}</div>
```

### TypeScript Validation Logic

```typescript
export class GridComponent {
    cellValue: string;
    cellError: string | null = null;
    
    validateCell(): void {
        if (!this.cellValue || this.cellValue.trim().length === 0) {
            this.cellError = "Value required";
            return;
        }
        
        if (this.cellValue.length > 100) {
            this.cellError = "Value too long";
            return;
        }
        
        this.cellError = null;
    }
}
```

---

## Authorization & Security Validation

### Access Control Validation

```java
@Log4j2
public class SecureGridReceiver extends WebSocketAbstractCallReceiver<...> {
    
    @Inject
    private AuthService authService;
    
    @Inject
    private DataRepository repository;
    
    @Override
    public Uni<AjaxResponse<?>> action(AjaxCall<?> call, AjaxResponse<?> response) {
        try {
            String userId = (String) call.getParameters().get("userId");
            String action = (String) call.getParameters().get("action");
            
            // Validate user
            if (!authService.isValidUser(userId)) {
                response.setStatus(401);  // Unauthorized
                log.warn("Invalid user: {}", userId);
                return Uni.createFrom().item(response);
            }
            
            // Validate permission
            if (!authService.hasPermission(userId, "VIEW_GRID")) {
                response.setStatus(403);  // Forbidden
                log.warn("User {} lacks VIEW_GRID permission", userId);
                return Uni.createFrom().item(response);
            }
            
            // Validate action
            if (action.equals("delete") && !authService.hasPermission(userId, "DELETE_RECORD")) {
                response.setStatus(403);
                log.warn("User {} lacks DELETE_RECORD permission", userId);
                return Uni.createFrom().item(response);
            }
            
            // Action authorized
            return handleAction(userId, action, response);
        } catch (Exception e) {
            log.error("Security validation error", e);
            response.setStatus(500);
            return Uni.createFrom().item(response);
        }
    }
}
```

---

## Custom Validation Rules

### Bean Validation Annotation

```java
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = PhoneNumberValidator.class)
public @interface ValidPhoneNumber {
    String message() default "Invalid phone number";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

public class PhoneNumberValidator implements ConstraintValidator<ValidPhoneNumber, String> {
    
    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null) return true;  // @NotNull handles null
        return value.matches("^\\d{10,15}$");
    }
}
```

### Usage in Entity

```java
public class Employee {
    
    @NotBlank
    private String name;
    
    @Email
    private String email;
    
    @ValidPhoneNumber
    private String phone;
    
    @Min(18)
    @Max(150)
    private Integer age;
}
```

---

## Validation in Grid Configuration

### AgGridOptions Validation

```java
public class GridRequest {
    
    @NotNull
    @Valid  // Validate nested object
    private AgGridOptions gridOptions;
    
    @NotEmpty
    @Valid  // Validate list elements
    private List<AgGridColumnDef> columnDefs;
}
```

---

## Error Response Format

### Standard Validation Error Response

```java
public class ValidationErrorResponse {
    private int status = 422;
    private String message = "Validation failed";
    private Map<String, List<String>> fieldErrors = new LinkedHashMap<>();
    
    public void addFieldError(String field, String error) {
        fieldErrors.computeIfAbsent(field, k -> new ArrayList<>())
            .add(error);
    }
    
    // Getters/setters
}
```

### Error Response Example

```json
{
  "status": 422,
  "message": "Validation failed",
  "fieldErrors": {
    "email": ["Invalid email format", "Email already exists"],
    "age": ["Age must be between 18 and 100"],
    "salary": ["Salary must be positive"]
  }
}
```

---

## Best Practices

### ✅ DO

- Always validate on the server (never trust client)
- Use Bean Validation annotations for simple rules
- Provide clear, user-friendly error messages
- Validate before database operations
- Log validation failures for security audits
- Return appropriate HTTP status codes (400, 422, 403)

### ❌ DO NOT

- Rely on client-side validation alone
- Use generic error messages ("Error" or "Invalid")
- Expose internal validation logic in error messages
- Validate at the UI layer only
- Ignore OWASP validation guidelines

---

## Related Documents

- **[WebSocket Integration](./websocket-integration.rules.md)** — Validation in receivers
- **[Event Handling](./event-handling.rules.md)** — Validating event parameters
- **[Data Binding](./data-binding.rules.md)** — Validating grid requests
