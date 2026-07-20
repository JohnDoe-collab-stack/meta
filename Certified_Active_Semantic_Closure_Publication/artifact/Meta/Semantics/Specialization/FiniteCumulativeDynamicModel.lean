import Meta.Semantics.Specialization.FiniteContextualModel

/-!
# Finite cumulative repair semantics

This closed model separates a candidate's syntax from semantic challenges.
The current gap computes an indexed repair instruction; executing that
instruction is the only source of the successor.  The second repair preserves
the first acquired judgment, so stability is cumulative rather than a relabelled
state transition.
-/

namespace Meta
namespace RelaxedSemantics
namespace FiniteCumulativeDynamicModel

open FiniteContextualModel

/-- Three genuine stages of a finite cumulative repair orbit. -/
inductive FiniteRepairState where
  | initial
  | duringRepaired
  | complete

/-- Syntax-level candidate carrying the two judgments repaired by the orbit. -/
structure FiniteCandidate : Type where
  duringAccepted : Bool
  completionAccepted : Bool

/-- Candidate stored at each stage. -/
def candidateAt : FiniteRepairState -> FiniteCandidate
  | .initial => ⟨false, false⟩
  | .duringRepaired => ⟨true, false⟩
  | .complete => ⟨true, true⟩

/-- The two semantic challenges addressed in order. -/
inductive FiniteRepairChallenge where
  | reachedDuring
  | reachedCompletion

/-- Syntax-level validity of one challenge in a candidate. -/
def CandidateHolds
    (candidate : FiniteCandidate) :
    FiniteRepairChallenge -> Prop
  | .reachedDuring => candidate.duringAccepted = true
  | .reachedCompletion => candidate.completionAccepted = true

/-- Current challenge is calculated from the repair stage. -/
def challengeAt : FiniteRepairState -> FiniteRepairChallenge
  | .initial => .reachedDuring
  | .duringRepaired => .reachedCompletion
  | .complete => .reachedCompletion

/-- Current formed phase. -/
def phaseAt : FiniteRepairState -> Phase
  | .initial => .before
  | .duringRepaired => .during
  | .complete => .after

/-- Target phase exposed by the current gap. -/
def targetPhaseAt : FiniteRepairState -> Phase
  | .initial => .during
  | .duringRepaired => .after
  | .complete => .after

/-- Proof-relevant use computed by the current finite gap. -/
def gapUseAt :
    (source : FiniteRepairState) ->
    PhaseUse (phaseAt source) (targetPhaseAt source)
  | .initial => .enter
  | .duringRepaired => .finish
  | .complete => .afterIdentity

/-- The current candidate either refutes its challenge or is already stable. -/
inductive ChallengeStatus
    (source : FiniteRepairState) : Type where
  | mismatch :
      (CandidateHolds (candidateAt source) (challengeAt source) -> False) ->
      ChallengeStatus source
  | stable :
      CandidateHolds (candidateAt source) (challengeAt source) ->
      ChallengeStatus source

/-- Causal state calculated entirely from the current source. -/
structure FiniteCausalState (source : FiniteRepairState) : Type where
  candidate : FiniteCandidate
  candidate_eq : candidate = candidateAt source
  currentPhase : Phase
  currentPhase_eq : currentPhase = phaseAt source
  targetPhase : Phase
  targetPhase_eq : targetPhase = targetPhaseAt source
  gapUse : PhaseUse currentPhase targetPhase
  challenge : FiniteRepairChallenge
  challenge_eq : challenge = challengeAt source
  status : ChallengeStatus source

