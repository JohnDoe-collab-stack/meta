# Plan de nettoyage ProjectedIdentity / OOD / Collatz

## Objet

Ce document prepare le nettoyage architectural impose par l'introduction de :

```text
Meta/Core/ProjectedIdentity.lean
```

Le but n'est pas de changer la preuve Collatz actuelle par une couche plus
lourde. Le but est de remettre chaque couche a sa place :

```text
ProjectedIdentity
-> theorie generale de l'identite quotientee et de la relaxation contrainte

OOD
-> facade applicative de changement de regime visible

RelaxedOddOOD
-> instance arithmetique OOD de l'impair relaxe

Collatz
-> raccord direct a l'impair relaxe, avec lecture visible `3n+1`
```

## Diagnostic actuel

### 1. Le noyau general existe

Le fichier :

```text
Meta/Core/ProjectedIdentity.lean
```

formalise deja :

```text
ProjectedIdentityCell
ReadIdentityCell
PositiveProjectedInvariant
ConstrainedProjectionRelaxation
```

et expose les facades :

```text
cellules projectives in/out
cellules lues in/out
invariant positif
obstructions in/out
non-reconstruction in/out
conservation du temoin
```

Ce fichier est le noyau theorique propre.

### 2. OOD existe encore comme theorie parallele

Le fichier :

```text
Meta/OOD/WitnessTransport.lean
```

porte deja :

```text
OODProjectionShift
OODRecoveredCell
OODWitnessTransport
OODPositiveWitnessTransport
OODPositiveInvariant
OODStructuralCertificate
OODPositiveStructuralCertificate
```

Mais ces objets ne sont pas encore raccordes formellement a
`ConstrainedProjectionRelaxation`.

Donc `OOD` fonctionne encore comme une couche autonome.

### 3. L'impair relaxe possede deja une lecture OOD

Le fichier :

```text
Meta/Arithmetic/RelaxedOddOOD.lean
```

donne deja une instance arithmetique OOD de l'impair relaxe :

```text
NatEnrichedRelaxedOddRole k
-> projection in/out
-> lecture in/out
-> visible shift
-> temoin positif transporte
-> invariant positif
-> certificat structurel OOD
```

Son contenu mathematique est pertinent pour Collatz, car il exprime :

```text
la branche relaxee n'est pas une sortie libre ;
elle est un changement de regime visible contraint par un temoin positif.
```

### 4. Collatz ne depend pas directement de RelaxedOddOOD

Les fichiers `Meta/Collatz` importent le noyau arithmetique direct :

```text
Meta.Arithmetic.RelaxedOdd
```

via :

```text
Meta/Collatz/RelaxedOddActionBridge.lean
```

La route actuelle est :

```text
OperationalParity
-> RelaxedOddActionBridge
-> CountdownConsumptionBridge
-> DynamicClosureLoop
-> InternalTerminality
-> DiagonalOrder
```

Donc Collatz utilise deja :

```text
impair relaxe
temoin positif
diagonale core
obstruction
3n+1 = 2 * rightPayload
retraction /2
consommation countdown
reinsertion
```

Mais il n'utilise pas directement :

```text
RelaxedOddOOD
```

## Lecture correcte

La lecture correcte n'est pas :

```text
Collatz doit passer par OOD pour fonctionner.
```

La lecture correcte est :

```text
Collatz utilise directement RelaxedOdd.
RelaxedOddOOD donne la lecture interface/OOD de ce meme mecanisme.
ProjectedIdentity donne la theorie generale expliquant pourquoi cette lecture
est une relaxation contrainte d'identite.
```

Donc :

```text
RelaxedOdd
= noyau arithmetique direct

RelaxedOddOOD
= lecture OOD du noyau arithmetique

ProjectedIdentity
= theorie generale de la relaxation contrainte
```

## Ce que le nettoyage doit prouver

Le nettoyage doit etablir trois raccords.

### Raccord 1 : OOD vers ProjectedIdentity

Il faut montrer que la structure OOD positive contient une extraction vers une
`ConstrainedProjectionRelaxation`.

Forme visee :

```text
OODPositiveWitnessTransport
-> ConstrainedProjectionRelaxation
```

avec une specialisation du temoin :

```text
WitnessOf cell := Nat
Positive cell w := 0 < w
```

Ce raccord est unidirectionnel.

Il ne faut pas affirmer une equivalence entre `OOD` et `ProjectedIdentity`.

`OOD` porte des donnees supplementaires :

```text
ShiftSource
RepairOf
recovered cell
```

`ConstrainedProjectionRelaxation` extrait seulement le noyau :

```text
cellule diagonale source
sameOut
visibleShift
temoin positif
conservation in/out du temoin
```

Donc la bonne phrase est :

```text
OODPositiveWitnessTransport fournit une ConstrainedProjectionRelaxation.
```

La phrase a eviter est :

