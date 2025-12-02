# Security Rules

**Prevent CSRF, XSS, injection attacks; enforce access control**

---

## Overview

Security priorities for AG Grid plugin:
- Prevent Cross-Site Request Forgery (CSRF)
- Prevent Cross-Site Scripting (XSS)
- Validate and sanitize all input
- Enforce access control on grid operations
- Log security events for audit trail

---

## CSRF Protection

### Spring Security CSRF Configuration

```java
@Configuration
@EnableWebSecurity
public class SecurityConfiguration {
  
  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
      .csrf(csrf -> csrf
        .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
        .ignoringRequestMatchers("/api/public/**", "/health")
      )
      .sessionManagement(session -> session
        .sessionFixationProtection(SessionFixationProtectionStrategy.MIGRATE_SESSION)
        .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
      )
      .authorizeHttpRequests(authz -> authz
        .requestMatchers("/api/grid/**").authenticated()
        .requestMatchers("/api/public/**").permitAll()
        .anyRequest().authenticated()
      )
      .build();
    
    return http.build();
  }
}

// CSRF token endpoint
@RestController
@RequestMapping("/api")
public class CsrfTokenController {
  
  @GetMapping("/csrf-token")
  public CsrfToken csrfToken(CsrfToken token) {
    return token;
  }
}
```

### Angular CSRF Token Integration

```typescript
import { HTTP_INTERCEPTORS, HttpClientXsrfTokenExtractor } from '@angular/common/http';
import { HttpClientXsrfModule } from '@angular/common/http';

@NgModule({
  imports: [
    HttpClientXsrfModule.withOptions({
      cookieName: 'XSRF-TOKEN',
      headerName: 'X-XSRF-TOKEN'
    })
  ]
})
export class AppModule { }

// Fetch and configure CSRF token
@Injectable()
export class CsrfInterceptor implements HttpInterceptor {
  
  constructor(private csrfTokenExtractor: HttpClientXsrfTokenExtractor) {}
  
  intercept(
    req: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    const token = this.csrfTokenExtractor.getToken() as string;
    
    if (token && req.method !== 'GET') {
      req = req.clone({
        setHeaders: {
          'X-XSRF-TOKEN': token
        }
      });
    }
    
    return next.handle(req);
  }
}
```

---

## XSS Prevention

### Angular Template Security

```typescript
// UNSAFE: Do NOT use this pattern
export class UnsafeGridComponent {
  userHtml = '<img src=x onerror="alert(\'XSS\')">';
  
  // DANGEROUS - bypasses Angular sanitization
  constructor(private sanitizer: DomSanitizer) {}
  safeHtml = this.sanitizer.bypassSecurityTrustHtml(this.userHtml);
  
  // Template (UNSAFE):
  // <div [innerHTML]="safeHtml"></div>
}

// SAFE: Use Angular's built-in sanitization
export class SafeGridComponent implements AfterViewInit {
  @ViewChild('gridContainer') gridContainer!: ElementRef;
  
  gridData: { name: string; description: string }[] = [];
  
  ngAfterViewInit(): void {
    // Cell renderer receives sanitized data
    const columnDefs = [
      {
        field: 'name',
        cellRenderer: (params: any) => {
          // Angular automatically escapes
          return params.value; // <name> becomes &lt;name&gt;
        }
      },
      {
        field: 'description',
        // Use textContent, not innerHTML
        cellRenderer: (params: any) => {
          const cell = document.createElement('span');
          cell.textContent = params.value; // Safe: text only
          return cell;
        }
      }
    ];
  }
}
```

### Server-Side HTML Escaping

