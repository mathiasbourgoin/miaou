(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

(* Stub - to be implemented *)

type change =
  | MoveTo of int * int
  | SetStyle of Matrix_cell.style
  | WriteChar of string
  | WriteRun of string * int

let compute _buffer = []
