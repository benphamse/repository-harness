#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

validate_observation() { "$ROOT_DIR/tests/cutover/assert-us100-observation-record.sh" "$1" >/dev/null; }

cat >"$tmp/valid.json" <<'JSON'
{
  "schema":"e11-us100-observation-window-v1","owner":"hoangnb24","required_calendar_days":7,
  "started_at":"2026-07-12T00:00:00Z","eligible_end_at":"2026-07-19T00:00:00Z","closed_at":"2026-07-19T00:00:00Z",
  "real_development_cycle":{"completed":true,"completed_at":"2026-07-18T00:00:00Z","evidence":"cycle-1"},
  "blocking_signals":[
    {"class":"protocol_mismatch","observed":false,"recovery":"compatible release tuple"},
    {"class":"state_loss_or_duplication","observed":false,"recovery":"paired state epoch"},
    {"class":"installer_or_release_regression","observed":false,"recovery":"installer/release revert"},
    {"class":"wrong_owner_active_suggestion","observed":false,"recovery":"selector ownership fence"},
    {"class":"platform_failure","observed":false,"recovery":"platform artifact withdrawal"}],
  "repairs":[],"rollback_artifacts_retained":true,"closure_decision":"complete_without_rollback"
}
JSON
validate_observation "$tmp/valid.json"

jq '.closed_at="2026-07-18T23:59:59Z"' "$tmp/valid.json" >"$tmp/early.json"
if validate_observation "$tmp/early.json"; then
  echo "observation gate accepted fewer than seven calendar days" >&2; exit 1
fi
jq '.real_development_cycle.completed=false' "$tmp/valid.json" >"$tmp/no-cycle.json"
if validate_observation "$tmp/no-cycle.json"; then
  echo "observation gate accepted a missing real development cycle" >&2; exit 1
fi
jq '.blocking_signals[0].observed=true' "$tmp/valid.json" >"$tmp/signal.json"
if validate_observation "$tmp/signal.json"; then
  echo "observation gate accepted a blocking signal" >&2; exit 1
fi
jq '.repairs=[{"at":"2026-07-15T00:00:00Z"}]' "$tmp/valid.json" >"$tmp/repair.json"
if validate_observation "$tmp/repair.json"; then
  echo "observation gate accepted a window that was not restarted after repair" >&2; exit 1
fi

echo "US-100 observation schema rejects early, cycle-free, signaled, and repaired windows"
