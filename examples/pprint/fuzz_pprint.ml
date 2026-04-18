open PPrint
open Alcobar

let doc =
  fix (fun doc ->
      choose
        [
          const ("", empty);
          const ("a", PPrint.char 'a');
          const ("123", string "123");
          const ("Hello", string "Hello");
          const
            ( "awordwhichisalittlebittoolong",
              string "awordwhichisalittlebittoolong" );
          const ("", hardline);
          map [ range 10 ] (fun n -> ("", break n));
          map [ range 10 ] (fun n -> ("", break n));
          map [ doc; doc ] (fun (sa, da) (sb, db) -> (sa ^ sb, da ^^ db));
          map [ range 10; doc ] (fun n (s, d) -> (s, nest n d));
          map [ doc ] (fun (s, d) -> (s, group d));
          map [ doc ] (fun (s, d) -> (s, align d));
        ])

let ws_re = Re.compile (Re.rep (Re.set " \t\n\r"))
let newline_re = Re.compile (Re.char '\n')
let mspace_re = Re.compile (Re.seq [ Re.compl [ Re.char ' ' ]; Re.char ' ' ])

let check_doc (s, d) =
  let b = Buffer.create 100 in
  let w = 40 in
  ToBuffer.pretty 1.0 w b d;
  let text = Bytes.to_string (Buffer.to_bytes b) in
  let del_ws = Re.replace_string ws_re ~by:"" in
  Re.split newline_re text
  |> List.iter (fun s ->
      if String.length s > w then
        match Re.exec ~pos:w mspace_re s with
        | _ -> assert false
        | exception Not_found -> ());
  check_eq (del_ws s) (del_ws text)

let test_pprint = test_case "pprint" [ doc ] check_doc
let suite = ("pprint", [ test_pprint ])
