# JWebMP — Topic Index (Frontend Wrappers)

Use this topic when you are working with JWebMP wrappers and integrations in frontend scenarios. These guides complement framework-agnostic Web Components and the WebAwesome component library.

Important policy for generators and maintainers (JWebMP projects):
- Do not touch or propose edits to generated artifacts (build outputs) such as compiled TypeScript, HTML, or site bundles. Treat generated files as read-only and ephemeral.
- We no longer generate or reference separate TS/HTML components for missing views. Dialogs, tables, and similar UI for cases like "missing graders stations" must be rendered directly from Java (JWebMP) within the relevant cell renderers or page/component classes.
- If Angular/TypeScript generation is enabled for a project, the generated TS is a build output only. Do not hand-edit it; make changes in Java sources that feed the generator.
- Avoid inline string HTML in Java. Always express markup using JWebMP components (Div, Paragraph, Span, Table, H1–H6, etc.).
- **CRTP Pattern**: All JWebMP components use CRTP (`Component<J extends Component<J>>`) and are intentionally extensible (never `final`) to enable type-safe client customization.

Guides
- JWebMP AI Guide — ./jwebmp_ai_guide.md
- JWebMP Angular Integration (TypeScript generation) — ./jwebmp_angular_ai_guide.md

See also
- Group: Frontend → Standard — ../README.md
- WebAwesome components index — ../webawesome/README.md
- Web Components — ../webcomponents/README.md
- Frontend category index — ../README.md