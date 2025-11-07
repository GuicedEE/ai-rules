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

- Component/topic areas (list): <TOPICS>
- Structural: [ ] MapStruct  [ ] Lombok  [ ] Logging  [ ] JSpecify
- Fluent API Strategy (choose exactly one): [ ] CRTP (generic self-type; implied for GuicedEE and JWebMP)  [ ] Builder pattern (Lombok @Builder/manual). Only one may be selected; if GuicedEE or JWebMP is selected, CRTP is enforced.
- Frontend (Standard): [ ] Web Components
- Frontend (Reactive): Angular (choose exactly one) [ ] Angular 17  [ ] Angular 19  [ ] Angular 20  [ ] React  [ ] Next.js
- Frontend (Angular Plugins): [ ] Angular Awesome
- Frameworks (JWebMP) : Core [ ] WebAwesome [ ]
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
- Fluent API Strategy: Choose either CRTP or Builder. CRTP is enforced if GuicedEE or JWebMP is selected. Align Lombok usage accordingly:
  - If CRTP: do not use @Builder; implement manual CRTP fluent setters returning (J)this with @SuppressWarnings("unchecked") as needed.
  - If Builder: prefer Lombok @Builder or manual builders; do not apply CRTP chaining rules.
- Glossary policy (topic-first): Provide and maintain a topic-scoped GLOSSARY.md for your library with minimal canonical terms and “LLM interpretation guidance”. Avoid duplicating definitions in host projects. Host projects compose their root GLOSSARY.md by linking to your topic GLOSSARY.md and copying only enforced Prompt Language Alignment mappings (e.g., WebAwesome names); all other terms should be linked to your topic files/anchors.

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

Language Selection (configure here)
- Languages
  - Java (choose exactly one LTS)
    - [ ] Java 17 LTS
    - [ ] Java 21 LTS
    - [ ] Java 25 LTS
  - Web
    - [ ] TypeScript
      - [ ] Angular (TypeScript)
      - [ ] React (TypeScript)
    - [ ] JavaScript
  - Kotlin
    - [ ] Kotlin
    - [ ] Ktor (requires Kotlin)
  - Other: <OTHER_LANGUAGES>

Language selection → generation rules
- If Java 17/21/25 is selected:
  - Apply the corresponding LTS rules and toolchains (link to the selected: rules/generative/language/java/java-17.rules.md, rules/generative/language/java/java-21.rules.md, or rules/generative/language/java/java-25.rules.md).
  - Include build integration via rules/generative/language/java/build-tooling.md.
- If Web → TypeScript is selected:
  - Include language rules link: rules/generative/language/typescript/README.md.
  - If Angular is also selected: include rules/generative/language/angular/README.md and scaffold Angular app structure when requested.
  - If React is also selected: include rules/generative/language/react/README.md and scaffold React app structure when requested.
- If Kotlin is selected:
  - Include language rules link: rules/generative/language/kotlin/README.md.
  - If Ktor is also selected, scaffold a minimal Ktor service module and wire guides accordingly.

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
    - Angular: rules/generative/language/angular/README.md
    - Angular Awesome (Angular 19+ plugin): rules/generative/frontend/angular-awesome/README.md
    - React: rules/generative/language/react/README.md
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
- Add “Prompt Language Alignment & Glossary” note:
  - Link to your library’s topic GLOSSARY.md and state that it is the authoritative, minimal glossary for this topic with LLM interpretation guidance (topic-first).
  - List any enforced aligned names (if applicable) and instruct host projects to copy only those into their root GLOSSARY.md; for all other terms, host projects should link back to your topic GLOSSARY.md/rules instead of duplicating definitions.
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
- [ ] Fluent API Strategy declared (CRTP vs Builder) and reflected in library rules/examples; Lombok usage aligned to selection
- [ ] Topic GLOSSARY.md created/updated (topic-first, minimal duplication) with LLM interpretation guidance; README includes “Prompt Language Alignment & Glossary” note linking to it
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