# Security, Classification & Observability

## Overview
ActivityMaster Core carries X-classification and security token metadata through every service call while emitting Log4j2 traces that map to the Stage 1 sequence diagrams. This file captures the rules for security token handling, classification updates, and logging instrumentation.

## Usage
- Always require or derive a `SecurityToken` before mutating classification tables; tokens should originate from `SecurityTokenService` helpers defined in `rules/generative/backend/guicedee/README.md`.
- Coordinate classification mutations through the `ISystemUpdate` pipelines and `@SortedUpdate` annotations so the host startup sequence reloads guardrails before exposing runtime services.
- Use Lombok `@Log4j2` across services plus `Mutiny` instrumentation hooks to trace classification join resolutions; reference `rules/generative/platform/observability/README.md` for the standard logging configuration (`logging.properties`).

## Inputs/Outputs/Constraints
- Classification helpers (e.g., `AddressXClassification`, `ArrangementXRules`) must never be mutated without the classification guardrails documented in host guides; updates should emit traceable events that ship with the deployed sequence diagrams.
- Logging statements must tie to the canonical sequence diagrams by emitting traceable markers when classification joins, security token validations, or system startups occur.
- Observability instrumentation should leverage the same `Log4j2` appenders and MDC keys described in the platform observability index to keep monitoring dashboards aligned.

## Performance & Validation
- Before touching classification data, validate token metadata against the `ActivityMaster` domain boundaries; add the same validations to any new audit entries to keep security transcripts consistent.
- Use Jacoco/Java Micro Harness scenarios (`rules/generative/platform/testing/README.md`) to cover classification flows and verify that tokens are passed across reactive boundaries without blocking.

## See also
- `../README.md` for the topic index.
- `../../platform/security-auth/README.md`, `../../backend/guicedee/README.md`, `../../platform/observability/README.md`, `../../platform/testing/README.md`.
