# Implementation de la consommation diagonale Collatz

## Objet

Ce document prepare l'implementation de la suite dans :

```text
Meta/Collatz/DiagonalConsumption.lean
```

Le fichier Lean contient deja le raccord canonique :

```text
collatzRoleDivergenceMaximum n
-> CollatzRoleDivergencePositiveDiagonalWitness n
-> support
-> terminalExcess
-> ArithmeticDynamicGapRow
```

La suite consiste a rendre ce raccord fibre par la divergence deja portee :

```text
divergence : CollatzRoleDivergenceMaximum n
```

Le but n'est pas d'ajouter une nouvelle route. Le but est de montrer que le
support d'une divergence portee par `CollatzRoleDivergenceMaximum n` est deja
le support consomme par la ligne countdown selectionnee par
`collatzDiagonalConsumerIndex n`.

## Etat Lean actuel

Le fichier actuel importe :

```lean
import Meta.Collatz.Countdown
```

Il contient :

```lean
def collatzDiagonalConsumerIndex
    (n : Nat) :
    Nat

theorem collatzDiagonalConsumer_terminalExcess_eq_support
    (n : Nat) :
    (countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)).terminalExcess =
      (collatzRoleDivergenceMaximum n).support

theorem collatzDiagonalSupport_eq_consumerTerminalExcess
    (n : Nat) :
    (collatzRoleDivergenceMaximum n).support =
      (countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)).terminalExcess
```

Puis le paquet :

```lean
structure CollatzDiagonalConsumption
    (n : Nat) where
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
    consumerRow =
      countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)
  support_eq_terminalExcess :
    divergence.support = consumerRow.terminalExcess
```

Le constructeur actuel est canonique :

```lean
def collatzDiagonalConsumption
    (n : Nat) :
    CollatzDiagonalConsumption n
```

Il choisit :

```text
divergence := collatzRoleDivergenceMaximum n
```

## Information deja portee par la divergence

Dans `Meta/Collatz/OperationalParity.lean`, la structure porte deja :

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

La suite doit utiliser ces champs. Le support n'est pas une donnee ajoutee :

```text
support
=
payload du role droit relaxe
=
payload de collatzShadowReturnRole n
```

La divergence fibre donc deja son support.

## Declaration 1 : support fibre vers support relaxe

A ajouter dans `Meta/Collatz/DiagonalConsumption.lean`, apres
`collatzDiagonalSupport_eq_consumerTerminalExcess` :

```lean
theorem collatzRoleDivergence_support_eq_relaxed
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    divergence.support =
      collatzRelaxedRightSupport n := by
  rw [divergence.support_eq_relaxedPayload]
  rw [divergence.relaxedRightRole_eq]
  rfl
```

Role du theoreme :

```text
extraire le support depuis les champs internes de la divergence ;
le ramener au support relaxe porte par n.
```

Cette preuve ne rajoute aucune entree. Elle consomme uniquement :

```text
support_eq_relaxedPayload
relaxedRightRole_eq
definition de collatzRelaxedRightSupport
```

## Declaration 2 : support fibre vers support canonique

A ajouter juste apres :

```lean
theorem collatzRoleDivergence_support_eq_canonical
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    divergence.support =
      (collatzRoleDivergenceMaximum n).support := by
  rw [collatzRoleDivergence_support_eq_relaxed divergence]
  rfl
```

Role du theoreme :

```text
le support d'une divergence portee coincide avec le support du paquet
canonique deja consomme.
```

Ce raccord est interne a `CollatzRoleDivergenceMaximum n`. Il ne demande pas de
trajectoire, de hauteur, de rang, de fenetre, de pont terminal ou de donnees
ajoutees.

## Declaration 3 : terminalExcess vers support fibre

A ajouter juste apres :

```lean
theorem collatzDiagonalConsumer_terminalExcess_eq_divergenceSupport
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    (countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)).terminalExcess =
      divergence.support := by
  rw [collatzDiagonalConsumer_terminalExcess_eq_support n]
  exact Eq.symm
    (collatzRoleDivergence_support_eq_canonical divergence)
```

Role du theoreme :

```text
la ligne countdown selectionnee consomme le support de la divergence portee.
```

C'est le verrou de la suite.

## Declaration 4 : support fibre vers terminalExcess

A ajouter juste apres :

