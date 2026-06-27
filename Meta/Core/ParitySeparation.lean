import Meta.Core.TwoPole

/-!
# Parity separation

This file formalizes parity as the minimal separating realization of the
operational two-pole structure.  It does not introduce arithmetic parity.  It
records two separated regimes whose visible projection is contracted, together
with the local repair carried by the formed regime.
-/

namespace Meta
namespace ClosedStabilityTheorem

/-! ## Minimal separated regimes -/

/-- The two separated regimes of the minimal parity realization. -/
inductive ParityRegime where
  | left
  | right

/-- The visible side obtained after contracting the regime distinction. -/
inductive ParityVisible where
  | contracted

/-- The visible projection forgets which separated regime is present. -/
def parityProjection : ParityRegime -> ParityVisible
  | _ => ParityVisible.contracted

/-! ## Projection and separation -/

/-- The left regime is separated from the right regime. -/
theorem parityRegime_left_ne_right :
    ParityRegime.left = ParityRegime.right -> False := by
  intro h
  cases h

/-- The right regime is separated from the left regime. -/
theorem parityRegime_right_ne_left :
    ParityRegime.right = ParityRegime.left -> False := by
  intro h
  cases h

/-- Both regimes have the same contracted visible projection. -/
theorem parityProjection_left_eq_right :
    parityProjection ParityRegime.left =
      parityProjection ParityRegime.right :=
  rfl

/-- Both regimes have the same contracted visible projection, in the reverse orientation. -/
theorem parityProjection_right_eq_left :
    parityProjection ParityRegime.right =
      parityProjection ParityRegime.left :=
  rfl

/-! ## Local repair -/

/-- Local repair of a formed parity regime after visible contraction. -/
structure ParityRegimeRepair
    (regime : ParityRegime) where
  visible : ParityVisible
  recovered : ParityRegime
  visible_eq_projection : visible = parityProjection regime
  recovered_eq_regime : recovered = regime

/-- The intrinsic local repair carried by each formed parity regime. -/
def parityRegimeRepair
    (regime : ParityRegime) :
    ParityRegimeRepair regime where
  visible := parityProjection regime
  recovered := regime
  visible_eq_projection := rfl
  recovered_eq_regime := rfl

/-! ## Two-pole realizations -/

/-- The left-to-right structural parity separation. -/
def parityStructuralTwoPole :
    StructuralTwoPole
      ParityRegime
      ParityVisible
      parityProjection where
  left := ParityRegime.left
  right := ParityRegime.right
  sameProjection := parityProjection_left_eq_right
  separatedInterface := parityRegime_left_ne_right

/-- The left-to-right operational parity separation. -/
def parityOperationalTwoPole :
    OperationalTwoPole
      ParityRegime
      ParityVisible
      parityProjection
      ParityRegimeRepair where
  formed := ParityRegime.left
  shadow := ParityRegime.right
  sameProjection := parityProjection_left_eq_right
  separated := parityRegime_left_ne_right
  repair := parityRegimeRepair ParityRegime.left
  recovered := ParityRegime.left
  recovered_eq_formed := rfl

/-- The right-to-left structural parity separation. -/
def parityOppositeStructuralTwoPole :
    StructuralTwoPole
      ParityRegime
      ParityVisible
      parityProjection where
  left := ParityRegime.right
  right := ParityRegime.left
  sameProjection := parityProjection_right_eq_left
  separatedInterface := parityRegime_right_ne_left

/-- The right-to-left operational parity separation. -/
def parityOppositeOperationalTwoPole :
    OperationalTwoPole
      ParityRegime
      ParityVisible
      parityProjection
      ParityRegimeRepair where
  formed := ParityRegime.right
  shadow := ParityRegime.left
  sameProjection := parityProjection_right_eq_left
  separated := parityRegime_right_ne_left
  repair := parityRegimeRepair ParityRegime.right
  recovered := ParityRegime.right
  recovered_eq_formed := rfl

/-! ## Consequences of the separating realization -/

/-- The operational parity realization has the same visible projection on both poles. -/
theorem parityOperationalTwoPole_sameVisible :
    parityProjection
      (operationalTwoPole_leftPole parityOperationalTwoPole) =
    parityProjection
      (operationalTwoPole_rightPole parityOperationalTwoPole) :=
  operationalTwoPole_sameVisible parityOperationalTwoPole

