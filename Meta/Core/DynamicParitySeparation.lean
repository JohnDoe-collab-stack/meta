import Meta.Core.DynamicTwoPole
import Meta.Core.ParitySeparation

/-!
# Dynamic parity separation

This file records the transversal raccord between a locally recovered dynamic
return and the minimal separating parity realization.  It does not assert that
every dynamic return is already a parity separation.  Instead, it packages the
positive data by which a dynamic return carries its own parity-regime reading.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a

/-! ## Dynamic return equipped with a parity-separating reading -/

/--
A locally recovered dynamic return equipped with an intrinsic reading into the
minimal parity separation.

The dynamic return keeps its own operational two-pole.  The `parityTwoPole`
field records the parity two-pole to which the dynamic formed/shadow poles are
read, while `regimeOf` and `visibleOf` give the actual readings of dynamic
interfaces and visibles.
-/
structure DynamicParitySeparation
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf) :
    Type (max u v w x y z r s a) where
  regimeOf : Interface -> ParityRegime
  visibleOf : Visible -> ParityVisible
  parityTwoPole :
    OperationalTwoPole
      ParityRegime
      ParityVisible
      parityProjection
      ParityRegimeRepair
  formed_regime :
    regimeOf dynamicReturn.localRecovery.formed =
      operationalTwoPole_leftPole parityTwoPole
  shadow_regime :
    regimeOf dynamicReturn.localRecovery.shadow =
      operationalTwoPole_rightPole parityTwoPole
  formed_visible :
    visibleOf (project dynamicReturn.localRecovery.formed) =
      parityProjection (regimeOf dynamicReturn.localRecovery.formed)
  shadow_visible :
    visibleOf (project dynamicReturn.localRecovery.shadow) =
      parityProjection (regimeOf dynamicReturn.localRecovery.shadow)

section DynamicParitySeparation

