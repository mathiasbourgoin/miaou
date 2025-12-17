# Image Widgets

Display images in the terminal using Unicode half-blocks with ANSI colors.

## Usage Pattern

```ocaml
match Image_widget.load_from_file "logo.png" ~max_width:80 ~max_height:24 () with
| Ok img ->
    let output = Image_widget.render img ~focus:true in
    print_endline output
| Error err ->
    Printf.eprintf "Failed to load: %s\n" err
```

## Key Features

- **Format support**: PNG, BMP, PPM, PGM, PBM (via imagelib)
- **Aspect ratio preservation**: Automatically scales while maintaining proportions
- **Half-block rendering**: 2 pixels per character cell for better resolution
- **ANSI 256-color**: Maps RGB to closest terminal colors
- **Memory efficiency**: Nearest-neighbor scaling, minimal allocations

## Rendering Details

Terminal rendering uses Unicode half-blocks:
- Upper half block shows top pixel, bottom pixel in foreground and background colors
- Full block when both pixels same color
- Achieves 2x vertical resolution vs simple character art

## Integration Tips

- Call `load_from_file` once, cache the result
- Use `max_width`/`max_height` to fit terminal size
- For dynamic resizing, reload on terminal size change
- Consider showing loading state for large images

## Keys

- 1 - Show logo image
- 2 - Show procedural gradient
- ? - Show tutorial
- q - Back to launcher

## Use Cases

- Display logos or branding in TUI apps
- Show charts/graphs exported as images
- Preview image files in file browsers
- Display user avatars or thumbnails
