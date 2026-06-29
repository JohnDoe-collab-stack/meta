# Plan de reinsertion formee Collatz-countdown

## Objet

Le pont deja obtenu dit :

```text
temoin positif Collatz
=
exces terminal du countdown consommateur canonique
```

Ce document prepare le verrou suivant.

Il ne suffit pas que la divergence positive soit consommable. Il faut montrer
que cette consommation la reinscrit dans le pole forme/reparable du cadre.

La cible est donc :

```text
activation Collatz
-> divergence relaxee positive
-> consommation countdown canonique
-> retour comme closingExcess
-> regime forme/reparable
```

## Ce que l'on a deja

Pour une intersection Collatz :

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

on dispose de l'index forme :

```lean
k = formedPositiveExcessOfIntersection intersection
```

de la valeur diagonale positive :

```lean
W = collatzRelaxedPositiveDiagonalValueOfIntersection intersection
```

du consommateur countdown canonique :

```lean
collatzRelaxedCountdownConsumerIntersection intersection
```

et du pont :

```lean
collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess :
  W =
    formedPositiveExcessOfIntersection
      (collatzRelaxedCountdownConsumerIntersection intersection)
```

Donc le temoin positif active par Collatz est deja l'exces terminal du
consommateur countdown.

## Verrou suivant

Le verrou suivant n'est pas une nouvelle egalite numerique.

Il faut montrer que l'exces consomme revient comme role forme :

```text
closingExcess W
```

dans l'intersection countdown consommatrice.

Autrement dit :

```text
la divergence positive n'est pas seulement egale a une valeur terminale ;
elle est reinscrite dans le role closing/forming du consommateur.
```

## Theoreme de reinsertion formee

### Fichier cible

La reinsertion doit prolonger le pont deja existant :

```text
Meta/Collatz/CountdownConsumptionBridge.lean
```

Ce fichier possede deja :

```lean
collatzRelaxedCountdownConsumerIndex
collatzRelaxedCountdownConsumerIntersection
collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
```

La reinsertion ne doit donc pas creer une nouvelle couche. Elle doit completer
la couche qui relie deja Collatz au consommateur countdown.

### Portee exacte du quantificateur

Dans le code actuel, `intersection` designe :

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

Donc l'expression :

```text
toute activation Collatz
```

signifie rigoureusement :

```text
toute intersection enrichie sur laquelle la couche
Meta.Collatz.OperationalParity instancie l'action Collatz.
```

Ce n'est pas encore une quantification sur toutes les trajectoires numeriques
Collatz. Le resultat reste au niveau structurel-operatoire du cadre.

### Egalite principale

Le theoreme cible principal est :

```lean
theorem collatzRelaxedCountdownConsumer_closingRole_eq_positiveDiagonal
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) =
      NatEnrichedParityRole.closingExcess
        (collatzRelaxedPositiveDiagonalValueOfIntersection intersection)
```

Lecture :

```text
le consommateur countdown reinscrit le temoin positif Collatz
comme closingExcess.
```

Preuve attendue :

```lean
  rw [arithmeticClosingRoleOfIntersection_eq
    (collatzRelaxedCountdownConsumerIntersection intersection)]
  rw [Eq.symm
    (collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
      intersection)]
```

ou une variante equivalente, selon l'orientation des simplifications.

## Raccord au regime forme/reparable

Une fois le role closing obtenu, il faut le raccorder a la lecture Collatz deja
disponible :

```text
closing = formed
```

Le fichier `Meta/Collatz/OperationalParity.lean` contient deja :

```lean
collatzClosingRegime_eq_formedRegime
collatzOperationalParity_dynamicRepair
```

Le pont de reinsertion ne doit pas recreer ces faits. Il doit seulement exposer
que le role obtenu par consommation est de type `closingExcess`, donc situe du
cote forme/reparable de la parite operationnelle enrichie.

Theoreme/facade possible :

```lean
theorem collatzRelaxedCountdownConsumer_reenters_formingRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Exists (fun w : Nat =>
      w = collatzRelaxedPositiveDiagonalValueOfIntersection intersection /\
      arithmeticClosingRoleOfIntersection
          (collatzRelaxedCountdownConsumerIntersection intersection) =
        NatEnrichedParityRole.closingExcess w)
```

Cette facade evite d'ajouter une nouvelle notion de regime. Elle dit seulement :

```text
la valeur positive produite par Collatz reentre comme role closing.
```

Si l'existentiel est juge inutile, la premiere egalite suffit et reste plus
directe.

## Paquet de boucle structurelle

Pour rendre le resultat lisible, on peut ensuite regrouper les donnees dans un
paquet :

```lean
structure CollatzRelaxedCountdownReinsertion
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  positiveWitness : Nat
  positiveWitness_eq :
    positiveWitness =
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection
  consumer :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision
              (collatzRelaxedCountdownConsumerIndex intersection)))))
  consumer_eq :
    consumer =
      collatzRelaxedCountdownConsumerIntersection intersection
  consumed_as_terminal_excess :
    positiveWitness =
      formedPositiveExcessOfIntersection consumer
  reenters_as_closing :
    arithmeticClosingRoleOfIntersection consumer =
      NatEnrichedParityRole.closingExcess positiveWitness
```

Lecture :

```text
production positive
-> consommation terminale
-> reinsertion comme closingExcess
```

Ce paquet ne doit ajouter aucune hypothese. Il doit seulement regrouper les
theoremes deja obtenus.

## Ce que cela pretend demontrer

Le resultat ne pretend pas encore que toute trajectoire Collatz atteint `1`.

Il pretend demontrer ceci :

```text
toute activation Collatz de la diagonale relaxee positive
produit une divergence qui est
1. exactement consommable par un countdown canonique ;
2. reinscrite par ce consommateur comme role closing/forming.
```

Donc :

```text
la divergence activee sur le cote mediating/shadow
revient structurellement dans le cote closing/forming.
```

Ce n'est pas une borne, ni une probabilite, ni une terminaison aval.

C'est une boucle structurelle :

```text
shadow/mediating
-> divergence positive
-> consommation countdown
-> closing/forming
```

## Ce qu'il ne faut pas faire

La reinsertion ne doit pas utiliser :

```text
OddClassical
natEnrichedParityRoleCode
countdownTerminalMediatingCode
une hauteur de trajectoire
une hypothese de terminaison
une borne externe
un pont conditionnel
```

Elle doit venir uniquement de :

```text
collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
arithmeticClosingRoleOfIntersection_eq
la definition du consommateur countdown canonique
```

## Formule courte

```text
Collatz active une divergence positive.
Le countdown canonique la consomme comme exces terminal.
Cette consommation la reinscrit comme closingExcess.
Donc la divergence revient dans le pole forme/reparable.
```
