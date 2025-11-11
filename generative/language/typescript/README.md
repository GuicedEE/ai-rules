# TypeScript (Latest) — DDD, Type Safety, Reactive Chaining, and Testing Standards

Scope
- Audience: Engineers and AI systems generating or reviewing TypeScript code for both frontend (Angular/React/Next.js/Web Components) and backend (Node.js) contexts.
- Goals: Enforce Domain-Driven Design (DDD), strict type safety (never use `any` unless explicitly requested), reactive chaining patterns (prefer RxJS or Promise combinators), and strict enumerations for fixed-value sets (<16 values).
- Version: Target the latest stable TypeScript (configure CI to stay within the latest minor, and run type-checking in CI).

Core Principles
- Type safety first: enable strict TypeScript configuration; do not use `any` unless a spec explicitly requires it (document why if used).
- DDD alignment: model the domain with Value Objects, Entities, Aggregates, Domain Events, Repositories, Application Services, and anti-corruption layers.
- Reactive-first composition: prefer chained reactive pipelines (RxJS or Promise combinators) over scattered `await` statements. Never await indefinitely — always bound with timeouts, cancellation, or safeguards.
- Strict enumerations: for known finite sets (<16), use string literal unions or immutable const arrays validated with satisfies; only use `enum` when interop requires, and ensure exhaustiveness checks.
- Testing completeness: define and implement a test taxonomy: unit, property-based, contract, integration, e2e, performance, and mutation testing.

1) TypeScript Configuration (strict)
Use or generate a baseline tsconfig.json with strictest reasonable settings:

```jsonc
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "useUnknownInCatchVariables": true,
    "forceConsistentCasingInFileNames": true,
    "isolatedModules": true,
    "declaration": true,
    "skipLibCheck": false,
    "resolveJsonModule": true,
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "types": []
  }
}
```

Linting/Rules (ESLint + typescript-eslint)
- Disallow `any`: @typescript-eslint/no-explicit-any: "error"
- Prefer readonly types: functional/immutable-data or custom rules for readonly where sensible.
- Exhaustive switch: add a utility function `assertNever` to force exhaustiveness.
- Ban floating promises: @typescript-eslint/no-floating-promises: "error"
- No misused promises: @typescript-eslint/no-misused-promises: ["error", {"checksVoidReturn": false}]

2) DDD Building Blocks in TypeScript

2.1 Value Objects
- Immutable, equality by value, constructors validate invariants.

```ts
// Money.ts
export type Currency = "USD" | "EUR" | "GBP" | "ZAR" | "JPY"; // <16 values → strict union

export class Money {
  public static readonly ZeroUSD = new Money(0, "USD");
  readonly amount: number;
  readonly currency: Currency;
  constructor(amount: number, currency: Currency) {
    if (!Number.isFinite(amount)) throw new Error("Amount must be finite");
    if (amount < 0) throw new Error("Amount must be >= 0");
    this.amount = amount;
    this.currency = currency;
    Object.freeze(this);
  }
  add(other: Money): Money {
    if (this.currency !== other.currency) throw new Error("Currency mismatch");
    return new Money(this.amount + other.amount, this.currency);
  }
  equals(other: Money): boolean {
    return this.amount === other.amount && this.currency === other.currency;
  }
}
```

2.2 Entities and Identifiers

```ts
// types.ts
export type Brand<K, T extends string> = K & { readonly __brand: T };
export type UUID = Brand<string, "uuid">;

export function asUUID(input: string): UUID {
  if (!/^([0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12})$/i.test(input))
    throw new Error("Invalid UUID");
  return input as UUID;
}

// UUID generation — use uuid v4
// Prefer the 'uuid' package for generating UUIDs consistently across Node and browser builds.
// npm i uuid
// ESM:
//   import { v4 as uuidv4 } from "uuid";
// CJS:
//   const { v4: uuidv4 } = require("uuid");
// Generate and brand:
//   const newId: UUID = asUUID(uuidv4());
// Note: Node 18+ includes crypto.randomUUID(), but for consistency and SSR/bundlers,
// we standardize on uuidv4 in this guide.

// Customer.ts
import { UUID } from "./types";
import { Money } from "./Money";

export interface CustomerProps {
  id: UUID;
  email: string;
  balance: Money;
}

export class Customer {
  private props: CustomerProps;
  constructor(props: CustomerProps) {
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(props.email)) throw new Error("Invalid email");
    this.props = { ...props };
  }
  get id(): UUID { return this.props.id; }
  get email(): string { return this.props.email; }
  get balance(): Money { return this.props.balance; }
  credit(amount: Money): Customer { return new Customer({ ...this.props, balance: this.props.balance.add(amount) }); }
}
```

