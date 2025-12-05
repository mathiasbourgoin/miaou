(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

[@@@warning "-32-34-37-69"]

open Tui_page
module Widgets = Miaou_widgets_display.Widgets

type t = private T

(* Local alias for outcome to ensure compilation when mli changes are applied *)
type outcome = [`Quit | `SwitchTo of string]

let size () = (Obj.magic 0 : t)

let poll_event () = "" (* placeholder synchronous event *)

let draw_text s =
  print_string s ;
  flush stdout

let clear () =
  print_string "\027[2J" ;
  flush stdout

let flush () = ()

let current_page : (module PAGE_SIG) option ref = ref None

let set_page (page_module : (module PAGE_SIG)) =
  current_page := Some page_module

let backend_choice () =
  match Sys.getenv_opt "MIAOU_DRIVER" with
  | Some v when String.lowercase_ascii (String.trim v) = "sdl" -> (
      if Sdl_enabled.enabled then `Sdl else `Lambda_term)
  | _ -> `Lambda_term

let run (initial_page : (module PAGE_SIG)) : outcome =
  Widgets.set_backend `Terminal ;
  (* Delegate to the requested backend driver. We keep a tail‑recursive loop to
     follow `SwitchTo` signals until a final `Quit`. *)
  let rec loop (page : (module PAGE_SIG)) : outcome =
    let outcome =
      match backend_choice () with
      | `Sdl ->
          Widgets.set_backend `Sdl ;
          Sdl_driver.run page
      | `Lambda_term ->
          Widgets.set_backend `Terminal ;
          Lambda_term_driver.run page
    in
    match outcome with
    | `Quit -> `Quit
    | `SwitchTo "__BACK__" -> `Quit (* demo/back semantics: exit demo *)
    | `SwitchTo next -> (
        match Registry.find next with
        | Some p -> loop p
        | None -> `Quit)
  in
  loop initial_page

let () =
  ignore size ;
  ignore poll_event ;
  ignore draw_text ;
  ignore clear ;
  ignore flush
