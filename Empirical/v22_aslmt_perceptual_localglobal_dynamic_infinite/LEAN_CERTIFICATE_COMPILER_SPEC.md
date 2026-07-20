# Spec: compilateur de certificat v22 -> Lean

## But

Le compilateur de certificat transforme les artefacts experimentaux v22 en un
objet formel consommable par Lean.

Il ne doit pas prouver par apprentissage que le modele est correct. Il doit
extraire, verifier et traduire les obligations structurelles deja certifiees
par v22 vers les hypotheses abstraites utilisees dans Lean.

Objectif cible :

```text
certificat v22 verifie
-> observable raffine rho
-> rho separe les diagonales dynamiques requises
-> SeparatesAllDynamicDiagonals rho D
-> MythosPropFactorsThrough rho D
```

La cible Lean principale est :

```lean
true_refined_observable_global_factorization
```

dans :

```text
COFRS/Examples/MythosProblem.lean
```

Les cibles Lean secondaires sont :

```lean
LocalFiniteClosureCover
DynamicResidualProfile
no_residualAt_of_rhoAt_eq_zero
globalClosure_of_noStableResidualSection
```

dans :

```text
COFRS/MultiInterfaceModular/LocalGlobal.lean
COFRS/MultiInterfaceModular/DynamicResidualProfile.lean
```

## Principe scientifique

v22 observe une situation de type :

```text
visible pauvre phi
+ dynamique vraie D
+ distinction cachee effacee par phi
```

Les controles marginaux prouvent experimentalement :

```text
phi(s) = phi(t)
mais
D(s) != D(t)
```

Les controles minproof prouvent pour `z < n` :

```text
rho_z(s) = rho_z(t)
mais
D(s) != D(t)
```

Donc `rho_z` ne separe pas toutes les diagonales.

Le cas final `z = n` doit etre traduit comme candidat :

```text
rho_final separe toutes les diagonales dynamiques testees
```

Le compilateur ne doit accepter cette phrase que sous forme bornee et explicite :

```text
pour le domaine fini certifie du run v22
et pour le schema local-fini declare par le bridge
```

Il ne doit jamais transformer un succes empirique en theorem global non borne
sans hypothese supplementaire.

## Entrees

Le compilateur prend un dossier de run v22 :

```text
Empirical/aslmt/runs/aslmt_v22_perceptual_localglobal_dynamic_infinite_<tag>/
```

Entrees obligatoires :

```text
summary.json
cert_bridge_v22_<tag>_n<N>_z<N>_seed<S>.jsonl
verify_bridge_v22_<tag>_n<N>_z<N>_seed<S>.json
falsification_bridge_v22_<tag>_n<N>_z<N>_seed<S>.json
v22_perceptual_master_<tag>_n<N>_z<N>_seed<S>.jsonl
verify_iid_<tag>_n<N>_z<N>_seed<S>.json
verify_ood_<tag>_n<N>_z<N>_seed<S>.json
verify_marginal_iid_<tag>_n<N>_z<N>_seed<S>.json
verify_marginal_ood_<tag>_n<N>_z<N>_seed<S>.json
verify_minproof_iid_<tag>_n<N>_z<N>_seed<S>.json
verify_minproof_ood_<tag>_n<N>_z<N>_seed<S>.json
```

Pour chaque `z < N`, le compilateur exige aussi :

```text
verify_iid_<tag>_n<N>_z<z>_seed<S>.json
verify_ood_<tag>_n<N>_z<z>_seed<S>.json
verify_minproof_iid_<tag>_n<N>_z<z>_seed<S>.json
verify_minproof_ood_<tag>_n<N>_z<z>_seed<S>.json
cert_minproof_iid_<tag>_n<N>_z<z>_seed<S>.jsonl
cert_minproof_ood_<tag>_n<N>_z<z>_seed<S>.jsonl
```

Entrees recommandees pour audit reproductible :

```text
ckpt_<tag>_n<N>_z<z>_seed<S>.pt
train_<tag>_n<N>_z<z>_seed<S>.txt
cert_iid_<tag>_n<N>_z<z>_seed<S>.jsonl
cert_ood_<tag>_n<N>_z<z>_seed<S>.jsonl
violations_*_<tag>_n<N>_z<z>_seed<S>.jsonl
```

