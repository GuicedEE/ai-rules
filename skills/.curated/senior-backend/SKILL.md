---
name: senior-backend
description: "Build or review backend APIs and services, including data models, authentication, migrations, performance, and observability."
---

# Senior Backend

Ship backend changes that are correct, observable, and easy to operate.

## Quick Start
1) Define contract first (API/events): inputs, outputs, errors, idempotency.
2) Define data ownership: schema changes, migrations, backfills, rollback.
3) Implement with safety:
   - validation, authZ, rate limits
   - structured errors + logging + metrics
4) Prove it: tests + a local “smoke path” + monitoring hooks.

## Optional tool: scaffold backend docs
```bash
python ~/.codex/skills/senior-backend/scripts/scaffold_backend_docs.py . --out docs/backend
```

## References
- API guidelines: `references/api-guidelines.md`

