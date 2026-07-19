# CP0 — prédiction carbonée tenue à l'écart

## Statut

Les portes `CP0-DATA-M0`, `CP0-DATA-I0` et l'import moléculaire
`CP0-ONTOLOGY-1` sont terminés au 19 juillet 2026.

```text
verdict M0               = GO-INPUT-AUDIT
verdict I0               = GO-DYNAMIC
candidat                 = ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41
réactions déclarées      = 47 015
rendements décodés        = 0
structures produit lues   = 0
test tenu à l'écart       = 2 317 lignes, 30 paires
import moléculaire        = 194 / 194, zéro collision
statut ontologie espèces  = QUALIFIED
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
- [`Lean/InputOntology`](./Lean/InputOntology.lean) implémente le premier noyau
  positif et constructif de cette extension ;
- [`Lean/CanonicalImport`](./Lean/CanonicalImport.lean) définit le vérificateur
  calculable et [`Lean/ImportedSpecies`](./Lean/ImportedSpecies.lean) porte les
  194 certificats ;
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

Poursuivre `CP0-ONTOLOGY-1` par l'import canonique des conditions et quantités,
sans ouvrir les cibles. La couche moléculaire O1–O6 est qualifiée. La suite est :

1. conditions et quantités vers Lean ;
2. état Core amine–acide–environnement ;
3. producteur de rendement construit sans le test ;
4. seulement ensuite, comparaison préenregistrée aux baselines.

Les rendements de `held_out_test` et les structures produit restent interdits.