/-- Canonical causal state, including the two genuine mismatches. -/
def finiteCausalState
    (source : FiniteRepairState) :
    FiniteCausalState source := by
  cases source with
  | initial =>
      exact
        { candidate := candidateAt .initial
          candidate_eq := rfl
          currentPhase := .before
          currentPhase_eq := rfl
          targetPhase := .during
          targetPhase_eq := rfl
          gapUse := .enter
          challenge := .reachedDuring
          challenge_eq := rfl
          status := .mismatch (fun impossible => by cases impossible) }
  | duringRepaired =>
      exact
        { candidate := candidateAt .duringRepaired
          candidate_eq := rfl
          currentPhase := .during
          currentPhase_eq := rfl
          targetPhase := .after
          targetPhase_eq := rfl
          gapUse := .finish
          challenge := .reachedCompletion
          challenge_eq := rfl
          status := .mismatch (fun impossible => by cases impossible) }
  | complete =>
      exact
        { candidate := candidateAt .complete
          candidate_eq := rfl
          currentPhase := .after
          currentPhase_eq := rfl
          targetPhase := .after
          targetPhase_eq := rfl
          gapUse := .afterIdentity
          challenge := .reachedCompletion
          challenge_eq := rfl
          status := .stable rfl }

/-- Indexed repair instructions; no independent next-state function exists. -/
inductive FiniteRepairInstruction : FiniteRepairState -> Type where
  | acceptDuring : FiniteRepairInstruction .initial
  | acceptCompletion : FiniteRepairInstruction .duringRepaired
  | preserveComplete : FiniteRepairInstruction .complete

/-- Execute the syntax-level repair. -/
def FiniteRepairInstruction.apply :
    {source : FiniteRepairState} ->
    FiniteRepairInstruction source ->
    FiniteRepairState
  | _, .acceptDuring => .duringRepaired
  | _, .acceptCompletion => .complete
  | _, .preserveComplete => .complete

/-- Repair instruction calculated from the current causal stage. -/
def instructionAt :
    (source : FiniteRepairState) ->
    FiniteRepairInstruction source
  | .initial => .acceptDuring
  | .duringRepaired => .acceptCompletion
  | .complete => .preserveComplete

/--
The executable repair contains the exact causal state from which its
instruction was calculated.  Causal provenance is therefore internal data,
not an equality supplied to a theorem after the transition.
-/
structure FiniteRepair (source : FiniteRepairState) : Type where
  causalState : FiniteCausalState source
  causalState_eq : causalState = finiteCausalState source
  instruction : FiniteRepairInstruction source
  challenge_eq : causalState.challenge = challengeAt source

def repairAt (source : FiniteRepairState) : FiniteRepair source where
  causalState := finiteCausalState source
  causalState_eq := rfl
  instruction := instructionAt source
  challenge_eq := (finiteCausalState source).challenge_eq

def FiniteRepair.apply
    {source : FiniteRepairState}
    (repair : FiniteRepair source) :
    FiniteRepairState :=
  repair.instruction.apply

/-- Algebra consuming the causal state and its indexed repair. -/
structure FiniteRepairAlgebra : Type where
  executeRepair :
    (source : FiniteRepairState) ->
    FiniteRepair source ->
    FiniteRepairState

/-- Canonical execution analyzes the gap use before applying the repair. -/
def finiteRepairAlgebra : FiniteRepairAlgebra where
  executeRepair := by
    intro source repair
    cases repair.instruction with
    | acceptDuring => exact .duringRepaired
    | acceptCompletion => exact .complete
    | preserveComplete => exact .complete

/-- Successor derived solely from causal state and current repair. -/
def repairDrivenNext (source : FiniteRepairState) : FiniteRepairState :=
  finiteRepairAlgebra.executeRepair source (repairAt source)

theorem repairDrivenNext_initial :
    repairDrivenNext .initial = .duringRepaired := rfl

theorem repairDrivenNext_during :
    repairDrivenNext .duringRepaired = .complete := rfl

theorem repairDrivenNext_complete :
    repairDrivenNext .complete = .complete := rfl

