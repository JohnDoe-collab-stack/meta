# CP0-DATA-I0 — audit des entrées AIChemEco

## 1. Verdict

Run scientifique figé du 19 juillet 2026 :

```text
verdict          = GO-DYNAMIC
cible            = rendement en pourcentage du produit désiré
statut ontologie = EXTENSION_REQUIRED
succès prédictif = non testé
```

Le jeu AIChemEco passe la porte de **faisabilité** de `CP0-D`. Il contient une
cible numérique complète et permet un découpage strict par identités d'amines
et d'acides. Il ne passe pas encore le test prédictif : aucun rendement n'a été
décodé, aucun modèle n'a été ajusté et aucune structure produit n'a été lue.

## 2. Source figée

| Objet | Valeur |
|---|---|
| dataset | `ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41` |
| commit `ord-data` | `ddb0d25770c80a0a6fcf9948c26e1c8f828cb8ad` |
| chemin | `data/47/ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41.pb.gz` |
| taille LFS | 8 753 257 octets |
| SHA-256 LFS et fichier téléchargé | `103c485fc009ee66f525c140611c8596d31f0673cdbb2ec16ec497ea44a58f6f` |
| commit `ord-schema` | `aeda34931f3a25497dccde0f68aa789b5830962b` |
| SHA-256 `reaction_pb2.py` | `1ed2befa91faf00e76e9fd1ef555bf0da51c69a0085e5d7dd4db6418751bdd9c` |

