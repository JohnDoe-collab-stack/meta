import LocalSemanticClosure.Standalone.Clean.meta.Beth.GapContraction

/-!
# Tarski gap and Beth collapse

This file closes the internal Tarski/Beth interface.

Tarski supplies a diagonal operational gap over a visible projection.  Beth
tests whether that projection collapses the gap by determining the enriched
interface from the visible value.  The diagonal operational gap survives the
Beth test: it refutes both Beth collapse and explicit recovery on realized
visible fibers.
-/

namespace LocalSemanticClosure
namespace Standalone
namespace Clean
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
      BethContractibleGap Meaning Syntax project) :
    False :=
  operationalGap_refutes_bethCollapse gap.operationalGap beth

/--
A Tarski diagonal obstruction refutes explicit recovery on realized visible
fibers for the same projection.
-/
theorem TarskiDiagonalObstruction.refutesBethExplicitDefinition
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (explicit :
      ExplicitDefinitionOnRealizedVisible Meaning Syntax project) :
    False :=
  operationalGap_refutes_bethExplicitDefinition gap.operationalGap explicit

end ClosedStabilityTheorem
end Clean
end Standalone
end LocalSemanticClosure

/- AXIOM_AUDIT_BEGIN -/
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.TarskiDiagonalObstruction.refutesBethCollapse
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.TarskiDiagonalObstruction.refutesBethExplicitDefinition
/- AXIOM_AUDIT_END -/
