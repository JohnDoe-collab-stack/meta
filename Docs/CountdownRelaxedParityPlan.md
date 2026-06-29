# Plan countdown et parite relaxee

## Objet

Ce document prepare la couche qui manque entre :

```text
countdown terminal
```

et :

```text
parite relaxee maximale
```

Le point de depart est le diagnostic suivant :

```text
Countdown.lean
```

ne depend pas des impaires non relaxes. Il construit une dynamique terminale
interne.

En revanche :

```text
CountdownGapContraction.lean
```

contient une lecture codee non relaxee du role mediating :

```lean
countdownTerminalMediatingCode_eq_n_plus_two
countdownTerminalMediatingCode_oddClassical
```

Cette couche est utile comme facade classique, mais elle ne doit pas porter le
raccord avec la diagonale relaxee.

## Separation stricte

Il faut separer trois niveaux.

### 1. Countdown pur

Fichier :

```text
Meta/Arithmetic/Countdown.lean
```

Objet :

```text
countdownStep
terminal collision
closed stability
```

Cette couche ne parle pas de codage impair.

### 2. Countdown code non relaxe

Fichier :

```text
Meta/Arithmetic/CountdownGapContraction.lean
```

Objet :

```text
closing code    = 2 * (n + 2)
mediating code  = 2 * (n + 2) + 1
```

Cette couche expose la presentation classique contractee.

### 3. Countdown relaxe

Fichier a creer :

```text
Meta/Arithmetic/CountdownRelaxedParity.lean
```

Objet :

```text
countdown terminal excess
-> index n + 2
-> gap relaxe maximal Nat enrichi
-> DiagonalCertificate core
-> ProjectionObstruction core
-> temoin positif
```

Cette couche ne doit pas utiliser le code impair non relaxe.

## Point architectural

Les faits terminaux utiles au countdown relaxe sont actuellement definis dans :

```text
Meta/Arithmetic/CountdownGapContraction.lean
```

Ce fichier contient deux sortes de declarations :

```text
faits terminaux enrichis
facade codee non relaxee
```

Les faits terminaux enrichis sont :

```lean
countdownTerminalIntersection
countdownArithmeticGapTerminalExcess_eq_n_plus_two
countdownTerminalClosingRole_eq_n_plus_two
countdownTerminalMediatingRole_eq_n_plus_two
```

La facade codee non relaxee contient notamment :

```lean
countdownTerminalClosingCode
countdownTerminalMediatingCode
countdownTerminalMediatingCode_oddClassical
```

Pour l'implementation immediate, le fichier :

```text
Meta/Arithmetic/CountdownRelaxedParity.lean
```

peut importer :

```lean
import Meta.Arithmetic.CountdownGapContraction
```

mais il doit utiliser uniquement les faits terminaux enrichis. L'import est
acceptable comme dependance technique actuelle ; il ne doit pas devenir une
dependance conceptuelle a la lecture codee non relaxee.

Amelioration architecturale ulterieure :

```text
Meta/Arithmetic/CountdownTerminal.lean
```

pourrait extraire les faits terminaux purs :

```text
terminal intersection
terminal excess = n + 2
closing role at n + 2
mediating role at n + 2
```

Puis :

```text
CountdownGapContraction.lean
```

porterait seulement la facade non relaxee, et :

```text
CountdownRelaxedParity.lean
```

porterait la facade relaxee.

Cette extraction n'est pas necessaire pour la premiere implementation, mais
elle clarifie la separation a maintenir.

## Entree formelle

La bonne entree est deja disponible :

```lean
countdownTerminalIntersection n
```

et son index terminal est deja prouve :

```lean
countdownArithmeticGapTerminalExcess_eq_n_plus_two :
  formedPositiveExcessOfIntersection (countdownTerminalIntersection n) =
    n + 2
```

Donc le point d'entree relaxe est :

```lean
formedPositiveExcessOfIntersection (countdownTerminalIntersection n)
```

pas :

```text
countdownTerminalMediatingCode n
```

## Construction principale

La couche doit definir :

```lean
def countdownRelaxedPositiveInternalDiagonalWitness
    (n : Nat) :
    NatEnrichedParityPositiveInternalDiagonalWitness
      (formedPositiveExcessOfIntersection
        (countdownTerminalIntersection n)) :=
  natEnrichedParityPositiveInternalDiagonalWitnessOfMaximallyRelaxedGap
    (formedPositiveExcessOfIntersection
      (countdownTerminalIntersection n))
```

Lecture :

```text
le countdown instancie la diagonale relaxee au meme index terminal que sa
fermeture dynamique.
```

## Facades a exposer

### Gap relaxe countdown

```lean
def countdownRelaxedGap
    (n : Nat) :
    NatEnrichedParityRelaxedBilateralGap
      (formedPositiveExcessOfIntersection
        (countdownTerminalIntersection n)) :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).relaxedGap
```

