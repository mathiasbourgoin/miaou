# QR Code Widgets

QR codes encode text or URLs into scannable 2D barcodes. Useful for sharing links, configuration, or data.

## Usage Pattern

```ocaml
match Qr_code_widget.create ~data:"https://example.com" ~scale:2 () with
| Ok qr ->
    let output = Qr_code_widget.render qr ~focus:true in
    print_endline output
| Error err ->
    Printf.eprintf "QR generation failed: %s\n" err
```

## Key Features

- **Automatic error correction**: Built-in error correction (M level by default)
- **Version auto-selection**: Automatically chooses QR version based on data size
- **Scale parameter**: Control visual size (1-4x recommended for terminal)
- **Quiet zone**: Automatic 4-module border as per QR spec
- **Terminal-friendly**: Uses block characters for terminal display

## Integration Tips

- Use `update_data` to change QR content dynamically
- Scale of 1 for compact display, 2-3 for easy scanning
- Combine with modals for "Share" functionality
- Check return value - data might be too large for QR encoding

## Keys

- 1-4 - Switch between examples
- ? - Show tutorial
- q - Back to launcher

## Use Cases

- Share URLs or configuration in TUI apps
- Display API keys or tokens for mobile capture
- Quick data transfer to mobile devices
- 2FA setup flows (TOTP secrets)
