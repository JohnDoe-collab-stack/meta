import Meta.Beth.GapContraction
import Meta.Tarski.GapContraction

/-!
# Tarski gap and Beth collapse

This file closes the internal Tarski/Beth interface.

Tarski supplies a diagonal operational gap over a visible projection.  Beth
tests whether the enriched truth property is determined and explicitly readable
from the visible value.  The diagonal operational gap survives the Beth test:
it refutes both Beth collapse and explicit visible definition of truth.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v

/-- A Tarski diagonal obstruction refutes Beth collapse of the same projection. -/
theorem TarskiDiagonalObstruction.refutesBethCollapse
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (beth :
      BethContractibleGap Meaning Syntax project Truth) :
    False :=
  operationalGap_refutes_bethCollapse
    gap.operationalGap
    gap.truth_formed
    gap.shadow_not_truth
    beth

/--
A Tarski diagonal obstruction refutes explicit visible definition of truth for
the same projection.
-/
theorem TarskiDiagonalObstruction.refutesBethExplicitDefinition
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (explicit :
      ExplicitDefinitionOnVisible Meaning Syntax project Truth) :
    False :=
  operationalGap_refutes_bethExplicitDefinition
    gap.operationalGap
    gap.truth_formed
    gap.shadow_not_truth
    explicit

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.refutesBethCollapse
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.refutesBethExplicitDefinition
/- AXIOM_AUDIT_END -/