## Sorties

Le compilateur produit un dossier :

```text
Empirical/aslmt/runs/<run>/lean_certificate/
```

Sorties minimales :

```text
certificate.normalized.json
certificate.audit.json
certificate.lean
certificate_manifest.json
```

Sorties optionnelles :

```text
counterexamples_z_lt_n.jsonl
finite_windows.jsonl
traceability_map.json
```

### `certificate.normalized.json`

Format canonique independant des fichiers bruts v22.

Schema :

```json
{
  "kind": "v22_to_lean_certificate",
  "n_classes": 8,
  "seed": 0,
  "final_z_classes": 8,
  "splits": ["iid", "ood"],
  "observables": {
    "poor": ["image", "cue"],
    "refined": ["image", "cue", "z", "res_bit"]
  },
  "dynamic_predicate": "hidden_target_compatibility",
  "interface_policy": {
    "kind": "automatic_next_interface_selection",
    "status": "certified_supervised_binary_policy",
    "causal_chain": ["cue", "z", "query_action", "res_bit", "decoder"],
    "policy_source": "query_logits := query_from_z(one_hot(argmax(z_logits.detach())))",
    "policy_supervision": "_policy_action_from_h(h)",
    "environment_response": "res_bit := _env_res_bit(h, k, action)",
    "action_space": ["0", "1"],
    "formal_contract": [
      "the selected interface reveals the dynamic diagonal hidden by the poor observable",
      "the selected interface and response bit determine a certified continuation step"
    ],
    "not_free_interface_search": true,
    "q_acc_by_split": {"iid": 1.0, "ood": 1.0},
    "query_action_rate_by_split": {"iid": 0.5009765625, "ood": 0.50439453125}
  },
  "final_gate": {
    "struct_ok": true,
    "marginal_nogo_ok": true,
    "minproof_ok": true,
    "bridge_ok": true,
    "falsification_ok": true
  },
  "negative_controls": [
    {
      "z_classes": 7,
      "split": "iid",
      "struct_ok": false,
      "minproof_ok": true,
      "collision_witness_count": 4096
    }
  ],
  "local_finite_schema": {
    "ctx_domain": "Nat",
    "time_domain": "Nat",
    "global_state_enumeration": false,
    "finite_exhaustive_global_reduction": false,
    "levels": [4, 8, 16, 32]
  }
}
```

### `certificate.audit.json`

Rapport des controles effectues par le compilateur.

Champs obligatoires :

```json
{
  "ok": true,
  "errors": [],
  "warnings": [],
  "checked_files": [],
  "checked_hashes": {},
  "accepted_claims": [],
  "rejected_overclaims": []
}
```

### `certificate.lean`

Fichier Lean genere.

Il doit etre clairement marque comme fichier genere :

```lean
/- Generated from v22 certificate.
   Do not edit by hand. -/
```

Il doit importer uniquement les modules necessaires :

```lean
import COFRS.Examples.MythosProblem
import COFRS.MultiInterfaceModular.LocalGlobal
import COFRS.MultiInterfaceModular.DynamicResidualProfile
```

Il ne doit pas importer de code Python, de JSON ou de resultats empiriques au
runtime. Toutes les donnees necessaires doivent etre reifiees en types finis,
listes ou constantes verifiables.

## Mode de confiance

Le compilateur est dans le TCB si Lean accepte des constantes opaques generees.
Pour limiter le TCB, il doit avoir deux modes.

### Mode A: certificat comme hypotheses

Le compilateur genere des `axiom`/`constant` locaux representant le certificat.

Avantage :

```text
simple, rapide, utile pour prototyper le pont
```

Inconvenient :

```text
la veracite du certificat reste externe a Lean
```

Dans ce mode, le fichier doit nommer explicitement les hypotheses :

```lean
axiom v22_separates_all_dynamic_diagonals :
  SeparatesAllDynamicDiagonals v22Rho v22D
```

Le fichier doit aussi imprimer les axiomes :

```lean
#print axioms v22_global_factorization
```

### Mode B: certificat verifie dans Lean

Le compilateur genere des donnees finies et des preuves par calcul.