### Certificat diagonal core

```lean
def countdownRelaxedDiagonalCertificate
    (n : Nat) :
    DiagonalCertificate
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).diagonalCertificate
```

### Obstruction projective

```lean
def countdownRelaxedProjectionObstruction
    (n : Nat) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).projectionObstruction
```

### Valeur positive

```lean
def countdownRelaxedPositiveDiagonalValue
    (n : Nat) :
    Nat :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).witness

theorem countdownRelaxedPositiveDiagonalValue_pos
    (n : Nat) :
    0 < countdownRelaxedPositiveDiagonalValue n :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).witness_pos
```

### Identification a l'index `n + 2`

Il faut exposer une facade lisible :

```lean
theorem countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence
    (n : Nat) :
    countdownRelaxedPositiveDiagonalValue n =
      natEnrichedParityMaximalRelaxedDivergence
        (formedPositiveExcessOfIntersection
          (countdownTerminalIntersection n)) :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).witness_eq_maximal
```

Puis la facade specialisee :

```lean
theorem countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence_n_plus_two
    (n : Nat) :
    countdownRelaxedPositiveDiagonalValue n =
      natEnrichedParityMaximalRelaxedDivergence (n + 2) := by
  rw [countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence]
  rw [countdownArithmeticGapTerminalExcess_eq_n_plus_two]
```

## Raccord aux roles countdown

Il faut rendre explicite que le certificat diagonal relaxe tombe sur les roles
du countdown terminal.

Theoremes a ajouter :

```lean
theorem countdownRelaxedDiagonalCertificate_left_eq_closingRole
    (n : Nat) :
    (countdownRelaxedDiagonalCertificate n).left =
      arithmeticClosingRoleOfIntersection
        (countdownTerminalIntersection n)

theorem countdownRelaxedDiagonalCertificate_right_eq_mediatingRole
    (n : Nat) :
    (countdownRelaxedDiagonalCertificate n).right =
      arithmeticMediatingRoleOfIntersection
        (countdownTerminalIntersection n)
```

Lecture :

```text
left  = closingExcess porte par l'intersection terminale countdown
right = mediatingValue porte par l'intersection terminale countdown
```

Puis exposer les versions indexees :

```lean
theorem countdownRelaxedDiagonalCertificate_left_eq_closing_n_plus_two
    (n : Nat) :
    (countdownRelaxedDiagonalCertificate n).left =
      NatEnrichedParityRole.closingExcess (n + 2)

theorem countdownRelaxedDiagonalCertificate_right_eq_mediating_n_plus_two
    (n : Nat) :
    (countdownRelaxedDiagonalCertificate n).right =
      NatEnrichedParityRole.mediatingValue (n + 2)
```

Ces theoremes utilisent :

```lean
countdownTerminalClosingRole_eq_n_plus_two
countdownTerminalMediatingRole_eq_n_plus_two
```

mais ils ne passent pas par :

```lean
countdownTerminalMediatingCode
OddClassical
natEnrichedParityRoleCode
```

## Interdits

La nouvelle couche ne doit pas utiliser :

```text
OddClassical
EvenClassical
IsMediatingCode
natEnrichedParityRoleCode
countdownTerminalMediatingCode
countdownTerminalMediatingCode_oddClassical
```

Ces objets appartiennent a la facade codee non relaxee.

La couche relaxee doit rester sur :

```text
role enrichi
payload visible
gap relaxe
DiagonalCertificate
ProjectionObstruction
temoin positif
```

## Resultat conceptuel attendu

Apres implementation, on aura deux lectures paralleles du meme terminal
countdown :

```text
lecture non relaxee :
n + 2 -> mediating code 2 * (n + 2) + 1
```

et :

```text
lecture relaxee :
n + 2 -> mediating role relaxe
      -> divergence maximale
      -> DiagonalCertificate
      -> ProjectionObstruction
      -> temoin positif
```

Le countdown ne dependra donc pas des impaires non relaxes. La couche non
relaxee restera une lecture codee. La couche relaxee donnera le raccord utile
avec la diagonale positive interne.

## Audit attendu

Le fichier Lean devra finir par un bloc unique :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveInternalDiagonalWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedProjectionObstruction
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveDiagonalValue
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveDiagonalValue_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence_n_plus_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate_left_eq_closingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate_right_eq_mediatingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate_left_eq_closing_n_plus_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate_right_eq_mediating_n_plus_two
/- AXIOM_AUDIT_END -/
```

Validation :

```text
lake env lean Meta/Arithmetic/CountdownRelaxedParity.lean
lake env lean Meta.lean
```

## Formule courte

```text
Countdown pur :
terminal collision -> n + 2

Countdown non relaxe :
n + 2 -> 2 * (n + 2) + 1

Countdown relaxe :
n + 2 -> gap relaxe maximal
      -> diagonale positive interne
      -> obstruction projective core
```
