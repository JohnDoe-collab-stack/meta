# CW1-gamma — Maintenance, débit et complétion de valence

## Statut

`CW1-alpha` ajoute au monde constructif `CW0` un premier témoin de maintenance
et de mémoire portée par l'organisation carbonée. Son implémentation est dans
[`Lean/MaintenanceMemory.lean`](./Lean/MaintenanceMemory.lean). La frontière
vers une maintenance active puis son instance énergétique sont formalisées dans
[`Lean/ActiveMaintenanceBoundary.lean`](./Lean/ActiveMaintenanceBoundary.lean).
La sémantique chimique minimale des deux squelettes se trouve dans
[`Lean/ValenceCompletion.lean`](./Lean/ValenceCompletion.lean).

`CW1-beta` représente maintenant un système ouvert à débit stationnaire : à
chaque pas, une unité abstraite d'énergie entre, une unité est demandée et
dissipée, tandis que le stock local disponible reste égal à un. L'entrée, la
dissipation et leur bilan sont portés par la réponse puis par la réparation ;
ils ne sont pas ajoutés après l'exécution.

`CW1-gamma` traite séparément une question plus élémentaire : les deux graphes
de `CW0` représentent-ils effectivement des organisations carbonées
comparables ? La réponse est désormais calculée, et non supposée. Dans le
fragment neutre H/C/N/O à ordres de liaison entiers :

```text
C-C-O : somme des ordres de liaison [1, 2, 1]
        hydrogènes implicites [3, 2, 1]
        connectivité complétée CH₃-CH₂-OH

C-O-C : somme des ordres de liaison [1, 1, 2]
        hydrogènes implicites [3, 3, 0]
        connectivité complétée CH₃-O-CH₃

dans les deux cas : inventaire complété C₂H₆O.
```

Ces connectivités sont celles de l'éthanol et de l'éther diméthylique. Le code
ne prend toutefois pas leurs noms comme entrées : il recalcule leurs profils à
partir des atomes, des extrémités de liaison et des ordres de liaison.

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
chainSkeleton_bondValenceProfile
chainSkeleton_implicitHydrogenProfile
bridgedSkeleton_bondValenceProfile
bridgedSkeleton_implicitHydrogenProfile
chainSkeleton_neutralValenceInventory
bridgedSkeleton_neutralValenceInventory
chainConnectedCertificate
bridgedConnectedCertificate
c2h6oConstitutionalIsomerWitness
CertifiedTwoPhaseEnergyFlowExport.fields_eq_lean
writeTwoPhaseEnergyKernel
```

La même projection visible correspond ainsi à deux valeurs de mémoire
topologique constructivement séparées. L'opération d'actualisation est portée
par la structure positive de mémoire et sa loi involutive est interne, pas
ajoutée comme hypothèse terminale.

## Ce qui est démontré exactement

`c2h6oConstitutionalIsomerWitness` contient positivement :

- deux `CarbonOrganization` dont les liaisons sont bien formées ;
- un certificat de complétion de valence pour chacune ;
- un chemin fait de liaisons stockées de la racine vers chaque atome explicite,
  donc la connexité de chaque graphe ;
- la même formule calculée C₂H₆O ;
- une preuve constructive que les deux graphes de liaison sont distincts.

Il s'agit donc d'un témoin formel d'isomérie constitutionnelle dans le fragment
chimique déclaré. Le calcul échoue explicitement (`none`) pour un atome P ou S,
une survalence, ou un hydrogène explicite mal lié. Cette politique évite
d'inventer une valence unique là où le modèle ne représente ni charge formelle
ni état d'oxydation.

## Portée exacte

Ce témoin établit une **mémoire matérielle structurelle et un débit énergétique
actif dans le modèle**, ainsi qu'une **complétion de formule chimiquement
interprétable**. Il ne prouve pas encore :

- une mémoire moléculaire physiquement réalisée ;
- une unité physique pour les jetons d'énergie ;
- un mécanisme chimique produisant l'entrée ou la dissipation ;
- une prise de matière, puisque la demande atomique reste nulle ;
- une cinétique ou une stabilité thermodynamique ;
- que la bascule formelle C-C-O ↔ C-O-C est une réaction possible ;
- les charges formelles, radicaux, liaisons aromatiques ou stéréochimie ;
- une reproduction, une transmission à des descendants ou une hérédité ;
- une variation ou une sélection.

Le stock de l'environnement reste constant parce que l'entrée et la
dissipation sont égales. La bascule entre les deux topologies reste la réponse
causale définie par `CW0`. L'export exécutable distinct se trouve dans
[`exports/energy-throughput-v1`](./exports/energy-throughput-v1/README.md) ;
l'export historique `CW0` reste inchangé octet pour octet.

Le prochain test utile n'est pas une simulation supplémentaire de la bascule
abstraite. Il consiste à élargir la complétion à un petit corpus moléculaire
gelé, puis à comparer automatiquement formule et connectivité calculées à des
références externes. Une dynamique ne deviendra chimique qu'après ajout d'une
transformation avec bilan de matière, mécanisme et domaine de conditions.
Le protocole de qualification statique puis de prédiction dynamique est fixé
dans [`CARBON_PREDICTION_0`](../CARBON_PREDICTION_0.md).
