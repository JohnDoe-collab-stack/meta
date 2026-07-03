# Identite quotientee par interface

## Objet

Ce document fixe la forme minimale de l'identite quotientee produite par une
interface.

On part d'une projection :

```text
q : X -> V
```

`X` est l'espace interne.

`V` est l'espace visible expose par l'interface.

## Identite interne

L'identite interne est l'egalite propre a `X` :

```text
Id_X(x, y) := (x = y)
```

Elle dit que deux etats sont identiques dans la structure interne elle-meme.

## Identite produite par l'interface

L'interface produit une autre relation d'identite :

```text
Id_q(x, y) := (q(x) = q(y))
```

Cette identite ne dit pas que `x` et `y` sont identiques dans `X`.

Elle dit seulement que `x` et `y` sont indiscernables par l'interface `q`.

## Quotient associe

En notation mathematique externe, on peut associer a cette relation un quotient :

```text
pi_q : X -> X / Id_q
pi_q(x) = [x]_q
```

Alors :

```text
Id_q(x, y)
```

implique :

```text
pi_q(x) = pi_q(y)
```

## Cellule diagonale projective

La cellule centrale du cadre est :

```text
not Id_X(x, y) and Id_q(x, y)
```

c'est-a-dire :

```text
x != y
mais
q(x) = q(y)
```

Deux etats restent separes dans `X`, mais sont identifies par l'interface.

## Deplacement de l'identite utilisee

Le deplacement consiste a utiliser l'identite produite par l'interface :

```text
Id_use := Id_q
```

au lieu de l'identite interne :

```text
Id_use := Id_X
```

La formule centrale est donc :

```text
Id_use := Id_q != Id_X
```

L'egalite utilisee n'est plus l'egalite interne. C'est l'egalite produite par
l'interface.

## Forme diagonale

On peut exprimer la meme idee par les diagonales :

```text
Delta_X = { (x, y) | x = y }

Delta_q = { (x, y) | q(x) = q(y) }

Delta_use := Delta_q
```

avec :

```text
Delta_q \ Delta_X != empty
```

Autrement dit, il existe des couples identifies par l'interface mais separes
dans la structure interne.

Formule courte :

```text
Delta_use := Delta_q != Delta_X
```

## Discipline Lean

Sous Lean, le cadre evite de construire directement le quotient :

```text
X / Id_q
```

et evite donc de dependre de `Quot`.

La formalisation constructive garde seulement l'effet quotientant de la
projection :

```lean
project formed = project shadow
formed = shadow -> False
```

La cellule Lean correspond donc a :

```text
Id_q(formed, shadow)
and
not Id_X(formed, shadow)
```

mais sans introduire l'objet quotient `X / Id_q`.

## Formule finale

```text
Une interface produit une identite quotientee.

Cette identite peut identifier deux etats que la structure interne separe.

Le cadre utilise cette identite projective comme identite operatoire, tout en
conservant explicitement la separation interne.
```
