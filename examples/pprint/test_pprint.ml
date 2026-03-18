open PPrint
open Crowbar
type t = (string * PPrint.document)
let doc = fix (fun doc -> choose [
  const ("", empty);
  const ("a", PPrint.char 'a');
  const ("123", string "123");
  const ("Hello", string "Hello");
  const ("awordwhichisalittlebittoolong",
         string "awordwhichisalittlebittoolong");
  const ("", hardline);
  map [range 10] (fun n -> ("", break n));
  map [range 10] (fun n -> ("", break n));
  map [doc; doc]
    (fun (sa,da) (sb,db) -> (sa ^ sb, da ^^ db));
  map [range 10; doc] (fun n (s,d) -> (s, nest n d));
  map [doc] (fun (s, d) -> (s, group d));
  map [doc] (fun (s, d) -> (s, align d))
])

let check_doc (s, d) =
  let b = Buffer.create 100 in
  let w = 40 in
  ToBuffer.pretty 1.0 w b d;
  let text = Bytes.to_string (Buffer.to_bytes b) in
  let ws = Re.(compile (rep (set " \t\n\r"))) in
  let del_ws s = Re.replace_string ws ~by:"" s in
  let mspace = Re.(compile (seq [compl [char ' ']; char ' '])) in
  String.split_on_char '\n' text |> List.iter (fun s ->
    if String.length s > w then
      if Re.execp ~pos:w mspace s then assert false);
  check_eq (del_ws s) (del_ws text)

let suite =
  ("pprint",
   [
     test_case "pprint" [doc] check_doc;
   ])

let () = run "crowbar" [ suite ]