2.3 Aggregates and Domain Events

```ts
// DomainEvent.ts
export interface DomainEvent<TType extends string, TPayload> {
  readonly type: TType;
  readonly occurredAt: Date;
  readonly payload: TPayload;
}

export type CustomerEventType = "CustomerRegistered" | "CustomerCredited"; // strict finite union

export type CustomerRegistered = DomainEvent<"CustomerRegistered", { id: string; email: string }>
export type CustomerCredited = DomainEvent<"CustomerCredited", { id: string; amount: number; currency: string }>

export type CustomerEvent = CustomerRegistered | CustomerCredited;
```

2.4 Repository Interfaces (ports)

```ts
// CustomerRepository.ts
import type { Customer } from "./Customer";
import type { UUID } from "./types";

export interface CustomerRepository {
  findById(id: UUID): Promise<Customer | null>;
  save(entity: Customer): Promise<void>;
}
```

2.5 Application Services (use cases)
- Compose domain and ports; enforce invariants at boundaries.
- Prefer reactive chaining; if using Promises, use combinators and timeouts.

```ts
// creditCustomer.ts
import { Money } from "./Money";
import { type CustomerRepository } from "./CustomerRepository";
import { type UUID } from "./types";

export async function creditCustomer(repo: CustomerRepository, id: UUID, amount: Money): Promise<void> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 3000);
  try {
    const customer = await withTimeout(repo.findById(id), 3000);
    if (!customer) throw new Error("Customer not found");
    await withTimeout(repo.save(customer.credit(amount)), 3000);
  } finally {
    clearTimeout(timeout);
  }
}

async function withTimeout<T>(p: Promise<T>, ms: number): Promise<T> {
  return Promise.race<T>([
    p,
    new Promise<T>((_, reject) => setTimeout(() => reject(new Error("Timed out")), ms))
  ]);
}
```

2.6 Reactive (RxJS) Application Services
- Prefer Observable chains for complex workflows, retries, or streams.
- Always bound streams with timeout, takeUntil, or similar operators.

```ts
// creditCustomer.rx.ts
import { Observable, from, timeout, throwError, mergeMap, map, catchError } from "rxjs";
import type { CustomerRepository } from "./CustomerRepository";
import type { UUID } from "./types";
import { Money } from "./Money";

export const creditCustomer$ = (
  repo: CustomerRepository,
  id: UUID,
  amount: Money,
): Observable<void> =>
  from(repo.findById(id)).pipe(
    timeout({ each: 3000 }),
    mergeMap((customer) => customer ? from(repo.save(customer.credit(amount))) : throwError(() => new Error("Customer not found"))),
    timeout({ each: 3000 }),
    map(() => void 0),
    catchError((e) => throwError(() => e))
  );
```

2.7 Infrastructure Adapters (adapters implement ports)

```ts
// InMemoryCustomerRepository.ts
import type { CustomerRepository } from "./CustomerRepository";
import type { UUID } from "./types";
import type { Customer } from "./Customer";

export class InMemoryCustomerRepository implements CustomerRepository {
  private readonly store: Map<UUID, Customer> = new Map();
  async findById(id: UUID): Promise<Customer | null> {
    return this.store.get(id) ?? null;
  }
  async save(entity: Customer): Promise<void> {
    this.store.set(entity.id, entity);
  }
}
```

3) Strict Enumerations for Small Fixed Sets
Prefer these patterns when the set is known and <16 values:

3.1 String literal union
```ts
export type OrderStatus = "Pending" | "Paid" | "Shipped" | "Delivered" | "Cancelled";

export function assertNever(x: never): never { throw new Error(`Unhandled case: ${String(x)}`); }

export function isTerminal(status: OrderStatus): boolean {
  switch (status) {
    case "Delivered":
    case "Cancelled":
      return true;
    case "Pending":
    case "Paid":
    case "Shipped":
      return false;
    default:
      return assertNever(status);
  }
}
```

3.2 Const array + satisfies for derivations
```ts
export const PAYMENT_METHODS = ["Card", "BankTransfer", "Cash", "Wallet"] as const;
export type PaymentMethod = typeof PAYMENT_METHODS[number];

export const PaymentMethodLabels: Record<PaymentMethod, string> = {
  Card: "Credit/Debit Card",
  BankTransfer: "Bank Transfer",
  Cash: "Cash",
  Wallet: "Digital Wallet",
} satisfies Record<PaymentMethod, string>;
```

3.3 Native enum only for interop or numeric protocol boundaries
```ts
export enum HttpStatus {
  OK = 200,
  BadRequest = 400,
  Unauthorized = 401,
}
```

