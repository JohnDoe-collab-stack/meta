import Meta.Core.DynamicCore

/-!
# Dynamic role carriers

This file extracts the generic positive structure carried by a locally
recovered dynamic return when it is read through an operational two-pole of
roles.

It does not mention parity.  Parity is one specialization of this pattern:
a dynamic return may be read into two separated roles whose visible reading is
contracted, while the formed side still carries local repair.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a p q t

/-! ## Dynamic return equipped with an abstract role reading -/

/--
A dynamic role carrier.

The dynamic return keeps its own operational two-pole on `Interface`.  The
carrier adds a second operational two-pole on `Role`, together with readings
from dynamic interfaces and dynamic visibles into that role-level referential.
-/
structure DynamicRoleCarrier
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
        RepairOf)
    (Role : Type p)
    (RoleVisible : Type q)
    (roleProject : Role -> RoleVisible)
    (RoleRepairOf : Role -> Type t) :
    Type (max u v w x y z r s a p q t) where
  roleOf : Interface -> Role
  visibleRoleOf : Visible -> RoleVisible
  roleTwoPole :
    OperationalTwoPole
      Role
      RoleVisible
      roleProject
      RoleRepairOf
  formed_role :
    roleOf dynamicReturn.localRecovery.formed =
      operationalTwoPole_leftPole roleTwoPole
  shadow_role :
    roleOf dynamicReturn.localRecovery.shadow =
      operationalTwoPole_rightPole roleTwoPole
  formed_visible :
    visibleRoleOf (project dynamicReturn.localRecovery.formed) =
      roleProject (roleOf dynamicReturn.localRecovery.formed)
  shadow_visible :
    visibleRoleOf (project dynamicReturn.localRecovery.shadow) =
      roleProject (roleOf dynamicReturn.localRecovery.shadow)

section DynamicRoleCarrier

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
variable {Role : Type p}
variable {RoleVisible : Type q}
variable {roleProject : Role -> RoleVisible}
variable {RoleRepairOf : Role -> Type t}

/-! ## Exposed two-poles -/

