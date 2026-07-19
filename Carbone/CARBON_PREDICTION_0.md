# CARBON_PREDICTION_0 — Plan d'un premier test prédictif tenu à l'écart

## 0. Statut et décision

**Plan de recherche — 19 juillet 2026. Aucun résultat prédictif n'est encore
acquis.**

`CARBON_PREDICTION_0`, abrégé `CP0`, organise le passage entre la complétion
statique de valence de `CW1-gamma` et un test dynamique sur des molécules qui
n'auront pas servi à construire le producteur.

Décision :

```text
GO      : construire gratuitement un contrôle statique tenu à l'écart ;
GO      : auditer les métadonnées de jeux réactionnels publics structurés ;
NO-GO   : choisir une famille réactionnelle avant cet audit ;
NO-GO   : ouvrir les produits du compartiment de test avant le gel ;
NO-GO   : appeler prédiction la bascule abstraite C-C-O ↔ C-O-C ;
NO-GO   : appeler percée une simple restitution de valence ou de formule.
```

Le résultat recherché est plus exigeant : une règle locale et générale,
construite sans identifiant de produit test, doit produire une transformation
ou une classe de réponse correcte sur des identités moléculaires absentes de
la construction et surpasser une baseline préenregistrée.

## 1. Question scientifique

La question primaire est :

> À partir des graphes des réactifs, de l'environnement déclaré et d'une
> famille réactionnelle bornée, le cadre peut-il calculer un ensemble restreint
> de réparations moléculaires contenant le produit observé pour des substrats
> tenus hors construction ?

Forme opérationnelle :

```text
input CP0
  = graphes moléculaires initiaux
  + rôles réactionnels déclarés
  + conditions disponibles
  + domaine de validité positif ;

prediction CP0
  = ensemble fini non vide de modifications de liaison
  + produits résultants calculés
  + classe de réponse ou intervalle de rendement, si identifiable ;

test CP0
  = comparaison à un produit public non ouvert avant le gel.
```

La prédiction n'est pas le choix postérieur du produit observé. Si plusieurs
produits restent compatibles avec l'information disponible, le producteur
retourne leur ensemble et paie explicitement sa largeur dans la métrique.

## 2. Ce qui existe et ce qui manque

### 2.1 Socle acquis

`CW1-gamma` fournit déjà, constructivement :

```text
atomes H/C/N/O dans un fragment neutre ;
ordres de liaison entiers ;
valence explicite par atome ;
complétion par hydrogènes implicites ;
inventaire moléculaire ;
connexité positive ;
séparation de deux connectivités de formule C₂H₆O.
```

Ce socle qualifie des graphes statiques. Il ne contient aucune loi permettant
de déduire une réaction physique.

### 2.2 Manques obligatoires avant une transformation

L'audit du jeu de données retenu devra déterminer lesquels des objets suivants
sont nécessaires :

```text
charge formelle entière ;
hydrogènes explicites et transferts de protons ;
isotopes, si présents dans le domaine ;
liaisons aromatiques ou représentation de Kekulé déclarée ;
stéréochimie, ou abstention explicite sur les cas stéréochimiques ;
composants et rôles : substrat, réactif, catalyseur, solvant, produit ;
suppression, ajout et changement d'ordre d'une liaison ;
conditions : température, durée, concentration, solvant, catalyseur ;
réponse nulle, produits concurrents et rendement mesuré ;
provenance et statut de complétude du bilan.
```

Il est interdit d'élargir l'ontologie « au cas où ». Chaque ajout doit être
justifié par les enregistrements admissibles du premier domaine CP0.

## 3. Deux étages qui ne doivent pas être confondus

### 3.1 `CP0-S` — qualification statique

`CP0-S` teste le langage moléculaire, l'import et la complétion de valence sur
un corpus PubChem gelé :

```text
entrée    : graphe explicite sans formule cible fournie au calcul Lean ;
sortie    : formule, hydrogènes implicites, connexité et statut d'admission ;
référence : formule et connectivité PubChem conservées par le vérificateur.
```

