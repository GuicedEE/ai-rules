#!/usr/bin/env python3
"""
Generate JWebMP plugin skills from pom.xml files.

This script automatically creates SKILL.md files for all JWebMP plugins
by extracting metadata from their pom.xml files.

Usage:
    python3 generate-jwebmp-skills.py
"""

import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Optional, Dict

# Add the skill-creator scripts to path so we can import its modules
sys.path.insert(0, str(Path(__file__).parent.parent / "skills" / ".system" / "skill-creator" / "scripts"))

JWEBMP_PLUGINS_DIR = Path(__file__).parent.parent.parent / "JWebMP" / "plugins"
SKILLS_OUTPUT_DIR = Path(__file__).parent.parent / "skills" / ".system"

# Plugin descriptions and use cases (curated)
PLUGIN_METADATA = {
    "agcharts": {
        "name": "jwebmp-agcharts",
        "title": "AG Charts Community",
        "description": "Build JWebMP AG Charts community visualizations with Java chart options, generated TypeScript, data binding, and themes.",
        "use_for": "AG Charts integration, chart types, responsive charting",
    },
    "agcharts-enterprise": {
        "name": "jwebmp-agcharts-enterprise",
        "title": "AG Charts Enterprise",
        "description": "Add licensed AG Charts Enterprise visualizations to JWebMP, including financial charts, heatmaps, treemaps, and sankey diagrams.",
        "use_for": "Enterprise charting, advanced visualizations",
    },
    "aggrid": {
        "name": "jwebmp-aggrid",
        "title": "AG Grid Community",
        "description": "Build JWebMP AG Grid community tables with Java column models, filtering, sorting, pagination, selection, and data binding.",
        "use_for": "AG Grid data tables, column definitions, row models, grid options",
    },
    "aggrid-enterprise": {
        "name": "jwebmp-aggrid-enterprise",
        "title": "AG Grid Enterprise",
        "description": "Add licensed AG Grid Enterprise features to JWebMP: grouping, pivoting, master/detail, server-side rows, and Excel export.",
        "use_for": "Enterprise data grids, advanced grid features",
    },
    "angular": {
        "name": "jwebmp-angular",
        "title": "Angular Integration",
        "description": "Generate Angular apps from JWebMP Java annotations; configure components, routes, services, control flow, and STOMP messaging.",
        "use_for": "Angular component integration, TypeScript client generation, reactive forms",
    },
    "angular-forms": {
        "name": "jwebmp-angular-forms",
        "title": "Angular Forms",
        "description": "Build JWebMP Angular reactive or template-driven forms with bindings, validation, and submission handling.",
        "use_for": "Angular form building, reactive forms, form validation",
    },
    "angular-material": {
        "name": "jwebmp-angular-material",
        "title": "Angular Material",
        "description": "Build JWebMP Angular Material interfaces with themed, accessible Material Design components.",
        "use_for": "Material Design components, Angular Material theming, accessible UI",
    },
    "bootstrap": {
        "name": "jwebmp-bootstrap",
        "title": "Bootstrap CSS Framework",
        "description": "Build responsive JWebMP layouts and components using the Bootstrap integration.",
        "use_for": "Bootstrap grid system, responsive layout, Bootstrap components",
    },
    "c3": {
        "name": "jwebmp-c3",
        "title": "C3 Charts",
        "description": "Build C3 charts and time-series dashboards through JWebMP's D3-based C3 integration.",
        "use_for": "C3 charts, D3-based visualizations, data-driven graphics",
    },
    "chartjs": {
        "name": "jwebmp-chartjs",
        "title": "Chart.js Charting",
        "description": "Build responsive Chart.js charts in JWebMP with Java options, data series, animations, and plugins.",
        "use_for": "Chart.js charting, simple charts, dashboard visualizations",
    },
    "d3": {
        "name": "jwebmp-d3",
        "title": "D3.js Data Visualization",
        "description": "Build custom D3 visualizations in JWebMP using selections, scales, axes, and transitions.",
        "use_for": "D3 visualizations, custom graphics, data-driven DOM manipulation",
    },
    "datatables": {
        "name": "jwebmp-datatables",
        "title": "DataTables",
        "description": "Build searchable, sortable, paginated JWebMP tables through the DataTables.net integration.",
        "use_for": "Advanced HTML tables, server-side pagination, table extensions",
    },
    "easy-pie-chart": {
        "name": "jwebmp-easy-pie-chart",
        "title": "Easy Pie Chart",
        "description": "Embed animated Easy Pie Chart pie and doughnut widgets in JWebMP.",
        "use_for": "Animated pie charts, doughnut charts, canvas-based visualizations",
    },
    "easing": {
        "name": "jwebmp-easing",
        "title": "jQuery Easing",
        "description": "Configure jQuery easing functions for JWebMP animations, transitions, and scrolling effects.",
        "use_for": "jQuery easing animations, animation curves, smooth transitions",
    },
    "fontawesome": {
        "name": "jwebmp-fontawesome",
        "title": "Font Awesome Free Icons",
        "description": "Add and style free FontAwesome icons in JWebMP, including sizing, rotation, animation, and stacking.",
        "use_for": "Font Awesome community icons, icon fonts, UI icons",
    },
    "fontawesome-pro": {
        "name": "jwebmp-fontawesome-pro",
        "title": "Font Awesome Pro Icons",
        "description": "Use licensed FontAwesome Pro icons, premium families, styles, and icon kits in JWebMP.",
        "use_for": "Font Awesome pro icons, extended icon library",
    },
    "fullcalendar": {
        "name": "jwebmp-fullcalendar",
        "title": "FullCalendar Community",
        "description": "Build JWebMP FullCalendar event calendars, scheduling views, event interactions, timezones, and localization.",
        "use_for": "Calendar integration, event scheduling, calendar views",
    },
    "fullcalendar-pro": {
        "name": "jwebmp-fullcalendar-pro",
        "title": "FullCalendar Pro",
        "description": "Add licensed FullCalendar Premium resource scheduling and timeline views to JWebMP calendars.",
        "use_for": "Advanced calendar scheduling, resource management",
    },
    "globalize": {
        "name": "jwebmp-globalize",
        "title": "Globalize i18n",
        "description": "Localize JWebMP content and format numbers, currencies, and dates with Globalize.",
        "use_for": "Internationalization, multi-language support, locale formatting",
    },
    "glyph-icons": {
        "name": "jwebmp-glyph-icons",
        "title": "Glyph Icons",
        "description": "Add Glyph Icons to Bootstrap-based JWebMP interfaces.",
        "use_for": "Icon fonts, Bootstrap icon integration",
    },
    "jqplot": {
        "name": "jwebmp-jqplot",
        "title": "jqPlot Charting",
        "description": "Build jqPlot line, bar, pie, and dashboard charts in JWebMP.",
        "use_for": "jqPlot charts, jQuery-based charting",
    },
    "jquery": {
        "name": "jwebmp-jquery",
        "title": "jQuery Library",
        "description": "Use JWebMP's jQuery integration for DOM manipulation, events, effects, AJAX, and plugin dependencies.",
        "use_for": "jQuery utilities, DOM manipulation, jQuery AJAX",
    },
    "jquery-ui": {
        "name": "jwebmp-jquery-ui",
        "title": "jQuery UI",
        "description": "Add jQuery UI widgets and drag/drop, resize, sort, or datepicker interactions to JWebMP.",
        "use_for": "jQuery UI widgets, drag and drop, resizable elements",
    },
    "local-storage": {
        "name": "jwebmp-local-storage",
        "title": "Local Storage",
        "description": "Persist JWebMP browser data or preferences across sessions using Local Storage.",
        "use_for": "Client-side storage, browser persistence, user preferences",
    },
    "markdown": {
        "name": "jwebmp-markdown",
        "title": "Markdown Support",
        "description": "Render Markdown content as JWebMP HTML components.",
        "use_for": "Markdown rendering, content conversion, CMS integration",
    },
    "material-design-icons": {
        "name": "jwebmp-material-design-icons",
        "title": "Material Design Icons",
        "description": "Add Google Material Design Icons to JWebMP interfaces.",
        "use_for": "Material Design icon fonts, icon integration",
    },
    "material-icons": {
        "name": "jwebmp-material-icons",
        "title": "Material Icons",
        "description": "Use the older Google Material Icons integration in JWebMP.",
        "use_for": "Material icon fonts",
    },
    "plus-as-tab": {
        "name": "jwebmp-plus-as-tab",
        "title": "Plus As Tab",
        "description": "Configure JWebMP's Plus As Tab integration for keyboard navigation with the plus key.",
        "use_for": "Tab navigation, plus-triggered actions",
    },
    "prettify": {
        "name": "jwebmp-prettify",
        "title": "Google Prettify",
        "description": "Highlight code snippets in JWebMP with Google Prettify.",
        "use_for": "Code syntax highlighting, code display",
    },
    "prism": {
        "name": "jwebmp-prism",
        "title": "Prism Syntax Highlighting",
        "description": "Highlight JWebMP code blocks with Prism themes, line numbers, and copy controls.",
        "use_for": "Code syntax highlighting, Prism plugins, code blocks",
    },
    "session-storage": {
        "name": "jwebmp-session-storage",
        "title": "Session Storage",
        "description": "Store temporary JWebMP browser data for the current tab/session using Session Storage.",
        "use_for": "Session data storage, temporary browser persistence",
    },
    "skycons": {
        "name": "jwebmp-skycons",
        "title": "Skycons Weather Icons",
        "description": "Render animated weather icons in JWebMP with Skycons.",
        "use_for": "Weather icons, animated SVG icons",
    },
    "themify-icons": {
        "name": "jwebmp-themify-icons",
        "title": "Themify Icons",
        "description": "Add Themify icon fonts to JWebMP interfaces.",
        "use_for": "Themify icon fonts, icon integration",
    },
    "toastr": {
        "name": "jwebmp-toastr",
        "title": "Toastr Notifications",
        "description": "Show non-blocking toast notifications in JWebMP using the jQuery Toastr integration.",
        "use_for": "Toast notifications, user alerts, notification UI",
    },
    "tsclient": {
        "name": "jwebmp-tsclient",
        "title": "TypeScript Client Generation",
        "description": "Define JWebMP TypeScript generation, npm dependencies, Angular annotations, and typed NgRestClient services from Java.",
        "use_for": "TypeScript generation, client-side type safety",
    },
    "waves-effect": {
        "name": "jwebmp-waves-effect",
        "title": "Waves Effect",
        "description": "Add Waves Material Design ripple effects to JWebMP interactions.",
        "use_for": "Ripple effects, Material Design interactions",
    },
    "waypoints": {
        "name": "jwebmp-waypoints",
        "title": "Waypoints Scroll Plugin",
        "description": "Trigger JWebMP scroll interactions when elements reach viewport waypoints.",
        "use_for": "Scroll detection, lazy loading, scroll animations",
    },
    "weather-icons": {
        "name": "jwebmp-weather-icons",
        "title": "Weather Icons",
        "description": "Display weather icon fonts in JWebMP interfaces.",
        "use_for": "Weather icon fonts",
    },
    "webawesome": {
        "name": "jwebmp-webawesome",
        "title": "Web Awesome Community",
        "description": "Build and style JWebMP WebAwesome components, WaPage layouts, forms, overlays, and theme tokens.",
        "use_for": "Web components, accessible UI components",
    },
    "webawesome-pro": {
        "name": "jwebmp-webawesome-pro",
        "title": "Web Awesome Pro",
        "description": "Use JWebMP WebAwesome Pro comboboxes, date pickers, uploads, charts, video, premium icons, and toast notifications.",
        "use_for": "Premium web components, extended component library",
    },
}

