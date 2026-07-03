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

Pris seul, ce fait ne suffit pas encore a caracteriser le deplacement du
cadre. Il dit seulement que l'interface confond deux etats internes.

La forme :

```text
x != y
q(x) = q(y)
```

est donc seulement le support minimal.

Le point decisif apparait lorsque l'identite produite par l'interface devient
l'identite effectivement utilisee par le systeme.

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

Ainsi, la chaine complete est :

```text
1. X distingue x et y

   x != y

2. L'interface les confond

   q(x) = q(y)

3. On definit l'identite d'interface

   Id_q(x, y) := q(x) = q(y)

4. Le systeme utilise cette identite

   Id_use := Id_q

5. Donc le systeme traite x et y comme identiques

   Id_use(x, y)

   alors que X les separe.
```

Forme compacte :

```text
x != y
mais
Id_use(x, y)
```

avec :

```text
Id_use(x, y) := q(x) = q(y)
```

Le point important n'est donc pas seulement :

```text
l'interface perd une difference
```

mais :

```text
la difference interne devient une identite utilisee.
```

Autrement dit, une perte d'information visible devient une regle d'identite
operatoire, sans que la separation interne soit effacee du cadre.

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

Cette formule ne doit pas etre lue comme une simple non-injectivite de `q`.
Elle dit que la diagonale d'usage du systeme est la diagonale projective
`Delta_q`, alors meme que `Delta_q` contient des couples absents de la
diagonale interne `Delta_X`.

Le deplacement est :

```text
confusion visible
-> identite d'usage
```

avec conservation de :

```text
separation interne
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

La formalisation Lean encode donc la chaine longue :

```text
formed
+ identite projective utilisee
+ shadow
```

avec :

```text
formed != shadow
project formed = project shadow
```

Elle ne reduit pas la situation a une egalite interne. Elle garde ensemble :

```text
le pole forme
le pole shadow
l'identite visible
la separation interne
```

## Formule finale

```text
Une interface produit une identite quotientee.

Cette identite peut identifier deux etats que la structure interne separe.

Le point decisif est que cette identite quotientee devient l'identite d'usage
du systeme.

Une difference interne devient alors une identite utilisee.

Le cadre conserve explicitement la separation interne au lieu de la supprimer.
```
