/-!
# Bare first-order arithmetic syntax

The grammar deliberately contains only the ordinary signature of first-order
arithmetic.  In particular, quotation, semantic closure, and fixed points are
not constructors of terms or formulas.
-/

namespace Meta
namespace BareArithmeticTarski

/-- Raw De Bruijn terms for the signature `{0, S, +, *}`. -/
inductive RawTerm where
  | bvar : Nat -> RawTerm
  | zero : RawTerm
  | succ : RawTerm -> RawTerm
  | add : RawTerm -> RawTerm -> RawTerm
  | mul : RawTerm -> RawTerm -> RawTerm
deriving DecidableEq

/-- Raw first-order formulas over equality and constructive connectives. -/
inductive RawFormula where
  | falsum : RawFormula
  | equal : RawTerm -> RawTerm -> RawFormula
  | conj : RawFormula -> RawFormula -> RawFormula
  | disj : RawFormula -> RawFormula -> RawFormula
  | impl : RawFormula -> RawFormula -> RawFormula
  | all : RawFormula -> RawFormula
  | ex : RawFormula -> RawFormula
deriving DecidableEq

/-- The standard numeral written using only `zero` and `succ`. -/
def RawTerm.numeral : Nat -> RawTerm
  | 0 => RawTerm.zero
  | Nat.succ value => RawTerm.succ (RawTerm.numeral value)

/-- Constructive negation is implication into falsity. -/
def RawFormula.neg (formula : RawFormula) : RawFormula :=
  RawFormula.impl formula RawFormula.falsum

/-- Syntactic truth, used only as an abbreviation. -/
def RawFormula.verum : RawFormula :=
  RawFormula.neg RawFormula.falsum

end BareArithmeticTarski
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.BareArithmeticTarski.RawTerm
#print axioms Meta.BareArithmeticTarski.RawFormula
#print axioms Meta.BareArithmeticTarski.RawTerm.numeral
/- AXIOM_AUDIT_END -/
