import Meta.Core.OperationalParityRoles

/-!
# Arithmetic parity role names

This file only gives arithmetic names to operational parity roles.  It does not
construct an arithmetic interface and does not specialize the roles to
countdown.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

universe u v w x y z r s a

/-! ## Arithmetic naming of operational parity roles -/

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

/--
Arithmetic names for the two operational parity roles.

The even role is the operational closing role.  The odd role is the operational
mediating role.  This structure does not identify `ParityRegime.left` or
`ParityRegime.right` globally with even or odd; that orientation is supplied by
the dynamic parity raccord.
-/
structure ArithmeticParityRoles
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    Type (max u v w x y z r s a) where
  evenRegime : ParityRegime
  oddRegime : ParityRegime
  even_eq_closing :
    evenRegime = operationalParityRoles_closingRegime roles
  odd_eq_mediating :
    oddRegime = operationalParityRoles_mediatingRegime roles

section ArithmeticParityRoles

/-- Attach arithmetic names to operational parity roles. -/
def arithmeticParityRolesOfOperationalRoles
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) :
    ArithmeticParityRoles roles where
  evenRegime := operationalParityRoles_closingRegime roles
  oddRegime := operationalParityRoles_mediatingRegime roles
  even_eq_closing := rfl
  odd_eq_mediating := rfl

/-- The arithmetic even role. -/
def arithmeticParityRoles_evenRegime
    {raccord : DynamicParitySeparation dynamicReturn}
    {roles : OperationalParityRoles raccord}
    (arithRoles : ArithmeticParityRoles roles) :
    ParityRegime :=
  arithRoles.evenRegime

/-- The arithmetic odd role. -/
def arithmeticParityRoles_oddRegime
    {raccord : DynamicParitySeparation dynamicReturn}
    {roles : OperationalParityRoles raccord}
    (arithRoles : ArithmeticParityRoles roles) :
    ParityRegime :=
  arithRoles.oddRegime

/-- The even role is the operational closing role. -/
theorem arithmeticParityRoles_even_eq_closing
    {raccord : DynamicParitySeparation dynamicReturn}
    {roles : OperationalParityRoles raccord}
    (arithRoles : ArithmeticParityRoles roles) :
    arithmeticParityRoles_evenRegime arithRoles =
      operationalParityRoles_closingRegime roles :=
  arithRoles.even_eq_closing

/-- The odd role is the operational mediating role. -/
theorem arithmeticParityRoles_odd_eq_mediating
    {raccord : DynamicParitySeparation dynamicReturn}
    {roles : OperationalParityRoles raccord}
    (arithRoles : ArithmeticParityRoles roles) :
    arithmeticParityRoles_oddRegime arithRoles =
      operationalParityRoles_mediatingRegime roles :=
  arithRoles.odd_eq_mediating

/-- Even and odd roles have the same parity visible. -/
theorem arithmeticParityRoles_sameParityProjection
    {raccord : DynamicParitySeparation dynamicReturn}
    {roles : OperationalParityRoles raccord}
    (arithRoles : ArithmeticParityRoles roles) :
    parityProjection (arithmeticParityRoles_evenRegime arithRoles) =
      parityProjection (arithmeticParityRoles_oddRegime arithRoles) := by
  calc
    parityProjection (arithmeticParityRoles_evenRegime arithRoles) =
        parityProjection (operationalParityRoles_closingRegime roles) :=
      congrArg parityProjection
        (arithmeticParityRoles_even_eq_closing arithRoles)
    _ =
        parityProjection (operationalParityRoles_mediatingRegime roles) :=
      operationalParityRoles_sameParityProjection roles
    _ = parityProjection (arithmeticParityRoles_oddRegime arithRoles) :=
      congrArg parityProjection
        (Eq.symm (arithmeticParityRoles_odd_eq_mediating arithRoles))

/-- Even and odd roles remain separated. -/
theorem arithmeticParityRoles_separated
    {raccord : DynamicParitySeparation dynamicReturn}
    {roles : OperationalParityRoles raccord}
    (arithRoles : ArithmeticParityRoles roles) :
    arithmeticParityRoles_evenRegime arithRoles =
      arithmeticParityRoles_oddRegime arithRoles -> False := by
  intro h
  exact
    operationalParityRoles_separated roles
      (by
        calc
          operationalParityRoles_closingRegime roles =
              arithmeticParityRoles_evenRegime arithRoles :=
            Eq.symm (arithmeticParityRoles_even_eq_closing arithRoles)
          _ = arithmeticParityRoles_oddRegime arithRoles := h
          _ = operationalParityRoles_mediatingRegime roles :=
            arithmeticParityRoles_odd_eq_mediating arithRoles)

/-- The arithmetic even role carries the dynamic local repair. -/
def arithmeticParityRoles_dynamicRepair
    {raccord : DynamicParitySeparation dynamicReturn}
    {roles : OperationalParityRoles raccord}
    (_arithRoles : ArithmeticParityRoles roles) :
    RepairOf
      (operationalTwoPole_leftPole
        (dynamicParitySeparation_dynamicOperationalTwoPole raccord)) :=
  operationalParityRoles_dynamicRepair roles

/-- Arithmetic parity roles rule out global parity-visible reconstruction. -/
def arithmeticParityRoles_noParityVisibleReconstruction
    {raccord : DynamicParitySeparation dynamicReturn}
    {roles : OperationalParityRoles raccord}
    (_arithRoles : ArithmeticParityRoles roles) :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False) :=
  operationalParityRoles_noParityVisibleReconstruction roles

end ArithmeticParityRoles

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.ArithmeticParityRoles
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticParityRolesOfOperationalRoles
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticParityRoles_evenRegime
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticParityRoles_oddRegime
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticParityRoles_even_eq_closing
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticParityRoles_odd_eq_mediating
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticParityRoles_sameParityProjection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticParityRoles_separated
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticParityRoles_dynamicRepair
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticParityRoles_noParityVisibleReconstruction
/- AXIOM_AUDIT_END -/
