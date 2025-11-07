# React Overview (Modular)

Purpose
- Provide a concise, AI-friendly overview of modern React used in enterprise apps.

Key points
- Prefer Function Components with Hooks; avoid legacy class components.
- State management: start with React context + reducers; consider Redux Toolkit, Zustand, or Jotai for complex/shared state.
- Styling: CSS Modules, Tailwind, or CSS-in-JS with restraint. Prefer framework/tooling standards of the host project.
- Forms: React Hook Form for performance and DX.
- Data fetching: prefer framework-level solutions when available (e.g., Next.js server components/fetch), otherwise use react-query (TanStack Query).
- Routing: use the host framework (e.g., Next.js App Router) or React Router for SPA setups.
- Testing: React Testing Library with Jest/Vitest. Keep tests behavior-focused.

Cross-links
- Web Components integration — ./react-web-components.md
- SSR choices with or without Next.js — ./react-ssr-options.md
- Frontend category index — ../README.md
