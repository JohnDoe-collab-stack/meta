# Plan d'instanciation Collatz de la diagonale relaxee

## Objet

Ce document prepare l'instanciation, dans la couche `Meta/Collatz`, du temoin
positif de diagonalisation interne deja construit dans la couche Nat enrichi.

L'objectif est strict :

```text
Collatz operational parity
-> regime mediating / shadow
-> index Nat enrichi de l'intersection
-> gap relaxe maximal Nat
-> DiagonalCertificate core
-> ProjectionObstruction core
-> temoin positif de diagonalisation interne
```

La couche Collatz ne doit pas reconstruire la diagonale par un calcul de
payload.

## Interdit de lecture

L'instanciation Collatz ne doit pas passer par :

```text
payload numerique de retour
role calcule depuis un payload
reconnaissance apres coup d'un closingExcess
codage impair classique
```

En particulier, la couche Collatz ne doit pas reintroduire une lecture du type :

```text
shadow return role = closingExcess (... calcul de payload ...)
```

La diagonale existe deja dans Nat enrichi. Collatz doit s'y raccorder par ses
roles operationnels, pas la recalculer.

## Etat Lean disponible

La couche Collatz actuelle fournit deja, dans :

```text
Meta/Collatz/OperationalParity.lean
```

les raccords suivants :

```lean
collatzClosingRegime_eq_formedRegime
collatzMediatingRegime_eq_shadowRegime
collatzOperationalParity_sameProjection
collatzOperationalParity_separated
collatzOperationalParity_dynamicRepair
```

Donc Collatz sait deja dire :

```text
closing = formed
mediating = shadow
same projection
separation des regimes
repair dynamique sur le cote forming/closing
```

La couche Nat enrichi fournit deja, dans :

```text
Meta/Arithmetic/Parity.lean
```

le paquet strict :

```lean
NatEnrichedParityPositiveInternalDiagonalWitness
```

avec :

```text
relaxedGap
DiagonalCertificate core
ProjectionObstruction core
witness = divergence
witness > 0
witness = divergence maximale relaxee
```

Le constructeur disponible est :

```lean
natEnrichedParityPositiveInternalDiagonalWitnessOfMaximallyRelaxedGap
```

## Point d'entree Collatz

Pour une intersection enrichie :

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

l'index Nat enrichi pertinent est deja :

```lean
formedPositiveExcessOfIntersection intersection
```

Ce n'est pas un nouveau parametre externe. C'est l'index deja porte par la
formation Nat enrichie.

L'instanciation Collatz doit donc prendre la forme :

```lean
def collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedParityPositiveInternalDiagonalWitness
      (formedPositiveExcessOfIntersection intersection) :=
  natEnrichedParityPositiveInternalDiagonalWitnessOfMaximallyRelaxedGap
    (formedPositiveExcessOfIntersection intersection)
```

Cette definition ne calcule pas un retour. Elle specialise le temoin Nat au
point d'entree porte par Collatz.

## Facades a exposer

La couche Collatz doit ensuite exposer des projections nommees, sans ajouter de
mathematique nouvelle.

### Gap relaxe Collatz

```lean
def collatzRelaxedGapOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedParityRelaxedBilateralGap
      (formedPositiveExcessOfIntersection intersection) :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).relaxedGap
```

Lecture :

```text
Collatz, via son intersection Nat enrichie, porte le gap relaxe maximal.
```

### Certificat diagonal core Collatz

```lean
def collatzRelaxedDiagonalCertificateOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    DiagonalCertificate
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).diagonalCertificate
```

Lecture :

```text
Collatz porte une vraie DiagonalCertificate core via Nat enrichi.
```

### Obstruction projective Collatz

```lean
def collatzRelaxedProjectionObstructionOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).projectionObstruction
```

Lecture :

```text
La diagonale relaxee portee par Collatz produit l'obstruction projective core.
```

### Temoin positif Collatz

```lean
def collatzRelaxedPositiveDiagonalValueOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).witness
```

Puis :

```lean
theorem collatzRelaxedPositiveDiagonalValue_pos
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    0 <
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).witness_pos
```

Lecture :

```text
Le temoin diagonal Collatz est strictement positif.
```

### Identification a la divergence maximale relaxee

```lean
theorem collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzRelaxedPositiveDiagonalValueOfIntersection intersection =
      natEnrichedParityMaximalRelaxedDivergence
        (formedPositiveExcessOfIntersection intersection) :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).witness_eq_maximal
```

Lecture :

```text
Le temoin positif Collatz est exactement la divergence maximale relaxee de Nat
enrichi a l'index porte par l'intersection.
```

## Raccord aux regimes Collatz

L'instanciation doit aussi exposer que cette diagonalisation est bien situee
sur le raccord closing/mediating de la couche Collatz, sans calcul de retour.

Les declarations existantes suffisent :

```lean
collatzMediatingRegime_eq_shadowRegime
collatzOperationalParity_sameProjection
collatzOperationalParity_separated
```

Il faut ajouter une facade de lecture :

```lean
theorem collatzRelaxedDiagonalCertificate_left_eq_closingRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedDiagonalCertificateOfIntersection intersection).left =
      arithmeticClosingRoleOfIntersection intersection

theorem collatzRelaxedDiagonalCertificate_right_eq_mediatingRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedDiagonalCertificateOfIntersection intersection).right =
      arithmeticMediatingRoleOfIntersection intersection
```

Lecture :

```text
left  du DiagonalCertificate = closing role extrait par Collatz
right du DiagonalCertificate = mediating role extrait par Collatz
```

Ces deux theoremes rendent le raccord explicitement auditable. Sans eux, le
temoin serait specialise au bon index, mais le lecteur devrait reconstruire
lui-meme que le certificat diagonal porte les roles closing/mediating de
l'intersection.

Recommandation :

```text
commencer par les facades simples ;
ajouter un paquet seulement si le code devient repetitif.
```

## Fichier cible

Le bon fichier cible est :

```text
Meta/Collatz/OperationalParity.lean
```

Justification :

```text
la diagonalisation relaxee concerne directement le raccord
closing/forming et mediating/shadow deja expose par ce fichier.
```

Le fichier `Meta/Collatz/Countdown.lean` ne doit pas etre touche pour cette
premiere instanciation. Il pourra recevoir une specialisation plus tard, mais
seulement apres que l'instanciation generale soit propre.

## Audit attendu

Ajouter dans le bloc `AXIOM_AUDIT` de `Meta/Collatz/OperationalParity.lean` :

```lean
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedGapOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedDiagonalCertificateOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedProjectionObstructionOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveDiagonalValueOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveDiagonalValue_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedDiagonalCertificate_left_eq_closingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedDiagonalCertificate_right_eq_mediatingRole
```

Validation obligatoire :

```text
lake env lean Meta/Collatz/OperationalParity.lean
lake env lean Meta.lean
```

Les audits doivent rester sans axiomes.

## Resultat attendu

Apres implementation, la couche Collatz dira strictement :

```text
Collatz porte, via son intersection Nat enrichie,
le temoin positif de diagonalisation interne produit par la divergence
maximale relaxee de la parite enrichie.
```

Elle ne dira pas :

```text
Collatz calcule un payload externe qui ressemble apres coup a un role Nat.
```

## Formule courte

```text
Collatz n'ajoute pas la diagonale.
Collatz instancie la diagonale relaxee deja produite par Nat enrichi
a l'index porte par son intersection operationnelle.
```
