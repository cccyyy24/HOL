(* simpledump.ml -- test for Hollex *)
(* Keith Wansbrough 2001 *)

open Hollex
open Holparse
open Holparsesupp

let go t = print_string ((render_token t)^" ")

let _ = Stream.iter go (tokstream ModeMosml stdin)

