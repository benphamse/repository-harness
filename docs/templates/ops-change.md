# US-XXX Ops Change Title

## Status

planned

## Lane

tiny | normal | high-risk

## Change Summary

Describe the infra, cluster, deploy, or observability change this work must make true.

## Scope

- Systems/services affected:
- Environments affected: dev | staging | prod
- Infra surface: Terraform/CloudFormation/Bicep/Pulumi | Kubernetes/Helm | CI/CD pipeline | logging/monitoring/tracing config

## Blast Radius

- What breaks if this change is wrong?
- Who/what depends on the affected system?
- Is the change reversible, and how fast?

## Plan / Dry-Run Evidence

Attach `terraform plan`, `kubectl diff`, pipeline dry-run, or equivalent output
before applying to any shared environment.

## Rollback Plan

Describe the exact steps to revert this change if it causes an incident.

## Observability Impact

- Alerts/dashboards added, changed, or removed:
- Log or trace signals added, changed, or removed:
- Confirm no existing alert, dashboard, or log signal is silently weakened.

## Validation

| Layer | Expected proof |
| --- | --- |
| Lint/static analysis | |
| Plan/dry-run | |
| Non-prod apply | |
| Prod apply | |
| Rollback tested | |

## Harness Delta

Document any harness updates made or proposed because of this change.

## Evidence

Add commands, plan output, dashboards, or links after validation exists.
