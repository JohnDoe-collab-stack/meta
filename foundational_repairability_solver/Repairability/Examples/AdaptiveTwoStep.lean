import Repairability.DepthOptimal
import Repairability.ExactPosterior
import Repairability.Transcript
import Repairability.Examples.OneStep

namespace Repairability.Examples.AdaptiveTwoStep

inductive State where
  | start
  | prepared
  | sawFalse
  | sawTrue
deriving DecidableEq, Repr

inductive Query where
  | prepare
  | read
deriving DecidableEq, Repr

inductive Response where
  | acknowledged
  | bitFalse
  | bitTrue
deriving DecidableEq, Repr

def stateCarrier : FiniteCarrier State where
  elements := [State.start, State.prepared, State.sawFalse, State.sawTrue]
  nodup := by decide
  complete := by
    intro s
    cases s
    · exact List.Mem.head _
    · exact List.Mem.tail _ (List.Mem.head _)
    · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))
    · exact List.Mem.tail _
        (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))
  eqDec := fun x y => inferInstance

def queryCarrier : FiniteCarrier Query where
  elements := [Query.prepare, Query.read]
  nodup := by decide
  complete := by
    intro q
    cases q
    · exact List.Mem.head _
    · exact List.Mem.tail _ (List.Mem.head _)
  eqDec := fun x y => inferInstance

def responseCarrier : FiniteCarrier Response where
  elements := [Response.acknowledged, Response.bitFalse, Response.bitTrue]
  nodup := by decide
  complete := by
    intro r
    cases r
    · exact List.Mem.head _
    · exact List.Mem.tail _ (List.Mem.head _)
    · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))
  eqDec := fun x y => inferInstance

def compatible : State → Bool → Bool
  | State.start, _ => true
  | State.prepared, _ => true
  | State.sawFalse, false => true
  | State.sawFalse, true => false
  | State.sawTrue, false => false
  | State.sawTrue, true => true

def authorized : State → Unit → Query → Bool
  | State.start, _, Query.prepare => true
  | State.start, _, Query.read => false
  | State.prepared, _, Query.prepare => false
  | State.prepared, _, Query.read => true
  | State.sawFalse, _, Query.prepare => false
  | State.sawFalse, _, Query.read => false
  | State.sawTrue, _, Query.prepare => false
  | State.sawTrue, _, Query.read => false

def respond : Bool → Query → Response
  | _, Query.prepare => Response.acknowledged
  | false, Query.read => Response.bitFalse
  | true, Query.read => Response.bitTrue

def advance : State → Unit → Query → Response → State
  | State.start, _, Query.prepare, Response.acknowledged => State.prepared
  | State.start, _, Query.prepare, Response.bitFalse => State.start
  | State.start, _, Query.prepare, Response.bitTrue => State.start
  | State.start, _, Query.read, _ => State.start
  | State.prepared, _, Query.prepare, _ => State.prepared
  | State.prepared, _, Query.read, Response.acknowledged => State.prepared
  | State.prepared, _, Query.read, Response.bitFalse => State.sawFalse
  | State.prepared, _, Query.read, Response.bitTrue => State.sawTrue
  | State.sawFalse, _, _, _ => State.sawFalse
  | State.sawTrue, _, _, _ => State.sawTrue

def decision : State → Unit → Option Bool
  | State.start, _ => none
  | State.prepared, _ => none
  | State.sawFalse, _ => some false
  | State.sawTrue, _ => some true

def game : PublicGame where
  World := Bool
  State := State
  Goal := Unit
  Action := Bool
  Query := Query
  Response := Response
  worlds := OneStep.boolCarrier
  states := stateCarrier
  goals := OneStep.unitCarrier
  actions := OneStep.boolCarrier
  queries := queryCarrier
  responses := responseCarrier
  actionEq := fun x y => inferInstance
  responseEq := fun x y => inferInstance
  compatible := compatible
  required := fun _ w => w
  authorized := authorized
  respond := respond
  advance := advance
  decision? := decision
  stateSafe := fun _ _ => true
  priorClosuresRetained := fun _ _ => true
  queryCost := fun _ _ _ => 1
  posteriorContains := by
    intro s g q r w ha hc hr
    change authorized s g q = true at ha
    change compatible s w = true at hc
    change respond w q = r at hr
    change compatible (advance s g q r) w = true
    cases g
    cases s <;> cases q <;> cases r <;> cases w <;>
      cases ha <;> cases hc <;> cases hr <;> rfl
  fiberMonotone := by
    intro s g q r w ha hreal hc
    rcases hreal with ⟨actual, hactual, hresponse⟩
    change authorized s g q = true at ha
    change compatible s actual = true at hactual
    change respond actual q = r at hresponse
    change compatible (advance s g q r) w = true at hc
    change compatible s w = true
    cases g
    cases s <;> cases q <;> cases r <;> cases w <;> cases actual <;>
      cases ha <;> cases hactual <;> cases hresponse <;> cases hc <;> rfl
  closuresRetained := by
    intro s g q r ha hreal
    rfl

