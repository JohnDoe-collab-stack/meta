# CW0 — Socle carboné constructif

## Statut

**`CW0-alpha` compilé sur la branche `carbone/cw0`.**

Cette tranche ne revendique ni chimie prédictive, ni fermeture
organisationnelle, ni évolution. Elle construit les données positives
nécessaires avant le raccord complet au Core :

```text
inventaire atomique avec présence positive de carbone ;
configuration et organisation carbonées finies avec toutes les liaisons
intrinsèquement certifiées entre deux indices atomiques distincts ;
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
Le premier témoin concret fermé est dans
[`Lean/ConcreteTwoPhase.lean`](./Lean/ConcreteTwoPhase.lean).
Son noyau observationnel fini est dans
[`Lean/FiniteKernel.lean`](./Lean/FiniteKernel.lean) et son protocole de
simulation dans [`SIMULATION_PROTOCOL.md`](./SIMULATION_PROTOCOL.md).
L'export JSON canonique est produit par
[`Lean/ExportTwoPhase.lean`](./Lean/ExportTwoPhase.lean).
L'interprète exact minimal est
[`python/simulate_two_phase.py`](./python/simulate_two_phase.py).
Le premier run figé et ses limites sont consignés dans
[`reports/CONFORMANCE.md`](./reports/CONFORMANCE.md).

Validation exécutée :

```text
lake build Carbone
```

La bibliothèque compile. Les audits finaux des déclarations principales
n'affichent aucun axiome.

## Limite actuelle

Le type `CarbonWorld` porte une famille de pas causaux sur ses seuls états
admissibles. Il ne fournit aucun successeur extérieur. L'adaptateur générique
et le témoin concret réalisent maintenant :

```text
CarbonWorld.Point
→ IntrinsicDynamicReturnFamily
→ GapRepairAlgebra.
```

Il prend comme entrée un `CarbonCoreAtlas` dont le pôle formé courant est la
source courante. `ConcreteTwoPhase` habite cet atlas : ses organisations et sa
branche bilatérale sont finies, tandis que la liste d'histoire reste
volontairement non bornée. La réparation alterne les deux squelettes, conserve
le stock de l'environnement et l'inventaire total, puis ajoute un
enregistrement interne. La couche `CW1-beta` enrichit la réponse et la
réparation d'un bilan ouvert explicite : une unité abstraite entre et une unité
est dissipée à chaque pas.

Ce témoin valide l'architecture et la calculabilité du pas. Il ne constitue
pas une cinétique chimique : aucune énergie d'activation, géométrie, loi de
vitesse ou donnée empirique n'y est encore encodée.

La paire de squelettes incluse dans le fichier Lean est un témoin structurel
fini de non-injectivité de la projection. Elle n'est pas une affirmation de
réactivité chimique ou d'évolution physique.

## Acquis de `CW0-alpha`

```text
carbonProjectionObstruction
CarbonWorld.step_eq_executeRepair
CarbonWorld.step_totalInventory
CarbonWorld.step_energyBalance
CarbonWorld.repairAt_energyDissipated_eq_requested
CarbonWorld.step_history.
CarbonCoreAtlas.toGapRepairAlgebra
CarbonCoreAtlas.coreNext_eq_worldStep.
twoPhaseCoreAtlas
twoPhaseCoreStep_organization
twoPhaseCoreStep_history
twoPhaseInitialCoreStep_preservesInventory
twoPhaseInitialCoreStep_changesOrganization.
twoPhaseKernel_commutes
twoPhaseKernel_two_steps.
CertifiedTwoPhaseStateExport.fields_eq_lean
writeTwoPhaseState_eq_certifiedWriter.
```

`step` ne figure pas dans les données de `CarbonWorld`. Il est défini depuis
`causalStepAt`, `repairOfCausalStep` et `executeRepair`. Le bilan conserve
l'inventaire combiné de l'organisation et de son environnement. L'égalité
`coreNext_eq_worldStep` porte sur le point dépendant complet, témoin
d'admissibilité compris. Les états JSON sont encodés depuis une charge utile
indexée par leur phase et certifiée égale à la configuration Lean ; les atomes,
liaisons et inventaires ne sont plus dupliqués sous forme de littéraux JSON.

La tranche suivante est documentée dans
[`../CW1/README.md`](../CW1/README.md). Elle ajoute une maintenance formelle,
une mémoire d'un bit effectivement lue dans la topologie des liaisons et une
complétion de valence qui identifie le cas statique C₂H₆O. Elle ne transforme
pas pour autant la bascule abstraite en réaction physico-chimique admissible.
