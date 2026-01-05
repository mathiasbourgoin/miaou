(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)
(* Mock Logger implementation for examples and tests.
   This is a no-op logger - it discards all log messages to avoid
   corrupting the TUI display. For actual logging in demos, use the
   Logger_demo which writes to a file. *)

let logf _lvl _s = ()

let set_enabled _ = ()

let set_logfile _ = Ok ()

let register () =
  let module L = Miaou_interfaces.Logger_capability in
  L.set {L.logf; set_enabled; set_logfile}
