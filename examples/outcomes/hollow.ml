open Alcobar

(* A decoder that refuses everything: the property returns () on both
   branches, so without its declared outcomes it passes on every sample and
   says nothing about the decoded branch. With them, the run fails and names
   the outcome no sample reached. The [runtest] rule beside this expects a
   non-zero exit and reads the counts in the failure. *)
let decode (_ : string) : (string, string) result = Error "refused"

let roundtrip buf =
  match decode buf with
  | Ok v -> (
      reach "decoded";
      match decode v with Ok v' -> check_eq v v' | Error e -> fail e)
  | Error _ -> reach "refused"

let suite =
  ( "outcomes",
    [
      test_case ~outcomes:[ "decoded"; "refused" ] "roundtrip" [ bytes ]
        roundtrip;
    ] )

let () = run "hollow" [ suite ]
