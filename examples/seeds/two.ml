open Alcobar

(* Two cases that say which of them ran. Under AFL a seed of the second must
   run the second, with the bytes it was generated from. *)
let first (_ : int) = print_endline "first"
let second (_ : int) = print_endline "second"

let suite =
  ( "two",
    [ test_case "first" [ uint8 ] first; test_case "second" [ uint8 ] second ]
  )

let () = run "two" [ suite ]