def read_pom_description(pom_path: Path) -> Optional[str]:
    """Extract description from pom.xml"""
    try:
        tree = ET.parse(pom_path)
        root = tree.getroot()
        ns = {'': 'http://maven.apache.org/POM/4.0.0'}

        # Try to get description
        desc = root.find('.//description', ns)
        if desc is None:
            desc = root.find('description')

        return desc.text if desc is not None else None
    except Exception:
        return None

def generate_skill_md(plugin_name: str, metadata: Dict) -> str:
    """Generate SKILL.md content for a plugin"""
    name = metadata["name"]
    title = metadata["title"]
    description = metadata["description"]
    use_for = metadata["use_for"]

    return f"""---
name: {name}
description: {description}
metadata:
  short-description: {title}
---

# {title}

## Overview

Integration of {title} into JWebMP with typed component model, CRTP API, dual rendering (HTML/JSON), and page configurators.

## Quick Start

```java
import com.jwebmp.plugins.{plugin_name.lower().replace('-', '')}.{title.split()[0]};

// Create component
// Example usage depends on the specific {title} library
```

## Use Cases

- {use_for}
- Integrating with JWebMP Component model
- Server-driven event handling
- Feature-based functionality

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>{plugin_name.lower()}</artifactId>
</dependency>
```

Version managed by JWebMP BOM.

## References

- Module: `com.jwebmp.plugins.{plugin_name.lower().replace('-', '')}`
- Java: 25+
- License: Apache 2.0

## See Also

- `jwebmp-core` - JWebMP core component model
- Other JWebMP plugins - Explore additional integrations
"""

