#!/usr/bin/env python3
"""Generate APM package metadata from the canonical skill catalog."""
import json
import argparse
import shutil
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parent.parent
VERSION = "2.4.0"


def main():
    packages = []
    names = set()
    for skill in sorted((ROOT / "skills").glob(".*/*/SKILL.md")):
        metadata = yaml.safe_load(skill.read_text(encoding="utf-8").split("---", 2)[1])
        name = metadata["name"]
        if name in names:
            raise ValueError(f"Duplicate skill name: {name}")
        names.add(name)
        description = " ".join(metadata["description"].split())
        source = "./" + skill.parent.relative_to(ROOT).as_posix()
        packages.append(dict(name=name, description=description, source=source,
                             version=VERSION, category="Development"))
        manifest = dict(name=name, version=VERSION, description=description,
                        license="Apache-2.0", dependencies={})
        (skill.parent / "apm.yml").write_text(yaml.safe_dump(manifest, sort_keys=False), encoding="utf-8")
        plugin = skill.parent / ".claude-plugin/plugin.json"
        plugin.parent.mkdir(exist_ok=True)
        plugin.write_text(json.dumps(dict(name=name, version=VERSION, description=description,
                                         license="Apache-2.0", skills=["./"]), indent=2) + "\n", encoding="utf-8")
    marketplace = dict(name="guicedee-ai-rules", version=VERSION,
                       description="Reusable enterprise development skills for GuicedEE, JWebMP, EntityAssist and ActivityMaster.",
                       license="Apache-2.0",
                       marketplace=dict(owner=dict(name="GuicedEE", url="https://github.com/GuicedEE"),
                                        outputs=dict(claude={}, codex={}), packages=packages))
    (ROOT / "apm.yml").write_text(yaml.safe_dump(marketplace, sort_keys=False), encoding="utf-8")
    print(f"Generated APM metadata for {len(packages)} skills. Run apm pack next.")


def export():
    destination = ROOT / "target/marketplace-preview"
    destination.mkdir(parents=True, exist_ok=True)
    for name in ("skills", ".claude-plugin", ".agents"):
        shutil.copytree(ROOT / name, destination / name, dirs_exist_ok=True)
    for name in ("apm.yml", "README.md", "LICENSE"):
        shutil.copyfile(ROOT / name, destination / name)
    print(f"Exported marketplace preview: {destination}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--export", action="store_true", help="Export generated indexes and skills for a local install preview, without Git metadata")
    args = parser.parse_args()
    if args.export:
        export()
    else:
        main()
