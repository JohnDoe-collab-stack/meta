import Repairability.ExactPosterior

namespace Repairability.PublicGame

structure ConcreteTraceInterface (E : PublicGame) where
  Trace : Type
  consistent : Trace → E.World → Bool
  closuresRetained : Trace → E.State → Bool

structure LearnedPacket (E : PublicGame) where
  proposedState : E.State
  proposedAction : E.Action

def abstractionCoversB
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (state : E.State) : Bool :=
  allList
    (fun w => (!C.consistent trace w) || E.compatible state w)
    E.worlds.elements

def learnedPacketAcceptedB
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (g : E.Goal) (packet : LearnedPacket E) : Bool :=
  (((abstractionCoversB E C trace packet.proposedState &&
      targetB E packet.proposedState g) &&
      C.closuresRetained trace packet.proposedState) &&
    match E.decision? packet.proposedState g with
    | none => false
    | some a => decideWith (E.actionEq a packet.proposedAction))

theorem abstractionCoversB_sound
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (state : E.State)
    (hcover : abstractionCoversB E C trace state = true) :
    ∀ w, C.consistent trace w = true → Compatible E state w := by
  intro w hconsistent
  have hpoint := (allList_eq_true_iff
    (fun w => (!C.consistent trace w) || E.compatible state w)
    E.worlds.elements).mp hcover w (E.worlds.complete w)
  exact (boolNotOr_eq_true_iff
    (C.consistent trace w) (E.compatible state w)).mp hpoint hconsistent

theorem acceptedLearnedPacket_sound
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (g : E.Goal) (packet : LearnedPacket E)
    (haccepted : learnedPacketAcceptedB E C trace g packet = true) :
    (∀ w, C.consistent trace w = true →
      E.required g w = packet.proposedAction) ∧
    E.stateSafe packet.proposedState g = true ∧
    C.closuresRetained trace packet.proposedState = true := by
  unfold learnedPacketAcceptedB at haccepted
  cases hdecision : E.decision? packet.proposedState g with
  | none =>
      rw [hdecision] at haccepted
      have houter := (boolAnd_eq_true_iff
        ((abstractionCoversB E C trace packet.proposedState &&
          targetB E packet.proposedState g) &&
          C.closuresRetained trace packet.proposedState)
        false).mp haccepted
      exact Bool.noConfusion houter.2
  | some action =>
      rw [hdecision] at haccepted
      have houter := (boolAnd_eq_true_iff
        ((abstractionCoversB E C trace packet.proposedState &&
          targetB E packet.proposedState g) &&
          C.closuresRetained trace packet.proposedState)
        (decideWith (E.actionEq action packet.proposedAction))).mp haccepted
      have hmiddle := (boolAnd_eq_true_iff
        (abstractionCoversB E C trace packet.proposedState &&
          targetB E packet.proposedState g)
        (C.closuresRetained trace packet.proposedState)).mp houter.1
      have hinner := (boolAnd_eq_true_iff
        (abstractionCoversB E C trace packet.proposedState)
        (targetB E packet.proposedState g)).mp hmiddle.1
      have htarget := (targetB_eq_true_iff E packet.proposedState g).mp hinner.2
      have heq : action = packet.proposedAction :=
        (decideWith_eq_true_iff (E.actionEq action packet.proposedAction)).mp houter.2
      constructor
      · intro w hconsistent
        have hcompatible := abstractionCoversB_sound E C trace
          packet.proposedState hinner.1 w hconsistent
        rcases htarget.2.2 with ⟨targetAction, htargetDecision, hall⟩
        have haction : action = targetAction := by
          rw [hdecision] at htargetDecision
          cases htargetDecision
          rfl
        exact (hall w hcompatible).trans (haction.symm.trans heq)
      · exact ⟨htarget.1, hmiddle.2⟩

