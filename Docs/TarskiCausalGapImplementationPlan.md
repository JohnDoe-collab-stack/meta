# Notice historique sur l'ancien plan causal de Tarski

## Statut

Ce document n'est plus un plan d'implementation actif.

L'ancienne API reparait directement un predicat semantique arbitraire de type
`Sentence -> Prop`. Elle a ete retiree de `Meta/Tarski/TruthGap.lean` parce
qu'elle ne garantissait pas que le candidat, le patch et l'iteration restent
des objets syntaxiques internes au systeme.

Le retrait concerne toute cette voie : patch semantique ponctuel, moteur
quantifie sur tous les predicats semantiques, et iteration de ces predicats.
Elle ne doit pas etre recreee sous un nom de compatibilite.

## Noyau conserve

Les constructions positives locales restent actives :

```text
TarskiDiagonalFixedPoint
TarskiPositiveDiagonal
LocalTruthMismatch
localTruthMismatchOfFixedPoint
ArithmeticTarskiContext
PatchableArithmeticTarskiContext
```

La causalite active passe exclusivement par un type syntaxique `Predicate` :

```text
candidat syntaxique
-> phrase diagonale
-> mismatch local
-> patch syntaxique interne
-> candidat syntaxique suivant
-> nouveau mismatch.
```

Elle est raccordee au systeme dynamique dans :

```text
Meta/Tarski/DynamicRelaxedUsage.lean
Meta/Tarski/ConstructivePatchModel.lean
```

## Suite normative

Les plans actifs sont desormais :

```text
Docs/IntrinsicArithmeticTarskiOrbitImplementationPlan.md
Docs/TarskiVisibleCausalNonRecurrenceImplementationPlan.md
```

Le premier remplace l'ancrage historique dans Foundation par un micro-noyau
arithmetique autonome. Le second internalise une memoire positive des vrais
`AlgorithmStep` syntaxiques et vise la recurrence visible avec non-retour
causal. Aucun des deux ne recree le patch semantique arbitraire retire par la
presente notice.