```java
import org.owasp.encoder.Encode;

@RestController
@RequestMapping("/api/grid")
public class GridController {
  
  @GetMapping("/{gridId}/data")
  public ResponseEntity<AjaxResponse<PagedResponse<OrderRow>>> getGridData(
    @PathVariable String gridId,
    @RequestParam(required = false) String filter,
    @RequestParam(required = false) String search
  ) {
    // Validate and escape user input
    String safeGridId = validateAndEscapeGridId(gridId);
    String safeFilter = escapeJsonString(filter);
    String safeSearch = escapeSearchTerm(search);
    
    List<OrderRow> data = orderRepository.findByGridAndFilter(
      safeGridId,
      safeFilter,
      safeSearch
    );
    
    return ResponseEntity.ok(new AjaxResponse<>(
      new PagedResponse<>(data)
    ));
  }
  
  private String validateAndEscapeGridId(String gridId) {
    // Validate format: alphanumeric + underscore only
    if (!gridId.matches("^[a-zA-Z0-9_-]{1,50}$")) {
      throw new IllegalArgumentException("Invalid gridId format");
    }
    return gridId;
  }
  
  private String escapeJsonString(String value) {
    if (value == null) return null;
    return Encode.forJava(value);
  }
  
  private String escapeSearchTerm(String term) {
    if (term == null) return null;
    return Encode.forHtml(term);
  }
}

@Data
@Entity
@Table(name = "order_rows")
public class OrderRow {
  
  @Id
  private Long id;
  
  @Column(nullable = false)
  @Size(min = 1, max = 255)
  private String customerName; // Validated on save
  
  @Column(nullable = false)
  @Min(0)
  @Digits(integer = 10, fraction = 2)
  private BigDecimal amount; // Validated on save
  
  @Enumerated(EnumType.STRING)
  private OrderStatus status; // Enum: safe from injection
  
  @CreationTimestamp
  private LocalDateTime createdAt;
}
```

---

## Input Validation

### Server-Side Validation (Mandatory)

```java
@RestController
@RequestMapping("/api/grid")
public class GridDataController {
  
  @PostMapping("/{gridId}/data")
  public ResponseEntity<AjaxResponse<PagedResponse<OrderRow>>> saveGridData(
    @PathVariable String gridId,
    @Valid @RequestBody CreateOrderRequest request,
    BindingResult bindingResult
  ) {
    // Validate request format
    if (bindingResult.hasErrors()) {
      return ResponseEntity.badRequest().body(
        new AjaxResponse<>(
          false,
          "Validation failed: " + bindingResult.getFieldError().getDefaultMessage()
        )
      );
    }
    
    // Business logic validation
    validateOrderData(request);
    
    // Sanitize data before persistence
    OrderRow orderRow = mapAndSanitize(request);
    orderRepository.save(orderRow);
    
    return ResponseEntity.ok(
      new AjaxResponse<>(new PagedResponse<>(List.of(orderRow)))
    );
  }
  
  private void validateOrderData(CreateOrderRequest request) {
    // Validate amount > 0
    if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
      throw new IllegalArgumentException("Amount must be greater than 0");
    }
    
    // Validate status is valid enum
    try {
      OrderStatus.valueOf(request.getStatus());
    } catch (IllegalArgumentException e) {
      throw new IllegalArgumentException("Invalid order status");
    }
    
    // Validate customer name length
    if (request.getCustomerName() == null || 
        request.getCustomerName().length() < 1 || 
        request.getCustomerName().length() > 255) {
      throw new IllegalArgumentException("Customer name must be 1-255 characters");
    }
  }
  
  private OrderRow mapAndSanitize(CreateOrderRequest request) {
    OrderRow row = new OrderRow();
    row.setCustomerName(request.getCustomerName().trim());
    row.setAmount(request.getAmount());
    row.setStatus(OrderStatus.valueOf(request.getStatus()));
    return row;
  }
}

@Data
@Validated
public class CreateOrderRequest {
  
  @NotBlank(message = "Customer name is required")
  @Size(min = 1, max = 255, message = "Customer name must be 1-255 characters")
  private String customerName;
  
  @NotNull(message = "Amount is required")
  @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
  @DecimalMax(value = "999999.99", message = "Amount exceeds maximum")
  private BigDecimal amount;
  
  @NotBlank(message = "Status is required")
  @Pattern(regexp = "PENDING|APPROVED|SHIPPED|DELIVERED", message = "Invalid status")
  private String status;
}
```

