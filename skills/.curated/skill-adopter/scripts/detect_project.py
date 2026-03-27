#!/usr/bin/env python3
"""
Scan a project directory to detect AI agent configurations and tech stack signals.

Usage:
    python detect_project.py <project-root> [--json]

Outputs a structured report of detected agents and stack technologies.
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path

AGENT_SIGNATURES = {
    "codex": {
        "files": ["AGENTS.md"],
        "label": "Codex CLI",
    },
    "copilot": {
        "files": [".github/copilot-instructions.md"],
        "label": "GitHub Copilot",
    },
    "cursor": {
        "files": [".cursor/rules.md", ".cursorrules"],
        "label": "Cursor",
    },
    "junie": {
        "files": [".junie/guidelines.md"],
        "label": "JetBrains Junie",
    },
    "ai-assistant": {
        "files": [".aiassistant/rules"],
        "label": "JetBrains AI Assistant",
    },
    "claude": {
        "files": [".claude/settings.json", ".claude/skills"],
        "label": "Claude",
    },
    "roo": {
        "files": [".roo/rules", ".roomodes"],
        "label": "Roo",
    },
}

STACK_SIGNALS = {
    "java-maven": {
        "files": ["pom.xml"],
        "label": "Java / Maven",
    },
    "guicedee": {
        "grep_files": ["pom.xml", "module-info.java"],
        "pattern": r"com\.guicedee",
        "label": "GuicedEE",
    },
    "jwebmp": {
        "grep_files": ["pom.xml", "module-info.java"],
        "pattern": r"com\.jwebmp",
        "label": "JWebMP",
    },
    "entityassist": {
        "grep_files": ["pom.xml", "module-info.java"],
        "pattern": r"com\.entityassist",
        "label": "EntityAssist",
    },
    "activitymaster": {
        "grep_files": ["pom.xml"],
        "pattern": r"activitymaster",
        "label": "ActivityMaster",
    },
    "vertx": {
        "grep_files": ["pom.xml", "module-info.java"],
        "pattern": r"(com\.guicedee\.vertx|io\.vertx)",
        "label": "Vert.x",
    },
    "angular": {
        "files": ["angular.json"],
        "label": "Angular",
    },
    "typescript": {
        "files": ["tsconfig.json"],
        "label": "TypeScript",
    },
    "terraform": {
        "globs": ["*.tf"],
        "label": "Terraform",
    },
    "docker": {
        "files": ["Dockerfile", "docker-compose.yml", "docker-compose.yaml"],
        "label": "Docker",
    },
    "react": {
        "grep_files": ["package.json"],
        "pattern": r'"react"',
        "label": "React",
    },
    "vue": {
        "grep_files": ["package.json"],
        "pattern": r'"vue"',
        "label": "Vue",
    },
    "nextjs": {
        "grep_files": ["package.json"],
        "pattern": r'"next"',
        "label": "Next.js",
    },
    "github-actions": {
        "files": [".github/workflows"],
        "label": "GitHub Actions",
    },
}


def check_file_exists(root: Path, relative: str) -> bool:
    target = root / relative
    return target.exists()


def grep_file(root: Path, relative: str, pattern: str) -> bool:
    target = root / relative
    if not target.is_file():
        return False
    try:
        text = target.read_text(encoding="utf-8", errors="ignore")
        return bool(re.search(pattern, text))
    except (OSError, UnicodeDecodeError):
        return False


def find_glob(root: Path, pattern: str) -> bool:
    return any(root.glob(pattern))


def detect_agents(root: Path) -> dict:
    detected = {}
    for agent_id, sig in AGENT_SIGNATURES.items():
        found_files = []
        for f in sig["files"]:
            if check_file_exists(root, f):
                found_files.append(f)
        if found_files:
            detected[agent_id] = {
                "label": sig["label"],
                "config_files": found_files,
            }
    return detected


def detect_stack(root: Path) -> dict:
    detected = {}
    for stack_id, sig in STACK_SIGNALS.items():
        found = False

        if "files" in sig:
            for f in sig["files"]:
                if check_file_exists(root, f):
                    found = True
                    break

        if not found and "grep_files" in sig:
            for f in sig["grep_files"]:
                if grep_file(root, f, sig["pattern"]):
                    found = True
                    break

        if not found and "globs" in sig:
            for g in sig["globs"]:
                if find_glob(root, g):
                    found = True
                    break

        if found:
            detected[stack_id] = {"label": sig["label"]}

    return detected


def find_skills_root(root: Path) -> str | None:
    """Try to locate the skills repository relative to the project root."""
    candidates = [
        "rules/skills",
        "AIRules/skills",
        "ai-rules/skills",
        "skills",
    ]
    for candidate in candidates:
        if (root / candidate / ".curated").is_dir() or (root / candidate / ".system").is_dir():
            return candidate
    return None


def recommend_skills(stack: dict) -> dict:
    """Return skill recommendations based on detected stack."""
    core = ["git-commit-helper", "code-reviewer", "systematic-debugging"]
    stack_specific = []
    optional = ["senior-architect", "test-driven-development"]

    if "guicedee" in stack:
        stack_specific.extend([
            "guicedee-inject", "guicedee-config", "guicedee-rest",
            "guicedee-persistence", "guicedee-web",
        ])
    if "vertx" in stack:
        stack_specific.append("guicedee-vertx")
    if "jwebmp" in stack:
        stack_specific.extend(["jwebmp-core", "jwebmp-client"])
    if "entityassist" in stack:
        stack_specific.append("entityassist")
    if "activitymaster" in stack:
        stack_specific.extend(["activitymaster", "entityassist"])
    if "terraform" in stack:
        stack_specific.extend([
            "terraform-code-generator", "terraform-validator",
            "terraform-plan-analyzer", "terraform-security-scanner",
        ])
    if "github-actions" in stack:
        stack_specific.extend(["gh-fix-ci", "gh-address-comments"])
        optional.append("finishing-a-development-branch")

    optional.append("security-best-practices")

    # Deduplicate while preserving order
    seen = set()
    def dedup(lst):
        result = []
        for item in lst:
            if item not in seen:
                seen.add(item)
                result.append(item)
        return result

    return {
        "core": dedup(core),
        "stack_specific": dedup(stack_specific),
        "optional": dedup(optional),
    }


def main():
    parser = argparse.ArgumentParser(description="Detect project AI agents and tech stack")
    parser.add_argument("project_root", help="Path to the project root directory")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    args = parser.parse_args()

    root = Path(args.project_root).resolve()
    if not root.is_dir():
        print(f"Error: {root} is not a directory", file=sys.stderr)
        sys.exit(1)

    agents = detect_agents(root)
    stack = detect_stack(root)
    skills_root = find_skills_root(root)
    recommendations = recommend_skills(stack)

    result = {
        "project_root": str(root),
        "skills_root": skills_root,
        "agents": agents,
        "stack": stack,
        "recommended_skills": recommendations,
    }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"Project: {root}\n")

        print("AI Agents detected:")
        if agents:
            for aid, info in agents.items():
                print(f"  ✓ {info['label']}  ({', '.join(info['config_files'])})")
        else:
            print("  (none found)")

        print(f"\nSkills repository: {skills_root or '(not found)'}\n")

        print("Tech stack detected:")
        if stack:
            for sid, info in stack.items():
                print(f"  • {info['label']}")
        else:
            print("  (none detected)")

        print("\nRecommended skills:")
        print("  Core:")
        for s in recommendations["core"]:
            print(f"    ✓ {s}")
        if recommendations["stack_specific"]:
            print("  Stack-specific:")
            for s in recommendations["stack_specific"]:
                print(f"    ✓ {s}")
        if recommendations["optional"]:
            print("  Optional:")
            for s in recommendations["optional"]:
                print(f"    ○ {s}")


if __name__ == "__main__":
    main()

