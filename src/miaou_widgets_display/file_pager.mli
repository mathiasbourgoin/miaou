(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)
(** Pager widget wired to a file source with Eio fibers.

    This module tails a file using inotify (when available) and falls back to
    polling. All background work runs on the shared {!Miaou_helpers.Fiber_runtime}
    initialized from [Eio_main.run]. *)

type t

(** [open_file path] loads [path] into a pager and, when [follow] is true,
    starts a background fiber that appends new lines on change.

    @param poll_interval seconds between polls when inotify is unavailable
    @return [Error msg] if the runtime is not initialized or the file cannot
    be read. *)
val open_file :
  ?follow:bool ->
  ?notify_render:(unit -> unit) ->
  ?poll_interval:float ->
  string ->
  (t, string) result

(** Access the underlying pager. *)
val pager : t -> Pager_widget.t

(** Stop watching and close any external resources. *)
val close : t -> unit