/-- Candidate information can only grow along a repair. -/
structure CandidateExtension
    (before after : FiniteCandidate) : Prop where
  preservesDuring :
    before.duringAccepted = true -> after.duringAccepted = true
  preservesCompletion :
    before.completionAccepted = true -> after.completionAccepted = true

/-- Progress distinguishes active repair from a stable terminal repair. -/
inductive RepairProgress
    (source target : FiniteRepairState) : Type where
  | changes : (source = target -> False) -> RepairProgress source target
  | stable : source = target -> RepairProgress source target

/-- Complete semantic effect of executing the current repair. -/
structure FiniteRepairEffect (source : FiniteRepairState) : Type where
  causalState : FiniteCausalState source
  causalState_eq : causalState = finiteCausalState source
  repair : FiniteRepair source
  repair_eq : repair = repairAt source
  causalState_eq_repair : causalState = repair.causalState
  target : FiniteRepairState
  target_eq : target = repairDrivenNext source
  extendsCandidate : CandidateExtension (candidateAt source) (candidateAt target)
  correctsCurrent : CandidateHolds (candidateAt target) (challengeAt source)
  preservesAcquired :
    (challenge : FiniteRepairChallenge) ->
    CandidateHolds (candidateAt source) challenge ->
    CandidateHolds (candidateAt target) challenge
  progress : RepairProgress source target

/-- Every finite repair has a calculated cumulative effect. -/
def finiteRepairEffect
    (source : FiniteRepairState) :
    FiniteRepairEffect source := by
  cases source with
  | initial =>
      exact
        { causalState := finiteCausalState .initial
          causalState_eq := rfl
          repair := repairAt .initial
          repair_eq := rfl
          causalState_eq_repair := rfl
          target := .duringRepaired
          target_eq := repairDrivenNext_initial.symm
          extendsCandidate :=
            { preservesDuring := fun impossible => by cases impossible
              preservesCompletion := fun impossible => by cases impossible }
          correctsCurrent := rfl
          preservesAcquired := by
            intro challenge proof
            cases challenge <;> cases proof
          progress := .changes (fun equality => by cases equality) }
  | duringRepaired =>
      exact
        { causalState := finiteCausalState .duringRepaired
          causalState_eq := rfl
          repair := repairAt .duringRepaired
          repair_eq := rfl
          causalState_eq_repair := rfl
          target := .complete
          target_eq := repairDrivenNext_during.symm
          extendsCandidate :=
            { preservesDuring := fun _ => rfl
              preservesCompletion := fun impossible => by cases impossible }
          correctsCurrent := rfl
          preservesAcquired := by
            intro challenge proof
            cases challenge
            · exact rfl
            · cases proof
          progress := .changes (fun equality => by cases equality) }
  | complete =>
      exact
        { causalState := finiteCausalState .complete
          causalState_eq := rfl
          repair := repairAt .complete
          repair_eq := rfl
          causalState_eq_repair := rfl
          target := .complete
          target_eq := repairDrivenNext_complete.symm
          extendsCandidate :=
            { preservesDuring := fun proof => proof
              preservesCompletion := fun proof => proof }
          correctsCurrent := rfl
          preservesAcquired := fun _ proof => proof
          progress := .stable rfl }

/-- Intrinsic finite iteration. -/
def iterateRepair : Nat -> FiniteRepairState -> FiniteRepairState
  | 0, source => source
  | Nat.succ n, source => repairDrivenNext (iterateRepair n source)

/-- Stable states have no completion without the prior during repair. -/
structure FiniteStableState (source : FiniteRepairState) : Type where
  completionRequiresDuring :
    CandidateHolds (candidateAt source) .reachedCompletion ->
    CandidateHolds (candidateAt source) .reachedDuring
  currentEffect : FiniteRepairEffect source

