# Next.js Security (App Router) — Modular

Purpose
- Provide a concise, copy-paste friendly security hardening checklist for modern Next.js (App Router, Server Components) with minimal, safe defaults.

Scope
- Applies to Next.js 13+ App Router projects using Server Components by default. Patterns note where Client Components or middleware are required.

Core principles
- Server-first: keep secrets and validation in Server Components, Route Handlers, and Server Actions.
- Least privilege: expose only what the client needs; never leak secrets via NEXT_PUBLIC.
- Deny by default: validate inputs, origins, and destinations; set strict headers and cookies.
- Cache consciously: do not cache personalized or sensitive data; scope revalidation carefully.

1) HTTP security headers (recommended baseline)
- Set strict-transport-security, x-content-type-options, x-frame-options, referrer-policy. Use a CSP with nonces for scripts and styles.

Example middleware adding security headers
```ts
// middleware.ts (at project root)
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(req: NextRequest) {
  const res = NextResponse.next();

  res.headers.set('strict-transport-security', 'max-age=63072000; includeSubDomains; preload');
  res.headers.set('x-content-type-options', 'nosniff');
  res.headers.set('x-frame-options', 'DENY');
  res.headers.set('referrer-policy', 'no-referrer');

  // Content Security Policy — adjust domains to your allow list
  const csp = [
    "default-src 'self'",
    "script-src 'self' 'strict-dynamic' 'nonce-PLACEHOLDER'",
    "style-src 'self' 'unsafe-inline'", // Prefer nonced styles; some libs require this
    "img-src 'self' data: https:",
    "connect-src 'self' https:",
    "font-src 'self' data: https:",
    "frame-ancestors 'none'",
    "base-uri 'self'",
    "form-action 'self'",
  ].join('; ');
  res.headers.set('content-security-policy', csp);

  return res;
}

export const config = {
  matcher: '/:path*',
};
```

CSP nonce pattern
```tsx
// app/layout.tsx
import type { Metadata } from 'next';
import { headers } from 'next/headers';

export const metadata: Metadata = { title: 'App' };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const nonce = headers().get('x-nonce') || undefined; // Set this in your reverse proxy or middleware
  return (
    <html>
      <head>
        {/* Example of nonced inline script if absolutely necessary */}
        {nonce && (
          <script
            nonce={nonce}
            dangerouslySetInnerHTML={{ __html: 'window.__BOOTSTRAP__=true' }}
          />
        )}
      </head>
      <body>{children}</body>
    </html>
  );
}
```
Notes
- Prefer external JS; reserve inline for bootstraps with a nonce. Avoid 'unsafe-inline' in script-src.
- Some hosting providers allow setting a per-request nonce header; otherwise generate one in middleware and propagate.

2) Cookie security (sessions/tokens)
- Use HttpOnly, Secure, SameSite=strict (or lax for cross-site flows), and a narrow path.

```ts
// app/api/session/route.ts
import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';

export async function POST() {
  const session = 'opaque-session-id';
  cookies().set({
    name: 'sid',
    value: session,
    httpOnly: true,
    secure: true,
    sameSite: 'strict',
    path: '/',
    maxAge: 60 * 60 * 24,
  });
  return NextResponse.json({ ok: true });
}
```

3) CSRF protection for state-changing requests
- Prefer same-site APIs via Route Handlers and Server Actions; still include CSRF tokens for cookie-authenticated flows.

Server action example with CSRF check
```tsx
// app/(protected)/actions.ts
'use server';
import { cookies, headers } from 'next/headers';

export async function updateProfile(formData: FormData) {
  const tokenFromForm = formData.get('csrfToken');
  const tokenCookie = cookies().get('csrf')?.value;
  const origin = headers().get('origin');
  if (!tokenFromForm || tokenFromForm !== tokenCookie) throw new Error('Invalid CSRF');
  if (!origin || !origin.startsWith(process.env.APP_ORIGIN!)) throw new Error('Bad origin');
  // ...update
}
```

Issue CSRF token
```ts
// app/api/csrf/route.ts
import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';

export async function GET() {
  const token = crypto.randomUUID();
  cookies().set({ name: 'csrf', value: token, httpOnly: true, sameSite: 'strict', secure: true, path: '/' });
  return NextResponse.json({ token });
}
```

4) Authentication and RSC boundaries
- Keep tokens and user lookups in Server Components / Route Handlers.
- Do not pass raw JWTs to the client. Derive a minimal session model for UI.
- In Client Components, call server actions or use a small authenticated fetch wrapper that forwards cookies automatically.

5) SSRF and outgoing requests
- Avoid proxying arbitrary URLs. Maintain an allow list for outbound domains.

