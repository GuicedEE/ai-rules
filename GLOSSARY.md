# Project Glossary

Purpose
- Canonical, human-readable definitions for terms, components, acronyms, product names, and prompt-aligned labels used across the project.
- Ensures consistent Prompt Language Alignment across PACT, RULES, GUIDES, IMPLEMENTATION, and code.

Population model
- This glossary is populated by the topics selected in project prompts (e.g., PROMPT_NEW_PROJECT.md, PROMPT_ADOPT_EXISTING_PROJECT.md).
- For UI/component topics that enforce Prompt Language Alignment, the aligned names and mappings MUST be copied here.
  - Example (WebAwesome):
    - “button” → WaButton
    - “icon button” → WaIconButton
    - “input” → WaInput
    - “row” (layout) → WaCluster
    - “column/stack” (layout) → WaStack
- For backend/framework topics, define agreed terminology (e.g., entity vs. record, service vs. handler, realm vs. tenant), and any domain-specific acronyms.

How to use in prompts and templates
- Prompt templates must create a lean, context-driven alignment to this glossary for all items selected for the project.
- When generating files, the AI should reference glossary entries by name and keep names consistent with this document.
- If a request mentions a variant without a dedicated file, use the glossary-aligned base term and link to the rule’s subsection as needed.

Maintenance rules
- Forward-only: update terms here when rules or libraries change; do not maintain legacy aliases unless explicitly required.
- Keep entries concise; prefer one-line definitions with optional see-also links to RULES.md sections or component rule files.
- Close loops:
  - PACT should reference this glossary for shared language.
  - RULES should point to glossary entries when naming/terminology is enforced.
  - GUIDES should use glossary names consistently and link back when terms are introduced.
  - IMPLEMENTATION should avoid inventing new terminology; use glossary names in code comments and docs.

Structure (suggested)
- UI components
  - WebAwesome: WaButton, WaIconButton, WaInput, WaCluster, WaStack
  - Angular Awesome: aligned Angular directives/components that wrap WebAwesome
- Backend & architecture
  - Define chosen terms (e.g., DDD: Aggregate, Entity, Value Object; Security: Issuer, Audience, Realm)
- Data
  - Database naming conventions and key acronyms

See also
- ./README.md → Structure of Work (Glossary layer)
- ./generative/frontend/webawesome/README.md → Prompt Language Alignment
- ./generative/frontend/angular-awesome/README.md → Prompt Language Alignment
- ./generative/frontend/jwebmp/jwebmp-webawesome/README.md → Prompt Language Alignment
