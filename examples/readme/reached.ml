open Alcobar

(* The library under test: a codec of decimal integers. *)
module Foo = struct
  let decode s =
    match int_of_string_opt s with Some n -> Ok n | None -> Error (`Msg s)

  let encode = string_of_int
end

[@@@part "roundtrip"]

let roundtrip buf =
  match Foo.decode buf with
  | Error _ -> reach "refused"
  | Ok v ->
      reach "decoded";
      check_eq (Foo.decode (Foo.encode v)) (Ok v)

let suite =
  ( "foo",
    [
      test_case ~outcomes:[ "decoded"; "refused" ] "roundtrip" [ bytes ]
        roundtrip;
    ] )

[@@@part "end"]

let () = run "foo" [ suite ]
