#!/usr/bin/env python3
"""Validate GuicedEE module baseline constraints."""

from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

LIFECYCLE_SPI_INTERFACES = [
    "com.guicedee.client.services.lifecycle.IGuicePreStartup",
    "com.guicedee.client.services.lifecycle.IGuiceModule",
    "com.guicedee.client.services.lifecycle.IGuicePostStartup",
]
MIN_JUNIT_JUPITER_VERSION = (6, 0, 3)
REQUIRED_JUNIT_TEST_DEPENDENCY = ("org.junit.jupiter", "junit-jupiter")
TEST_JUPITER_MODULES = {"org.junit.jupiter.api", "org.junit.jupiter"}
TEST_JUNIT_COMMONS_MODULE = "org.junit.platform.commons"

MAIN_OPEN_TARGET_PATTERNS: dict[str, tuple[str, ...]] = {
    "com.google.guice": (
        r"\bimport\s+com\.google\.inject\.",
        r"\bimport\s+(?:jakarta|javax)\.inject\.",
        r"@\s*Inject\b",
    ),
    "com.fasterxml.jackson.databind": (
        r"\bimport\s+com\.fasterxml\.jackson\.",
        r"@\s*Json[A-Za-z0-9_]*\b",
    ),
    "com.guicedee.vertx": (
        r"\bimport\s+io\.vertx\.",
        r"\bimport\s+com\.guicedee\.vertx\.",
    ),
}


def local_name(tag: str) -> str:
    return tag.split("}", 1)[1] if "}" in tag else tag


def find_first_text(root: ET.Element, names: list[str]) -> str | None:
    for element in root.iter():
        if local_name(element.tag) in names and element.text and element.text.strip():
            return element.text.strip()
    return None


def parse_version_tuple(raw: str) -> tuple[int, int, int] | None:
    if not raw:
        return None
    nums = re.findall(r"\d+", raw)
    if not nums:
        return None
    parts = [int(n) for n in nums[:3]]
    while len(parts) < 3:
        parts.append(0)
    return tuple(parts)  # type: ignore[return-value]


def version_str(version: tuple[int, int, int]) -> str:
    return f"{version[0]}.{version[1]}.{version[2]}"


def parse_module_name(module_info: Path) -> str | None:
    if not module_info.exists():
        return None
    content = module_info.read_text(encoding="utf-8", errors="ignore")
    match = re.search(r"^\s*(?:open\s+)?module\s+([A-Za-z0-9_.]+)\s*\{", content, re.MULTILINE)
    return match.group(1) if match else None


def collect_packages(source_root: Path) -> set[str]:
    packages: set[str] = set()
    if not source_root.exists():
        return packages
    for java_file in source_root.rglob("*.java"):
        if java_file.name == "module-info.java":
            continue
        content = java_file.read_text(encoding="utf-8", errors="ignore")
        match = re.search(r"^\s*package\s+([A-Za-z_][A-Za-z0-9_.]*)\s*;", content, re.MULTILINE)
        if match:
            packages.add(match.group(1))
    return packages


def parse_java_package(content: str) -> str | None:
    match = re.search(r"^\s*package\s+([A-Za-z_][A-Za-z0-9_.]*)\s*;", content, re.MULTILINE)
    return match.group(1) if match else None


def read_module_info_content(module_info: Path) -> str:
    if not module_info.exists():
        return ""
    return module_info.read_text(encoding="utf-8", errors="ignore")


def extract_required_modules(module_info_content: str) -> set[str]:
    required: set[str] = set()
    for match in re.finditer(
        r"\brequires\s+(?:(?:transitive|static)\s+)*([A-Za-z0-9_.]+)\s*;",
        module_info_content,
    ):
        required.add(match.group(1))
    return required


