# Enterprise Skills Repository

Enterprise-wide AI skills catalog for AI-assisted and human development. This repository provides a versioned, canonical source of truth for reusable skills that extend AI agents (Codex, Copilot, Cursor, Junie, Claude, Roo, ChatGPT) with specialized knowledge, workflows, and tool integrations.

## Repository Structure

```text
AIRules/
|-- README.md              # repository overview and complete skill catalog
|-- skills.md              # categorized skills catalog and load order
|-- LICENSE
|-- scripts/               # repository authoring tools
`-- skills/
    |-- .curated/          # 39 general-purpose skills, including Azure access audits
    `-- .system/           # 78 ecosystem and tooling skills
        |-- activitymaster/
        |-- entityassist/
        |-- guicedee-*/    # 29 GuicedEE skills
        |-- jwebmp-*/      # 45 JWebMP skills, including website aside routing
        |-- skill-creator/
        `-- skill-installer/
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
python skills/.system/skill-creator/scripts/init_skill.py my-new-skill --path skills/.system

# Generate agents/openai.yaml metadata
python skills/.system/skill-creator/scripts/generate_openai_yaml.py skills/.system/my-new-skill
```

See `skills/.system/skill-creator/SKILL.md` for the full creation guide.

## Skill Catalogs

### Curated Skills (`.curated/`)

General-purpose skills suitable for any project:

| Skill | Description |
|-------|-------------|
| [aggrid](skills/.curated/aggrid/SKILL.md) | AG Grid MCP integration, column definitions, row models, version migrations |
| [api-integration-specialist](skills/.curated/api-integration-specialist/SKILL.md) | API integration design and implementation |
| [arm-to-terraform-migration](skills/.curated/arm-to-terraform-migration/SKILL.md) | Azure ARM template → Terraform migration |
| [azure-access-and-exposure-audit](skills/.curated/azure-access-and-exposure-audit/SKILL.md) | Azure public exposure audits, RBAC/PIM access diagnosis, and PowerShell/bash audit tools |
| [changelog-generator](skills/.curated/changelog-generator/SKILL.md) | Automated changelog generation from commits |
| [code-reviewer](skills/.curated/code-reviewer/SKILL.md) | Structured code review with checklists and diff analysis |
| [dispatching-parallel-agents](skills/.curated/dispatching-parallel-agents/SKILL.md) | Parallel agent orchestration and dispatch patterns |
| [figma](skills/.curated/figma/SKILL.md) | Figma MCP integration for design-to-code workflows |
| [finishing-a-development-branch](skills/.curated/finishing-a-development-branch/SKILL.md) | Branch completion, cleanup, and merge workflows |
| [gh-address-comments](skills/.curated/gh-address-comments/SKILL.md) | GitHub PR comment resolution |
| [gh-fix-ci](skills/.curated/gh-fix-ci/SKILL.md) | GitHub CI failure diagnosis and repair |
| [git-commit-helper](skills/.curated/git-commit-helper/SKILL.md) | Conventional commit message crafting |
| [git-commit-signing](skills/.curated/git-commit-signing/SKILL.md) | Configure and troubleshoot Git commit signing |
| [information-architect](skills/.curated/information-architect/SKILL.md) | Information architecture and content strategy |
| [playwright](skills/.curated/playwright/SKILL.md) | Playwright end-to-end test authoring |
| [screenshot](skills/.curated/screenshot/SKILL.md) | Screenshot capture and visual comparison |
| [security-best-practices](skills/.curated/security-best-practices/SKILL.md) | Language/framework-specific security reviews and reports |
| [security-compliance](skills/.curated/security-compliance/SKILL.md) | Security compliance auditing |
| [security-ownership-map](skills/.curated/security-ownership-map/SKILL.md) | Security ownership mapping |
| [senior-architect](skills/.curated/senior-architect/SKILL.md) | System design, ADRs, trade-off analysis, architecture diagrams |
| [senior-backend](skills/.curated/senior-backend/SKILL.md) | Backend engineering workflows |
| [senior-devops](skills/.curated/senior-devops/SKILL.md) | DevOps and infrastructure workflows |
| [senior-prompt-engineer](skills/.curated/senior-prompt-engineer/SKILL.md) | Prompt engineering and optimization |
| [senior-qa](skills/.curated/senior-qa/SKILL.md) | Quality assurance and test strategy |
| [senior-secops](skills/.curated/senior-secops/SKILL.md) | Security operations workflows |
| [skill-adopter](skills/.curated/skill-adopter/SKILL.md) | Adopt and wire enterprise skills into a project for any AI agent |
| [structured-skill-creator](skills/.curated/structured-skill-creator/SKILL.md) | Structured skill authoring guide |
| [systematic-debugging](skills/.curated/systematic-debugging/SKILL.md) | Systematic debugging methodology |
| [terraform-code-generator](skills/.curated/terraform-code-generator/SKILL.md) | Terraform code generation |
| [terraform-doc-generator](skills/.curated/terraform-doc-generator/SKILL.md) | Terraform documentation generation |
| [terraform-module-scaffold](skills/.curated/terraform-module-scaffold/SKILL.md) | Terraform module scaffolding |
| [terraform-plan-analyzer](skills/.curated/terraform-plan-analyzer/SKILL.md) | Terraform plan analysis |
| [terraform-project-generator](skills/.curated/terraform-project-generator/SKILL.md) | Terraform project generation |
| [terraform-resource-fetch](skills/.curated/terraform-resource-fetch/SKILL.md) | Terraform resource fetching |
| [terraform-security-scanner](skills/.curated/terraform-security-scanner/SKILL.md) | Terraform security scanning |
| [terraform-state-manager](skills/.curated/terraform-state-manager/SKILL.md) | Terraform state management |
| [terraform-validator](skills/.curated/terraform-validator/SKILL.md) | Terraform validation |
| [test-driven-development](skills/.curated/test-driven-development/SKILL.md) | Red → green → refactor TDD workflow |
| [using-git-worktrees](skills/.curated/using-git-worktrees/SKILL.md) | Git worktree workflows |

### System Skills (`.system/`)

Project-specific skills for the GuicedEE ecosystem:

| Skill | Description |
|-------|-------------|
| [activitymaster](skills/.system/activitymaster/SKILL.md) | FSDM domain services, enterprise resource management, reactive persistence |
| [entityassist](skills/.system/entityassist/SKILL.md) | CRTP entities, fluent query builder, reactive CRUD with Mutiny |
| [guicedee-auth](skills/.system/guicedee-auth/SKILL.md) | Authentication and authorization (OAuth2, JWT, ABAC, OTP, Property File, LDAP, htpasswd, htdigest) |
| [guicedee-cdi](skills/.system/guicedee-cdi/SKILL.md) | CDI integration |
| [guicedee-cerial](skills/.system/guicedee-cerial/SKILL.md) | Serial port connectivity with jSerialComm and Vert.x |
| [guicedee-client](skills/.system/guicedee-client/SKILL.md) | Runtime context, lifecycle SPI contracts, and environment configuration |
| [guicedee-cloud-app](skills/.system/guicedee-cloud-app/SKILL.md) | Multi-module cloud app scaffolding/audit (parent + BOM + service modules + observability stack) |
| [guicedee-config](skills/.system/guicedee-config/SKILL.md) | MicroProfile Config |
| [guicedee-creator](skills/.system/guicedee-creator/SKILL.md) | GuicedEE project scaffolding and baseline verification |
| [guicedee-hazelcast](skills/.system/guicedee-hazelcast/SKILL.md) | Hazelcast clustering, Vert.x cluster manager, JCache, distributed data structures |
| [guicedee-health](skills/.system/guicedee-health/SKILL.md) | MicroProfile Health |
| [guicedee-ibmmq](skills/.system/guicedee-ibmmq/SKILL.md) | IBM MQ messaging (JMS 3.0, queues, topics, transacted sessions, durable subscriptions) |
| [guicedee-inject](skills/.system/guicedee-inject/SKILL.md) | Guice DI with classpath scanning and lifecycle |
| [guicedee-installer](skills/.system/guicedee-installer/SKILL.md) | Module installation and retrofit |
| [guicedee-jpms-shade](skills/.system/guicedee-jpms-shade/SKILL.md) | Shade automatic-module JARs into JPMS service modules for the jlink pipeline |
| [guicedee-jwt](skills/.system/guicedee-jwt/SKILL.md) | MicroProfile JWT bridge, claim injection, and role-based access |
| [guicedee-kafka](skills/.system/guicedee-kafka/SKILL.md) | Kafka messaging |
| [guicedee-mail-client](skills/.system/guicedee-mail-client/SKILL.md) | SMTP mail client |
| [guicedee-metrics](skills/.system/guicedee-metrics/SKILL.md) | MicroProfile Metrics |
| [guicedee-openapi](skills/.system/guicedee-openapi/SKILL.md) | OpenAPI/Swagger integration |
| [guicedee-persistence](skills/.system/guicedee-persistence/SKILL.md) | JPA/Hibernate persistence wiring |
| [guicedee-rabbitmq](skills/.system/guicedee-rabbitmq/SKILL.md) | RabbitMQ messaging |
| [guicedee-rest](skills/.system/guicedee-rest/SKILL.md) | JAX-RS REST endpoints |
| [guicedee-rest-client](skills/.system/guicedee-rest-client/SKILL.md) | Typed REST clients using @Endpoint and Vert.x WebClient |
| [guicedee-service-registry](skills/.system/guicedee-service-registry/SKILL.md) | Named service registry with health-aware URL resolution |
| [guicedee-swagger-ui](skills/.system/guicedee-swagger-ui/SKILL.md) | Swagger UI serving |
| [guicedee-telemetry](skills/.system/guicedee-telemetry/SKILL.md) | OpenTelemetry integration |
| [guicedee-vertx](skills/.system/guicedee-vertx/SKILL.md) | Vert.x 5 event-bus, verticles, reactive wiring |
| [guicedee-web](skills/.system/guicedee-web/SKILL.md) | Web module configuration |
| [guicedee-webservices](skills/.system/guicedee-webservices/SKILL.md) | SOAP/XML web services |
| [guicedee-websockets](skills/.system/guicedee-websockets/SKILL.md) | WebSocket integration |
| [jwebmp-agcharts](skills/.system/jwebmp-agcharts/SKILL.md) | AG Charts community integration |
| [jwebmp-agcharts-enterprise](skills/.system/jwebmp-agcharts-enterprise/SKILL.md) | AG Charts enterprise visualization |
| [jwebmp-aggrid](skills/.system/jwebmp-aggrid/SKILL.md) | AG Grid community data tables |
| [jwebmp-aggrid-enterprise](skills/.system/jwebmp-aggrid-enterprise/SKILL.md) | AG Grid enterprise data grids |
| [jwebmp-angular](skills/.system/jwebmp-angular/SKILL.md) | Angular framework integration |
| [jwebmp-angular-forms](skills/.system/jwebmp-angular-forms/SKILL.md) | Angular reactive forms |
| [jwebmp-angular-graphql](skills/.system/jwebmp-angular-graphql/SKILL.md) | Apollo GraphQL client generation (@NgGraphQL) |
| [jwebmp-angular-material](skills/.system/jwebmp-angular-material/SKILL.md) | Angular Material design components |
| [jwebmp-bootstrap](skills/.system/jwebmp-bootstrap/SKILL.md) | Bootstrap CSS framework |
| [jwebmp-c3](skills/.system/jwebmp-c3/SKILL.md) | C3 D3-based charting |
| [jwebmp-chartjs](skills/.system/jwebmp-chartjs/SKILL.md) | Chart.js charting |
| [jwebmp-client](skills/.system/jwebmp-client/SKILL.md) | JWebMP client module |
| [jwebmp-core](skills/.system/jwebmp-core/SKILL.md) | JWebMP core framework (HTML, CSS, events, page configurators) |
| [jwebmp-d3](skills/.system/jwebmp-d3/SKILL.md) | D3.js data visualization |
| [jwebmp-datatables](skills/.system/jwebmp-datatables/SKILL.md) | DataTables advanced HTML tables |
| [jwebmp-easing](skills/.system/jwebmp-easing/SKILL.md) | jQuery easing animations |
| [jwebmp-easy-pie-chart](skills/.system/jwebmp-easy-pie-chart/SKILL.md) | Animated pie charts |
| [jwebmp-fontawesome](skills/.system/jwebmp-fontawesome/SKILL.md) | Font Awesome free icons |
| [jwebmp-fontawesome-pro](skills/.system/jwebmp-fontawesome-pro/SKILL.md) | Font Awesome pro icons |
| [jwebmp-fullcalendar](skills/.system/jwebmp-fullcalendar/SKILL.md) | FullCalendar community |
| [jwebmp-fullcalendar-pro](skills/.system/jwebmp-fullcalendar-pro/SKILL.md) | FullCalendar pro with advanced features |
| [jwebmp-globalize](skills/.system/jwebmp-globalize/SKILL.md) | Internationalization (i18n) |
| [jwebmp-glyph-icons](skills/.system/jwebmp-glyph-icons/SKILL.md) | Glyph icons |
| [jwebmp-jqplot](skills/.system/jwebmp-jqplot/SKILL.md) | jqPlot jQuery charting |
| [jwebmp-jquery](skills/.system/jwebmp-jquery/SKILL.md) | jQuery DOM manipulation library |
| [jwebmp-jquery-ui](skills/.system/jwebmp-jquery-ui/SKILL.md) | jQuery UI widgets and interactions |
| [jwebmp-local-storage](skills/.system/jwebmp-local-storage/SKILL.md) | Browser local storage persistence |
| [jwebmp-markdown](skills/.system/jwebmp-markdown/SKILL.md) | Markdown parsing and rendering |
| [jwebmp-material-design-icons](skills/.system/jwebmp-material-design-icons/SKILL.md) | Google Material Design icons |
| [jwebmp-material-icons](skills/.system/jwebmp-material-icons/SKILL.md) | Google Material icons |
| [jwebmp-plus-as-tab](skills/.system/jwebmp-plus-as-tab/SKILL.md) | Plus button tab navigation |
| [jwebmp-prettify](skills/.system/jwebmp-prettify/SKILL.md) | Google Prettify code highlighting |
| [jwebmp-prism](skills/.system/jwebmp-prism/SKILL.md) | Prism syntax highlighting |
| [jwebmp-session-storage](skills/.system/jwebmp-session-storage/SKILL.md) | Browser session storage |
| [jwebmp-skycons](skills/.system/jwebmp-skycons/SKILL.md) | Animated weather icons |
| [jwebmp-themify-icons](skills/.system/jwebmp-themify-icons/SKILL.md) | Themify icon fonts |
| [jwebmp-toastr](skills/.system/jwebmp-toastr/SKILL.md) | Toast notification alerts |
| [jwebmp-tsclient](skills/.system/jwebmp-tsclient/SKILL.md) | TypeScript client code generation |
| [jwebmp-vertx](skills/.system/jwebmp-vertx/SKILL.md) | JWebMP Vert.x event bus runtime |
| [jwebmp-waves-effect](skills/.system/jwebmp-waves-effect/SKILL.md) | Material Design ripple effects |
| [jwebmp-waypoints](skills/.system/jwebmp-waypoints/SKILL.md) | Scroll-triggered callbacks |
| [jwebmp-weather-icons](skills/.system/jwebmp-weather-icons/SKILL.md) | Weather icon fonts |
| [jwebmp-webawesome](skills/.system/jwebmp-webawesome/SKILL.md) | Web Awesome community components |
| [jwebmp-webawesome-pro](skills/.system/jwebmp-webawesome-pro/SKILL.md) | Web Awesome pro web components |
| [jwebmp-website-aside-routing](skills/.system/jwebmp-website-aside-routing/SKILL.md) | WaPage named aside outlets, route synchronization, and empty-aside layout collapse |
| [skill-creator](skills/.system/skill-creator/SKILL.md) | Creating and updating skills with proper anatomy |
| [skill-installer](skills/.system/skill-installer/SKILL.md) | Installing skills from curated lists or GitHub repos |

## Refreshing from global skills

The 2026-09-12 refresh imports changes to 26 existing skills and adds
`azure-access-and-exposure-audit` and `jwebmp-website-aside-routing` from the global
`~/.agents/skills/` collection. The repository now contains **117 skills: 39 curated
and 78 system**. ActivityMaster lifecycle/resource guidance, GuicedEE runtime and
REST contracts, EntityAssist session guidance, and WebAwesome component APIs are
included in the refresh.

For subsequent updates, compare the global skill folders with this checkout by
skill name. Keep existing tier assignments; put general-purpose additions in
`.curated/` and ecosystem-specific additions in `.system/`. Copy each changed skill
with its references, scripts, assets, and agent metadata. Preserve repository-only
skills, and exclude caches and generated output. Update both catalogs and validate
frontmatter and local links. Run bundled script checks without invoking live cloud
operations. Keep bash scripts as LF without a BOM, as specified by the Azure skill's
`.gitattributes`.

The global installation is the input to this refresh; updating this checkout does
not install skills into agent profiles or publish changes upstream.

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