Deux strates sont nécessaires :

- cas positifs appartenant exactement au fragment supporté ;
- cas négatifs hors domaine — charges, aromaticité, élément ou stéréochimie
  non supportés — qui doivent provoquer une abstention et non une réponse
  inventée.

Le succès de `CP0-S` est une porte d'ingénierie. Il ne sera jamais présenté
comme une découverte chimique ou une prédiction surprenante.

### 3.2 `CP0-D` — test dynamique tenu à l'écart

`CP0-D` teste une famille de réactions mono-étape issue d'une source publique
structurée. Le produit exact, la modification de liaison ou la classe de
réponse constitue la cible tenue à l'écart.

Le domaine doit permettre au minimum :

```text
plusieurs identités de substrats variables ;
un rôle réactionnel comparable entre enregistrements ;
des conditions encodables ;
un produit structural identifié ;
une provenance par réaction ;
et un découpage par identité moléculaire, pas seulement par ligne.
```

Si le corpus ne contient que des réactions positives ou omet les conditions
décisives, CP0 peut tester le **produit conditionnel à la réaction**, mais pas
prédire honnêtement si la réaction aura lieu. Cette limite doit figurer dans
le nom de la cible et dans chaque résultat.

## 4. Sources publiques et porte de sélection

### 4.1 Source statique

PubChem fournit un accès programmatique aux structures, formules, identifiants
et services de standardisation. Pour chaque molécule retenue, CP0 conservera :

```text
CID ;
requête PUG REST exacte ;
date de récupération ;
réponse brute ;
structure 2D utilisée ;
formule de référence ;
InChI et InChIKey ;
hash SHA-256 de chaque artefact.
```

La standardisation PubChem est une opération externe documentée, pas un
théorème Lean. Le projet conservera côte à côte l'entrée brute, la forme
standardisée et la transformation déclarée.

### 4.2 Source dynamique prioritaire

L'Open Reaction Database (`ORD`) est prioritaire pour l'audit dynamique parce
qu'elle fournit un schéma public pour réactions mono-étape, conditions,
produits, mesures de rendement et provenance, ainsi qu'un dépôt de données
téléchargeable.

Les familles factorisées ou de chimie à haut débit sont préférables aux
réactions extraites de brevets : elles offrent des conditions systématiques,
des rendements faibles ou nuls et des comparaisons plus homogènes. Les données
de brevet sans conditions ou sans rendement ne peuvent servir qu'à une cible
structurale plus faible.

### 4.3 Un candidat prioritaire, aucun jeu encore qualifié

Les entrées publiques actuellement visibles suggèrent plusieurs types de
candidats — couplages à haut débit, réarrangements à produits concurrents,
oléfinations sur plusieurs paires de substrats. Elles ont toutefois des coûts
ontologiques différents : métaux et halogènes, aromaticité, soufre,
stéréochimie ou nombre insuffisant de substrats.

L'audit de métadonnées `CP0-DATA-M0` a depuis retenu le jeu AIChemEco d'amides
comme unique candidat à l'audit des entrées. Ce choix intermédiaire ne qualifie
ni ses structures, ni ses réponses, ni un découpage dynamique. Le choix final
reste une sortie de `CP0-DATA-I0`, pas une préférence narrative.

### 4.4 Porte `CP0-DATA`

Avant toute formalisation dynamique, un rapport doit produire pour chaque
candidat :

```text
dataset_id et version ORD ;
commit exact de ord-data ;
version exacte de ord-schema ;
licence et provenance ;
nombre de réactions et d'identités moléculaires ;
éléments, charges et types de liaisons rencontrés ;
présence des rôles et conditions nécessaires ;
complétude des structures produit ;
présence ou absence des types d'observation, sans distribution de leurs valeurs ;
duplicats et quasi-duplicats ;
possibilité d'un découpage par molécules ;
taille de téléchargement et coût de calcul estimé.
```

Verdict :