def extract_opens_map(module_info_content: str) -> dict[str, set[str]]:
    opens_map: dict[str, set[str]] = {}
    for match in re.finditer(
        r"\bopens\s+([A-Za-z_][A-Za-z0-9_.]*)\s*(?:to\s+([^;]+))?\s*;",
        module_info_content,
        re.DOTALL,
    ):
        package_name = match.group(1)
        targets = match.group(2)
        if not targets:
            opens_map.setdefault(package_name, set()).add("*")
            continue

        parsed_targets = {
            target.strip()
            for target in targets.replace("\n", " ").split(",")
            if target.strip()
        }
        if parsed_targets:
            opens_map.setdefault(package_name, set()).update(parsed_targets)
    return opens_map


def package_is_open_to(opens_map: dict[str, set[str]], package_name: str, module_name: str) -> bool:
    targets = opens_map.get(package_name, set())
    return "*" in targets or module_name in targets


def discover_main_open_requirements(source_root: Path) -> dict[str, set[str]]:
    requirements: dict[str, set[str]] = {}
    if not source_root.exists():
        return requirements

    for java_file in source_root.rglob("*.java"):
        if java_file.name == "module-info.java":
            continue
        content = java_file.read_text(encoding="utf-8", errors="ignore")
        package_name = parse_java_package(content)
        if not package_name:
            continue

        required_targets = requirements.setdefault(package_name, set())
        for target_module, patterns in MAIN_OPEN_TARGET_PATTERNS.items():
            if any(re.search(pattern, content, re.MULTILINE) for pattern in patterns):
                required_targets.add(target_module)

        if not required_targets:
            requirements.pop(package_name, None)

    return requirements


def discover_lifecycle_spi_implementations(source_root: Path) -> dict[str, dict[str, Path]]:
    found: dict[str, dict[str, Path]] = {spi: {} for spi in LIFECYCLE_SPI_INTERFACES}
    if not source_root.exists():
        return found

    class_pattern = re.compile(
        r"\bclass\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:extends\s+[^{]+?)?\s*implements\s*([^\\{]+)\{",
        re.DOTALL,
    )

    for java_file in source_root.rglob("*.java"):
        if java_file.name == "module-info.java":
            continue

        content = java_file.read_text(encoding="utf-8", errors="ignore")
        package_name = parse_java_package(content)

        for match in class_pattern.finditer(content):
            class_name = match.group(1)
            implemented = match.group(2)
            fqcn = f"{package_name}.{class_name}" if package_name else class_name

            for spi in LIFECYCLE_SPI_INTERFACES:
                simple = spi.rsplit(".", 1)[1]
                if re.search(
                    rf"\b(?:{re.escape(spi)}|{re.escape(simple)})\b",
                    implemented,
                    re.DOTALL,
                ):
                    found[spi][fqcn] = java_file

    return found


def has_sort_order_override(content: str) -> bool:
    return bool(
        re.search(
            r"\b(?:@Override\s+)?(?:public\s+)?int\s+sortOrder\s*\(",
            content,
            re.DOTALL,
        )
    )


def module_info_has_provides(module_info_content: str, spi: str, impl: str) -> bool:
    pattern = re.compile(
        rf"provides\s+{re.escape(spi)}\s+with\s+([^;]*\b{re.escape(impl)}\b[^;]*);",
        re.DOTALL,
    )
    return bool(pattern.search(module_info_content))


def read_service_implementations(service_file: Path) -> set[str]:
    if not service_file.exists():
        return set()
    values: set[str] = set()
    for line in service_file.read_text(encoding="utf-8", errors="ignore").splitlines():
        clean = line.strip()
        if not clean or clean.startswith("#"):
            continue
        values.add(clean)
    return values


