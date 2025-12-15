open Alcotest
module MR = Miaou_internals.Modal_renderer
module MS = Miaou_internals.Modal_snapshot

let test_overlay () =
  let seen = ref None in
  MS.set_provider (fun () ->
      [
        ( "Modal",
          Some 0,
          Some 10,
          true,
          fun size ->
            seen := Some size ;
            "overlay" );
      ]) ;
  let rendered = MR.render_overlay ~cols:(Some 20) ~rows:5 ~base:"base" () in
  match rendered with
  | None -> fail "expected overlay"
  | Some s -> (
      check bool "non-empty" true (String.length s > 0) ;
      match !seen with
      | None -> fail "expected modal view to be called"
      | Some size ->
          (* max_width=10 => content_width=6; rows=5 => max_height=5 => max_content_h=3 *)
          check int "content cols" 6 size.LTerm_geom.cols ;
          check int "content rows" 3 size.LTerm_geom.rows)

let suite = [test_case "render overlay" `Quick test_overlay]

let () = run "modal_renderer" [("modal_renderer", suite)]