```text
GO    si une famille permet un test moléculaire groupé, une cible définie et
      une ontologie finie raisonnable ;

NO-GO si la cible exige d'imputer des produits, conditions ou espèces absents,
      ou si les molécules de test ne peuvent pas être séparées de celles de
      construction.
```

Après découpage, une seconde porte `CP0-SIGNAL` est évaluée uniquement sur
`construction` et `selection`. Elle exige une variation suffisante de la cible
pour distinguer les modèles. Si elle échoue, le candidat est abandonné sans
ouvrir son test. Aucun agrégat des valeurs test ne sert à choisir la famille.

## 5. Compartiments de données

Les mots `training`, `validation` et `test` décrivent ici l'accès autorisé,
qu'un modèle statistique soit utilisé ou non.

| Compartiment | Accès | Usage autorisé |
|---|---|---|
| `metadata_audit` | métadonnées et schéma, sans cibles ligne par ligne | décider si le corpus est admissible |
| `construction` | entrées et sorties ouvertes | construire les règles et estimer les paramètres |
| `selection` | entrées et sorties ouvertes | choisir entre versions et fixer les seuils |
| `held_out_test` | entrées ouvertes, sorties scellées jusqu'au gel | exécuter une seule évaluation primaire |
| `prospective` | réactions publiées après le gel | réplication la plus forte, sans réemploi du test |

### 5.1 Unité de découpage

Le découpage aléatoire par ligne est interdit. Des répétitions d'une même
réaction ou des conditions voisines rendraient alors le test artificiellement
facile.

L'unité primaire est un groupe d'identité moléculaire, défini avant ouverture
des sorties :

```text
group_id = identités standardisées des substrats variables
           + famille réactionnelle
           + règle de rôle versionnée.
```

Une identité variable présente dans `held_out_test` ne doit apparaître ni dans
`construction` ni dans `selection`. Si la famille met en jeu deux substrats
variables, le protocole précisera s'il exige :

- une paire nouvelle seulement ;
- au moins un substrat nouveau ;
- ou tous les substrats nouveaux.

Le troisième régime est le plus fort mais peut être impossible avec un petit
corpus. Le régime choisi et son effectif doivent être gelés avant le test.

### 5.2 Découpage déterministe

Le splitter utilise uniquement les identités d'entrée et une graine publiée :

```text
split_key = SHA-256(split_version || salt || group_id).
```

Les seuils de compartiment sont déclarés avant calcul. Les sorties produit et
rendement ne participent jamais au hash ni à l'affectation.

Les doublons exacts et quasi-duplicats sont groupés avant découpage. Toute
modification ultérieure du normaliseur, du sel ou des seuils crée une nouvelle
version du protocole et invalide le test non ouvert associé.

### 5.3 Limite d'un test public

Un jeu public tenu à l'écart par discipline est moins fort qu'un test réellement
aveugle. CP0 distinguera donc :

```text
retrospective_held_out : sorties publiques mais non consultées pendant la construction ;
prospective            : sorties absentes du corpus au moment du gel ;
independent_blind       : sorties conservées par un tiers.
```

Seuls les deux derniers statuts peuvent soutenir une revendication de surprise
forte. Le premier peut établir une généralisation rétrospective crédible.

## 6. Cible prédictive

### 6.1 Cible primaire

La cible préférée est l'ensemble exact des modifications du graphe principal :

```text
BondEdit
  = AddBond atomA atomB order
  | RemoveBond atomA atomB order
  | ChangeBondOrder atomA atomB before after ;

ProductPrediction
  reactantGraphs : graphes admis
  editSupport    : ensemble fini non vide de listes de BondEdit
  productSupport : résultats calculés par application des edits
  domainProof    : preuve positive du domaine
  modelVersion   : identifiant gelé.
```

L'identifiant ORD du produit, son SMILES cible ou son index dans le test ne
peuvent apparaître dans le producteur.

### 6.2 Cibles secondaires conditionnelles

Seulement si les données sont assez complètes :

