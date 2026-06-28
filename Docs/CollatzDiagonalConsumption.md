# Consommation diagonale Collatz

## Objet

Ce document fixe le verrou qui suit la diagonalisation locale deja obtenue dans
`Meta`.

La couche actuelle donne deja :

```text
Core Meta
-> Nat enrichi
-> parite bilaterale enrichie
-> divergence maximale locale Collatz
-> support diagonal porte
-> temoin diagonal positif
```

Le verrou suivant est la consommation dynamique de ce support :

```text
support diagonal porte
-> excess terminal consomme
-> fermeture operationnelle
```

Cette route reste interne au cadre `Meta`. Elle ne repart pas depuis une fibre
de trajectoire.

## Regle de lecture

Le document ne lit pas le raccord par une operation de payload.

La lecture correcte est :

```text
role enrichi
-> support porte
-> intersection canonique
-> temoin positif
-> consumption dynamique par excess terminal
```

Le payload visible ne definit pas le raccord. Il peut seulement verifier
l'ombre visible d'une couture deja portee par les structures enrichies.

## Socle bilaterale enrichi

Le socle est dans :

```text
Meta/Arithmetic/Parity.lean
```

Declaration centrale, restreinte aux champs structurels utiles :

```text
NatEnrichedParityBilateralGap
leftStep
rightStep
mediating_from_left
closing_from_right
```

Lecture enrichie :

```text
closingExcess
+ raccord gauche
mediatingValue
+ raccord droit
closingExcess
```

Les deux raccords sont portes separement :

```text
leftStep
rightStep
```

La structure ne contient pas d'identification des deux pas. Elle preserve donc
une relaxation asymetrique.

## Divergence maximale locale Collatz

La divergence Collatz est dans :

```text
Meta/Collatz/OperationalParity.lean
```

Les champs pertinents sont :

```lean
structure CollatzRoleDivergenceMaximum
    (n : Nat) where
  formedRole : NatEnrichedParityRole
  mediatingRole : NatEnrichedParityRole
  relaxedRightRole : NatEnrichedParityRole
  support : Nat
  formedRole_eq :
    formedRole = NatEnrichedParityRole.closingExcess n
  mediatingRole_eq :
    mediatingRole = NatEnrichedParityRole.mediatingValue n
  relaxedRightRole_eq :
    relaxedRightRole = collatzShadowReturnRole n
  support_eq_relaxedPayload :
    support = natEnrichedParityRolePayload relaxedRightRole
  relaxedRightRole_eq_support :
    relaxedRightRole = NatEnrichedParityRole.closingExcess support
```

Le support ne vient pas apres coup. Il est porte par le role droit relaxe :

```lean
support_eq_relaxedPayload :
  support = natEnrichedParityRolePayload relaxedRightRole
```

Et ce role droit relaxe est lu comme role de fermeture :

```lean
relaxedRightRole_eq_support :
  relaxedRightRole = NatEnrichedParityRole.closingExcess support
```

Donc le cote Collatz du raccord est :

```text
role droit relaxe
-> support porte
-> role de fermeture
```

Constructeur canonique :

```lean
def collatzRoleDivergenceMaximum
    (n : Nat) :
    CollatzRoleDivergenceMaximum n
```

## Temoin positif de diagonalisation

La diagonalisation locale est aussi dans :

```text
Meta/Collatz/OperationalParity.lean
```

Declaration centrale :

```lean
structure CollatzRoleDivergencePositiveDiagonalWitness
    (n : Nat) where
  roleDivergence : CollatzRoleDivergenceMaximum n
  diagonalIntersection :
    bidirectionalCompleteness.Intersection
      (canonicalBranch roleDivergence.support)
  diagonalIntersection_eq :
    diagonalIntersection =
      canonicalIntersection roleDivergence.support
  positiveWitness : Nat
  positiveWitness_eq :
    positiveWitness =
      formedPositiveExcessOfIntersection diagonalIntersection
  positiveWitness_pos :
    0 < positiveWitness
  diagonal :
    DiagonalCertificate
      (List NatTraceAtom)
      (List Nat)
      tracePayloads
  diagonal_eq :
    diagonal =
      diagonalCertificateOfIntersection diagonalIntersection
```

Constructeur canonique :

```lean
def canonicalCollatzRoleDivergencePositiveDiagonalWitness
    (n : Nat) :
    CollatzRoleDivergencePositiveDiagonalWitness n
```

Chaine codee :

```text
divergence de role
-> support porte par le role droit relaxe
-> canonicalIntersection support
-> formedPositiveExcessOfIntersection
-> temoin positif
-> DiagonalCertificate
```

Donc ce qui est deja obtenu est :

```text
Collatz porte un temoin positif de diagonalisation
issu de sa divergence locale enrichie.
```

## Lecture `1 + gap + 1`

La divergence maximale locale est une lecture enrichie d'un raccord
asymetrique :

```text
role forme
-> role mediateur
-> role droit relaxe
```

Dans la langue `1 + gap + 1` :

```text
1 gauche  = role forme
gap       = mediation relachee
1 droite  = retour ferme
```

