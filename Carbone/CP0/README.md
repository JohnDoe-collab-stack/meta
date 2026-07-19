# CP0 — prédiction carbonée tenue à l'écart

## Statut

Les portes `CP0-DATA-M0`, `CP0-DATA-I0`, l'import moléculaire
`CP0-ONTOLOGY-1`, l'organisation d'entrée `CP0-ONTOLOGY-2`, le contrat
`CP0-PRODUCER-C0` et les portes synthétiques `T1`–`T2` sont terminés au 19
juillet 2026.

```text
verdict M0               = GO-INPUT-AUDIT
verdict I0               = GO-DYNAMIC
candidat                 = ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41
réactions déclarées      = 47 015
rendements décodés        = 0
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
rendements réels lus par T2 = 0
```

Ce résultat qualifie un test dynamique et sa cible. Il ne mesure encore aucune
performance et ne démontre aucune prédiction.

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

Le contrat positif, l'audit synthétique et son gel sont achevés. Avant `T3`, il
faut figer les wheels et hashes RDKit/scikit-learn ainsi qu'un harnais commun
aux méthodes du cadre et aux baselines. `T3` pourra alors ouvrir uniquement
`construction`, jamais `held_out_test`, pour construire la première loi de
rendement réellement testable.

Les rendements de `held_out_test` et les structures produit restent interdits.
Aucune prédiction empirique n'a encore été produite.