### Parameterized Queries (Prevent SQL Injection)

```java
// UNSAFE: String concatenation
String query = "SELECT * FROM orders WHERE customer_name = '" + customerName + "'";
// Vulnerable to: name = "'; DROP TABLE orders; --"

// SAFE: JPA with parameterized queries
public interface OrderRepository extends JpaRepository<OrderRow, Long> {
  
  // JPA automatically parameterizes
  List<OrderRow> findByCustomerName(String customerName);
  
  // Using Specifications
  List<OrderRow> findAll(Specification<OrderRow> spec);
  
  // Using Query Annotations
  @Query("SELECT o FROM OrderRow o WHERE o.customerName = :name")
  List<OrderRow> findByName(@Param("name") String name);
}

// Usage
List<OrderRow> orders = orderRepository.findByCustomerName(userInput);
// userInput is safely parameterized, no injection possible
```

---

## Access Control

### Authorization at Grid Level

```java
@RestController
@RequestMapping("/api/grid")
public class GridAccessController {
  
  @PreAuthorize("hasRole('USER')")
  @GetMapping("/{gridId}/data")
  public ResponseEntity<AjaxResponse<PagedResponse<OrderRow>>> getGridData(
    @PathVariable String gridId,
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "50") int pageSize,
    @AuthenticationPrincipal UserDetails userDetails
  ) {
    // Check if user has access to this grid
    if (!hasAccessToGrid(gridId, userDetails)) {
      throw new AccessDeniedException("Access denied to grid: " + gridId);
    }
    
    // Filter data by user permissions
    Specification<OrderRow> spec = Specification
      .where(byGridId(gridId))
      .and(byUserTenant(userDetails));
    
    Page<OrderRow> result = orderRepository.findAll(spec, 
      PageRequest.of(page, pageSize));
    
    return ResponseEntity.ok(new AjaxResponse<>(
      new PagedResponse<>(result)
    ));
  }
  
  @PreAuthorize("hasRole('ADMIN')")
  @DeleteMapping("/{gridId}/row/{rowId}")
  public ResponseEntity<AjaxResponse<?>> deleteRow(
    @PathVariable String gridId,
    @PathVariable Long rowId,
    @AuthenticationPrincipal UserDetails userDetails
  ) {
    // Only admins can delete
    orderRepository.deleteById(rowId);
    return ResponseEntity.ok(new AjaxResponse<>(true));
  }
  
  private boolean hasAccessToGrid(String gridId, UserDetails user) {
    // Check user permissions for this grid
    return user.getAuthorities().stream()
      .map(GrantedAuthority::getAuthority)
      .anyMatch(auth -> auth.equals("ROLE_" + gridId.toUpperCase()));
  }
  
  private Specification<OrderRow> byUserTenant(UserDetails user) {
    return (root, query, cb) -> {
      // Filter by user's tenant/organization
      return cb.equal(root.get("tenantId"), extractTenantId(user));
    };
  }
  
  private String extractTenantId(UserDetails user) {
    // Extract from user claims or session
    return (String) ((UserPrincipal) user).getClaims().get("tenant_id");
  }
}
```

### Angular Authorization Guards

```typescript
import { Injectable } from '@angular/core';
import { Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { AuthService } from './auth.service';

@Injectable({ providedIn: 'root' })
export class GridAccessGuard implements CanActivate {
  
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}
  
  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean {
    const gridId = route.params['gridId'];
    
    // Check user has role
    if (!this.authService.hasRole('USER')) {
      this.router.navigate(['/unauthorized']);
      return false;
    }
    
    // Check user has access to specific grid
    if (!this.authService.canAccessGrid(gridId)) {
      this.router.navigate(['/forbidden']);
      return false;
    }
    
    return true;
  }
}

// Route configuration
const routes = [
  {
    path: 'grid/:gridId',
    component: GridComponent,
    canActivate: [GridAccessGuard]
  }
];
```

