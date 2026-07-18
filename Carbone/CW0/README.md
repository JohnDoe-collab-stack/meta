# CW0 — Socle carboné constructif

## Statut

**`CW0-alpha` compilé sur la branche `carbone/cw0`.**

Cette tranche ne revendique ni chimie prédictive, ni fermeture
organisationnelle, ni évolution. Elle construit les données positives
nécessaires avant le raccord complet au Core :

```text
inventaire atomique avec présence positive de carbone ;
configuration et organisation carbonées finies ;
environnement et histoire ;
projection vers un visible d'inventaire ;
obstruction projective concrète ;
gap, interaction, réponse et réparation indexés ;
bilan matériel système–environnement ;
successeur dérivé exclusivement de la réparation.
```

Le fichier principal est
[`Lean/CarbonWorld.lean`](./Lean/CarbonWorld.lean).
Le raccord générique au Core est dans
[`Lean/CoreAdapter.lean`](./Lean/CoreAdapter.lean).

Validation exécutée :

```text
lake build Carbone
```

La bibliothèque compile. L'audit final des quatre déclarations principales
n'affiche aucun axiome.

## Limite actuelle

Le type `CarbonWorld` porte une famille de pas causaux sur ses seuls états
admissibles. Il ne fournit aucun successeur extérieur. L'adaptateur générique
réalise maintenant :

```text
CarbonWorld.Point
→ IntrinsicDynamicReturnFamily
→ GapRepairAlgebra.
```

Il prend comme entrée un `CarbonCoreAtlas` dont le pôle formé courant est la
source courante. La prochaine tranche doit construire un premier atlas fini
concret ; l'adaptateur ne suppose aucun état futur.

La paire de squelettes incluse dans le fichier Lean est un témoin structurel
fini de non-injectivité de la projection. Elle n'est pas une affirmation de
réactivité chimique ou d'évolution physique.

## Acquis de `CW0-alpha`

```text
carbonProjectionObstruction
CarbonWorld.step_eq_executeRepair
CarbonWorld.step_totalInventory
CarbonWorld.step_history.
CarbonCoreAtlas.toGapRepairAlgebra
CarbonCoreAtlas.coreNext_source_eq_worldStep.
```

`step` ne figure pas dans les données de `CarbonWorld`. Il est défini depuis
`causalStepAt`, `repairOfCausalStep` et `executeRepair`. Le bilan conserve
l'inventaire combiné de l'organisation et de son environnement.
