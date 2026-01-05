(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

(* Stub - to be implemented *)

type t = unit

let create () = ()

let reset () = ()

let render () _changes = ""

let cursor_hide = "\027[?25l"

let cursor_show = "\027[?25h"

let cursor_home = "\027[H"
