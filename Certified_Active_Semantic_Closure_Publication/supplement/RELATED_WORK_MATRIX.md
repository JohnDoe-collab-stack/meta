# Structural related-work matrix

This comparison is by formal role, not by vocabulary. “Not primary” means the
cited work does not make the feature its stated formal object; it is not a claim
that no extension in the wider literature could express it.

| Tradition | State/representation criterion | Failure signal or ambiguity | Active information | Persistent update | Formal guarantee emphasized | Relation to this artifact |
|---|---|---|---|---|---|---|
| POMDP belief-state planning [Kaelbling et al., 1998] | Posterior sufficient statistic for control | Belief uncertainty | Information-gathering actions within planning | Bayesian belief update | Planning semantics under partial observability | Supplies the canonical partial-observation setting; this artifact types the repair causal chain and proves constructive finite/open certificates |
| Predictive-state representations [Littman et al., 2001] | Predictions of future tests | Different predictive profiles | Tests/observations are central | Predictive state update | State represented by observable predictions | Closest representational analogy to continuation profiles; this artifact focuses on detected failure and certified repair provenance |
| MDP equivalence/minimization [Givan et al., 2003] | Behavioral equivalence for aggregation | Partition violates equivalence | Not primary | Model refinement/aggregation | Correctness of state reduction | Provides the state-abstraction baseline; our no-go isolates an action-relevant contraction and the positive system acquires a separating answer |
| Bisimulation metrics [Ferns et al., 2004] | Quantitative behavioral similarity | Nonzero behavioral distance | Not primary | Aggregation guided by metric | Value-related bounds | Motivates quantitative future extensions; current artifact is exact and discrete |
| CEGAR [Clarke et al., 2000] | Abstraction adequate for verification | Spurious counterexample | Counterexample analysis | Abstraction refinement | Verification convergence on finite models | Shares failure-driven refinement; our repair is an online agent transition indexed by query/response provenance |
| Causal representation learning [Schölkopf et al., 2021] | High-level causal variables | Non-identifiability/change | Interventions are central to the research program | Learned representation | Transfer and causal semantics | Supplies the causal-representation objective; this artifact proves a typed symbolic repair mechanism, not latent recovery from pixels |
| Interventional causal representation learning [Ahuja et al., 2023] | Identifiability from intervention distributions | Latent indeterminacy | Perfect/imperfect interventions | Representation identification | Identification up to stated transformations | Establishes the information value of interventions; our exact query separates a compatible fiber in two constructed systems |
| Causal curiosity [Sontakke et al., 2021] | Learned causal factors | Unrevealed causal variation | Self-supervised experiments | Learned agent state | Empirical factor discovery and transfer | Empirical active-acquisition analogue; our contribution is kernel-checked local causality and closure |
| Continual learning/EWC [Kirkpatrick et al., 2017] | Retained task competence | Catastrophic forgetting | Not primary | Parameter update with consolidation | Empirical retention across tasks | Motivates non-regression; our finite/open prefix preservation is exact but narrower |
| This artifact | Task target determined on the compatible-world fiber | Typed mismatch or unresolved fiber | Query selected downstream of gap/use/transport | Candidate, observation, and history updated together | Axiom-free information necessity, closure-to-sufficiency, finite termination, open progress | Integrates the listed roles in two exact constructive realizations |

## Priority boundary

The matrix supports positioning, not a claim of firstness. Establishing absolute
historical novelty would require a broader systematic review of active state
construction, automata learning, epistemic planning, runtime assurance,
interactive theorem proving, and verified neural controllers. The publication
claim is therefore the machine-checked integration and its exact theorem scope,
not ownership of perceptual aliasing, abstraction refinement, active sensing,
or continual preservation as individual ideas.

Full citation data is in `REFERENCES.bib`.