```text
OODPositiveWitnessTransport est equivalent a ConstrainedProjectionRelaxation.
```

Ce raccord doit rester constructif.

Il ne doit pas ajouter de nouvelle hypothese.

Il ne doit pas remplacer une fermeture par un theoreme conditionnel.

Declaration cible probable :

```text
constrainedProjectionRelaxationOfOODPositiveWitnessTransport
```

Construction attendue :

```text
sourceCell.formed      := transport.cell.shift.formed
sourceCell.shadow      := transport.cell.shift.shadow
sourceCell.sameVisible := transport.cell.shift.sameIn
sourceCell.separated   := transport.cell.shift.separated
sameOut                := transport.cell.shift.sameOut
visibleShift           := transport.cell.shift.visibleShift
invariant              := transport.witnessOfCell
invariant_pos          := transport.witness_pos
witnessIn              := transport.witnessIn
witnessOut             := transport.witnessOut
witnessIn_eq           := transport.witnessIn_eq
witnessOut_eq          := transport.witnessOut_eq
```

Equivalent explicite possible pour `visibleShift` :

```text
transport.cell.shift.visibleShiftOfSource transport.cell.shift.shiftSource
```

Ce second style est plus transparent si Lean ne reduit pas bien la notation par
point.

### Raccord 2 : RelaxedOddOOD vers ProjectedIdentity

Une fois le raccord OOD general etabli, il faut exposer la consequence
arithmetique :

```text
natEnrichedRelaxedOddOODPositiveWitnessTransport k
-> ConstrainedProjectionRelaxation
```

Declaration cible probable :

```text
natEnrichedRelaxedOddConstrainedProjectionRelaxation
```

Puis extraire depuis cette relaxation :

```text
cellule projective in/out
cellule lue in/out
invariant positif
obstruction in/out
non-reconstruction in/out
```

Cela montrera formellement que l'impair relaxe arithmetique est une instance de
la theorie `ProjectedIdentity`.

Ici encore, le raccord est une extraction :

```text
RelaxedOddOOD
-> ConstrainedProjectionRelaxation
```

Il ne remplace pas `RelaxedOddOOD`. Il expose son noyau projectif positif.

### Raccord 3 : Collatz vers la lecture OOD sans perdre le raccord direct

Collatz doit garder son raccord direct :

```text
RelaxedOdd
-> RelaxedOddActionBridge
```

Mais on peut ajouter une facade de lecture :

```text
Collatz intersection
-> formedPositiveExcessOfIntersection intersection
-> RelaxedOddOOD a cet index
-> ConstrainedProjectionRelaxation
```

Cette facade ne doit pas devenir la route obligatoire de la preuve Collatz.

Elle doit seulement certifier que la branche visible `3n+1` est la lecture d'un
changement de regime visible contraint par le temoin positif interne.

## Ordre d'implementation recommande

### Etape 1 : ne pas toucher Collatz

Avant de modifier Collatz, stabiliser le raccord general :

```text
OOD -> ProjectedIdentity
```

Fichier probable :

```text
Meta/OOD/ProjectedIdentityBridge.lean
```

ou ajout controle dans :

```text
Meta/OOD/WitnessTransport.lean
```

Preference :

```text
nouveau fichier
```

car cela evite de perturber la couche OOD actuelle.

Imports attendus :

```lean
import Meta.Core.ProjectedIdentity
import Meta.OOD.WitnessTransport
```

Ce fichier ne doit pas importer Collatz ni Arithmetic.

### Etape 2 : raccorder RelaxedOddOOD

Ajouter une facade dans :

```text
Meta/Arithmetic/RelaxedOddOOD.lean
```

ou dans un nouveau fichier :

```text
Meta/Arithmetic/RelaxedOddProjectedIdentity.lean
```

Preference :

```text
nouveau fichier
```

car `RelaxedOddOOD.lean` est deja une instance OOD stable.

Imports attendus :

```lean
import Meta.OOD.ProjectedIdentityBridge
import Meta.Arithmetic.RelaxedOddOOD
```

Ce fichier ne doit pas importer Collatz.

### Etape 3 : ajouter une facade Collatz de lecture

Ajouter un fichier dedie :

```text
Meta/Collatz/RelaxedOddProjectedIdentityBridge.lean
```

Ce fichier doit seulement dire :

```text
une intersection Collatz active l'index k ;
l'index k porte l'instance RelaxedOddOOD ;
cette instance produit une relaxation contrainte ProjectedIdentity ;
le temoin positif est celui deja porte par l'impair relaxe.
```

Il ne doit pas redefinir :

```text
3n+1
rightPayload
temoin positif
diagonale
countdown
```

Il doit reutiliser les declarations existantes.

Declaration cible probable :

```text
collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
```

Elle doit etre definie a partir de :

```text
formedPositiveExcessOfIntersection intersection
natEnrichedRelaxedOddOODPositiveWitnessTransport
constrainedProjectionRelaxationOfOODPositiveWitnessTransport
```