variable {Branch : Type u}
variable {complete : BidirectionalCompleteness.{u, v, w} Branch}
variable {coherence : RoundTripCoherence complete}
variable {branch : Branch}
variable {Source : Type a}
variable {Interface : Type x}
variable {WitnessOf : Interface -> Type y}
variable {RealizesInterface :
  StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
variable {Visible : Type r}
variable {project : Interface -> Visible}
variable {RepairOf : Interface -> Type s}
variable {dynamicReturn :
  LocallyRecoveredDynamicReturn
    complete
    coherence
    branch
    Source
    Interface
    WitnessOf
    RealizesInterface
    Visible
    project
    RepairOf}

/-! ## Exposed two-poles -/

/-- The operational two-pole carried by the dynamic return itself. -/
def dynamicParitySeparation_dynamicOperationalTwoPole
    (_raccord : DynamicParitySeparation dynamicReturn) :
    OperationalTwoPole Interface Visible project RepairOf :=
  dynamicReturn_operationalTwoPole dynamicReturn

/-- The parity operational two-pole to which the dynamic return is raccorded. -/
def dynamicParitySeparation_parityOperationalTwoPole
    (raccord : DynamicParitySeparation dynamicReturn) :
    OperationalTwoPole
      ParityRegime
      ParityVisible
      parityProjection
      ParityRegimeRepair :=
  raccord.parityTwoPole

/-- The structural two-pole carried by the dynamic return itself. -/
def dynamicParitySeparation_dynamicStructuralTwoPole
    (raccord : DynamicParitySeparation dynamicReturn) :
    StructuralTwoPole Interface Visible project :=
  operationalTwoPole_structural
    (dynamicParitySeparation_dynamicOperationalTwoPole raccord)

/-- The parity structural two-pole to which the dynamic return is raccorded. -/
def dynamicParitySeparation_parityStructuralTwoPole
    (raccord : DynamicParitySeparation dynamicReturn) :
    StructuralTwoPole ParityRegime ParityVisible parityProjection :=
  operationalTwoPole_structural
    (dynamicParitySeparation_parityOperationalTwoPole raccord)

/-! ## Readings of the dynamic formed and shadow sides -/

/-- The parity regime read from the formed dynamic interface. -/
def dynamicParitySeparation_formedRegime
    (raccord : DynamicParitySeparation dynamicReturn) :
    ParityRegime :=
  raccord.regimeOf dynamicReturn.localRecovery.formed

/-- The parity regime read from the shadow dynamic interface. -/
def dynamicParitySeparation_shadowRegime
    (raccord : DynamicParitySeparation dynamicReturn) :
    ParityRegime :=
  raccord.regimeOf dynamicReturn.localRecovery.shadow

/-- The parity visible read from the formed dynamic visible. -/
def dynamicParitySeparation_formedVisible
    (raccord : DynamicParitySeparation dynamicReturn) :
    ParityVisible :=
  raccord.visibleOf (project dynamicReturn.localRecovery.formed)

/-- The parity visible read from the shadow dynamic visible. -/
def dynamicParitySeparation_shadowVisible
    (raccord : DynamicParitySeparation dynamicReturn) :
    ParityVisible :=
  raccord.visibleOf (project dynamicReturn.localRecovery.shadow)

/-- The formed dynamic interface is read as the left pole of the chosen parity two-pole. -/
theorem dynamicParitySeparation_formedRegime_eq_leftPole
    (raccord : DynamicParitySeparation dynamicReturn) :
    dynamicParitySeparation_formedRegime raccord =
      operationalTwoPole_leftPole
        (dynamicParitySeparation_parityOperationalTwoPole raccord) :=
  raccord.formed_regime

/-- The shadow dynamic interface is read as the right pole of the chosen parity two-pole. -/
theorem dynamicParitySeparation_shadowRegime_eq_rightPole
    (raccord : DynamicParitySeparation dynamicReturn) :
    dynamicParitySeparation_shadowRegime raccord =
      operationalTwoPole_rightPole
        (dynamicParitySeparation_parityOperationalTwoPole raccord) :=
  raccord.shadow_regime

/-- The formed dynamic visible is compatible with the parity projection. -/
theorem dynamicParitySeparation_formedVisible_eq_projection
    (raccord : DynamicParitySeparation dynamicReturn) :
    dynamicParitySeparation_formedVisible raccord =
      parityProjection (dynamicParitySeparation_formedRegime raccord) :=
  raccord.formed_visible

/-- The shadow dynamic visible is compatible with the parity projection. -/
theorem dynamicParitySeparation_shadowVisible_eq_projection
    (raccord : DynamicParitySeparation dynamicReturn) :
    dynamicParitySeparation_shadowVisible raccord =
      parityProjection (dynamicParitySeparation_shadowRegime raccord) :=
  raccord.shadow_visible

/-! ## Consequences of the raccord -/

/-- The parity visibles read from the formed and shadow dynamic sides coincide. -/
theorem dynamicParitySeparation_sameParityVisible
    (raccord : DynamicParitySeparation dynamicReturn) :
    dynamicParitySeparation_formedVisible raccord =
      dynamicParitySeparation_shadowVisible raccord := by
  calc
    dynamicParitySeparation_formedVisible raccord =
        parityProjection (dynamicParitySeparation_formedRegime raccord) :=
      dynamicParitySeparation_formedVisible_eq_projection raccord
    _ =
        parityProjection
          (operationalTwoPole_leftPole
            (dynamicParitySeparation_parityOperationalTwoPole raccord)) :=
      congrArg parityProjection
        (dynamicParitySeparation_formedRegime_eq_leftPole raccord)
    _ =
        parityProjection
          (operationalTwoPole_rightPole
            (dynamicParitySeparation_parityOperationalTwoPole raccord)) :=
      operationalTwoPole_sameVisible
        (dynamicParitySeparation_parityOperationalTwoPole raccord)
    _ =
        parityProjection (dynamicParitySeparation_shadowRegime raccord) :=
      Eq.symm
        (congrArg parityProjection
          (dynamicParitySeparation_shadowRegime_eq_rightPole raccord))
    _ = dynamicParitySeparation_shadowVisible raccord :=
      Eq.symm (dynamicParitySeparation_shadowVisible_eq_projection raccord)

/-- The parity regimes read from the formed and shadow dynamic sides remain separated. -/
theorem dynamicParitySeparation_separatedParityRegimes
    (raccord : DynamicParitySeparation dynamicReturn) :
    dynamicParitySeparation_formedRegime raccord =
      dynamicParitySeparation_shadowRegime raccord -> False := by
  intro h
  exact
    operationalTwoPole_separatedPoles
      (dynamicParitySeparation_parityOperationalTwoPole raccord)
      (by
        calc
          operationalTwoPole_leftPole
              (dynamicParitySeparation_parityOperationalTwoPole raccord) =
              dynamicParitySeparation_formedRegime raccord :=
            Eq.symm (dynamicParitySeparation_formedRegime_eq_leftPole raccord)
          _ = dynamicParitySeparation_shadowRegime raccord :=
            h
          _ =
              operationalTwoPole_rightPole
                (dynamicParitySeparation_parityOperationalTwoPole raccord) :=
            dynamicParitySeparation_shadowRegime_eq_rightPole raccord)

/-- The parity raccord refutes a short presentation of the parity projection. -/
theorem dynamicParitySeparation_refutesParityShortPresentation
    (raccord : DynamicParitySeparation dynamicReturn)
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  operationalTwoPole_refutes_shortPresentation
    (dynamicParitySeparation_parityOperationalTwoPole raccord)
    short

/-- The parity raccord refutes contractibility of the parity visible fiber. -/
theorem dynamicParitySeparation_parityNotContractible
    (raccord : DynamicParitySeparation dynamicReturn)
    (contractible :
      ContractibleReferentialGap
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  operationalTwoPole_not_contractible
    (dynamicParitySeparation_parityOperationalTwoPole raccord)
    contractible

/-- No global parity-visible reconstruction can recover both separated regimes. -/
def dynamicParitySeparation_noParityProjectiveReconstruction
    (raccord : DynamicParitySeparation dynamicReturn) :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False) :=
  operationalTwoPole_noProjectiveReconstruction
    (dynamicParitySeparation_parityOperationalTwoPole raccord)

/-! ## Orientation constructors -/

/-- Raccord a dynamic return to the left-to-right parity separation. -/
def dynamicParitySeparation_leftRight
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf)
    (regimeOf : Interface -> ParityRegime)
    (visibleOf : Visible -> ParityVisible)
    (formed_regime :
      regimeOf dynamicReturn.localRecovery.formed = ParityRegime.left)
    (shadow_regime :
      regimeOf dynamicReturn.localRecovery.shadow = ParityRegime.right)
    (formed_visible :
      visibleOf (project dynamicReturn.localRecovery.formed) =
        parityProjection (regimeOf dynamicReturn.localRecovery.formed))
    (shadow_visible :
      visibleOf (project dynamicReturn.localRecovery.shadow) =
        parityProjection (regimeOf dynamicReturn.localRecovery.shadow)) :
    DynamicParitySeparation dynamicReturn where
  regimeOf := regimeOf
  visibleOf := visibleOf
  parityTwoPole := parityOperationalTwoPole
  formed_regime := formed_regime
  shadow_regime := shadow_regime
  formed_visible := formed_visible
  shadow_visible := shadow_visible