def create_plugin_skill(plugin_name: str, skill_output_dir: Path):
    """Create a skill directory for a plugin"""
    if plugin_name not in PLUGIN_METADATA:
        print(f"[SKIP] {plugin_name} - No metadata available")
        return False

    metadata = PLUGIN_METADATA[plugin_name]
    skill_name = metadata["name"]
    skill_dir = skill_output_dir / skill_name

    # Skip if already exists
    if skill_dir.exists():
        print(f"[SKIP] {skill_name} - Already exists")
        return False

    try:
        # Create directory
        skill_dir.mkdir(parents=True, exist_ok=True)

        # Create SKILL.md
        skill_md_path = skill_dir / "SKILL.md"
        skill_md_path.write_text(generate_skill_md(plugin_name, metadata))

        # Create agents directory
        agents_dir = skill_dir / "agents"
        agents_dir.mkdir(exist_ok=True)

        # Create minimal agents/openai.yaml
        openai_yaml_path = agents_dir / "openai.yaml"
        openai_yaml_content = f"""display_name: "{metadata['title']}"
short_description: "{metadata['title']} integration for JWebMP"
default_prompt: "Help me work with {metadata['title']} in JWebMP"
"""
        openai_yaml_path.write_text(openai_yaml_content)

        print(f"[OK] {skill_name}")
        return True

    except Exception as e:
        print(f"[ERROR] {skill_name}: {e}")
        return False

