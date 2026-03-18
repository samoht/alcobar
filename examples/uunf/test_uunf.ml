open Alcobar

let uchar =
  map [ int32 ] (fun n ->
      let n = Int32.to_int n land 0xFFFFFFF mod 0x10FFFF in
      try Uchar.of_int n with Invalid_argument _ -> bad_test ())

let unicode = list1 uchar

let norm form str =
  let n = Uunf.create form in
  let rec add acc v =
    match Uunf.add n v with
    | `Uchar u -> add (u :: acc) `Await
    | `Await | `End -> acc
  in
  let rec go acc = function
    | [] -> List.rev (add acc `End)
    | v :: vs -> go (add acc (`Uchar v)) vs
  in
  go [] str

let unicode_to_string s =
  let b = Buffer.create 10 in
  List.iter (Uutf.Buffer.add_utf_8 b) s;
  Buffer.contents b

let pp_unicode ppf s =
  Fmt.pf ppf "@[<v 2>";
  Fmt.pf ppf "@[\"%s\"@]@ " (unicode_to_string s);
  s
  |> List.iter (fun u ->
      Fmt.pf ppf "@[U+%04x %s (%a)@]@ " (Uchar.to_int u) (Uucp.Name.name u)
        Uucp.Block.pp (Uucp.Block.block u));
  Fmt.pf ppf "@]\n"

let unicode = with_printer pp_unicode unicode

let test_normalization s =
  let nfc = norm `NFC s in
  let nfd = norm `NFD s in
  let nfkc = norm `NFKC s in
  let nfkd = norm `NFKD s in
  let tests =
    [
      (nfc, [ norm `NFC nfc; norm `NFC nfd ]);
      (nfd, [ norm `NFD nfc; norm `NFD nfd ]);
      ( nfkc,
        [
          norm `NFC nfkc;
          norm `NFC nfkd;
          norm `NFKC nfc;
          norm `NFKC nfd;
          norm `NFKC nfkc;
          norm `NFKC nfkd;
        ] );
      ( nfkd,
        [
          norm `NFD nfkc;
          norm `NFD nfkd;
          norm `NFKD nfc;
          norm `NFKD nfd;
          norm `NFKD nfkc;
          norm `NFKD nfkd;
        ] );
    ]
  in
  tests
  |> List.iter (fun (s, eqs) ->
      List.iter (fun s' -> check_eq ~pp:pp_unicode s s') eqs)

let suite =
  ("uunf", [ test_case "normalization" [ unicode ] test_normalization ])

let () = run "alcobar" [ suite ]