def check_lifecycle_spi_registrations(project_root: Path, main_module_info: Path) -> tuple[bool, str]:
    source_root = project_root / "src" / "main" / "java"
    impls_by_spi = discover_lifecycle_spi_implementations(source_root)

    total_impls = sum(len(v) for v in impls_by_spi.values())
    if total_impls == 0:
        return True, "No lifecycle SPI implementations found in src/main/java."

    module_content = ""
    if main_module_info.exists():
        module_content = main_module_info.read_text(encoding="utf-8", errors="ignore")

    errors: list[str] = []
    for spi in LIFECYCLE_SPI_INTERFACES:
        impl_map = impls_by_spi[spi]
        if not impl_map:
            continue

        service_file = project_root / "src" / "main" / "resources" / "META-INF" / "services" / spi
        service_impls = read_service_implementations(service_file)

        for impl in sorted(impl_map):
            impl_file = impl_map[impl]
            impl_content = impl_file.read_text(encoding="utf-8", errors="ignore")

            if not module_content:
                errors.append(
                    f"{impl} implements {spi} but src/main/java/module-info.java is missing for 'provides' registration."
                )
            elif not module_info_has_provides(module_content, spi, impl):
                errors.append(
                    f"{impl} implements {spi} but module-info.java is missing 'provides {spi} with {impl};'."
                )

            if not service_file.exists():
                errors.append(
                    f"{impl} implements {spi} but META-INF/services file is missing: src/main/resources/META-INF/services/{spi}"
                )
            elif impl not in service_impls:
                errors.append(
                    f"{impl} implements {spi} but is not listed in META-INF/services/{spi}."
                )

            if not has_sort_order_override(impl_content):
                errors.append(
                    f"{impl} implements {spi} but does not override sortOrder() from IDefaultService."
                )

    if errors:
        return False, " | ".join(errors)

    return True, "Lifecycle SPI implementations are registered and override sortOrder()."


def check_bootstrap_main(project_root: Path, expected_module_name: str | None) -> tuple[bool, str]:
    source_root = project_root / "src" / "main" / "java"
    if not source_root.exists():
        return False, "Missing src/main/java (cannot validate bootstrap main class)."

    found_main_method = False
    failures: list[tuple[Path, list[str]]] = []

    for java_file in source_root.rglob("*.java"):
        if java_file.name == "module-info.java":
            continue
        content = java_file.read_text(encoding="utf-8", errors="ignore")

        if not re.search(r"\bstatic\s+void\s+main\s*\(", content):
            continue

        found_main_method = True
        issues: list[str] = []

        if not re.search(r"LogUtils\s*\.\s*addHighlightedConsoleLogger\s*\(", content):
            issues.append("missing LogUtils.addHighlightedConsoleLogger(...)")

        module_match = re.search(
            r'IGuiceContext\s*\.\s*registerModule\s*\(\s*"([^"]+)"\s*\)', content
        )
        if not module_match:
            issues.append('missing IGuiceContext.registerModule("<module>")')
        elif expected_module_name and module_match.group(1) != expected_module_name:
            issues.append(
                f'registered module "{module_match.group(1)}" does not match "{expected_module_name}"'
            )

        if not re.search(
            r"IGuiceContext\s*\.\s*instance\s*\(\s*\)\s*\.\s*inject\s*\(\s*\)\s*;", content
        ):
            issues.append("missing IGuiceContext.instance().inject()")

        if not issues:
            rel = java_file.relative_to(project_root)
            return True, f"Bootstrap main class verified in {rel}."

        failures.append((java_file, issues))

    if not found_main_method:
        return False, "Missing bootstrap main class with static void main(...) under src/main/java."

    summary: list[str] = [
        "Found main method(s), but none match required GuicedEE bootstrap pattern:"
    ]
    for java_file, issues in failures:
        rel = java_file.relative_to(project_root)
        summary.append(f"{rel} -> {', '.join(issues)}")
    return False, " | ".join(summary)


