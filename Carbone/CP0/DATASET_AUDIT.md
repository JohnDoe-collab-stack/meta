# CP0-DATA-M0 — audit de métadonnées ORD

> Mise à jour : la porte suivante `CP0-DATA-I0` est terminée avec le verdict
> `GO-DYNAMIC`, cible rendement complète et extension ontologique requise. Voir
> [`INPUT_AUDIT`](./INPUT_AUDIT.md). Le présent document reste le rapport
> historique de sélection par métadonnées.

## 1. Décision

Audit exécuté le 19 juillet 2026 :

```text
GO-INPUT-AUDIT
ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41
AIChemEco amide coupling conditions 47k dataset
```

Ce verdict signifie : **examiner ensuite les entrées du corpus AIChemEco, sans
ouvrir les cibles**. Il ne signifie ni `GO-DYNAMIC`, ni succès du cadre, ni
prédiction chimique.

La porte finale `CP0-DATA` reste fermée tant que l'ontologie, les identités
moléculaires, la complétude des conditions, la présence scellable des réponses
et la possibilité du découpage tenu à l'écart n'ont pas été établies sur les
enregistrements.

## 2. Question de cette porte

La question est volontairement plus faible que la question scientifique CP0 :

> Les seules métadonnées publiques permettent-elles d'isoler un corpus dont le
> nombre d'identités et la factorisation déclarée justifient un audit aveugle
> des entrées ?

Cette porte peut éliminer un corpus manifestement inadéquat. Elle ne peut pas
confirmer une cible, une distribution de signal ou une transformation.

## 3. Source et provenance