Avantage :

```text
le TCB est reduit au noyau Lean + generation correcte des donnees
```

Inconvenient :

```text
plus volumineux, plus lent, plus difficile
```

Dans ce mode, les collisions, separations et fenetres locales doivent etre
reifiees comme listes finies :

```lean
def v22States : List V22State := [...]
def v22Windows : List V22Window := [...]
def v22Rho : V22State -> V22R := ...
def v22D : V22State -> Prop := ...
```

Puis les preuves doivent etre calculees :

```lean
theorem v22_separates_all_dynamic_diagonals :
  SeparatesAllDynamicDiagonals v22Rho v22D := by
  decide
```

Le mode B est la cible finale.

## Objets Lean a generer

### Domaine fini du run

Le run v22 final a `n_classes = N`.

Le compilateur genere :

```lean
inductive V22Split where
  | iid
  | ood
deriving DecidableEq, Repr

structure V22Ctx where
  cx : Nat
  cy : Nat
  t : Nat
  occ_half : Nat
  img_size : Nat
  ood : Bool
  seed : Nat
deriving DecidableEq, Repr

structure V22State where
  split : V22Split
  ctx : V22Ctx
  h : Fin N
  k : Fin 2
deriving DecidableEq, Repr
```

Si le fichier Lean ne peut pas dependre directement de `N` comme parametre
compile-time, le compilateur genere un module specialise :

```lean
namespace V22_n8_seed0
```

### Observable pauvre

Le visible pauvre correspond au quotient qui oublie une distinction dynamique.

Forme abstraite :

```lean
def phiPoor : V22State -> V22PoorObs
```

Il doit encoder au minimum les deux barrières testees :

```text
image barrier: meme image, h varie, k fixe
cue barrier:   meme cue,   k varie, h fixe
```

Le compilateur doit produire deux familles de temoins :

```lean
def imageBarrierPairs : List (V22State × V22State)
def cueBarrierPairs : List (V22State × V22State)
```

Chaque paire doit satisfaire :

```lean
phiPoor s = phiPoor t
D s != D t
```

### Predicate dynamique

Le predicate dynamique doit etre propositionnel pour s'aligner sur
`MythosProblem.lean`.

Forme minimale :

```lean
def v22D : V22State -> Prop
```

Interpretation :

```text
v22D s = "le cote dynamique/cache compatible est celui de s"
```

Pour une paire diagonale `(s,t)`, le certificat doit fournir :

```lean
v22D s
¬ v22D t
```

Si la cible empirique est multi-valeur (`hidden_target`), le compilateur doit
choisir une comparaison propositionnelle locale :

```text
D_pair(s) := predicted target ranks target_s above target_t
```

ou bien construire un predicate indexe par paire :

```lean
def v22DForPair : V22Pair -> V22State -> Prop
```

La version globale est preferable seulement si elle est naturellement stable.

### Observable raffine

Le raffinement final correspond a `z = n`, avec les interfaces necessaires.

```lean
def v22Rho : V22State -> V22RefinedObs
```

Le compilateur doit aussi generer la projection vers l'ancien observable :

```lean
def forgetV22 : V22RefinedObs -> V22PoorObs

theorem forgetV22_commutes :
  forall s : V22State, forgetV22 (v22Rho s) = phiPoor s
```

Cela permet de construire :

```lean
def v22TrueRefinedObservable :
  TrueRefinedObservable phiPoor v22D
```

### Politique automatique de prochaine interface

v22 ne fournit pas seulement un raffinement statique. Le mediateur `z`
alimente une tete de query qui choisit automatiquement une action binaire :

```text
cue -> z -> query_action -> res_bit -> decoder
```

Dans le modele :

```text
query_logits := query_from_z(one_hot(argmax(z_logits.detach())))
action := argmax(query_logits)
res_bit := _env_res_bit(h, k, action)
```

Le compilateur doit formaliser cette couche sans la sur-vendre :

```text
ce n'est pas une decouverte libre d'interface,
c'est une politique binaire supervisee et certifiee.
```

Objet Lean genere en mode hypotheses. Les objets dependants du certificat ne
doivent pas etre definis par `noncomputable def`.

