import Meta.Core.DynamicParitySeparation

/-!
# Operational parity roles

This file orients a dynamic parity separation into two operational roles:
a locally closing role carried by the formed dynamic side, and a mediating role
carried by the shadow dynamic side.  It does not identify these roles with
arithmetic classes.  The orientation into `ParityRegime.left` or
`ParityRegime.right` is supplied by `DynamicParitySeparation`; the dynamic
status of the roles remains formed/shadow.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a

/-! ## Operational roles extracted from a dynamic parity separation -/

/--
Operational roles carried by a dynamic parity separation.

The closing role is the dynamic formed side, because that is where the local
repair is carried.  The mediating role is the dynamic shadow side, because that
is where the separated regime remains visible to the raccord.  Changing the
left/right orientation of the parity reading does not swap these dynamic roles.
-/
structure OperationalParityRoles
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
    {dynamicReturn :
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
    (raccord : DynamicParitySeparation dynamicReturn) :
    Type (max u v w x y z r s a) where
  closingRegime : ParityRegime
  mediatingRegime : ParityRegime
  closing_eq_formed :
    closingRegime =
      dynamicParitySeparation_formedRegime raccord
  mediating_eq_shadow :
    mediatingRegime =
      dynamicParitySeparation_shadowRegime raccord
  sameVisible :
    dynamicParitySeparation_formedVisible raccord =
      dynamicParitySeparation_shadowVisible raccord
  separated :
    closingRegime = mediatingRegime -> False
  dynamicRepair :
    RepairOf
      (operationalTwoPole_leftPole
        (dynamicParitySeparation_dynamicOperationalTwoPole raccord))
  noParityVisibleReconstruction :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False)

section OperationalParityRoles

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

/-! ## Canonical extraction from a dynamic parity separation -/

/-- Extract the operational parity roles carried by a dynamic parity separation. -/
def operationalParityRolesOfDynamicParitySeparation
    (raccord : DynamicParitySeparation dynamicReturn) :
    OperationalParityRoles raccord where
  closingRegime := dynamicParitySeparation_formedRegime raccord
  mediatingRegime := dynamicParitySeparation_shadowRegime raccord
  closing_eq_formed := rfl
  mediating_eq_shadow := rfl
  sameVisible := dynamicParitySeparation_sameParityVisible raccord
  separated := dynamicParitySeparation_separatedParityRegimes raccord
  dynamicRepair :=
    operationalTwoPole_repair
      (dynamicParitySeparation_dynamicOperationalTwoPole raccord)
  noParityVisibleReconstruction :=
    dynamicParitySeparation_noParityProjectiveReconstruction raccord

/--
Operational parity roles expose the generic mediated-role structure carried by
their dynamic parity separation.
-/
def operationalParityRoles_mediatedDynamicRoles
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    MediatedDynamicRoles
      (dynamicParitySeparation_roleCarrier raccord) where
  closingRole := roles.closingRegime
  mediatingRole := roles.mediatingRegime
  closing_eq_formed := roles.closing_eq_formed
  mediating_eq_shadow := roles.mediating_eq_shadow
  sameVisible := roles.sameVisible
  separated := roles.separated
  dynamicRepair := roles.dynamicRepair
  roleRepair :=
    dynamicRoleCarrier_roleRepair
      (dynamicParitySeparation_roleCarrier raccord)
  noRoleVisibleReconstruction := roles.noParityVisibleReconstruction

/-! ## Projections -/

/-- The closing parity regime of the operational role reading. -/
def operationalParityRoles_closingRegime
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    ParityRegime :=
  roles.closingRegime

/-- The mediating parity regime of the operational role reading. -/
def operationalParityRoles_mediatingRegime
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    ParityRegime :=
  roles.mediatingRegime

/-- The closing role is the formed dynamic regime. -/
theorem operationalParityRoles_closing_eq_formed
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    operationalParityRoles_closingRegime roles =
      dynamicParitySeparation_formedRegime raccord :=
  roles.closing_eq_formed

/-- The mediating role is the shadow dynamic regime. -/
theorem operationalParityRoles_mediating_eq_shadow
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    operationalParityRoles_mediatingRegime roles =
      dynamicParitySeparation_shadowRegime raccord :=
  roles.mediating_eq_shadow

/-- The operational roles expose the same parity visible on the formed and shadow sides. -/
theorem operationalParityRoles_sameVisible
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    dynamicParitySeparation_formedVisible raccord =
      dynamicParitySeparation_shadowVisible raccord :=
  roles.sameVisible

