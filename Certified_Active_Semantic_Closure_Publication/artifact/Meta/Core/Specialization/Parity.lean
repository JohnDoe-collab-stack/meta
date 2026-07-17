import Meta.Core.ProjectiveCore
import Meta.Core.DynamicRoleCarrier

/-!
# Minimal parity and dynamic parity specialization

The first part gives the autonomous minimal two-pole realization. The second
part specializes DynamicRoleCarrier by positive readings of a locally
recovered dynamic return into that realization. It does not derive a parity
reading from a dynamic return alone.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a

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

/-- The parity operational two-pole to which the dynamic return is connected. -/
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

/-- The parity structural two-pole to which the dynamic return is connected. -/
def dynamicParitySeparation_parityStructuralTwoPole
    (raccord : DynamicParitySeparation dynamicReturn) :
    StructuralTwoPole ParityRegime ParityVisible parityProjection :=
  operationalTwoPole_structural
    (dynamicParitySeparation_parityOperationalTwoPole raccord)

/-! ## Generic role-carrier reading -/

/--
A dynamic parity separation is a dynamic role carrier whose roles are the two
minimal parity regimes.
-/
def dynamicParitySeparation_roleCarrier
    (raccord : DynamicParitySeparation dynamicReturn) :
    DynamicRoleCarrier
      dynamicReturn
      ParityRegime
      ParityVisible
      parityProjection
      ParityRegimeRepair where
  roleOf := raccord.regimeOf
  visibleRoleOf := raccord.visibleOf
  roleTwoPole := raccord.parityTwoPole
  formed_role := raccord.formed_regime
  shadow_role := raccord.shadow_regime
  formed_visible := raccord.formed_visible
  shadow_visible := raccord.shadow_visible

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

/-! ## Operational roles extracted from a dynamic parity separation -/

/--
Operational roles carried by a dynamic parity separation.

The closing role is the dynamic formed side, because that is where the local
repair is carried.  The mediating role is the dynamic shadow side, because that
is where the separated regime remains visible to the raccord.  Changing the
left/right orientation of the parity reading does not swap these dynamic roles.
-/
structure OperationalParityRoles
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

/-! ## Operational role extraction and projections -/

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

/-! ## Operational role consequences -/

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

/-! ## Operational role orientation constructors -/

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

end DynamicParitySeparation

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ParityRegime
#print axioms Meta.ClosedStabilityTheorem.ParityVisible
#print axioms Meta.ClosedStabilityTheorem.parityProjection
#print axioms Meta.ClosedStabilityTheorem.ParityRegimeRepair
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_noProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.DynamicParitySeparation
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_roleCarrier
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_leftRight
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_rightLeft
#print axioms Meta.ClosedStabilityTheorem.OperationalParityRoles
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_mediatedDynamicRoles
#print axioms Meta.ClosedStabilityTheorem.operationalParityRoles_noParityVisibleReconstruction
/- AXIOM_AUDIT_END -/