Le raffinement vrai doit etre construit directement dans la preuve du theoreme,
afin que ses champs restent definitionnellement :

```lean
refined := v22Rho
forget := forgetV22
```

et non caches derriere une constante opaque.

```lean
theorem v22_refined_factorization :
  MythosPropFactorsThrough v22Rho v22D := by
  let href : TrueRefinedObservable phiPoor v22D := {
    R := V22RefinedObs
    refined := v22Rho
    forget := forgetV22
    commutes := forgetV22_commutes
    separatesDiagonal := ...
  }
  exact true_refined_observable_global_factorization
    href
    v22_separates_all_dynamic_diagonals
```

Pour la politique d'interface :

```lean
structure InterfacePolicyCertificate where
  actionFromRefined : V22RefinedObs -> V22Action
  interfaceFromAction : V22Action -> V22Interface
  certifiedAction : V22State -> V22Action
  responseFromAction : V22State -> V22Action -> V22ResponseBit
  certifiedResponse : V22State -> V22ResponseBit
  revealsDynamicDistinction : V22Interface -> V22State -> V22State -> Prop
  continuationStep :
    V22State -> V22Interface -> V22ResponseBit -> V22State -> Prop
  certifiedNextState : V22State -> V22State
  action_selected :
    forall s,
      actionFromRefined (v22Rho s) = certifiedAction s
  selected_interface :
    forall s,
      interfaceFromAction (actionFromRefined (v22Rho s)) =
        interfaceFromAction (certifiedAction s)
  response_selected :
    forall s,
      responseFromAction s (actionFromRefined (v22Rho s)) =
        certifiedResponse s
  selected_interface_reveals_diagonal :
    forall {s t},
      phiPoor s = phiPoor t ->
        v22D s ->
          Not (v22D t) ->
            revealsDynamicDistinction
              (interfaceFromAction (actionFromRefined (v22Rho s)))
              s
              t
  selected_response_continues :
    forall s,
      continuationStep
        s
        (interfaceFromAction (actionFromRefined (v22Rho s)))
        (responseFromAction s (actionFromRefined (v22Rho s)))
        (certifiedNextState s)
```

Theoremes generes :

```lean
theorem v22_refined_selects_next_interface :
  forall s,
    certificate_interface_policy.interfaceFromAction
      (certificate_interface_policy.actionFromRefined (v22Rho s)) =
        certificate_interface_policy.interfaceFromAction
          (certificate_interface_policy.certifiedAction s)

theorem v22_refined_action_produces_certified_response :
  forall s,
    responseFromAction s (actionFromRefined (v22Rho s)) =
      certifiedResponse s

theorem v22_selected_interface_reveals_dynamic_diagonal :
  forall {s t},
    phiPoor s = phiPoor t ->
      v22D s ->
        Not (v22D t) ->
          revealsDynamicDistinction
            (interfaceFromAction (actionFromRefined (v22Rho s)))
            s
            t

theorem v22_selected_interface_response_continues :
  forall s,
    continuationStep
      s
      (interfaceFromAction (actionFromRefined (v22Rho s)))
      (responseFromAction s (actionFromRefined (v22Rho s)))
      (certifiedNextState s)
```

## Obligations a verifier

### O1: integrite des artefacts

Le compilateur doit verifier :

```text
summary.json existe
bridge json existe
falsification json existe
tous les verify json requis existent
les fichiers referencent le meme n, z, seed, tag
les SHA256 declares dans les certificats correspondent aux fichiers presents
```

Echec si :

```text
fichier manquant
tag incoherent
seed incoherent
n_classes incoherent
z_classes incoherent
hash incoherent
```

### O2: final gate `z = n`

Conditions obligatoires :

```text
final_z_classes = n_classes
verify_iid.struct_ok = true
verify_ood.struct_ok = true
verify_iid.violations = 0
verify_ood.violations = 0
verify_marginal_iid.ok = true
verify_marginal_ood.ok = true
verify_minproof_iid.ok = true
verify_minproof_ood.ok = true
```

Metrics obligatoires depuis le master JSONL :

```text
z_acc = 1.0
q_acc = 1.0
res_acc = 1.0
A_iou >= 0.80
B_img_iou = 0.0
B_cue_iou = 0.0
```

