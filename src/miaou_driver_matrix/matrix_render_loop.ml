(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

(* Stub - to be implemented *)

type t = {mutable frame_pending : bool; mutable shutdown : bool}

let create ~config:_ ~buffer:_ ~writer:_ ~terminal:_ =
  {frame_pending = false; shutdown = false}

let request_frame t = t.frame_pending <- true

let shutdown t = t.shutdown <- true

let current_fps _t = 0.0