def check_module_open_rules(
    project_root: Path,
    main_module_info: Path,
    test_module_info: Path,
    test_packages: set[str],
) -> tuple[bool, str]:
    errors: list[str] = []
    checks: list[str] = []

    test_content = read_module_info_content(test_module_info)
    if not test_content:
        errors.append("Missing src/test/java/module-info.java for JUnit requires/opens validation.")
    else:
        required_modules = extract_required_modules(test_content)
        if required_modules.intersection(TEST_JUPITER_MODULES):
            checks.append("Test module requires JUnit Jupiter module(s).")
        else:
            errors.append(
                "Test module must require JUnit Jupiter (for example 'requires org.junit.jupiter.api;')."
            )

        test_opens = extract_opens_map(test_content)
        if test_packages:
            missing_test_opens = [
                pkg
                for pkg in sorted(test_packages)
                if not package_is_open_to(test_opens, pkg, TEST_JUNIT_COMMONS_MODULE)
            ]
            if missing_test_opens:
                errors.append(
                    "Every test package must open to org.junit.platform.commons: "
                    + ", ".join(missing_test_opens)
                )
            else:
                checks.append("All test packages open to org.junit.platform.commons.")

    main_content = read_module_info_content(main_module_info)
    if not main_content:
        errors.append("Missing src/main/java/module-info.java for package opens validation.")
    else:
        main_opens = extract_opens_map(main_content)
        required_main_opens = discover_main_open_requirements(
            project_root / "src" / "main" / "java"
        )

        if not required_main_opens:
            checks.append("No inferred Guice/Jackson/Vert.x package opens requirements found.")
        else:
            missing_main_opens: list[str] = []
            for package_name, target_modules in sorted(required_main_opens.items()):
                for target_module in sorted(target_modules):
                    if not package_is_open_to(main_opens, package_name, target_module):
                        missing_main_opens.append(f"{package_name} -> {target_module}")

            if missing_main_opens:
                errors.append(
                    "Missing main module opens directives for inferred package usage: "
                    + ", ".join(missing_main_opens)
                )
            else:
                checks.append(
                    "Main package opens cover inferred Guice/Jackson/Vert.x reflection usage."
                )

    if errors:
        return False, " | ".join(errors)
    return True, " | ".join(checks) if checks else "Module requires/opens rules verified."


def resolve_property(raw: str, properties: dict[str, str]) -> str:
    if not raw:
        return raw
    prop_match = re.fullmatch(r"\$\{([^}]+)\}", raw.strip())
    if prop_match:
        return properties.get(prop_match.group(1), raw)
    return raw


def collect_dependencies(root: ET.Element, properties: dict[str, str]) -> list[dict[str, str]]:
    dependencies: list[dict[str, str]] = []
    for dep in root.iter():
        if local_name(dep.tag) != "dependency":
            continue
        values: dict[str, str] = {}
        for child in list(dep):
            key = local_name(child.tag)
            values[key] = (child.text or "").strip()

        raw_version = values.get("version", "")
        resolved_version = resolve_property(raw_version, properties) if raw_version else ""

        dependencies.append(
            {
                "groupId": values.get("groupId", ""),
                "artifactId": values.get("artifactId", ""),
                "scope": values.get("scope", ""),
                "type": values.get("type", ""),
                "version": resolved_version,
            }
        )
    return dependencies


