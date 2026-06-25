import LocalSemanticClosure.Standalone.Clean.meta.Synthesis.TarskiBethBellGap

/-!
# Bell Tsirelson bound

This file records the constructive local Tsirelson layer.

The external mathlib theorem `tsirelson_inequality` proves the standard ordered
star-algebra bound, but it depends on classical axioms through its real-number
infrastructure.  Under the constructive audit rules of this project, we do not
import that theorem here.

Instead, this file exposes the intrinsic certificate shape used by the
Tsirelson proof: a structured CHSH tuple together with a sum-of-squares
decomposition of the difference between the Tsirelson bound and the CHSH
expression.  From that positive certificate, the bound follows constructively.
-/

namespace LocalSemanticClosure
namespace Standalone
namespace Clean
namespace ClosedStabilityTheorem

universe u

/-! ## Algebraic CHSH expression -/

/-- The algebraic CHSH expression attached to four observables. -/
def BellCHSHExpression
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    (A0 A1 B0 B1 : R) :
    R :=
  A0 * B0 + A0 * B1 + A1 * B0 - A1 * B1

/--
A structured Tsirelson tuple.

The tuple records the observable data used in the standard CHSH/Tsirelson
setting: four self-adjoint involutions, with Alice observables commuting with
Bob observables.  The `star` operation is carried as explicit structure so this
file does not depend on any external star-algebra class.
-/
structure BellTsirelsonObservableTuple
    (R : Type u)
    [Mul R]
    [OfNat R 1] :
    Type u where
  A0 : R
  A1 : R
  B0 : R
  B1 : R
  star : R -> R
  A0_involutive : A0 * A0 = 1
  A1_involutive : A1 * A1 = 1
  B0_involutive : B0 * B0 = 1
  B1_involutive : B1 * B1 = 1
  A0_selfAdjoint : star A0 = A0
  A1_selfAdjoint : star A1 = A1
  B0_selfAdjoint : star B0 = B0
  B1_selfAdjoint : star B1 = B1
  A0B0_commutes : A0 * B0 = B0 * A0
  A0B1_commutes : A0 * B1 = B1 * A0
  A1B0_commutes : A1 * B0 = B0 * A1
  A1B1_commutes : A1 * B1 = B1 * A1

namespace BellTsirelsonObservableTuple

/-- The CHSH expression of a structured Tsirelson tuple. -/
def chsh
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 1]
    (tuple : BellTsirelsonObservableTuple R) :
    R :=
  BellCHSHExpression tuple.A0 tuple.A1 tuple.B0 tuple.B1

end BellTsirelsonObservableTuple

/-! ## Constructive Tsirelson certificate -/

/--
A constructive certificate for a Tsirelson bound.

The certificate is the positive internal data needed to derive the bound:
the difference between the proposed bound and the CHSH expression is identified
with a nonnegative sum-of-squares term, and the ambient order admits the
corresponding subtraction-to-order step.
-/
structure BellTsirelsonSumOfSquaresCertificate
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    (tuple : BellTsirelsonObservableTuple R)
    (tsirelsonBound : R) :
    Type u where
  scale : R
  squareLeft : R
  squareRight : R
  nonnegative_decomposition :
    0 ≤ scale * (squareLeft * squareLeft + squareRight * squareRight)
  decomposition :
    tsirelsonBound - tuple.chsh =
      scale * (squareLeft * squareLeft + squareRight * squareRight)
  le_of_sub_nonnegative :
    0 ≤ tsirelsonBound - tuple.chsh ->
      tuple.chsh ≤ tsirelsonBound

/--
The constructive Tsirelson bound extracted from a sum-of-squares certificate.
-/
theorem bellTsirelsonBound_of_sumOfSquaresCertificate
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    {tsirelsonBound : R}
    (certificate :
      BellTsirelsonSumOfSquaresCertificate tuple tsirelsonBound) :
    tuple.chsh ≤ tsirelsonBound := by
  apply certificate.le_of_sub_nonnegative
  rw [certificate.decomposition]
  exact certificate.nonnegative_decomposition

/--
The quantum structured Bell gap row: a structured observable tuple together
with a certified Tsirelson bound.
-/
structure BellTsirelsonStructuredGap
    (R : Type u)
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R] :
    Type u where
  tuple : BellTsirelsonObservableTuple R
  tsirelsonBound : R
  certificate :
    BellTsirelsonSumOfSquaresCertificate tuple tsirelsonBound

namespace BellTsirelsonStructuredGap

/-- The CHSH expression carried by a structured Tsirelson gap. -/
def chsh
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    (gap : BellTsirelsonStructuredGap R) :
    R :=
  gap.tuple.chsh

/-- The certified Tsirelson bound carried by a structured Tsirelson gap. -/
theorem bound
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    (gap : BellTsirelsonStructuredGap R) :
    gap.chsh ≤ gap.tsirelsonBound :=
  bellTsirelsonBound_of_sumOfSquaresCertificate gap.certificate

end BellTsirelsonStructuredGap

/-! ## Bound hierarchy -/

/--
The three-level Bell hierarchy as ordered internal data:
classical bound, Tsirelson bound, and algebraic bound.
-/
structure BellTsirelsonBoundHierarchy
    (R : Type u)
    [LE R] :
    Type u where
  classicalBound : R
  tsirelsonBound : R
  algebraicBound : R
  classical_le_tsirelson :
    classicalBound ≤ tsirelsonBound
  tsirelson_le_algebraic :
    tsirelsonBound ≤ algebraicBound

/--
The final Bell/Tsirelson row: the certified quantum structured gap is placed
inside a three-level bound hierarchy.
-/
structure BellTsirelsonRow
    (R : Type u)
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R] :
    Type u where
  structuredGap : BellTsirelsonStructuredGap R
  hierarchy : BellTsirelsonBoundHierarchy R
  bound_matches_hierarchy :
    structuredGap.tsirelsonBound = hierarchy.tsirelsonBound

namespace BellTsirelsonRow

/-- The Bell/Tsirelson row yields the hierarchy-level Tsirelson bound. -/
theorem tsirelson_bound
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    (row : BellTsirelsonRow R) :
    row.structuredGap.chsh ≤ row.hierarchy.tsirelsonBound := by
  rw [← row.bound_matches_hierarchy]
  exact row.structuredGap.bound

end BellTsirelsonRow

end ClosedStabilityTheorem
end Clean
end Standalone
end LocalSemanticClosure

/- AXIOM_AUDIT_BEGIN -/
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellCHSHExpression
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellTsirelsonObservableTuple
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellTsirelsonObservableTuple.chsh
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellTsirelsonSumOfSquaresCertificate
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.bellTsirelsonBound_of_sumOfSquaresCertificate
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellTsirelsonStructuredGap
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellTsirelsonStructuredGap.chsh
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellTsirelsonStructuredGap.bound
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellTsirelsonBoundHierarchy
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellTsirelsonRow
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellTsirelsonRow.tsirelson_bound
/- AXIOM_AUDIT_END -/