pour `iid` et `ood`.

### O3: controles negatifs `z < n`

Pour chaque `z < n`, `iid` et `ood` :

```text
verify_struct.ok = false
verify_minproof.ok = true
verify_marginal.ok = true
```

Le compilateur doit extraire au moins une collision minproof par contexte :

```text
h0 != h1
rho_z(h0) = rho_z(h1)
same_pred = true
forced_fail = true
```

Ces temoins deviennent :

```lean
def v22LowerDimCounterexamples :
  List LowerDimCounterexample
```

Usage scientifique :

```text
prouver que les dimensions inferieures ne sont pas seulement mal entrainees,
mais structurellement incapables de separer toutes les diagonales.
```

### O4: barrières marginales

Le compilateur doit verifier que les certificats marginaux etablissent :

```text
image barrier:
  meme image sous h variable, k fixe,
  hidden_target different

cue barrier:
  meme cue sous k variable, h fixe,
  hidden_target different
```

Traduction Lean :

```lean
def v22PoorDiagonalPairs : List (V22State × V22State)
```

avec :

```lean
theorem v22_poor_diagonal_pairs_sound :
  forall p in v22PoorDiagonalPairs,
    phiPoor p.1 = phiPoor p.2 ∧
    v22D p.1 ∧
    ¬ v22D p.2
```

### O5: selection automatique de la prochaine interface/action

Le compilateur doit verifier dans les resultats finaux :

```text
q_acc = 1.0
z_acc = 1.0
res_acc = 1.0
0.0 < query_action_rate < 1.0
```

pour `iid` et `ood`.

Ces conditions certifient :

```text
le cue determine z,
z determine l'action de query,
l'action produit le bon res_bit dynamique,
la politique n'est pas une branche constante,
l'interface choisie revele la diagonale dynamique restante,
et la reponse obtenue permet un pas de continuation certifie.
```

Traduction Lean en mode hypotheses :

```lean
axiom certificate_interface_policy :
  InterfacePolicyCertificate
```

Qualification scientifique obligatoire :

```text
la politique est supervisee par _policy_action_from_h(h).
Elle ne prouve pas une exploration libre de toutes les interfaces possibles.
```

### O6: usage causal de `z`

Le compilateur doit verifier :

```text
ablation_z rate
swap(z) suit la cible swappee
swap(z) ne conserve pas l'ancienne cible
```

Dans les resultats v22 finaux :

```text
A_ablated_both_image_pair_rate = 0.0
A_swap_follow_image_pair_rate = 1.0
A_swap_orig_both_image_pair_rate = 0.0
```

Ces conditions ne sont pas suffisantes pour Lean, mais elles sont une defense
scientifique contre une interpretation faible :

```text
z n'est pas seulement correle, il est utilise causalement par le decodeur.
```

### O7: bridge local-fini

Le bridge doit verifier :

```text
ctx_domain = Nat
time_domain = Nat
global_state_enumeration = false
finite_exhaustive_global_reduction = false
lean_target = PrimitiveHolonomy.MultiInterfaceModular.LocalFiniteClosureCover
cover_form = "forall ctx time, exists finite local window with zero residual coordinate"
```

Traduction Lean :

```lean
def v22LocalFiniteClosureCover :
  LocalFiniteClosureCover v22Obs v22Sigma v22Interfaces
```

ou, en mode hypotheses :

```lean
axiom v22_local_finite_closure_cover :
  LocalFiniteClosureCover v22Obs v22Sigma v22Interfaces
```

### O8: elimination dynamique

Le bridge doit verifier :

```text
dynamic_profile_target =
  PrimitiveHolonomy.MultiInterfaceModular.DynamicResidualProfile

coordinate_target =
  PrimitiveHolonomy.MultiInterfaceModular.no_residualAt_of_rhoAt_eq_zero

stable_section_target =
  PrimitiveHolonomy.MultiInterfaceModular.StableResidualSection
```

Et :

```text
stable_section_eliminated_by_local_zero_window = true
transport_preserves_parameterized_window_schema = true
```

Traduction Lean :

```lean
def v22DynamicResidualProfile :
  DynamicResidualProfile V22State V22Horizon V22Time V22Window

def v22DynamicResidualCoordinate :
  DynamicResidualCoordinate v22DynamicResidualProfile
```

