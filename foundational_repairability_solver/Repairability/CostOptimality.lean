import Repairability.ExactPosterior

namespace Repairability

def maxNatList : List Nat → Nat
  | [] => 0
  | value :: rest => Nat.max value (maxNatList rest)

theorem le_maxNatList_of_mem
    (value : Nat) : ∀ values, value ∈ values → value ≤ maxNatList values := by
  intro values hmem
  induction values with
  | nil => contradiction
  | cons head tail ih =>
      cases hmem with
      | head => exact Nat.le_max_left value (maxNatList tail)
      | tail _ htail =>
          exact Nat.le_trans (ih htail)
            (Nat.le_max_right head (maxNatList tail))

theorem le_maxNatList_map
    {α : Type} (score : α → Nat) (values : List α)
    (value : α) (hmem : value ∈ values) :
    score value ≤ maxNatList (values.map score) :=
  le_maxNatList_of_mem (score value) (values.map score)
    (List.mem_map.mpr ⟨value, hmem, rfl⟩)

namespace PublicGame

/-- Relational recomputation of the cost induced by a concrete world. -/
inductive PublicExecutionCost (E : PublicGame) (g : E.Goal) :
    {fuel : Nat} → {s : E.State} →
      PublicTreeWithin E g fuel s → E.World → Nat → Prop
  | leaf {fuel s} (target : CertifiedTarget E s g)
      (w : E.World) (compatible : Compatible E s w) :
      PublicExecutionCost E g
        (PublicTreeWithin.leaf (fuel := fuel) target) w 0
  | query {fuel s} (q : E.Query) (playable : Playable E s g q)
      (children : ∀ r, Realizable E s q r →
        PublicTreeWithin E g fuel (E.advance s g q r))
      (w : E.World) (compatible : Compatible E s w) (childCost : Nat)
      (childExecution :
        PublicExecutionCost E g
          (children (E.respond w q) ⟨w, compatible, rfl⟩) w childCost) :
      PublicExecutionCost E g (PublicTreeWithin.query q playable children) w
        (E.queryCost s g q + childCost)

theorem publicExecutionCost_compatible
    {E : PublicGame} {g : E.Goal} {fuel : Nat} {s : E.State}
    {tree : PublicTreeWithin E g fuel s} {w : E.World} {cost : Nat}
    (execution : PublicExecutionCost E g tree w cost) :
    Compatible E s w := by
  cases execution with
  | leaf target w compatible => exact compatible
  | query q playable children w compatible childCost childExecution =>
      exact compatible

theorem publicExecutionCost_exists
    (E : PublicGame) (g : E.Goal) :
    ∀ {fuel s} (tree : PublicTreeWithin E g fuel s)
      (w : E.World), Compatible E s w →
      ∃ cost, PublicExecutionCost E g tree w cost := by
  intro fuel s tree
  induction tree with
  | leaf target =>
      intro w hw
      exact ⟨0, PublicExecutionCost.leaf target w hw⟩
  | @query fuel s q playable children ih =>
      intro w hw
      let r := E.respond w q
      let hr : Realizable E s q r := ⟨w, hw, rfl⟩
      have hwAfter : Compatible E (E.advance s g q r) w :=
        E.posteriorContains s g q r w playable.1 hw rfl
      rcases ih r hr w hwAfter with ⟨childCost, childExecution⟩
      exact ⟨E.queryCost s g q + childCost,
        PublicExecutionCost.query q playable children w hw childCost
          childExecution⟩

theorem publicExecutionCost_le_depth_of_unitCost
    (E : PublicGame) (g : E.Goal)
    (hunit : ∀ s q, E.queryCost s g q ≤ 1)
    {fuel : Nat} {s : E.State} {tree : PublicTreeWithin E g fuel s}
    {w : E.World} {cost : Nat}
    (execution : PublicExecutionCost E g tree w cost) :
    cost ≤ fuel := by
  induction execution with
  | leaf target w compatible => exact Nat.zero_le _
  | @query fuel s q playable children w compatible childCost childExecution ih =>
      have hsum := Nat.add_le_add (hunit s q) ih
      rw [Nat.add_comm 1 fuel] at hsum
      exact hsum

/-- Exact worst-case cost, expressed without selecting hidden proof witnesses. -/
structure CertifiedWorstCaseCost
    (E : PublicGame) (g : E.Goal) {depth : Nat} {s : E.State}
    (tree : PublicTreeWithin E g depth s) (announced : Nat) : Prop where
  upper :
    ∀ w cost, PublicExecutionCost E g tree w cost → cost ≤ announced
  attained :
    ∃ w, PublicExecutionCost E g tree w announced

/--
`potential s` is a universal lower bound when every query admits a realizable
adversarial branch that preserves the bound after paying the query cost.
-/
structure CostLowerPotential
    (E : PublicGame) (g : E.Goal) (potential : E.State → Nat) : Prop where
  targetZero :
    ∀ s, CertifiedTarget E s g → potential s = 0
  queryLower :
    ∀ s q, Playable E s g q →
      ∃ r, Realizable E s q r ∧
        potential s ≤ E.queryCost s g q + potential (E.advance s g q r)

