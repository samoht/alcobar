type data = Datum of string | Block of header * data list
and header = string

type _ ty =
  | Int : int ty
  | Bool : bool ty
  | Prod : 'a ty * 'b ty -> ('a * 'b) ty
  | List : 'a ty -> 'a list ty

let rec pp_ty : type a. _ -> a ty -> unit =
 fun ppf -> function
  | Int -> Fmt.pf ppf "Int"
  | Bool -> Fmt.pf ppf "Bool"
  | Prod (ta, tb) -> Fmt.pf ppf "Prod(%a,%a)" pp_ty ta pp_ty tb
  | List t -> Fmt.pf ppf "List(%a)" pp_ty t

let rec serialize : type a. a ty -> a -> data = function
  | Int -> fun n -> Datum (string_of_int n)
  | Bool -> fun b -> Datum (string_of_bool b)
  | Prod (ta, tb) ->
      fun (va, vb) -> Block ("pair", [ serialize ta va; serialize tb vb ])
  | List t -> fun vs -> Block ("list", List.map (serialize t) vs)

let rec deserialize : type a. a ty -> data -> a = function
  | Int -> (
      function
      | Datum s -> int_of_string s
      | Block _ -> failwith "expected Datum for Int")
  | Bool -> (
      function
      | Datum s -> bool_of_string s
      | Block _ -> failwith "expected Datum for Bool")
  | Prod (ta, tb) -> (
      function
      | Block ("pair", [ sa; sb ]) -> (deserialize ta sa, deserialize tb sb)
      | _ -> failwith "expected Block(pair, [_;_]) for Prod")
  | List t -> (
      function
      | Block ("list", ss) -> List.map (deserialize t) ss
      | _ -> failwith "expected Block(list, _) for List")