```text
occurrenceClass : aucune / faible / active ;
yieldInterval   : intervalle préenregistré ;
selectivityClass: produit A / produit B / mélange ;
abstention      : hors domaine ou information insuffisante.
```

Les seuils de rendement sont fixés depuis `construction` et `selection`, jamais
depuis `held_out_test`.

### 6.3 Bilan matériel : deux niveaux séparés

De nombreuses bases réactionnelles n'énumèrent pas tous les sous-produits.
CP0 distinguera donc :

```text
MappedProductBalance
  chaque atome du produit principal provient d'un réactif déclaré ;
  les modifications locales sont cohérentes ;

CompleteReactionBalance
  toutes les espèces consommées et produites sont présentes ;
  atomes et charge sont conservés sur la réaction complète.
```

Une preuve de `MappedProductBalance` ne sera jamais décrite comme une
conservation complète de matière. Si les enregistrements ne permettent pas le
second niveau, le statut restera explicitement partiel.

## 7. Producteur issu du cadre

Le producteur doit être une instance finie de la chaîne :

```text
configuration + environnement
→ projection autorisée
→ incompatibilité ou besoin local
→ interaction admissible
→ classe de réponse
→ réparation moléculaire
→ application des BondEdit
→ produit calculé.
```

### 7.1 Règle d'endogénéité

Le producteur peut contenir :

- des prédicats locaux sur atomes, charges, voisinages et conditions ;
- des règles de réponse construites sur `construction` ;
- des paramètres estimés sans accès au test ;
- un ensemble de réparations lorsque l'information ne tranche pas.

Il ne peut pas contenir :

- une table `reactant_id → product_id` ;
- un hash ou identifiant appartenant au test ;
- un modèle préentraîné ayant déjà consommé les réactions du test sans que
  cette consommation soit déclarée ;
- une branche ajoutée après inspection d'un échec test ;
- un oracle externe consulté pendant l'évaluation.

### 7.2 Ce que signifie « non encodé à l'avance »

La famille réactionnelle et la forme générale d'une transformation peuvent
être connues chimiquement. La partie non encodée est l'application correcte à
une nouvelle identité moléculaire, le choix entre réparations concurrentes ou
la réponse aux conditions.

Si une unique règle de réécriture locale suffit toujours, sa réussite est
attendue. CP0 devra alors être présenté comme validation de généralité, pas
comme découverte. Une surprise commence seulement lorsque l'organisation
interne ou l'environnement apporte un gain prédictif que la règle locale la
plus simple ne possède pas.

## 8. Obligations Lean

La couche formelle ne sera écrite après la porte `CP0-DATA` que pour le domaine
réellement retenu. Elle devra établir constructivement :

```text
finitude des graphes, réponses et réparations ;
validité des indices d'atomes et extrémités de liaisons ;
absence de liaison d'un atome avec lui-même ;
cohérence des types et ordres de liaison ;
préconditions de chaque BondEdit ;
fermeture de l'application des edits ;
valence ou statut de rejet après réparation ;
MappedProductBalance, ou CompleteReactionBalance si disponible ;
origine de chaque réparation dans une réponse intrinsèque ;
égalité entre le pas du monde et l'exécution de la réparation ;
absence de toute lecture du produit tenu à l'écart.
```

Chaque fichier Lean suivra l'audit constructif du dépôt : aucun axiome,
`Classical`, `propext`, `Quot.sound` ou fermeture conditionnelle extérieure.

Lean ne prouvera pas que la règle prédit correctement la réalité. Il prouvera
que le producteur exécuté possède exactement la sémantique déclarée et respecte
ses invariants. La concordance avec les produits ORD restera un résultat
empirique séparé.

## 9. Export, exécution et traçabilité

L'autorité suit :

```text
définitions Lean
→ export canonique hashé
→ exécution exacte Python
→ prédictions gelées
→ ouverture des observations
→ vérification séparée.
```

