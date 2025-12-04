# Sample capture artifacts

The files in this directory are reference captures used for regression testing,
documentation, and screencast generation:

- `miaou_logging_create_keystrokes.jsonl` – manual keystrokes that walk through
  the demo launcher and open a few widgets.
- `miaou_logging_switch_keystrokes.jsonl` – keystrokes for toggling the demo
  logger between two simulated backends.
- `miaou_logging_switch_frames.jsonl` – a single-frame dump rendered from the
  demo’s logger view (used by `tools/replay_screencast.sh`).
- `miaou_logging_switch.cast` – asciinema v2 recording produced by replaying the
  keystrokes above against `miaou.demo` (input for
  `tools/convert_cast_to_gif.sh`).

Feel free to regenerate these artifacts with `./tools/capture_helper.sh` followed
by `./tools/replay_tui.py --keystrokes … --write-cast …`. If you do so, please
keep the filenames stable so downstream documentation and scripts keep working.
