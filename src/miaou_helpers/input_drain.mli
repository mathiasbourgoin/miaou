(******************************************************************************)
(*                                                                            *)
(* SPDX-License-Identifier: MIT                                               *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                 *)
(*                                                                            *)
(******************************************************************************)

(** Capability for draining pending input characters.

    This allows widgets like textboxes to process all buffered printable
    characters at once, preventing lag when typing fast. *)

(** Type of the drain function provided by the driver. *)
type drain_fn = unit -> string list

(** Register the drain function. Called by the driver at startup. *)
val register : drain_fn -> unit

(** Drain all pending printable characters from the input buffer.
    Returns a list of single-character strings (or "Backspace").
    Returns empty list if no drain function is registered or no pending input. *)
val drain_pending_chars : unit -> string list