Python ne redéfinira pas les transitions. Il chargera les règles ou le noyau
exporté, appliquera les mêmes opérations de graphe et démontrera sa conformité
sur le domaine fini avant toute prédiction.

Tout script expérimental suivra la règle du dépôt :

```text
aucun script historique modifié après résultat cité ;
nouvelle variante = nouveau fichier ;
run scientifique sur copie timestampée et hashée ;
sorties portant exactement le même suffixe ;
commande complète et hash enregistrés dans le rapport du run.
```

Artefacts minimaux du gel :

```text
source_manifest.json
eligibility_protocol.md
split_manifest.json
normalization_manifest.json
model_manifest.json
lean_export/MANIFEST.sha256
baseline_manifest.json
prediction_manifest.json
predictions.jsonl
verification_protocol.md
```

## 10. Baselines obligatoires

La nouveauté ne sera pas évaluée contre zéro. Les baselines minimales sont :

```text
B0 identity          : aucune transformation ;
B1 family_majority   : modification locale la plus fréquente de construction ;
B2 condition_blind   : même règle sans environnement ;
B3 nearest_training  : réponse du voisin de construction selon une distance gelée ;
B4 simple_template   : meilleur patron réactionnel local sans mémoire du Core.
```

Si la cible est probabiliste ou ordinale, une baseline de fréquence par famille
est ajoutée. Aucun grand modèle préentraîné n'est requis pour le premier test ;
si un tel modèle est utilisé plus tard, son corpus d'entraînement doit être
audité pour contamination du test.

La menace principale est `B4`. Si CP0 ne la dépasse pas, la formalisation peut
rester correcte, mais le Core n'aura montré aucun gain prédictif propre.

## 11. Métriques

### 11.1 Structure

```text
edit_exact_match       : liste exacte de modifications ;
product_connectivity   : connectivité standardisée exacte ;
support_coverage       : produit observé dans l'ensemble prédit ;
support_size           : nombre de produits proposés ;
invalid_prediction     : produit violant un invariant ;
abstention_rate        : proportion déclarée hors domaine.
```

Une couverture de 100 % obtenue en proposant tous les produits est un échec.
La couverture est toujours rapportée avec `support_size`.

### 11.2 Réponse quantitative, si admise

```text
yield_interval_coverage ;
yield_interval_width ;
balanced_accuracy pour classes ;
Brier score ou log loss pour probabilités rationnelles ;
calibration par classe de confiance.
```

Une seule métrique primaire et son seuil seront sélectionnés sur `selection`.
Les autres resteront secondaires. Les intervalles de confiance seront calculés
par groupe moléculaire, pas en traitant des répétitions corrélées comme des
molécules indépendantes.

## 12. Gel et ouverture unique

Avant l'accès aux sorties du test, le commit de gel doit contenir :

```text
question et revendication exactes ;
dataset, version, fichiers et hashes ;
critères d'admission et d'exclusion ;
normalisation et découpage ;
liste hashée des groupes de test ;
code Lean et audit ;
export canonique ;
code d'exécution conforme ;
baselines ;
métrique primaire ;
seuil numérique de GO/NO-GO ;
prédictions pour toutes les entrées test ;
règles de données manquantes et d'abstention.
```

L'ouverture du test est exécutée une fois. Une erreur observée est un résultat,
pas une demande de réparation immédiate. Toute correction produit `CP0-v2` ;
le test de `CP0-v1` devient alors une donnée de construction et ne peut plus
servir à annoncer une performance tenue à l'écart.

## 13. Critères de succès et de réfutation

### 13.1 Portes absolues

Un run est invalide si :

- une cible test a été lue avant gel ;
- un groupe moléculaire traverse les compartiments ;
- l'export Python diverge du noyau Lean ;
- une prédiction annoncée viole un invariant formel ;
- des exclusions sont décidées après lecture du résultat ;
- le statut partiel/complet du bilan est mal présenté.

### 13.2 `CP0-S` réussi

Le contrôle statique exige :

