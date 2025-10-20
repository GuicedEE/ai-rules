# 🔀 OpenAPI Orchestration Contract Map — ExperimentalAIApp

## Purpose

This document defines how OpenAPI specifications are discovered, exposed, and routed across all active backend microservices and frontend shell applications in the ExperimentalAIApp platform.

---

---

## Aggregation Responsibilities (Shell)

The ExperimentalAIApp shell is responsible for:

* Aggregating all mounted OpenAPI contracts
* Registering known services into the routing graph
* Providing a centralized API viewer (combined Swagger UI optional)
* Validating MFE contracts at load-time
* Exposing contract links through the configuration injection layer

---

## Routing and Loading Expectations

* Each backend microservice defines an isolated OpenAPI YAML
* The shell mounts these contracts under distinct prefixes
* All contracts must:

  * Conform to the authoring guidelines
  * Use shared component references where applicable

---

## OpenAPI Contract Health Check

Each mounted OpenAPI service must:

* Be reachable via its `/openapi.yaml`
* Expose `/health` for availability checks
* Register its tag prefix and logical module name in shell configuration

---

## Future Enhancements

* Combined OpenAPI viewer via `swagger-ui-bundle.js` for platform-wide discovery
* Registry-based contract validation pipeline
* CLI support for `contract lint`, validation and bundling

---

📡 **Every service. Every contract. Discoverable and validated.**
