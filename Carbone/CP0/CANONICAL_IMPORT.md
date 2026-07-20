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
20260719T085207Z_sha256-df6b9ce0236f0ae755fdf17d125ecf4c56b53e6fd67d1da3007190fd69ff5f84
```

```text
script Python  df6b9ce0236f0ae755fdf17d125ecf4c56b53e6fd67d1da3007190fd69ff5f84
rapport JSONL  2c41eb07050636d3e056ff6d6ed7705625a3e53f0f606bcc146a67885eaa5449
rapport texte  9bc623615b48253dc040ee78484487dcc7ddd6701f7c79942ed2125318b1bd4c
export Lean    116f6a2a28b9cae7b7d8e02b338937e93df9cc3e4f219baee1e77c29c63a8872
dépendances    cea25e4d47005a3f5e8263bcdae37788450c4e49e62275b9ed074d7f938f0b59
```

La copie stable `Lean/ImportedSpecies.lean` est octet pour octet identique à
l'export Lean figé.

Le run `20260719T080146Z_sha256-0efd910c...` est conservé mais supersédé. Son
audit externe des 194 molécules était valide, cependant son rendu imbriqué des
records et listes était syntaxiquement invalide dans Lean. Le run normatif
ci-dessus produit les mêmes graphes au moyen de constructeurs explicites et
compile réellement avec les preuves `rfl` et l'audit sans axiome.

## Limite et prochaine porte

La couche moléculaire d'entrée est désormais totale sur ce corpus. L'import
canonique des conditions et quantités et la résolution de l'organisation
amine–acide–environnement sont documentés dans
[`ENVIRONMENT_IMPORT.md`](./ENVIRONMENT_IMPORT.md). Restent à construire, sans
ouvrir le test tenu à l'écart, le contrat du producteur issu du Core, son
lecteur de cible synthétique, puis les étapes d'ouverture prévues par
`TARGET_PROTOCOL`.

Cette étape démontre la calculabilité structurelle des 194 espèces dans le
cadre. Elle ne démontre ni une transformation chimique, ni un rendement, ni la
supériorité prédictive du cadre.