```text
100 % des cas admis : formule et connectivité conformes ;
100 % des cas hors domaine : abstention explicite ;
0 axiome interdit ;
0 divergence Lean/Python.
```

Ce GO autorise le test dynamique, sans constituer une revendication
scientifique nouvelle.

### 13.3 `CP0-D` réussi

Les seuils numériques seront fixés seulement après l'audit des effectifs et la
phase `selection`, mais avant ouverture du test. Le GO exigera simultanément :

```text
invariants formels satisfaits sur 100 % des prédictions ;
performance primaire supérieure à B4 selon la marge gelée ;
ensemble prédit assez étroit selon la borne gelée ;
résultat maintenu sur molécules absentes de construction ;
aucune fuite ou modification postérieure du protocole.
```

Un résultat égal à la baseline est un résultat formel utile mais un NO-GO pour
la nouveauté prédictive. Un résultat inférieur ou mal calibré réfute la version
du producteur dans son domaine déclaré.

### 13.4 Niveaux d'interprétation

| Niveau | Résultat | Interprétation permise |
|---|---|---|
| `CP0-S` | qualification statique | pipeline moléculaire correct |
| `CP0-R` | test public rétrospectif supérieur aux baselines | généralisation prometteuse |
| `CP0-P` | données publiées après gel | résultat réellement surprenant possible |
| `CP0-I` | test aveugle détenu par un tiers | validation indépendante forte |

Aucun de ces niveaux ne démontre une évolution darwinienne ni la calculabilité
générale du carbone.

## 14. Séquence de travail

### Phase A — audit sans modèle

```text
A1 — figer les références des sources, schémas et la réponse de métadonnées ;
A2 — filtrer les métadonnées sans ouvrir de ligne réactionnelle ;
A3 — retenir au plus un candidat pour l'audit des entrées ;
A4 — inventorier l'ontologie des entrées sans exposer les cibles ;
A5 — sceller les cibles et proposer le découpage par identités moléculaires ;
A6 — décider GO-DYNAMIC / GO-STATIC-ONLY / NO-GO sur CP0-DATA ;
A7 — publier les deux rapports, y compris en cas de NO-GO.
```

### Phase B — gel des données

```text
B1 — figer la normalisation des identités moléculaires ;
B2 — grouper duplicats et quasi-duplicats ;
B3 — exécuter le découpage déterministe ;
B4 — sceller les sorties de held_out_test ;
B5 — hasher sources, groupes et manifests.
```

### Phase C — langage chimique

```text
C1 — étendre CarbonConfiguration uniquement selon CP0-DATA ;
C2 — formaliser charges, types de liaison et BondEdit nécessaires ;
C3 — prouver l'application sûre des edits ;
C4 — construire MappedProductBalance ;
C5 — n'ajouter CompleteReactionBalance que si les données le permettent.
```

### Phase D — qualification statique

```text
D1 — geler le corpus PubChem positif et négatif ;
D2 — produire les prédictions statiques sans formules cibles ;
D3 — ouvrir les références ;
D4 — exiger le GO absolu CP0-S ;
D5 — corriger le langage dans une nouvelle version si nécessaire.
```

### Phase E — construction du producteur

```text
E1 — ouvrir construction et selection seulement ;
E2 — définir les réponses et réparations locales ;
E3 — comparer les versions sur selection ;
E4 — construire les cinq baselines ;
E5 — fixer métrique, marge et bornes d'abstention/support.
```

### Phase F — formalisation et gel

```text
F1 — instancier le Core et les invariants dans Lean ;
F2 — exporter le noyau canonique ;
F3 — démontrer la conformité exhaustive du moteur Python ;
F4 — calculer les prédictions test sans ouvrir leurs sorties ;
F5 — committer et hasher le paquet de gel.
```

### Phase G — test

```text
G1 — ouvrir les sorties une seule fois ;
G2 — exécuter le vérificateur inchangé ;
G3 — rapporter métriques, exclusions prévues et chaque échec ;
G4 — décider GO/NO-GO sans réajustement ;
G5 — archiver CP0-R ;
G6 — si GO, attendre ou obtenir un lot prospectif CP0-P.
```

