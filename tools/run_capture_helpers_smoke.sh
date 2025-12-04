#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Nomadic Labs
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

note() {
  printf '%s\n' "$1"
}

ok() {
  note "OK: $1"
  PASS=$((PASS + 1))
}

fail() {
  note "MISSING: $1" >&2
  FAIL=$((FAIL + 1))
}

check_file() {
  local path="$1"
  if [ -f "$path" ]; then
    ok "$path exists"
  else
    fail "$path"
  fi
}

check_exec() {
  local path="$1"
  if [ -x "$path" ]; then
    ok "$path executable"
  else
    fail "$path (not executable)"
  fi
}

check_nonempty() {
  local path="$1"
  if [ -s "$path" ]; then
    ok "$path non-empty"
  else
    fail "$path (empty or missing)"
  fi
}

note "Smoke test: capture helpers & sample artifacts"

check_file "$ROOT/tools/capture_helper.sh"
check_exec "$ROOT/tools/capture_helper.sh"
check_file "$ROOT/tools/replay_all_captures.sh"
check_exec "$ROOT/tools/replay_all_captures.sh"
check_file "$ROOT/tools/replay_tui.py"
check_exec "$ROOT/tools/replay_tui.py"
check_file "$ROOT/docs/CAPTURE_HELPER.md"
check_nonempty "$ROOT/recordings/README.md"

samples=(
  "$ROOT/recordings/miaou_logging_create_keystrokes.jsonl"
  "$ROOT/recordings/miaou_logging_switch_keystrokes.jsonl"
  "$ROOT/recordings/miaou_logging_switch_frames.jsonl"
  "$ROOT/recordings/miaou_logging_switch.cast"
)

for sample in "${samples[@]}"; do
  check_nonempty "$sample"
done

echo
note "Summary: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  note "Smoke test FAILED" >&2
  exit 2
else
  note "Smoke test PASSED"
fi
