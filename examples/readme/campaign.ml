open Alcobar

(* The library under test: a codec of decimal integers. *)
module Foo = struct
  let decode s =
    match int_of_string_opt s with Some n -> Ok n | None -> Error (`Msg s)

  let encode = string_of_int
end

[@@@part "campaign"]

let decoded = ref 0

let roundtrip buf =
  match Foo.decode buf with
  | Error _ -> ()
  | Ok v ->
      incr decoded;
      check_eq (Foo.decode (Foo.encode v)) (Ok v)

let enough_decoded () =
  if !decoded < 100 then failf "only %d samples decoded" !decoded

let suite =
  ( "foo",
    [
      test_case "roundtrip" [ bytes ] roundtrip;
      verdict "decoded" enough_decoded;
    ] )

[@@@part "end"]

let () = run "foo" [ suite ]
