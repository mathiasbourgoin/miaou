(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

(* Stub - to be implemented *)

type t = {mutable rows : int; mutable cols : int}

let setup () = {rows = 24; cols = 80}

let cleanup _t = ()

let enter_raw _t = ()

let leave_raw _t = ()

let size t = (t.rows, t.cols)

let invalidate_size_cache _t = ()

let enable_mouse _t = ()

let disable_mouse _t = ()

let fd _t = Unix.stdin

let write _t _s = ()

let install_signals _t _cleanup = Atomic.make false

let resize_pending _t = false

let clear_resize_pending _t = ()
