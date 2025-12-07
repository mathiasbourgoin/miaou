# SDL-Enhanced Chart Widgets

This directory now includes SDL-optimized versions of chart widgets that provide superior visual quality when running with the SDL backend.

## New Modules

### `sparkline_widget_sdl`
SDL-enhanced sparkline rendering with:
- **Smooth anti-aliased lines** instead of Unicode block characters
- **Filled area under curve** with transparency/gradient support
- **Pixel-level precision** vs character-cell quantization
- **Threshold lines** rendered as smooth horizontal lines

### `line_chart_widget_sdl`
SDL-enhanced line chart rendering with:
- **Vector-quality smooth lines** with anti-aliasing
- **Filled areas under curves** with alpha transparency
- **Smooth grid lines** and axes
- **Precise point plotting** at pixel resolution
- **Color thresholds** with smooth transitions

## Architecture

The SDL widgets follow this pattern:

```ocaml
type sdl_render_info = {
  renderer : Tsdl.Sdl.renderer;
  x : int;          (* pixel position *)
  y : int;          (* pixel position *)
  width : int;      (* in character cells *)
  height : int;     (* in character cells *)
  char_w : int;     (* character width in pixels *)
  char_h : int;     (* character height in pixels *)
}
```

### Usage Pattern

1. **Terminal Mode**: Continue using the base widget modules (`sparkline_widget`, `line_chart_widget`)
2. **SDL Mode**: Use the SDL-specific rendering functions with `render_sdl`

The SDL widgets provide `render_sdl` functions that take an `sdl_render_info` context and render directly to the SDL renderer, bypassing text rendering entirely.

## Key Differences: Text vs SDL Rendering

| Feature | Terminal (Text) | SDL (Graphics) |
|---------|----------------|----------------|
| Resolution | Character cells | Pixels |
| Lines | Unicode characters (─, │) | Vector lines |
| Curves | Block approximation (▂▃▄) | Smooth curves |
| Colors | 256 ANSI colors | Full RGB |
| Transparency | No | Yes (alpha blending) |
| Anti-aliasing | No | Yes |
| Fills | Character blocks | Smooth gradients |

## Color Codes

Both modes use ANSI color code strings for compatibility:
- `"31"` → Red (RGB: 220, 50, 47)
- `"32"` → Green (RGB: 133, 153, 0)
- `"33"` → Yellow (RGB: 181, 137, 0)
- `"34"` → Blue (RGB: 38, 139, 210)
- `"35"` → Magenta (RGB: 211, 54, 130)
- `"36"` → Cyan (RGB: 42, 161, 152)

SDL widgets internally convert ANSI codes to RGB for rendering.

## Integration with SDL Driver

To use SDL widgets in the driver, you need to:

1. Detect when SDL backend is active
2. Create `sdl_render_info` from current rendering context
3. Call `render_sdl` functions directly instead of text-based renders
4. Let the SDL driver handle the actual display

Example integration pattern (pseudocode):

```ocaml
match backend with
| `Terminal ->
    (* Use text rendering *)
    let output = Sparkline_widget.render sparkline ~focus ~show_value () in
    (* ... render text to terminal ... *)
    
| `Sdl ->
    (* Use SDL rendering *)
    let info = { renderer; x; y; width; height; char_w; char_h } in
    Sparkline_widget_sdl.render_sdl info sparkline ~focus ~show_value ()
    (* ... already drawn to SDL renderer ... *)
```

## Future Enhancements

Potential improvements for SDL rendering:
- [ ] Bezier curve smoothing for line charts
- [ ] Animated transitions between data updates
- [ ] 3D-style bars with shadows for bar charts
- [ ] Interactive tooltips on hover
- [ ] Export to PNG/SVG
- [ ] Custom gradients and color schemes
- [ ] Axis labels with proper font rendering

## Performance Notes

SDL rendering is generally faster than text rendering for complex charts because:
1. Direct pixel manipulation vs font rasterization
2. GPU acceleration for blending and fills
3. No ANSI parsing overhead
4. Batch rendering of primitives

However, for simple sparklines, text mode may be faster due to lower setup overhead.
