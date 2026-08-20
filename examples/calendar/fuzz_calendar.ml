open Alcobar
module C = CalendarLib.Calendar.Precise

let time =
  map [ int64 ] (fun a ->
      try C.from_mjd (Int64.to_float a /. 100_000_000_000_000.)
      with CalendarLib.Date.Out_of_bounds -> bad_test ())

let pp_time ppf t =
  pp ppf "%04d-%02d-%02d %02d:%02d:%02d" (C.year t)
    (C.month t |> C.Date.int_of_month)
    (C.day_of_month t) (C.hour t) (C.minute t) (C.second t)

let time = with_printer pp_time time

(* Subtracting two dates and adding the difference back should land on the
   second date. It does not when the day of the month has no counterpart in the
   month it lands in: 1711-06-30 plus (1713-03-29 - 1711-06-30), a period of
   1 year 8 months 30 days, gives 1713-04-01, because 1713-02-30 is normalised
   forward before the leftover days are added. That bug is in calendar, so the
   dune file beside this keeps the example out of runtest. *)
let test_calendar =
  test_case "calendar" [ time; time ] @@ fun t1 t2 ->
  guard (C.compare t1 t2 < 0);
  check_eq ~pp:pp_time ~eq:C.equal (C.add t1 (C.precise_sub t2 t1)) t2

let suite = ("calendar", [ test_calendar ])
