import Meta.Core.OperationalParityRoles
import Meta.Arithmetic.CountdownDynamicGap

/-!
# Arithmetic parity roles

This file gives a non-trivial arithmetic instance of the operational parity
roles.  It does not classify raw `Nat` values by congruence.  Instead, it
starts from an exact arithmetic intersection, builds an oriented arithmetic
interface carrying the formed and shadow traces, connects that dynamic return
to the abstract parity separation, and then reads the resulting operational
roles as arithmetic even/odd roles.
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

/-! ## Oriented arithmetic interface generated by an intersection -/

/--
The oriented arithmetic interface generated by an exact arithmetic
intersection.

This is the non-trivial interface used for the parity instance: the role is
carried by the intersection itself, not recovered by classifying raw traces.
-/
inductive ArithmeticIntersectionPole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  | formed
  | shadow

/-- The trace carried by an oriented arithmetic pole. -/
def arithmeticIntersectionPoleTrace
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch} :
    ArithmeticIntersectionPole intersection -> List NatTraceAtom
  | ArithmeticIntersectionPole.formed => formedTraceOfIntersection intersection
  | ArithmeticIntersectionPole.shadow => payloadOnlyTraceOfIntersection intersection

/-- The visible payload carried by an oriented arithmetic pole. -/
def arithmeticIntersectionPoleVisible
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (pole : ArithmeticIntersectionPole intersection) :
    List Nat :=
  tracePayloads (arithmeticIntersectionPoleTrace pole)

/-- Repair type attached to the trace carried by an oriented arithmetic pole. -/
def arithmeticIntersectionPoleRepair
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (pole : ArithmeticIntersectionPole intersection) :
    Type :=
  NatInterfaceRepair (arithmeticIntersectionPoleTrace pole)

/-- The formed arithmetic pole carries the formed intersection trace. -/
theorem arithmeticIntersectionPoleTrace_formed
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticIntersectionPoleTrace
        (ArithmeticIntersectionPole.formed
          (intersection := intersection)) =
      formedTraceOfIntersection intersection :=
  rfl

/-- The shadow arithmetic pole carries the payload-only shadow trace. -/
theorem arithmeticIntersectionPoleTrace_shadow
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticIntersectionPoleTrace
        (ArithmeticIntersectionPole.shadow
          (intersection := intersection)) =
      payloadOnlyTraceOfIntersection intersection :=
  rfl

/-- The formed and shadow arithmetic poles expose the same visible payload. -/
theorem arithmeticIntersectionPoleVisible_same
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticIntersectionPoleVisible
        (ArithmeticIntersectionPole.formed
          (intersection := intersection)) =
      arithmeticIntersectionPoleVisible
        (ArithmeticIntersectionPole.shadow
          (intersection := intersection)) :=
  formedTraceOfIntersection_same_payloadOnlyPayload intersection

/-- The traces carried by the formed and shadow arithmetic poles remain separated. -/
theorem arithmeticIntersectionPoleTrace_separated
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticIntersectionPoleTrace
        (ArithmeticIntersectionPole.formed
          (intersection := intersection)) =
      arithmeticIntersectionPoleTrace
        (ArithmeticIntersectionPole.shadow
          (intersection := intersection)) ->
        False :=
  formedTraceOfIntersection_ne_payloadOnlyTrace intersection

/-- The oriented formed and shadow arithmetic poles are separated. -/
theorem arithmeticIntersectionPole_separated
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ArithmeticIntersectionPole.formed (intersection := intersection) =
      ArithmeticIntersectionPole.shadow (intersection := intersection) ->
        False := by
  intro h
  cases h

/--
The exact local recovery carried by the oriented arithmetic interface.

