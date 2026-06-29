# Countdown et regime de fermeture

## Objet

Ce document fixe la lecture du countdown dans le cadre :

```text
1 + gap + 1
```

Le but est de comprendre le countdown avant de le raccorder a un autre regime.
Le countdown ne doit pas etre lu seulement comme une descente numerique. Dans
le cadre, il donne une forme de fermeture dynamique.

## Countdown classique

La lecture classique du countdown est :

```text
n
n - 1
n - 2
...
1
0
```

Dans le code, cette lecture est portee par :

```lean
countdownStep : Nat -> Nat
```

avec :

```lean
countdownStep 0 = 0
countdownStep (n + 1) = n
```

La propriete de base est :

```lean
natTrajectory_countdown_at_self n :
  natTrajectory countdownStep n n = 0
```

Donc, classiquement :

```text
n est une quantite a epuiser ;
apres n pas, la trajectoire atteint 0.
```

Cette lecture est correcte, mais elle est courte. Elle voit la descente. Elle
ne montre pas encore la structure de fermeture.

## Le point terminal n'est pas seulement une fin

Le code ne s'arrete pas a :

```text
temps n : valeur 0
```

Il ajoute le temps suivant :

```lean
natTrajectory_countdown_after_self n :
  natTrajectory countdownStep n (n + 1) = 0
```

Donc le terminal apparait deux fois :

```text
temps n     : premiere occurrence terminale
temps n + 1 : repetition terminale
```

La collision terminale explicite est :

```lean
countdownTerminalWindowCollision n
```

avec :

```lean
leftOffset  = n
rightOffset = n + 1
same_value  = 0 = 0
```

La fermeture ne vient donc pas seulement du fait que la descente atteint `0`.
Elle vient du fait que le terminal est stabilise par une repetition.

## Le role du 2

Le countdown porte une fenetre de longueur :

```text
n + 2
```

Cette longueur se decompose comme :

```text
n pas de descente
+
1 premiere occurrence terminale
+
1 repetition terminale
=
n + 2
```

Donc :

```text
2 = premiere occurrence terminale + repetition terminale
```

Dans cette lecture, le `2` n'est pas seulement un nombre. Il est la double borne
minimale qui permet de reconnaitre une fermeture dynamique :

```text
pole terminal gauche
+
pole terminal droit
```

Le countdown classique ecrase souvent cette structure en simple fin de
processus. La lecture enrichie garde les deux poles.

## Forme 1 + gap + 1

La collision terminale donne la forme :

```text
1 + gap + 1
```

avec :

```text
1 gauche = premiere occurrence terminale
gap      = temps de descente jusqu'au terminal
1 droit  = repetition terminale
```

Dans le countdown pur :

```text
gap = n
```

et la fenetre totale est :

```text
1 + n + 1 = n + 2
```

Cette formule ne doit pas etre lue comme une simple addition externe. Elle dit
que la fermeture dynamique possede deux poles explicites et une mediation
consommee entre eux.

## Exces terminal

Le fichier `CountdownDynamicGap.lean` prouve :

```lean
countdownTerminalExcess_eq_n_plus_two
```

c'est-a-dire :

```lean
formedPositiveExcessOfIntersection
  (repeatedIndexIntersection ...)
=
n + 2
```

Donc l'exces terminal du countdown n'est pas seulement `n`. Il est :

```text
n + 2
```

Autrement dit :

```text
matiere de descente
+
double borne terminale
```

Le countdown donne deja une instance ou l'exces terminal porte une fermeture a
deux poles.

## Gap dynamique et gap arithmetique

Le countdown traverse deux lectures du gap.

Lecture dynamique :

```text
retour terminal
collision d'index
intersection repetee
```

Lecture arithmetique :

```text
formedPositiveExcessOfIntersection = n + 2
closingExcess (n + 2)
mediatingValue (n + 2)
```

Le fichier `CountdownGapContraction.lean` expose notamment :

```lean
countdownTerminalClosingRole_eq_n_plus_two
countdownTerminalMediatingRole_eq_n_plus_two
```

Donc le meme index `n + 2` porte deux roles enrichis :

```text
closingExcess (n + 2)
mediatingValue (n + 2)
```

Le visible peut contracter ces deux roles vers un meme payload, mais la couche
enrichie conserve leur difference de role.

## Ce que le countdown apporte

Le countdown apporte une forme modele de consommation :

```text
descente
terminal
repetition terminale
intersection
exces terminal
fermeture recuperee
```

Il ne produit pas seulement une borne. Il produit une fermeture dynamique
complete a partir d'une collision terminale explicite.

La ligne importante est :

```text
countdown = format interne de consommation d'un gap dynamique
```

## Ce qui reste a comprendre pour le regime relaxe

Le regime relaxe produit une diagonale positive interne.

Le countdown produit une fermeture terminale explicite.

Le raccord a comprendre est :

```text
diagonale positive relaxee
-> exces terminal
-> format countdown
-> fermeture dynamique
```

Il ne faut pas poser trop vite :

```text
diagonale = countdown
```

La formulation correcte est :

```text
la diagonale produit ou expose un exces positif ;
le countdown donne le format de consommation terminale de cet exces.
```

Le prochain travail conceptuel est donc :

```text
identifier comment l'exces positif porte par la diagonale relaxee
entre dans une structure de fermeture de type countdown.
```

## Formule courte

```text
Countdown classique :
n est une longueur a epuiser.

Countdown enrichi :
n + 2 est une fermeture :
n mediation consommee
+
2 poles terminaux.

Lecture 1 + gap + 1 :
premier terminal
+
gap de descente
+
repetition terminale.
```

