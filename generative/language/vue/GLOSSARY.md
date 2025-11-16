# Vue Glossary (Topic-Scoped)

Canonical terms for Vue 3 projects. Topic precedence: entries here override root glossary for Vue scope.

- **Single File Component (SFC)** — `.vue` file with `<template>`, `<script setup>` or `<script>`, and `<style>` blocks; enforce `<script setup>` for Composition API-first scaffolds.
- **Composition API** — Core APIs (`ref`, `reactive`, `computed`, `watch`, `provide/inject`) used inside `<script setup>` blocks; prefer for new code to enable strong typing and tree-shaking.
- **Options API** — Legacy component definition via `export default { data, methods }`; only use when migrating older code or when plugin constraints require it.
- **Reactive State Module** — Encapsulated store built with Pinia or Vue's reactivity primitives; exposes typed getters/actions instead of mutating shared refs inline.
- **Lifecycle Hooks** — Vue-provided functions such as `onMounted`, `onBeforeUnmount`, `onErrorCaptured`; wrap async effects inside hooks and unregister listeners in cleanup callbacks.
- **Teleport** — `<teleport>` component for rendering content outside the parent DOM tree (e.g., modals); always scope teleport targets inside the same app root to avoid hydration drift.
- **Nuxt Page** — File-based route under `pages/` inside a Nuxt project; each file becomes a route with server/client lifecycle hooks.
- **Composable** — Reusable function encapsulating state/effects (e.g., `useUserProfile`); returned references must be typed and documented; treat as part of Composition API module library.

LLM guidance
- Always specify whether a snippet uses `<script setup>` or standard `<script>`.
- Prefer `defineProps`/`defineEmits` macros for props/events; align prop names with glossary terms.
- When referencing Nuxt features, defer to Nuxt topic and keep Vue content framework-agnostic.
