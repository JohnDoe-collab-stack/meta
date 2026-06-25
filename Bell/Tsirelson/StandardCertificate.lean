import LocalSemanticClosure.Standalone.Clean.meta.Bell.Tsirelson.Bound

/-!
# Standard Tsirelson certificate

This file strengthens the constructive Tsirelson layer without importing the
external mathlib CHSH theorem.

The previous layer proved that any positive sum-of-squares certificate yields a
certified bound.  This file names the standard Tsirelson certificate shape:

* the left square is `sqrtTwoInv * (A1 + A0) - B0`;
* the right square is `sqrtTwoInv * (A1 - A0) + B1`;
* the bound is `sqrtTwoCubed * 1`;
* the hierarchy places the standard bound between the classical and algebraic
  bounds.

The algebraic decomposition and positivity are carried as intrinsic positive
data.  This is the constructive role of the standard Tsirelson package inside
the present framework.
-/

namespace LocalSemanticClosure
namespace Standalone
namespace Clean
namespace ClosedStabilityTheorem

universe u

/-! ## Standard square terms -/

/-- The standard left square term in the Tsirelson sum-of-squares certificate. -/
def standardTsirelsonSquareLeft
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 1]
    (sqrtTwoInv : R)
    (tuple : BellTsirelsonObservableTuple R) :
    R :=
  sqrtTwoInv * (tuple.A1 + tuple.A0) - tuple.B0

/-- The standard right square term in the Tsirelson sum-of-squares certificate. -/
def standardTsirelsonSquareRight
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 1]
    (sqrtTwoInv : R)
    (tuple : BellTsirelsonObservableTuple R) :
    R :=
  sqrtTwoInv * (tuple.A1 - tuple.A0) + tuple.B1

/-- The standard Tsirelson bound value, written internally as `sqrtTwoCubed * 1`. -/
def standardTsirelsonBoundValue
    {R : Type u}
    [Mul R]
    [OfNat R 1]
    (sqrtTwoCubed : R) :
    R :=
  sqrtTwoCubed * 1

/-! ## Intrinsic standard certificate data -/

/--
Intrinsic data for the standard Tsirelson certificate.

This structure is the constructive replacement for importing the classical
mathlib theorem.  It carries the standard square terms through their scalar
`sqrtTwoInv`, the bound scalar `sqrtTwoCubed`, the positive square
decomposition, and the ambient subtraction-to-order rule needed to consume it.
-/
structure StandardTsirelsonCertificateData
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    (tuple : BellTsirelsonObservableTuple R) :
    Type u where
  sqrtTwoInv : R
  sqrtTwoCubed : R
  nonnegative_standardSquares :
    0 ≤
      sqrtTwoInv *
        (standardTsirelsonSquareLeft sqrtTwoInv tuple *
            standardTsirelsonSquareLeft sqrtTwoInv tuple +
          standardTsirelsonSquareRight sqrtTwoInv tuple *
            standardTsirelsonSquareRight sqrtTwoInv tuple)
  standard_decomposition :
    standardTsirelsonBoundValue sqrtTwoCubed - tuple.chsh =
      sqrtTwoInv *
        (standardTsirelsonSquareLeft sqrtTwoInv tuple *
            standardTsirelsonSquareLeft sqrtTwoInv tuple +
          standardTsirelsonSquareRight sqrtTwoInv tuple *
            standardTsirelsonSquareRight sqrtTwoInv tuple)
  le_of_sub_nonnegative :
    0 ≤ standardTsirelsonBoundValue sqrtTwoCubed - tuple.chsh ->
      tuple.chsh ≤ standardTsirelsonBoundValue sqrtTwoCubed

/--
The standard intrinsic data produces the generic sum-of-squares certificate of
the previous Tsirelson layer.
-/
def standardTsirelsonCertificate
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    (data : StandardTsirelsonCertificateData tuple) :
    BellTsirelsonSumOfSquaresCertificate
      tuple
      (standardTsirelsonBoundValue data.sqrtTwoCubed) where
  scale := data.sqrtTwoInv
  squareLeft :=
    standardTsirelsonSquareLeft data.sqrtTwoInv tuple
  squareRight :=
    standardTsirelsonSquareRight data.sqrtTwoInv tuple
  nonnegative_decomposition :=
    data.nonnegative_standardSquares
  decomposition :=
    data.standard_decomposition
  le_of_sub_nonnegative :=
    data.le_of_sub_nonnegative

