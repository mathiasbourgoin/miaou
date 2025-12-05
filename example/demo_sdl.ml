(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(* Demo entrypoint that prefers SDL (if present) and falls back to TUI.      *)
(* Reuses the page registration from [demo.ml].                              *)
(*                                                                           *)
(*****************************************************************************)

let () =
  (* Ensure the demo capabilities/pages are registered. *)
  Demo_lib.register_all () ;
  Demo_lib.ensure_system_capability () ;
  Demo_lib.register_page () ;
  let page_name = Demo_lib.launcher_page_name in
  let page =
    match Miaou_core.Registry.find page_name with
    | Some p -> p
    | None -> failwith ("Demo page not registered: " ^ page_name)
  in
  match Miaou_runner_native.Runner_native.run page with
  | `Quit | `SwitchTo _ -> ()
