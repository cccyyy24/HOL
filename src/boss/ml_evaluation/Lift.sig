signature Lift =
sig
  include Abbrev

  val lift_def_syntax   : (hol_type -> term option) * hol_type
                           -> string list * string list * term list
  val pp_lifter_def     : hol_type Parse.pprinter

end
