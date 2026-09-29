# repository-harness

Turn a software repository into a legible, agent-ready workspace.

`repository-harness` installs a small repository protocol and a safe updater.
The repository remains the system of record: product documents, decisions,
plans, code, tests, CI, and runtime evidence define the work.

It is not a task database, story tracker, agent orchestrator, or application
runtime.

## What It Solves

Coding agents often fail for ordinary engineering reasons:

- important intent exists only in chat;
- the repository does not identify authoritative documents;
- small changes acquire unnecessary process;
- long changes lose decisions and recovery context;
- completion is claimed without behavior-level proof; and
- an agent invents product policy when the request leaves a material choice
  open.

Harness provides a compact entrypoint, a navigable repository map, durable plans
only when work needs them, explicit judgment boundaries, and mechanical
validation.

## Built For Infra And Ops-Heavy Repos

The harness pattern is stack-agnostic, but it is especially valuable in repos
where the blast radius of a wrong agent change is an outage, a security
incident, or a bad rollout rather than a failed unit test. That is the daily
reality for:

- **DevSecOps engineers** — IaC changes (Terraform, CloudFormation, Bicep),
  policy-as-code, secrets and identity boundaries, CI/CD pipeline hardening.
- **Platform engineers** — Kubernetes platform config, internal developer
  platforms, multi-cloud (AWS, Azure, GCP) landing zones, service meshes.
- **SRE engineers** — production runbooks, alerting and paging config,
  capacity and reliability tradeoffs, incident-driven changes under time
  pressure.
- **AIOps / observability engineers** — logging pipelines, monitoring and
  alert rules, distributed tracing, anomaly detection and automation glue.

In these repos, the missing context an agent needs is rarely "how does this
function work" — it is "what is the blast radius of this change, what proof
of safety is required before it ships, and what tradeoff did the last on-call
already make here." The Harness intake, risk lanes, and decision records exist
to make that context explicit instead of trapped in someone's head or a closed
incident channel.

Common technology surfaces this harness pattern applies well to:

- Cloud providers: AWS, Azure, GCP
- Container and orchestration: Kubernetes, Docker, Helm
- Infrastructure as code: Terraform, CloudFormation, Bicep, Pulumi
- Observability: logging, metrics/monitoring, distributed tracing, alerting
- CI/CD: pipeline definitions, deployment gates, release automation

## The Problem

````text
read-only request
  -> inspect the smallest authoritative surface
  -> answer with evidence

bounded change
  -> inspect authority and affected behavior
  -> implement the smallest coherent change
  -> run relevant proof

multi-session or coordinated change
  -> create docs/plans/active/<plan>.md
  -> keep decisions, progress, recovery, and validation current
  -> move the validated plan to docs/plans/completed/

A repository starts to have a harness when it helps an agent answer practical
engineering questions without relying only on chat history:

- What should I read first?
- What type of work is this?
- Which product contract does it affect?
- How risky is the change?
- What proof will show the work is done?
- What decision or lesson should future agents inherit?

In this repo, those answers live in:

- `AGENTS.md` — the stable agent shim with local project notes and Harness
  doc links.
- `docs/HARNESS.md` — the human-agent collaboration model.
- `docs/FEATURE_INTAKE.md` — tiny, normal, and high-risk work classification.
- `docs/ARCHITECTURE.md` — architecture discovery and boundary rules.
- `docs/TEST_MATRIX.md` — behavior-to-proof validation expectations.
- `docs/stories/` — story packets and backlog items.
- `docs/decisions/` — durable decisions and tradeoffs.
- `docs/templates/` — reusable spec, story, decision, and validation templates.

OpenAI describes this shift as an agent-first world where humans steer and
agents execute:

<https://openai.com/index/harness-engineering/>

## Install Harness Into A Project

From a target project directory, run:

```bash
curl -fsSL "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --yes
material product ambiguity
  -> stop before mutation
  -> present the concrete choice and consequences
````

A typo does not need a plan. A migration spanning sessions does. A request to
“add rate limiting” without a quota, identity key, enforcement owner, shared
state topology, or response contract must stop before implementation.

Start with [`AGENTS.md`](AGENTS.md), then
[`docs/WORKFLOW.md`](docs/WORKFLOW.md).

## What Gets Installed

The default core contains:

- a compact `AGENTS.md` entrypoint;
- the repository workflow and documentation map;
- product, decision, and execution-plan structure;
- optional templates for durable plans, decisions, application runbooks, and
  evidence-backed Harness improvements; and
- an invariant-encoding pattern and skill, plus explicit-only onboarding and
  proposal-audit skills.

It does not install application architecture, product policy, validation
commands, credentials, a database, schemas, orchestration, or background
processes.

The exact payload is declared in
[`scripts/harness-install-files.txt`](scripts/harness-install-files.txt).

## Install

From a target repository:

```bash
curl -fsSL "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.sh?$(date +%s)" |
  bash -s -- --yes
```

On PowerShell:

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.ps1"))) -Yes
```

Use `--merge` / `-Merge` to preserve existing files and add only missing
Harness paths. Use `--override` / `-Override` only when replacement is
intentional. Use `--dry-run` / `-DryRun` to preview.

The bootstrap downloads a versioned `harness` binary and checksum, verifies
release identity, and delegates installation to that candidate.

## Maintain An Installation

```bash
# Update an existing Harness repo without moving existing files
curl -fsSL "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --yes

# Back up and replace AGENTS.md, docs/, and scripts/
curl -fsSL "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --override --yes
```

