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
        "description": "AG Charts community integration for JWebMP providing simple yet flexible charting with line, bar, scatter, pie, and more chart types. Use when embedding AG Charts visualizations.",
        "use_for": "AG Charts integration, chart types, responsive charting",
    },
    "agcharts-enterprise": {
        "name": "jwebmp-agcharts-enterprise",
        "title": "AG Charts Enterprise",
        "description": "AG Charts enterprise edition for JWebMP with advanced charting features, themes, and performance optimizations.",
        "use_for": "Enterprise charting, advanced visualizations",
    },
    "aggrid": {
        "name": "jwebmp-aggrid",
        "title": "AG Grid Community",
        "description": "AG Grid community integration with data tables, sorting, filtering, pagination, and row selection. Type-safe component model with CRTP API, dual rendering (HTML/JSON), and JWebMP integration. Use when working with AG Grid, creating data-heavy tables, grids with advanced filtering, or enterprise data presentation.",
        "use_for": "AG Grid data tables, column definitions, row models, grid options",
    },
    "aggrid-enterprise": {
        "name": "jwebmp-aggrid-enterprise",
        "title": "AG Grid Enterprise",
        "description": "AG Grid enterprise edition for JWebMP with advanced features like master-detail, aggregation, grouping, and server-side operations.",
        "use_for": "Enterprise data grids, advanced grid features",
    },
    "angular": {
        "name": "jwebmp-angular",
        "title": "Angular Integration",
        "description": "Angular framework integration for JWebMP providing component databinding, form handling, and reactive features. Use when building Angular-based JWebMP applications, integrating TypeScript components, or working with Angular forms.",
        "use_for": "Angular component integration, TypeScript client generation, reactive forms",
    },
    "angular-forms": {
        "name": "jwebmp-angular-forms",
        "title": "Angular Forms",
        "description": "Angular reactive and template-driven forms for JWebMP. Provides form validation, binding, and submission handling integrated with the JWebMP component model. Use when building complex forms with Angular in JWebMP applications.",
        "use_for": "Angular form building, reactive forms, form validation",
    },
    "angular-material": {
        "name": "jwebmp-angular-material",
        "title": "Angular Material",
        "description": "Angular Material design components integrated into JWebMP. Provides Material Design UI components with theme support and built-in accessibility. Use when building modern Material Design interfaces with Angular in JWebMP.",
        "use_for": "Material Design components, Angular Material theming, accessible UI",
    },
    "bootstrap": {
        "name": "jwebmp-bootstrap",
        "title": "Bootstrap CSS Framework",
        "description": "Bootstrap 5 CSS framework integration for JWebMP providing responsive grid layout, components, and utilities. Use when building responsive Bootstrap-based websites and applications with JWebMP.",
        "use_for": "Bootstrap grid system, responsive layout, Bootstrap components",
    },
    "c3": {
        "name": "jwebmp-c3",
        "title": "C3 Charts",
        "description": "C3 charting library integration for JWebMP providing D3-based reusable chart components. Use when creating data visualizations, time-series charts, or D3-powered dashboards.",
        "use_for": "C3 charts, D3-based visualizations, data-driven graphics",
    },
    "chartjs": {
        "name": "jwebmp-chartjs",
        "title": "Chart.js Charting",
        "description": "Chart.js integration for JWebMP providing simple yet flexible charting with line, bar, radar, doughnut, pie, polar area, bubble, and scatter charts with responsive design, animations, and plugins. Use when working with Chart.js, creating simple charts, building dashboards, or implementing lightweight charting in JWebMP applications.",
        "use_for": "Chart.js charting, simple charts, dashboard visualizations",
    },
    "d3": {
        "name": "jwebmp-d3",
        "title": "D3.js Data Visualization",
        "description": "D3.js integration for JWebMP enabling powerful data-driven document visualization. Provides access to D3 selections, scales, axes, and transitions. Use when building custom data visualizations or complex interactive graphics.",
        "use_for": "D3 visualizations, custom graphics, data-driven DOM manipulation",
    },
    "datatables": {
        "name": "jwebmp-datatables",
        "title": "DataTables",
        "description": "DataTables.net integration for JWebMP providing advanced interactive HTML tables with sorting, filtering, pagination, and AJAX capabilities. Use when building sophisticated data tables with search, sort, and export functionality.",
        "use_for": "Advanced HTML tables, server-side pagination, table extensions",
    },
    "easy-pie-chart": {
        "name": "jwebmp-easy-pie-chart",
        "title": "Easy Pie Chart",
        "description": "Easy Pie Chart jQuery plugin for JWebMP creating animated pie and doughnut charts with customizable canvas rendering. Use when embedding simple animated pie charts.",
        "use_for": "Animated pie charts, doughnut charts, canvas-based visualizations",
    },
    "easing": {
        "name": "jwebmp-easing",
        "title": "jQuery Easing",
        "description": "jQuery easing functions for JWebMP providing smooth animations and transitions with various easing curves. Use when implementing animated transitions and effects.",
        "use_for": "jQuery easing animations, animation curves, smooth transitions",
    },
    "fontawesome": {
        "name": "jwebmp-fontawesome",
        "title": "Font Awesome Free Icons",
        "description": "Font Awesome free icon library integration for JWebMP providing comprehensive icon fonts. Use when adding Font Awesome icons to JWebMP applications.",
        "use_for": "Font Awesome community icons, icon fonts, UI icons",
    },
    "fontawesome-pro": {
        "name": "jwebmp-fontawesome-pro",
        "title": "Font Awesome Pro Icons",
        "description": "Font Awesome pro icon library integration for JWebMP with expanded icon set and additional weights. Use when accessing premium Font Awesome icons.",
        "use_for": "Font Awesome pro icons, extended icon library",
    },
    "fullcalendar": {
        "name": "jwebmp-fullcalendar",
        "title": "FullCalendar Community",
        "description": "FullCalendar community edition for JWebMP providing interactive calendar with events, scheduling, and views. Use when building calendar-based scheduling interfaces.",
        "use_for": "Calendar integration, event scheduling, calendar views",
    },
    "fullcalendar-pro": {
        "name": "jwebmp-fullcalendar-pro",
        "title": "FullCalendar Pro",
        "description": "FullCalendar pro edition for JWebMP with advanced features like resource scheduling and timeline views.",
        "use_for": "Advanced calendar scheduling, resource management",
    },
    "globalize": {
        "name": "jwebmp-globalize",
        "title": "Globalize i18n",
        "description": "Globalize internationalization library integration for JWebMP supporting multi-language content, number/currency formatting, and date handling. Use when building multi-language JWebMP applications.",
        "use_for": "Internationalization, multi-language support, locale formatting",
    },
    "glyph-icons": {
        "name": "jwebmp-glyph-icons",
        "title": "Glyph Icons",
        "description": "Glyph Icons font library for JWebMP providing icon typography for Bootstrap and other projects. Use when adding icon fonts to Bootstrap-based JWebMP applications.",
        "use_for": "Icon fonts, Bootstrap icon integration",
    },
    "jqplot": {
        "name": "jwebmp-jqplot",
        "title": "jqPlot Charting",
        "description": "jqPlot jQuery charting plugin integration for JWebMP creating line, bar, pie, and other chart types. Use when building chart dashboards with jqPlot.",
        "use_for": "jqPlot charts, jQuery-based charting",
    },
    "jquery": {
        "name": "jwebmp-jquery",
        "title": "jQuery Library",
        "description": "jQuery JavaScript library integration for JWebMP providing foundational DOM manipulation, effects, and AJAX utilities. Foundation for many JWebMP plugin features.",
        "use_for": "jQuery utilities, DOM manipulation, jQuery AJAX",
    },
    "jquery-ui": {
        "name": "jwebmp-jquery-ui",
        "title": "jQuery UI",
        "description": "jQuery UI widget library integration for JWebMP providing interactions (drag, drop, resizable) and widgets (accordion, tabs, datepicker). Use when building interactive jQuery-based UIs.",
        "use_for": "jQuery UI widgets, drag and drop, resizable elements",
    },
    "local-storage": {
        "name": "jwebmp-local-storage",
        "title": "Local Storage",
        "description": "Browser Local Storage integration for JWebMP providing client-side persistent data storage. Use when implementing offline capability or storing user preferences in the browser.",
        "use_for": "Client-side storage, browser persistence, user preferences",
    },
    "markdown": {
        "name": "jwebmp-markdown",
        "title": "Markdown Support",
        "description": "Markdown parser and renderer integration for JWebMP converting Markdown to HTML components. Use when rendering user-generated or CMS content as Markdown.",
        "use_for": "Markdown rendering, content conversion, CMS integration",
    },
    "material-design-icons": {
        "name": "jwebmp-material-design-icons",
        "title": "Material Design Icons",
        "description": "Google Material Design Icons font library for JWebMP providing Material Design icon fonts. Use when adding Material Design icons to JWebMP applications.",
        "use_for": "Material Design icon fonts, icon integration",
    },
    "material-icons": {
        "name": "jwebmp-material-icons",
        "title": "Material Icons",
        "description": "Google Material Icons (older) font library for JWebMP. Use when integrating classic Material Icons.",
        "use_for": "Material icon fonts",
    },
    "plus-as-tab": {
        "name": "jwebmp-plus-as-tab",
        "title": "Plus As Tab",
        "description": "Plus As Tab feature for JWebMP allowing plus symbol (+) to act as tab navigation. Use when implementing tab-like navigation with plus button functionality.",
        "use_for": "Tab navigation, plus-triggered actions",
    },
    "prettify": {
        "name": "jwebmp-prettify",
        "title": "Google Prettify",
        "description": "Google Prettify syntax highlighter integration for JWebMP. Use when displaying and highlighting code snippets.",
        "use_for": "Code syntax highlighting, code display",
    },
    "prism": {
        "name": "jwebmp-prism",
        "title": "Prism Syntax Highlighting",
        "description": "Prism syntax highlighter integration for JWebMP providing powerful code highlighting with line numbers, copy button, and themes. Use when displaying highlighted code with advanced features.",
        "use_for": "Code syntax highlighting, Prism plugins, code blocks",
    },
    "session-storage": {
        "name": "jwebmp-session-storage",
        "title": "Session Storage",
        "description": "Browser Session Storage integration for JWebMP providing client-side temporary data storage for the browser session. Use when storing temporary user session data.",
        "use_for": "Session data storage, temporary browser persistence",
    },
    "skycons": {
        "name": "jwebmp-skycons",
        "title": "Skycons Weather Icons",
        "description": "Skycons animated weather icons for JWebMP creating beautiful animated SVG weather visualizations. Use when rendering weather data with animated icons.",
        "use_for": "Weather icons, animated SVG icons",
    },
    "themify-icons": {
        "name": "jwebmp-themify-icons",
        "title": "Themify Icons",
        "description": "Themify Icons font library for JWebMP providing a comprehensive icon font collection. Use when adding Themify icons to projects.",
        "use_for": "Themify icon fonts, icon integration",
    },
    "toastr": {
        "name": "jwebmp-toastr",
        "title": "Toastr Notifications",
        "description": "Toastr jQuery notification plugin integration for JWebMP displaying non-blocking toast notifications. Use when showing transient user notifications and alerts.",
        "use_for": "Toast notifications, user alerts, notification UI",
    },
    "tsclient": {
        "name": "jwebmp-tsclient",
        "title": "TypeScript Client Generation",
        "description": "TypeScript client code generator for JWebMP creating type-safe TypeScript from Java components. Use when generating TypeScript clients for JWebMP REST endpoints.",
        "use_for": "TypeScript generation, client-side type safety",
    },
    "waves-effect": {
        "name": "jwebmp-waves-effect",
        "title": "Waves Effect",
        "description": "Waves material design ripple effect for JWebMP creating Material Design click ripples on elements. Use when adding Material Design interaction effects.",
        "use_for": "Ripple effects, Material Design interactions",
    },
    "waypoints": {
        "name": "jwebmp-waypoints",
        "title": "Waypoints Scroll Plugin",
        "description": "Waypoints jQuery plugin for JWebMP triggering functions when elements enter the viewport. Use when implementing scroll-based interactions and animations.",
        "use_for": "Scroll detection, lazy loading, scroll animations",
    },
    "weather-icons": {
        "name": "jwebmp-weather-icons",
        "title": "Weather Icons",
        "description": "Weather Icons font library for JWebMP providing weather icon fonts. Use when displaying weather-related icons.",
        "use_for": "Weather icon fonts",
    },
    "webawesome": {
        "name": "jwebmp-webawesome",
        "title": "Web Awesome Community",
        "description": "Web Awesome community components for JWebMP providing accessible web components with Material Design. Use when building modern component-based UIs.",
        "use_for": "Web components, accessible UI components",
    },
    "webawesome-pro": {
        "name": "jwebmp-webawesome-pro",
        "title": "Web Awesome Pro",
        "description": "Web Awesome pro edition with extended component set and premium features.",
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





