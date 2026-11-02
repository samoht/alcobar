open Alcobar

(* Every sample reaches "always", twice: the count is of samples, so a run of
   N samples reports N, and a runner that counted calls would report 2N. Half
   the samples are even, so "even" and "odd" are both reached in any run of a
   hundred samples. The [runtest] rule beside this reads the counts the run
   prints. *)
let parity n =
  reach "always";
  reach (if n land 1 = 0 then "even" else "odd");
  reach "always"

let suite =
  ( "outcomes",
    [ test_case ~outcomes:[ "always"; "even"; "odd" ] "parity" [ int ] parity ]
  )

let () = run "covered" [ suite ]
