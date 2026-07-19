# CP0-ONTOLOGY-2 — organisation d'entrée complète sans cible

## Verdict

```text
verdict                         = QUALIFIED_ENVIRONMENT_IMPORT_94_OF_94
lignes ORD vérifiées            = 47 015 / 47 015
lignes égales au manifest I0    = 47 015 / 47 015
espèces moléculaires référencées = 194 / 194
amines distinctes               = 70
acides distincts                = 66
environnements sémantiques      = 94 / 94
hashs de contenu uniques        = 94 / 94
entrées (amine, acide, env.)    = 46 211
conditions physiques distinctes = 1
structures produit décodées     = 0
valeurs cibles décodées         = 0
```

Cette porte construit une organisation d'entrée calculable à partir des deux
substrats, des espèces auxiliaires, des rôles, des quantités, du protocole
d'addition et des conditions physiques. Elle ne construit encore ni dynamique
du Core, ni loi de rendement, ni prédiction.

## Frontière de lecture

L'exporteur ne désérialise que les champs protobuf `Reaction.inputs`,
`Reaction.conditions` et `Reaction.reaction_id`. L'identifiant de réaction est
immédiatement transformé par un hash de domaine et sert uniquement à vérifier
l'égalité ligne par ligne avec le manifest gelé `CP0-DATA-I0`. Les identifiants
structuraux de réaction ne sont pas lus.

Les champs `outcomes`, produits, rendements, provenance, setup, workups et
identifiants structuraux restent hors du message assaini. Le run compte :

```text
product_structures_decoded              = 0
target_numeric_values_decoded           = 0
reaction_structure_identifiers_decoded  = 0
reaction_id_strings_hashed              = 47 015
```

Pour chacune des 47 015 lignes, le hash de réaction, l'identité de l'amine,
l'identité de l'acide et le hash de condition sémantique coïncident exactement
avec le manifest I0. Cette égalité relie l'import au split gelé sans ouvrir sa
cible.

## Données positives importées

Les quantités `float32` de la source sont converties en rationnels binaires
exacts : aucune approximation décimale supplémentaire n'est introduite. Les
unités réellement rencontrées sont `millimole` et `microliter`.

Chaque environnement porte :

- les quantités de l'amine et de l'acide ;
- 7 à 9 composants auxiliaires avec groupe, espèce, rôle et quantité ;
- six étapes d'addition ordonnées, leur délai éventuel et la pipette ;
- température, unité, contrôle de température, pression, atmosphère,
  agitation et reflux.

Le corpus ne contient qu'une condition physique canonique dans cette
projection : 25 °C, plaque d'aluminium sèche, pression ambiante, air, barreau
agité et absence de reflux. Les 94 environnements se distinguent donc par les
auxiliaires et leurs quantités, pas par 94 températures différentes. Dix
quantités auxiliaires exactes distinctes sont rencontrées.

## Qualification constructive dans Lean

[`EnvironmentImport.lean`](./Lean/EnvironmentImport.lean) définit les types
positifs, les vérificateurs et la résolution. Les certificats calculés exigent :

- 94 environnements valides et deux collections de hash uniques ;
- 70 identités d'amines et 66 identités d'acides, uniques ;
- l'appartenance de ces 136 identités aux 194 espèces moléculaires certifiées ;
- des quantités strictement positives et des dénominateurs non nuls ;
- des indices d'espèces auxiliaires bornés ;
- six groupes et six ordres d'addition sans doublon ;
- des conditions physiques rationnelles bien formées.

[`ImportedEnvironments.lean`](./Lean/ImportedEnvironments.lean) contient les 94
instances et les preuves par réduction. Un exemple réel est résolu jusqu'à
`InputOrganization`, puis projeté vers `InputProjection`; les deux calculs se
réduisent à `some`.

Les hash et indices ne sont que des clés de résolution. `InputOrganization`
contient ensuite les graphes moléculaires, rôles, quantités, étapes et condition
physique, sans hash de molécule, hash d'environnement, numéro de ligne ou
identifiant de réaction. `InputProjection` ne réintroduit aucune de ces clés.

Le build et les blocs `#print axioms` ne rapportent aucun axiome. La résolution
a été écrite par récursion structurelle explicite afin de ne dépendre ni de
`propext`, ni de `Classical`, ni de `Quot.sound`.

## Run normatif et empreintes

Suffixe commun :

```text
20260719T091321Z_sha256-ba12c0482fd4a541d77cc4e90232a8ccf53e298feafaae30d547db53a1d65e37
```

```text
script Python  ba12c0482fd4a541d77cc4e90232a8ccf53e298feafaae30d547db53a1d65e37
rapport JSONL  90813afc63660cfedee172cc1fee60d4feb3287953db35fd6b1a59d3f1dccca5
rapport texte  63d74395654c275d672d5610609951123581f94d7ad2a41ede9d07a530a7a589
export Lean    2a33153e36ce3e54cb1bba528431dbd0ef5ad65fd736fdeeff265fabbdc2ce62
dépendances    1dccdaf2d71bbd2c63f3f28d00562694f4aceddc1f57d918e06cbaa181888796
manifest I0    da963892cf8caebf3ad5983773b866a13333260869805542b16d0be1aa01cb9b
```

La copie stable `Lean/ImportedEnvironments.lean` est octet pour octet identique
à l'export Lean figé.

## Ce qui est acquis, et la prochaine porte

Il est maintenant possible de calculer, pour toute ligne admise du corpus, une
entrée intrinsèque complète et sans cible. Cela ferme le problème de
représentation des entrées de `CP0-R`.

Il reste à définir avant toute ouverture de rendement :

1. le contrat du producteur issu du Core et la projection admissible de
   `InputOrganization` ;
2. un lecteur de cible testé uniquement sur données synthétiques (`T1`) ;
3. le gel de ce lecteur et de ses contrôles `[0, 100]` (`T2`) ;
4. seulement ensuite l'ouverture de `construction`, jamais de
   `held_out_test`.

Cette porte établit la calculabilité et l'intégrité de l'entrée. Elle n'établit
pas encore que le cadre explique la chimie ni qu'il bat une baseline.
