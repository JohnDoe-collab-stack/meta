import Meta.Bell.Tsirelson.StandardCertificate

/-!
# Standard Tsirelson algebraic CHSH package

This file is the next constructive step after
`StandardTsirelsonCertificate`.

The certificate layer consumed a fully positive standard certificate.  Here we
produce that certificate from more primitive intrinsic algebraic data:

* the standard CHSH observable tuple;
* the scalar `sqrtTwoInv` is nonnegative;
* squares are nonnegative;
* nonnegativity is closed under addition and left multiplication by a
  nonnegative scalar;
* the standard Tsirelson square decomposition holds;
* the usual hierarchy comparisons are carried internally.

This still avoids importing the external classical Tsirelson theorem.  The
remaining non-computational mathematical content is isolated in one algebraic
identity field, the standard square decomposition.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u

/-! ## Primitive algebraic CHSH data -/

/--
Primitive constructive algebraic data for the standard Tsirelson CHSH proof.

This package is deliberately smaller than `StandardTsirelsonCertificateData`:
it does not ask for nonnegativity of the whole standard sum-of-squares
expression.  That nonnegativity is derived from the square-positivity and
closure rules below.
-/
structure StandardTsirelsonAlgebraicCHSHData
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
  sqrtTwoInv_nonnegative :
    0 ≤ sqrtTwoInv
  square_nonnegative :
    (value : R) -> 0 ≤ value * value
  add_nonnegative :
    {left right : R} ->
      0 ≤ left ->
      0 ≤ right ->
        0 ≤ left + right
  left_mul_nonnegative :
    {scale value : R} ->
      0 ≤ scale ->
      0 ≤ value ->
        0 ≤ scale * value
  standard_square_decomposition :
    standardTsirelsonBoundValue sqrtTwoCubed - tuple.chsh =
      sqrtTwoInv *
        (standardTsirelsonSquareLeft sqrtTwoInv tuple *
            standardTsirelsonSquareLeft sqrtTwoInv tuple +
          standardTsirelsonSquareRight sqrtTwoInv tuple *
            standardTsirelsonSquareRight sqrtTwoInv tuple)
  le_of_sub_nonnegative :
    0 ≤ standardTsirelsonBoundValue sqrtTwoCubed - tuple.chsh ->
      tuple.chsh ≤ standardTsirelsonBoundValue sqrtTwoCubed

namespace StandardTsirelsonAlgebraicCHSHData

/-- The standard left square term carried by algebraic CHSH data. -/
def squareLeft
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    (data : StandardTsirelsonAlgebraicCHSHData tuple) :
    R :=
  standardTsirelsonSquareLeft data.sqrtTwoInv tuple

/-- The standard right square term carried by algebraic CHSH data. -/
def squareRight
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    (data : StandardTsirelsonAlgebraicCHSHData tuple) :
    R :=
  standardTsirelsonSquareRight data.sqrtTwoInv tuple

/--
The standard sum of squares is nonnegative, derived from primitive positivity
rules rather than carried as a final certificate field.
-/
theorem standardSquares_nonnegative
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    (data : StandardTsirelsonAlgebraicCHSHData tuple) :
    0 ≤
      data.sqrtTwoInv *
        (data.squareLeft * data.squareLeft +
          data.squareRight * data.squareRight) :=
  data.left_mul_nonnegative
    data.sqrtTwoInv_nonnegative
    (data.add_nonnegative
      (data.square_nonnegative data.squareLeft)
      (data.square_nonnegative data.squareRight))

end StandardTsirelsonAlgebraicCHSHData

/-! ## From primitive algebraic data to standard certificate data -/

/--
Primitive algebraic CHSH data produces the standard certificate data consumed
by the previous layer.
-/
def standardTsirelsonCertificateData_of_algebraicCHSH
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    (data : StandardTsirelsonAlgebraicCHSHData tuple) :
    StandardTsirelsonCertificateData tuple where
  sqrtTwoInv := data.sqrtTwoInv
  sqrtTwoCubed := data.sqrtTwoCubed
  nonnegative_standardSquares :=
    data.standardSquares_nonnegative
  standard_decomposition :=
    data.standard_square_decomposition
  le_of_sub_nonnegative :=
    data.le_of_sub_nonnegative

