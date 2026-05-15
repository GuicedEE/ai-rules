# Skills Catalog

Pinned skills catalog for the enterprise skills repository. This file provides the canonical index and load-order for all skills in the repository.

## Repository Layout

Skills are organized into two tiers:

- **`skills/.curated/`** — General-purpose, community-quality skills suitable for any project.
- **`skills/.system/`** — Project-specific skills for the GuicedEE / JWebMP / ActivityMaster ecosystem.

Each skill is a self-contained folder with a required `SKILL.md` (YAML frontmatter + Markdown instructions) and optional `agents/`, `references/`, `scripts/`, and `assets/` subdirectories.

## Load Order

1. Identify the task scope and select relevant skills from the catalogs below.
2. Load the selected skill's `SKILL.md` — frontmatter triggers activation; body provides instructions.
3. Load `references/` files only when the skill instructions call for them.

Fallback rule (mandatory):
- If runtime skill discovery does not return skills, open skill files directly from this catalog; do not proceed with unguided/direct implementation.
- Keep implementation library-first under fallback: use concrete APIs/contracts from selected skill references before introducing new interfaces.

## Curated Skills

General-purpose skills available to any project:

| Skill | Path | Use for |
|-------|------|---------|
| `aggrid` | `skills/.curated/aggrid/SKILL.md` | AG Grid MCP integration, column definitions, row models, version migrations |
| `api-integration-specialist` | `skills/.curated/api-integration-specialist/SKILL.md` | API integration design and implementation |
| `arm-to-terraform-migration` | `skills/.curated/arm-to-terraform-migration/SKILL.md` | Azure ARM template → Terraform migration |
| `changelog-generator` | `skills/.curated/changelog-generator/SKILL.md` | Automated changelog generation from commits |
| `code-reviewer` | `skills/.curated/code-reviewer/SKILL.md` | Structured code review with checklists and diff analysis |
| `dispatching-parallel-agents` | `skills/.curated/dispatching-parallel-agents/SKILL.md` | Parallel agent orchestration and dispatch patterns |
| `figma` | `skills/.curated/figma/SKILL.md` | Figma MCP integration for design-to-code workflows |
| `finishing-a-development-branch` | `skills/.curated/finishing-a-development-branch/SKILL.md` | Branch completion, cleanup, and merge workflows |
| `gh-address-comments` | `skills/.curated/gh-address-comments/SKILL.md` | GitHub PR comment resolution |
| `gh-fix-ci` | `skills/.curated/gh-fix-ci/SKILL.md` | GitHub CI failure diagnosis and repair |
| `git-commit-helper` | `skills/.curated/git-commit-helper/SKILL.md` | Conventional commit message crafting |
| `information-architect` | `skills/.curated/information-architect/SKILL.md` | Information architecture and content strategy |
| `playwright` | `skills/.curated/playwright/SKILL.md` | Playwright end-to-end test authoring |
| `screenshot` | `skills/.curated/screenshot/SKILL.md` | Screenshot capture and visual comparison |
| `security-best-practices` | `skills/.curated/security-best-practices/SKILL.md` | Language/framework-specific security reviews and reports |
| `security-compliance` | `skills/.curated/security-compliance/SKILL.md` | Security compliance auditing |
| `security-ownership-map` | `skills/.curated/security-ownership-map/SKILL.md` | Security ownership mapping |
| `senior-architect` | `skills/.curated/senior-architect/SKILL.md` | System design, ADRs, trade-off analysis, architecture diagrams |
| `senior-backend` | `skills/.curated/senior-backend/SKILL.md` | Backend engineering workflows |
| `senior-devops` | `skills/.curated/senior-devops/SKILL.md` | DevOps and infrastructure workflows |
| `senior-prompt-engineer` | `skills/.curated/senior-prompt-engineer/SKILL.md` | Prompt engineering and optimization |
| `senior-qa` | `skills/.curated/senior-qa/SKILL.md` | Quality assurance and test strategy |
| `senior-secops` | `skills/.curated/senior-secops/SKILL.md` | Security operations workflows |
| `skill-adopter` | `skills/.curated/skill-adopter/SKILL.md` | Adopt and wire enterprise skills into a project for any AI agent |
| `structured-skill-creator` | `skills/.curated/structured-skill-creator/SKILL.md` | Structured skill authoring guide |
| `systematic-debugging` | `skills/.curated/systematic-debugging/SKILL.md` | Systematic debugging methodology |
| `terraform-code-generator` | `skills/.curated/terraform-code-generator/SKILL.md` | Terraform code generation |
| `terraform-doc-generator` | `skills/.curated/terraform-doc-generator/SKILL.md` | Terraform documentation generation |
| `terraform-module-scaffold` | `skills/.curated/terraform-module-scaffold/SKILL.md` | Terraform module scaffolding |
| `terraform-plan-analyzer` | `skills/.curated/terraform-plan-analyzer/SKILL.md` | Terraform plan analysis |
| `terraform-project-generator` | `skills/.curated/terraform-project-generator/SKILL.md` | Terraform project generation |
| `terraform-resource-fetch` | `skills/.curated/terraform-resource-fetch/SKILL.md` | Terraform resource fetching |
| `terraform-security-scanner` | `skills/.curated/terraform-security-scanner/SKILL.md` | Terraform security scanning |
| `terraform-state-manager` | `skills/.curated/terraform-state-manager/SKILL.md` | Terraform state management |
| `terraform-validator` | `skills/.curated/terraform-validator/SKILL.md` | Terraform validation |
| `test-driven-development` | `skills/.curated/test-driven-development/SKILL.md` | Red → green → refactor TDD workflow |
| `using-git-worktrees` | `skills/.curated/using-git-worktrees/SKILL.md` | Git worktree workflows |

