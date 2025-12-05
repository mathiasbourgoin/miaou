(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(* Demo entrypoint for terminal-only (lambda-term) rendering.                *)
(*                                                                           *)
(*****************************************************************************)

let () =
  Demo_lib.register_all () ;
  Demo_lib.ensure_system_capability () ;
  Demo_lib.register_page () ;
  let page_name = Demo_lib.launcher_page_name in
  let page =
    match Miaou_core.Registry.find page_name with
    | Some p -> p
    | None -> failwith ("Demo page not registered: " ^ page_name)
  in
  ignore (Miaou_core.Tui_driver.run page)
