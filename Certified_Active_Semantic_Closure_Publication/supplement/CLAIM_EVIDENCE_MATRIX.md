# Claim–evidence matrix

This matrix is normative. If prose elsewhere appears broader, this table fixes
the intended claim boundary.

| ID | Publication claim | Evidence | Quantification | Excluded interpretation |
|---|---|---|---|---|
| C1 | Visible aliasing makes simultaneous correctness impossible | `continuationAliasing_informationNecessity` | All types, encoders, required-decision functions, rules, and positive aliasing witnesses | Does not say every representation is aliased |
| C2 | Compatible-world aliasing refutes local target determinacy | `latentAliasing_refutesFiberDeterminacy` | Every active-closure system and supplied aliasing witness | Does not synthesize witnesses classically |
| C3 | No candidate is known correct at an aliased index | `latentAliasing_informationNecessity` | Every system with unique agreement targets | Does not refute correctness in only one selected world |
| C4 | Certified gap closure restores local sufficiency | `closureRestoresLocalSufficiency` | Every `GapClosedBy` witness | Local to the exact repaired index |
| C5 | Residual aliasing at that index is impossible | `closureRefutesPostRepairAliasing` | Every certified closure | Does not identify the semantic worlds globally |
| C6 | The first finite step is complete | `finiteCertifiedLatentRepair0` | Exact `state0 → state1` step | Not all arbitrary finite states |
| C7 | The second finite step is complete | `finiteCertifiedLatentRepair1` | Exact `state1 → state2` step | Not all arbitrary finite states |
| C8 | The third finite step is complete | `finiteCertifiedLatentRepair2` | Exact `state2 → state3` step | Not all arbitrary finite states |
| C9 | Finite repairs preserve prior certified facts | `repair_preserves_closedPrefix`, `state3_retainsRepairs` | Canonical repaired prefixes/history | Not arbitrary user predicates |
| C10 | The finite orbit terminates and is stable | `finiteMeasureClosureCertificate`, `state3_is_stable` | Canonical three-index domain | Not arbitrary finite environments |
| C11 | Every open stage has a complete repair step | `openCertifiedLatentRepairAt` | All `stage : Nat` | Does not claim global finite closure |
| C12 | Every open step strictly shrinks its current compatible fiber | `openStrictFiberReductionAt` | All `stage : Nat` | Fibers at different indices need not be finite |
| C13 | Open repairs preserve every learned entry | `openRepair_preservesKnownPrefix` | All stages and all successful prior lookups | Not robustness to contradictory observations |
| C14 | No open finite stage is globally closed | `openOrbit_notGloballyClosed` | All `stage : Nat` | Not a claim of divergence or failure |
| C15 | Passive/visible-factored guarantees fail on aliased tasks | `aiClosureNoGoCertificate` | Stated policy/controller classes, including fixed seeds | Not all conceivable interactive agents |
| C16 | Strict identity is conservative and the syntax is consistent | `aiFoundationalValidation` fields | Published finite/open signatures | Not a general consistency proof for Lean |
| C17 | Transport semantics is not reduced to projection or use graph | foundational and non-reduction certificates in `aiFoundationalValidation` | Published regimes/witnesses | Not historical uniqueness |
| C18 | The quantized agent is exact on 697 obligations | `validCertifiedRun`, `exhaustiveCertifiedInputs_count` | Explicit finite catalogue | Not unseen-input accuracy |
| C19 | Every semantic head reference is covered exactly | `SemanticallyClosedCertifiedRun` | Counts 15/22/44/88/528 | Not continuous-region coverage |
| C20 | The whole published package is jointly inhabited | `certifiedLatentRepairPublication` | All fields of the aggregate structure | Not a single universal theorem for all POMDPs |
| C21 | The planned problem obligations hold jointly at their declared generic/exact scopes | `plannedProblemResolutionAudit` | Generic bridges plus every finite/open published stage | Does not prove minimality, perturbation robustness, unseen-input generalization, or arbitrary-environment detector completeness |
| C22 | The computed action-conflict measure is zero exactly on action-sufficient fibers | `actionConflictMeasure_eq_zero_iff` | Every declared `FiniteActionModel`, public state, and obligation | Does not identify the world when action classes already agree |
| C22a | Posterior inclusion cannot increase the computed action-conflict measure | `actionConflictMeasure_monotone` | Every declared finite action model and pair of included public fibers | Monotonicity alone does not imply strict progress |
| C23 | Eliminating a conflicting pair under posterior inclusion strictly decreases the computed measure | `actionConflictMeasure_strictly_decreases` | Every declared finite action model and supplied eliminated conflict | Does not require every individual repair step to decrease immediately |
| C24 | Adaptive public indistinguishability of an action-conflicting pair rules out certified repairability | `adaptivePublicNoGo` | Exactly the `PublicRepairTree` class used by the positive definition | Does not cover policies that receive the private world |
| C25 | Certified repairability is operationally equivalent to a global public tree with action-sufficient leaves | `certifiedRepairable_iff_uniformlyActionResolvable` | Environments equipped with total homogeneous-decision realization | The realization interface is an explicit adequacy hypothesis |
| C26 | Composable local pair separators synthesize a global certified repair strategy | `composableSeparability_implies_certifiedRepairable` | Finite models, invariant-preserving separators, nonempty initial fiber, and total decision realization | Initial-state pair separability alone is insufficient |
| C27 | Compiler-generated trees represent the exact posterior at every leaf | `exactGeneratedTree_leafPosterior` | Trees carrying `GeneratedByExactCompiler` for a supplied exact compiler | Does not assert exactness of arbitrary repair trees |
| C28 | The characterization hypotheses are independently necessary | four declarations in `Countermodels.lean` | Explicit finite countermodels for non-composability, candidate inexpressivity, private-world leakage, and frame regression | Countermodels isolate assumptions; they are not benchmark environments |
| C29 | The generic synthesis theorem is inhabited end to end | `synthesizedCertifiedRepairability`, `exactInstanceCertifiedRepairable` | Explicit two-world deterministic public environment | Demonstrates non-vacuity, not empirical scale |
| C30 | Established and adaptive results coexist in one axiom-free package | `certifiedAdaptiveClosurePublicationValidation` | Aggregate of the prior publication validation, the new generic characterization, and the positive instance | Aggregation does not enlarge any component quantifier |

## Evidence hierarchy

- **Generic theorem:** quantified over the interfaces shown in its Lean type.
- **Exact instance theorem:** quantified over all stages or objects of a named
  published realization.
- **Finite catalogue certificate:** exhaustive only for an explicit reified
  list.
- **Protocol:** a pre-specified empirical procedure, not a result.
- **Development checkpoint:** engineering evidence, not independent science.
