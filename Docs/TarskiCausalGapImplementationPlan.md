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

Le plan actif est :

```text
Docs/ConstructiveTarskiOrbitAndFoundationPlan.md
```

Il exige d'abord la theorie exacte de l'orbite du modele ferme, puis une
instance arithmetique utilisant les vrais types syntaxiques et la vraie
semantique de Foundation. Aucun patch semantique externe ne constitue une
solution de remplacement.