def finiteStableState (source : FiniteRepairState) : FiniteStableState source := by
  cases source with
  | initial =>
      exact
        { completionRequiresDuring := fun impossible => by cases impossible
          currentEffect := finiteRepairEffect .initial }
  | duringRepaired =>
      exact
        { completionRequiresDuring := fun impossible => by cases impossible
          currentEffect := finiteRepairEffect .duringRepaired }
  | complete =>
      exact
        { completionRequiresDuring := fun _ => rfl
          currentEffect := finiteRepairEffect .complete }

/-- Every point of the cumulative repair orbit is stable. -/
def finiteDynamicOrbitStable
    (n : Nat) :
    FiniteStableState (iterateRepair n .initial) :=
  finiteStableState (iterateRepair n .initial)

/-- The second repair preserves the first repaired challenge. -/
theorem secondRepair_preservesFirst :
    CandidateHolds (candidateAt .complete) .reachedDuring :=
  by
    have preserved :=
      (finiteRepairEffect .duringRepaired).preservesAcquired
        .reachedDuring
        rfl
    rw [(finiteRepairEffect .duringRepaired).target_eq,
      repairDrivenNext_during] at preserved
    exact preserved

/-! ## Same transition, different intrinsic causal challenges -/

/-- Two non-identical internal descriptions of the causal challenge. -/
inductive FiniteSemanticChallenge (source : FiniteRepairState) : Type where
  | predicate :
      FiniteRepairChallenge ->
      FiniteSemanticChallenge source
  | transport :
      PhaseUse (phaseAt source) (targetPhaseAt source) ->
      FiniteSemanticChallenge source

/-- Semantic challenge denoted by every proof-relevant phase use. -/
def phaseUseChallenge :
    {left right : Phase} ->
    PhaseUse left right ->
    FiniteRepairChallenge
  | _, _, .beforeIdentity => .reachedDuring
  | _, _, .duringIdentity => .reachedDuring
  | _, _, .afterIdentity => .reachedCompletion
  | _, _, .enter => .reachedDuring
  | _, _, .finish => .reachedCompletion
  | _, _, .direct => .reachedCompletion

/-- Semantic requirement denoted by either internal challenge form. -/
def FiniteSemanticChallenge.denotes
    {source : FiniteRepairState} :
    FiniteSemanticChallenge source ->
    FiniteRepairChallenge
  | .predicate challenge => challenge
  | .transport use => phaseUseChallenge use

def predicateChallengeAt
    (source : FiniteRepairState) :
    FiniteSemanticChallenge source :=
  .predicate (challengeAt source)

def transportChallengeAt
    (source : FiniteRepairState) :
    FiniteSemanticChallenge source :=
  .transport (gapUseAt source)

theorem finiteSemanticChallenges_separated
    (source : FiniteRepairState) :
    predicateChallengeAt source = transportChallengeAt source -> False := by
  intro equality
  cases equality

/-- Both distinct causal challenges are corrected by the same repair target. -/
structure FiniteDynamicSemanticDistinction
    (source : FiniteRepairState) : Type where
  predicateChallenge : FiniteSemanticChallenge source
  transportChallenge : FiniteSemanticChallenge source
  predicateChallenge_eq : predicateChallenge = predicateChallengeAt source
  transportChallenge_eq : transportChallenge = transportChallengeAt source
  challengesSeparated : predicateChallenge = transportChallenge -> False
  predicateMismatchBefore :
    CandidateHolds (candidateAt source) predicateChallenge.denotes -> False
  transportMismatchBefore :
    CandidateHolds (candidateAt source) transportChallenge.denotes -> False
  effect : FiniteRepairEffect source
  commonTarget : FiniteRepairState
  commonTarget_eq : commonTarget = repairDrivenNext source
  commonTarget_eq_effect : commonTarget = effect.target
  predicateCorrected :
    CandidateHolds (candidateAt commonTarget) predicateChallenge.denotes
  transportCorrected :
    CandidateHolds (candidateAt commonTarget) transportChallenge.denotes
  repairProvenance :
    effect.repair = repairAt source

