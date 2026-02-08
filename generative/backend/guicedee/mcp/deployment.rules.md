# Deployment Rules - mcp.guicedee.com

Purpose: define production deployment and release policy for the hosted MCP server.

## Environment profile
- Production endpoint: `https://mcp.guicedee.com/mcp`.
- Keep separate deployment environments (`dev`, `staging`, `prod`) with isolated credentials and quotas.
- Use immutable build artifacts and reproducible dependency resolution.

## Edge and network controls
- Terminate TLS at managed edge with modern ciphers and automatic certificate renewal.
- Restrict direct app-tier ingress; only edge/load-balancer traffic may reach Vert.x listeners.
- Apply IP reputation and bot controls before app-tier dispatch.

## Runtime configuration
- Externalize all sensitive config through environment variables or secret stores.
- Keep explicit settings for:
  - protocol revision default,
  - transport mode (`stdio`, `http`, or dual),
  - session mode (stateful/stateless),
  - timeout and concurrency budgets,
  - authentication provider metadata.
- Fail startup on invalid required settings.

## Release gates
- Required gates before production rollout:
  - protocol conformance suite pass,
  - security regression suite pass,
  - load test pass at target concurrency,
  - architecture conformance pass (no interface-only scaffolding where selected libraries provide concrete contracts),
  - rollback verification pass.
- Use progressive rollout (canary then broad rollout) with automated rollback triggers.

## Capacity and scaling
- Scale horizontally behind load balancers.
- If stateful sessions are enabled, use sticky routing or external session storage.
- Keep per-node backpressure controls to protect event loops under burst traffic.

## Disaster recovery
- Keep backup and restore plans for any persistent capability metadata.
- Document recovery time objective (RTO) and recovery point objective (RPO).
- Test failover and restore procedures on a fixed cadence.

See also: `./transport-streamable-http.rules.md`, `./security-authz.rules.md`, `../../../platform/ci-cd/README.md`.
