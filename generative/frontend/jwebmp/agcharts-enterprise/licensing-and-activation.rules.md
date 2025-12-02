# Licensing & Activation — AgCharts Enterprise

Overview
- AG Charts Enterprise requires a valid license. The `AgGridEnterprisePageConfigurator` handles license initialization by injecting the key into the Angular-compiled application.
- License keys are managed via: (1) programmatic static setter, (2) system property `ag.grid.license`, or (3) environment variable `AG_GRID_LICENSE`.
- Keys are never committed to source control; they are injected at runtime only.

Usage patterns
- Obtain a license from AG Grid/AG Charts per their terms.
- Provide the license key to the JWebMP application via one of three methods (see Configuration section below).
- The `configureAngular()` method in `AgGridEnterprisePageConfigurator` automatically injects the key into a `<script>` tag as `window.AG_GRID_LICENSE_KEY` for the client to use.

Configuration
- Ensure `ag-charts-enterprise` is present in the generated Angular app so that license APIs are available.
- Set the license key using one of these three methods (checked in order):

Constraints
- Respect vendor licensing. This repository must not contain license keys or circumvention instructions.

See also
- Integration overview — ./agcharts-enterprise-integration.rules.md
- Page Configurator — ./page-configurator.rules.md
- Troubleshooting — ./troubleshooting.rules.md

Java activation approaches (JWebMP)
- Goal: Initialize AG Charts Enterprise with a license key without committing secrets to source control.
- The license is automatically handled by `AgGridEnterprisePageConfigurator.configureAngular()` which:
  1. Checks the static field `AG_GRID_LICENSE_KEY` (if programmatically set via setter)
  2. Falls back to system property `ag.grid.license` (JVM startup arg: `-Dag.grid.license=YOUR_KEY`)
  3. Falls back to environment variable `AG_GRID_LICENSE`
  4. If found, injects it into a `<script>` tag as `window.AG_GRID_LICENSE_KEY` for the client

### Method 1: Programmatic Static Setter (Recommended for Custom Configuration)
```java
// In your application initialization code
import com.jwebmp.plugins.aggridenterprise.AgGridEnterprisePageConfigurator;

// Set the license key programmatically at application startup
String licenseKey = loadLicenseFromSecureSource(); // your secret provider
AgGridEnterprisePageConfigurator.setAG_GRID_LICENSE_KEY(licenseKey);
```

### Method 2: System Property (Recommended for Container/Cloud Deployment)
```bash
# Set via JVM startup arguments
java -Dag.grid.license="YOUR_LICENSE_KEY" -jar application.jar
```

Or programmatically:
```java
// Before JWebMP page initialization
System.setProperty("ag.grid.license", licenseKey);
```

### Method 3: Environment Variable (Recommended for CI/CD)
```bash
# Set in your shell or deployment configuration
export AG_GRID_LICENSE="YOUR_LICENSE_KEY"
java -jar application.jar
```

Important
- Never store license keys in source control, example data, or logs.
- Prefer Method 1 (static setter with secret provider) or Method 2/3 (environment/system properties) for production.
- The `configureAngular()` method is called during page initialization and safely handles null/empty keys (no injection occurs if key is not found).
- Validate in the generated Angular app that `ag-charts-enterprise` is present; the license injection alone is insufficient without the dependency.