## System Skills

Project-specific skills for the GuicedEE / JWebMP / ActivityMaster ecosystem:

### Platform & Tooling

| Skill | Path | Use for |
|-------|------|---------|
| `skill-creator` | `skills/.system/skill-creator/SKILL.md` | Creating and updating skills with proper anatomy |
| `skill-installer` | `skills/.system/skill-installer/SKILL.md` | Installing skills from curated lists or GitHub repos |

### ActivityMaster & EntityAssist

| Skill | Path | Use for |
|-------|------|---------|
| `activitymaster` | `skills/.system/activitymaster/SKILL.md` | FSDM domain services, enterprise resource management, reactive persistence |
| `entityassist` | `skills/.system/entityassist/SKILL.md` | CRTP entities, fluent query builder, reactive CRUD with Mutiny |

### GuicedEE

| Skill | Path | Use for |
|-------|------|---------|
| `guicedee-auth` | `skills/.system/guicedee-auth/SKILL.md` | Authentication and authorization (OAuth2, JWT, ABAC, OTP, Property File, LDAP, htpasswd, htdigest) |
| `guicedee-cdi` | `skills/.system/guicedee-cdi/SKILL.md` | CDI integration |
| `guicedee-cerial` | `skills/.system/guicedee-cerial/SKILL.md` | Serialization framework |
| `guicedee-client` | `skills/.system/guicedee-client/SKILL.md` | HTTP client integration |
| `guicedee-config` | `skills/.system/guicedee-config/SKILL.md` | MicroProfile Config |
| `guicedee-creator` | `skills/.system/guicedee-creator/SKILL.md` | GuicedEE project scaffolding and baseline verification |
| `guicedee-health` | `skills/.system/guicedee-health/SKILL.md` | MicroProfile Health |
| `guicedee-inject` | `skills/.system/guicedee-inject/SKILL.md` | Guice DI with classpath scanning and lifecycle |
| `guicedee-installer` | `skills/.system/guicedee-installer/SKILL.md` | Module installation and retrofit |
| `guicedee-metrics` | `skills/.system/guicedee-metrics/SKILL.md` | MicroProfile Metrics |
| `guicedee-openapi` | `skills/.system/guicedee-openapi/SKILL.md` | OpenAPI/Swagger integration |
| `guicedee-persistence` | `skills/.system/guicedee-persistence/SKILL.md` | JPA/Hibernate persistence wiring |
| `guicedee-kafka` | `skills/.system/guicedee-kafka/SKILL.md` | Kafka messaging |
| `guicedee-hazelcast` | `skills/.system/guicedee-hazelcast/SKILL.md` | Hazelcast clustering, Vert.x cluster manager, JCache, distributed data structures |
| `guicedee-ibmmq` | `skills/.system/guicedee-ibmmq/SKILL.md` | IBM MQ messaging (JMS 3.0, queues, topics, transacted sessions, durable subscriptions) |
| `guicedee-mail-client` | `skills/.system/guicedee-mail-client/SKILL.md` | SMTP mail client |
| `guicedee-rabbitmq` | `skills/.system/guicedee-rabbitmq/SKILL.md` | RabbitMQ messaging |
| `guicedee-rest` | `skills/.system/guicedee-rest/SKILL.md` | JAX-RS REST endpoints |
| `guicedee-rest-client` | `skills/.system/guicedee-rest-client/SKILL.md` | MicroProfile REST Client |
| `guicedee-swagger-ui` | `skills/.system/guicedee-swagger-ui/SKILL.md` | Swagger UI serving |
| `guicedee-telemetry` | `skills/.system/guicedee-telemetry/SKILL.md` | OpenTelemetry integration |
| `guicedee-vertx` | `skills/.system/guicedee-vertx/SKILL.md` | Vert.x 5 event-bus, verticles, reactive wiring |
| `guicedee-web` | `skills/.system/guicedee-web/SKILL.md` | Web module configuration |
| `guicedee-webservices` | `skills/.system/guicedee-webservices/SKILL.md` | SOAP/XML web services |
| `guicedee-websockets` | `skills/.system/guicedee-websockets/SKILL.md` | WebSocket integration |

