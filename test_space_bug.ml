(* Test to demonstrate the Space key bug in edit mode *)
module FB = Miaou_widgets_layout.File_browser_widget

let stub_system =
  let open Miaou_interfaces in
  let run_command ~argv:_ ~cwd:_ =
    Ok System.{exit_code = 0; stdout = ""; stderr = ""}
  in
  System.
    {
      file_exists = (fun _ -> true);
      is_directory = (fun p -> not (String.ends_with ~suffix:".txt" p));
      read_file = (fun _ -> Ok "");
      write_file = (fun _ _ -> Ok ());
      mkdir = (fun _ -> Ok ());
      run_command;
      get_current_user_info = (fun () -> Ok ("user", "/home/user"));
      get_disk_usage = (fun ~path:_ -> Ok 0L);
      list_dir = (fun _ -> Ok ["node-mainnet"; "file.txt"]);
      probe_writable = (fun ~path:_ -> Ok true);
      get_env_var = (fun _ -> None);
    }

let () =
  Miaou_interfaces.System.set stub_system ;
  
  (* Create a file browser in browsing mode *)
  let w = FB.open_centered ~path:"/tmp" ~dirs_only:false () in
  Printf.printf "Initial mode: %s\n" (if FB.is_editing w then "EditingPath" else "Browsing");
  Printf.printf "Initial pending_selection: %s\n" 
    (match FB.get_pending_selection w with Some p -> p | None -> "None");
  
  (* Enter editing mode by pressing Tab *)
  let w = FB.handle_key w ~key:"Tab" in
  Printf.printf "\nAfter Tab - mode: %s\n" (if FB.is_editing w then "EditingPath" else "Browsing");
  Printf.printf "Pending selection: %s\n" 
    (match FB.get_pending_selection w with Some p -> p | None -> "None");
  
  (* Now press Space in edit mode *)
  let w = FB.handle_key w ~key:"Space" in
  Printf.printf "\nAfter Space in EditingPath - mode: %s\n" (if FB.is_editing w then "EditingPath" else "Browsing");
  Printf.printf "Pending selection: %s\n" 
    (match FB.get_pending_selection w with Some p -> p | None -> "None");
  Printf.printf "Input text: '%s'\n" (FB.current_input w);
  
  (* Check if the bug exists *)
  if FB.get_pending_selection w <> None then
    Printf.printf "\n❌ BUG CONFIRMED: Space in EditingPath mode set a pending selection!\n"
  else
    Printf.printf "\n✓ No bug: Space did not set a pending selection\n"