```powershell
# Update an existing Harness repo without moving existing files
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.ps1"))) -Merge -Yes

# Back up and replace AGENTS.md, docs/, and scripts/
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.ps1"))) -Override -Yes
```

Use `--merge` when a project already has Harness and you want to append newly
added Harness files without moving the existing `AGENTS.md`, `docs/`, or
`scripts/` paths into backup. Existing files stay untouched; only missing
Harness files are created.

For older Harness installs whose `AGENTS.md` still contains the full generated
operating guide, refresh it into the small stable shim:

```bash
curl -fsSL "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --refresh-agent-shim --yes
scripts/bin/harness status
scripts/bin/harness doctor
scripts/bin/harness update --dry-run
scripts/bin/harness update
```

The updater stores the exact upstream base under `.harness-core/`, performs a
three-way merge, backs up changed files, and activates the result
transactionally.

If local and upstream edits overlap, no managed file or executable changes.
Harness retains BASE, LOCAL, UPSTREAM, and RESOLVED copies plus the frozen
managed input set. After a human resolves the semantic choice:

```bash
scripts/bin/harness update --continue --dry-run
scripts/bin/harness update --continue
```

Use `scripts/bin/harness update --abort` to discard only the staged resolution.

## Optional Skills

```bash
curl -fsSL "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --claude --yes
```

Or install into a specific path:

```bash
curl -fsSL "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --directory /path/to/project --yes
```

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/benphamse/repository-harness/main/scripts/install-harness.ps1"))) -Directory C:\path\to\project -Yes
```

Use `--dry-run` on Bash or `-DryRun` on PowerShell to preview changes before
writing files.

The installer also downloads the prebuilt Harness CLI for the current platform,
verifies its `.sha256` checksum, and installs it at
`scripts/bin/harness-cli` on macOS/Linux or `scripts/bin/harness-cli.exe` on
Windows. The Rust CLI is the main Harness tool and stable command path.

Then bootstrap the local ignored database. A Harness source checkout builds the
CLI from that checkout and validates the restored core-state epoch; it refuses
to fabricate an empty replacement for missing repository state. An installed
project reuses the verified release binary and initializes its own empty local
state:

```bash
scripts/bootstrap-harness.sh
```

```powershell
.\scripts\bootstrap-harness.ps1
```

Harness CLI release assets are built and proven before tag promotion by the
`Harness CLI Release` GitHub Actions workflow. The installer expects each
published release to include `harness-cli-<platform>` and
`harness-cli-<platform>.sha256` assets for macOS arm64, macOS x64, Linux x64,
Linux arm64, and Windows x64. The Windows asset is
`harness-cli-windows-x64.exe` plus `harness-cli-windows-x64.exe.sha256`.

Merged pull requests are recorded in `CHANGELOG.md` by the
`Post-Merge Maintenance` workflow. When a merged PR changes the Rust CLI source,
schema, Cargo metadata, or CLI release packaging, that workflow bumps the CLI
patch version, updates `scripts/harness-cli-release-tag`, and submits the exact
maintenance commit as a release candidate. The reusable workflow builds and
tests all five platforms, verifies the pinned `v0.1.14` upgrade transition,
then creates the annotated `harness-cli-v*` tag and publishes the ten binary and
checksum assets. Failed tags are never moved or reused.

## Try The Flow

The fastest way to understand the harness is to inspect the tiny demo:

- `docs/demo/README.md`: shows how a simple product idea becomes product docs,
  stories, validation expectations, and decisions before implementation starts.

A typical flow looks like this:
Invariant enforcement routes accepted rules through repository-native
validation:

```text
$encode-invariant
```

Brownfield onboarding is explicit and read-only first:

```text
$onboard-repository
```

Harness improvement is also explicit and requires baseline-to-rerun evidence:

```text
$improve-harness
```

Engineering advice is a separate opt-in payload:

```bash
scripts/install-harness.sh --with-engineering-wisdom --yes /path/to/project
```

No skill runs during installation. Onboarding and Harness improvement remain
explicit-only; invariant encoding responds only to matching work requests.

## What We Prove

Harness owns three release-evidence boundaries:

> An agent-ready repo harness for Claude Code, Codex, Cursor, and other coding
> agents: AGENTS.md, product contracts, story packets, validation matrix, and
> decision records. Built for infra and ops-heavy repos — DevSecOps, Platform,
> SRE, and AIOps engineering across AWS, Azure, GCP, Kubernetes, Terraform,
> logging, monitoring, and tracing.

1. **Fresh installation:** the declared core is installed without fabricated
   application truth or hidden lifecycle state.
2. **Repository navigation:** an agent follows repository authority, avoids
   speculative product policy, and can stop at a real decision boundary.
3. **Safe maintenance:** updates verify identity and checksum, preserve local
   edits, stage conflicts, reject drift, and recover interrupted transactions.

Operating an arbitrary consumer application end to end remains consumer-owned
research. Harness does not claim that installation alone supplies runtimes,
fixtures, credentials, logs, or interface automation.

## Protocol V1 End Of Life

The former SQLite `harness-cli` and machine protocol v1 ended support on
2026-08-10. The last published compatibility release is
`harness-cli-v0.1.22`. Existing consumers may pin that immutable release, but
the current repository no longer builds, installs, tests, or publishes it.

Harness does not automatically delete legacy binaries, databases, schemas, or
state from consumer repositories.

See
[`decision 0027`](docs/decisions/0027-end-protocol-v1-and-focus-repository-protocol.md).

## Development

```bash
scripts/validate-premerge.sh
```

The contract runs Rust formatting, tests, Clippy, installer and workflow
checks, release guards, documentation checks, shell syntax, and
`git diff --check`.
