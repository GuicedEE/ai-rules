# AI Assistant Core Rules (Pinned)

Canonical policy source: `AGENTS.md`.

## Load First

1. `RULES.md` sections 4, 5, Document Modularity Policy, 6
2. `README.md`
3. `skills.md`

## Behavioral and Technical Requirements

- Respect forward-only updates for requested changes.
- Keep documentation-first, stage-gated workflow unless user waiver is explicit.
- Close loops between `PACT`, `GLOSSARY`, `RULES`, `GUIDES`, and `IMPLEMENTATION`.
- If runtime skill discovery is incomplete, load project skills/rules directly from `skills.md` and topic indexes instead of using unguided/direct implementation fallback.
- Keep implementation library-first: prefer concrete APIs/SPI contracts from selected topic rules before adding new interfaces.