Puis :

```lean
theorem v22_no_residual_at_zero_windows :
  ...
```

par application de :

```lean
no_residualAt_of_rhoAt_eq_zero
```

## Theoremes Lean generes

### T1: diagonale visible pauvre

```lean
theorem v22_poor_observable_has_diagonal :
  MythosPropDiagonalObstruction phiPoor v22D
```

### T2: non-factorisation du visible pauvre

```lean
theorem v22_poor_observable_no_factorization :
  ¬ MythosPropFactorsThrough phiPoor v22D :=
  mythos_prop_diagonal_obstruction_no_factorization
    phiPoor
    v22D
    v22_poor_observable_has_diagonal
```

### T3: raffinement vrai

```lean
def v22_true_refined_observable :
  TrueRefinedObservable phiPoor v22D
```

avec :

```lean
forget : V22RefinedObs -> V22PoorObs
commutes : forall s, forget (v22Rho s) = phiPoor s
separatesDiagonal : ...
```

### T4: separation globale des diagonales

Mode hypotheses :

```lean
axiom v22_separates_all_dynamic_diagonals :
  SeparatesAllDynamicDiagonals v22Rho v22D
```

Mode verifie :

```lean
theorem v22_separates_all_dynamic_diagonals :
  SeparatesAllDynamicDiagonals v22Rho v22D := by
  decide
```

### T5: factorisation par le raffinement

```lean
theorem v22_refined_factorization :
  MythosPropFactorsThrough v22Rho v22D :=
  true_refined_observable_global_factorization
    v22_true_refined_observable
    v22_separates_all_dynamic_diagonals
```

### T6: selection automatique de la prochaine interface

```lean
theorem v22_refined_selects_next_interface :
  forall s : V22State,
    certificate_interface_policy.interfaceFromAction
      (certificate_interface_policy.actionFromRefined (v22Rho s)) =
        certificate_interface_policy.interfaceFromAction
          (certificate_interface_policy.certifiedAction s)
```

et :

```lean
theorem v22_refined_action_produces_certified_response :
  forall s : V22State,
    responseFromAction s (actionFromRefined (v22Rho s)) =
      certifiedResponse s
```

Puis la version forte de poursuite :

```lean
theorem v22_selected_interface_reveals_dynamic_diagonal :
  forall {s t : V22State},
    phiPoor s = phiPoor t ->
      v22D s ->
        Not (v22D t) ->
          certificate_interface_policy.revealsDynamicDistinction
            (certificate_interface_policy.interfaceFromAction
              (certificate_interface_policy.actionFromRefined (v22Rho s)))
            s
            t

theorem v22_selected_interface_response_continues :
  forall s : V22State,
    certificate_interface_policy.continuationStep
      s
      (certificate_interface_policy.interfaceFromAction
        (certificate_interface_policy.actionFromRefined (v22Rho s)))
      (certificate_interface_policy.responseFromAction s
        (certificate_interface_policy.actionFromRefined (v22Rho s)))
      (certificate_interface_policy.certifiedNextState s)
```

### T7: closure locale-finie

```lean
theorem v22_closed_from_local_finite_cover :
  Closed v22Obs v22Sigma v22Interfaces :=
  closed_of_localFiniteClosureCover
    v22Obs
    v22Sigma
    v22Interfaces
    v22_local_finite_closure_cover
```

### T8: pas de section residuelle stable

```lean
theorem v22_global_closure_of_no_stable_residual :
  v22Bridge.GlobalClosure :=
  globalClosure_of_noStableResidualSection
    v22Bridge
    v22_no_stable_residual_section
```

## Mapping conceptuel v22 -> Lean