def finiteInitialDynamicSemanticDistinction :
    FiniteDynamicSemanticDistinction .initial where
  predicateChallenge := predicateChallengeAt .initial
  transportChallenge := transportChallengeAt .initial
  predicateChallenge_eq := rfl
  transportChallenge_eq := rfl
  challengesSeparated := finiteSemanticChallenges_separated .initial
  predicateMismatchBefore := by
    change false = true -> False
    intro impossible
    cases impossible
  transportMismatchBefore := by
    change false = true -> False
    intro impossible
    cases impossible
  effect := finiteRepairEffect .initial
  commonTarget := .duringRepaired
  commonTarget_eq := rfl
  commonTarget_eq_effect := rfl
  predicateCorrected := by change true = true; rfl
  transportCorrected := by change true = true; rfl
  repairProvenance := by
    change repairAt .initial = repairAt .initial
    rfl

def finiteSecondDynamicSemanticDistinction :
    FiniteDynamicSemanticDistinction .duringRepaired where
  predicateChallenge := predicateChallengeAt .duringRepaired
  transportChallenge := transportChallengeAt .duringRepaired
  predicateChallenge_eq := rfl
  transportChallenge_eq := rfl
  challengesSeparated := finiteSemanticChallenges_separated .duringRepaired
  predicateMismatchBefore := by
    change false = true -> False
    intro impossible
    cases impossible
  transportMismatchBefore := by
    change false = true -> False
    intro impossible
    cases impossible
  effect := finiteRepairEffect .duringRepaired
  commonTarget := .complete
  commonTarget_eq := rfl
  commonTarget_eq_effect := rfl
  predicateCorrected := by change true = true; rfl
  transportCorrected := by change true = true; rfl
  repairProvenance := by
    change repairAt .duringRepaired = repairAt .duringRepaired
    rfl

/-- Closed cumulative system with no externally supplied transition. -/
structure FiniteDynamicFoundationalSystem : Type where
  algebra : FiniteRepairAlgebra
  initialEffect : FiniteRepairEffect .initial
  secondEffect : FiniteRepairEffect .duringRepaired
  firstCausalDistinction : FiniteDynamicSemanticDistinction .initial
  secondCausalDistinction : FiniteDynamicSemanticDistinction .duringRepaired
  orbitStable : (n : Nat) -> FiniteStableState (iterateRepair n .initial)
  cumulative : CandidateHolds (candidateAt .complete) .reachedDuring

def finiteDynamicFoundationalSystem : FiniteDynamicFoundationalSystem where
  algebra := finiteRepairAlgebra
  initialEffect := finiteRepairEffect .initial
  secondEffect := finiteRepairEffect .duringRepaired
  firstCausalDistinction := finiteInitialDynamicSemanticDistinction
  secondCausalDistinction := finiteSecondDynamicSemanticDistinction
  orbitStable := finiteDynamicOrbitStable
  cumulative := secondRepair_preservesFirst

end FiniteCumulativeDynamicModel
end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.FiniteCumulativeDynamicModel.finiteCausalState
#print axioms Meta.RelaxedSemantics.FiniteCumulativeDynamicModel.finiteRepairAlgebra
#print axioms Meta.RelaxedSemantics.FiniteCumulativeDynamicModel.repairDrivenNext
#print axioms Meta.RelaxedSemantics.FiniteCumulativeDynamicModel.finiteRepairEffect
#print axioms Meta.RelaxedSemantics.FiniteCumulativeDynamicModel.finiteDynamicOrbitStable
#print axioms Meta.RelaxedSemantics.FiniteCumulativeDynamicModel.secondRepair_preservesFirst
#print axioms Meta.RelaxedSemantics.FiniteCumulativeDynamicModel.FiniteDynamicSemanticDistinction
#print axioms Meta.RelaxedSemantics.FiniteCumulativeDynamicModel.finiteDynamicFoundationalSystem
/- AXIOM_AUDIT_END -/
