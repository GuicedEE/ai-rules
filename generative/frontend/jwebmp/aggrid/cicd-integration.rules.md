# CI/CD Integration Rules

**Automate build, test, and deployment workflows**

---

## Overview

CI/CD pipelines ensure code quality, run tests, and publish artifacts automatically on every commit.

---

## GitHub Actions Workflow

### Maven Build & Test Workflow

Create `.github/workflows/maven-build.yml`:

```yaml
name: Maven Build & Test

on:
  push:
    branches: [ master, develop ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        java-version: [ '25' ]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK ${{ matrix.java-version }}
      uses: actions/setup-java@v3
      with:
        java-version: ${{ matrix.java-version }}
        distribution: 'temurin'
        cache: maven
    
    - name: Build with Maven
      run: mvn -B clean compile
    
    - name: Run tests with coverage
      run: mvn -B clean verify jacoco:report
    
    - name: Check Jacoco coverage
      run: mvn jacoco:check
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: ./target/site/jacoco/jacoco.xml
        flags: unittests
        name: codecov-umbrella
    
    - name: SonarQube analysis
      run: mvn -B sonar:sonar -Dsonar.projectKey=com.jwebmp.plugins:aggrid
      env:
        SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
        SONAR_LOGIN: ${{ secrets.SONAR_LOGIN }}
```

### Artifact Publishing Workflow

Create `.github/workflows/publish.yml`:

```yaml
name: Publish Artifacts

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 25
      uses: actions/setup-java@v3
      with:
        java-version: '25'
        distribution: 'temurin'
        cache: maven
        server-id: ossrh
        server-username: MAVEN_USERNAME
        server-password: MAVEN_PASSWORD
    
    - name: Publish to Maven Central
      run: mvn -B clean deploy
      env:
        MAVEN_USERNAME: ${{ secrets.OSSRH_USERNAME }}
        MAVEN_PASSWORD: ${{ secrets.OSSRH_PASSWORD }}
        GPG_PASSPHRASE: ${{ secrets.GPG_PASSPHRASE }}
```

---

## Build Configuration

### Maven POM Build Section

```xml
<build>
    <plugins>
        <!-- Compiler -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.11.0</version>
            <configuration>
                <source>25</source>
                <target>25</target>
                <release>25</release>
            </configuration>
        </plugin>
        
        <!-- Testing -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>3.1.2</version>
            <configuration>
                <includes>
                    <include>**/*Test.java</include>
                    <include>**/*Tests.java</include>
                </includes>
            </configuration>
        </plugin>
        
        <!-- Code Coverage -->
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
                    <phase>verify</phase>
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
                                        <minimum>0.80</minimum>
                                    </limit>
                                </limits>
                            </rule>
                        </rules>
                    </configuration>
                </execution>
            </executions>
        </plugin>
        
        <!-- Flatten POM -->
        <plugin>
            <groupId>org.codehaus.mojo</groupId>
            <artifactId>flatten-maven-plugin</artifactId>
            <version>1.5.0</version>
            <executions>
                <execution>
                    <id>flatten</id>
                    <phase>process-resources</phase>
                    <goals>
                        <goal>flatten</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

---

## GitHub Secrets Configuration

### Required Secrets

```
OSSRH_USERNAME          # Maven Central username
OSSRH_PASSWORD          # Maven Central password
GPG_PASSPHRASE          # GPG signing passphrase
SONAR_HOST_URL          # SonarQube server URL
SONAR_LOGIN             # SonarQube authentication token
```

### Setting Secrets

```bash
# Via GitHub CLI
gh secret set OSSRH_USERNAME --body "<username>"
gh secret set OSSRH_PASSWORD --body "<password>"

# Or via GitHub web interface:
# Repository Settings → Secrets and variables → Actions
```

---

## Pre-Commit Hooks

### Git Pre-Commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

# Run tests before commit
echo "Running tests..."
mvn test

if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Commit aborted."
    exit 1
fi

echo "✅ Tests passed. Proceeding with commit."
exit 0
```

---

## Deployment Strategies

### Rolling Deployment

```yaml
name: Deploy to Production
on:
  push:
    branches: [ master ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: mvn clean package
      - name: Deploy (Rolling)
        run: |
          # Stop old instances
          # Deploy new version
          # Health check
          # Verify deployment
```

---

## Release Management

### Release Version Management

```bash
# Using Maven Release Plugin
mvn release:prepare
mvn release:perform

# Manual version bump
mvn versions:set -DnewVersion=2.1.0
```

### Release Checklist

- [ ] All tests passing (Jacoco ≥80%)
- [ ] SonarQube quality gates passed
- [ ] Security scans clean
- [ ] CHANGELOG updated
- [ ] Version bumped
- [ ] Release notes prepared
- [ ] Artifacts published to Maven Central
- [ ] Documentation updated

---

## Monitoring & Alerts

### Build Status Badge

Add to README.md:

```markdown
[![Build Status](https://github.com/JWebMP/AgGrid/workflows/Maven%20Build%20&%20Test/badge.svg)](https://github.com/JWebMP/AgGrid/actions)
[![Coverage Status](https://codecov.io/gh/JWebMP/AgGrid/branch/master/graph/badge.svg)](https://codecov.io/gh/JWebMP/AgGrid)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=com.jwebmp.plugins:aggrid&metric=alert_status)](https://sonarcloud.io/dashboard?id=com.jwebmp.plugins:aggrid)
```

### Failed Build Notifications

Configure GitHub to notify on:
- Build failures
- Coverage drops below 80%
- New security vulnerabilities
- SonarQube quality gate failures

---

## Performance Benchmarking

### Load Testing

```yaml
- name: Performance Benchmarks
  run: |
    mvn clean verify -Pbenchmark
    # Generates performance reports
```

---

## Best Practices

### ✅ DO

- Run CI on every push to main branches
- Run full test suite including coverage check
- Require passing CI before merge
- Track coverage trends over time
- Automate security scanning
- Publish artifacts only on releases
- Keep CI logs for audit trail

### ❌ DO NOT

- Skip tests in CI
- Bypass quality gates
- Publish snapshots to Maven Central
- Leave manual deployment steps
- Ignore CI failures
- Run CI only on demand

---

## Related Documents

- **[Code Quality](./code-quality.rules.md)** — Quality metrics
- **[Testing Strategy](./testing-strategy.rules.md)** — Test execution
