(lang dune 3.21)
(using mdx 0.4)
(implicit_transitive_deps false)
(name alcobar)

(generate_opam_files true)

(source (uri https://github.com/samoht/alcobar))
(license MIT)
(authors "Stephen Dolan <stephen.dolan@cl.cam.ac.uk>")
(maintainers "Thomas Gazagnaire <thomas@gazagnaire.org>")

(package
 (name alcobar)
 (tags (org:blacksun test))
 (synopsis "Write tests, let a fuzzer find failing cases")
 (description
"\| Alcobar is a library for testing code, combining QuickCheck-style
"\| property-based testing and the magical bug-finding powers of
"\| [afl-fuzz](http://lcamtuf.coredump.cx/afl/).
 )
 (depends
  (ocaml (>= "4.11"))
  alcotest
  (fmt (>= 0.8.7))
  (mdx :with-test)
  base-unix
  (re (and :with-test (>= 1.11)))
  (cmdliner (>= 1.1.0))
  (afl-persistent (>= "1.1"))
  ("astring" :with-test)
  ("fpath" :with-test)
  ("pprint" :with-test)
  ("uucp" :with-test)
  ("uunf" :with-test)
  ("uutf" :with-test)))
