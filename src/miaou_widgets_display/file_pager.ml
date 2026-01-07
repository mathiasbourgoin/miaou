(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)
module Pager = Pager_widget

type tail_state = {
  path : string;
  mutable pos : int;
  mutable last_check : float;
  poll_interval_s : float;
  mutable closed : bool;
}

type t = {
  pager : Pager.t;
  mutable tail : tail_state option;
  mutable closed : bool;
  notify_render : unit -> unit;
}

let read_all_lines path =
  try
    let ic = open_in path in
    let rec loop acc =
      match input_line ic with
      | line -> loop (line :: acc)
      | exception End_of_file -> List.rev acc
    in
    let lines = loop [] in
    close_in ic ;
    lines
  with _ -> []

let make_tail path poll_interval_s =
  try
    let st = Unix.stat path in
    Some
      {
        path;
        pos = st.Unix.st_size;
        last_check = Unix.gettimeofday ();
        poll_interval_s;
        closed = false;
      }
  with _ -> None

let close_tail (ts : tail_state) = ts.closed <- true

let read_new_lines (ts : tail_state) pager =
  match try Some (Unix.stat ts.path) with _ -> None with
  | None -> false
  | Some st -> (
      if st.Unix.st_size < ts.pos then ts.pos <- st.Unix.st_size ;
      if st.Unix.st_size <= ts.pos then false
      else
        try
          let ic = open_in_bin ts.path in
          seek_in ic ts.pos ;
          let rec loop acc =
            match input_line ic with
            | line -> loop (line :: acc)
            | exception End_of_file -> (List.rev acc, pos_in ic)
          in
          let lines, new_pos = loop [] in
          close_in_noerr ic ;
          ts.pos <- new_pos ;
          if lines <> [] then (
            Pager.append_lines_batched pager lines ;
            true)
          else false
        with _ -> false)

(* Background thread for tailing - doesn't depend on Eio scheduler *)
let tail_thread_fn (fp : t) (ts : tail_state) =
  while (not fp.closed) && not ts.closed do
    let now = Unix.gettimeofday () in
    if now -. ts.last_check >= ts.poll_interval_s then (
      ts.last_check <- now ;
      let read_any = read_new_lines ts fp.pager in
      Pager.flush_pending_if_needed ~force:true fp.pager ;
      if read_any then fp.notify_render ()) ;
    Thread.delay ts.poll_interval_s
  done

let close (fp : t) =
  fp.closed <- true ;
  Option.iter
    (fun (ts : tail_state) ->
      close_tail ts ;
      fp.tail <- None ;
      Pager.stop_streaming fp.pager)
    fp.tail

let start_tail_watcher (fp : t) (ts : tail_state) =
  let _ = Thread.create (fun () -> tail_thread_fn fp ts) () in
  ()

let pager (fp : t) = fp.pager

let open_file ?(follow = false) ?notify_render ?(poll_interval = 0.25) path =
  try
    let lines = read_all_lines path in
    let pager = Pager.open_lines ~title:path ?notify_render lines in
    let notify_cb =
      match notify_render with
      | Some f -> f
      | None -> (
          match pager.Pager.notify_render with
          | Some f -> f
          | None -> fun () -> ())
    in
    let fp = {pager; tail = None; closed = false; notify_render = notify_cb} in
    if follow then (
      Pager.start_streaming fp.pager ;
      fp.pager.Pager.follow <- true ;
      match make_tail path poll_interval with
      | Some ts ->
          fp.tail <- Some ts ;
          start_tail_watcher fp ts
      | None -> ()) ;
    Ok fp
  with exn -> Error (Printexc.to_string exn)
