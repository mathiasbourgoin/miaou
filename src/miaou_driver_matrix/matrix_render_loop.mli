(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

(** Render loop for the Matrix driver.

    Manages frame rendering with configurable FPS cap. Uses Eio fibers
    for cooperative concurrency within the main event loop.

    The render loop computes diffs between front/back buffers and
    emits minimal ANSI sequences to update the terminal.
*)

(** Render loop state. *)
type t

(** Create a new render loop.
    @param config Configuration (FPS cap, debug mode)
    @param buffer Double buffer for diff computation
    @param writer ANSI writer for output generation
    @param terminal Terminal for output *)
val create :
  config:Matrix_config.t ->
  buffer:Matrix_buffer.t ->
  writer:Matrix_ansi_writer.t ->
  terminal:Matrix_terminal.t ->
  t

(** Request a frame to be rendered.
    Multiple requests before actual render are coalesced. *)
val request_frame : t -> unit

(** Render immediately if frame is pending.
    Call this from the main loop after updating the buffer.
    Returns true if a frame was rendered. *)
val render_if_needed : t -> bool

(** Force immediate render regardless of pending state. *)
val force_render : t -> unit

(** Shutdown the render loop. *)
val shutdown : t -> unit

(** Get current achieved FPS (for diagnostics). *)
val current_fps : t -> float

(** Check if a frame is pending. *)
val frame_pending : t -> bool
