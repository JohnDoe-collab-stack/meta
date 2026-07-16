# Meta/AI

Ce dossier contient les spécialisations Lean de la fermeture sémantique active
définie dans
[`Docs/ValidationIntegraleFermetureSemantiqueIA.md`](../../Docs/ValidationIntegraleFermetureSemantiqueIA.md).

## Frontière architecturale

Les modules de ce dossier peuvent importer `Meta/Core`, `Meta/Semantics` et les
spécialisations nécessaires. Aucun module générique de ces couches ne doit
importer `Meta/AI`.

La direction des dépendances est :

```text
Meta/Core + Meta/Semantics
          ↓
        Meta/AI
          ↓
Empirical/v23_gap_driven_active_semantic_closure
```

Les artefacts Python et les traces empiriques ne sont jamais des hypothèses des
théorèmes Lean. Ils peuvent seulement être réifiés comme données finies puis
vérifiés par calcul.

## Modules

```text
présents :
  ActiveSemanticClosure.lean
  FiniteActiveSemanticClosure.lean
  OpenActiveSemanticClosure.lean
  VisibleFactoredClosureNoGo.lean
  ActiveClosureFoundationalRealization.lean
  OpenClosureFoundationalRealization.lean
  ActiveClosureUseGraphNonReduction.lean
  ActiveClosureInterventions.lean
  CertifiedInference.lean
  LeanValidationCompleteness.lean
  AIFoundationalValidation.lean

campagne v23 à construire :
  EmpiricalTraceSchema.lean
  EmpiricalTraceVerifier.lean
```

`ActiveSemanticClosure.lean` définit le noyau causal, les gaps sémantiques
typés, la fermeture connue et `GapClosedBy`. `FiniteActiveSemanticClosure.lean`
construit une orbite fermée de trois réparations. Chaque étape possède un gap
sémantique réalisé, une réduction stricte de la fibre compatible, une preuve de
fermeture et une intervention par réponse croisée qui réfute la fermeture. Le
dernier état conserve les trois réparations et est stable. La fermeture est
également certifiée par la décroissance interne `3 > 2 > 1 > 0` du nombre de
gaps ouverts et par une borne calculée depuis le domaine canonique.

`ActiveClosureInterventions.lean` définit les interventions typées sur
l'observation, le gap, l'usage, le transport, la requête, la réponse et le
patch. Une intervention conserve l'amont et recalcule l'aval ; une requête non
admissible ou une réponse d'un autre type dépendant ne peut pas être injectée.
Le certificat fini isole les effets observation→détection, gap→usage,
usage→transport, transport→requête, requête→forme de réponse et
réponse→réparation→successeur. À réponse fixée, `RepairDerivedFrom` détermine
les trois sorties opérationnelles de la réparation et l'état exécuté ; un patch
alternatif incohérent est donc refusé au lieu d'être fabriqué pour le test.

`LeanValidationCompleteness.lean` rassemble les obligations Lean non-v23 :
non-trivialité sémantique et opérationnelle, deux usages sur un gap, deux
lectures transportées, deux requêtes admissibles et une requête refusée,
empreintes locales et bornées des réponses, réduction des fibres, fermeture
finie mesurée, orbite ouverte cumulative, interventions causales, no-go et
non-réductions.

Les empreintes de réponse sont des contrats informationnels de localité et de
borne, pas des nœuds causaux ajoutés entre la requête et la réponse.

La branche Lean non empirique est assemblée par
`AIFoundationalValidation.lean`. Elle contient une fermeture finie certifiée,
une orbite ouverte cumulative, deux réalisations fondationnelles intrinsèques,
un schéma causal commun, les no-go passif et visible factorisé sur des objets
de fermeture concrets, une non-réduction au seul graphe d'usage et le certificat
`AILeanNonV23Obligations`. Aucun résultat empirique v23 n'est revendiqué par ces
modules.

## Contraintes

Tout fichier Lean de ce dossier doit être constructif, sans axiome, sans
`Classical`, sans `propext`, sans `Quot.sound`, sans `sorry`, sans pont terminal
externe et avec un unique bloc `AXIOM_AUDIT` final.

Les types opérationnels ne peuvent pas être fermés par `Unit`, une projection
constante, une réparation neutre, un `next` fourni séparément ou une preuve de
fermeture sur une fibre compatible vide.

## Statut

Validation Lean non-v23 implémentée et auditée. Les blocs `AXIOM_AUDIT`
compilent sans axiome, `Classical`, `propext` ni `Quot.sound`. La campagne
empirique v23, ses schémas de traces et ses vérificateurs restent un livrable
ultérieur distinct.
