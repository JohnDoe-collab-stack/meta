# CP0-ONTOLOGY-1 — import canonique des 194 entrées

## Verdict

```text
verdict                         = QUALIFIED_INPUT_IMPORT_194_OF_194
espèces uniques                = 194 / 194
fragments connexes             = 222
atomes lourds                  = 2 539
liaisons                       = 2 587
hashs d'identité uniques       = 194 / 194
hashs de graphe uniques        = 194 / 194
round-trips SMILES canoniques  = 194 / 194
permutations atomiques testées = 970 / 970
```

Cette porte ferme l'écart de représentation des espèces moléculaires observées
par `CP0-DATA-I0`. Elle ne constitue pas un résultat prédictif : aucune valeur
de rendement, structure produit, condition, identité de réaction ou provenance
n'a été désérialisée pendant cet import.

## Frontière de lecture

L'exporteur reconstruit chaque message `Reaction` à partir du seul champ wire 2,
`Reaction.inputs`, avant de le passer au schéma ORD. Les champs suivants sont
comptés comme enveloppes puis ignorés : identifiants, setup, conditions, notes,
observations, workups, outcomes, provenance et `reaction_id`.

La source est le dataset ORD officiel
`ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41`, figé au commit de données
`ddb0d25770c80a0a6fcf9948c26e1c8f828cb8ad`. Son fichier gzip contient
47 015 réactions, mesure 8 753 257 octets et porte le SHA-256
`103c485fc009ee66f525c140611c8596d31f0673cdbb2ec16ec497ea44a58f6f`.

## Canonicalisation externe

Pour chaque SMILES d'entrée, RDKit 2026.03.4 effectue les opérations suivantes :

1. parsing puis écriture isomérique canonique ;
2. nouveau parsing et vérification du point fixe textuel ;
3. séparation des fragments ;
4. rang canonique des atomes, racine minimale et parcours en largeur ;
5. tri canonique des fragments et des liaisons ;
6. export des éléments, charges, hydrogènes implicites, aromaticité et stéréo ;
7. cinq permutations atomiques déterministes par espèce et comparaison exacte
   du graphe exporté.

Les 194 points fixes et les 970 permutations passent. Cette partie qualifie la
stabilité observée de l'exporteur dans l'environnement figé ; ce n'est pas une
preuve Lean de l'algorithme interne de RDKit.

## Qualification constructive dans Lean

[`CanonicalImport.lean`](./Lean/CanonicalImport.lean) définit un vérificateur
calculable. Un fragment accepté satisfait simultanément :

- une liste d'atomes non vide ;
- un parent par atome ;
- des extrémités de liaison bornées et distinctes ;
- aucune paire d'extrémités non orientée dupliquée ;
- une racine d'indice zéro ;
- pour tout indice ultérieur, un parent strictement plus petit relié par une
  liaison stockée.

Le dernier point est un certificat fini d'arbre couvrant : chaque atome se
ramène à zéro par décroissance stricte. Une espèce acceptée contient au moins
un fragment, uniquement des fragments acceptés, et au moins un atome de
carbone sur l'ensemble de ses fragments. Un micro-corpus calculé vérifie aussi
l'acceptation du singleton et le rejet du vide, d'une boucle et d'un fragment
déconnecté.

[`ImportedSpecies.lean`](./Lean/ImportedSpecies.lean) contient les 194 graphes.
La déclaration `validatedSpeciesImport` prouve par réduction (`rfl`) :

```text
nombre d'espèces             = 194
toutes les espèces valides   = true
hashs d'identité uniques     = true
hashs de graphe uniques      = true
```

Le build et les blocs `#print axioms` ne rapportent aucun axiome. Il n'y a ni
`Classical`, ni `propext`, ni `Quot.sound`.

## Inventaire importé

```text
éléments                = B, Br, C, Cl, F, N, O, P, S
atomes aromatiques      = 1 087
atomes formellement chargés = 66
hydrogènes implicites   = 2 081
centres tétraédriques   = 23, assignés ou explicitement non assignés
liaisons stéréo         = 1
```

Les fragments sans carbone, notamment des contre-ions, sont autorisés à
l'intérieur d'une espèce carbonée. Les isotopes et radicaux restent refusés,
conformément à leur absence dans l'audit I0.

## Run normatif et empreintes

Suffixe commun :

```text
20260719T080146Z_sha256-0efd910c53dddb4014752533035a70268cfe03e637afe5323c91ccb74e874344
```

```text
script Python  0efd910c53dddb4014752533035a70268cfe03e637afe5323c91ccb74e874344
rapport JSONL  a06008eb42a3405046e93cad73a6f2baa9ab242deb0e50ae948430b4b5e0803c
rapport texte  dc2891d29061ff341b31e97c3a626a5ada6775c668be3f7fc5a59253941ca7ed
export Lean    afaeea1eb4537042d9183c50f8e6ee9222202bbd700348ebd0000cb47cfef9cd
dépendances    1db1caec76b147bd3a63776adb9c69c489790622c0e0aa3257d7206c479c8fde
```

La copie stable `Lean/ImportedSpecies.lean` est octet pour octet identique à
l'export Lean figé.

## Limite et prochaine porte

La couche moléculaire d'entrée est désormais totale sur ce corpus. Restent à
construire, sans ouvrir le test tenu à l'écart :

1. l'import canonique des conditions et quantités autorisées ;
2. la représentation Core de l'organisation complète amine–acide–environnement ;
3. un producteur de rendement déterminé uniquement sur la construction ;
4. la comparaison aux baselines selon `TARGET_PROTOCOL`.

Cette étape démontre la calculabilité structurelle des 194 espèces dans le
cadre. Elle ne démontre ni une transformation chimique, ni un rendement, ni la
supériorité prédictive du cadre.