```lean
theorem collatzDivergenceSupport_eq_consumerTerminalExcess
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    divergence.support =
      (countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)).terminalExcess :=
  Eq.symm
    (collatzDiagonalConsumer_terminalExcess_eq_divergenceSupport
      divergence)
```

Role du theoreme :

```text
donner la forme directement utilisable dans
CollatzDiagonalConsumption.support_eq_terminalExcess.
```

## Declaration 5 : constructeur fibre

A ajouter apres la structure `CollatzDiagonalConsumption` :

```lean
def collatzDiagonalConsumptionOfDivergence
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    CollatzDiagonalConsumption n where
  divergence := divergence
  positiveDiagonal :=
    collatzRoleDivergencePositiveDiagonalWitness divergence
  positiveDiagonal_roleDivergence_eq := rfl
  consumerIntersection :=
    countdownTerminalIntersection (collatzDiagonalConsumerIndex n)
  consumerIntersection_eq := rfl
  consumerRow :=
    countdownTerminalDynamicGapRow (collatzDiagonalConsumerIndex n)
  consumerRow_eq := rfl
  support_eq_terminalExcess :=
    collatzDivergenceSupport_eq_consumerTerminalExcess divergence
```

Role du constructeur :

```text
partir de la divergence portee ;
produire son temoin positif de diagonalisation ;
selectionner la ligne countdown consommatrice ;
fermer support = terminalExcess.
```

Ce constructeur est la suite effective du fichier.

## Declaration 6 : constructeur canonique comme specialisation

Le constructeur deja present doit devenir la specialisation du constructeur
fibre :

```lean
def collatzDiagonalConsumption
    (n : Nat) :
    CollatzDiagonalConsumption n :=
  collatzDiagonalConsumptionOfDivergence
    (collatzRoleDivergenceMaximum n)
```

Role :

```text
le paquet canonique devient une specialisation du paquet fibre.
```

## Declaration 7 : facade du constructeur fibre

A ajouter apres les facades existantes :

```lean
theorem collatzDiagonalConsumptionOfDivergence_support_eq_terminalExcess
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    (collatzDiagonalConsumptionOfDivergence divergence).divergence.support =
      (collatzDiagonalConsumptionOfDivergence divergence).consumerRow.terminalExcess :=
  (collatzDiagonalConsumptionOfDivergence divergence).support_eq_terminalExcess
```

Et :

```lean
theorem collatzDiagonalConsumptionOfDivergence_positiveDiagonal_eq
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    (collatzDiagonalConsumptionOfDivergence divergence).positiveDiagonal.roleDivergence =
      (collatzDiagonalConsumptionOfDivergence divergence).divergence :=
  (collatzDiagonalConsumptionOfDivergence divergence).positiveDiagonal_roleDivergence_eq
```

Role :

```text
exposer la consommation et le temoin positif sans ouvrir la structure.
```

## Audit a mettre a jour

Le bloc final devra inclure les declarations nouvelles :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumerIndex
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumer_terminalExcess_eq_support
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalSupport_eq_consumerTerminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRoleDivergence_support_eq_relaxed
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRoleDivergence_support_eq_canonical
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumer_terminalExcess_eq_divergenceSupport
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDivergenceSupport_eq_consumerTerminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDiagonalConsumption
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumptionOfDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumption
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumption_support_eq_terminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumption_positiveDiagonal_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumptionOfDivergence_support_eq_terminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumptionOfDivergence_positiveDiagonal_eq
/- AXIOM_AUDIT_END -/
```

## Resultat attendu apres implementation

Apres cette suite, le fichier dira :

```text
toute divergence portee par CollatzRoleDivergenceMaximum n
porte un support deja lisible comme terminalExcess
de la ligne countdown consommatrice.
```

La chaine complete deviendra :

```text
CollatzRoleDivergenceMaximum n
-> support porte
-> CollatzRoleDivergencePositiveDiagonalWitness n
-> terminalExcess consomme
-> ArithmeticDynamicGapRow
```

Donc la consommation diagonale ne sera plus seulement le paquet canonique :

```text
collatzRoleDivergenceMaximum n
```

Elle sera disponible pour la divergence portee :

```text
divergence : CollatzRoleDivergenceMaximum n
```

## Formule courte

```text
La divergence porte son support.
Le temoin positif diagonalise ce support.
La ligne countdown consomme ce meme support comme terminalExcess.
La suite consiste a rendre ce raccord fibre, sans ajouter de nouvelle entree.
```
