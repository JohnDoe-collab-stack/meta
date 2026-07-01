# Hauteur fibrewise de la fibre Collatz initiale

## Objet

Ce document fixe le point de lecture suivant :

```text
n initial
=
index k de la fibre Collatz
```

L'index `k` n'est pas un temps de la sequence.

L'index `k` n'est pas une valeur quelconque rencontree plus tard.

L'index `k` est le nom interne de la fibre ouverte par la valeur initiale.

Donc, pour une sequence Collatz issue de `n`, on lit :

```text
k := n
```

## Lecture dans le cadre

Dans le cadre Meta, une fibre n'est pas seulement une suite visible de valeurs.
Elle est un support operationnel indexe.

Ainsi, l'entier initial `n` sert de point d'attache a la structure enrichie :

```text
k
-> closingExcess k
-> mediatingValue k
-> divergence maximale relaxee a k
-> hauteur fibrewise H(k)
-> temoin positif de diagonalisation
-> consommation countdown
-> reinsertion closing/forming
```

La hauteur de vol pertinente pour cette lecture est donc :

```text
H(k) = natEnrichedParityFibrewiseStructuralPeak k
```

et, pour la fibre Collatz issue de `n` :

```text
H(n) = natEnrichedParityFibrewiseStructuralPeak n
```

## Ce qui est deja porte par Nat enrichi

Dans `Meta/Arithmetic/Parity.lean`, pour tout index `k`, on dispose de :

```lean
natEnrichedParityFibrewiseStructuralPeak k
```

avec :

```lean
natEnrichedParityFibrewiseStructuralPeak k =
  natEnrichedParityMaximalRelaxedDivergence k
```

et :

```lean
natEnrichedParityFibrewiseStructuralPeak k = (k + k) + 2
```

Cette hauteur est :

```text
positive ;
issue de la divergence maximale relaxee ;
porteuse d'un temoin positif interne de diagonalisation ;
deja en forme consommable par countdown.
```

Le temoin positif interne est porte par :

```lean
natEnrichedParityFibrewiseStructuralPeakWitness k
```

## Lecture Collatz

La facade Collatz attendue ne doit pas reconstruire cette hauteur par une
trajectoire classique.

Elle doit seulement nommer la hauteur de la fibre initiale :

```lean
def collatzInitialIndexFibreHeight (n : Nat) : Nat :=
  natEnrichedParityFibrewiseStructuralPeak n
```

Lecture :

```text
la sequence issue de n est la fibre indexee par n ;
la hauteur fibrewise de cette fibre est H(n).
```

Cette facade doit exposer :

```lean
collatzInitialIndexFibreHeight_eq_maximalRelaxedDivergence
collatzInitialIndexFibreHeight_eq_double_add_two
collatzInitialIndexFibreHeight_pos
collatzInitialIndexFibreHeightWitness
collatzInitialIndexFibreHeight_eq_countdownTerminalExcess
```

## Raccord countdown

La consommation countdown est deja disponible au niveau Nat enrichi :

```lean
natEnrichedParityFibrewiseStructuralPeak_eq_countdownTerminalExcess
```

Elle donne :

```text
H(k)
=
terminal excess du countdown canonique a l'index k + k.
```

Pour la fibre initiale `n` :

```text
H(n)
=
terminal excess du countdown canonique a l'index n + n.
```

Donc la hauteur fibrewise n'est pas une donnee ajoutee.
Elle vient avec son consommateur canonique.

## Rapport avec les intersections Collatz

La couche actuelle `Meta/Collatz/CountdownConsumptionBridge.lean` traite les
intersections enrichies.

Pour une intersection :

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

l'index active est :

```lean
formedPositiveExcessOfIntersection intersection
```

et le pic active est :

```lean
collatzFibrewiseStructuralPeak intersection
```

avec :

```lean
collatzFibrewiseStructuralPeak intersection =
  natEnrichedParityFibrewiseStructuralPeak
    (formedPositiveExcessOfIntersection intersection)
```

La nouvelle facade initiale complete cette lecture en partant directement de
l'index initial :

```text
n initial
-> k := n
-> H(k)
```

Elle ne remplace pas la couche par intersection.
Elle donne le point d'entree fibrewise pour une sequence nommee par son index
initial.

## Enonce conceptuel precise

Formulation correcte :

```text
Pour chaque entier initial n, la fibre Collatz indexee par n porte une hauteur
fibrewise H(n). Cette hauteur est produite par Nat enrichi, certifiee par un
temoin positif interne de diagonalisation, consommable par countdown, et
reinscriptible comme closing/forming.
```

Formulation a eviter :

```text
on a prouve par une trajectoire classique que H(n) est le maximum visible de
l'orbite numerique.
```

Le cadre ne cherche pas a obtenir ce resultat par une borne externe de
trajectoire. Il identifie la hauteur pertinente comme structure interne de la
fibre indexee.

## Implementation attendue

Fichier cible :

```text
Meta/Collatz/FibrewiseFlightHeight.lean
```

Import attendu :

```lean
import Meta.Arithmetic.CountdownRelaxedParity
```

Declarations attendues :

```lean
def collatzInitialIndexFibreHeight (n : Nat) : Nat :=
  natEnrichedParityFibrewiseStructuralPeak n
```

```lean
theorem collatzInitialIndexFibreHeight_eq_maximalRelaxedDivergence
    (n : Nat) :
    collatzInitialIndexFibreHeight n =
      natEnrichedParityMaximalRelaxedDivergence n := rfl
```

```lean
theorem collatzInitialIndexFibreHeight_eq_double_add_two
    (n : Nat) :
    collatzInitialIndexFibreHeight n = (n + n) + 2 :=
  natEnrichedParityFibrewiseStructuralPeak_eq_double_add_two n
```

```lean
theorem collatzInitialIndexFibreHeight_pos
    (n : Nat) :
    0 < collatzInitialIndexFibreHeight n :=
  natEnrichedParityFibrewiseStructuralPeak_pos n
```

```lean
def collatzInitialIndexFibreHeightWitness
    (n : Nat) :
    NatEnrichedParityPositiveInternalDiagonalWitness n :=
  natEnrichedParityFibrewiseStructuralPeakWitness n
```

```lean
theorem collatzInitialIndexFibreHeight_eq_countdownTerminalExcess
    (n : Nat) :
    collatzInitialIndexFibreHeight n =
      formedPositiveExcessOfIntersection
        (countdownTerminalIntersection (n + n)) :=
  natEnrichedParityFibrewiseStructuralPeak_eq_countdownTerminalExcess n
```

## Audit attendu

Le fichier Lean devra finir par :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeight
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeight_eq_double_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeightWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeight_eq_countdownTerminalExcess
/- AXIOM_AUDIT_END -/
```

Validation :

```text
lake env lean Meta/Collatz/FibrewiseFlightHeight.lean
lake env lean Meta.lean
```

## Formule courte

```text
Chaque sequence Collatz est nommee par son index initial n.
Dans le cadre, cet index est la fibre k := n.
Nat enrichi attache a cette fibre une hauteur H(k).
Cette hauteur porte la diagonale positive, se consomme par countdown,
et revient comme closing/forming.
```
