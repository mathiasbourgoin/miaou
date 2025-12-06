open Alcotest
module Toast = Miaou_widgets_layout.Toast_widget

let sample_time = 1_000.

let test_enqueue_and_render () =
  let t =
    Toast.empty () |> fun t ->
    Toast.enqueue ~now:sample_time t Toast.Info "hello" |> fun t ->
    Toast.enqueue ~now:(sample_time +. 1.) t Toast.Error "oops"
  in
  let rendered = Toast.render t ~cols:30 in
  check bool "first toast tag" true (String.contains rendered '[') ;
  check bool "info toast text" true (String.contains rendered 'h') ;
  check bool "error toast text" true (String.contains rendered 'o')

let test_tick_expires () =
  let t =
    Toast.empty () |> fun t ->
    Toast.enqueue ~ttl:1. ~now:sample_time t Toast.Info "short" |> fun t ->
    Toast.enqueue ~ttl:5. ~now:sample_time t Toast.Info "long"
  in
  let expired = Toast.tick ~now:(sample_time +. 2.) t in
  let rendered = Toast.render expired ~cols:20 in
  check bool "short toast removed" false (String.contains rendered 's') ;
  check bool "long toast kept" true (String.contains rendered 'l')

let test_position_ordering () =
  let t =
    Toast.empty ~position:`Bottom_right () |> fun t ->
    Toast.enqueue ~now:sample_time t Toast.Info "first" |> fun t ->
    Toast.enqueue ~now:(sample_time +. 1.) t Toast.Info "second"
  in
  let lines = String.split_on_char '\n' (Toast.render t ~cols:30) in
  match List.rev lines with
  | last :: _ ->
      check bool "last line is newest" true (String.contains last 'd')
  | _ -> Alcotest.fail "no lines rendered"

let () =
  run
    "feedback_widgets"
    [
      ( "toast",
        [
          test_case "enqueue and render" `Quick test_enqueue_and_render;
          test_case "tick expires stale entries" `Quick test_tick_expires;
          test_case
            "bottom positions stack newest last"
            `Quick
            test_position_ordering;
        ] );
    ]