Elle ne doit pas recalculer la branche `3n+1`.

Imports attendus :

```lean
import Meta.Arithmetic.RelaxedOddProjectedIdentity
import Meta.Collatz.RelaxedOddActionBridge
```

Le fichier peut importer `RelaxedOddActionBridge` pour identifier l'index active
par l'intersection, mais il ne doit pas recreer les preuves arithmetiques deja
presentes.

## Discipline d'integration

Les nouveaux fichiers doivent d'abord compiler comme modules separes.

Ordre de validation :

```text
1. lake env lean Meta/OOD/ProjectedIdentityBridge.lean
2. lake env lean Meta/Arithmetic/RelaxedOddProjectedIdentity.lean
3. lake env lean Meta/Collatz/RelaxedOddProjectedIdentityBridge.lean
```

L'ajout a `Meta.lean` ne vient qu'apres validation de chaque fichier.

Si `Meta.lean` est modifie, son bloc `AXIOM_AUDIT` doit etre mis a jour dans le
meme commit.

Le point important :

```text
ProjectedIdentity.lean ne doit pas devenir une dependance globale par defaut
tant qu'un pont explicite ne l'exige pas.
```

Donc l'import de `ProjectedIdentity` doit rester local au pont :

```text
OOD/ProjectedIdentityBridge
```

puis se propager uniquement par les fichiers qui utilisent ce pont.

## Ce qu'il ne faut pas faire

### Ne pas faire de OOD la route principale de Collatz

La route principale reste :

```text
RelaxedOdd
-> Collatz
```

OOD est une lecture de regime visible, pas le moteur arithmetique.

### Ne pas redefinir l'impair relaxe par le code visible

Interdit conceptuel :

```text
impair relaxe := 2k+1
```

Le code visible peut etre utilise comme lecture source, mais l'impair relaxe
reste le role enrichi :

```text
NatEnrichedRelaxedOddRole k
```

### Ne pas confondre projection et lecture

Il faut conserver la distinction :

```text
project : Interface -> Visible
read : Visible -> Label
```

La projection expose.

La lecture interprete.

Le shift visible concerne la lecture.

La cellule diagonale concerne d'abord la projection.

### Ne pas ajouter de producteur aval

Le raccord doit utiliser les donnees deja presentes :

```text
OODPositiveWitnessTransport
NatEnrichedRelaxedOddRole
formedPositiveExcessOfIntersection
```

Il ne faut pas introduire une donnee du type :

```text
si un pont existe alors...
```

## Criteres de validation Lean

Chaque fichier Lean cree ou modifie doit verifier :

```text
pas d'axiome
pas de Classical
pas de propext
pas de Quot.sound
pas de Quot
pas de sorry
un seul AXIOM_AUDIT en fin de fichier
```

Verifications minimales :

```bash
lake env lean <fichier>
lake build <module>
rg -n "axiom|sorry|Classical\\.|open Classical|propext|Quot\\.sound|\\bQuot\\b" <fichier>
```

## Verification de typabilite deja faite

Le plan a ete verifie par prototype Lean non persiste.

Les trois raccords suivants sont typables :

```text
OODPositiveWitnessTransport
-> ConstrainedProjectionRelaxation

natEnrichedRelaxedOddOODPositiveWitnessTransport k
-> ConstrainedProjectionRelaxation

Collatz intersection
-> formedPositiveExcessOfIntersection intersection
-> natEnrichedRelaxedOddOODPositiveWitnessTransport
-> ConstrainedProjectionRelaxation
```

Les prototypes controles etaient :

```text
testConstrainedProjectionRelaxationOfOODPositiveWitnessTransport
testNatEnrichedRelaxedOddConstrainedProjectionRelaxation
testCollatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
```

Chaque prototype a affiche :

```text
does not depend on any axioms
```

Donc l'implementation n'a pas besoin d'inventer une nouvelle donnee. Elle doit
se contenter de materialiser proprement ces raccords dans les trois fichiers
dedies.

## Resultat attendu

Apres nettoyage, l'architecture doit se lire ainsi :

```text
ProjectedIdentity
  theorie generale :
  identite quotientee + relaxation contrainte

OOD
  facade applicative :
  changement de regime visible + transport du temoin

RelaxedOddOOD
  instance arithmetique :
  impair relaxe comme relaxation contrainte

Collatz
  raccord direct :
  branche `3n+1` comme lecture visible de l'impair relaxe

Collatz facade ProjectedIdentity
  lecture certifiee :
  l'activation Collatz instancie une relaxation contrainte
  a l'index forme par l'intersection
```

La phrase finale a obtenir est :

```text
Dans le cadre Meta, la branche Collatz `3n+1` n'est pas une sortie libre.
Elle est la lecture visible d'une relaxation contrainte de l'identite impaire,
portee par l'impair relaxe enrichi et controlee par son temoin positif interne.
```
