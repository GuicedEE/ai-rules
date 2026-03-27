# Enterprise Skills Repository

Enterprise-wide AI skills catalog for AI-assisted and human development. This repository provides a versioned, canonical source of truth for reusable skills that extend AI agents (Codex, Copilot, Cursor, Junie, Claude, Roo, ChatGPT) with specialized knowledge, workflows, and tool integrations.

## Repository Structure

```
AIRules/
├── README.md              ← you are here
├── skills.md              ← pinned skills catalog and load-order
├── LICENSE
└── skills/
    ├── .curated/          ← general-purpose, community-quality skills
    │   ├── aggrid/
    │   ├── api-integration-specialist/
    │   ├── arm-to-terraform-migration/
    │   ├── changelog-generator/
    │   ├── code-reviewer/
    │   ├── dispatching-parallel-agents/
    │   ├── figma/
    │   ├── finishing-a-development-branch/
    │   ├── gh-address-comments/
    │   ├── gh-fix-ci/
    │   ├── git-commit-helper/
    │   ├── information-architect/
    │   ├── playwright/
    │   ├── screenshot/
    │   ├── security-best-practices/
    │   ├── security-compliance/
    │   ├── security-ownership-map/
    │   ├── senior-architect/
    │   ├── senior-backend/
    │   ├── senior-devops/
    │   ├── senior-prompt-engineer/
    │   ├── senior-qa/
    │   ├── senior-secops/
    │   ├── skill-adopter/
    │   ├── structured-skill-creator/
    │   ├── systematic-debugging/
    │   ├── terraform-*/          (9 terraform skills)
    │   ├── test-driven-development/
    │   └── using-git-worktrees/
    └── .system/           ← project-specific skills for GuicedEE / JWebMP / ActivityMaster
        ├── activitymaster/
        ├── entityassist/
        ├── guicedee-*/           (18 guicedee skills)
        ├── jwebmp-*/             (16 jwebmp skills)
        ├── skill-creator/
        └── skill-installer/
```

### Skill anatomy

Every skill is a self-contained folder with a required `SKILL.md` and optional bundled resources:

```
skill-name/
├── SKILL.md              (required — YAML frontmatter + Markdown instructions)
├── agents/               (recommended — UI metadata)
│   └── openai.yaml
├── references/           (optional — domain docs loaded on demand)
├── scripts/              (optional — executable automation)
└── assets/               (optional — icons, templates, etc.)
```

## Enterprise Usage

### Consuming as a Git submodule

```bash
git submodule add https://github.com/GuicedEE/ai-rules.git rules/
git submodule update --init --recursive
```

Host projects reference skills from the submodule. Do not place project-specific artifacts inside the submodule directory.

### Installing individual skills (Codex / CLI)

Use the **skill-installer** skill to install skills into `$CODEX_HOME/skills/`:

```bash
# List available skills (curated from both OpenAI and GuicedEE sources)
python skills/.system/skill-installer/scripts/list-skills.py

# Install a curated skill by name
python skills/.system/skill-installer/scripts/install-skill-from-defaults.py senior-architect

# Install from any GitHub repo
python skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo GuicedEE/ai-rules --path skills/.curated/figma
```

### Creating new skills

Use the **skill-creator** skill for guided skill authoring:

```bash
# Bootstrap a new skill skeleton
python skills/.system/skill-creator/scripts/init_skill.py my-new-skill

# Generate agents/openai.yaml metadata
python skills/.system/skill-creator/scripts/generate_openai_yaml.py my-new-skill
```

See `skills/.system/skill-creator/SKILL.md` for the full creation guide.

## Skill Catalogs

### Curated Skills (`.curated/`)

General-purpose skills suitable for any project:

| Skill | Description |
|-------|-------------|
| `aggrid` | AG Grid MCP integration for React, Angular, Vue, and vanilla JS |
| `api-integration-specialist` | API integration design and implementation |
| `arm-to-terraform-migration` | Azure ARM → Terraform migration workflows |
| `changelog-generator` | Automated changelog generation |
| `code-reviewer` | Structured code review with checklists |
| `dispatching-parallel-agents` | Parallel agent orchestration patterns |
| `figma` | Figma MCP integration for design-to-code |
| `finishing-a-development-branch` | Branch completion and merge workflows |
| `gh-address-comments` | GitHub PR comment resolution |
| `gh-fix-ci` | GitHub CI failure diagnosis and repair |
| `git-commit-helper` | Conventional commit message crafting |
| `information-architect` | Information architecture and content strategy |
| `playwright` | Playwright end-to-end test authoring |
| `screenshot` | Screenshot capture and comparison |
| `security-best-practices` | Language/framework-specific security reviews |
| `security-compliance` | Security compliance auditing |
| `security-ownership-map` | Security ownership mapping |
| `senior-architect` | System design, ADRs, and architecture diagrams |
| `senior-backend` | Backend engineering workflows |
| `senior-devops` | DevOps and infrastructure workflows |
| `senior-prompt-engineer` | Prompt engineering and optimization |
| `senior-qa` | Quality assurance and test strategy |
| `senior-secops` | Security operations workflows |
| `skill-adopter` | Adopt and wire enterprise skills into a project for any AI agent |
| `structured-skill-creator` | Structured skill authoring guide |
| `systematic-debugging` | Systematic debugging methodology |
| `terraform-*` | Terraform code gen, docs, modules, plans, security, state, validation |
| `test-driven-development` | Red → green → refactor TDD workflow |
| `using-git-worktrees` | Git worktree workflows |