def exactPosterior : PublicGame.ExactPosteriorCompiler game where
  responseExact := by
    intro s g q r w ha hr hc
    rcases hr with ⟨actual, hactual, hresponse⟩
    change authorized s g q = true at ha
    change compatible s actual = true at hactual
    change respond actual q = r at hresponse
    change compatible (advance s g q r) w = true at hc
    change respond w q = r
    cases g
    cases s <;> cases q <;> cases r <;> cases w <;> cases actual <;>
      cases ha <;> cases hactual <;> cases hresponse <;> cases hc <;> rfl

theorem preparation_is_not_discriminating :
    respond false Query.prepare = respond true Query.prepare := by
  rfl

theorem start_not_winning_at_depth_one :
    PublicGame.winningWithinB game () 1 State.start = false := by
  rfl

theorem start_winning_at_depth_two :
    PublicGame.winningWithinB game () 2 State.start = true := by
  rfl

def extractedAdaptiveStrategy :
    PublicGame.PublicTreeWithin game () 2 State.start :=
  PublicGame.winningWithinB_build game () 2 State.start
    start_winning_at_depth_two

theorem no_one_step_strategy :
    ¬ Nonempty (PublicGame.PublicTreeWithin game () 1 State.start) := by
  intro htree
  rcases htree with ⟨tree⟩
  have hwin := PublicGame.publicTreeWithin_complete game () tree
  rw [start_not_winning_at_depth_one] at hwin
  exact Bool.noConfusion hwin

def computedOptimalVerdict :
    PublicGame.OptimalDepthSolveResult game () State.start :=
  PublicGame.solveDepthOptimal game () State.start

def falseTranscript :
    PublicGame.CertifiedTranscript game () State.start State.sawFalse := by
  have hprepareAuthorized :
      PublicGame.Authorized game State.start () Query.prepare := by rfl
  have hackRealizable :
      PublicGame.Realizable game State.start Query.prepare
        Response.acknowledged :=
    ⟨false, by rfl, by rfl⟩
  have hreadAuthorized :
      PublicGame.Authorized game State.prepared () Query.read := by rfl
  have hfalseRealizable :
      PublicGame.Realizable game State.prepared Query.read
        Response.bitFalse :=
    ⟨false, by rfl, by rfl⟩
  have preparedTranscript :
      PublicGame.CertifiedTranscript game () State.start State.prepared :=
    @PublicGame.CertifiedTranscript.step game () State.start State.start
      (@PublicGame.CertifiedTranscript.nil game () State.start)
      Query.prepare Response.acknowledged hprepareAuthorized hackRealizable
  exact @PublicGame.CertifiedTranscript.step game () State.start State.prepared
    preparedTranscript Query.read Response.bitFalse hreadAuthorized
      hfalseRealizable

theorem falseTranscript_exact_fiber (w : Bool) :
    PublicGame.Compatible game State.sawFalse w ↔
      PublicGame.Compatible game State.start w ∧
        PublicGame.TranscriptMatches falseTranscript w :=
  PublicGame.exactTranscript_iff game exactPosterior () falseTranscript w

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.Examples.AdaptiveTwoStep.exactPosterior
#print axioms Repairability.Examples.AdaptiveTwoStep.extractedAdaptiveStrategy
#print axioms Repairability.Examples.AdaptiveTwoStep.no_one_step_strategy
#print axioms Repairability.Examples.AdaptiveTwoStep.computedOptimalVerdict
#print axioms Repairability.Examples.AdaptiveTwoStep.falseTranscript
#print axioms Repairability.Examples.AdaptiveTwoStep.falseTranscript_exact_fiber
/- AXIOM_AUDIT_END -/
