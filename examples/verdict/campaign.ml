open Alcobar

(* A campaign that counts its samples, and the coverage check that reads the
   count once the campaign is over. *)
let runs = ref 0
let count (_ : int) = incr runs

let coverage () =
  if !runs < 10 then failf "the campaign ran %d samples, under 10" !runs

let suite =
  ("campaign", [ test_case "count" [ int ] count; verdict "coverage" coverage ])

let () = run "campaign" [ suite ]
