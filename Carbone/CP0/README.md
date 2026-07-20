# CP0 — prédiction carbonée tenue à l'écart

## Statut

Les portes `CP0-DATA-M0`, `CP0-DATA-I0`, l'import moléculaire
`CP0-ONTOLOGY-1`, l'organisation d'entrée `CP0-ONTOLOGY-2`, le contrat
`CP0-PRODUCER-C0` et les portes empiriques `T1`–`T5` sont terminés au 19
juillet 2026.

```text
verdict M0               = GO-INPUT-AUDIT
verdict I0               = GO-DYNAMIC
candidat                 = ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41
réactions déclarées      = 47 015
rendements réels ouverts  = 18 759 lignes, construction + selection
structures produit lues   = 0
test tenu à l'écart       = 2 317 lignes, 30 paires
import moléculaire        = 194 / 194, zéro collision
import environnements     = 94 / 94, zéro collision de contenu
liens manifest I0         = 47 015 / 47 015
entrées uniques résolubles = 46 211
statut ontologie espèces  = QUALIFIED
statut organisation entrée = QUALIFIED
statut contrat producteur  = CONTRACT_QUALIFIED
statut lecteur cible T1    = SYNTHETIC_READER_QUALIFIED
statut gel cible T2        = SYNTHETIC_TARGET_READER_FROZEN
statut empirique C0-BIR     = NO-GO-C0-BIR-SELECTION
statut empirique C1 centre   = NO-GO-C1-RC-KNN-SELECTION
statut protocolaire C2       = NO-GO-PROTOCOL-C2-MS-REPAIR-SELECTION
MAE meilleure baseline     = 14,59081197
MAE C0-BIR                 = 18,50213433
MAE C1 centre seul          = 14,78209735
MAE C2 local–global         = 13,63890761, signal développement seulement
held_out_test ouvert        = non
```

Le premier résultat empirique est maintenant mesuré : la règle C0-BIR est
dominée de 3,91132236 points de MAE sur `selection`. C'est une réfutation de
cette candidate, pas une réfutation du cadre général.

La candidate C1 fondée uniquement sur les voisinages des centres réactifs
arrive à 0,19128538 point de B2. Le diagnostic C2 local–global obtient une MAE
ponctuelle meilleure de 0,95190435 point, mais échoue au seuil de deux points
et son intervalle bootstrap contient zéro. Le test final reste fermé.

## Documents

- [`CARBON_PREDICTION_0`](../CARBON_PREDICTION_0.md) fixe la question, les
  baselines, les séparations et les critères de réfutation ;
- [`DATASET_AUDIT`](./DATASET_AUDIT.md) consigne la méthode, les huit candidats,
  le verdict et les inconnues restantes ;
- [`INPUT_AUDIT`](./INPUT_AUDIT.md) établit la cible complète, l'ontologie et le
  split bilatéral sans décoder les rendements ;
- [`TARGET_PROTOCOL`](./TARGET_PROTOCOL.md) préenregistre l'unité statistique,
  les métriques, les baselines et le seuil de succès ;
- [`ONTOLOGY_GAP`](./ONTOLOGY_GAP.md) fixe l'extension minimale imposée à CW1 ;
- [`CANONICAL_IMPORT`](./CANONICAL_IMPORT.md) consigne l'import 194/194, ses
  invariants constructifs et ses limites ;
- [`ENVIRONMENT_IMPORT`](./ENVIRONMENT_IMPORT.md) consigne les quantités, les
  94 environnements et la résolution sans hash de l'entrée complète ;
- [`PRODUCER_CONTRACT`](./PRODUCER_CONTRACT.md) fixe l'interface intrinsèque du
  producteur, sa chaîne causale et le lecteur de cible gelé `T2` ;
- [`EMPIRICAL_RESULT_0`](./EMPIRICAL_RESULT_0.md) consigne le premier NO-GO
  numérique sur `selection`, les baselines et tous les artefacts figés ;
- [`EMPIRICAL_RESULT_1`](./EMPIRICAL_RESULT_1.md) teste les centres réactifs,
  mesure le signal multiscalaire et consigne son NO-GO protocolaire ;
- [`Lean/InputOntology`](./Lean/InputOntology.lean) implémente le premier noyau
  positif et constructif de cette extension ;
- [`Lean/CanonicalImport`](./Lean/CanonicalImport.lean) définit le vérificateur
  calculable et [`Lean/ImportedSpecies`](./Lean/ImportedSpecies.lean) porte les
  194 certificats ;
- [`Lean/EnvironmentImport`](./Lean/EnvironmentImport.lean) définit la
  qualification et la projection, et
  [`Lean/ImportedEnvironments`](./Lean/ImportedEnvironments.lean) porte les 94
  environnements certifiés ;
- [`Lean/ProducerContract`](./Lean/ProducerContract.lean) impose la projection
  sans clé, le rendement rationnel borné et la chaîne
  gap–interaction–réponse–réparation ;
- [`ord_metadata_audit.py`](./scripts/ord_metadata_audit.py) est l'inspecteur
  canonique de métadonnées ;
- [`frozen_runs`](./frozen_runs/) contient le script exécuté, la réponse source
  brute et les rapports portant un suffixe commun timestamp + SHA-256.

## Frontière d'aveuglement

L'inspecteur accepte exactement les champs publics suivants :

```text
dataset_id
name
description
num_reactions
submitted_at
```

Tout champ supplémentaire provoque un échec. Les structures moléculaires, les
conditions ligne par ligne, les produits et les valeurs expérimentales sont
donc absents de cette phase.

## Prochaine action autorisée

`T3`–`T5` ont réfuté C0-BIR. C1 et C2 ont ensuite utilisé `selection` comme
domaine de développement déjà ouvert. C2 donne un signal local–global, mais ne
franchit ni la marge de deux points ni l'intervalle de confiance. Le test final
reste scellé. La prochaine action utile est une fonction mécanistique
intrinsèque portant explicitement attaque, activation, stérique et réponse au
milieu, gelée avant toute utilisation du test final.
