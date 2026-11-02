open Alcobar

(* An outcome the test does not declare is a misspelt one: counting it would
   leave the declared outcome at zero for a reason the report could not name.
   The [runtest] rule beside this expects a non-zero exit naming it. *)
let misspelt n = if n >= 0 then reach "non-negative" else reach "negativ"

let suite =
  ( "outcomes",
    [
      test_case
        ~outcomes:[ "non-negative"; "negative" ]
        "misspelt" [ int ] misspelt;
    ] )

let () = run "undeclared" [ suite ]
