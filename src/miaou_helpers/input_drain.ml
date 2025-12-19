(******************************************************************************)
(*                                                                            *)
(* SPDX-License-Identifier: MIT                                               *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                 *)
(*                                                                            *)
(******************************************************************************)

(* Capability for draining pending input characters.

   This allows widgets like textboxes to process all buffered printable
   characters at once, preventing lag when typing fast. The driver registers
   a drain function that the widget can call. *)

type drain_fn = unit -> string list

let drain_ref : drain_fn option ref = ref None

let register fn = drain_ref := Some fn

let drain_pending_chars () =
  match !drain_ref with None -> [] | Some fn -> fn ()
