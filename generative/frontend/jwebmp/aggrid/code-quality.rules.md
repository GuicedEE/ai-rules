# Code Quality Rules

**Maintain high code standards and prevent defects**

---

## Overview

Code quality enforcement ensures maintainability, reliability, and security. Jacoco measures coverage; SonarQube identifies issues.

---

## Code Coverage with Jacoco

### Maven Configuration

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.10</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
        <execution>
            <id>jacoco-check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>PACKAGE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>  <!-- 80% minimum -->
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### Checking Coverage

```bash
mvn clean test jacoco:report
# Report generated at: target/site/jacoco/index.html
```

---

## SonarQube Integration

### Maven Plugin Configuration

```xml
<plugin>
    <groupId>org.sonarsource.scanner.maven</groupId>
    <artifactId>sonar-maven-plugin</artifactId>
    <version>3.9.1.2184</version>
</plugin>
```

### Running SonarQube Analysis

```bash
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=com.jwebmp.plugins:aggrid \
  -Dsonar.host.url=https://sonarqube.company.com \
  -Dsonar.login=<token>
```

### Quality Gates

- **Coverage**: ≥80% (fail if below)
- **Code Smells**: 0 critical issues
- **Bugs**: 0 blocking issues
- **Security**: No vulnerabilities
- **Duplication**: <3% duplicated lines

---

## Code Style & Formatting

### IntelliJ IDEA Code Style

```java
// Naming conventions
class AgGrid { }              // PascalCase
public AgGrid setHeight() {}  // camelCase
private int TIMEOUT = 5000;   // UPPER_SNAKE_CASE

// Formatting
void method() {
    if (condition) {
        // 4-space indentation
        doSomething();
    }
}

// Line length: 120 characters (soft), 140 (hard)
```

### Automated Formatting

```bash
# Format code using Maven
mvn spotless:apply
```

### Checkstyle Plugin

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <configuration>
        <configLocation>google_checks.xml</configLocation>
        <failOnViolation>true</failOnViolation>
    </configuration>
</plugin>
```

---

## Nullness Checking with JSpecify

### Annotations

```java
// Import JSpecify
import org.jspecify.annotations.Nullable;
import org.jspecify.annotations.NonNull;

public class GridService {
    
    // Non-null parameter, non-null return
    public @NonNull String getGridId(@NonNull AgGrid grid) {
        return grid.getId();
    }
    
    // Nullable parameter, nullable return
    public @Nullable String getOptionalValue(@Nullable String key) {
        return properties.get(key);
    }
    
    // Collection nullness
    public @NonNull List<@NonNull String> getColumns() {
        return List.of("id", "name", "email");
    }
}
```

### IDE Inspection

IntelliJ IDEA inspects nullness annotations and warns on potential NPE:

```java
String id = getGridId(null);  // WARNING: null is not @NonNull
```

---

## Anti-Patterns & Code Smells

### Avoiding Common Issues

```java
// ❌ DON'T: Mutable static state
public static List<AgGrid> grids = new ArrayList<>();

// ✅ DO: Use IoC container for singletons
@Inject
private GridRegistry gridRegistry;

// ❌ DON'T: Duplicate code
if (status.equals("ACTIVE")) { color = "green"; }
if (status.equals("ACTIVE")) { icon = "check"; }

// ✅ DO: Extract method
private void applyActiveStyles() { color = "green"; icon = "check"; }

// ❌ DON'T: Long parameter lists
void configureGrid(String height, String width, String theme, boolean pagination, ...) { }

// ✅ DO: Use objects for configuration
void configureGrid(GridConfig config) { }

// ❌ DON'T: Swallow exceptions
try {
    data = repository.find All();
} catch (Exception e) {
    // Silently ignored!
}

// ✅ DO: Log and handle appropriately
try {
    data = repository.findAll();
} catch (RepositoryException e) {
    log.error("Failed to fetch data", e);
    throw new GridDataException("Unable to load grid", e);
}
```

---

## Complexity Metrics

### Cyclomatic Complexity

Target: ≤10 for methods

```java
// High complexity (avoid)
public void processGrid(GridData data) {
    if (data.isEmpty()) {
        // ...
    } else if (data.size() > 1000) {
        // ...
    } else if (data.hasFilter()) {
        // ...
    } else if (data.hasSorting()) {
        // ...
    }
    // Many more if-else branches...
}

// Better: Delegate to helper methods
public void processGrid(GridData data) {
    if (data.isEmpty()) {
        handleEmpty();
    } else {
        handleNonEmpty(data);
    }
}
```

---

## Documentation Standards

### JavaDoc for Public APIs

```java
/**
 * Configures the grid with a CRTP fluent API.
 * 
 * <p>Example usage:
 * <pre>
 * new MyGrid()
 *     .setHeight("600px")
 *     .setTheme("ag-theme-alpine")
 *     .enableRowSelection("multiple");
 * </pre>
 * 
 * @param <J> the subclass type for CRTP
 * @see AgGridOptions
 * @since 2.0.0
 */
public abstract class AgGrid<J extends AgGrid<J>> extends DivSimple<J> {
    
    /**
     * Sets the grid height in CSS units.
     * 
     * @param height the height (e.g., "600px", "80vh")
     * @return this grid instance for chaining
     * @throws IllegalArgumentException if height is null or empty
     */
    @SuppressWarnings("unchecked")
    public J setHeight(String height) {
        // ...
    }
}
```

---

## Security Scanning

### OWASP Dependency Check

```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>  <!-- Fail on high/critical vulns -->
    </configuration>
</plugin>
```

### Running Scan

```bash
mvn org.owasp:dependency-check-maven:check
```

---

## Performance Analysis

### Profiling Grid Operations

```java
@Test
public void testGridPerformance() {
    long start = System.nanoTime();
    
    grid.init();
    grid.setRowData(generateLargeDataset(10000));
    grid.render();
    
    long elapsed = System.nanoTime() - start;
    long elapsedMs = TimeUnit.NANOSECONDS.toMillis(elapsed);
    
    assertTrue(elapsedMs < 5000, "Grid render took: " + elapsedMs + "ms");
}
```

---

## Continuous Quality Integration

### GitHub Actions CI Workflow

```yaml
name: Quality Gate
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 25
        uses: actions/setup-java@v3
        with:
          java-version: '25'
      - name: Run tests and coverage
        run: mvn clean test jacoco:report
      - name: Check coverage
        run: mvn jacoco:check
      - name: SonarQube analysis
        run: mvn sonar:sonar -Dsonar.projectKey=com.jwebmp.plugins:aggrid
```

---

## Best Practices

### ✅ DO

- Maintain ≥80% code coverage (Jacoco)
- Fix all SonarQube critical issues
- Use nullness annotations on public APIs
- Write meaningful JavaDoc for public classes/methods
- Keep cyclomatic complexity ≤10
- Scan for security vulnerabilities regularly

### ❌ DO NOT

- Skip coverage checks in CI
- Ignore SonarQube warnings
- Leave TODOs without tickets
- Commit commented-out code
- Skip performance profiling
- Ignore security scan reports

---

## Related Documents

- **[Testing Strategy](./testing-strategy.rules.md)** — Coverage measurement
- **[CI/CD Integration](./cicd-integration.rules.md)** — Automated quality gates