Le role droit relaxe porte le support diagonal. La diagonale positive est
ensuite obtenue par la mecanique Nat enrichie :

```text
support porte
-> intersection canonique
-> excess positif
-> certificat diagonal
```

## Verrou restant

La diagonalisation est le producteur. Le verrou suivant est le consommateur.

Il faut maintenant une couche qui porte ensemble :

```text
1. la divergence maximale locale ;
2. le temoin positif de diagonalisation issu de son support ;
3. une ligne dynamique arithmetique qui consomme ce support comme excess ;
4. la fermeture operationnelle obtenue par cette consommation.
```

Nom naturel :

```text
Meta/Collatz/DiagonalConsumption.lean
```

## Pas de retour vers une fibre trajectorielle

`Meta/Arithmetic/HeightDiagonal.lean` donne une autre route :

```text
NatTrajectoryFinitePrefixHeightCertificate
-> NatTrajectoryPositiveDiagonalHeightWitness
```

Cette route concerne les hauteurs de trajectoire et les fenetres post-pic.
Elle ne donne pas le point de depart du verrou actuel.

Le point de depart actuel est :

```text
CollatzRoleDivergenceMaximum n
```

Il produit directement :

```text
support porte
```

puis :

```text
CollatzRoleDivergencePositiveDiagonalWitness n
```

La prochaine couche doit donc consommer le support diagonal deja produit par la
divergence de role. Elle ne doit pas remplacer cette production par une hauteur
de trajectoire.

## Consommation dynamique disponible

La couche dynamique arithmetique est dans :

```text
Meta/Arithmetic/DynamicGap.lean
```

Elle expose `ArithmeticDynamicGapRow` avec :

```text
formed
shadow
visible
terminalTime
terminalExcess
sameVisible
separated
obstruction
recovery
```

Cette ligne est le bon type de consommation :

```text
intersection dynamique
-> trace formee
-> shadow payload-only
-> meme visible
-> separation
-> recuperation locale
```

La specialisation countdown donne une consommation terminale explicite :

```text
Meta/Arithmetic/CountdownDynamicGap.lean
Meta/Arithmetic/CountdownGapContraction.lean
Meta/Collatz/Countdown.lean
```

Elle porte les declarations de consommation :

```text
countdownTerminalDynamicGapRow
countdownTerminalIntersection
```

Dans cette couche, le countdown porte `terminalExcess` comme excess dynamique
consomme.

## Raccord a formaliser

Le raccord ne doit pas etre formule comme une egalite de payload.

Il doit etre formule ainsi :

```text
support porte par relaxedRightRole
=
terminalExcess porte par countdownTerminalIntersection
```

Le cote Collatz est enrichi :

```text
CollatzRoleDivergenceMaximum
-> relaxedRightRole
-> support
-> closingExcess support
```

Le cote countdown est enrichi :

```text
countdownTerminalIntersection
-> formedPositiveExcessOfIntersection
-> terminalExcess
-> ArithmeticDynamicGapRow
```

Le choix de l'index du consommateur countdown doit etre determine par cette
couture enrichie. Sa presentation ne doit pas faire du payload le moteur du
raisonnement.

## Forme Lean visee

Le paquet attendu doit verrouiller les donnees :

```lean
structure CollatzDiagonalConsumption (n : Nat) where
  divergence :
    CollatzRoleDivergenceMaximum n
  positiveDiagonal :
    CollatzRoleDivergencePositiveDiagonalWitness n
  positiveDiagonal_roleDivergence_eq :
    positiveDiagonal.roleDivergence = divergence
  consumerIntersection :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision
              (collatzDiagonalConsumerIndex n)))))
  consumerIntersection_eq :
    consumerIntersection =
      countdownTerminalIntersection (collatzDiagonalConsumerIndex n)
  consumerRow :
    ArithmeticDynamicGapRow
  consumerRow_eq :
    consumerRow = countdownTerminalDynamicGapRow
      (collatzDiagonalConsumerIndex n)
  support_eq_terminalExcess :
    divergence.support = consumerRow.terminalExcess
```

Constructeur canonique attendu :

```lean
def collatzDiagonalConsumption
    (n : Nat) :
    CollatzDiagonalConsumption n
```

Cette couche doit etre une facade constructive directe. Elle ne doit pas
ajouter de hauteur, de rang, de pont terminal, ni de donnee aval.

## Ce que cela demontrera

La couche demontrera :

```text
le support diagonal porte par la divergence locale Collatz
est consommable comme excess terminal par la dynamique Nat enrichie.
```

Elle demontrera donc le raccord :

```text
temoin positif de diagonalisation
-> support porte
-> excess terminal consomme
-> ligne dynamique operationnelle
```

Elle ne doit pas etre presentee comme une operation visible.

## Formule courte

```text
CollatzRoleDivergenceMaximum
produit un support porte par le role droit relaxe.

CollatzRoleDivergencePositiveDiagonalWitness
diagonalise positivement ce support.

La prochaine couche doit montrer que ce support
est consomme comme terminalExcess par la dynamique Nat enrichie.
```