def costLowerPotentialB
    (E : PublicGame) (g : E.Goal) (potential : E.State → Nat) : Bool :=
  allList
    (fun s =>
      ((!targetB E s g) ||
        decideWith (inferInstance : Decidable (potential s = 0))) &&
      allList
        (fun q =>
          (!playableB E s g q) ||
            anyList
              (fun r =>
                realizableB E s q r &&
                  decideWith
                    (inferInstance : Decidable
                      (potential s ≤ E.queryCost s g q +
                        potential (E.advance s g q r))))
              E.responses.elements)
        E.queries.elements)
    E.states.elements

theorem costLowerPotentialB_sound
    (E : PublicGame) (g : E.Goal) (potential : E.State → Nat)
    (hcheck : costLowerPotentialB E g potential = true) :
    CostLowerPotential E g potential := by
  constructor
  · intro s htarget
    have hstate := (allList_eq_true_iff
      (fun s =>
        ((!targetB E s g) ||
          decideWith (inferInstance : Decidable (potential s = 0))) &&
        allList
          (fun q =>
            (!playableB E s g q) ||
              anyList
                (fun r =>
                  realizableB E s q r &&
                    decideWith
                      (inferInstance : Decidable
                        (potential s ≤ E.queryCost s g q +
                          potential (E.advance s g q r))))
                E.responses.elements)
          E.queries.elements)
      E.states.elements).mp hcheck s (E.states.complete s)
    have htargetB : targetB E s g = true :=
      (targetB_eq_true_iff E s g).mpr htarget
    have hzeroB := (boolAnd_eq_true_iff _ _).mp hstate |>.1
    have hzero := (boolNotOr_eq_true_iff
      (targetB E s g)
      (decideWith (inferInstance : Decidable (potential s = 0)))).mp
      hzeroB htargetB
    exact (decideWith_eq_true_iff
      (inferInstance : Decidable (potential s = 0))).mp hzero
  · intro s q hplay
    have hstate := (allList_eq_true_iff
      (fun s =>
        ((!targetB E s g) ||
          decideWith (inferInstance : Decidable (potential s = 0))) &&
        allList
          (fun q =>
            (!playableB E s g q) ||
              anyList
                (fun r =>
                  realizableB E s q r &&
                    decideWith
                      (inferInstance : Decidable
                        (potential s ≤ E.queryCost s g q +
                          potential (E.advance s g q r))))
                E.responses.elements)
          E.queries.elements)
      E.states.elements).mp hcheck s (E.states.complete s)
    have hallQueries := (boolAnd_eq_true_iff _ _).mp hstate |>.2
    have hquery := (allList_eq_true_iff
      (fun q =>
        (!playableB E s g q) ||
          anyList
            (fun r =>
              realizableB E s q r &&
                decideWith
                  (inferInstance : Decidable
                    (potential s ≤ E.queryCost s g q +
                      potential (E.advance s g q r))))
            E.responses.elements)
      E.queries.elements).mp hallQueries q (E.queries.complete q)
    have hplayB : playableB E s g q = true :=
      (playableB_eq_true_iff E s g q).mpr hplay
    have hany := (boolNotOr_eq_true_iff
      (playableB E s g q)
      (anyList
        (fun r =>
          realizableB E s q r &&
            decideWith
              (inferInstance : Decidable
                (potential s ≤ E.queryCost s g q +
                  potential (E.advance s g q r))))
        E.responses.elements)).mp hquery hplayB
    rcases (anyList_eq_true_iff
      (fun r =>
        realizableB E s q r &&
          decideWith
            (inferInstance : Decidable
              (potential s ≤ E.queryCost s g q +
                potential (E.advance s g q r))))
      E.responses.elements).mp hany with ⟨r, _, hr⟩
    have hparts := (boolAnd_eq_true_iff _ _).mp hr
    exact ⟨r,
      (realizableB_eq_true_iff E s q r).mp hparts.1,
      (decideWith_eq_true_iff
        (inferInstance : Decidable
          (potential s ≤ E.queryCost s g q +
            potential (E.advance s g q r)))).mp hparts.2⟩

