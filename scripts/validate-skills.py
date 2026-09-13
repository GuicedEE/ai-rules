#!/usr/bin/env python3
"""Read-only skill catalog checks. Run with Python's UTF-8 mode and PyYAML."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote

import yaml

REPOSITORY = Path(__file__).resolve().parent.parent


def prose_lines(text):
    marker = None
    length = 0
    for line in text.splitlines():
        fence = re.match(r'^\s*(`{3,}|~{3,})(.*)$', line)
        if fence:
            if marker is None:
                marker, length = fence[1][0], len(fence[1])
            elif fence[1][0] == marker and len(fence[1]) >= length and not fence[2].strip():
                marker = None
            continue
        if marker is None:
            yield line


def anchors(text):
    found = set(re.findall(r'<a\s+(?:name|id)=["\']([^"\']+)', text))
    counts = {}
    for line in prose_lines(text):
        match = re.match(r'^#{1,6}\s+(.+?)\s*#*$', line)
        if not match:
            continue
        slug = re.sub(r'[^\w\- ]', '', match[1].lower()).replace(' ', '-')
        count = counts.get(slug, 0)
        counts[slug] = count + 1
        found.add(slug + (f'-{count}' if count else ''))
    return found


def check_links(path):
    errors = []
    for line in prose_lines(path.read_text(encoding='utf-8')):
        for target in re.findall(r'\]\(([^)\n]+)\)', line):
            # URLs and illustrative placeholder targets are not local file references.
            if re.match(r'[a-zA-Z][\w+.-]*:', target) or '<' in target or '>' in target:
                continue
            target = target.split(' "', 1)[0]
            filename, _, fragment = unquote(target).partition('#')
            linked = path.parent / filename if filename else path
            if not linked.exists():
                errors.append(f'{path}: missing link target {target}')
            elif fragment and linked.suffix == '.md' and fragment not in anchors(linked.read_text(encoding='utf-8')):
                errors.append(f'{path}: missing anchor {target}')
    return errors


def audit(root, validator_path):
    spec = importlib.util.spec_from_file_location('upstream_skill_validator', validator_path)
    validator = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(validator)
    entries = sorted(set(root.glob('*/SKILL.md')) | set(root.glob('*/*/SKILL.md')))
    result = {'root': str(root), 'skills': [], 'errors': [], 'advisories': []}
    if not entries:
        result['errors'].append('No skills found under the specified root')
    names = set()
    for entry in entries:
        try:
            valid, message = validator.validate_skill(entry.parent)
            if not valid:
                result['errors'].append(f'{entry}: {message}')
                continue
            text = entry.read_text(encoding='utf-8')
            metadata = yaml.safe_load(re.match(r'\A---\n(.*?)\n---', text, re.S)[1])
            name, description = metadata['name'], metadata['description']
            if not name.strip() or not description.strip():
                result['errors'].append(f'{entry}: name and description must be nonempty')
            if name in names:
                result['errors'].append(f'{entry}: duplicate skill name {name}')
            names.add(name)
            if name != entry.parent.name:
                result['errors'].append(f'{entry}: name differs from directory name')
            row = {'name': name, 'description_characters': len(description), 'entrypoint_lines': len(text.splitlines()), 'entrypoint_bytes': len(text.encode('utf-8'))}
            result['skills'].append(row)
            if len(description) > 200:
                result['advisories'].append(f'{name}: description exceeds the collection target of 200 characters (not a schema limit)')
            if row['entrypoint_lines'] > 500:
                result['advisories'].append(f'{name}: consider workflow references for this large entrypoint')
            ui_path = entry.parent / 'agents/openai.yaml'
            if ui_path.exists():
                ui = yaml.safe_load(ui_path.read_text(encoding='utf-8')).get('interface', {})
                short = ui.get('short_description')
                prompt = ui.get('default_prompt')
                if short is not None and (not isinstance(short, str) or not 25 <= len(short) <= 64):
                    result['errors'].append(f'{ui_path}: short_description must have 25-64 characters')
                if prompt is not None and (not isinstance(prompt, str) or f'${name}' not in prompt):
                    result['errors'].append(f'{ui_path}: default_prompt must mention ${name}')
                for field in ['icon_small', 'icon_large']:
                    if ui.get(field) and not (entry.parent / ui[field]).is_file():
                        result['errors'].append(f'{ui_path}: missing {field} asset {ui[field]}')
            for document in [entry, *sorted((entry.parent / 'references').rglob('*.md'))]:
                result['errors'].extend(check_links(document))
        except (OSError, ValueError, TypeError, KeyError, AttributeError, yaml.YAMLError) as error:
            result['errors'].append(f'{entry}: {error}')
    result['skill_count'] = len(result['skills'])
    result['description_characters'] = sum(row['description_characters'] for row in result['skills'])
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=REPOSITORY / 'skills')
    parser.add_argument('--validator', type=Path, default=REPOSITORY / 'skills/.system/skill-creator/scripts/quick_validate.py')
    parser.add_argument('--json', type=Path, help='Write the detailed report to this file')
    args = parser.parse_args()
    result = audit(args.root, args.validator)
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2), encoding='utf-8')
    print(f"{result['skill_count']} skills; {result['description_characters']:,} description characters; {len(result['errors'])} errors; {len(result['advisories'])} advisories")
    for message in result['errors']:
        print('ERROR:', message)
    for message in result['advisories']:
        print('NOTE:', message)
    return bool(result['errors'])


if __name__ == '__main__':
    sys.exit(main())