### System Skills (`.system/`)

Project-specific skills for the GuicedEE ecosystem:

| Skill | Description |
|-------|-------------|
| `activitymaster` | FSDM enterprise resource management platform |
| `entityassist` | Reactive persistence with Hibernate Reactive 7 and Mutiny |
| `guicedee-cdi` | CDI integration for GuicedEE |
| `guicedee-cerial` | Serialization framework |
| `guicedee-client` | HTTP client integration |
| `guicedee-config` | MicroProfile Config integration |
| `guicedee-creator` | GuicedEE project scaffolding |
| `guicedee-health` | MicroProfile Health integration |
| `guicedee-inject` | Guice DI with classpath scanning |
| `guicedee-installer` | Module installation and retrofit |
| `guicedee-metrics` | MicroProfile Metrics integration |
| `guicedee-openapi` | OpenAPI/Swagger integration |
| `guicedee-persistence` | JPA/Hibernate persistence wiring |
| `guicedee-rabbitmq` | RabbitMQ messaging integration |
| `guicedee-rest` | JAX-RS REST endpoint wiring |
| `guicedee-rest-client` | MicroProfile REST Client |
| `guicedee-swagger-ui` | Swagger UI serving |
| `guicedee-telemetry` | OpenTelemetry integration |
| `guicedee-vertx` | Vert.x 5 event-bus, verticles, and reactive wiring |
| `guicedee-web` | Web module configuration |
| `guicedee-webservices` | SOAP/XML web services |
| `guicedee-websockets` | WebSocket integration |
| `jwebmp-agcharts` | AG Charts community integration |
| `jwebmp-agcharts-enterprise` | AG Charts enterprise integration |
| `jwebmp-aggrid-enterprise` | AG Grid enterprise integration |
| `jwebmp-angular` | Angular integration for JWebMP |
| `jwebmp-chartjs` | Chart.js integration |
| `jwebmp-client` | JWebMP client module |
| `jwebmp-core` | JWebMP core framework (HTML, CSS, events) |
| `jwebmp-easing` | jQuery easing animations |
| `jwebmp-fontawesome` | Font Awesome free icons |
| `jwebmp-fontawesome-pro` | Font Awesome pro icons |
| `jwebmp-fullcalendar` | FullCalendar community integration |
| `jwebmp-fullcalendar-pro` | FullCalendar pro integration |
| `jwebmp-tsclient` | TypeScript client generation |
| `jwebmp-vertx` | JWebMP Vert.x runtime |
| `jwebmp-webawesome` | Web Awesome community components |
| `jwebmp-webawesome-pro` | Web Awesome pro components |
| `skill-creator` | Skill authoring guide and scaffolding scripts |
| `skill-installer` | Skill installation from defaults or GitHub |

## Principles

### 🧭 Continuity
We carry context across threads. We remember conventions and tone. We pick up where we left off.

### 🧩 Finesse
We refine outputs iteratively. We respect nuance — less brute-forcing, more shaping. We preserve language, structure, and intent.

### 🌿 Collaborative Flow
This is not a question-answer transaction. It's a collaborative design conversation that grows over time.

### 🔁 Closing Loops
Every artifact links forward (to implementation) and backward (to its reasoning). We don't leave threads dangling.

## Forward-Only Change Policy

- Apply requested changes in full: update/remove conflicting documents, indexes, and links in the same change.
- Do not leave stubs or partial updates; provide complete, final artifacts.
- Only maintain backwards compatibility if the request explicitly requires it.

## Structure of Work

| Layer | Description | Artifact |
|-------|-------------|----------|
| Skills | Modular, self-contained domain knowledge | `skills/` |
| References | Supporting docs loaded on demand | `skills/**/references/` |
| Scripts | Executable automation bundled with skills | `skills/**/scripts/` |

### Host project setup

- **Skills** — Install relevant skills via `skill-installer` or reference the submodule directly.
- **Agent configs** — Use `skill-adopter` to generate agent-native configuration files for your AI tools.
- **Project docs** — Place project-specific documentation outside the submodule (e.g., under `docs/`).

## Docs-as-Code Diagrams Policy

All projects should maintain text-based architecture diagrams that are reviewable by humans and consumable by AI:

- **C4 Architecture**: L1 (Context), L2 (Container), L3 (Component). L4 optional.
- **Sequence Diagrams**: Critical flows including async boundaries.
- **ERDs**: Core domain models, relationships, bounded context ownership.
- **Deployment/Runtime**: Topology, environments, infrastructure.

Use Mermaid in fenced Markdown blocks. Commit diagram sources — images are optional derivatives.

## Usage Tips

- Ask: "What skills are available?" to list discovered skills.
- Use `skill-installer` to browse and install skills interactively.
- Use `skill-creator` to author new skills following the standard anatomy.
- Each skill's `SKILL.md` frontmatter (`name` + `description`) determines when the skill triggers.
- Skill instructions (body) are loaded only after activation.

## Notes

- Keep skills focused and concise — the context window is shared with everything else.
- Use lowercase-hyphen names for skill directories.
- Each skill must have valid YAML frontmatter with `name` and `description`.
- Prefer relative links within skills.
