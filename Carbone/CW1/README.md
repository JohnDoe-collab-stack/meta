# CW1-beta — Maintenance, mémoire et débit énergétique formels

## Statut

`CW1-alpha` ajoute au monde constructif `CW0` un premier témoin de maintenance
et de mémoire portée par l'organisation carbonée. Son implémentation est dans
[`Lean/MaintenanceMemory.lean`](./Lean/MaintenanceMemory.lean). La frontière
vers une maintenance active puis son instance énergétique sont formalisées dans
[`Lean/ActiveMaintenanceBoundary.lean`](./Lean/ActiveMaintenanceBoundary.lean).

`CW1-beta` représente maintenant un système ouvert à débit stationnaire : à
chaque pas, une unité abstraite d'énergie entre, une unité est demandée et
dissipée, tandis que le stock local disponible reste égal à un. L'entrée, la
dissipation et leur bilan sont portés par la réponse puis par la réparation ;
ils ne sont pas ajoutés après l'exécution.

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
twoPhase_requestedEnergyAt_one
twoPhase_energyInflow_one
twoPhase_energyDissipated_one
twoPhaseEnergyThroughputMaintenance
twoPhaseResourceCoupledMaintenance
twoPhase_step_energyBalance
twoPhase_energyDissipated_eq_requested
CertifiedTwoPhaseEnergyFlowExport.fields_eq_lean
writeTwoPhaseEnergyKernel
```

La même projection visible correspond ainsi à deux valeurs de mémoire
topologique constructivement séparées. L'opération d'actualisation est portée
par la structure positive de mémoire et sa loi involutive est interne, pas
ajoutée comme hypothèse terminale.

## Portée exacte

Ce témoin établit une **mémoire matérielle structurelle et un débit énergétique
actif dans le modèle**. Il ne prouve pas encore :

- une mémoire moléculaire physiquement réalisée ;
- une unité physique pour les jetons d'énergie ;
- un mécanisme chimique produisant l'entrée ou la dissipation ;
- une prise de matière, puisque la demande atomique reste nulle ;
- une cinétique ou une stabilité thermodynamique ;
- une reproduction, une transmission à des descendants ou une hérédité ;
- une variation ou une sélection.

Le stock de l'environnement reste constant parce que l'entrée et la
dissipation sont égales. La bascule entre les deux topologies reste la réponse
causale définie par `CW0`. L'export exécutable distinct se trouve dans
[`exports/energy-throughput-v1`](./exports/energy-throughput-v1/README.md) ;
l'export historique `CW0` reste inchangé octet pour octet.

La prochaine étape honnête est un flux matériel positif — prise et rejet
d'atomes ou composants avec bilan — avant d'introduire une unité reproductrice
`CW2`.
