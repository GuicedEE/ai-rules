# Using Web Components in React (Modular)

Purpose
- How to consume native Custom Elements inside React apps with correct typing and event handling.

Key rules
- Prefer native Custom Elements; avoid wrapper re-implementations when possible.
- Register elements once at app bootstrap (ES modules side-effect import).
- For TypeScript JSX typing, add intrinsic element declarations for custom tags.
- For CustomEvent payloads, use event.detail and narrow types explicitly.

Setup
1) Import/register your custom elements (usually once):
```ts
// e.g., src/web-components.ts
import '@acme/ui-button';
```

2) Tell TSX about the custom element (global JSX IntrinsicElements):
```ts
// src/types/custom-elements.d.ts
declare namespace JSX {
  interface IntrinsicElements {
    'ui-button': React.DetailedHTMLProps<React.HTMLAttributes<HTMLElement>, HTMLElement> & {
      variant?: 'solid' | 'outline';
      disabled?: boolean;
    };
  }
}
```

3) Handle CustomEvent in React:
```tsx
function Page() {
  const onConfirm = (e: Event) => {
    const ce = e as CustomEvent<{ id: string }>;
    console.log(ce.detail.id);
  };
  return <ui-button onClick={onConfirm} variant="solid">Confirm</ui-button>;
}
```

Notes
- Some libraries fire CustomEvent for custom interactions; React’s synthetic events may not type-narrow. Cast carefully or attach native listeners via refs.
- For complex event contracts, define a typed wrapper component that attaches addEventListener/removeEventListener in useEffect.

Cross-links
- Web Components core — ../webcomponents/README.md
- Angular 20 consuming web components — ../webcomponents/angular20-consuming-web-components.md
- React overview — ./react-overview.md
- Next.js specific integration — ../nextjs/nextjs-web-components.md
