# Braille Chart Rendering

This demo compares ASCII and Braille rendering modes for chart widgets.

## What is Braille Mode?

Braille mode uses Unicode Braille patterns for higher resolution chart rendering:
- Each character cell contains a 2x4 dot grid (8 dots total)
- This provides 4x vertical resolution compared to ASCII mode
- Results in smoother curves and more detailed visualization

## Comparison

**ASCII Mode** uses traditional block characters:
- Characters like `_`, `|`, `^`, `v` for lines
- Lower resolution but universally compatible

**Braille Mode** uses Unicode Braille patterns:
- Characters from U+2800 to U+28FF range
- Smoother curves and better detail
- Requires Unicode/UTF-8 terminal support

## Keys

- b - Toggle between ASCII and Braille modes
- Esc - Return to launcher

## When to Use Each Mode

**ASCII Mode**:
- When terminal doesn't support Unicode well
- When copying output to plain text
- For maximum compatibility

**Braille Mode**:
- When visual quality matters
- For presentations or screenshots
- In modern terminals with good Unicode support