```ts
const ALLOW = new Set(['api.example.com', 'auth.example.com']);
export async function safeFetch(url: URL | string, init?: RequestInit) {
  const u = new URL(url.toString());
  if (!ALLOW.has(u.hostname)) throw new Error('Blocked host');
  return fetch(u, { ...init, cache: 'no-store' });
}
```

6) Caching, ISR, and personalization
- Never cache per-user data. Use cache: 'no-store' or dynamic = 'force-dynamic' when rendering with user context.
- Use revalidateTag and revalidatePath only from trusted server code on writes; tag by resource ID.

```tsx
// app/(account)/page.tsx
export const dynamic = 'force-dynamic'; // per-user
export default async function Account() {
  const res = await fetch('https://api.example.com/me', { cache: 'no-store' });
  const me = await res.json();
  return <pre>{JSON.stringify(me)}</pre>;
}
```

7) Redirects and open-redirect prevention
- Validate redirect targets against an allow list or ensure they are same-origin.

```ts
import { NextResponse } from 'next/server';

function isSafe(url: URL) {
  return url.origin === process.env.APP_ORIGIN;
}

export function safeRedirect(target: string) {
  const url = new URL(target, process.env.APP_ORIGIN);
  if (!isSafe(url)) return NextResponse.redirect(process.env.APP_ORIGIN!);
  return NextResponse.redirect(url);
}
```

8) Environment variables and secrets
- Only variables prefixed with NEXT_PUBLIC_ are exposed to the client — treat them as public.
- Keep all credentials (API keys, DB URLs) server-side; never import them in Client Components.

9) Images and uploads
- Restrict remote image domains via next.config.js images.remotePatterns.
- Validate and scan uploaded files in Route Handlers; store outside the repo; set appropriate Content-Type.

10) Rate limiting and abuse protection
- Add basic rate limiting in middleware or Route Handlers. For production, use a durable store (e.g., Redis/Upstash).

```ts
// app/api/limited/route.ts
import { NextResponse } from 'next/server';
const BUCKET = new Map<string, { count: number; ts: number }>();

export async function GET(request: Request) {
  const ip = (request.headers.get('x-forwarded-for') || '').split(',')[0] || 'unknown';
  const rec = BUCKET.get(ip) || { count: 0, ts: Date.now() };
  const now = Date.now();
  if (now - rec.ts > 60_000) { rec.count = 0; rec.ts = now; }
  rec.count += 1; BUCKET.set(ip, rec);
  if (rec.count > 60) return new NextResponse('Too Many Requests', { status: 429 });
  return NextResponse.json({ ok: true });
}
```

11) Dependency and build-time safety
- Keep dependencies current; enable eslint-plugin-security and type-checked env.
- Turn on strict TypeScript and enable next lint in CI.

12) Monitoring and incident response
- Log authentication/authorization failures server-side only; avoid logging secrets.
- Emit security-relevant metrics and trace IDs where available.

13) Client Components ('use client') risk model
- 'use client' marks a component as a Client Component and ships its code to the browser. Any values imported or embedded there are exposed to users and tooling. Treat everything reachable from Client Components as public.
- Never import server-only modules, private environment variables, or credential-bearing constants in Client Components. NEXT_PUBLIC_* vars are public by design; all others must remain on the server.
- Prefer Server Components by default; use Client Components only for interactive islands that require state, effects, refs, portals, or browser-only APIs.

Do — safe patterns
- Keep secrets in Route Handlers, Server Actions, or Server Components; pass only minimal, non-sensitive data to clients.
- For authenticated client fetch, call server actions or same-origin API routes that use HttpOnly cookies; do not pass raw tokens/JWTs to the client.
- If a client needs a scoped capability, mint a short-lived, least-privilege, signed token specifically for that purpose (e.g., upload) and validate server-side.
- Validate all client-provided data server-side; treat client as untrusted.

Don't — unsafe patterns
- Don't read process.env (non-NEXT_PUBLIC) or import secret-bearing config in Client Components.
- Don't embed API keys, database URLs, or service credentials in client code, even behind feature flags.
- Don't hydrate per-user sensitive data into static caches; avoid caching routes with user context.

Guardrails
- Add ESLint rules to disallow process.env access in client files and to ban importing server-only modules into client boundaries.
- Code review checklist: "Does this 'use client' boundary expose secrets? Are we passing tokens? Can this be a Server Component instead?"
- CI: run next lint and a custom grep to prevent accidental secrets in client code.

Cross-links
- Next.js overview — ./nextjs-overview.md
- Routing & data — ./nextjs-routing-data.md
- SSR/SSG/ISR — ./nextjs-ssr-ssg.md
- Web Components in Next.js — ./nextjs-web-components.md
- Platform Security & Auth — ../../platform/security-auth/README.md