def check_testing_stack(root: ET.Element, properties: dict[str, str]) -> tuple[bool, str]:
    dependencies = collect_dependencies(root, properties)

    exact_junit_dep = any(
        dep["groupId"] == REQUIRED_JUNIT_TEST_DEPENDENCY[0]
        and dep["artifactId"] == REQUIRED_JUNIT_TEST_DEPENDENCY[1]
        and dep["scope"] == "test"
        for dep in dependencies
    )
    if not exact_junit_dep:
        return (
            False,
            "Missing required test dependency org.junit.jupiter:junit-jupiter with scope=test.",
        )

    junit_deps = [
        dep
        for dep in dependencies
        if dep["groupId"] == "org.junit.jupiter" and dep["artifactId"].startswith("junit-jupiter")
    ]
    if not junit_deps:
        return False, "Missing JUnit Jupiter dependency (org.junit.jupiter:junit-jupiter*)."

    junit_versions: list[tuple[int, int, int]] = []
    for dep in junit_deps:
        parsed = parse_version_tuple(dep["version"])
        if parsed:
            junit_versions.append(parsed)

    if "junit.jupiter.version" in properties:
        parsed = parse_version_tuple(resolve_property(properties["junit.jupiter.version"], properties))
        if parsed:
            junit_versions.append(parsed)

    if not junit_versions:
        return (
            False,
            "Could not verify JUnit Jupiter version >= 6.0.3. "
            "Declare junit.jupiter.version (or explicit junit-jupiter dependency version).",
        )

    highest_junit = max(junit_versions)
    if highest_junit < MIN_JUNIT_JUPITER_VERSION:
        return (
            False,
            f"JUnit Jupiter version is below minimum 6.0.3 (found: {version_str(highest_junit)}).",
        )

    mockito_present = any(
        dep["groupId"] == "org.mockito" or dep["artifactId"].startswith("mockito-")
        for dep in dependencies
    )
    if not mockito_present:
        return False, "Missing Mockito dependency (org.mockito:mockito-*)."

    playwright_present = any(
        dep["groupId"] == "com.microsoft.playwright" or dep["artifactId"] == "playwright"
        for dep in dependencies
    )
    if playwright_present:
        return (
            True,
            f"Testing stack verified (JUnit Jupiter {version_str(highest_junit)} + Mockito + Playwright).",
        )

    return (
        True,
        f"Testing stack verified (JUnit Jupiter {version_str(highest_junit)} + Mockito; Playwright optional).",
    )


def version_at_least(raw: str, minimum: int) -> bool:
    match = re.search(r"(\d+)", raw or "")
    if not match:
        return False
    return int(match.group(1)) >= minimum


def parse_pom_properties(root: ET.Element) -> dict[str, str]:
    properties: dict[str, str] = {}
    for element in root.iter():
        if local_name(element.tag) != "properties":
            continue
        for child in list(element):
            name = local_name(child.tag)
            if child.text and child.text.strip():
                properties[name] = child.text.strip()
    return properties


def has_guicedee_bom_import(root: ET.Element) -> bool:
    for element in root.iter():
        if local_name(element.tag) != "dependencyManagement":
            continue
        for dependency in element.iter():
            if local_name(dependency.tag) != "dependency":
                continue
            fields: dict[str, str] = {}
            for child in list(dependency):
                name = local_name(child.tag)
                value = (child.text or "").strip()
                fields[name] = value
            if (
                fields.get("groupId") == "com.guicedee"
                and fields.get("artifactId") == "guicedee-bom"
                and fields.get("type") == "pom"
                and fields.get("scope") == "import"
            ):
                return True
    return False


def find_compiler_release(root: ET.Element, properties: dict[str, str]) -> str | None:
    for candidate in ("maven.compiler.release", "java.version"):
        if candidate in properties:
            return properties[candidate]

    for plugin in root.iter():
        if local_name(plugin.tag) != "plugin":
            continue
        artifact_id = None
        configuration = None
        for child in list(plugin):
            tag = local_name(child.tag)
            if tag == "artifactId":
                artifact_id = (child.text or "").strip()
            if tag == "configuration":
                configuration = child
        if artifact_id != "maven-compiler-plugin" or configuration is None:
            continue
        release = find_first_text(configuration, ["release", "source", "target"])
        if release:
            return resolve_property(release, properties)
    return None


def check_wrapper_maven4(project_root: Path) -> tuple[bool, str]:
    wrapper = project_root / ".mvn" / "wrapper" / "maven-wrapper.properties"
    if not wrapper.exists():
        return False, "Missing .mvn/wrapper/maven-wrapper.properties (cannot verify Maven 4)."
    content = wrapper.read_text(encoding="utf-8", errors="ignore")
    if "apache-maven-4" not in content:
        return False, "Wrapper distribution URL is not pinned to Maven 4."
    return True, "Maven wrapper is pinned to Maven 4."


