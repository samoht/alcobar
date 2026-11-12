(* One iteration outlives a one-second [--timeout], so the run fails with
   [Timeout]. Where the system has no SIGALRM (Windows) there is no
   per-iteration timeout, and the iteration finishes instead. *)

let () =
  Alcobar.run "timeout"
    [
      ( "timeout",
        [
          Alcobar.test_case "outlives the timeout" [ Alcobar.uint8 ] (fun _ ->
              Unix.sleepf 1.5);
        ] );
    ]