Le fichier tiers n'est pas recopié dans le dépôt. Son
[URI exacte](https://media.githubusercontent.com/media/open-reaction-database/ord-data/ddb0d25770c80a0a6fcf9948c26e1c8f828cb8ad/data/47/ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41.pb.gz),
son commit, sa taille et son hash suffisent à le récupérer et à le vérifier.

## 3. Barrière de lecture

Le protobuf `Reaction` contient dix champs. Le run scientifique n'en
désérialise que trois :

```text
2  inputs
4  conditions
10 reaction_id
```

Il saute avant désérialisation :

```text
identifiers  : 282 090 enveloppes
setup        :  47 015 enveloppes
workups      : 423 135 enveloppes
outcomes     :  47 015 enveloppes
provenance   :  47 015 enveloppes
```

Les identifiants réactionnels sont exclus parce qu'un `REACTION_SMILES` peut
contenir le produit. Le `setup` est exclu parce que la position de plaque peut
porter un signal de lot qui ne constitue pas une condition chimique.

À l'intérieur des enveloppes `outcomes`, un lecteur binaire séparé ne résout
que les numéros de champs et les enums nécessaires pour compter :

```text
1 outcome par réaction ;
1 produit désiré de rôle PRODUCT par réaction ;
1 mesure IDENTITY par réaction ;
1 mesure YIELD portée par un Percentage avec valeur présente par réaction.
```

Il ne décode ni l'identifiant du produit, ni les octets `float32` du
pourcentage. Les compteurs normatifs sont donc :

```text
product_structures_decoded = 0
target_numeric_values_decoded = 0
reaction_identifiers_decoded = 0
complete_yield_envelopes = 47 015
```

### Limite honnête de l'aveuglement

La source est publique. Aucun chiffrement local ne peut empêcher un agent ayant
Internet de la retélécharger. La garantie fournie ici est procédurale et
vérifiable : le programme figé n'a pas de chemin de désérialisation vers les
structures produit ou les valeurs numériques, le manifest ne contient que des
hashs d'entrées, et les artefacts exécutés sont identifiés par SHA-256.

Lors d'un probe d'ingénierie antérieur au gel, le conteneur `Dataset` complet a
été instancié une fois pour vérifier la compatibilité protobuf et compter ses
réactions. Aucun champ `outcomes`, aucune structure produit et aucune valeur
n'ont été consultés ou imprimés. Le run scientifique normatif utilise ensuite
la barrière binaire décrite ci-dessus.

## 4. Complétude des entrées

Chaque ligne admissible possède exactement :

- une amine de rôle `REACTANT`, avec un SMILES ;
- un acide carboxylique de rôle `REACTANT`, avec un SMILES ;
- un agent d'activation et son solvant ;
- un solvant principal ;
- les champs de température, pression, agitation et reflux ;
- des quantités numériques pour chaque composant présent.

Le dataset contient aussi :

- une base dans 37 329 lignes ;
- un additif dans 23 795 lignes ;
- leurs solvants de stock, encodés dans toutes les lignes correspondantes.

Le filtre par rôle est obligatoire. Si l'on compte aveuglément tous les
composants rangés sous les clés `amine` et `carboxylic acid`, les solvants de
stock créent artificiellement 71 et 67 identités. Après sélection du seul
composant `REACTANT`, on retrouve exactement 70 amines et 66 acides.

RDKit canonicalise 194 SMILES bruts en 194 SMILES canoniques, sans collision.

## 5. Factorisation observée sans cible

| Objet | Nombre |
|---|---:|
| réactions | 47 015 |
| amines réactantes | 70 |
| acides réactants | 66 |
| paires amine–acide | 632 |
| conditions chimiques sémantiques | 94 |
| signatures incluant les étiquettes source | 95 |
| répétitions de paire–condition sémantique | 804 |

Les 95 étiquettes déclarées se réduisent à 94 configurations chimiques après
canonicalisation des composants et des quantités. Un seul groupe sémantique se
scinde en deux signatures d'étiquette de fréquences 600 et 1. Le protocole
retient la signature **sémantique** ; une différence de nom sans différence de
structure, quantité ou condition ne doit pas devenir une variable prédictive.

Les 804 lignes répétées ne traversent pas les compartiments, car le split est
déterminé par les deux identités moléculaires. Elles devront être regroupées au
scoring pour ne pas surpondérer une même entrée.

## 6. Split moléculaire gelé

Les amines et les acides sont classés séparément par SHA-256 avec séparation de
domaine, puis alloués exactement à 60/20/20 %. Une ligne n'entre dans un
compartiment que si **ses deux partenaires** appartiennent à ce compartiment.
Les lignes croisées sont exclues avant toute cible.

### Allocation des identités

| Compartiment | Amines | Acides |
|---|---:|---:|
| `construction` | 42 | 39 |
| `selection` | 14 | 13 |
| `held_out_test` | 14 | 14 |

### Allocation des lignes et paires

| Compartiment | Lignes | Paires | Conditions sémantiques |
|---|---:|---:|---:|
| `construction` | 17 318 | 242 | 94 |
| `selection` | 1 441 | 19 | 94 |
| `held_out_test` | 2 317 | 30 | 94 |
| `excluded_cross` | 25 939 | 341 | 94 |

Invariants :

```text
amines construction ∩ test = ∅
acides construction ∩ test = ∅
valeurs cibles complètes dans test = 2 317 enveloppes sur 2 317
```

Le test n'est donc pas un simple holdout de lignes ou de paires connues. Chaque
amine et chaque acide du test est absent de la construction.

## 7. Écart ontologique avec CW1

Les 194 molécules d'entrée utilisent :

```text
éléments   = B, Br, C, Cl, F, N, O, P, S
liaisons   = simple, double, triple, aromatique
```

Elles comprennent :

| Propriété | Molécules concernées |
|---|---:|
| liaison aromatique | 152 |
| atome formellement chargé | 32 |
| plusieurs fragments | 28 |
| centre chiral détecté | 18 |
| liaison stéréochimique | 1 |
| isotope | 0 |
| radical | 0 |

Seulement 22 molécules sur 194 passent le **filtre syntaxique supérieur** de
CW1. Ce nombre n'est pas encore une preuve de valence. Parmi les 136 substrats,
la borne tombe à 12 amines et 1 acide. Restreindre le corpus à CW1 détruirait
donc le test principal au lieu de l'appliquer honnêtement.

Le domaine reste néanmoins fini et explicite. Le détail de l'extension exigée
est fixé dans [`ONTOLOGY_GAP`](./ONTOLOGY_GAP.md).

## 8. Pourquoi le verdict est `GO-DYNAMIC`

Les critères positifs de la porte sont tous satisfaits :

```text
cible numérique présente et typée dans 100 % des lignes ;
deux familles de substrats variables ;
split bilatéral non vide et assez grand ;
conditions communes aux trois compartiments ;
identités test absentes de construction ;
ontologie finie, quoique non encore implémentée ;
source et manifest reproductibles.
```

Le verdict autorise :

```text
FREEZE_TARGET_PROTOCOL_AND_BUILD_INPUT_LANGUAGE
```

Il interdit encore :

```text
ouvrir les rendements held_out_test ;
ouvrir les structures produit ;
revendiquer une performance ou une percée.
```

## 9. Artefacts scientifiques

Suffixe commun :

```text
20260719T073503Z_sha256-c8ebfeb5d1884789c846e4336ea03b1a4312a07304e47f0deb5f6ddce10a5a9f
```

- [script figé](./frozen_runs/ord_input_audit_20260719T073503Z_sha256-c8ebfeb5d1884789c846e4336ea03b1a4312a07304e47f0deb5f6ddce10a5a9f.py) — `c8ebfeb5d1884789c846e4336ea03b1a4312a07304e47f0deb5f6ddce10a5a9f` ;
- [résultats JSONL](./frozen_runs/ord_input_audit_20260719T073503Z_sha256-c8ebfeb5d1884789c846e4336ea03b1a4312a07304e47f0deb5f6ddce10a5a9f.jsonl) — `08059e4b24ed4c9ff616c7ddf337b08cd2fb6be02527feb3e6f96730897455df` ;
- [rapport et commande](./frozen_runs/ord_input_audit_20260719T073503Z_sha256-c8ebfeb5d1884789c846e4336ea03b1a4312a07304e47f0deb5f6ddce10a5a9f.txt) — `cd49dda8b7b8681a573e723bc574abfef27143d8ded57c874acd7554c6dfeb08` ;
- [manifest sans cible](./frozen_runs/ord_input_manifest_20260719T073503Z_sha256-c8ebfeb5d1884789c846e4336ea03b1a4312a07304e47f0deb5f6ddce10a5a9f.csv.gz) — `da963892cf8caebf3ad5983773b866a13333260869805542b16d0be1aa01cb9b` ;
- [dépendances figées](./frozen_runs/ord_input_dependencies_20260719T073503Z_sha256-c8ebfeb5d1884789c846e4336ea03b1a4312a07304e47f0deb5f6ddce10a5a9f.json) — `5f8f48832dff1e2187cacf22b0cd068d60c92d621f877ee2301bc5c77cdaa3c9`.

Le premier run scientifique `v3` reste archivé mais est supersédé : `v4`
ajoute la vérification que chaque valeur de rendement présente porte exactement
le wire type protobuf `float32` et renomme explicitement la compatibilité CW1
en borne syntaxique.

Le manifest contient 47 015 lignes de hashs d'identités, conditions et
compartiments, plus son en-tête. Il ne contient aucun SMILES, produit ou
rendement.

## 10. Résultat exact

`CP0-DATA-I0` démontre qu'un test dynamique public et réfutable peut être
construit sans laboratoire et sans fuite de cible dans le pipeline réalisé.

Il ne démontre pas que le cadre prédit déjà les rendements. La prochaine
réfutation porte sur deux objets désormais précis : la capacité du cadre à
représenter ces entrées, puis sa capacité à battre les baselines gelées sur les
30 paires totalement nouvelles du test.

Mise à jour du 19 juillet 2026 : la première réfutation est passée pour la
couche moléculaire, avec 194/194 espèces qualifiées et zéro collision. Voir
[`CANONICAL_IMPORT.md`](./CANONICAL_IMPORT.md). Les conditions et quantités
doivent encore être importées avant de construire le producteur.
