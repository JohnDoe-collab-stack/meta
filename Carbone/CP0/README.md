# CP0 — prédiction carbonée tenue à l'écart

## Statut

La porte de métadonnées `CP0-DATA-M0` est terminée au 19 juillet 2026.

```text
verdict                  = GO-INPUT-AUDIT
candidat                 = ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41
réactions déclarées      = 47 015
lignes réaction ouvertes = 0
produits ouverts          = 0
autorisation suivante     = audit des entrées uniquement
```

Ce résultat ne mesure aucune performance et ne démontre aucune prédiction. Il
établit seulement qu'un corpus public mérite un contrôle plus profond sans
encore ouvrir ses cibles.

## Documents

- [`CARBON_PREDICTION_0`](../CARBON_PREDICTION_0.md) fixe la question, les
  baselines, les séparations et les critères de réfutation ;
- [`DATASET_AUDIT`](./DATASET_AUDIT.md) consigne la méthode, les huit candidats,
  le verdict et les inconnues restantes ;
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

Construire `CP0-DATA-I0`, un auditeur du seul candidat AIChemEco qui :

1. charge les structures et rôles des **entrées** ainsi que les conditions ;
2. n'expose aucune structure produit ni valeur de réponse ;
3. calcule l'ontologie réellement nécessaire et les identités moléculaires ;
4. propose un découpage déterministe par amines et acides absents de la
   construction ;
5. chiffre les cibles hors du producteur et scelle l'archive par hash avant
   tout développement du producteur ;
6. rend alors seulement `GO-DYNAMIC`, `GO-STATIC-ONLY` ou `NO-GO`.

Jusqu'à cette seconde porte, entraîner un modèle, choisir une cible dynamique
ou revendiquer un résultat prédictif est interdit.
