(lang dune 2.9)
(name alcobar)

(generate_opam_files true)

(source (github samoht/alcobar))
(license MIT)
(authors "Stephen Dolan <stephen.dolan@cl.cam.ac.uk>")
(maintainers "Thomas Gazagnaire <thomas@gazagnaire.org>")

(package
 (name alcobar)
 (synopsis "Write tests, let a fuzzer find failing cases")
 (description
"\| Alcobar is a library for testing code, combining QuickCheck-style
"\| property-based testing and the magical bug-finding powers of
"\| [afl-fuzz](http://lcamtuf.coredump.cx/afl/).
 )
 (depends
  (ocaml (>= "4.08"))
  alcotest
  (cmdliner (>= 1.1.0))
  (afl-persistent (>= "1.1"))
  ("calendar" (and (>= "2.00") :with-test))
  ("fpath" :with-test)
  ("pprint" :with-test)
  ("uucp" :with-test)
  ("uunf" :with-test)
  ("uutf" :with-test)))