The same visible payload and the separation of the two traces are inherited
from the arithmetic intersection.
-/
def arithmeticIntersectionLocalRecovery
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    LocalProjectiveRecovery
      (ArithmeticIntersectionPole intersection)
      (List Nat)
      arithmeticIntersectionPoleVisible
      arithmeticIntersectionPoleRepair where
  formed := ArithmeticIntersectionPole.formed
  shadow := ArithmeticIntersectionPole.shadow
  sameProjection := arithmeticIntersectionPoleVisible_same intersection
  separated := arithmeticIntersectionPole_separated intersection
  repair := natInterfaceRepairOfIntersection intersection
  recovered := ArithmeticIntersectionPole.formed
  recovered_eq_formed := rfl

/-- Witness type for the trace carried by an oriented arithmetic pole. -/
def arithmeticIntersectionPoleWitness
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (pole : ArithmeticIntersectionPole intersection) :
    Type :=
  NatInterfaceWitness (arithmeticIntersectionPoleTrace pole)

/-- Realization type for the trace carried by an oriented arithmetic pole. -/
def arithmeticIntersectionPoleRealization
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (cycle :
      StrongTerminalCycleFromIntersection bidirectionalCompleteness branch)
    (pole : ArithmeticIntersectionPole intersection) :
    Type :=
  NatInterfaceRealization cycle (arithmeticIntersectionPoleTrace pole)

/-- The locally recovered dynamic return generated by one arithmetic intersection. -/
def arithmeticIntersectionDynamicReturn
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    LocallyRecoveredDynamicReturn
      bidirectionalCompleteness
      enrichedNatRoundTripCoherence
      branch
      PUnit
      (ArithmeticIntersectionPole intersection)
      arithmeticIntersectionPoleWitness
      arithmeticIntersectionPoleRealization
      (List Nat)
      arithmeticIntersectionPoleVisible
      arithmeticIntersectionPoleRepair where
  formedReturn :=
    { source := PUnit.unit
      intersection := intersection }
  formed :=
    { interface := ArithmeticIntersectionPole.formed
      witness :=
        { payload := tracePayloads (formedTraceOfIntersection intersection)
          payload_eq := rfl } }
  realizes :=
    { interface_eq_formedTrace := rfl }
  localRecovery := arithmeticIntersectionLocalRecovery intersection
  localRecovery_sameInterface := rfl

/-- The dynamic parity raccord generated by one arithmetic intersection. -/
def arithmeticIntersectionParityRaccord
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    DynamicParitySeparation
      (arithmeticIntersectionDynamicReturn intersection) :=
  dynamicParitySeparation_leftRight
    (arithmeticIntersectionDynamicReturn intersection)
    (fun
      | ArithmeticIntersectionPole.formed => ParityRegime.left
      | ArithmeticIntersectionPole.shadow => ParityRegime.right)
    (fun _ => ParityVisible.contracted)
    rfl
    rfl
    rfl
    rfl

/-- Operational parity roles produced by one arithmetic intersection. -/
def arithmeticIntersectionOperationalParityRoles
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    OperationalParityRoles
      (arithmeticIntersectionParityRaccord intersection) :=
  operationalParityRolesOfDynamicParitySeparation
    (arithmeticIntersectionParityRaccord intersection)

/-- Arithmetic parity roles produced by one arithmetic intersection. -/
def arithmeticIntersectionArithmeticParityRoles
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ArithmeticParityRoles
      (arithmeticIntersectionOperationalParityRoles intersection) :=
  arithmeticParityRolesOfOperationalRoles
    (arithmeticIntersectionOperationalParityRoles intersection)

/-! ## Packaged arithmetic dynamic parity instance -/

/-- Full arithmetic dynamic parity instance generated by one intersection. -/
structure ArithmeticDynamicParityInstance
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  dynamicReturn :
    LocallyRecoveredDynamicReturn
      bidirectionalCompleteness
      enrichedNatRoundTripCoherence
      branch
      PUnit
      (ArithmeticIntersectionPole intersection)
      arithmeticIntersectionPoleWitness
      arithmeticIntersectionPoleRealization
      (List Nat)
      arithmeticIntersectionPoleVisible
      arithmeticIntersectionPoleRepair
  parityRaccord : DynamicParitySeparation dynamicReturn
  operationalRoles : OperationalParityRoles parityRaccord
  arithmeticRoles : ArithmeticParityRoles operationalRoles