/-- Raccord a dynamic return to the right-to-left parity separation. -/
def dynamicParitySeparation_rightLeft
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf)
    (regimeOf : Interface -> ParityRegime)
    (visibleOf : Visible -> ParityVisible)
    (formed_regime :
      regimeOf dynamicReturn.localRecovery.formed = ParityRegime.right)
    (shadow_regime :
      regimeOf dynamicReturn.localRecovery.shadow = ParityRegime.left)
    (formed_visible :
      visibleOf (project dynamicReturn.localRecovery.formed) =
        parityProjection (regimeOf dynamicReturn.localRecovery.formed))
    (shadow_visible :
      visibleOf (project dynamicReturn.localRecovery.shadow) =
        parityProjection (regimeOf dynamicReturn.localRecovery.shadow)) :
    DynamicParitySeparation dynamicReturn where
  regimeOf := regimeOf
  visibleOf := visibleOf
  parityTwoPole := parityOppositeOperationalTwoPole
  formed_regime := formed_regime
  shadow_regime := shadow_regime
  formed_visible := formed_visible
  shadow_visible := shadow_visible

end DynamicParitySeparation

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.DynamicParitySeparation
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_dynamicOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_parityOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_dynamicStructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_parityStructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_formedRegime
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_shadowRegime
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_formedVisible
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_shadowVisible
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_formedRegime_eq_leftPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_shadowRegime_eq_rightPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_formedVisible_eq_projection
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_shadowVisible_eq_projection
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_sameParityVisible
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_separatedParityRegimes
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_refutesParityShortPresentation
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_parityNotContractible
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_noParityProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_leftRight
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_rightLeft
/- AXIOM_AUDIT_END -/
