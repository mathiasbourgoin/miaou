(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

(** Configuration for the Matrix driver.

    Settings can be configured via environment variables:
    - MIAOU_MATRIX_FPS: Frame rate cap (default: 60)
    - MIAOU_MATRIX_DEBUG: Enable debug logging (default: false)
*)

type t = {
  fps_cap : int;  (** Maximum frames per second (1-120) *)
  frame_time_ms : float;  (** Minimum time between frames in ms *)
  debug : bool;  (** Enable debug logging *)
}

(** Default configuration: 60 FPS, no debug. *)
val default : t

(** Load configuration from environment variables. *)
val load : unit -> t

(** Minimum frame time for given FPS. *)
val frame_time_of_fps : int -> float
