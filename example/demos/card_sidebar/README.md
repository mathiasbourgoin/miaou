# Card + Sidebar layout

Use arrow keys to scroll this tutorial if needed.

- `Card_widget.render` wraps content with title/footer/accent styling.
- `Sidebar_widget.render` arranges a navigation column + main panel; we flip `~sidebar_open` on Tab.

## Usage Pattern

```ocaml
let view s ~focus:_ ~size =
  let cols = max 50 size.LTerm_geom.cols in
  let card = Card.create ~title:"Card title" ~footer:"Footer" () |> Card.render ~cols in
  let sidebar =
    Sidebar.create ~sidebar:"Navigation..." ~main:"Main content..." ~sidebar_open:s.sidebar_open ()
    |> Sidebar.render ~cols
  in
  String.concat "\n\n" ["Card & Sidebar demo"; card; sidebar]
```

## Key Features

- **Card Widget**: Bordered container with title, body, and footer
- **Sidebar Widget**: Two-column layout with collapsible sidebar
- **Accent Colors**: Customize card borders with ANSI color codes

## Keys

- Tab - Toggle sidebar open/closed
- t - Show this tutorial
- Esc - Return to launcher