def get_available_plugins() -> set:
    """Get list of available JWebMP plugins from directory"""
    plugins = set()
    if JWEBMP_PLUGINS_DIR.exists():
        for item in JWEBMP_PLUGINS_DIR.iterdir():
            if item.is_dir() and (item / "pom.xml").exists():
                plugins.add(item.name)
    return plugins

def get_existing_skills() -> set:
    """Get list of existing JWebMP skills"""
    skills = set()
    if SKILLS_OUTPUT_DIR.exists():
        for item in SKILLS_OUTPUT_DIR.iterdir():
            if item.is_dir() and item.name.startswith("jwebmp-"):
                # Extract plugin name from skill name
                skill_name = item.name
                # Map skill name back to plugin name
                for plugin, metadata in PLUGIN_METADATA.items():
                    if metadata["name"] == skill_name:
                        skills.add(plugin)
                        break
    return skills

def main():
    print("=" * 70)
    print("JWebMP Plugin Skills Generator")
    print("=" * 70)
    print()

    available_plugins = get_available_plugins()
    existing_skills = get_existing_skills()

    print(f"Available plugins: {len(available_plugins)}")
    print(f"Existing skills: {len(existing_skills)}")
    print()

    # Find plugins that need skills
    plugins_needing_skills = available_plugins - existing_skills

    if not plugins_needing_skills:
        print("[INFO] All available plugins already have skills!")
        return

    print(f"Plugins needing skills: {len(plugins_needing_skills)}")
    print()

    # Create skills for missing plugins
    created_count = 0
    for plugin in sorted(plugins_needing_skills):
        if create_plugin_skill(plugin, SKILLS_OUTPUT_DIR):
            created_count += 1

    print()
    print("=" * 70)
    print(f"Created: {created_count} skills")
    print("=" * 70)

    # Also try to create any plugins from metadata that aren't in the directory
    # but are tracked in PLUGIN_METADATA
    print()
    print("Creating any additional tracked plugins...")
    for plugin_name, metadata in sorted(PLUGIN_METADATA.items()):
        skill_name = metadata["name"]
        skill_dir = SKILLS_OUTPUT_DIR / skill_name
        if not skill_dir.exists():
            if create_plugin_skill(plugin_name, SKILLS_OUTPUT_DIR):
                created_count += 1

    print()
    print(f"Total created: {created_count} skills")

if __name__ == "__main__":
    main()