/-- The operational two-pole carried by the dynamic return itself. -/
def dynamicRoleCarrier_dynamicOperationalTwoPole
    (_carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    OperationalTwoPole Interface Visible project RepairOf :=
  dynamicReturn_operationalTwoPole dynamicReturn

/-- The role-level operational two-pole through which the dynamic return is read. -/
def dynamicRoleCarrier_roleOperationalTwoPole
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    OperationalTwoPole Role RoleVisible roleProject RoleRepairOf :=
  carrier.roleTwoPole

/-! ## Readings of the dynamic formed and shadow sides -/

/-- The role read from the formed dynamic interface. -/
def dynamicRoleCarrier_formedRole
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    Role :=
  carrier.roleOf dynamicReturn.localRecovery.formed

/-- The role read from the shadow dynamic interface. -/
def dynamicRoleCarrier_shadowRole
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    Role :=
  carrier.roleOf dynamicReturn.localRecovery.shadow

/-- The role-visible value read from the formed dynamic visible. -/
def dynamicRoleCarrier_formedVisibleRole
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    RoleVisible :=
  carrier.visibleRoleOf (project dynamicReturn.localRecovery.formed)

/-- The role-visible value read from the shadow dynamic visible. -/
def dynamicRoleCarrier_shadowVisibleRole
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    RoleVisible :=
  carrier.visibleRoleOf (project dynamicReturn.localRecovery.shadow)

/-- The formed dynamic interface is read as the formed role pole. -/
theorem dynamicRoleCarrier_formedRole_eq_leftPole
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    dynamicRoleCarrier_formedRole carrier =
      operationalTwoPole_leftPole
        (dynamicRoleCarrier_roleOperationalTwoPole carrier) :=
  carrier.formed_role

/-- The shadow dynamic interface is read as the shadow role pole. -/
theorem dynamicRoleCarrier_shadowRole_eq_rightPole
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    dynamicRoleCarrier_shadowRole carrier =
      operationalTwoPole_rightPole
        (dynamicRoleCarrier_roleOperationalTwoPole carrier) :=
  carrier.shadow_role

/-- The formed dynamic visible is compatible with the role projection. -/
theorem dynamicRoleCarrier_formedVisible_eq_projection
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    dynamicRoleCarrier_formedVisibleRole carrier =
      roleProject (dynamicRoleCarrier_formedRole carrier) :=
  carrier.formed_visible

/-- The shadow dynamic visible is compatible with the role projection. -/
theorem dynamicRoleCarrier_shadowVisible_eq_projection
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    dynamicRoleCarrier_shadowVisibleRole carrier =
      roleProject (dynamicRoleCarrier_shadowRole carrier) :=
  carrier.shadow_visible

/-! ## Consequences of a dynamic role carrier -/

/-- The role-visible values read from the formed and shadow dynamic sides coincide. -/
theorem dynamicRoleCarrier_sameRoleVisible
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    dynamicRoleCarrier_formedVisibleRole carrier =
      dynamicRoleCarrier_shadowVisibleRole carrier := by
  calc
    dynamicRoleCarrier_formedVisibleRole carrier =
        roleProject (dynamicRoleCarrier_formedRole carrier) :=
      dynamicRoleCarrier_formedVisible_eq_projection carrier
    _ =
        roleProject
          (operationalTwoPole_leftPole
            (dynamicRoleCarrier_roleOperationalTwoPole carrier)) :=
      congrArg roleProject
        (dynamicRoleCarrier_formedRole_eq_leftPole carrier)
    _ =
        roleProject
          (operationalTwoPole_rightPole
            (dynamicRoleCarrier_roleOperationalTwoPole carrier)) :=
      operationalTwoPole_sameVisible
        (dynamicRoleCarrier_roleOperationalTwoPole carrier)
    _ = roleProject (dynamicRoleCarrier_shadowRole carrier) :=
      Eq.symm
        (congrArg roleProject
          (dynamicRoleCarrier_shadowRole_eq_rightPole carrier))
    _ = dynamicRoleCarrier_shadowVisibleRole carrier :=
      Eq.symm (dynamicRoleCarrier_shadowVisible_eq_projection carrier)

/-- The formed and shadow roles remain separated. -/
theorem dynamicRoleCarrier_separatedRoles
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    dynamicRoleCarrier_formedRole carrier =
      dynamicRoleCarrier_shadowRole carrier -> False := by
  intro h
  exact
    operationalTwoPole_separatedPoles
      (dynamicRoleCarrier_roleOperationalTwoPole carrier)
      (by
        calc
          operationalTwoPole_leftPole
              (dynamicRoleCarrier_roleOperationalTwoPole carrier) =
              dynamicRoleCarrier_formedRole carrier :=
            Eq.symm (dynamicRoleCarrier_formedRole_eq_leftPole carrier)
          _ = dynamicRoleCarrier_shadowRole carrier :=
            h
          _ =
              operationalTwoPole_rightPole
                (dynamicRoleCarrier_roleOperationalTwoPole carrier) :=
            dynamicRoleCarrier_shadowRole_eq_rightPole carrier)

/-- The dynamic formed side carries its original local repair. -/
def dynamicRoleCarrier_dynamicRepair
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    RepairOf
      (operationalTwoPole_leftPole
        (dynamicRoleCarrier_dynamicOperationalTwoPole carrier)) :=
  operationalTwoPole_repair
    (dynamicRoleCarrier_dynamicOperationalTwoPole carrier)

/-- The formed role side carries the role-level local repair. -/
def dynamicRoleCarrier_roleRepair
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    RoleRepairOf
      (operationalTwoPole_leftPole
        (dynamicRoleCarrier_roleOperationalTwoPole carrier)) :=
  operationalTwoPole_repair
    (dynamicRoleCarrier_roleOperationalTwoPole carrier)

/-- A role carrier refutes a short presentation of its role projection. -/
theorem dynamicRoleCarrier_refutesRoleShortPresentation
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf)
    (short :
      ShortReferentialPresentation Role RoleVisible roleProject) :
    False :=
  operationalTwoPole_refutes_shortPresentation
    (dynamicRoleCarrier_roleOperationalTwoPole carrier)
    short

