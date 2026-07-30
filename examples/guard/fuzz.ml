open Alcobar

(* A guard that can never hold, so no iteration ever reaches the property.
   Alcobar has to report that as a failure: a run that checked nothing is
   indistinguishable, to anyone reading the output, from a run whose property
   held every time. The [runtest] rule beside this expects a non-zero exit,
   which is what makes the expectation testable at all -- a passing binary is
   the bug. *)
let never_reached n =
  guard (n < 0 && n > 0);
  check false

let suite = ("guard", [ test_case "starved by its guard" [ int ] never_reached ])
let () = run "guard" [ suite ]
