# ADR-0011: Contract-first OpenAPI; two tracks meet only at the contract

## Status
Accepted

## Date
2026-10-17

## Context
Backend and mobile will be built in parallel by different builders. Without a fixed interface, they block each other or diverge. ASP.NET Core can generate an OpenAPI document from code (Swashbuckle), but a code-first document only exists once the code does, and it drifts towards whatever the implementation happens to do.

## Decision
- **`docs/openapi.yaml` (OpenAPI 3.1) is the source of truth**, hand-authored and reviewed. It is linted by Redocly (`make api-lint`, `contract.yml`) with the repo's `redocly.yaml`.
- **The backend keeps Swashbuckle** for dev tooling, and an integration test (`OpenApiContractTests`) compares the generated document with `docs/openapi.yaml`. The set of operations (method + path), the documented status codes per operation, and the security requirements must match. Schema compatibility is checked by validating real integration-test responses against the YAML schemas, using a JSON Schema validator (JsonSchema.Net) in a response-recording test filter. So the generated document doesn't have to be byte-identical; behaviour does.
- **Mobile** develops against a **Prism mock** of `openapi.yaml` until the backend is deployed. Its DTO tests run against JSON fixtures that CI validates against the YAML schemas.
- **Process:** contract changes land first, in their own PR (`api(contract): …`), reviewed by one person from each track. Then each track implements independently. Breaking changes in v1 are forbidden (ADR-0010).

## Alternatives considered
- **Code-first (Swashbuckle output as the contract).** It blocks mobile until the backend exists, and the implementation can silently change the contract. Rejected.
- **Generated server stubs (NSwag server generation).** These fight with Clean Architecture controllers and produce awkward code. Rejected.
- **Generated Dart client (openapi-generator).** Considered for later (`packages/api_client`). It's verbose and not idiomatic for Riverpod plus Drift, and fixtures plus hand-written DTOs are enough at this size.

## Consequences
- Some duplication: the YAML and the C# DTOs and attributes. The contract test catches drift in CI.
- Every new endpoint starts in the YAML. PLAN tasks reference operationIds.
- The YAML gains vendor extensions (`x-sakina-child-allowed`, `x-sakina-plus-required`, `x-sakina-rate-limit`), which the backend's authorisation-matrix test reads to check that policies match.