theorem acceptedLearnedPacket_repairable
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (g : E.Goal) (packet : LearnedPacket E)
    (haccepted : learnedPacketAcceptedB E C trace g packet = true) :
    CertifiedRepairableAt E packet.proposedState g := by
  unfold learnedPacketAcceptedB at haccepted
  cases hdecision : E.decision? packet.proposedState g with
  | none =>
      rw [hdecision] at haccepted
      have houter := (boolAnd_eq_true_iff
        ((abstractionCoversB E C trace packet.proposedState &&
          targetB E packet.proposedState g) &&
          C.closuresRetained trace packet.proposedState)
        false).mp haccepted
      exact False.elim (Bool.noConfusion houter.2)
  | some action =>
      rw [hdecision] at haccepted
      have houter := (boolAnd_eq_true_iff
        ((abstractionCoversB E C trace packet.proposedState &&
          targetB E packet.proposedState g) &&
          C.closuresRetained trace packet.proposedState)
        (decideWith (E.actionEq action packet.proposedAction))).mp haccepted
      have hmiddle := (boolAnd_eq_true_iff
        (abstractionCoversB E C trace packet.proposedState &&
          targetB E packet.proposedState g)
        (C.closuresRetained trace packet.proposedState)).mp houter.1
      have hinner := (boolAnd_eq_true_iff
        (abstractionCoversB E C trace packet.proposedState)
        (targetB E packet.proposedState g)).mp hmiddle.1
      exact ⟨0, ⟨PublicTreeWithin.leaf
        ((targetB_eq_true_iff E packet.proposedState g).mp hinner.2)⟩⟩

inductive LearnedCheckResult
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (g : E.Goal) (packet : LearnedPacket E) where
  | accepted
      (proof : learnedPacketAcceptedB E C trace g packet = true)
  | rejected
      (proof : learnedPacketAcceptedB E C trace g packet = false)

def checkLearnedPacket
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (g : E.Goal) (packet : LearnedPacket E) :
    LearnedCheckResult E C trace g packet := by
  cases hcheck : learnedPacketAcceptedB E C trace g packet with
  | true => exact .accepted hcheck
  | false => exact .rejected hcheck

def checkedLearnedAction?
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (g : E.Goal) (packet : LearnedPacket E) : Option E.Action :=
  match learnedPacketAcceptedB E C trace g packet with
  | true => some packet.proposedAction
  | false => none

theorem rejectedPacket_abstains
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (g : E.Goal) (packet : LearnedPacket E)
    (hrejected : learnedPacketAcceptedB E C trace g packet = false) :
    checkedLearnedAction? E C trace g packet = none := by
  unfold checkedLearnedAction?
  rw [hrejected]

theorem emittedLearnedAction_sound
    (E : PublicGame) (C : ConcreteTraceInterface E)
    (trace : C.Trace) (g : E.Goal) (packet : LearnedPacket E)
    (action : E.Action)
    (hemitted : checkedLearnedAction? E C trace g packet = some action) :
    ∀ w, C.consistent trace w = true → E.required g w = action := by
  unfold checkedLearnedAction? at hemitted
  cases hcheck : learnedPacketAcceptedB E C trace g packet with
  | false =>
      rw [hcheck] at hemitted
      contradiction
  | true =>
      rw [hcheck] at hemitted
      have haction : packet.proposedAction = action := by
        cases hemitted
        rfl
      intro w hw
      exact ((acceptedLearnedPacket_sound E C trace g packet hcheck).1 w hw).trans
        haction

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.abstractionCoversB_sound
#print axioms Repairability.PublicGame.acceptedLearnedPacket_sound
#print axioms Repairability.PublicGame.acceptedLearnedPacket_repairable
#print axioms Repairability.PublicGame.checkLearnedPacket
#print axioms Repairability.PublicGame.rejectedPacket_abstains
#print axioms Repairability.PublicGame.emittedLearnedAction_sound
/- AXIOM_AUDIT_END -/