def validate(project_root: Path, expected_module_name: str | None) -> list[str]:
    errors: list[str] = []
    checks: list[str] = []

    pom_path = project_root / "pom.xml"
    if not pom_path.exists():
        return ["Missing pom.xml."]

    try:
        pom_root = ET.parse(pom_path).getroot()
    except ET.ParseError as exc:
        return [f"Invalid pom.xml: {exc}"]

    ok, message = check_wrapper_maven4(project_root)
    (checks if ok else errors).append(message)

    properties = parse_pom_properties(pom_root)
    release_raw = find_compiler_release(pom_root, properties)
    if not release_raw:
        errors.append("Could not find Java release/source/target configuration in pom.xml.")
    elif not version_at_least(release_raw, 25):
        errors.append(f"Java baseline is below 25 (found: {release_raw}).")
    else:
        checks.append(f"Java baseline is {release_raw} (>= 25).")

    if has_guicedee_bom_import(pom_root):
        checks.append("Found GuicedEE BOM import (com.guicedee:guicedee-bom, type=pom, scope=import).")
    else:
        errors.append("Missing GuicedEE BOM import in dependencyManagement.")

    ok, message = check_testing_stack(pom_root, properties)
    (checks if ok else errors).append(message)

    main_module_info = project_root / "src" / "main" / "java" / "module-info.java"
    test_module_info = project_root / "src" / "test" / "java" / "module-info.java"

    if not main_module_info.exists():
        errors.append("Missing src/main/java/module-info.java.")
    if not test_module_info.exists():
        errors.append("Missing src/test/java/module-info.java.")

    main_module_name = parse_module_name(main_module_info) if main_module_info.exists() else None
    test_module_name = parse_module_name(test_module_info) if test_module_info.exists() else None

    if main_module_name:
        checks.append(f"Main module name: {main_module_name}")
    elif main_module_info.exists():
        errors.append("Could not parse main module name from src/main/java/module-info.java.")

    if expected_module_name and main_module_name and main_module_name != expected_module_name:
        errors.append(
            f"Main module name mismatch: expected '{expected_module_name}', found '{main_module_name}'."
        )

    if test_module_name:
        checks.append(f"Test module name: {test_module_name}")
    elif test_module_info.exists():
        errors.append("Could not parse test module name from src/test/java/module-info.java.")

    if main_module_name and test_module_name:
        expected_test_name = f"{main_module_name}.test"
        if test_module_name != expected_test_name:
            errors.append(
                f"Test module name must default to '{expected_test_name}', found '{test_module_name}'."
            )

    ok, message = check_lifecycle_spi_registrations(project_root, main_module_info)
    (checks if ok else errors).append(message)

    bootstrap_expected = main_module_name or expected_module_name
    ok, message = check_bootstrap_main(project_root, bootstrap_expected)
    (checks if ok else errors).append(message)

    main_packages = collect_packages(project_root / "src" / "main" / "java")
    test_packages = collect_packages(project_root / "src" / "test" / "java")

    duplicated = sorted(main_packages.intersection(test_packages))
    if duplicated:
        errors.append(f"Duplicate packages across main/test modules: {', '.join(duplicated)}")
    else:
        checks.append("No duplicated package names between main and test source sets.")

    invalid_test_packages = sorted(pkg for pkg in test_packages if not pkg.endswith(".test"))
    if invalid_test_packages:
        errors.append(
            "Test packages must end with '.test': " + ", ".join(invalid_test_packages)
        )
    else:
        checks.append("All test packages use the '.test' suffix.")

    ok, message = check_module_open_rules(
        project_root,
        main_module_info,
        test_module_info,
        test_packages,
    )
    (checks if ok else errors).append(message)

    print("Validation summary:")
    for item in checks:
        print(f"[OK] {item}")
    for item in errors:
        print(f"[FAIL] {item}")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate GuicedEE creator baseline.")
    parser.add_argument(
        "--project-root",
        default=".",
        help="Path to the Maven project root (default: current directory).",
    )
    parser.add_argument(
        "--module-name",
        default=None,
        help="Optional expected main module name for validation.",
    )
    args = parser.parse_args()

    project_root = Path(args.project_root).resolve()
    errors = validate(project_root, args.module_name)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
