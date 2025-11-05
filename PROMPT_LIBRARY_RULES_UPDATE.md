# 🧰 Starter Prompt — Library Rules Update (Framework/Component Libraries)

Use this prompt when you maintain a library (e.g., JWebMP, EntityAssist, WebAwesome) and need to update or (re)create its rules, indexes, and guides to align with the RulesRepository. This drives a forward-only, modular documentation model and ensures host projects can navigate component/topic rules easily.

Supported: JetBrains AI (Junie), GitHub Copilot Chat, Cursor, ChatGPT, Claude, Roo.

---

## 0) Provide Inputs
Fill before running.

- Library name: <LIBRARY_NAME>
- Current/new version: <VERSION>
- Repository URL / path: <REPO_URL_OR_PATH>
- Short description: <ONE_LINE_DESCRIPTION>
- Type: [ ] UI component library  [ ] Data/ORM  [ ] Service/Framework  [ ] Other: <OTHER>
- Primary language(s): <LANGUAGES>
- Component/topic areas (list): <TOPICS>
- Structural: [ ] MapStruct  [ ] Lombok  [ ] Logging  [ ] JSpecify
- Security (Reactive): [ ] Vert.x Web Auth/JWT/OAuth2
- Security/Auth Providers: [ ] OpenID Connect (generic)  [ ] GCP (IAP/OIDC)  [ ] Firebase Auth  [ ] Microsoft Entra ID (Azure AD)
- Architecture: [ ] Monolith  [ ] Microservices  [ ] Micro Frontends  [ ] DDD
- Observability/Diagnostics: [ ] Wireshark
- AI engine used: [ ] JetBrains Junie  [ ] GitHub Copilot  [ ] Cursor  [ ] ChatGPT  [ ] Claude  [ ] Roo
- Release impact: [x] Forward-only (breaking changes allowed)  [ ] Backcompat required (only if explicitly demanded)

Policies (must honor):
- Follow RULES.md sections: 4 (Behavioral), 5 (Technical), Document Modularity Policy, 6 (Forward-Only Change Policy).
- Generated artifacts are read-only; do not propose edits to compiled outputs (e.g., TS/HTML/site bundles). For JWebMP specifically, do not generate or reference separate TS/HTML components for missing views—render dialogs/tables directly from Java components/cell renderers.
- In JWebMP, avoid inline string HTML; express markup using JWebMP components (Div, Paragraph, Span, Table, H1–H6, etc.).
- PostgreSQL (JPMS): Do not shade the driver. Use GuicedEE Services artifacts (com.guicedee.services:postgresql) and require org.postgresql in module-info.java.
- For component-driven topics, provide a parent README index that links to each component .rules.md or subsection anchors.

---

## 1) Self‑Configure the AI Engine
- Pin ./RULES.md anchors (sections above). Operate in forward-only mode.
- If Copilot/Cursor, create a workspace note or .cursor/rules.md summarizing constraints.
- If ChatGPT/Claude:
  - Start with system note: "Follow RulesRepository RULES.md sections 4,5, Document Modularity, and 6 (forward-only). Close loops across artifacts."
  - Owner mode (this RulesRepository repository is the active workspace; not used as a submodule):
    - Do not refer to this repository as a submodule.
    - Load and pin ./skills.md; use project-scoped Skills under .claude/skills/.
  - Host project mode (a downstream project consuming these rules):
    - Use this repository as a Git submodule and link to it from host artifacts.
  - For Claude specifically: load and pin ./skills.md; discover project Agent Skills under .claude/skills/ (auto-discovered by Claude Code); acknowledge which Skills are active and apply them throughout generation.
- If Roo, load and pin ROO_WORKSPACE_POLICY.md at the repository root. If it does not exist, create it with a summary of RULES.md sections 4,5, Document Modularity Policy, and 6 (Forward-Only). Ensure repo-scoped conversations, include file paths in responses, and confirm forward-only mode is enabled. Update all references affected by a change in the same forward-only change set.

---

## 2) Library Documentation Tasks
Perform as a single, forward-only change set. The exact target paths depend on your library repo structure (e.g., docs/, guides/, or packages/<lib>/docs/). Do NOT put library-specific docs inside the RulesRepository submodule directory.

