# Known Issues and Limitations

## Bar Chart UTF-8 Display Issues

**Symptoms:** Bar chart blocks appear as mangled characters (`����`) instead of proper Unicode blocks (█, ▀).

**Cause:** This is a terminal encoding configuration issue, not a Miaou bug. The terminal must be configured to use UTF-8 encoding.

**Solutions:**
1. Ensure your terminal is set to UTF-8 encoding (most modern terminals default to this)
2. Check your `LANG` environment variable: `echo $LANG` (should contain `UTF-8`)
3. If using bash, add to `~/.bashrc`: `export LANG=en_US.UTF-8`
4. For zsh, add to `~/.zshrc`: `export LANG=en_US.UTF-8`
5. As a workaround, set `MIAOU_ASCII=1` to use ASCII characters instead of Unicode blocks

## Mouse Mode Not Disabled on Abnormal Exit

**Symptoms:** After pressing Ctrl+C in a demo, the terminal reports "unbound keyseq mouse" errors when using the mouse wheel.

**Cause:** The TUI enables xterm mouse tracking (modes 1000 and 1006) at startup. Mouse tracking must be properly disabled when the application exits.

**Fix Applied:**

The **actual root cause** was the `mouse_cleanup_done` flag preventing cleanup from running when it mattered most:

1. During normal operation (e.g., page navigation), `cleanup()` was being called and set `mouse_cleanup_done = true`
2. When Ctrl+C was pressed, the signal handler called `cleanup()` again
3. The flag check prevented mouse cleanup from running: `if not !mouse_cleanup_done then ...`
4. Result: Mouse tracking stayed enabled!

**Solution:**
- **Removed the `mouse_cleanup_done` flag entirely**
- Mouse cleanup now runs **every time** `cleanup()` is called
- Disabling mouse tracking is idempotent (safe to do multiple times)
- Signal handler runs cleanup synchronously, ensuring it completes before process termination
- Multi-method approach: writes escape sequences to /dev/tty, stdout, and stderr
- 200ms delay after sending sequences to give terminal time to process

**Technical Details:**
- Restore terminal to canonical mode BEFORE disabling mouse tracking
- Write directly to /dev/tty using `Unix.write` (bypasses stdio buffering)
- Use `Unix.tcdrain` to ensure bytes are transmitted to terminal hardware
- Triple-redundancy writes to handle edge cases

**Status:** ✅ FIXED. Tested and confirmed working in terminator, kitty, and konsole.

## Help Hint Documentation

The Help_hint module is fully documented in `src/miaou_core/help_hint.mli`. Key points:

- The driver intercepts "?" key presses before they reach your `handle_key` function
- Use `Help_hint.set`, `Help_hint.push`, and `Help_hint.pop` to manage contextual help
- See examples in the .mli file for usage patterns

This is working as designed and is well-documented.
