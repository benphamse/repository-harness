# Architecture

`repository-harness` has one Rust binary, `harness`, plus thin Bash and
PowerShell bootstraps.

## Product Boundary

```text
consumer repository truth
  <- installed repository protocol
  <- safely maintained by harness
```

Harness installs navigation, working-memory structure, and decision boundaries.
It does not own the consumer's product, runtime, orchestration, credentials,
logs, fixtures, or validation commands.

## Rust Dependency Direction

```text
domain <- application <- infrastructure
                    <- interface

main.rs composes interface and infrastructure
```

- Domain types represent paths, hashes, provenance, merge outcomes, and
  reports without filesystem, process, serialization, or CLI dependencies.
- Application use cases depend on ports and own install, update, status,
  doctor, self-update, version, conflict, and recovery policy.
- Infrastructure implements embedded release content, hashing, locks,
  filesystem transactions, Git three-way merge, candidate download, checksum,
  and executable replacement.
- Interface parses commands and renders reports.
- `main.rs` is the composition root.

Architecture tests reject outward dependencies from inner layers.

## Installation State

Consumer provenance lives under `.harness-core/`:

```text
.harness-core/
├── manifest.json
├── base/
├── transaction.json          # only while an apply is pending
├── update/                   # only while conflict resolution is pending
└── update-candidate/         # retained verified candidate when required
```

The manifest and base contain only Harness-managed core state. They are not a
task database or product-memory store.

## Update Transaction

```text
load installed base and candidate
  -> validate every managed path
  -> freeze current workspace inputs
  -> plan three-way changes
  -> stop and stage overlapping conflicts
  -> otherwise write journal and backups
  -> activate workspace files
  -> commit provenance last
  -> replace repository-local executable last
```

A later mutating command rolls back an interrupted apply before starting new
work. Symlinks in managed paths, candidate paths, and executable replacement
paths are rejected.

## Infra & Ops Surfaces

For repos where the consumer stack is infrastructure rather than an
application (Terraform/CloudFormation/Bicep modules, Kubernetes manifests and
Helm charts, CI/CD pipeline definitions, observability configuration), the
boundary and discovery thinking still applies, with these surfaces standing
in for the app-layer ones above:

- Boundary inputs: cloud provider API responses, IaC state files, Kubernetes
  API objects, webhook/event payloads from CI systems, secrets resolved at
  deploy time.
- Core domains: environments (dev/staging/prod), workloads/services, network
  and identity boundaries (VPCs, IAM roles, service accounts), alerting and
  SLO definitions.
- Parse-first still applies: a `terraform plan`/`kubectl diff` (or provider
  equivalent) output is the parsed, typed view of the change; do not apply an
  IaC or manifest change straight to production without reviewing that
  output first.
- Validation ladder here usually looks like: lint/static-analyze the IaC or
  manifest -> plan/dry-run against a non-prod target -> apply to a lower
  environment -> apply to production with a rollback path recorded.

This is a thinking template, not a scaffold. Do not generate Terraform
modules, Helm charts, or pipeline files speculatively — create them only when
a real story or spec calls for that specific infrastructure.

## Observability Contract

Harness preserves BASE, LOCAL, UPSTREAM, and RESOLVED but does not choose
policy. An agent may explain the difference; a human supplies direction when a
material product choice remains. Continuation rejects conflict markers,
candidate tampering, malformed sessions, and drift in any frozen managed file.

## Trust Boundary

Updates resolve the exact `harness-v*` release pointer, download the matching
platform binary and SHA-256 sidecar, require the binary-reported version to
equal the pointer, and reject downgrades.

SHA-256 verifies bytes relative to the GitHub release. It is not an independent
publisher-compromise trust root.

## Consumer Application Guidance

Harness does not prescribe a generic application architecture. A consumer
should document only its actual stack, domains, inputs, run commands, readiness,
state ownership, logs, validation, and cleanup behavior.

Use `docs/templates/application-runbook.md` when a real application operation
needs durable guidance. Do not invent commands, credentials, policies, or
cleanup ownership to complete the template.
