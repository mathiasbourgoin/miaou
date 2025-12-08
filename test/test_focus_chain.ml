open Alcotest
module Focus = Miaou_internals.Focus_chain

let test_cycle () =
  let f = Focus.create ~total:3 in
  let f, _ = Focus.handle_key f ~key:"Tab" in
  check (option int) "next focus" (Some 1) (Focus.current f) ;
  let f, _ = Focus.handle_key f ~key:"S-Tab" in
  check (option int) "prev focus" (Some 0) (Focus.current f)

let test_bubble_when_empty () =
  let f = Focus.create ~total:0 in
  let _, res = Focus.handle_key f ~key:"Tab" in
  check bool "bubbles when no focusable" true (res = `Bubble)

let () =
  run
    "focus_chain"
    [
      ( "focus",
        [
          test_case "cycle" `Quick test_cycle;
          test_case "empty" `Quick test_bubble_when_empty;
        ] );
    ]
