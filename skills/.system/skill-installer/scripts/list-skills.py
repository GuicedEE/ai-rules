#!/usr/bin/env python3
"""List skills from a GitHub repo path."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
import os
import sys
import urllib.error

from github_utils import github_api_contents_url, github_request

DEFAULT_OPENAI_REPO = "openai/skills"
DEFAULT_GUICEDEE_REPO = "GuicedEE/ai-rules"
DEFAULT_PATH = "skills/.curated"
SYSTEM_PATH = "skills/.system"
GUICEDEE_FALLBACK_PATH = ".claude/skills"
DEFAULT_REF_BY_REPO = {
    DEFAULT_OPENAI_REPO: "main",
    DEFAULT_GUICEDEE_REPO: "master",
}


class ListError(Exception):
    pass


class Args(argparse.Namespace):
    repo: str | None
    source: str
    path: str
    include_system: bool
    ref: str | None
    format: str


@dataclass(frozen=True)
class SourceSpec:
    repo: str
    path: str
    ref: str


def _request(url: str) -> bytes:
    return github_request(url, "codex-skill-list")


def _codex_home() -> str:
    return os.environ.get("CODEX_HOME", os.path.expanduser("~/.codex"))


def _installed_skills() -> set[str]:
    root = os.path.join(_codex_home(), "skills")
    if not os.path.isdir(root):
        return set()
    entries = set()
    for name in os.listdir(root):
        path = os.path.join(root, name)
        if os.path.isdir(path):
            entries.add(name)
    return entries


def _list_skills(repo: str, path: str, ref: str) -> list[str]:
    api_url = github_api_contents_url(repo, path, ref)
    try:
        payload = _request(api_url)
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            raise ListError(
                "Skills path not found: "
                f"https://github.com/{repo}/tree/{ref}/{path}"
            ) from exc
        raise ListError(f"Failed to fetch skills: HTTP {exc.code}") from exc
    data = json.loads(payload.decode("utf-8"))
    if not isinstance(data, list):
        raise ListError("Unexpected skills listing response.")
    skills = [item["name"] for item in data if item.get("type") == "dir"]
    return sorted(skills)


def _selected_repos(args: Args) -> list[str]:
    if args.repo:
        return [args.repo]
    if args.source == "openai":
        return [DEFAULT_OPENAI_REPO]
    if args.source == "guicedee":
        return [DEFAULT_GUICEDEE_REPO]
    return [DEFAULT_OPENAI_REPO, DEFAULT_GUICEDEE_REPO]


def _selected_paths(args: Args, repo: str) -> list[str]:
    paths = [args.path]
    if args.include_system and SYSTEM_PATH not in paths:
        paths.append(SYSTEM_PATH)
    if (
        repo == DEFAULT_GUICEDEE_REPO
        and args.path == DEFAULT_PATH
        and GUICEDEE_FALLBACK_PATH not in paths
    ):
        paths.append(GUICEDEE_FALLBACK_PATH)
    return paths


def _default_ref(repo: str) -> str:
    return DEFAULT_REF_BY_REPO.get(repo, "main")


def _selected_sources(args: Args) -> list[SourceSpec]:
    repos = _selected_repos(args)
    sources: list[SourceSpec] = []
    for repo in repos:
        paths = _selected_paths(args, repo)
        for path in paths:
            sources.append(
                SourceSpec(
                    repo=repo,
                    path=path,
                    ref=args.ref or _default_ref(repo),
                )
            )
    return sources


def _parse_args(argv: list[str]) -> Args:
    parser = argparse.ArgumentParser(description="List skills.")
    parser.add_argument("--repo", help="owner/repo (overrides --source)")
    parser.add_argument(
        "--source",
        choices=["all", "openai", "guicedee"],
        default="all",
        help="Default source set when --repo is not provided (default: all)",
    )
    parser.add_argument(
        "--path",
        default=DEFAULT_PATH,
        help="Repo path to list (default: skills/.curated)",
    )
    parser.add_argument(
        "--include-system",
        action="store_true",
        help="Also include skills/.system for the selected sources",
    )
    parser.add_argument(
        "--ref",
        default=None,
        help="Git ref to use (default is source-specific: openai=main, guicedee=master)",
    )
    parser.add_argument(
        "--format",
        choices=["text", "json"],
        default="text",
        help="Output format",
    )
    return parser.parse_args(argv, namespace=Args())


def main(argv: list[str]) -> int:
    args = _parse_args(argv)
    sources = _selected_sources(args)
    installed = _installed_skills()
    failures: list[tuple[SourceSpec, str]] = []
    listings: list[tuple[SourceSpec, list[str]]] = []

    for source in sources:
        try:
            skills = _list_skills(source.repo, source.path, source.ref)
            listings.append((source, skills))
        except ListError as exc:
            failures.append((source, str(exc)))

    if not listings:
        for source, error in failures:
            print(
                f"Error: {source.repo}:{source.path}@{source.ref} -> {error}",
                file=sys.stderr,
            )
        return 1

    is_single_source = len(listings) == 1 and not failures

    try:
        if args.format == "json":
            if is_single_source:
                payload = [
                    {"name": name, "installed": name in installed}
                    for name in listings[0][1]
                ]
            else:
                payload = [
                    {
                        "repo": source.repo,
                        "path": source.path,
                        "name": name,
                        "installed": name in installed,
                    }
                    for source, skills in listings
                    for name in skills
                ]
            print(json.dumps(payload))
        else:
            if is_single_source:
                for idx, name in enumerate(listings[0][1], start=1):
                    suffix = " (already installed)" if name in installed else ""
                    print(f"{idx}. {name}{suffix}")
            else:
                for source, skills in listings:
                    print(f"Skills from {source.repo} ({source.path}@{source.ref}):")
                    for idx, name in enumerate(skills, start=1):
                        suffix = " (already installed)" if name in installed else ""
                        print(f"{idx}. {name}{suffix}")
                    print("")

        success_repos = {source.repo for source, _ in listings}
        for source, error in failures:
            if source.repo in success_repos:
                continue
            print(
                f"Warning: {source.repo}:{source.path}@{source.ref} -> {error}",
                file=sys.stderr,
            )
        return 0
    except ListError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
