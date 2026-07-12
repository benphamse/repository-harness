#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="${US100_EVIDENCE_DIR:-$ROOT_DIR/docs/stories/epics/E11-symphony-repository-separation/US-100-cutover-and-post-separation-audit/evidence}"
MODE="${1:---final}"

case "$MODE" in
  --readiness|--final) ;;
  *) echo "usage: $0 [--readiness|--final]" >&2; exit 2 ;;
esac

fail() { echo "US-100 verification failed: $*" >&2; exit 1; }
need() { test -e "$1" || fail "required evidence is missing: $1"; }

for command in jq shasum sqlite3; do
  command -v "$command" >/dev/null || fail "required command is missing: $command"
done

RELEASE="$EVIDENCE_DIR/symphony-release.json"
CUTOVER="$EVIDENCE_DIR/cutover-readiness.json"
OBSERVATION="$EVIDENCE_DIR/observation-window.json"
ROLLBACK="$EVIDENCE_DIR/rollback-rehearsal.json"
ROLLBACK_SUM="$ROLLBACK.sha256"

for file in "$RELEASE" "$CUTOVER" "$ROLLBACK" "$ROLLBACK_SUM"; do need "$file"; done

# The sidecar proves that the reviewed rollback record is the record being used.
(cd "$EVIDENCE_DIR" && shasum -a 256 -c "$(basename "$ROLLBACK_SUM")") >/dev/null \
  || fail "rollback rehearsal checksum does not match"
jq -e '
  .schema == "e11-us100-rollback-rehearsal-v1" and
  .mode == "scratch-copy-read-only" and
  .source_epoch.integrity_check == "ok" and .source_epoch.foreign_key_violations == 0 and
  .target_pre_reconcile_epoch.integrity_check == "ok" and .target_pre_reconcile_epoch.foreign_key_violations == 0 and
  .target_post_reconcile_epoch.integrity_check == "ok" and .target_post_reconcile_epoch.foreign_key_violations == 0 and
  (.source_bundle.sha256 | test("^[0-9a-f]{64}$")) and
  .source_bundle.verify == "complete history" and
  .target_raw_import_tag.tag == "symphony-raw-import-20260712" and
  (.target_raw_import_tag.peeled_commit | test("^[0-9a-f]{40}$"))
' "$ROLLBACK" >/dev/null || fail "rollback rehearsal record is incomplete"

# Pin the exact public Symphony release already independently downloaded and
# checksum-verified. A release URL or tag alone is not sufficient evidence.
jq -e '
  .schema == "e11-us100-symphony-release-v1" and
  .repository == "hoangnb24/symphony" and
  .tag == "symphony-v0.1.0" and
  .source_commit == "2357bc4f333a12794f975a46dbc0df96599fe4c0" and
  .draft == false and .prerelease == false and
  (.published_at | fromdateiso8601) > 0 and
  (.release_url | test("^https://github.com/hoangnb24/symphony/releases/tag/symphony-v0\\.1\\.0$")) and
  .download_verification.all_sidecars_passed == true and
  (.download_verification.verified_at | fromdateiso8601) > 0 and
  ([.archives[] | {key: .platform, value: .sha256}] | from_entries) == {
    "linux-arm64": "3615d178909931950d7624c8e5622b25d42fb8938013549ad8d52bcb28bfd45c",
    "linux-x64": "0efdf1e772010f850aee64f8bc758c6fe94131e103a7a1caea968db7522e7e55",
    "mac-arm64": "eb9d56bde05581c1fba56984937159218d4829b339385eb4ebafce835c049d90",
    "mac-x64": "0a3906dbfd8bd803715a0ad69c10aaed8c266047a2184543edb332e0dbc44574",
    "windows-x64": "1f5c6711e3c045fa70adfe8a9b44bf33ddc00b640b32bfdaef17ec667abf2390"
  } and
  ([.archives[].sha256] | length) == 5 and ([.archives[].sha256] | unique | length) == 5
' "$RELEASE" >/dev/null || fail "Symphony release identity or archive checksums do not match the approved release"

# Readiness describes the complete cutover tuple. It is deliberately separate
# from the observation record so it can pass before the seven-day clock closes.
jq -e '
  .schema == "e11-us100-cutover-readiness-v1" and
  .symphony.tag == "symphony-v0.1.0" and
  .symphony.source_commit == "2357bc4f333a12794f975a46dbc0df96599fe4c0" and
  .harness.initial_protocol.tag == "harness-cli-v0.1.14" and
  .harness.initial_protocol.source_commit == "d2f89eeabe8d01df95fd19cd6ba981b01a71730f" and
  (.harness.cleaned_core.tag | test("^harness-cli-v[0-9]+\\.[0-9]+\\.[0-9]+$")) and
  (.harness.cleaned_core.source_commit | test("^[0-9a-f]{40}$")) and
  (.harness.cleaned_core.archives | length) == 5 and
  all(.harness.cleaned_core.archives[]; (.sha256 | test("^[0-9a-f]{64}$")) and .verified == true) and
  .contracts.initial_protocol.protocol_version == 1 and
  .contracts.cleaned_core.protocol_version == 1 and
  (.contracts.initial_protocol.capabilities | type) == "array" and
  (.contracts.cleaned_core.capabilities | type) == "array" and
  .smokes.initial_protocol.status == "pass" and
  .smokes.cleaned_core.status == "pass" and
  .clean_harness_install.status == "pass" and
  .canonical_ownership_audit.status == "pass" and
  .runtime_disposition.status == "complete" and
  (.recorded_at | fromdateiso8601) > 0
' "$CUTOVER" >/dev/null || fail "cutover readiness record is incomplete"

DB="${HARNESS_DB_PATH:-$ROOT_DIR/harness.db}"
need "$DB"
test "$(sqlite3 "$DB" "SELECT count(*) FROM story WHERE id='US-100' AND status='in_progress';")" = 1 \
  || fail "US-100 must remain in_progress until final verification and explicit completion"

"$ROOT_DIR/tests/core/assert-durable-state-boundary.sh" >/dev/null \
  || fail "source durable-state ownership boundary failed"

for path in .agents .codex .impeccable; do
  test ! -e "$ROOT_DIR/$path" || fail "active checkout still contains $path"
done
if find "$ROOT_DIR/.harness/changesets" -type f -print -quit 2>/dev/null | grep -q .; then
  fail "active checkout contains live .harness/changesets files"
fi

if [[ "$MODE" == "--readiness" ]]; then
  echo "US-100 pre-observation readiness passed; story remains in_progress"
  exit 0
fi

need "$OBSERVATION"
"$ROOT_DIR/tests/cutover/assert-us100-observation-record.sh" "$OBSERVATION" >/dev/null \
  || fail "observation window is not eligible for closure"

echo "US-100 final observation gate passed; explicit story completion may now run"