### JWebMP

#### Core & Foundation

| Skill | Path | Use for |
|-------|------|---------|
| `jwebmp-core` | `skills/.system/jwebmp-core/SKILL.md` | JWebMP core framework (HTML, CSS, events, page configurators) |
| `jwebmp-client` | `skills/.system/jwebmp-client/SKILL.md` | JWebMP client module |
| `jwebmp-vertx` | `skills/.system/jwebmp-vertx/SKILL.md` | JWebMP Vert.x event bus runtime |
| `jwebmp-tsclient` | `skills/.system/jwebmp-tsclient/SKILL.md` | TypeScript client code generation |

#### Data & Analytics

| Skill | Path | Use for |
|-------|------|---------|
| `jwebmp-aggrid` | `skills/.system/jwebmp-aggrid/SKILL.md` | AG Grid community data tables |
| `jwebmp-aggrid-enterprise` | `skills/.system/jwebmp-aggrid-enterprise/SKILL.md` | AG Grid enterprise data grids |
| `jwebmp-agcharts` | `skills/.system/jwebmp-agcharts/SKILL.md` | AG Charts community integration |
| `jwebmp-agcharts-enterprise` | `skills/.system/jwebmp-agcharts-enterprise/SKILL.md` | AG Charts enterprise visualization |
| `jwebmp-chartjs` | `skills/.system/jwebmp-chartjs/SKILL.md` | Chart.js charting |
| `jwebmp-c3` | `skills/.system/jwebmp-c3/SKILL.md` | C3 D3-based charting |
| `jwebmp-d3` | `skills/.system/jwebmp-d3/SKILL.md` | D3.js data visualization |
| `jwebmp-datatables` | `skills/.system/jwebmp-datatables/SKILL.md` | DataTables advanced HTML tables |
| `jwebmp-jqplot` | `skills/.system/jwebmp-jqplot/SKILL.md` | jqPlot jQuery charting |
| `jwebmp-easy-pie-chart` | `skills/.system/jwebmp-easy-pie-chart/SKILL.md` | Animated pie charts |

#### UI Frameworks & Components