/-- The operational roles keep closing and mediating regimes separated. -/
theorem operationalParityRoles_separated
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    operationalParityRoles_closingRegime roles =
      operationalParityRoles_mediatingRegime roles -> False :=
  roles.separated

/-- The closing role carries the dynamic local repair. -/
def operationalParityRoles_dynamicRepair
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    RepairOf
      (operationalTwoPole_leftPole
        (dynamicParitySeparation_dynamicOperationalTwoPole raccord)) :=
  roles.dynamicRepair

/-- The operational role reading rules out global parity-visible reconstruction. -/
def operationalParityRoles_noParityVisibleReconstruction
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False) :=
  roles.noParityVisibleReconstruction

/-! ## Consequences -/

/-- Closing and mediating regimes have the same parity projection. -/
theorem operationalParityRoles_sameParityProjection
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    parityProjection (operationalParityRoles_closingRegime roles) =
      parityProjection (operationalParityRoles_mediatingRegime roles) := by
  calc
    parityProjection (operationalParityRoles_closingRegime roles) =
        parityProjection (dynamicParitySeparation_formedRegime raccord) :=
      congrArg parityProjection
        (operationalParityRoles_closing_eq_formed roles)
    _ = dynamicParitySeparation_formedVisible raccord :=
      Eq.symm
        (dynamicParitySeparation_formedVisible_eq_projection raccord)
    _ = dynamicParitySeparation_shadowVisible raccord :=
      operationalParityRoles_sameVisible roles
    _ = parityProjection (dynamicParitySeparation_shadowRegime raccord) :=
      dynamicParitySeparation_shadowVisible_eq_projection raccord
    _ = parityProjection (operationalParityRoles_mediatingRegime roles) :=
      congrArg parityProjection
        (Eq.symm (operationalParityRoles_mediating_eq_shadow roles))

/-- Operational parity roles refute a short presentation of the parity projection. -/
theorem operationalParityRoles_refutesParityShortPresentation
    {raccord : DynamicParitySeparation dynamicReturn}
    (_roles : OperationalParityRoles raccord)
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  dynamicParitySeparation_refutesParityShortPresentation raccord short

/-- Operational parity roles refute contractibility of the parity visible fiber. -/
theorem operationalParityRoles_parityNotContractible
    {raccord : DynamicParitySeparation dynamicReturn}
    (_roles : OperationalParityRoles raccord)
    (contractible :
      ContractibleReferentialGap
        ParityRegime
        ParityVisible
        parityProjection) :
    False :=
  dynamicParitySeparation_parityNotContractible raccord contractible

/-! ## Orientation constructors -/

/-- Extract operational roles after a left-to-right dynamic parity raccord. -/
def operationalParityRoles_leftRight
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
    OperationalParityRoles
      (dynamicParitySeparation_leftRight
        dynamicReturn
        regimeOf
        visibleOf
        formed_regime
        shadow_regime
        formed_visible
        shadow_visible) :=
  operationalParityRolesOfDynamicParitySeparation
    (dynamicParitySeparation_leftRight
      dynamicReturn
      regimeOf
      visibleOf
      formed_regime
      shadow_regime
      formed_visible
      shadow_visible)

/-- Extract operational roles after a right-to-left dynamic parity raccord. -/
def operationalParityRoles_rightLeft
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
    OperationalParityRoles
      (dynamicParitySeparation_rightLeft
        dynamicReturn
        regimeOf
        visibleOf
        formed_regime
        shadow_regime
        formed_visible
        shadow_visible) :=
  operationalParityRolesOfDynamicParitySeparation
    (dynamicParitySeparation_rightLeft
      dynamicReturn
      regimeOf
      visibleOf
      formed_regime
      shadow_regime
      formed_visible
      shadow_visible)

end OperationalParityRoles

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.OperationalParityRoles
#print axioms Meta.ClosedStabilityTheorem.operationalParityRolesOfDynamicParitySeparation
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_mediatedDynamicRoles
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_closingRegime
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_mediatingRegime
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_closing_eq_formed
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_mediating_eq_shadow
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_sameVisible
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_separated
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_dynamicRepair
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_noParityVisibleReconstruction
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_sameParityProjection
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_refutesParityShortPresentation
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_parityNotContractible
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_leftRight
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_rightLeft
/- AXIOM_AUDIT_END -/
