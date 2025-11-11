# Using Web Components in Next.js (Modular)

Purpose
- Document how to consume native Custom Elements within Next.js (App Router) and handle SSR boundaries.

Key rules
- Register custom elements only on the client; avoid executing customElements.define during SSR.
- Prefer dynamic import with ssr: false for client-only wrappers.
- For TSX typing, extend JSX.IntrinsicElements to add custom tag props.

Client-only wrapper example
```tsx
// app/components/ui-button-client.tsx
'use client';
import React, { useEffect, useRef } from 'react';

export function UIButtonClient(props: { onConfirm?: (e: CustomEvent<{ id: string }>) => void }) {
  const ref = useRef<HTMLElement>(null);
  useEffect(() => {
    const el = ref.current;
    if (!el || !props.onConfirm) return;
    const handler = (e: Event) => props.onConfirm!(e as CustomEvent<{ id: string }>);
    el.addEventListener('confirm', handler as any);
    return () => el.removeEventListener('confirm', handler as any);
  }, [props.onConfirm]);
  return <ui-button ref={ref as any}>Confirm</ui-button>;
}
```

Usage in a Server Component via dynamic import
```tsx
// app/page.tsx
import dynamic from 'next/dynamic';
const UIButton = dynamic(() => import('./components/ui-button-client').then(m => m.UIButtonClient), { ssr: false });

export default async function Page() {
  return <UIButton onConfirm={(e) => console.log(e.detail.id)} />;
}
```

Typing for custom elements
```ts
// src/types/custom-elements.d.ts
declare namespace JSX {
  interface IntrinsicElements {
    'ui-button': React.DetailedHTMLProps<React.HTMLAttributes<HTMLElement>, HTMLElement> & {
      variant?: 'solid' | 'outline';
    };
  }
}
```

Cross-links
- Web Components core — ../webcomponents/README.md
- React Web Components — ../react/react-web-components.md
- Next.js overview — ./nextjs-overview.md