| Skill | Path | Use for |
|-------|------|---------|
| `jwebmp-angular` | `skills/.system/jwebmp-angular/SKILL.md` | Angular framework integration |
| `jwebmp-angular-forms` | `skills/.system/jwebmp-angular-forms/SKILL.md` | Angular reactive forms |
| `jwebmp-angular-material` | `skills/.system/jwebmp-angular-material/SKILL.md` | Angular Material design components |
| `jwebmp-bootstrap` | `skills/.system/jwebmp-bootstrap/SKILL.md` | Bootstrap CSS framework |
| `jwebmp-webawesome` | `skills/.system/jwebmp-webawesome/SKILL.md` | Web Awesome community components |
| `jwebmp-webawesome-pro` | `skills/.system/jwebmp-webawesome-pro/SKILL.md` | Web Awesome pro web components |

#### Calendars & Scheduling

| Skill | Path | Use for |
|-------|------|---------|
| `jwebmp-fullcalendar` | `skills/.system/jwebmp-fullcalendar/SKILL.md` | FullCalendar community |
| `jwebmp-fullcalendar-pro` | `skills/.system/jwebmp-fullcalendar-pro/SKILL.md` | FullCalendar pro with advanced features |

#### Icons & Typography

| Skill | Path | Use for |
|-------|------|---------|
| `jwebmp-fontawesome` | `skills/.system/jwebmp-fontawesome/SKILL.md` | Font Awesome free icons |
| `jwebmp-fontawesome-pro` | `skills/.system/jwebmp-fontawesome-pro/SKILL.md` | Font Awesome pro icons |
| `jwebmp-material-design-icons` | `skills/.system/jwebmp-material-design-icons/SKILL.md` | Google Material Design icons |
| `jwebmp-material-icons` | `skills/.system/jwebmp-material-icons/SKILL.md` | Google Material icons |
| `jwebmp-glyph-icons` | `skills/.system/jwebmp-glyph-icons/SKILL.md` | Glyph icons |
| `jwebmp-themify-icons` | `skills/.system/jwebmp-themify-icons/SKILL.md` | Themify icon fonts |
| `jwebmp-weather-icons` | `skills/.system/jwebmp-weather-icons/SKILL.md` | Weather icon fonts |
| `jwebmp-skycons` | `skills/.system/jwebmp-skycons/SKILL.md` | Animated weather icons |

#### Library Foundations

| Skill | Path | Use for |
|-------|------|---------|
| `jwebmp-jquery` | `skills/.system/jwebmp-jquery/SKILL.md` | jQuery DOM manipulation library |
| `jwebmp-jquery-ui` | `skills/.system/jwebmp-jquery-ui/SKILL.md` | jQuery UI widgets and interactions |
| `jwebmp-easing` | `skills/.system/jwebmp-easing/SKILL.md` | jQuery easing animations |

#### Client-Side Storage & Effects

| Skill | Path | Use for |
|-------|------|---------|
| `jwebmp-local-storage` | `skills/.system/jwebmp-local-storage/SKILL.md` | Browser local storage persistence |
| `jwebmp-session-storage` | `skills/.system/jwebmp-session-storage/SKILL.md` | Browser session storage |
| `jwebmp-waves-effect` | `skills/.system/jwebmp-waves-effect/SKILL.md` | Material Design ripple effects |

#### Utilities & Enhancements

| Skill | Path | Use for |
|-------|------|---------|
| `jwebmp-markdown` | `skills/.system/jwebmp-markdown/SKILL.md` | Markdown parsing and rendering |
| `jwebmp-toastr` | `skills/.system/jwebmp-toastr/SKILL.md` | Toast notification alerts |
| `jwebmp-prism` | `skills/.system/jwebmp-prism/SKILL.md` | Prism syntax highlighting |
| `jwebmp-prettify` | `skills/.system/jwebmp-prettify/SKILL.md` | Google Prettify code highlighting |
| `jwebmp-globalize` | `skills/.system/jwebmp-globalize/SKILL.md` | Internationalization (i18n) |
| `jwebmp-waypoints` | `skills/.system/jwebmp-waypoints/SKILL.md` | Scroll-triggered callbacks |
| `jwebmp-plus-as-tab` | `skills/.system/jwebmp-plus-as-tab/SKILL.md` | Plus button tab navigation |