/-- The standard intrinsic data yields the certified Tsirelson bound. -/
theorem standardTsirelsonBound_of_certificateData
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    (data : StandardTsirelsonCertificateData tuple) :
    tuple.chsh ≤ standardTsirelsonBoundValue data.sqrtTwoCubed :=
  bellTsirelsonBound_of_sumOfSquaresCertificate
    (standardTsirelsonCertificate data)

/-- The standard intrinsic data is a structured Tsirelson gap. -/
def standardTsirelsonStructuredGap
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    (data : StandardTsirelsonCertificateData tuple) :
    BellTsirelsonStructuredGap R where
  tuple := tuple
  tsirelsonBound :=
    standardTsirelsonBoundValue data.sqrtTwoCubed
  certificate :=
    standardTsirelsonCertificate data

/-! ## Standard hierarchy data -/

/--
Intrinsic hierarchy data for the standard Tsirelson bound.

The numerical interpretation is the usual `2 <= 2 * sqrt(2) <= 4`, but this
file keeps the comparison as constructive ordered data over the ambient carrier.
-/
structure StandardTsirelsonHierarchyData
    {R : Type u}
    [Mul R]
    [OfNat R 1]
    [OfNat R 2]
    [OfNat R 4]
    [LE R]
    (sqrtTwoCubed : R) :
    Type u where
  classical_le_standard :
    (2 : R) ≤ standardTsirelsonBoundValue sqrtTwoCubed
  standard_le_algebraic :
    standardTsirelsonBoundValue sqrtTwoCubed ≤ (4 : R)

/-- The standard hierarchy as a `BellTsirelsonBoundHierarchy`. -/
def standardTsirelsonBoundHierarchy
    {R : Type u}
    [Mul R]
    [OfNat R 1]
    [OfNat R 2]
    [OfNat R 4]
    [LE R]
    {sqrtTwoCubed : R}
    (hierarchy : StandardTsirelsonHierarchyData sqrtTwoCubed) :
    BellTsirelsonBoundHierarchy R where
  classicalBound := 2
  tsirelsonBound :=
    standardTsirelsonBoundValue sqrtTwoCubed
  algebraicBound := 4
  classical_le_tsirelson :=
    hierarchy.classical_le_standard
  tsirelson_le_algebraic :=
    hierarchy.standard_le_algebraic

/-! ## Full intrinsic standard row -/

/--
A full intrinsic standard Tsirelson package.

This is the positive internal datum consumed by the framework: the observable
tuple, the standard sum-of-squares certificate data, and the bound hierarchy for
the same standard bound value.
-/
structure StandardTsirelsonIntrinsicPackage
    (R : Type u)
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [OfNat R 2]
    [OfNat R 4]
    [LE R] :
    Type u where
  tuple : BellTsirelsonObservableTuple R
  certificateData : StandardTsirelsonCertificateData tuple
  hierarchyData :
    StandardTsirelsonHierarchyData certificateData.sqrtTwoCubed

/-- A full intrinsic standard package gives a Bell/Tsirelson row. -/
def standardTsirelsonRow
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [OfNat R 2]
    [OfNat R 4]
    [LE R]
    (package : StandardTsirelsonIntrinsicPackage R) :
    BellTsirelsonRow R where
  structuredGap :=
    standardTsirelsonStructuredGap package.certificateData
  hierarchy :=
    standardTsirelsonBoundHierarchy package.hierarchyData
  bound_matches_hierarchy :=
    rfl

/-- A full intrinsic standard package yields the hierarchy-level Tsirelson bound. -/
theorem standardTsirelsonRow_bound
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [OfNat R 2]
    [OfNat R 4]
    [LE R]
    (package : StandardTsirelsonIntrinsicPackage R) :
    (standardTsirelsonRow package).structuredGap.chsh ≤
      (standardTsirelsonRow package).hierarchy.tsirelsonBound :=
  BellTsirelsonRow.tsirelson_bound
    (standardTsirelsonRow package)

end ClosedStabilityTheorem
end Clean
end Standalone
end LocalSemanticClosure

/- AXIOM_AUDIT_BEGIN -/
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.standardTsirelsonSquareLeft
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.standardTsirelsonSquareRight
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.standardTsirelsonBoundValue
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.StandardTsirelsonCertificateData
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.standardTsirelsonCertificate
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.standardTsirelsonBound_of_certificateData
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.standardTsirelsonStructuredGap
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.StandardTsirelsonHierarchyData
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.standardTsirelsonBoundHierarchy
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.StandardTsirelsonIntrinsicPackage
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.standardTsirelsonRow
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.standardTsirelsonRow_bound
/- AXIOM_AUDIT_END -/
