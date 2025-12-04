# Capture Helper

`tools/capture_helper.sh` is a tiny wrapper that exports the capture-related
environment variables (`MIAOU_DEBUG_KEYSTROKE_CAPTURE*`,
`MIAOU_DEBUG_FRAME_CAPTURE*`, `MIAOU_DEBUG_CAPTURE_DIR`) and then runs whatever
command you pass after `--`. Use it whenever you need to record fresh
keystroke/frame JSONL streams from a Miaou-based TUI.

## Usage

```sh
# record into ./recordings/
./tools/capture_helper.sh --dir recordings -- dune exec -- miaou.demo

# override individual artifact paths if desired
./tools/capture_helper.sh \
  --keystrokes /tmp/miaou_keystrokes.jsonl \
  --frames /tmp/miaou_frames.jsonl \
  -- dune exec -- miaou.demo --demo-mode
```

The helper prints the exact keystroke/frame paths before launching the demo, so
you can copy/paste them into PR descriptions or replay commands. The script does
**not** automate keystrokes—you still drive the UI manually to produce natural
captures.

## Verification checklist

1. Inspect the generated files to ensure they exist and are non-empty:
   ```sh
   ls -l recordings/*keystrokes*.jsonl
   ls -l recordings/*frames*.jsonl
   ```
2. Replay at least one capture locally:
   ```sh
   ./tools/replay_tui.py --keystrokes recordings/miaou_logging_switch_keystrokes.jsonl
   ```
3. Optional: run `./tools/replay_screencast.sh recordings/miaou_logging_switch_frames.jsonl`
   to eyeball the frame-by-frame screencast replay.

## Related helpers

- [`tools/replay_all_captures.sh`](../tools/replay_all_captures.sh) iterates over
  every `*keystrokes*.jsonl` file in a directory and replays them sequentially.
- [`tools/convert_cast_to_gif.sh`](../tools/convert_cast_to_gif.sh) turns an
  asciinema cast into a GIF (handy for PR descriptions).
- [`tools/docker_convert_cast_entrypoint.sh`](../tools/docker_convert_cast_entrypoint.sh)
  and [`Dockerfile.cast2gif`](../Dockerfile.cast2gif) provide a reproducible
  container image for CI conversions.

See [README.md](../README.md#recording--replay) for the bigger picture and the
sample artifacts that ship with the repository.
