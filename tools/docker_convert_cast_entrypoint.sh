#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Nomadic Labs
set -eu

# Usage: docker_convert_cast_entrypoint.sh <input.cast> <output.gif>
echo "docker convert entrypoint starting in $(pwd)"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input.cast> <output.gif> - no cast provided, skipping conversion" >&2
  # Treat missing args as a no-op so CI convert step can continue when no casts exist.
  exit 0
fi

CAST_IN="$1"
GIF_OUT="$2"

if [ -f "$CAST_IN" ]; then
  echo "Found existing cast: $CAST_IN — skipping replay step"
else
  echo "Cast $CAST_IN not found — attempting to run replayer to produce it"
  # try to infer keystrokes file name from cast name (convention used by CI)
  base=$(basename "$CAST_IN" .cast)
  keystrokes_glob="*${base}*keystrokes*.jsonl"
  ks=$(ls $keystrokes_glob 2>/dev/null || true)
  if [ -n "$ks" ]; then
    KEYS="$ks"
  else
    echo "No keystrokes file matching $keystrokes_glob found; expecting caller to provide cast." >&2
    exit 3
  fi
  echo "Using keystrokes file: $KEYS"
  REPLAY_CMD="python3 tools/replay_tui.py --keystrokes $KEYS --initial-wait 1.0 --speed 0.6 --cols 120 --rows 40 --write-cast $CAST_IN --cast-cols 120 --cast-rows 40"
  echo "Running replay to write cast: $REPLAY_CMD"
  if sh -c "$REPLAY_CMD"; then
    echo "Replay finished and cast written to $CAST_IN"
  else
    echo "replay_tui failed" >&2
    exit 2
  fi
fi

echo "Converting $CAST_IN -> $GIF_OUT"

# Try converters in order: agg -> asciinema2gif -> svg-term + convert
if command -v agg >/dev/null 2>&1; then
  echo "Using agg to convert"
  # prefer agg with specific terminal geometry and theme/font options that produce the best result
  # Read cols/rows from cast header if present so agg uses the same geometry.
  CAST_COLS=120
  CAST_ROWS=40
  if [ -f "$CAST_IN" ]; then
    # first line of cast file is header json
    head1=$(head -n 1 "$CAST_IN" 2>/dev/null || true)
    if [ -n "$head1" ]; then
      # extract term.cols and term.rows using grep+sed (robust-ish)
      cols_val=$(printf '%s' "$head1" | sed -n "s/.*\"cols\"\s*:\s*\([0-9]*\).*/\1/p") || true
      rows_val=$(printf '%s' "$head1" | sed -n "s/.*\"rows\"\s*:\s*\([0-9]*\).*/\1/p") || true
      if [ -n "$cols_val" ]; then CAST_COLS=$cols_val; fi
      if [ -n "$rows_val" ]; then CAST_ROWS=$rows_val; fi
    fi
  fi
  echo "agg: using cols=$CAST_COLS rows=$CAST_ROWS"
  if agg --cols "$CAST_COLS" --rows "$CAST_ROWS" "$CAST_IN" "$GIF_OUT" --theme monokai --font-size 20; then
    echo "Wrote $GIF_OUT (agg)"
    exit 0
  else
    echo "agg conversion failed, falling back" >&2
  fi
fi

if python3 -m asciinema2gif "$CAST_IN" "$GIF_OUT"; then
  echo "Wrote $GIF_OUT (asciinema2gif)"
  exit 0
else
  echo "asciinema2gif failed, falling back" >&2
fi

if command -v npx >/dev/null 2>&1 && command -v convert >/dev/null 2>&1; then
  echo "Trying svg-term-cli (npx) + ImageMagick convert"
  TMP_SVG="/tmp/tui.svg"
  # svg-term-cli expects cast input and will render with the cast's cols/rows; specify no explicit pixel size
  if npx -y svg-term-cli@latest --in "$CAST_IN" --out "$TMP_SVG"; then
    # Use ImageMagick to convert svg -> gif and ensure image is not vertically cropped by forcing extent
    if convert "$TMP_SVG" -background black -alpha remove -coalesce "$GIF_OUT"; then
      echo "Wrote $GIF_OUT (svg-term+convert)"
      exit 0
    else
      echo "convert failed" >&2
    fi
  else
    echo "svg-term-cli failed" >&2
  fi
fi

echo "No converter succeeded. Please run conversion locally or ensure agg/asciinema2gif/svg-term/convert are available." >&2
exit 4