---

## Audit Logging

### Log Security Events

```java
@Component
@Slf4j
public class GridAuditLogger {
  
  private final AuditEventRepository auditRepository;
  
  @PostMapping("/api/grid/{gridId}/data")
  public void logDataAccess(
    String gridId,
    @AuthenticationPrincipal UserDetails user,
    Map<String, String> filters
  ) {
    AuditEvent event = new AuditEvent();
    event.setEventType("GRID_DATA_ACCESS");
    event.setUserId(user.getUsername());
    event.setGridId(gridId);
    event.setFilters(filters);
    event.setTimestamp(LocalDateTime.now());
    event.setIpAddress(getClientIp());
    
    auditRepository.save(event);
    log.info("Grid access: user={} grid={} ip={}", 
      user.getUsername(), gridId, event.getIpAddress());
  }
  
  @DeleteMapping("/api/grid/{gridId}/row/{rowId}")
  public void logDataDeletion(
    String gridId,
    Long rowId,
    @AuthenticationPrincipal UserDetails user
  ) {
    AuditEvent event = new AuditEvent();
    event.setEventType("GRID_DATA_DELETION");
    event.setUserId(user.getUsername());
    event.setGridId(gridId);
    event.setRowId(rowId);
    event.setTimestamp(LocalDateTime.now());
    event.setIpAddress(getClientIp());
    
    auditRepository.save(event);
    log.warn("Grid deletion: user={} grid={} row={}", 
      user.getUsername(), gridId, rowId);
  }
  
  private String getClientIp() {
    RequestAttributes attrs = RequestContextHolder.getRequestAttributes();
    if (attrs instanceof ServletRequestAttributes) {
      HttpServletRequest request = ((ServletRequestAttributes) attrs).getRequest();
      String ip = request.getHeader("X-Forwarded-For");
      if (ip == null || ip.isEmpty()) {
        ip = request.getRemoteAddr();
      }
      return ip;
    }
    return "unknown";
  }
}

@Entity
@Table(name = "audit_events")
@Data
public class AuditEvent {
  @Id
  @GeneratedValue
  private Long id;
  
  @Column(nullable = false)
  private String eventType; // GRID_DATA_ACCESS, GRID_DATA_DELETION, etc.
  
  @Column(nullable = false)
  private String userId;
  
  @Column(nullable = false)
  private String gridId;
  
  private Long rowId;
  
  @Column(columnDefinition = "TEXT")
  private String filters;
  
  @Column(nullable = false)
  private LocalDateTime timestamp;
  
  @Column(nullable = false)
  private String ipAddress;
  
  @Index
  private String severity; // INFO, WARN, ERROR
}
```

---

## Best Practices

### ✅ DO

- Validate all input on server-side (never trust client)
- Use parameterized queries (JPA, PreparedStatement)
- Escape HTML output with `textContent`, not `innerHTML`
- Implement CSRF tokens for state-changing operations
- Use Spring Security annotations (@PreAuthorize, @PostAuthorize)
- Log all security-relevant events with audit trail
- Use HTTPS for all communication
- Implement rate limiting on API endpoints
- Use httpOnly cookies for session tokens
- Validate column definitions against whitelist
- Sanitize filter/sort parameters

### ❌ DO NOT

- Trust client-side validation alone
- Build SQL strings via concatenation
- Use `innerHTML` with user data
- Bypass Angular sanitization with `bypassSecurityTrustHtml`
- Store sensitive data in localStorage (use secure cookies)
- Log passwords or tokens
- Expose detailed error messages to clients
- Allow arbitrary filter expressions
- Accept HTML in grid data
- Skip CSRF protection on POST/PUT/DELETE

---

## Related Documents

- **[Validation](./validation.rules.md)** — Input validation patterns
- **[Code Quality](./code-quality.rules.md)** — Security scanning