L'exécution a lu uniquement
[`GET /api/datasets`](https://open-reaction-database.org/api/datasets), dont
l'interface publique renvoie une fiche `DatasetInfo` par jeu. La définition de
l'API est publiée dans le dépôt officiel
[`ord-interface`](https://github.com/open-reaction-database/ord-interface).

État observé au moment de l'exécution :

| Objet | Identifiant |
|---|---|
| réponse HTTP brute | SHA-256 `6953cdfbaaeba94f281f8bfad1c62fc32cc4fc553cd03dc12d63eecdfe84ed4c` |
| fiches reçues | 550 |
| `ord-interface`, branche consultée | `8cafe295517a45cc9317c5e5a686dfc4b352522d` |
| `ord-data`, tête `main` observée | `ddb0d25770c80a0a6fcf9948c26e1c8f828cb8ad` |
| `ord-schema`, tête `main` observée | `aeda34931f3a25497dccde0f68aa789b5830962b` |
| licence du dépôt `ord-data` à ce commit | CC BY-SA 4.0 |

Les trois commits sont des références distantes observées séparément. L'API
déployée ne fournit pas d'attestation reliant sa réponse à ces commits ; le
hash de la réponse brute est donc l'identité normative de cet audit.

La provenance déclarée du candidat AIChemEco est le DOI
[`10.1039/d5sc03364k`](https://doi.org/10.1039/d5sc03364k). Ni l'article ni ses
résultats n'ont été utilisés pour classer les candidats lors de l'exécution.

## 4. Isolation des cibles

L'inspecteur refuse tout objet dont les clés ne sont pas exactement :

```text
dataset_id, name, description, num_reactions, submitted_at
```

Il s'arrête également si un candidat disparaît ou si les fragments descriptifs
sur lesquels repose sa qualification changent. Le run consigne explicitement :

```text
reaction_rows_opened = 0
product_rows_opened  = 0
target_rows_opened   = 0
```

Les règles de qualification ont été codées puis le script a été copié sous un
nom contenant son hash avant l'exécution archivée. Des métadonnées avaient été
consultées pendant la conception de l'audit ; aucune valeur réactionnelle ne
l'a été. Ce travail est donc un audit de sélection traçable, pas une
préinscription indépendante des métadonnées.

## 5. Résultats comparatifs

| Rang | Jeu ORD | Taille déclarée | Décision de métadonnées | Motif limitant |
|---:|---|---:|---|---|
| 1 | `47eaacc…` AIChemEco amide | 47 015 | `ADVANCE_INPUT_AUDIT` | 70 amines, 66 acides, 632 paires et 95 conditions déclarées |
| 2 | `805ad8…` couplages C–N | 50 688 | réserve | seulement 2 amines et 4 halogénures d'aryle |
| 3 | `dc0249…` oléfination transfert | 136 | réserve | 26 paires mais très peu de lignes par paire |
| 4 | `c70326…` oléfination bayésienne | 120 | réserve | 5 paires seulement |
| 5 | `1ec280…` réarrangement en flux | 1 227 | rejet CP0 principal | un substrat déclaré ; pas de holdout moléculaire |
| 6 | `5c9a10…` Chan–Lam | 9 632 | réserve | 2 acides boroniques et ontologie S/B/Cu |
| 7 | `c5b005…` catalyse asymétrique | 1 430 | réserve | stéréochimie et deux espaces de catalyseurs |
| 8 | `7acd6a…` amidation anilines | 960 | réserve | coeur acide indométacine fixe |

Les décisions sont spécifiques au **premier** test CP0. Une mise en réserve ne
juge pas la qualité chimique générale du jeu.

## 6. Pourquoi AIChemEco avance

Les métadonnées déclarent :

```text
70 amines
66 acides
632 paires de produits
95 conditions de couplage
47 015 réactions
```

Il existe donc, en principe, assez d'identités de chaque partenaire pour
séparer des amines et des acides entiers entre construction et test. C'est le
point que ne satisfait pas le grand jeu de 50 688 couplages C–N : son volume
vient principalement des conditions et catalyseurs, pas de la diversité des
substrats déclarés.

Le produit cartésien descriptif `632 × 95` vaut 60 040, tandis que le nombre de
lignes déclaré vaut 47 015, soit 78,31 %. Ce rapport ne doit pas être appelé
« couverture » avant inspection : lignes manquantes, répétitions, filtrages ou
plan non factoriel peuvent l'expliquer. Il devient une question explicite de
`CP0-DATA-I0`.

## 7. Cible scientifique envisagée, mais non choisie

Pour une amidification, prédire seulement la connectivité du produit risque de
récompenser une règle-template évidente. La baseline `B4`, template chimique
standard, doit donc rester l'adversaire principal.

Le test potentiellement informatif serait plutôt une **réponse aux conditions
pour des amines et acides tenus hors construction** — classe de rendement,
intervalle ou classement — à condition que les enregistrements ORD contiennent
une mesure comparable et suffisamment complète. Les métadonnées présentes ne
le prouvent pas. La cible reste donc indéfinie et aucune valeur n'a été ouverte.

Un `GO-DYNAMIC` exigera qu'une règle issue du cadre et fixée avant test dépasse
`B4` et les baselines simples sur des identités absentes de construction. Une
simple restitution de l'amide attendu ne sera pas interprétée comme
surprenante.

## 8. Inconnues bloquantes

La phase de métadonnées ne répond à aucune des questions suivantes :

- combien d'amines, d'acides et de paires sont réellement encodés et
  canonicalisables ;
- quels éléments, charges, aromaticités, stéréochimies et types de liaisons
  apparaissent dans les **entrées** ;
- si les rôles, quantités, solvants, températures et durées sont complets ;
- si une cible comparable est présente pour chaque ligne admissible ;
- si les échecs, faibles réponses et répétitions sont conservés ;
- si des duplicats ou quasi-duplicats traverseraient le découpage ;
- si un découpage bilatéral par amines et acides laisse assez de données dans
  chaque compartiment ;
- si la provenance et les droits applicables aux données du candidat exigent
  des contraintes supplémentaires au-delà de la licence du dépôt.

Ces inconnues interdisent de construire le producteur maintenant.

## 9. Contrat de la prochaine porte `CP0-DATA-I0`

L'auditeur suivant devra être conçu avant son run archivé et ne produire que :

```text
inventaire et hash des molécules d'entrée canonicalisées ;
rôles et ontologie des entrées ;
inventaire des champs de conditions et taux de présence ;
booléens agrégés de présence des cibles, jamais leurs valeurs ;
groupes de duplicats définis sans cible ;
manifest déterministe construction / selection / held_out_test ;
archive de cibles chiffrée hors du producteur et hash SHA-256 de cette archive ;
effectifs par compartiment sans statistique des valeurs cibles.
```

Le découpage devra tenir hors construction des identités d'amines **et**
d'acides, pas seulement des paires ou des lignes. Le vérificateur de cible sera
séparé du producteur.

Critères de sortie :

```text
GO-DYNAMIC
  si une cible finie, présente et scellable existe, si le split moléculaire est
  non vide et si l'ontologie d'entrée est bornée ;

GO-STATIC-ONLY
  si les molécules peuvent être qualifiées mais qu'aucune cible dynamique
  honnête ou aucun split moléculaire robuste n'existe ;

NO-GO
  si les entrées elles-mêmes ne peuvent être normalisées sans imputation ou
  élargissement non borné du cadre.
```

## 10. Artefacts figés

Suffixe commun du run scientifique :

```text
20260719T065806Z_sha256-9121cdb235feb3b6fc368b017f51c41a487a8ecb90793fb2d1a8269a59582c7e
```

Artefacts :

- [script figé](./frozen_runs/ord_metadata_audit_20260719T065806Z_sha256-9121cdb235feb3b6fc368b017f51c41a487a8ecb90793fb2d1a8269a59582c7e.py) — SHA-256 `9121cdb235feb3b6fc368b017f51c41a487a8ecb90793fb2d1a8269a59582c7e` ;
- [rapport JSONL](./frozen_runs/ord_metadata_audit_20260719T065806Z_sha256-9121cdb235feb3b6fc368b017f51c41a487a8ecb90793fb2d1a8269a59582c7e.jsonl) — SHA-256 `9e97174d923326f7fbeb1f2573675e4e8784e8c79b02f9ab3e341a2cdfc497ae` ;
- [rapport texte et commande](./frozen_runs/ord_metadata_audit_20260719T065806Z_sha256-9121cdb235feb3b6fc368b017f51c41a487a8ecb90793fb2d1a8269a59582c7e.txt) — SHA-256 `24c3bc2db41760ab6880517994b23e66a0e7284da4edb824a5db85591b56963a` ;
- [réponse API brute](./frozen_runs/ord_metadata_source_20260719T065806Z_sha256-9121cdb235feb3b6fc368b017f51c41a487a8ecb90793fb2d1a8269a59582c7e.json) — SHA-256 `6953cdfbaaeba94f281f8bfad1c62fc32cc4fc553cd03dc12d63eecdfe84ed4c`.

Le fichier texte commence par la commande complète et le hash du script. Une
nouvelle exécution scientifique devra créer un nouveau script figé et de
nouveaux fichiers ; aucun de ces artefacts historiques ne doit être écrasé.

## 11. Conclusion réfutable

Le résultat démontré par `CP0-DATA-M0` est étroit : au moins un jeu public
déclare une diversité bilatérale de substrats et de conditions compatible avec
un futur test tenu hors molécules.

Il sera réfuté comme base de `CP0-D` si l'audit des entrées montre qu'il est
impossible de sceller une cible comparable, de séparer réellement les
identités moléculaires, ou de borner l'ontologie sans imputation. C'est la
prochaine expérience gratuite et décisive.