1. Topic index (parent README)
   - Create or update a topic index README for this library’s rules directory.
   - For UI libraries (e.g., WebAwesome):
     - Index each component with links to ./<component>.rules.md
     - If a component is documented as a subsection, add direct anchors (e.g., input.rules.md#number-input)
   - For non-UI libraries (e.g., EntityAssist):
     - Index modular topics (e.g., Entities, Repositories, Transactions, Testing, Anti-patterns)

2. Modularize content
   - Split monolithic docs into smaller modular files focused on a single topic/area.
   - Use kebab-case filenames; for components, use <component>.rules.md; for guides, prefer concise overviews.
   - Remove obsolete monoliths (no legacy anchors) and update all references per Forward-Only policy.

3. Rules templates (components)
   - For each component/topic, create a .rules.md with:
     - Overview and purpose
     - Usage patterns and minimal examples
     - Inputs/outputs/events (for UI)
     - Styling/theming (for UI) or configuration (for non-UI)
     - Accessibility (UI) or performance/constraints (non-UI)
     - See-also links (index, related rules)

4. Cross-links to enterprise topics
- Link to relevant RulesRepository indexes in your README to aid host projects:
  - Frontend (Standard):
    - Web Components: rules/generative/frontend/webcomponents/README.md
    - WebAwesome: rules/generative/frontend/webawesome/README.md
    - JWebMP: rules/generative/frontend/jwebmp/README.md
  - Frontend (Reactive):
    - Angular: rules/generative/frontend/angular/README.md
    - Angular Awesome (Angular 19+ plugin): rules/generative/frontend/angular-awesome/README.md
    - React: rules/generative/frontend/react/README.md
    - Next.js (App Router): rules/generative/frontend/nextjs/README.md
  - Backend:
    - Hibernate 7 Reactive: rules/generative/backend/hibernate/README.md
    - Security (Reactive): rules/generative/backend/security-reactive/README.md
  - Platform:
    - Platform Observability: rules/generative/platform/observability/README.md
    - Platform Security & Auth: rules/generative/platform/security-auth/README.md
    - Env variables: rules/generative/platform/secrets-config/env-variables.md
  - Architecture: rules/generative/architecture/README.md (e.g., ddd/README.md, microfronts/README.md)
  - Data:
    - rules/generative/data/README.md
    - rules/generative/data/activity-master/README.md

5. Versioning and release notes
   - If rules reorganization is breaking (likely under forward-only), prepare RELEASE_NOTES.md summarizing changes.
   - Update CHANGELOG.md and bump version appropriately.

6. README (library root) updates
   - Add “How to use these rules” section pointing to your topic index and to the RulesRepository submodule usage.
   - Add a short “Prompt Language Alignment & Glossary” note: state the aligned names (if any) and instruct host projects to copy them into their GLOSSARY.md so prompts and docs share terminology.

---

## 3) Special Guidance by Library Type
- WebAwesome (UI components)
  - Ensure parent README index exists and includes components such as button.rules.md, input.rules.md (with #number-input anchor), etc.
  - Enforce prompt language alignment in docs and examples: use WebAwesome component names when prompting and naming (e.g., WaButton, WaIconButton, WaInput, WaCluster for rows, WaStack for columns/stacks). Link to generative/frontend/webawesome/README.md → “Prompt Language Alignment”.
  - For new components, add <name>.rules.md and update the index.
- JWebMP wrappers
  - Provide wrapper-specific rules where needed; link to underlying WebAwesome or Web Component contracts.
- EntityAssist / ORM-like libraries
  - Provide modular rules for entities, repositories, transactions, testing, threading, and anti-patterns.
- Service/Framework libraries
  - Provide modular rules for lifecycle, configuration, extension points, and integration examples.

---

## 4) Output Checklist
- [ ] Parent topic README index created/updated with full component/topic coverage
- [ ] Modular .md files created and linked; monoliths removed per Forward-Only policy
- [ ] Component .rules.md files created/updated with usage, patterns, and see-also links
- [ ] Cross-links to RulesRepository topic indexes included
- [ ] Release notes and version bump prepared (if applicable)
- [ ] Root README updated with navigation and usage instructions
- [ ] All links resolve

---

## 5) Guardrails
- No backwards compatibility stubs unless explicitly required; apply Forward-Only Change Policy fully.
- Keep library docs in the library repo (outside any RulesRepository submodule).
- Close loops: indexes ↔ rules files ↔ examples/implementations.

---

## 6) AI Response Format
1) Proposed documentation and index changes
2) File/diff list
3) Open questions (if any)
4) Final content

End of prompt.