/-- The operational parity realization keeps its two regimes separated. -/
theorem parityOperationalTwoPole_separated :
    operationalTwoPole_leftPole parityOperationalTwoPole =
      operationalTwoPole_rightPole parityOperationalTwoPole -> False :=
  operationalTwoPole_separatedPoles parityOperationalTwoPole

/-- The opposite operational parity realization has the same visible projection on both poles. -/
theorem parityOppositeOperationalTwoPole_sameVisible :
    parityProjection
      (operationalTwoPole_leftPole parityOppositeOperationalTwoPole) =
    parityProjection
      (operationalTwoPole_rightPole parityOppositeOperationalTwoPole) :=
  operationalTwoPole_sameVisible parityOppositeOperationalTwoPole

/-- The opposite operational parity realization keeps its two regimes separated. -/
theorem parityOppositeOperationalTwoPole_separated :
    operationalTwoPole_leftPole parityOppositeOperationalTwoPole =
      operationalTwoPole_rightPole parityOppositeOperationalTwoPole -> False :=
  operationalTwoPole_separatedPoles parityOppositeOperationalTwoPole

/-- The structural parity separation refutes the short referential presentation. -/
theorem parityStructuralTwoPole_refutes_shortPresentation
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  structuralTwoPole_refutes_shortPresentation parityStructuralTwoPole short

/-- The operational parity separation refutes the short referential presentation. -/
theorem parityOperationalTwoPole_refutes_shortPresentation
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  operationalTwoPole_refutes_shortPresentation parityOperationalTwoPole short

/-- The opposite structural parity separation refutes the short referential presentation. -/
theorem parityOppositeStructuralTwoPole_refutes_shortPresentation
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  structuralTwoPole_refutes_shortPresentation parityOppositeStructuralTwoPole short

/-- The opposite operational parity separation refutes the short referential presentation. -/
theorem parityOppositeOperationalTwoPole_refutes_shortPresentation
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  operationalTwoPole_refutes_shortPresentation parityOppositeOperationalTwoPole short

/-- The operational parity separation refutes contractibility of the visible fiber. -/
theorem parityOperationalTwoPole_not_contractible
    (contractible :
      ContractibleReferentialGap
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  operationalTwoPole_not_contractible parityOperationalTwoPole contractible

/-- The opposite operational parity separation refutes contractibility of the visible fiber. -/
theorem parityOppositeOperationalTwoPole_not_contractible
    (contractible :
      ContractibleReferentialGap
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  operationalTwoPole_not_contractible parityOppositeOperationalTwoPole contractible

/-- No global visible reconstruction can recover both separated parity regimes. -/
def parityOperationalTwoPole_noProjectiveReconstruction :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False) :=
  operationalTwoPole_noProjectiveReconstruction parityOperationalTwoPole

/-- No global visible reconstruction can recover both opposite separated parity regimes. -/
def parityOppositeOperationalTwoPole_noProjectiveReconstruction :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False) :=
  operationalTwoPole_noProjectiveReconstruction parityOppositeOperationalTwoPole

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ParityRegime
#print axioms Meta.ClosedStabilityTheorem.ParityVisible
#print axioms Meta.ClosedStabilityTheorem.parityProjection
#print axioms Meta.ClosedStabilityTheorem.parityRegime_left_ne_right
#print axioms Meta.ClosedStabilityTheorem.parityRegime_right_ne_left
#print axioms Meta.ClosedStabilityTheorem.parityProjection_left_eq_right
#print axioms Meta.ClosedStabilityTheorem.parityProjection_right_eq_left
#print axioms Meta.ClosedStabilityTheorem.ParityRegimeRepair
#print axioms Meta.ClosedStabilityTheorem.parityRegimeRepair
#print axioms Meta.ClosedStabilityTheorem.parityStructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOppositeStructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_sameVisible
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_separated
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_sameVisible
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_separated
#print axioms Meta.ClosedStabilityTheorem.parityStructuralTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.parityOppositeStructuralTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_not_contractible
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_not_contractible
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_noProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_noProjectiveReconstruction
/- AXIOM_AUDIT_END -/