/-- Canonical arithmetic dynamic parity instance generated by one intersection. -/
def arithmeticDynamicParityInstance
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ArithmeticDynamicParityInstance intersection where
  dynamicReturn := arithmeticIntersectionDynamicReturn intersection
  parityRaccord := arithmeticIntersectionParityRaccord intersection
  operationalRoles := arithmeticIntersectionOperationalParityRoles intersection
  arithmeticRoles := arithmeticIntersectionArithmeticParityRoles intersection

/-- The even and odd roles of an arithmetic dynamic parity instance have the same visible. -/
theorem arithmeticDynamicParityInstance_sameParityProjection
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (parityInstance : ArithmeticDynamicParityInstance intersection) :
    parityProjection
        (arithmeticParityRoles_evenRegime parityInstance.arithmeticRoles) =
      parityProjection
        (arithmeticParityRoles_oddRegime parityInstance.arithmeticRoles) :=
  arithmeticParityRoles_sameParityProjection parityInstance.arithmeticRoles

/-- The even and odd roles of an arithmetic dynamic parity instance remain separated. -/
theorem arithmeticDynamicParityInstance_separated
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (parityInstance : ArithmeticDynamicParityInstance intersection) :
    arithmeticParityRoles_evenRegime parityInstance.arithmeticRoles =
      arithmeticParityRoles_oddRegime parityInstance.arithmeticRoles -> False :=
  arithmeticParityRoles_separated parityInstance.arithmeticRoles

/--
An arithmetic dynamic parity instance rules out global reconstruction from the
contracted parity visible alone.
-/
def arithmeticDynamicParityInstance_noParityVisibleReconstruction
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (parityInstance : ArithmeticDynamicParityInstance intersection) :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False) :=
  operationalParityRoles_noParityVisibleReconstruction
    parityInstance.operationalRoles

/-! ## Countdown specialization -/

/-- The arithmetic intersection generated by the terminal countdown collision. -/
def countdownArithmeticParityIntersection
    (n : Nat) :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision n)))) :=
  repeatedIndexIntersection
    (repeatedIndexCollision_of_trajectoryCollision
      (trajectoryCollision_of_windowCollision
        (countdownTerminalWindowCollision n)))

/-- The countdown arithmetic parity dynamic return. -/
def countdownArithmeticParityDynamicReturn
    (n : Nat) :
    LocallyRecoveredDynamicReturn
      bidirectionalCompleteness
      enrichedNatRoundTripCoherence
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision n))))
      PUnit
      (ArithmeticIntersectionPole (countdownArithmeticParityIntersection n))
      arithmeticIntersectionPoleWitness
      arithmeticIntersectionPoleRealization
      (List Nat)
      arithmeticIntersectionPoleVisible
      arithmeticIntersectionPoleRepair :=
  arithmeticIntersectionDynamicReturn
    (countdownArithmeticParityIntersection n)

/-- The countdown arithmetic parity raccord. -/
def countdownArithmeticParityRaccord
    (n : Nat) :
    DynamicParitySeparation
      (countdownArithmeticParityDynamicReturn n) :=
  arithmeticIntersectionParityRaccord
    (countdownArithmeticParityIntersection n)

/-- Operational parity roles generated by the countdown terminal closure. -/
def countdownOperationalParityRoles
    (n : Nat) :
    OperationalParityRoles
      (countdownArithmeticParityRaccord n) :=
  arithmeticIntersectionOperationalParityRoles
    (countdownArithmeticParityIntersection n)

/-- Arithmetic parity roles generated by the countdown terminal closure. -/
def countdownArithmeticParityRoles
    (n : Nat) :
    ArithmeticParityRoles
      (countdownOperationalParityRoles n) :=
  arithmeticIntersectionArithmeticParityRoles
    (countdownArithmeticParityIntersection n)

