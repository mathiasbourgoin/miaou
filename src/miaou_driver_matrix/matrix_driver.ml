(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

(* Stub - to be implemented *)

let available = true

let run (_initial_page : (module Miaou_core.Tui_page.PAGE_SIG)) :
    [`Quit | `SwitchTo of string] =
  `Quit
