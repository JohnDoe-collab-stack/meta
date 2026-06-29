# Pont Collatz-countdown de consommation de la divergence relaxee

## Objet

Ce document fixe le prochain verrou conceptuel a formaliser.

La couche Collatz porte maintenant une instanciation de la diagonale relaxee :

```text
intersection Collatz
-> index forme k
-> divergence relaxee maximale
-> DiagonalCertificate core
-> ProjectionObstruction core
-> temoin positif
```

La couche countdown porte maintenant un format de consommation terminale :

```text
countdown terminal at m
-> terminal excess = m + 2
```

Le point a etablir est que le temoin positif active par Collatz possede un
consommateur countdown canonique.

## Principe

On ne doit pas chercher ce raccord par une estimation de trajectoire.

Le raccord attendu est une egalite structurelle de consommation :

```text
temoin positif Collatz
=
exces terminal countdown
```

Autrement dit :

```text
la divergence relaxee activee par Collatz
n'est pas une croissance libre ;
elle arrive avec un format exact de consommation terminale.
```

## Donnee Collatz

Pour une intersection :

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

l'index porte par Nat enrichi est :

```lean
k = formedPositiveExcessOfIntersection intersection
```

La diagonale relaxee Collatz donne :

```lean
collatzRelaxedPositiveDiagonalValueOfIntersection intersection
```

avec :

```lean
collatzRelaxedPositiveDiagonalValueOfIntersection intersection =
  natEnrichedParityMaximalRelaxedDivergence k
```

## Forme de la divergence relaxee

Dans Nat enrichi, la divergence maximale relaxee est definie par :

```lean
natEnrichedParityMaximalRelaxedDivergence k =
  Nat.succ (k + Nat.succ k)
```

Conceptuellement :

```text
Nat.succ (k + Nat.succ k)
=
k + k + 2
```

Donc le temoin positif Collatz a la forme :

```text
W(k) = k + k + 2
```

## Donnee countdown

Le countdown consomme un index `m` sous forme terminale :

```text
terminal excess at m = m + 2
```

Dans le code, cette forme est portee par :

```lean
formedPositiveExcessOfIntersection
  (countdownTerminalIntersection m)
```

avec la facade :

```lean
countdownArithmeticGapTerminalExcess_eq_n_plus_two
```

qui donne :

```text
formedPositiveExcessOfIntersection
  (countdownTerminalIntersection m)
=
m + 2
```

## Index consommateur canonique

Pour consommer :

```text
W(k) = k + k + 2
```

il faut prendre :

```text
m = k + k
```

Alors :

```text
terminal excess countdown at (k + k)
=
(k + k) + 2
=
W(k)
```

Donc le consommateur countdown canonique de la divergence relaxee Collatz est :

```lean
countdownTerminalIntersection (k + k)
```

avec :

```lean
k = formedPositiveExcessOfIntersection intersection
```

## Theoreme cible

### Fichier cible

Le pont ne doit pas etre ajoute dans `Meta.Arithmetic.CountdownRelaxedParity`.
Cette couche reste purement countdown.

Le bon emplacement est une couche Collatz dediee, par exemple :

```text
Meta/Collatz/CountdownConsumptionBridge.lean
```

avec les imports :

```lean
import Meta.Collatz.OperationalParity
import Meta.Arithmetic.CountdownRelaxedParity
```

Lecture :

```text
Collatz fournit le temoin positif ;
Countdown fournit le format terminal de consommation ;
le fichier pont raccorde les deux.
```

### Lemme arithmetique intermediaire

Avant le pont Collatz-countdown, il est plus propre d'exposer dans la couche
Nat enrichi le calcul structurel de la divergence relaxee :

```lean
theorem natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two
    (k : Nat) :
    natEnrichedParityMaximalRelaxedDivergence k = (k + k) + 2 := by
  unfold natEnrichedParityMaximalRelaxedDivergence
  omega
```

Ce lemme ne donne pas une lecture classique de l'impair. Il ne passe pas par
`2*k+1`. Il expose seulement la forme de consommation :

```text
divergence relaxee maximale = double mediation + deux poles terminaux.
```

Il doit etre audite dans `Meta/Arithmetic/Parity.lean` s'il est ajoute.

### Pont principal

Le premier theoreme structurel a viser est :

```lean
theorem collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzRelaxedPositiveDiagonalValueOfIntersection intersection =
      formedPositiveExcessOfIntersection
        (countdownTerminalIntersection
          (formedPositiveExcessOfIntersection intersection +
           formedPositiveExcessOfIntersection intersection))
```

Lecture :

```text
le temoin diagonal positif active par Collatz
est exactement l'exces terminal d'un countdown canonique.
```

Preuve attendue :

```lean
  rw [collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence]
  rw [countdownArithmeticGapTerminalExcess_eq_n_plus_two]
  rw [natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two]
```

avec :

```lean
k = formedPositiveExcessOfIntersection intersection
```

## Ce que cela prouve

Ce theoreme ne prouve pas encore la conjecture de Collatz.

Il prouve le verrou structurel suivant :

```text
activation Collatz
=
production d'une divergence positive relaxee

countdown
=
format terminal exact capable de consommer cette divergence
```

Donc :

```text
la divergence positive Collatz n'est pas sans forme ;
elle est deja raccordable a une fermeture terminale.
```

## Ce qu'il ne faut pas faire

Il ne faut pas remplacer ce theoreme par :

```text
une borne ;
une hauteur ;
une trajectoire aval ;
une hypothese de terminaison ;
un pont conditionnel ;
une lecture classique des impairs ;
un retour au code 2k+1.
```

Le theoreme doit etre inconditionnel.

Il doit seulement utiliser :

```text
la diagonale relaxee Collatz ;
la definition de la divergence relaxee maximale ;
le lemme structurel divergence = double mediation + 2 ;
le terminal excess countdown ;
```

Si une preuve a besoin de `OddClassical`, `natEnrichedParityRoleCode`,
`countdownTerminalMediatingCode`, d'une borne, d'une hauteur ou d'un pont
conditionnel, alors ce n'est pas le bon theoreme.

## Etape suivante

Une fois ce pont etabli, la question suivante sera plus forte :

```text
comment cette consommation countdown se reinsere-t-elle
dans la dynamique Collatz elle-meme ?
```

Mais ce n'est pas le premier verrou.

Le premier verrou est :

```text
temoin positif Collatz
=
exces terminal countdown canonique.
```

## Formule courte

```text
Collatz active une divergence relaxee positive.
Cette divergence vaut k + k + 2.
Le countdown consomme m sous la forme m + 2.
Avec m = k + k, le countdown consomme exactement la divergence Collatz.
```
