# Pager Widget

The pager widget provides a scrollable, searchable text viewer with real-time file tailing support.

## Usage Pattern

```ocaml
(* Open a file with tailing *)
let file = File_pager.open_file ~follow:true "/var/log/syslog" in
let pager = File_pager.pager file in

(* Or open from lines *)
let pager = Pager.open_lines ~title:"My Log" ["line1"; "line2"] in

(* Render with size *)
Pager.render_with_size ~size pager ~focus:true
```

## Key Features

- **File tailing**: Use `~follow:true` to tail files in real-time
- **Search**: Press `/` to search, `n`/`p` for next/previous match
- **Follow mode**: Press `f` to toggle auto-scroll to bottom
- **Streaming mode**: Append lines programmatically with batching

## Keys

- / - Start search
- n - Next search match
- p - Previous search match
- f - Toggle follow mode (auto-scroll)
- a - Append a test line
- s - Toggle streaming mode
- Esc - Exit demo (or close search bar)

## Integration Tips

- Use `File_pager` for tailing real files
- Use `Pager.append_lines_batched` for high-frequency updates
- Call `Pager.flush_pending_if_needed` in refresh cycle
- Check `input_mode` to determine if search is active