/-- A role carrier refutes contractibility of its role-visible fiber. -/
theorem dynamicRoleCarrier_roleNotContractible
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf)
    (contractible :
      ContractibleReferentialGap Role RoleVisible roleProject) :
    False :=
  operationalTwoPole_not_contractible
    (dynamicRoleCarrier_roleOperationalTwoPole carrier)
    contractible

/-- No global role-visible reconstruction can recover both separated roles. -/
def dynamicRoleCarrier_noRoleProjectiveReconstruction
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    ((recover : RoleVisible -> Role) ->
      ((role : Role) ->
        recover (roleProject role) = role) ->
      False) :=
  operationalTwoPole_noProjectiveReconstruction
    (dynamicRoleCarrier_roleOperationalTwoPole carrier)

/-! ## Mediated dynamic roles -/

/--
Mediated dynamic roles extracted from a dynamic role carrier.

The closing role is the formed role reading.  The mediating role is the shadow
role reading.  Their visible reading coincides, but the roles remain separated,
and the formed side carries both the dynamic repair and the role-level repair.
-/
structure MediatedDynamicRoles
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
    {Role : Type p}
    {RoleVisible : Type q}
    {roleProject : Role -> RoleVisible}
    {RoleRepairOf : Role -> Type t}
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    Type (max u v w x y z r s a p q t) where
  closingRole : Role
  mediatingRole : Role
  closing_eq_formed :
    closingRole = dynamicRoleCarrier_formedRole carrier
  mediating_eq_shadow :
    mediatingRole = dynamicRoleCarrier_shadowRole carrier
  sameVisible :
    dynamicRoleCarrier_formedVisibleRole carrier =
      dynamicRoleCarrier_shadowVisibleRole carrier
  separated :
    closingRole = mediatingRole -> False
  dynamicRepair :
    RepairOf
      (operationalTwoPole_leftPole
        (dynamicRoleCarrier_dynamicOperationalTwoPole carrier))
  roleRepair :
    RoleRepairOf
      (operationalTwoPole_leftPole
        (dynamicRoleCarrier_roleOperationalTwoPole carrier))
  noRoleVisibleReconstruction :
    ((recover : RoleVisible -> Role) ->
      ((role : Role) ->
        recover (roleProject role) = role) ->
      False)

/-- Extract mediated dynamic roles from any dynamic role carrier. -/
def mediatedDynamicRolesOfCarrier
    (carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf) :
    MediatedDynamicRoles carrier where
  closingRole := dynamicRoleCarrier_formedRole carrier
  mediatingRole := dynamicRoleCarrier_shadowRole carrier
  closing_eq_formed := rfl
  mediating_eq_shadow := rfl
  sameVisible := dynamicRoleCarrier_sameRoleVisible carrier
  separated := dynamicRoleCarrier_separatedRoles carrier
  dynamicRepair := dynamicRoleCarrier_dynamicRepair carrier
  roleRepair := dynamicRoleCarrier_roleRepair carrier
  noRoleVisibleReconstruction :=
    dynamicRoleCarrier_noRoleProjectiveReconstruction carrier

/-! ## Projections and consequences -/

/-- The closing role of a mediated dynamic role package. -/
def mediatedDynamicRoles_closingRole
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    Role :=
  roles.closingRole

/-- The mediating role of a mediated dynamic role package. -/
def mediatedDynamicRoles_mediatingRole
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    Role :=
  roles.mediatingRole

/-- The closing role is the formed role reading. -/
theorem mediatedDynamicRoles_closing_eq_formed
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    mediatedDynamicRoles_closingRole roles =
      dynamicRoleCarrier_formedRole carrier :=
  roles.closing_eq_formed

/-- The mediating role is the shadow role reading. -/
theorem mediatedDynamicRoles_mediating_eq_shadow
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    mediatedDynamicRoles_mediatingRole roles =
      dynamicRoleCarrier_shadowRole carrier :=
  roles.mediating_eq_shadow

/-- The mediated roles expose the same role-visible value. -/
theorem mediatedDynamicRoles_sameVisible
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    dynamicRoleCarrier_formedVisibleRole carrier =
      dynamicRoleCarrier_shadowVisibleRole carrier :=
  roles.sameVisible

