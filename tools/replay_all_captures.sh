#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Nomadic Labs
set -euo pipefail

# Replay every *keystrokes*.jsonl capture inside a directory (defaults to
# recordings/) using tools/replay_tui.py. Additional arguments after -- are
# forwarded to the Python replayer.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CAP_DIR="$ROOT/recordings"
REPLAYER_ARGS=()

while (($#)); do
  case "$1" in
    --dir)
      if [ $# -lt 2 ]; then
        echo "--dir requires a path" >&2
        exit 64
      fi
      CAP_DIR="$2"
      shift 2
      ;;
    --)
      shift
      REPLAYER_ARGS=("$@")
      break
      ;;
    *)
      REPLAYER_ARGS+=("$1")
      shift
      ;;
  esac
done

if [ ! -d "$CAP_DIR" ]; then
  echo "No capture directory found at $CAP_DIR" >&2
  exit 1
fi

shopt -s nullglob
files=("$CAP_DIR"/*keystrokes*.jsonl)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  echo "No *keystrokes*.jsonl files found in $CAP_DIR" >&2
  exit 1
fi

for f in "${files[@]}"; do
  echo "[replay-all] Running tools/replay_tui.py for $f"
  python3 "$ROOT/tools/replay_tui.py" --keystrokes "$f" "${REPLAYER_ARGS[@]}" || {
    echo "Replay failed for $f" >&2
    exit 2
  }
  echo "[replay-all] ✔ $f"
  echo
done

echo "All captures replayed successfully."