/-- The countdown terminal closure carries the arithmetic dynamic parity instance. -/
def countdownArithmeticParityInstance
    (n : Nat) :
    ArithmeticDynamicParityInstance
      (countdownArithmeticParityIntersection n) where
  dynamicReturn := countdownArithmeticParityDynamicReturn n
  parityRaccord := countdownArithmeticParityRaccord n
  operationalRoles := countdownOperationalParityRoles n
  arithmeticRoles := countdownArithmeticParityRoles n

/-- The countdown arithmetic parity instance keeps the terminal `n + 2` excess. -/
theorem countdownArithmeticParity_terminalExcess_eq_n_plus_two
    (n : Nat) :
    formedPositiveExcessOfIntersection
      (countdownArithmeticParityIntersection n) =
        n + 2 :=
  countdownTerminalExcess_eq_n_plus_two n

/-- Countdown arithmetic parity packaged together with its terminal excess lock. -/
structure CountdownArithmeticParityPackage
    (n : Nat) where
  parityInstance :
    ArithmeticDynamicParityInstance
      (countdownArithmeticParityIntersection n)
  terminalExcess_eq_n_plus_two :
    formedPositiveExcessOfIntersection
      (countdownArithmeticParityIntersection n) =
        n + 2

/-- Canonical countdown arithmetic parity package. -/
def countdownArithmeticParityPackage
    (n : Nat) :
    CountdownArithmeticParityPackage n where
  parityInstance := countdownArithmeticParityInstance n
  terminalExcess_eq_n_plus_two :=
    countdownArithmeticParity_terminalExcess_eq_n_plus_two n

/-- Countdown even and odd roles have the same parity visible. -/
theorem countdownArithmeticParity_sameParityProjection
    (n : Nat) :
    parityProjection
        (arithmeticParityRoles_evenRegime
          (countdownArithmeticParityRoles n)) =
      parityProjection
        (arithmeticParityRoles_oddRegime
          (countdownArithmeticParityRoles n)) :=
  arithmeticParityRoles_sameParityProjection
    (countdownArithmeticParityRoles n)

/-- Countdown even and odd roles remain separated. -/
theorem countdownArithmeticParity_separated
    (n : Nat) :
    arithmeticParityRoles_evenRegime
        (countdownArithmeticParityRoles n) =
      arithmeticParityRoles_oddRegime
        (countdownArithmeticParityRoles n) -> False :=
  arithmeticParityRoles_separated
    (countdownArithmeticParityRoles n)

/-- Countdown arithmetic parity rules out global parity-visible reconstruction. -/
def countdownArithmeticParity_noParityVisibleReconstruction
    (n : Nat) :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False) :=
  arithmeticDynamicParityInstance_noParityVisibleReconstruction
    (countdownArithmeticParityInstance n)

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
#print axioms Meta.EnrichedNatClosedStabilityInstance.ArithmeticIntersectionPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPoleTrace
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPoleVisible
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPoleRepair
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPoleTrace_formed
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPoleTrace_shadow
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPoleVisible_same
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPoleTrace_separated
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPole_separated
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionLocalRecovery
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPoleWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionPoleRealization
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionDynamicReturn
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionParityRaccord
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionOperationalParityRoles
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticIntersectionArithmeticParityRoles
#print axioms Meta.EnrichedNatClosedStabilityInstance.ArithmeticDynamicParityInstance
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicParityInstance
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicParityInstance_sameParityProjection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicParityInstance_separated
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicParityInstance_noParityVisibleReconstruction
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParityIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParityDynamicReturn
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParityRaccord
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownOperationalParityRoles
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParityRoles
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParityInstance
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParity_terminalExcess_eq_n_plus_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.CountdownArithmeticParityPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParityPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParity_sameParityProjection
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParity_separated
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticParity_noParityVisibleReconstruction
/- AXIOM_AUDIT_END -/
