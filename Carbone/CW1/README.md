# CW1-alpha — Maintenance et mémoire matérielle structurelles

## Statut

`CW1-alpha` ajoute au monde constructif `CW0` un premier témoin de maintenance
et de mémoire portée par l'organisation carbonée. Son implémentation est dans
[`Lean/MaintenanceMemory.lean`](./Lean/MaintenanceMemory.lean). La frontière
vers une maintenance active est formalisée séparément dans
[`Lean/ActiveMaintenanceBoundary.lean`](./Lean/ActiveMaintenanceBoundary.lean).

La revendication démontrée est strictement formelle :

```text
une organisation admissible encode un bit dans sa topologie de liaisons ;
ce bit est lisible depuis l'organisation seule ;
le pas intrinsèque du monde met ce bit à jour ;
le pas du Core effectue exactement la même mise à jour ;
deux pas restaurent l'organisation matérielle ;
l'inventaire atomique et l'environnement sont maintenus.
```

Le lecteur `readTwoPhaseTopology` ne reçoit ni l'histoire, ni le nom de la
phase, ni le témoin d'admissibilité. Il inspecte la première liaison de la
configuration. Les preuves `read_encode` et `organization_encoded` établissent
respectivement que chaque code est relu correctement et que toute organisation
admissible du monde appartient au code matériel déclaré.

## Résultats constructifs

```text
CarbonMaintenance.totalInventory_preserved
CarbonMaterialMemory.read_two_steps
readTwoPhaseTopology_organization
twoPhaseMaintenance
twoPhaseMaterialMemory
twoPhaseMemory_sameProjection
twoPhaseMemory_reads_separated
twoPhaseCore_read_updates
twoPhaseCore_two_steps_organization
twoPhaseCore_read_two_steps
twoPhase_requestedResourcesAt_zero
twoPhase_requestedEnergyAt_zero
twoPhase_no_nonzeroMaintenanceDemand
twoPhase_not_resourceCoupledMaintenance
```

La même projection visible correspond ainsi à deux valeurs de mémoire
topologique constructivement séparées. L'opération d'actualisation est portée
par la structure positive de mémoire et sa loi involutive est interne, pas
ajoutée comme hypothèse terminale.

## Portée exacte

Ce témoin établit une **mémoire matérielle structurelle dans le modèle**. Il ne
prouve pas encore :

- une mémoire moléculaire physiquement réalisée ;
- une maintenance active consommant des ressources ou dissipant de l'énergie ;
- une cinétique ou une stabilité thermodynamique ;
- une reproduction, une transmission à des descendants ou une hérédité ;
- une variation ou une sélection.

L'environnement du témoin reste constant et la bascule entre les deux
topologies est encore la réponse causale définie par `CW0`. La porte
`ResourceCoupledMaintenance` exige une demande intrinsèque non nulle à chaque
état admissible. Le témoin actuel est constructivement prouvé incapable de
l'habiter, puisque toutes ses demandes valent zéro.

La prochaine étape honnête est donc une nouvelle instance `CW1-beta`, avec une
ontologie positive de prise de ressources, dissipation et renouvellement. Une
simple demande non nulle ne suffira pas : le flux effectivement exécuté devra
être relié à la réponse et à la réparation avant d'introduire une unité
reproductrice `CW2`.
