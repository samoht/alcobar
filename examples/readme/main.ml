open Alcobar

let identity = test_case "identity" [ int ] (fun x -> check_eq x x)
let () = run "my_lib" [ ("arith", [ identity ]) ]