| v22 | Lean |
| --- | --- |
| image/cue visibles | `phiPoor` |
| target cache / compatibilite | `v22D` |
| collision minproof | `MythosPropDiagonalObstruction` |
| `z < n` | `¬ SeparatesAllDynamicDiagonals rho_z D` |
| `z = n` | candidat `rho` raffine |
| `query_logits := f(one_hot(argmax(z)))` | `InterfacePolicyCertificate.actionFromRefined` |
| action choisie | `selectedInterfaceFromRefined` |
| `_env_res_bit(h,k,action)` | `responseFromAction` / `certifiedResponse` |
| ablation/swap | evidence causale externe que `rho` est utilise |
| bridge finite windows | `LocalFiniteClosureCover` |
| zero residual coordinate | `no_residualAt_of_rhoAt_eq_zero` |
| dynamic schema | `DynamicResidualProfile` |
| no stable residual section | `globalClosure_of_noStableResidualSection` |

## Pseudocode du compilateur

```text
compile_v22_to_lean(run_dir, n, seed):
  load summary.json
  locate final tag with z=n

  check_integrity()
  check_final_gate(z=n)
  check_negative_controls(z<n)
  check_marginal_nogo()
  check_structural_zero_violations()
  check_bridge()
  check_falsification()

  normalized = normalize_certificate()

  if mode == hypotheses:
    emit_lean_with_axioms(normalized)
  else:
    finite_data = reify_finite_domains(normalized)
    emit_lean_with_decidable_proofs(finite_data)

  run lake build generated_module
  run axiom_audit
  write certificate.audit.json
```

## Rejets obligatoires

Le compilateur doit echouer si une des phrases suivantes apparait comme
revendication acceptee :

```text
formal theorem from empirical run
unbounded empirical infinity
global exhaustive enumeration
autonomous discovery
```

Il doit aussi echouer si :

```text
z_classes != n_classes pour le certificat final
un z<n passe structuralement
un minproof z<n ne fournit pas de collision
une baseline visible-only reussit
ablation_z reussit
swap(z) ne suit pas la cible swappee
bridge cache la portee locale-finie
bridge remplace ctx/time : Nat par un domaine fini
```

## Audit des axiomes

Chaque fichier Lean genere doit finir par :

```lean
#print axioms v22_poor_observable_no_factorization
#print axioms v22_refined_factorization
#print axioms v22_closed_from_local_finite_cover
#print axioms v22_global_closure_of_no_stable_residual
```

En mode hypotheses, les axiomes attendus doivent etre listes dans
`certificate.audit.json`.

En mode verifie, les theoremes ne doivent pas dependre de `sorryAx`.

## Phasage recommande

### Phase 1: normalisateur/auditeur

Produit :

```text
certificate.normalized.json
certificate.audit.json
```

Pas encore de Lean genere.

### Phase 2: Lean avec hypotheses explicites

Produit :

```text
certificate.lean
```

avec constantes/axiomes nommes.

But :

```text
valider l'interface exacte avec MythosProblem.lean
```

### Phase 3: Lean fini verifie

Remplace les axiomes de separation par des donnees finies et `decide`.

But :

```text
eliminer le TCB empirique pour le domaine fini certifie
```

### Phase 4: schema local-fini parametre

Connecte le certificat au schema :

```lean
LocalFiniteClosureCover
DynamicResidualProfile
```

But :

```text
formaliser le passage "chaque prefixe fini local est couvert"
sans le transformer en enumeration globale.
```

## Limites explicites

Le compilateur ne doit pas revendiquer :

```text
que le reseau generalise a tous les pixels possibles
que l'experience prouve une infinite empirique
que le checkpoint est correct hors du domaine certifie
que le bridge v22 est deja un theorem Lean complet
```

Il peut revendiquer :

```text
les artefacts v22 verifient un schema local-fini aligne Lean
les controles z<n produisent des diagonales/collisions
le cas z=n satisfait les obligations empiriques certifiees
les hypotheses Lean abstraites correspondent exactement aux obligations v22
```

## Critere de succes

Le compilateur est considere correct quand :

```text
1. il rejette les runs incomplets ou sur-revendiques ;
2. il extrait toutes les collisions z<n ;
3. il extrait les obligations z=n sans violations ;
4. il genere un fichier Lean qui compile ;
5. il produit v22_refined_factorization ;
6. il indique clairement quelles hypotheses restent externes ;
7. en mode verifie, il ne depend pas de sorryAx.
```

Le resultat final attendu est :

```text
v22 n'est plus seulement une experience alignee avec Lean.
v22 devient un producteur de certificats que Lean peut consommer.
```
