open Alcotest

let test_driver_flags () =
  ignore Miaou_runner_common.Html_driver.available ;
  ignore Miaou_driver_term.Lambda_term_driver.available ;
  ignore Miaou_driver_sdl.Sdl_enabled.enabled ;
  ignore (Miaou_runner_common.Tui_driver_common.size ())

let () =
  run
    "drivers_smoke"
    [("drivers_smoke", [test_case "driver flags" `Quick test_driver_flags])]
