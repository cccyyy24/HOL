(* ========================================================================= *)
(* FILE          : smlExecute.sml                                            *)
(* DESCRIPTION   : Execute SML strings                                       *)
(* AUTHOR        : (c) Thibault Gauthier, University of Innsbruck            *)
(* DATE          : 2018                                                      *)
(* ========================================================================= *)

structure smlExecute :> smlExecute =
struct

open HolKernel Abbrev boolLib Tactical aiLib smlTimeout smlLexer

val ERR = mk_HOL_ERR "smlExec"

val sml_dir = HOLDIR ^ "/src/AI/sml_inspection"
val sml_code_dir = sml_dir ^ "/code"
val execprefix_glob = ref ""

(* -------------------------------------------------------------------------
   Global references
   ------------------------------------------------------------------------- *)

val sml_bool_glob = ref false
val sml_tactic_glob = ref (FAIL_TAC "smlExecute")
val sml_tacticl_glob = ref []
val sml_string_glob = ref ""
val sml_goal_glob = ref ([],F)
val sml_term_glob = ref T
val sml_termlist_glob = ref [T]
val sml_thm_glob = ref TRUTH
val sml_thml_glob = ref []

(* -------------------------------------------------------------------------
   Execute strings as sml code
   ------------------------------------------------------------------------- *)

fun exec_sml file s =
  let
    val _    = mkDir_err sml_code_dir
    val path = sml_code_dir ^ "/" ^ !execprefix_glob ^ "_" ^ file
    val oc   = TextIO.openOut path
    fun os s = TextIO.output (oc,s)
  in
    os s; TextIO.closeOut oc; can QUse.use path
  end

fun exec_poly file s =
  let
    val _    = mkDir_err sml_code_dir
    val path = sml_code_dir ^ "/" ^ !execprefix_glob ^ "_" ^ file
    val oc   = TextIO.openOut path
    fun os s = TextIO.output (oc,s)
  in
    os s; TextIO.closeOut oc; can PolyML.use path
  end


fun use_string s =
  let
    val stream = TextIO.openString s
    fun infn () = TextIO.input1 stream
  in
    PolyML.compiler (infn, []) ()
  end


(* -------------------------------------------------------------------------
   Tests
   ------------------------------------------------------------------------- *)

fun string_of_pretty p =
  let
    val acc = ref []
    fun f s = acc := s :: !acc
  in
    PolyML.prettyPrint (f,80) p;
    String.concatWith " " (rev (!acc))
  end

fun smltype_of_value l s =
  let
    val v = assoc s l handle HOL_ERR _ => raise ERR "type_of_value" s
    val t = PolyML.NameSpace.Values.typeof v
    val p = PolyML.NameSpace.Values.printType (t,0,NONE)
  in
    string_of_pretty p
  end

fun is_local_value s =
  mem s (map fst (#allVal (PolyML.globalNameSpace) ()))

fun is_thm_value l s =
  let
    val s1 = smltype_of_value l s
    val s2 = smlLexer.partial_sml_lexer s1
  in
    case s2 of
      [a] => (drop_sig a = "thm" handle HOL_ERR _ => false)
    | _   => false
  end

fun is_thm s = exec_sml "is_thm" ("val _ : Thm.thm = (" ^ s ^ ")")
fun is_tactic s = exec_sml "is_tactic" ("val _ : Tactic.tactic = (" ^ s ^ ")")
fun is_string s = exec_sml "is_string" ("val _ : String.string = (" ^ s ^ ")")
fun is_simpset s = 
  exec_sml "is_simpset" ("val _ : simpLib.simpset = (" ^ s ^ ")")
fun is_thml s = exec_sml "is_thm" ("val _ : Thm.thm List.list = (" ^ s ^ ")")


fun thm_of_sml s =
  if is_thm s then
    let val b = exec_sml "thm_of_sml" ("smlExecute.sml_thm_glob := " ^ s) in
      if b then SOME (s, !sml_thm_glob) else NONE
    end
  else NONE

fun thml_of_sml sl =
  let
    val s = "[" ^ String.concatWith ", " sl ^ "]"
    val b = exec_sml "thml_of_sml" ("smlExecute.sml_thml_glob := " ^ s)
  in
    if b then SOME (combine (sl, !sml_thml_glob)) else NONE
  end



fun is_pointer_eq s1 s2 =
  let
    val b = exec_sml "is_pointer_eq"
      ("val _ = smlExecute.sml_bool_glob := PolyML.pointerEq (" ^ s1 ^ "," ^
       s2 ^ ")")
  in
    b andalso (!sml_bool_glob)
  end

(* -------------------------------------------------------------------------
   Read tactics
   ------------------------------------------------------------------------- *)

fun mk_valid s = "Tactical.VALID (" ^ s ^ ")"

fun tactic_of_sml tim s =
  let
    val tactic = mk_valid s
    val program =
      "let fun f () = smlExecute.sml_tactic_glob := (" ^ tactic ^ ") in " ^
      "smlTimeout.timeout " ^ rts tim ^ " f () end"
    val b = exec_sml "tactic_of_sml" program
  in
    if b then !sml_tactic_glob else raise ERR "tactic_of_sml" s
  end

(* -------------------------------------------------------------------------
   Read string
   ------------------------------------------------------------------------- *)

fun string_of_sml s =
  let
    val b = exec_sml "string_of_sml"
      ("val _ = smlExecute.sml_string_glob := (" ^ s ^ " )")
  in
    if b then !sml_string_glob else raise ERR "string_of_sml" s
  end

fun is_stype s =
  let
    fun not_in cl c = not (mem c cl)
    fun test c = not_in [#"\t",#"\n",#" ",#"\""] c
  in
    List.find test (explode (rm_comment (rm_squote s))) = SOME #":"
  end

(* ------------------------------------------------------------------------
   Read goal
   ------------------------------------------------------------------------ *)

fun goal_of_sml s =
  let
    val b = exec_sml "goal_of_sml"
      ("val _ = smlExecute.sml_goal_glob := (" ^ s ^ " )")
  in
    if b then !sml_goal_glob else raise ERR "goal_of_sml" s
  end

(* -------------------------------------------------------------------------
   Apply tactic string
   ------------------------------------------------------------------------- *)

val (TC_OFF : tactic -> tactic) = trace ("show_typecheck_errors", 0)

fun app_stac tim stac g =
  let val tac = tactic_of_sml tim stac in
    SOME (fst (timeout tim (TC_OFF tac) g))
  end
  handle Interrupt => raise Interrupt | _ => NONE

end (* struct *)
