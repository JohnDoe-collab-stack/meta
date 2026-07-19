# CP0-ONTOLOGY-0 — écart entre CW1 et les entrées AIChemEco

> État d'implémentation : O1 à O6 sont terminées pour la couche moléculaire.
> [`InputOntology.lean`](./Lean/InputOntology.lean) définit le langage,
> [`CanonicalImport.lean`](./Lean/CanonicalImport.lean) son vérificateur et
> [`ImportedSpecies.lean`](./Lean/ImportedSpecies.lean) certifie 194/194
> espèces, sans axiome ni collision. `CP0-ONTOLOGY-2` importe aussi les
> quantités et 94 environnements, vérifie les 47 015 liens au manifest I0 et
> résout une organisation d'entrée sans clé de dataset. O7, le producteur issu
> du Core, reste ouvert.

## 1. Décision

Le corpus dynamique ne peut pas être transcrit directement dans
`CarbonConfiguration` de CW1 : au plus 13 des 136 substrats passent son filtre
syntaxique, avant même preuve de valence. Le bon choix n'est ni de masquer les
autres molécules, ni de déclarer RDKit comme preuve. Il faut construire une
extension positive, finie et auditée du langage d'entrée.

## 2. Domaine minimal imposé par les données

L'audit fixe exactement les extensions suivantes :

```text
éléments lourds : B, C, N, O, F, P, S, Cl, Br
hydrogène       : explicite ou implicitement calculé, mais convention unique
charge          : charge formelle entière par atome
liaisons        : simple, double, triple, aromatique
stéréochimie    : centre tétraédrique et stéréo de liaison présents dans le corpus
composition     : molécule connexe ou multiensemble de fragments pour sels
rôle            : REACTANT, REAGENT, SOLVENT
quantité        : moles ou volume avec unité et valeur positive
conditions      : température, pression, agitation, reflux
```

Radicaux et isotopes sont absents : ils restent hors domaine. Aucun nouvel
élément ou type de liaison ne sera ajouté « au cas où ».

## 3. Structures positives à introduire

Le langage Lean devra porter les données suivantes :

```text
CP0Element
  = B | C | N | O | F | P | S | Cl | Br | H

CP0BondKind
  = single | double | triple | aromatic

CP0Atom
  = element
  + formalCharge : Int
  + isotope      : absent dans CP0
  + tetraStereo  : none | cw | ccw | unspecified

CP0Bond
  = deux indices d'atomes distincts
  + type de liaison
  + stéréo de liaison bornée

CP0Molecule
  = tableau fini d'atomes
  + tableau fini de liaisons
  + validité des indices
  + canonicalId calculable

CP0Mixture
  = multiensemble fini de CP0Molecule avec rôles et quantités

CP0Condition
  = température + pression + agitation + reflux

CP0Input
  = amine + acide + mixture auxiliaire + condition
```

Une molécule multiframe de type sel ne doit pas être déclarée connexe. Elle doit
être représentée comme un multiensemble positif de fragments connexes. Cela
préserve la distinction entre organisation moléculaire et mélange.

## 4. Ce qui doit être prouvé constructivement

Pour chaque structure importée :

```text
indices de liaisons dans les bornes ;
absence de boucle atomique ;
unicité canonique des arêtes non orientées ;
connexité de chaque fragment déclaré connexe ;
conservation exacte des charges et composants par l'import ;
stabilité du canonicalId sous réordonnancement des atomes ;
séparation des rôles réactant / réagent / solvant ;
positivité et unité déclarée des quantités.
```

La validation RDKit reste un contrôle externe. La déclaration Lean ne peut pas
prendre « RDKit accepte le SMILES » comme axiome : les instances finies
exportées devront satisfaire leurs invariants par calcul ou preuve.

## 5. Valence et aromaticité

Une table universelle de valence serait trop ambitieuse pour CP0, notamment
pour B, P et S. Le premier langage doit distinguer :

1. **validité structurelle**, calculable pour toutes les entrées du corpus ;
2. **admissibilité de valence**, définie seulement pour les motifs réellement
   rencontrés et justifiée par inventaire ;
3. **transformation chimique**, non nécessaire pour la première cible de
   rendement si le produit n'est jamais calculé.

L'aromaticité doit être un type de liaison explicite, pas une alternance de
Kekulé choisie silencieusement. Une normalisation Kekulé pourra être ajoutée
comme fonction totale avec preuve de conservation, mais elle n'est pas requise
pour identifier les entrées.

## 6. Pont avec le Core

Le Core ne reçoit pas un nom de molécule ou un numéro de ligne. Il reçoit un
état fini :

```text
organisation = deux substrats + environnement moléculaire + conditions ;
localité      = voisinages atomiques et interactions de fragments ;
capacité      = ressources/activations portées par les réagents ;
réponse       = intervalle ou valeur de rendement calculée ;
abstention    = entrée hors ontologie positive.
```

Les identifiants de dataset, numéros de plaque et étiquettes de condition sont
interdits comme features. Leur utilisation transformerait le test du cadre en
mémorisation de corpus.

## 7. Ordre d'implémentation

```text
O1 — définir CP0Element, CP0BondKind, CP0Atom et CP0Bond — noyau compilé ;
O2 — définir fragments, molécules et mélanges finis — noyau compilé ;
O3 — écrire l'importeur Python vers une forme canonique sans cible — terminé ;
O4 — exporter un micro-corpus positif et négatif vers Lean — terminé ;
O5 — calculer les invariants et auditer l'idempotence canonique — terminé ;
O6 — couvrir les 194 identités d'entrée ou s'abstenir explicitement — 194/194 ;
O6b — importer quantités, rôles, protocole et conditions — 94/94, terminé ;
O6c — résoudre l'organisation complète sans hash ni cible — terminé ;
O7 — définir le producteur de réponse du Core — non commencé.
```

Le GO ontologique exige une couverture de 194/194 identités et zéro collision
canonique. Une couverture partielle ne peut être réparée par exclusion
postérieure du test.

Les rapports normatifs et la distinction entre preuve Lean et audits externes
sont consignés dans [`CANONICAL_IMPORT.md`](./CANONICAL_IMPORT.md) et
[`ENVIRONMENT_IMPORT.md`](./ENVIRONMENT_IMPORT.md).
