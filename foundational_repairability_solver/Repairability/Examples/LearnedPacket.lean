import Repairability.LearnedTransfer
import Repairability.Examples.OneStep

namespace Repairability.Examples.LearnedPacket

def traceMatches : Bool → Bool → Bool
  | false, false => true
  | false, true => false
  | true, false => false
  | true, true => true

def concrete : PublicGame.ConcreteTraceInterface OneStep.game where
  Trace := Bool
  consistent := traceMatches
  closuresRetained := fun _ _ => true

def packet : Bool → PublicGame.LearnedPacket OneStep.game
  | false => {
      proposedState := OneStep.State.sawFalse
      proposedAction := false
    }
  | true => {
      proposedState := OneStep.State.sawTrue
      proposedAction := true
    }

theorem packet_accepted (trace : Bool) :
    PublicGame.learnedPacketAcceptedB OneStep.game concrete trace ()
      (packet trace) = true := by
  cases trace <;> rfl

theorem packet_transfers_to_concrete_worlds (trace : Bool) :
    (∀ w, concrete.consistent trace w = true →
      OneStep.game.required () w = (packet trace).proposedAction) ∧
    OneStep.game.stateSafe (packet trace).proposedState () = true ∧
    concrete.closuresRetained trace (packet trace).proposedState = true :=
  PublicGame.acceptedLearnedPacket_sound OneStep.game concrete trace ()
    (packet trace) (packet_accepted trace)

theorem packet_is_certifiably_repairable (trace : Bool) :
    PublicGame.CertifiedRepairableAt OneStep.game
      (packet trace).proposedState () :=
  PublicGame.acceptedLearnedPacket_repairable OneStep.game concrete trace ()
    (packet trace) (packet_accepted trace)

def forgedPacket : PublicGame.LearnedPacket OneStep.game where
  proposedState := OneStep.State.sawFalse
  proposedAction := true

theorem forged_packet_rejected :
    PublicGame.learnedPacketAcceptedB OneStep.game concrete false ()
      forgedPacket = false := by
  rfl

theorem forged_packet_forces_abstention :
    PublicGame.checkedLearnedAction? OneStep.game concrete false ()
      forgedPacket = none :=
  PublicGame.rejectedPacket_abstains OneStep.game concrete false ()
    forgedPacket forged_packet_rejected

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.Examples.LearnedPacket.packet_accepted
#print axioms Repairability.Examples.LearnedPacket.packet_transfers_to_concrete_worlds
#print axioms Repairability.Examples.LearnedPacket.packet_is_certifiably_repairable
#print axioms Repairability.Examples.LearnedPacket.forged_packet_rejected
#print axioms Repairability.Examples.LearnedPacket.forged_packet_forces_abstention
/- AXIOM_AUDIT_END -/
