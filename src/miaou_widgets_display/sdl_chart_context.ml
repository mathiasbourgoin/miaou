(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

(* Global SDL rendering context for chart widgets
   This allows chart widgets to detect SDL availability and render directly
   without changing the PAGE_SIG interface or creating circular dependencies. 
   
   We store SDL types as abstract values to avoid hard tsdl dependency here.
   The SDL driver and chart rendering code will cast appropriately. *)

type sdl_context = {
  renderer_obj : Obj.t; (* Tsdl.Sdl.renderer *)
  font_obj : Obj.t; (* Tsdl_ttf.Ttf.font *)
  char_w : int;
  char_h : int;
  mutable y_offset : int;
  enabled : bool; (* Set to false during transitions to avoid duplicate rendering *)
  cols : int; (* Terminal width in columns *)
}

let current_context : sdl_context option ref = ref None

let set_context_obj ~renderer ~font ~char_w ~char_h ~y_offset ~cols ?(enabled=true) () =
  current_context := Some {
    renderer_obj = Obj.repr renderer;
    font_obj = Obj.repr font;
    char_w;
    char_h;
    y_offset;
    enabled;
    cols;
  }

let clear_context () = current_context := None

let get_context () = 
  match !current_context with
  | Some ctx when ctx.enabled -> Some ctx
  | _ -> None

(* Extract renderer from context - caller must cast *)
let get_renderer ctx = Obj.obj ctx.renderer_obj

let get_font ctx = Obj.obj ctx.font_obj
