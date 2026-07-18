import Carbone.CW0.Lean.CarbonWorld
import Meta.Semantics.DynamicFoundationalStability

/-!
# CW0: adapter from a carbon world to the repair-driven Core

The adapter consumes an intrinsic dynamic-return atlas whose formed interface
is definitionally identified, pointwise, with the current admissible carbon
source.  Repairs are canonical inhabitants indexed by that formed interface.
The resulting `GapRepairAlgebra` executes the carried repair; it introduces no
independent successor.
-/

namespace Meta
namespace Carbone
namespace CW0

open ClosedStabilityTheorem
open DynamicRelaxedUsage
open RelaxedSemantics

universe u v w y z

/-- The only repair admitted at a point is the repair derived by its world. -/
structure CanonicalRepairAt
    (world : CarbonWorld)
    (point : world.Point) where
  repair : CarbonRepair point.1
  repair_eq : repair = world.repairAt point

namespace CanonicalRepairAt

def cast
    {world : CarbonWorld}
    {left right : world.Point}
    (equality : left = right)
    (repair : CanonicalRepairAt world left) :
    CanonicalRepairAt world right :=
  equality ▸ repair

def execute
    {world : CarbonWorld}
    (point : world.Point)
    (canonical : CanonicalRepairAt world point) : world.Point :=
  ⟨ executeRepair point.1 canonical.repair
  , by
      rw [canonical.repair_eq]
      exact world.closedUnderRepair point.1 point.2 ⟩

theorem execute_source_eq_worldStep
    {world : CarbonWorld}
    (point : world.Point)
    (canonical : CanonicalRepairAt world point) :
    (execute point canonical).1 = (world.step point).1 := by
  change
    executeRepair point.1 canonical.repair =
      executeRepair point.1 (world.repairAt point)
  rw [canonical.repair_eq]

end CanonicalRepairAt

def pointProject
    (world : CarbonWorld)
    (point : world.Point) : CarbonVisible :=
  project point.1.organization

/--
An intrinsic Core atlas over the admissible points of one carbon world.

The pointwise equality is structural data: the formed interface recovered at
the current source is that source.  It does not state or assume anything about
a future source.
-/
structure CarbonCoreAtlas
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    (branch : Branch)
    (world : CarbonWorld)
    (WitnessOf : world.Point -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        world.Point ->
        Type z) where
  family :
    IntrinsicDynamicReturnFamily
      complete
      coherence
      branch
      world.Point
      world.Point
      WitnessOf
      RealizesInterface
      CarbonVisible
      (pointProject world)
      (CanonicalRepairAt world)
  formedAt_eq_source :
    (source : world.Point) -> family.formedAt source = source

namespace CarbonCoreAtlas

variable
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {world : CarbonWorld}
    {WitnessOf : world.Point -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        world.Point ->
        Type z}

def repairAtSource
    (atlas :
      CarbonCoreAtlas
        complete coherence branch world WitnessOf RealizesInterface)
    (source : world.Point)
    (repair : CanonicalRepairAt world (atlas.family.formedAt source)) :
    CanonicalRepairAt world source :=
  repair.cast (atlas.formedAt_eq_source source)

def executeCoreRepair
    (atlas :
      CarbonCoreAtlas
        complete coherence branch world WitnessOf RealizesInterface)
    (source : world.Point)
    (repair : CanonicalRepairAt world (atlas.family.formedAt source)) :
    world.Point :=
  (atlas.repairAtSource source repair).execute source

theorem executeCoreRepair_source_eq_worldStep
    (atlas :
      CarbonCoreAtlas
        complete coherence branch world WitnessOf RealizesInterface)
    (source : world.Point)
    (repair : CanonicalRepairAt world (atlas.family.formedAt source)) :
    (atlas.executeCoreRepair source repair).1 = (world.step source).1 :=
  CanonicalRepairAt.execute_source_eq_worldStep
    source
    (atlas.repairAtSource source repair)

/-- The Core algebra executes exactly the repair carried by the formed pole. -/
def toGapRepairAlgebra
    (atlas :
      CarbonCoreAtlas
        complete coherence branch world WitnessOf RealizesInterface) :
    GapRepairAlgebra atlas.family where
  executeRepair := fun source _causalState repair =>
    atlas.executeCoreRepair source repair

/-- The derived Core successor and the carbon-world step have the same source. -/
theorem coreNext_source_eq_worldStep
    (atlas :
      CarbonCoreAtlas
        complete coherence branch world WitnessOf RealizesInterface)
    (source : world.Point) :
    ((atlas.toGapRepairAlgebra.next source).1) = (world.step source).1 := by
  exact
    atlas.executeCoreRepair_source_eq_worldStep
      source
      (atlas.family.repairAt source)

end CarbonCoreAtlas

end CW0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CW0.CanonicalRepairAt.execute_source_eq_worldStep
#print axioms Meta.Carbone.CW0.CarbonCoreAtlas.toGapRepairAlgebra
#print axioms Meta.Carbone.CW0.CarbonCoreAtlas.coreNext_source_eq_worldStep
/- AXIOM_AUDIT_END -/
