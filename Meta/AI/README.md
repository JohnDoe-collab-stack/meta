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

à construire :
  OpenActiveSemanticClosure.lean
  VisibleFactoredClosureNoGo.lean
  ActiveClosureFoundationalRealization.lean
  CertifiedInference.lean
  EmpiricalTraceSchema.lean
  EmpiricalTraceVerifier.lean
  AIFoundationalValidation.lean
```

`ActiveSemanticClosure.lean` définit le noyau causal, les gaps sémantiques
typés, la fermeture connue et `GapClosedBy`. `FiniteActiveSemanticClosure.lean`
construit une orbite fermée de trois réparations. Chaque étape possède un gap
sémantique réalisé, une réduction stricte de la fibre compatible, une preuve de
fermeture et une intervention par réponse croisée qui réfute la fermeture. Le
dernier état conserve les trois réparations et est stable.

La réalisation fondationnelle, les no-go de politiques, les certificats de
traces et l'instance ouverte restent des obligations séparées. Aucun résultat
empirique n'est revendiqué par les deux premiers modules.

## Contraintes

Tout fichier Lean de ce dossier doit être constructif, sans axiome, sans
`Classical`, sans `propext`, sans `Quot.sound`, sans `sorry`, sans pont terminal
externe et avec un unique bloc `AXIOM_AUDIT` final.

Les types opérationnels ne peuvent pas être fermés par `Unit`, une projection
constante, une réparation neutre, un `next` fourni séparément ou une preuve de
fermeture sur une fibre compatible vide.

## Statut

Premier incrément Lean implémenté et audité : noyau causal et instance finie
non triviale. Les blocs `AXIOM_AUDIT` compilent sans axiome, `Classical`,
`propext` ni `Quot.sound`. La validation intégrale n'est pas encore terminée.
