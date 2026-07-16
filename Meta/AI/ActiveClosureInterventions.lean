import Meta.AI.FiniteActiveSemanticClosure

/-!
# Typed interventions for active semantic closure

An intervention replaces one structural equation and recomputes every
downstream object.  The dependent indices prevent a use, transport, response,
or repair from being copied from an incompatible gap.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace Interventions

universe u v

variable
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}

structure IntervenedOpenRun
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent) where
  use : GapAuthorizedUse D G state.agent gap
  transport : GapAuthorizedTransport D G T state.agent gap use
  query : I.Query gap.index
  queryAdmissible : I.QueryAdmissible state.agent gap use transport query
  response : I.Response query
  repair :
    IntrinsicRepair D G T I
      state.agent gap use transport query response
  after : ActiveSemanticClosureState D
  after_eq : after = ActiveSemanticClosureSystem.executeRepair state repair

def runNatural
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D) :
    ActiveSemanticClosureState D :=
  system.nextState state

def replaceObservation
    (state : ActiveSemanticClosureState D)
    (observation : D.Observation) : ActiveSemanticClosureState D :=
  { world := state.world
    agent :=
      { candidate := state.agent.candidate
        observation := observation
        history := state.agent.history } }

def runWithObservation
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (observation : D.Observation) : ActiveSemanticClosureState D :=
  system.nextState (replaceObservation state observation)

def runWithGap
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent) :
    IntervenedOpenRun system state gap :=
  let use := system.authorize state.agent gap
  let transport := system.executeTransport state.agent gap use
  let query := system.selectQuery transport
  let response := system.respond state.world query
  let repair :=
    system.buildRepair state.agent gap use transport query response
  { use := use
    transport := transport
    query := query
    queryAdmissible := system.selectedQueryAdmissible transport
    response := response
    repair := repair
    after := ActiveSemanticClosureSystem.executeRepair state repair
    after_eq := rfl }

def runWithUse
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent)
    (use : GapAuthorizedUse D G state.agent gap) :
    IntervenedOpenRun system state gap :=
  let transport := system.executeTransport state.agent gap use
  let query := system.selectQuery transport
  let response := system.respond state.world query
  let repair :=
    system.buildRepair state.agent gap use transport query response
  { use := use
    transport := transport
    query := query
    queryAdmissible := system.selectedQueryAdmissible transport
    response := response
    repair := repair
    after := ActiveSemanticClosureSystem.executeRepair state repair
    after_eq := rfl }

def runWithTransport
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent)
    (use : GapAuthorizedUse D G state.agent gap)
    (transport : GapAuthorizedTransport D G T state.agent gap use) :
    IntervenedOpenRun system state gap :=
  let query := system.selectQuery transport
  let response := system.respond state.world query
  let repair :=
    system.buildRepair state.agent gap use transport query response
  { use := use
    transport := transport
    query := query
    queryAdmissible := system.selectedQueryAdmissible transport
    response := response
    repair := repair
    after := ActiveSemanticClosureSystem.executeRepair state repair
    after_eq := rfl }

def runWithQuery
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent)
    (use : GapAuthorizedUse D G state.agent gap)
    (transport : GapAuthorizedTransport D G T state.agent gap use)
    (query : I.Query gap.index)
    (admissible : I.QueryAdmissible state.agent gap use transport query) :
    IntervenedOpenRun system state gap :=
  let response := system.respond state.world query
  let repair :=
    system.buildRepair state.agent gap use transport query response
  { use := use
    transport := transport
    query := query
    queryAdmissible := admissible
    response := response
    repair := repair
    after := ActiveSemanticClosureSystem.executeRepair state repair
    after_eq := rfl }

def runWithResponse
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent)
    (use : GapAuthorizedUse D G state.agent gap)
    (transport : GapAuthorizedTransport D G T state.agent gap use)
    (query : I.Query gap.index)
    (admissible : I.QueryAdmissible state.agent gap use transport query)
    (response : I.Response query) : IntervenedOpenRun system state gap :=
  let repair :=
    system.buildRepair state.agent gap use transport query response
  { use := use
    transport := transport
    query := query
    queryAdmissible := admissible
    response := response
    repair := repair
    after := ActiveSemanticClosureSystem.executeRepair state repair
    after_eq := rfl }

def runWithPatch
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent)
    (use : GapAuthorizedUse D G state.agent gap)
    (transport : GapAuthorizedTransport D G T state.agent gap use)
    (query : I.Query gap.index)
    (admissible : I.QueryAdmissible state.agent gap use transport query)
    (response : I.Response query)
    (repair :
      IntrinsicRepair D G T I
        state.agent gap use transport query response) :
    IntervenedOpenRun system state gap :=
  { use := use
    transport := transport
    query := query
    queryAdmissible := admissible
    response := response
    repair := repair
    after := ActiveSemanticClosureSystem.executeRepair state repair
    after_eq := rfl }