/-- Primitive algebraic CHSH data yields the standard certified Tsirelson bound. -/
theorem standardTsirelsonBound_of_algebraicCHSH
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    (data : StandardTsirelsonAlgebraicCHSHData tuple) :
    tuple.chsh ≤ standardTsirelsonBoundValue data.sqrtTwoCubed :=
  standardTsirelsonBound_of_certificateData
    (standardTsirelsonCertificateData_of_algebraicCHSH data)

/-- Primitive algebraic CHSH data yields a structured Tsirelson gap. -/
def standardTsirelsonStructuredGap_of_algebraicCHSH
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [LE R]
    {tuple : BellTsirelsonObservableTuple R}
    (data : StandardTsirelsonAlgebraicCHSHData tuple) :
    BellTsirelsonStructuredGap R :=
  standardTsirelsonStructuredGap
    (standardTsirelsonCertificateData_of_algebraicCHSH data)

/-! ## Full algebraic package with hierarchy -/

/--
Full primitive algebraic CHSH package.

This is the strongest internal package currently used by the framework: it
contains the observable tuple, the primitive algebraic data producing the
standard Tsirelson certificate, and the hierarchy comparisons for the same
standard bound.
-/
structure StandardTsirelsonAlgebraicCHSHPackage
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
  algebraicData :
    StandardTsirelsonAlgebraicCHSHData tuple
  hierarchyData :
    StandardTsirelsonHierarchyData algebraicData.sqrtTwoCubed

/--
A primitive algebraic CHSH package gives the full intrinsic standard
Tsirelson package.
-/
def standardTsirelsonIntrinsicPackage_of_algebraicCHSH
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [OfNat R 2]
    [OfNat R 4]
    [LE R]
    (package : StandardTsirelsonAlgebraicCHSHPackage R) :
    StandardTsirelsonIntrinsicPackage R where
  tuple := package.tuple
  certificateData :=
    standardTsirelsonCertificateData_of_algebraicCHSH
      package.algebraicData
  hierarchyData :=
    package.hierarchyData

/-- A primitive algebraic CHSH package gives the standard Bell/Tsirelson row. -/
def standardTsirelsonRow_of_algebraicCHSH
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [OfNat R 2]
    [OfNat R 4]
    [LE R]
    (package : StandardTsirelsonAlgebraicCHSHPackage R) :
    BellTsirelsonRow R :=
  standardTsirelsonRow
    (standardTsirelsonIntrinsicPackage_of_algebraicCHSH package)

/-- A primitive algebraic CHSH package yields the hierarchy-level Tsirelson bound. -/
theorem standardTsirelsonRow_bound_of_algebraicCHSH
    {R : Type u}
    [Add R]
    [Sub R]
    [Mul R]
    [OfNat R 0]
    [OfNat R 1]
    [OfNat R 2]
    [OfNat R 4]
    [LE R]
    (package : StandardTsirelsonAlgebraicCHSHPackage R) :
    (standardTsirelsonRow_of_algebraicCHSH package).structuredGap.chsh ≤
      (standardTsirelsonRow_of_algebraicCHSH package).hierarchy.tsirelsonBound :=
  BellTsirelsonRow.tsirelson_bound
    (standardTsirelsonRow_of_algebraicCHSH package)

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.StandardTsirelsonAlgebraicCHSHData
#print axioms Meta.ClosedStabilityTheorem.StandardTsirelsonAlgebraicCHSHData.squareLeft
#print axioms Meta.ClosedStabilityTheorem.StandardTsirelsonAlgebraicCHSHData.squareRight
#print axioms Meta.ClosedStabilityTheorem.StandardTsirelsonAlgebraicCHSHData.standardSquares_nonnegative
#print axioms Meta.ClosedStabilityTheorem.standardTsirelsonCertificateData_of_algebraicCHSH
#print axioms Meta.ClosedStabilityTheorem.standardTsirelsonBound_of_algebraicCHSH
#print axioms Meta.ClosedStabilityTheorem.standardTsirelsonStructuredGap_of_algebraicCHSH
#print axioms Meta.ClosedStabilityTheorem.StandardTsirelsonAlgebraicCHSHPackage
#print axioms Meta.ClosedStabilityTheorem.standardTsirelsonIntrinsicPackage_of_algebraicCHSH
#print axioms Meta.ClosedStabilityTheorem.standardTsirelsonRow_of_algebraicCHSH
#print axioms Meta.ClosedStabilityTheorem.standardTsirelsonRow_bound_of_algebraicCHSH
/- AXIOM_AUDIT_END -/
