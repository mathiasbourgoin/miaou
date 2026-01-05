(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

(* Stub - to be implemented *)

type event = Key of string | Mouse of int * int | Resize | Timeout | Quit

type t = {fd : Unix.file_descr}

let create fd = {fd}

let poll _t ~timeout_ms:_ = Timeout

let drain_nav_keys _t _event = 0
