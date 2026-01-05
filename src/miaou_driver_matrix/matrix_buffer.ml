(*****************************************************************************)
(*                                                                           *)
(* SPDX-License-Identifier: MIT                                              *)
(* Copyright (c) 2025 Nomadic Labs <contact@nomadic-labs.com>                *)
(*                                                                           *)
(*****************************************************************************)

[@@@warning "-69"]

type t = {
  mutable rows : int;
  mutable cols : int;
  mutable front : Matrix_cell.t array array;
  mutable back : Matrix_cell.t array array;
}

let make_grid ~rows ~cols =
  Array.init rows (fun _ -> Array.init cols (fun _ -> Matrix_cell.empty ()))

let create ~rows ~cols =
  let rows = max 1 rows in
  let cols = max 1 cols in
  {rows; cols; front = make_grid ~rows ~cols; back = make_grid ~rows ~cols}

let resize t ~rows ~cols =
  let rows = max 1 rows in
  let cols = max 1 cols in
  let new_front = make_grid ~rows ~cols in
  let new_back = make_grid ~rows ~cols in
  (* Copy existing content where it fits *)
  let copy_rows = min t.rows rows in
  let copy_cols = min t.cols cols in
  for r = 0 to copy_rows - 1 do
    for c = 0 to copy_cols - 1 do
      new_front.(r).(c) <- Matrix_cell.copy t.front.(r).(c) ;
      new_back.(r).(c) <- Matrix_cell.copy t.back.(r).(c)
    done
  done ;
  {rows; cols; front = new_front; back = new_back}

let rows t = t.rows

let cols t = t.cols

let size t = (t.rows, t.cols)

let in_bounds t ~row ~col = row >= 0 && row < t.rows && col >= 0 && col < t.cols

let set t ~row ~col cell =
  if in_bounds t ~row ~col then t.back.(row).(col) <- cell

let set_from t ~row ~col cell =
  if in_bounds t ~row ~col then begin
    t.back.(row).(col).char <- cell.Matrix_cell.char ;
    t.back.(row).(col).style <- cell.Matrix_cell.style
  end

let get_back t ~row ~col =
  if in_bounds t ~row ~col then t.back.(row).(col) else Matrix_cell.empty ()

let clear_back t =
  for r = 0 to t.rows - 1 do
    for c = 0 to t.cols - 1 do
      Matrix_cell.reset t.back.(r).(c)
    done
  done

let set_char t ~row ~col ~char ~style =
  if in_bounds t ~row ~col then begin
    t.back.(row).(col).char <- char ;
    t.back.(row).(col).style <- style
  end

let get_front t ~row ~col =
  if in_bounds t ~row ~col then t.front.(row).(col) else Matrix_cell.empty ()

let swap t =
  let tmp = t.front in
  t.front <- t.back ;
  t.back <- tmp

let cell_changed t ~row ~col =
  if in_bounds t ~row ~col then
    not (Matrix_cell.equal t.front.(row).(col) t.back.(row).(col))
  else false

let mark_all_dirty t =
  (* Clear front buffer so all cells appear changed *)
  for r = 0 to t.rows - 1 do
    for c = 0 to t.cols - 1 do
      Matrix_cell.reset t.front.(r).(c)
    done
  done