theorem replaceObservation_world
    (state : ActiveSemanticClosureState D)
    (observation : D.Observation) :
    (replaceObservation state observation).world = state.world := rfl

theorem replaceObservation_candidate
    (state : ActiveSemanticClosureState D)
    (observation : D.Observation) :
    (replaceObservation state observation).agent.candidate =
      state.agent.candidate := rfl

theorem replaceObservation_history
    (state : ActiveSemanticClosureState D)
    (observation : D.Observation) :
    (replaceObservation state observation).agent.history =
      state.agent.history := rfl

theorem intervenedOpenRun_world
    {system : ActiveSemanticClosureSystem D G T I}
    {state : ActiveSemanticClosureState D}
    {gap : OperationalGap D G state.agent}
    (run : IntervenedOpenRun system state gap) :
    run.after.world = state.world := by
  rw [run.after_eq]
  rfl

/-! ## Reachable finite interventions with observable effects -/

open Finite

def finiteNaturalOpenRun0 := runWithGap finiteSystem state0 gap0

def finiteUseIntervention0 :=
  runWithUse finiteSystem state0 gap0 inspectUse0

def finiteTransportIntervention0 :=
  runWithTransport finiteSystem state0 gap0 use0 evidenceTransport0

def finiteConfirmQueryIntervention0 :=
  runWithQuery finiteSystem state0 gap0 use0 transport0
    confirmQuery0 confirmQuery0_admissible

def finiteCrossedResponseIntervention0 :=
  runWithResponse finiteSystem state0 gap0 use0 transport0
    query0 (finiteSystem.selectedQueryAdmissible transport0)
    alternateResponse0

def finiteCrossedPatchIntervention0 :=
  runWithPatch finiteSystem state0 gap0 use0 transport0
    query0 (finiteSystem.selectedQueryAdmissible transport0)
    alternateResponse0 alternateRepair0

theorem finiteUseIntervention_changesDirection :
    finiteNaturalOpenRun0.use.direction =
      finiteUseIntervention0.use.direction -> False := by
  intro equality
  cases equality

theorem finiteUseIntervention_changesTransport :
    finiteNaturalOpenRun0.transport.reading.direction =
      finiteUseIntervention0.transport.reading.direction -> False := by
  intro equality
  cases equality

theorem finiteTransportIntervention_changesQuery :
    finiteNaturalOpenRun0.query = finiteTransportIntervention0.query -> False := by
  intro equality
  cases equality

theorem finiteCrossedResponse_changesRepair :
    finiteNaturalOpenRun0.repair.candidatePatch =
      finiteCrossedResponseIntervention0.repair.candidatePatch -> False := by
  intro equality
  cases equality

theorem finiteNaturalOpenRun0_after_eq :
    finiteNaturalOpenRun0.after = state1 := rfl

theorem finiteCrossedResponseIntervention0_after_eq :
    finiteCrossedResponseIntervention0.after = alternateState1 := rfl

theorem finiteCrossedResponse_changesSuccessor :
    finiteNaturalOpenRun0.after =
      finiteCrossedResponseIntervention0.after -> False := by
  intro equality
  have statesEqual : state1 = alternateState1 :=
    finiteNaturalOpenRun0_after_eq.symm.trans
      (equality.trans finiteCrossedResponseIntervention0_after_eq)
  have candidatesEqual := congrArg
    (fun state : ClosedState => state.agent.candidate.first)
    statesEqual
  cases candidatesEqual

theorem finiteCrossedResponse_failsClosure :
    GapClosedBy finiteSystem state0 gap0
      finiteCrossedResponseIntervention0.after -> False := by
  intro closure
  apply alternateResponse0_not_closesGap
  simpa [finiteCrossedResponseIntervention0, runWithResponse,
    alternateState1] using closure

end Interventions
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.Interventions.runWithObservation
#print axioms Meta.ActiveSemanticClosure.Interventions.runWithGap
#print axioms Meta.ActiveSemanticClosure.Interventions.runWithUse
#print axioms Meta.ActiveSemanticClosure.Interventions.runWithTransport
#print axioms Meta.ActiveSemanticClosure.Interventions.runWithQuery
#print axioms Meta.ActiveSemanticClosure.Interventions.runWithResponse
#print axioms Meta.ActiveSemanticClosure.Interventions.runWithPatch
#print axioms Meta.ActiveSemanticClosure.Interventions.finiteTransportIntervention_changesQuery
#print axioms Meta.ActiveSemanticClosure.Interventions.finiteCrossedResponse_failsClosure
/- AXIOM_AUDIT_END -/