theorem costLowerPotentialB_complete
    (E : PublicGame) (g : E.Goal) (potential : E.State → Nat)
    (hpotential : CostLowerPotential E g potential) :
    costLowerPotentialB E g potential = true := by
  apply (allList_eq_true_iff _ E.states.elements).mpr
  intro s _
  apply (boolAnd_eq_true_iff _ _).mpr
  constructor
  · cases htarget : targetB E s g with
    | false => rfl
    | true =>
        apply (boolNotOr_eq_true_iff _ _).mpr
        intro _
        exact (decideWith_eq_true_iff
          (inferInstance : Decidable (potential s = 0))).mpr
            (hpotential.targetZero s ((targetB_eq_true_iff E s g).mp htarget))
  · apply (allList_eq_true_iff _ E.queries.elements).mpr
    intro q _
    cases hplay : playableB E s g q with
    | false => rfl
    | true =>
        apply (boolNotOr_eq_true_iff _ _).mpr
        intro _
        rcases hpotential.queryLower s q
          ((playableB_eq_true_iff E s g q).mp hplay) with ⟨r, hr, hlower⟩
        apply (anyList_eq_true_iff _ E.responses.elements).mpr
        refine ⟨r, E.responses.complete r, ?_⟩
        apply (boolAnd_eq_true_iff _ _).mpr
        exact ⟨
          (realizableB_eq_true_iff E s q r).mpr hr,
          (decideWith_eq_true_iff
            (inferInstance : Decidable
              (potential s ≤ E.queryCost s g q +
                potential (E.advance s g q r)))).mpr hlower⟩

theorem potential_execution_witness
    (E : PublicGame) (X : ExactPosteriorCompiler E)
    (g : E.Goal) (potential : E.State → Nat)
    (hpotential : CostLowerPotential E g potential) :
    ∀ {depth s} (tree : PublicTreeWithin E g depth s),
      ∃ w, ∃ cost,
        PublicExecutionCost E g tree w cost ∧ potential s ≤ cost := by
  intro depth s tree
  induction tree with
  | leaf htarget =>
      rcases htarget.2.1 with ⟨w, hw⟩
      refine ⟨w, 0, PublicExecutionCost.leaf htarget w hw, ?_⟩
      exact Nat.le_of_eq (hpotential.targetZero _ htarget)
  | @query depth s q hplay children ih =>
      rcases hpotential.queryLower s q hplay with ⟨r, hr, hlower⟩
      rcases ih r hr with ⟨w, childCost, childExecution, hchild⟩
      have hwAfter := publicExecutionCost_compatible childExecution
      have hposterior :=
        (exactPosterior_iff E X s g q r hplay.1 hr w).mp hwAfter
      rcases hposterior with ⟨hwBefore, hresponse⟩
      cases hresponse
      refine ⟨w, E.queryCost s g q + childCost,
        PublicExecutionCost.query q hplay children w hwBefore childCost
          childExecution, ?_⟩
      exact Nat.le_trans hlower
        (Nat.add_le_add_left hchild (E.queryCost s g q))

structure OptimalCostCertificate
    (E : PublicGame) (X : ExactPosteriorCompiler E)
    (g : E.Goal) (root : E.State) where
  depth : Nat
  tree : PublicTreeWithin E g depth root
  announcedCost : Nat
  exactWorstCase : CertifiedWorstCaseCost E g tree announcedCost
  potential : E.State → Nat
  potentialChecked : costLowerPotentialB E g potential = true
  attainedPotential : announcedCost = potential root

def emittedCost
    {E : PublicGame} {X : ExactPosteriorCompiler E}
    {g : E.Goal} {root : E.State}
    (certificate : OptimalCostCertificate E X g root) : Nat :=
  certificate.announcedCost

theorem optimal_sound
    {E : PublicGame} {X : ExactPosteriorCompiler E}
    {g : E.Goal} {root : E.State}
    (certificate : OptimalCostCertificate E X g root) :
    CertifiedWorstCaseCost E g certificate.tree (emittedCost certificate) :=
  certificate.exactWorstCase

theorem optimal_lower_bound
    {E : PublicGame} {X : ExactPosteriorCompiler E}
    {g : E.Goal} {root : E.State}
    (certificate : OptimalCostCertificate E X g root) :
    ∀ {otherDepth} (other : PublicTreeWithin E g otherDepth root)
      {otherCost : Nat}, CertifiedWorstCaseCost E g other otherCost →
      emittedCost certificate ≤ otherCost := by
  intro otherDepth other otherCost hother
  rcases potential_execution_witness E X g certificate.potential
    (costLowerPotentialB_sound E g certificate.potential
      certificate.potentialChecked) other with
      ⟨w, executionCost, execution, hlower⟩
  change certificate.announcedCost ≤ otherCost
  rw [certificate.attainedPotential]
  exact Nat.le_trans hlower (hother.upper w executionCost execution)

theorem optimal_attained
    {E : PublicGame} {X : ExactPosteriorCompiler E}
    {g : E.Goal} {root : E.State}
    (certificate : OptimalCostCertificate E X g root) :
    ∃ w, PublicExecutionCost E g certificate.tree w (emittedCost certificate) :=
  certificate.exactWorstCase.attained

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.publicExecutionCost_exists
#print axioms Repairability.PublicGame.publicExecutionCost_le_depth_of_unitCost
#print axioms Repairability.PublicGame.costLowerPotentialB_sound
#print axioms Repairability.PublicGame.costLowerPotentialB_complete
#print axioms Repairability.PublicGame.potential_execution_witness
#print axioms Repairability.PublicGame.optimal_sound
#print axioms Repairability.PublicGame.optimal_lower_bound
#print axioms Repairability.PublicGame.optimal_attained
/- AXIOM_AUDIT_END -/
