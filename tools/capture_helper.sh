#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: capture_helper.sh [options] -- <command>

Options:
  --keystrokes PATH   Write keystrokes JSONL to PATH (default: ./miaou_capture_keystrokes_<ts>.jsonl)
  --frames PATH       Write frame JSONL to PATH (default: ./miaou_capture_frames_<ts>.jsonl)
  --dir DIR           Directory used for default capture files
  -h, --help          Show this help

Examples:
  ./tools/capture_helper.sh -- dune exec -- miaou.demo
  ./tools/capture_helper.sh --keystrokes casts/keys.jsonl --frames casts/frames.jsonl -- \
      dune exec -- miaou.demo --demo-mode
USAGE
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

KEYS=""
FRAMES=""
DIR=""
CMD=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --keystrokes)
      [[ $# -ge 2 ]] || { echo "--keystrokes requires a path" >&2; exit 2; }
      KEYS="$2"
      shift 2
      ;;
    --frames)
      [[ $# -ge 2 ]] || { echo "--frames requires a path" >&2; exit 2; }
      FRAMES="$2"
      shift 2
      ;;
    --dir)
      [[ $# -ge 2 ]] || { echo "--dir requires a path" >&2; exit 2; }
      DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      CMD=("$@")
      break
      ;;
    *)
      CMD=("$@")
      break
      ;;
  esac
done

if [[ ${#CMD[@]} -eq 0 ]]; then
  usage
  exit 1
fi

stamp() {
  date +%Y%m%d-%H%M%S
}

if [[ -n "$DIR" ]]; then
  export MIAOU_DEBUG_CAPTURE_DIR="$DIR"
fi
BASE_DIR="${MIAOU_DEBUG_CAPTURE_DIR:-$(pwd)}"
mkdir -p "$BASE_DIR"

if [[ -z "$KEYS" ]]; then
  KEYS="$BASE_DIR/miaou_capture_keystrokes_$(stamp).jsonl"
fi
if [[ -z "$FRAMES" ]]; then
  FRAMES="$BASE_DIR/miaou_capture_frames_$(stamp).jsonl"
fi

export MIAOU_DEBUG_KEYSTROKE_CAPTURE_PATH="$KEYS"
export MIAOU_DEBUG_FRAME_CAPTURE_PATH="$FRAMES"
export MIAOU_DEBUG_KEYSTROKE_CAPTURE="${MIAOU_DEBUG_KEYSTROKE_CAPTURE:-1}"
export MIAOU_DEBUG_FRAME_CAPTURE="${MIAOU_DEBUG_FRAME_CAPTURE:-1}"

printf '[capture] keystrokes -> %s\n' "$KEYS" >&2
printf '[capture] frames     -> %s\n' "$FRAMES" >&2
exec "${CMD[@]}"
