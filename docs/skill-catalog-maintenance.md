# Skill catalog maintenance

Skill descriptions are loaded before the skill body. Keep the capability and its task boundary
near the beginning; place API inventories, versions, and implementation examples in the body or
workflow references. Aim for roughly 100–200 characters when that communicates the distinction
clearly. This is a collection target, not an OpenAI schema limit. Preserve explicit invocation
boundaries, such as security reviews that apply only when requested.

The catalog still contains 117 skills. This update reduced repository description text from
37,891 to 12,165 characters and the matching 79 global skills from 28,783 to 7,763 characters.
The nine largest entrypoints now route to workflow references while preserving their original
sections and code examples. Seven nested Markdown template fences were corrected during extraction.

## Skill-creator source

The creator guide and scripts were refreshed from the installed Codex system bundle, whose
entrypoint and validator match
[openai/codex at b4c864d](https://github.com/openai/codex/tree/b4c864dd6497ae764e6a826300b34f7ca77ba965/codex-rs/skills/src/assets/samples/skill-creator).
At verification time, the
[openai/skills copy at 49f948f](https://github.com/openai/skills/tree/49f948faa9258a0c61caceaf225e179651397431/skills/.system/skill-creator)
still contained the older guide. Compare versions before importing; a GitHub download is not
automatically newer than the installed system bundle.

Local adaptations retain the GuicedEE `.curated`/`.system` destination convention and provide a
valid UI short description and an explicit `$skill-creator` default prompt. Existing licenses,
icons, dependency declarations, and invocation policies are preserved. The installed Codex system
copy and IDE/plugin-managed copies are not patched by this repository maintenance workflow.

## Validate changes

With Python 3 and PyYAML available, run from the repository root:

```powershell
python -B -X utf8 scripts/validate-skills.py --json target/skill-validation.json
python -B -X utf8 scripts/tests/test_validate_skills.py
```

Check an installed global collection using the same rules:

```powershell
python -B -X utf8 scripts/validate-skills.py --root C:/Users/GedMarc/.agents/skills
```

Use `python3` on Linux/macOS. The checker invokes the bundled OpenAI validator, verifies existing
UI metadata and assets, and checks local Markdown links and anchors in entrypoints and references.
It reports description/body size advisories separately from validation failures. It does not
execute domain examples, contact cloud services, or certify every documented API contract.

When changing executable helpers, test their behavior too. Keep bash scripts LF without a BOM.
For generator updates, ensure regeneration retains the concise discovery text. Do not copy old
generated skills over reviewed content without comparing the complete diff.

## Installing the update

Apply metadata to matching global skills by name. Preserve their independent scripts, bodies,
policies, and dependency declarations; copy new references whenever an entrypoint begins linking
to them. For extracted guides, operate on each installed copy's own content so local differences
survive. Back up files before replacing them.

Codex can still shorten descriptions when names, paths, plugin skills, and other metadata exceed
the session's available budget. The
[catalog renderer](https://github.com/openai/codex/blob/b4c864dd6497ae764e6a826300b34f7ca77ba965/codex-rs/ext/skills/src/render.rs)
handles this separately from skill validation. Start a fresh Codex session after applying global
updates to inspect the newly loaded catalog. Offline size reduction alone cannot establish that
the IDE warning has disappeared. Do not disable skills or plugins merely to satisfy this checker.
