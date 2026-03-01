#!/usr/bin/env python3
"""Install skill(s) by name from default repositories."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys

DEFAULT_OPENAI_REPO = "openai/skills"
DEFAULT_GUICEDEE_REPO = "GuicedEE/ai-rules"
CURATED_PATH = "skills/.curated"
SYSTEM_PATH = "skills/.system"
GUICEDEE_FALLBACK_PATH = ".claude/skills"
DEFAULT_REF_BY_REPO = {
    DEFAULT_OPENAI_REPO: "main",
    DEFAULT_GUICEDEE_REPO: "master",
}


class Args(argparse.Namespace):
    skills: list[str]
    source: str
    curated_only: bool
    ref: str | None
    dest: str | None
    method: str


def _script_dir() -> str:
    return os.path.dirname(os.path.abspath(__file__))


def _installer_script() -> str:
    return os.path.join(_script_dir(), "install-skill-from-github.py")


def _selected_repos(source: str) -> list[str]:
    if source == "openai":
        return [DEFAULT_OPENAI_REPO]
    if source == "guicedee":
        return [DEFAULT_GUICEDEE_REPO]
    return [DEFAULT_OPENAI_REPO, DEFAULT_GUICEDEE_REPO]


def _selected_paths(curated_only: bool) -> list[str]:
    if curated_only:
        return [CURATED_PATH]
    return [CURATED_PATH, SYSTEM_PATH]


def _default_ref(repo: str) -> str:
    return DEFAULT_REF_BY_REPO.get(repo, "main")


def _validate_skill_name(skill_name: str) -> bool:
    if not skill_name:
        return False
    if "/" in skill_name or "\\" in skill_name:
        return False
    if skill_name in (".", ".."):
        return False
    return True


def _attempt_install(
    skill_name: str,
    repo: str,
    base_path: str,
    ref: str,
    dest: str | None,
    method: str,
) -> subprocess.CompletedProcess[str]:
    script = _installer_script()
    skill_path = f"{base_path}/{skill_name}"
    cmd = [
        sys.executable,
        script,
        "--repo",
        repo,
        "--path",
        skill_path,
        "--ref",
        ref,
        "--method",
        method,
    ]
    if dest:
        cmd.extend(["--dest", dest])
    return subprocess.run(cmd, capture_output=True, text=True)


def _parse_args(argv: list[str]) -> Args:
    parser = argparse.ArgumentParser(
        description=(
            "Install one or more skills by name from default sources "
            "(openai/skills and GuicedEE/ai-rules)."
        )
    )
    parser.add_argument("skills", nargs="+", help="Skill name(s) to install")
    parser.add_argument(
        "--source",
        choices=["all", "openai", "guicedee"],
        default="all",
        help="Source set to search (default: all)",
    )
    parser.add_argument(
        "--curated-only",
        action="store_true",
        help="Search only skills/.curated (default searches .curated and .system)",
    )
    parser.add_argument(
        "--ref",
        default=None,
        help="Git ref to use (default is source-specific: openai=main, guicedee=master)",
    )
    parser.add_argument("--dest", help="Destination skills directory")
    parser.add_argument(
        "--method",
        choices=["auto", "download", "git"],
        default="auto",
    )
    return parser.parse_args(argv, namespace=Args())


def main(argv: list[str]) -> int:
    args = _parse_args(argv)
    repos = _selected_repos(args.source)
    paths = _selected_paths(args.curated_only)
    failures = 0

    for skill_name in args.skills:
        if not _validate_skill_name(skill_name):
            print(f"Error: Invalid skill name '{skill_name}'.", file=sys.stderr)
            failures += 1
            continue

        installed = False
        attempts: list[str] = []

        for repo in repos:
            repo_paths = list(paths)
            if repo == DEFAULT_GUICEDEE_REPO and GUICEDEE_FALLBACK_PATH not in repo_paths:
                repo_paths.append(GUICEDEE_FALLBACK_PATH)

            for base_path in repo_paths:
                result = _attempt_install(
                    skill_name,
                    repo,
                    base_path,
                    args.ref or _default_ref(repo),
                    args.dest,
                    args.method,
                )
                if result.returncode == 0:
                    if result.stdout.strip():
                        print(result.stdout.strip())
                    print(
                        f"Resolved {skill_name} from {repo}/{base_path}/{skill_name}"
                    )
                    installed = True
                    break
                err = result.stderr.strip() or result.stdout.strip() or "unknown error"
                attempts.append(f"{repo}:{base_path}/{skill_name} -> {err}")
            if installed:
                break

        if not installed:
            failures += 1
            print(
                f"Error: Could not install '{skill_name}' from default sources.",
                file=sys.stderr,
            )
            for attempt in attempts:
                print(f"  - {attempt}", file=sys.stderr)

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
