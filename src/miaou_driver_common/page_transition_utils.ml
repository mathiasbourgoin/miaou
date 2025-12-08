(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

open Miaou_core.Tui_page
module Registry = Miaou_core.Registry

type 'r handler = {
  on_quit : unit -> 'r;
  on_same_page : unit -> 'r;
  on_new_page :
    'new_s. (module PAGE_SIG with type state = 'new_s) -> 'new_s -> 'r;
}

let handle_next_page (type s r) (module P : PAGE_SIG with type state = s)
    (st : s) (handler : r handler) : r =
  match P.next_page st with
  | Some "__QUIT__" -> handler.on_quit ()
  | Some name -> (
      match Registry.find name with
      | Some (module Next : PAGE_SIG) ->
          let st_to = Next.init () in
          handler.on_new_page (module Next) st_to
      | None -> handler.on_quit ())
  | None -> handler.on_same_page ()