## 15. Livrables prévus

```text
Carbone/CP0/
  README.md
  DATASET_AUDIT.md
  ELIGIBILITY_PROTOCOL.md
  SPLIT_PROTOCOL.md
  MODEL_CARD.md
  BASELINES.md
  FREEZE_REPORT.md
  TEST_REPORT.md
  manifests/
  schemas/
  Lean/
  scripts/
  frozen_runs/
```

Les données tierces volumineuses restent locales lorsque leur licence ou leur
taille l'exige. Le dépôt conserve leurs URI, versions, hashes, scripts de
récupération et transcriptions nécessaires à l'audit.

## 16. Coût et discipline

La phase `A` ne requiert ni laboratoire, ni achat de données, ni calcul lourd.
Les sources et logiciels prioritaires sont publics. Le téléchargement doit
viser un sous-ensemble ORD après audit, pas les millions de réactions par
défaut.

Le coût immédiat est donc du temps de formalisation, de nettoyage et d'audit.
Si aucun corpus public ne passe `CP0-DATA`, le résultat correct est un NO-GO
documenté, pas l'élargissement silencieux de la revendication.

## 17. Relation à CR0 et à la cible évolutive

`CP0` ne remplace pas `CARBON_REFERENCE_0` :

```text
CR0 : teste une collision projective et des futurs chiraux appariés ;
CP0 : teste la généralisation d'un producteur moléculaire sur données publiques ;
CW2/CW3 : devront encore construire reproduction, hérédité et sélection.
```

Un succès CP0 montrerait que le cadre peut porter un calcul chimique réfutable
qui généralise au-delà de ses exemples de construction. Il ne montrerait pas
encore que la matière réalise elle-même toute la computation du Core, ni qu'un
système carboné évolue.

## 18. Prochaine action autorisée

L'inspecteur **de métadonnées seulement** et
`Carbone/CP0/DATASET_AUDIT.md` sont maintenant produits. `CP0-DATA-M0` rend le
verdict intermédiaire `GO-INPUT-AUDIT` pour le jeu AIChemEco, sans avoir ouvert
de ligne réactionnelle, de produit ou de valeur cible.

La prochaine action n'est toujours pas d'écrire le producteur. Elle est de
construire `CP0-DATA-I0`, l'audit des structures d'entrée, rôles, conditions,
identités et groupes du seul candidat retenu. Les cibles doivent rester
inaccessibles ; seuls leur statut de présence agrégé et leur hash scellé sont
autorisés.

Cette seconde porte recommandera exactement un des verdicts suivants :

```text
GO-DYNAMIC     : une famille et une cible peuvent être gelées ;
GO-STATIC-ONLY : CP0-S est possible mais aucun test dynamique propre ne l'est ;
NO-GO          : les entrées du candidat ne peuvent être qualifiées sans
                 imputation ou élargissement non borné.
```

Rapport intermédiaire :
[`CP0-DATA-M0`](./CP0/DATASET_AUDIT.md).

## 19. Sources normatives de départ

- [Open Reaction Database — vue d'ensemble et accès aux données](https://docs.open-reaction-database.org/en/stable/overview.html)
- [Open Reaction Database — schéma des réactions, résultats et provenance](https://docs.open-reaction-database.org/en/stable/schema.html)
- [Dépôt officiel `ord-data`](https://github.com/open-reaction-database/ord-data)
- [Navigateur public des jeux ORD](https://open-reaction-database.org/browse)
- [PubChem PUG REST](https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest)
- [Service de standardisation PubChem](https://pubchem.ncbi.nlm.nih.gov/docs/standardization-service)
- [Contrat général CarbonWorld–simulation–réalité](./CARBON_WORLD_BRIDGE.md)
- [Contrat expérimental CARBON_REFERENCE_0](./CARBON_REFERENCE_0.md)