/-- The closing and mediating roles remain separated. -/
theorem mediatedDynamicRoles_separated
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    mediatedDynamicRoles_closingRole roles =
      mediatedDynamicRoles_mediatingRole roles -> False :=
  roles.separated

/-- The mediated role package carries the dynamic local repair. -/
def mediatedDynamicRoles_dynamicRepair
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    RepairOf
      (operationalTwoPole_leftPole
        (dynamicRoleCarrier_dynamicOperationalTwoPole carrier)) :=
  roles.dynamicRepair

/-- The mediated role package carries the role-level local repair. -/
def mediatedDynamicRoles_roleRepair
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    RoleRepairOf
      (operationalTwoPole_leftPole
        (dynamicRoleCarrier_roleOperationalTwoPole carrier)) :=
  roles.roleRepair

/-- The mediated role package rules out global role-visible reconstruction. -/
def mediatedDynamicRoles_noRoleVisibleReconstruction
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    ((recover : RoleVisible -> Role) ->
      ((role : Role) ->
        recover (roleProject role) = role) ->
      False) :=
  roles.noRoleVisibleReconstruction

/-- Closing and mediating roles have the same role projection. -/
theorem mediatedDynamicRoles_sameRoleProjection
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (roles : MediatedDynamicRoles carrier) :
    roleProject (mediatedDynamicRoles_closingRole roles) =
      roleProject (mediatedDynamicRoles_mediatingRole roles) := by
  calc
    roleProject (mediatedDynamicRoles_closingRole roles) =
        roleProject (dynamicRoleCarrier_formedRole carrier) :=
      congrArg roleProject
        (mediatedDynamicRoles_closing_eq_formed roles)
    _ = dynamicRoleCarrier_formedVisibleRole carrier :=
      Eq.symm
        (dynamicRoleCarrier_formedVisible_eq_projection carrier)
    _ = dynamicRoleCarrier_shadowVisibleRole carrier :=
      mediatedDynamicRoles_sameVisible roles
    _ = roleProject (dynamicRoleCarrier_shadowRole carrier) :=
      dynamicRoleCarrier_shadowVisible_eq_projection carrier
    _ = roleProject (mediatedDynamicRoles_mediatingRole roles) :=
      congrArg roleProject
        (Eq.symm (mediatedDynamicRoles_mediating_eq_shadow roles))

/-- Mediated dynamic roles refute a short presentation of the role projection. -/
theorem mediatedDynamicRoles_refutesRoleShortPresentation
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (_roles : MediatedDynamicRoles carrier)
    (short : ShortReferentialPresentation Role RoleVisible roleProject) :
    False :=
  dynamicRoleCarrier_refutesRoleShortPresentation carrier short

/-- Mediated dynamic roles refute contractibility of the role-visible fiber. -/
theorem mediatedDynamicRoles_roleNotContractible
    {carrier :
      DynamicRoleCarrier
        dynamicReturn
        Role
        RoleVisible
        roleProject
        RoleRepairOf}
    (_roles : MediatedDynamicRoles carrier)
    (contractible : ContractibleReferentialGap Role RoleVisible roleProject) :
    False :=
  dynamicRoleCarrier_roleNotContractible carrier contractible

end DynamicRoleCarrier

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.DynamicRoleCarrier
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_dynamicOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_roleOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_formedRole
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_shadowRole
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_formedVisibleRole
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_shadowVisibleRole
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_formedRole_eq_leftPole
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_shadowRole_eq_rightPole
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_formedVisible_eq_projection
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_shadowVisible_eq_projection
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_sameRoleVisible
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_separatedRoles
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_dynamicRepair
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_roleRepair
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_refutesRoleShortPresentation
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_roleNotContractible
#print axioms Meta.ClosedStabilityTheorem.dynamicRoleCarrier_noRoleProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.MediatedDynamicRoles
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRolesOfCarrier
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_closingRole
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_mediatingRole
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_closing_eq_formed
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_mediating_eq_shadow
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_sameVisible
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_separated
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_dynamicRepair
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_roleRepair
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_noRoleVisibleReconstruction
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_sameRoleProjection
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_refutesRoleShortPresentation
#print axioms Meta.ClosedStabilityTheorem.mediatedDynamicRoles_roleNotContractible
/- AXIOM_AUDIT_END -/
