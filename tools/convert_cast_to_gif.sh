#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Nomadic Labs
# Lightweight helper to convert an asciinema cast to GIF.
# This script tries svg-term-cli (via npx) -> ImageMagick convert.
# It does not install packages; run locally where npx/convert are available.

CAST=${1:-recordings/miaou_logging_switch.cast}
OUT=${2:-recordings/miaou_logging_switch.gif}
WIDTH=${3:-120}
HEIGHT=${4:-40}

echo "Converting $CAST -> $OUT (width=$WIDTH height=$HEIGHT)"

if [ ! -f "$CAST" ]; then
  echo "Cast file not found: $CAST"
  exit 1
fi

if command -v npx >/dev/null 2>&1 && command -v convert >/dev/null 2>&1; then
  echo "Using npx svg-term-cli + ImageMagick convert"
  TMP_SVG="/tmp/tui_cast.svg"
  npx -y svg-term-cli@latest --in "$CAST" --out "$TMP_SVG" --width "$WIDTH" --height "$HEIGHT" || {
    echo "svg-term-cli failed. If your cast is asciicast v3, re-record locally with asciinema v2 or use a local re-record.";
    exit 2
  }
  convert "$TMP_SVG" "$OUT" || { echo "convert failed"; exit 3; }
  echo "Wrote $OUT"
  exit 0
fi

if command -v asciinema2gif >/dev/null 2>&1; then
  echo "Using asciinema2gif"
  asciinema2gif "$CAST" "$OUT" && echo "Wrote $OUT" && exit 0
fi

cat <<EOF
No suitable converter found in PATH.

Recommended local commands:
1) Re-record locally with a sufficiently large terminal and then convert locally:
   asciinema rec recordings/miaou_logging_switch.cast
   python3 tools/replay_tui.py --keystrokes recordings/miaou_logging_switch_keystrokes.jsonl --initial-wait 1.0 --speed 0.6 --cols 120 --rows 40
   # stop recording when replay finishes

2) Convert using npx + ImageMagick (on your machine):
   npx -y svg-term-cli --in recordings/miaou_logging_switch.cast --out /tmp/tui.svg --width 120 --height 40
   convert /tmp/tui.svg recordings/miaou_logging_switch.gif

3) Or install a dedicated tool:
   pipx install asciinema2gif  # then: asciinema2gif recordings/miaou_logging_switch.cast recordings/miaou_logging_switch.gif

This script is a convenience; run the commands above on a machine where you can install tools.
EOF

exit 0