4) Reactive Patterns and Safeguards
- Never await indefinitely: always wrap awaits with timeouts, races, or abort signals.
- Promise utilities:
  - withTimeout(p, ms): Promise.race with a timeout rejection.
  - allSettled or all with bounded concurrency via p-limit (if needed).
- RxJS utilities:
  - timeout({ each: ms }), takeUntil(abort$), take(n), first(), raceWith(...), finalize() for cleanup.
- Retries should be bounded and jittered: retry({ count: 3, delay: expBackoff(i) }).

Example bounded fetch with AbortController:
```ts
export async function getJson<T>(url: string, ms = 3000): Promise<T> {
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), ms);
  try {
    const res = await fetch(url, { signal: controller.signal });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return (await res.json()) as T;
  } finally {
    clearTimeout(id);
  }
}
```

5) Testing Taxonomy and Structures
Adopt a layered strategy. Example tools: Vitest or Jest for unit/integration; Playwright/Cypress for e2e; fast-check for property; Pact or protobuf/OpenAPI contracts; k6/Artillery for performance; Stryker for mutation testing.

Recommended folder layout:
- src/
- test/
  - unit/
  - property/
  - contract/
  - integration/
  - e2e/
  - performance/
  - mutation/

Naming conventions:
- Test files mirror src paths: src/domain/Customer.ts → test/unit/domain/Customer.spec.ts
- Use explicit type annotations in tests; avoid `any`.

5.1 Unit tests (fast, isolated)
```ts
// test/unit/Money.spec.ts (Vitest)
import { describe, it, expect } from "vitest";
import { Money } from "../../src/Money";

describe("Money", () => {
  it("adds in same currency", () => {
    const a = new Money(10, "USD");
    const b = new Money(5, "USD");
    expect(a.add(b).equals(new Money(15, "USD"))).toBe(true);
  });
});
```

5.2 Property-based tests
```ts
import { describe, it } from "vitest";
import { fc } from "@fast-check/vitest";
import { Money } from "../../src/Money";

describe("Money properties", () => {
  it("addition is commutative", () =>
    fc.assert(
      fc.property(fc.nat(1_000_000), (n) => {
        const a = new Money(n, "USD");
        const b = new Money(1, "USD");
        return a.add(b).equals(b.add(a));
      })
    ));
});
```

5.3 Contract tests (consumer/provider)
- Use Pact or schema-based (OpenAPI/protobuf) to verify types and payload shapes are consistent.
- Keep domain models decoupled from transport DTOs (anti-corruption layer).

5.4 Integration tests
- Wire real adapters (DB, HTTP) with ephemeral infra (Testcontainers or local doubles). Time-bound all external calls.

5.5 End-to-end (e2e)
- Test critical user journeys with Playwright/Cypress; run headless in CI; stabilize via test-ids and bounded waits.

5.6 Performance tests
- Define SLOs; run k6/Artillery scripts; assert latency budgets and error rates.

5.7 Mutation tests
- Run Stryker on the unit test suite; maintain a mutation score threshold (e.g., ≥ 80%).

6) Dependency Injection and Modularity
- Prefer constructor injection; keep interfaces as ports.
- For Node/React: minimal DI via factory functions, no global singletons.
- For Angular: leverage providedIn: 'root' services and injection tokens with strict types.

7) DTOs and Mappers
- Use explicit DTO types distinct from domain models. Map via pure functions or libraries that preserve types. Never leak `any` across layers.

8) Error Handling and Result Types
- Favor specific Error subclasses or Result/Either types where flows benefit from explicit control. Always preserve type safety across branches.

9) CI and Quality Gates
- Type-check in CI: tsc --noEmit
- Lint with ESLint (no-explicit-any, no-floating-promises) and run tests with coverage and mutation score thresholds.

10) Code Review Checklist (TS DDD)
- Are all small finite sets modeled as strict unions or const arrays with satisfies (or carefully chosen enums)?
- Are any awaits bounded with timeout/abort or handled via reactive operators?
- Are domain invariants enforced in constructors/factories of Value Objects/Entities?
- Do repositories and services expose precise types (no `any`)?
- Are tests covering unit, property, contract, integration, and e2e perspectives where appropriate?

References
- RxJS Docs: https://rxjs.dev/guide/operators
- TypeScript Handbook (Latest): https://www.typescriptlang.org/docs/
- fast-check: https://github.com/dubzzz/fast-check
- Stryker Mutator: https://stryker-mutator.io/

Back/Forward Links
- Back to rules: see RULES.md — Technical Commitments for TypeScript and Angular/React sections.
- Forward to implementations: link project-specific services, repositories, and components to the examples above.
