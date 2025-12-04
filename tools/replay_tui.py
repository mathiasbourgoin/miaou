#!/usr/bin/env python3
"""Replay a Miaou-based TUI using a recorded keystroke JSONL file.

The JSONL format matches the files produced when running with
MIAOU_DEBUG_KEYSTROKE_CAPTURE*. Each line is a JSON object with at least
"timestamp" (float seconds) and "key" (string). The script replays the
keystrokes against the provided command, optionally writing an asciicast v3
recording of the session.
"""

from __future__ import annotations

import argparse
import json
import os
import pty
import select
import shlex
import struct
import sys
import termios
import time
import fcntl
from pathlib import Path

if sys.platform == "win32":
    raise SystemExit("replay_tui.py is not supported on Windows")


def load_events(path: str) -> list[tuple[float, str]]:
    with open(path, "r", encoding="utf8") as handle:
        lines = [line.strip() for line in handle if line.strip()]
    if not lines:
        raise SystemExit(f"no keystrokes found in {path}")
    records = [json.loads(line) for line in lines]
    start = records[0].get("timestamp", 0.0)
    return [(rec.get("timestamp", 0.0) - start, rec.get("key", "")) for rec in records]


def key_to_bytes(key: str) -> bytes:
    if key in {"Enter", "\n"}:
        return b"\r"
    if key == "Tab":
        return b"\t"
    if key == "Space" or key == " ":
        return b" "
    if key == "Backspace":
        return b"\x7f"
    if key == "Escape" or key == "Esc":
        return b"\x1b"
    arrows = {"Up": "A", "Down": "B", "Right": "C", "Left": "D"}
    if key in arrows:
        return b"\x1b[" + arrows[key].encode("ascii")
    if key.startswith("C-") and len(key) == 3:
        ch = key[-1]
        return bytes([ord(ch.upper()) - 64])
    if len(key) == 1:
        return key.encode("utf8")
    return key.encode("utf8")


def spawn(cmd: list[str], cols: int, rows: int) -> tuple[int, int]:
    master, slave = pty.openpty()
    try:
        winsize = struct.pack("HHHH", rows, cols, 0, 0)
        fcntl.ioctl(master, termios.TIOCSWINSZ, winsize)
    except OSError:
        pass

    pid = os.fork()
    if pid == 0:
        os.setsid()
        os.dup2(slave, 0)
        os.dup2(slave, 1)
        os.dup2(slave, 2)
        os.environ.setdefault("TERM", "xterm-256color")
        try:
            os.execvp(cmd[0], cmd)
        except Exception as exc:  # pragma: no cover - informative exit only
            print(f"exec failed: {exc}", file=sys.stderr)
            os._exit(127)
    os.close(slave)
    return master, pid


def replay(events: list[tuple[float, str]], cmd: list[str], *, initial_wait: float, cols: int, rows: int, write_cast: str | None, cast_cols: int | None, cast_rows: int | None) -> None:
    master, pid = spawn(cmd, cols, rows)
    out_events: list[tuple[float, str, str]] = []

    end = time.time() + max(0.4, initial_wait)
    while time.time() < end:
        ready, _, _ = select.select([master], [], [], 0.1)
        if master in ready:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                break
            if not chunk:
                break
            sys.stdout.buffer.write(chunk)
            sys.stdout.buffer.flush()
            if write_cast:
                out_events.append((time.time(), "o", chunk.decode("utf8", errors="replace")))

    base = time.time()
    for delay, key in events:
        target = base + delay
        if target > time.time():
            time.sleep(target - time.time())
        payload = key_to_bytes(key)
        try:
            os.write(master, payload)
            print(f"[replay] sent {key!r}", file=sys.stderr)
        except OSError:
            break
        ready, _, _ = select.select([master], [], [], 0.05)
        if master in ready:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                break
            if not chunk:
                break
            sys.stdout.buffer.write(chunk)
            sys.stdout.buffer.flush()
            if write_cast:
                out_events.append((time.time(), "o", chunk.decode("utf8", errors="replace")))

    time.sleep(0.4)
    try:
        os.kill(pid, 15)
    except OSError:
        pass

    while True:
        ready, _, _ = select.select([master], [], [], 0.1)
        if master not in ready:
            break
        try:
            chunk = os.read(master, 4096)
        except OSError:
            break
        if not chunk:
            break
        sys.stdout.buffer.write(chunk)
        sys.stdout.buffer.flush()
        if write_cast:
            out_events.append((time.time(), "o", chunk.decode("utf8", errors="replace")))

    if write_cast and out_events:
        term_cols = cast_cols or cols
        term_rows = cast_rows or rows
        header = {
            "version": 3,
            "term": {
                "cols": term_cols,
                "rows": term_rows,
                "type": os.environ.get("TERM", "xterm-256color"),
            },
            "timestamp": int(time.time()),
            "command": " ".join(cmd),
            "env": dict(os.environ),
        }
        with open(write_cast, "w", encoding="utf8") as cast_file:
            cast_file.write(json.dumps(header, ensure_ascii=False) + "\n")
            base_ts = out_events[0][0]
            for ts, kind, payload in out_events:
                rel = ts - base_ts
                cast_file.write(
                    json.dumps([round(rel, 6), kind, payload], ensure_ascii=False)
                    + "\n"
                )
        print(f"[replay] wrote cast to {write_cast}", file=sys.stderr)


def main() -> None:
    parser = argparse.ArgumentParser(description="Replay keystrokes against a Miaou TUI")
    parser.add_argument("--keystrokes", required=True, help="path to the JSONL keystrokes file")
    parser.add_argument(
        "--cmd",
        default="./_build/default/example/demo.exe",
        help="command to execute (default: ./_build/default/example/demo.exe)",
    )
    parser.add_argument("--initial-wait", type=float, default=0.6, help="seconds to wait before sending the first key")
    parser.add_argument("--speed", type=float, default=1.0, help="multiply recorded delays (e.g. 0.5 speeds up)")
    parser.add_argument("--cols", type=int, default=80, help="terminal columns")
    parser.add_argument("--rows", type=int, default=24, help="terminal rows")
    parser.add_argument("--write-cast", help="optional path to write an asciicast v3 recording")
    parser.add_argument("--cast-cols", type=int, help="override cols stored in the cast header")
    parser.add_argument("--cast-rows", type=int, help="override rows stored in the cast header")
    args = parser.parse_args()

    if not os.path.exists(args.keystrokes):
        raise SystemExit(f"keystrokes file not found: {args.keystrokes}")
    events = load_events(args.keystrokes)
    if args.speed != 1.0:
        events = [(delay * args.speed, key) for delay, key in events]

    command = shlex.split(args.cmd)
    if not command:
        raise SystemExit("empty command")
    if not shutil.which(command[0]):
        print(f"[replay] warning: command {command[0]!r} not found in PATH", file=sys.stderr)
    replay(
        events,
        command,
        initial_wait=args.initial_wait,
        cols=args.cols,
        rows=args.rows,
        write_cast=args.write_cast,
        cast_cols=args.cast_cols,
        cast_rows=args.cast_rows,
    )


if __name__ == "__main__":  # pragma: no cover
    import shutil

    main()
