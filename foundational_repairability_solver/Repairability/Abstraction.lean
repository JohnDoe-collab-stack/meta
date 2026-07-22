import Repairability.FixedPoint

namespace Repairability.PublicGame

structure LiftedQuery
    (concrete : PublicGame.{0}) (s : concrete.State) (g : concrete.Goal) where
  query : concrete.Query
  playable : Playable concrete s g query

/--
A proof-relevant forward simulation.  An abstract public strategy is usable in
the concrete game only when every abstract query can be implemented and every
concrete response can be translated to a realizable abstract response with a
commuting successor state.
-/
structure ForwardPublicSimulation
    (concrete abstract : PublicGame.{0}) where
  mapState : concrete.State → abstract.State
  mapGoal : concrete.Goal → abstract.Goal
  targetBack :
    ∀ s g, CertifiedTarget abstract (mapState s) (mapGoal g) →
      CertifiedTarget concrete s g
  liftQuery :
    ∀ s g q,
      Playable abstract (mapState s) (mapGoal g) q →
      LiftedQuery concrete s g
  liftResponse :
    ∀ s g q
      (abstractPlayable : Playable abstract (mapState s) (mapGoal g) q)
      (r : concrete.Response),
      Realizable concrete s (liftQuery s g q abstractPlayable).query r →
      {abstractResponse //
        Realizable abstract (mapState s) q abstractResponse ∧
        mapState
            (concrete.advance s g
              (liftQuery s g q abstractPlayable).query r) =
          abstract.advance (mapState s) (mapGoal g) q abstractResponse}

def transferPublicTree
    {concrete abstract : PublicGame.{0}}
    (simulation : ForwardPublicSimulation concrete abstract)
    (g : concrete.Goal) :
    (fuel : Nat) → (s : concrete.State) →
      PublicTreeWithin abstract (simulation.mapGoal g) fuel
        (simulation.mapState s) →
      PublicTreeWithin concrete g fuel s
  | _, s, .leaf target =>
      PublicTreeWithin.leaf (simulation.targetBack s g target)
  | fuel + 1, s, .query q abstractPlayable abstractChildren => by
      let lifted := simulation.liftQuery s g q abstractPlayable
      refine PublicTreeWithin.query lifted.query lifted.playable ?_
      intro r hr
      let mapped := simulation.liftResponse s g q abstractPlayable r hr
      have abstractChild := abstractChildren mapped.1 mapped.2.1
      have aligned :
          PublicTreeWithin abstract (simulation.mapGoal g) fuel
            (simulation.mapState
              (concrete.advance s g lifted.query r)) := by
        rw [mapped.2.2]
        exact abstractChild
      exact transferPublicTree simulation g fuel
        (concrete.advance s g lifted.query r) aligned

theorem abstractWin_transfers
    {concrete abstract : PublicGame.{0}}
    (simulation : ForwardPublicSimulation concrete abstract)
    (g : concrete.Goal) (fuel : Nat) (s : concrete.State)
    (abstractWin :
      winningWithinB abstract (simulation.mapGoal g) fuel
        (simulation.mapState s) = true) :
    Nonempty (PublicTreeWithin concrete g fuel s) := by
  exact ⟨transferPublicTree simulation g fuel s
    (winningWithinB_build abstract (simulation.mapGoal g) fuel
      (simulation.mapState s) abstractWin)⟩

def identitySimulation (E : PublicGame.{0}) : ForwardPublicSimulation E E where
  mapState := fun s => s
  mapGoal := fun g => g
  targetBack := by
    intro s g target
    exact target
  liftQuery := by
    intro s g q playable
    exact ⟨q, playable⟩
  liftResponse := by
    intro s g q playable r realizable
    exact ⟨r, realizable, rfl⟩

theorem identity_transfer_preserves_wins
    (E : PublicGame.{0}) (g : E.Goal) (fuel : Nat) (s : E.State)
    (hwin : winningWithinB E g fuel s = true) :
    Nonempty (PublicTreeWithin E g fuel s) :=
  abstractWin_transfers (identitySimulation E) g fuel s hwin

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.transferPublicTree
#print axioms Repairability.PublicGame.abstractWin_transfers
#print axioms Repairability.PublicGame.identitySimulation
#print axioms Repairability.PublicGame.identity_transfer_preserves_wins
/- AXIOM_AUDIT_END -/
