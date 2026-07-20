import Meta.Core.DynamicRelaxedUsage
import Meta.Semantics.UseGraphNonReduction

/-!
# Repair-driven foundational dynamics

The transition primitive is execution of the repair stored at the formed pole
of the current gap.  The generic `GapDrivenDynamicSystem.advance` is derived
from this operation and is not an independently supplied next-state function.
-/

namespace Meta
namespace RelaxedSemantics

open ClosedStabilityTheorem
open DynamicRelaxedUsage

universe u v w a x y z r s e

/-- An internal algebra executing the repair carried by a dynamic gap. -/
structure GapRepairAlgebra
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf) where
  executeRepair :
    (source : Source) ->
    DynamicGapCausalState family source ->
    RepairOf (family.formedAt source) ->
    Source

namespace GapRepairAlgebra

variable
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}

/-- Successor computed from the canonical causal state and its stored repair. -/
def next (algebra : GapRepairAlgebra family) (source : Source) : Source :=
  algebra.executeRepair
    source
    (dynamicGapCausalState family source)
    (family.repairAt source)

/-- The generic dynamic-system API derived from repair execution. -/
def toGapDrivenDynamicSystem
    (algebra : GapRepairAlgebra family) :
    GapDrivenDynamicSystem family where
  advance := fun input =>
    match input with
    | ⟨source, causalState⟩ =>
        algebra.executeRepair source causalState (family.repairAt source)

/-- The derived system successor is definitionally repair execution. -/
theorem systemNext_eq_repairNext
    (algebra : GapRepairAlgebra family)
    (source : Source) :
    (algebra.toGapDrivenDynamicSystem.next source) = algebra.next source :=
  rfl

/-- Intrinsic iteration of the repair-driven successor. -/
def iterate
    (algebra : GapRepairAlgebra family) :
    Nat -> Source -> Source
  | 0, source => source
  | Nat.succ n, source => algebra.next (algebra.iterate n source)

/-- The repair-driven and generic gap-driven iterations coincide pointwise. -/
theorem systemIterate_eq_repairIterate
    (algebra : GapRepairAlgebra family)
    (n : Nat)
    (source : Source) :
    algebra.toGapDrivenDynamicSystem.iterateSource n source =
      algebra.iterate n source := by
  induction n with
  | zero => rfl
  | succ n inductionHypothesis =>
      change
        algebra.toGapDrivenDynamicSystem.next
            (algebra.toGapDrivenDynamicSystem.iterateSource n source) =
          algebra.next (algebra.iterate n source)
      rw [inductionHypothesis]
      exact algebra.systemNext_eq_repairNext (algebra.iterate n source)

end GapRepairAlgebra

/-- The entire causal chain of one repair-driven step. -/
structure InternalRepairDrivenStep
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    (algebra : GapRepairAlgebra family)
    (source : Source) where
  causalState : DynamicGapCausalState family source
  causalState_eq : causalState = dynamicGapCausalState family source
  repair : RepairOf (family.formedAt source)
  repair_eq : repair = family.repairAt source
  target : Source
  target_eq : target = algebra.executeRepair source causalState repair

/-- Canonical step containing no external transition datum. -/
def canonicalInternalRepairDrivenStep
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    (algebra : GapRepairAlgebra family)
    (source : Source) :
    InternalRepairDrivenStep algebra source where
  causalState := dynamicGapCausalState family source
  causalState_eq := rfl
  repair := family.repairAt source
  repair_eq := rfl
  target := algebra.next source
  target_eq := rfl

/-- A nontrivial step certifies that repair execution changes its source. -/
structure EffectiveRepairAt
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    (algebra : GapRepairAlgebra family)
    (source : Source) where
  changesSource : algebra.next source = source -> False

/-- An invariant is preserved specifically by repair execution. -/
structure RepairDrivenInvariant
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    (algebra : GapRepairAlgebra family) where
  Stable : Source -> Type e
  initiallyStable : Stable family.initial
  preserved :
    (source : Source) ->
    Stable source ->
    Stable (algebra.next source)

/-- Stability holds at every finite stage of the intrinsic repair orbit. -/
def RepairDrivenInvariant.stableAtIteration
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {algebra : GapRepairAlgebra family}
    (invariant : RepairDrivenInvariant.{u, v, w, a, x, y, z, r, s, e} algebra) :
    (n : Nat) ->
    invariant.Stable (algebra.iterate n family.initial)
  | 0 => invariant.initiallyStable
  | Nat.succ n =>
      invariant.preserved
        (algebra.iterate n family.initial)
        (invariant.stableAtIteration n)

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.GapRepairAlgebra
#print axioms Meta.RelaxedSemantics.GapRepairAlgebra.toGapDrivenDynamicSystem
#print axioms Meta.RelaxedSemantics.GapRepairAlgebra.systemIterate_eq_repairIterate
#print axioms Meta.RelaxedSemantics.InternalRepairDrivenStep
#print axioms Meta.RelaxedSemantics.canonicalInternalRepairDrivenStep
#print axioms Meta.RelaxedSemantics.EffectiveRepairAt
#print axioms Meta.RelaxedSemantics.RepairDrivenInvariant.stableAtIteration
/- AXIOM_AUDIT_END -/
