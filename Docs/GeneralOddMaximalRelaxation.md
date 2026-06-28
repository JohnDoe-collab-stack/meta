# Impair general et relaxation maximale

## Objet

Ce document fixe la lecture correcte de l'impair general dans le cadre Meta.

La notion visee n'est pas une classe numerique. Elle n'est pas un codage. Elle
est une structure operationnelle de mediation.

Formule centrale :

```text
impair general
=
mediation strictement relaxee
+
asymetrie maximale
```

La consequence attendue est :

```text
impair general
-> divergence maximale
-> temoin positif de diagonalisation interne
```

## Interdit de lecture

Il ne faut pas lire l'impair general comme un code numerique.

La forme numerique usuelle correspond au regime non relaxe et symetrique.
Elle ne porte donc pas l'impair general.

Dans cette analyse, utiliser cette forme comme guide detruit l'information
principale :

```text
relaxation
asymetrie
divergence maximale
```

Donc la lecture correcte est :

```text
impair general
≠
forme numerique non relaxee
```

La forme non relaxee est une contraction. Elle ne doit pas servir de modele.

## Structure de l'impair general

L'impair general doit porter au minimum :

```text
role mediateur
raccord gauche
raccord droit
relaxation du raccord
asymetrie entre les raccords
divergence interne
```

Le role mediateur n'est pas seulement une position entre deux bornes. Il est
une mediation capable de porter une difference entre ses deux raccords.

La relaxation signifie :

```text
les deux raccords ne sont pas forces a se contracter
dans une meme unite symetrique.
```

L'asymetrie signifie :

```text
les deux cotes de la mediation ne jouent pas le meme role
et ne doivent pas etre identifies.
```

## Relaxation stricte

L'impair general est strictement relaxe.

Cela signifie que la relaxation n'est pas une option ajoutee apres coup. Elle
fait partie de la notion.

Donc une structure qui force la mediation a revenir au regime non relaxe ne
decrit pas l'impair general. Elle decrit une contraction de celui-ci.

Formulation :

```text
impair general
=
mediation dont la relaxation est constitutive
```

## Asymetrie maximale

L'impair general n'est pas seulement relaxe. Il est relaxe a son maximum.

Cela signifie :

```text
la divergence entre les deux raccords est portee comme donne centrale
et non comme ecart accidentel.
```

Le maximum ici n'est pas une hauteur de trajectoire. Ce n'est pas une borne
globale externe. C'est une maximalite interne de la mediation.

Formulation :

```text
maximum
=
maximum de relaxation/asymetrie du role mediateur
```

## Divergence maximale

La divergence maximale est la difference interne produite par l'asymetrie
maximale de la mediation relaxee.

Elle doit etre comprise comme :

```text
divergence maximale
=
ecart maximal productible entre le raccord gauche et le raccord droit
de l'impair general
```

Cette divergence n'est pas une valeur ajoutee depuis l'exterieur.

Elle est produite par :

```text
role mediateur strictement relaxe
+
asymetrie maximale
```

C'est precisement pour cette raison que Nat enrichi relaxe ce point : il faut
laisser apparaitre l'ecart maximal entre `left` et `right`, au lieu de forcer
les deux raccords dans une mediation non relaxee.

Cette relaxation ne signifie pas que l'on retrouve la forme numerique non
relaxee. Elle signifie exactement l'inverse :

```text
divergence maximale
=
cas ou la mediation ne se contracte pas dans la forme non relaxee
```

## Temoin positif de diagonalisation interne

Le vrai temoin positif de diagonalisation interne doit venir de cette
divergence maximale.

La chaine correcte est :

```text
impair general strictement relaxe
-> asymetrie maximale
-> divergence maximale
-> temoin positif de diagonalisation interne
```

Le temoin ne doit pas etre obtenu en prenant un support isole puis en lui
appliquant une diagonalisation Nat generique.

Le temoin doit exprimer que :

```text
la divergence maximale du role mediateur produit elle-meme
le point de diagonalisation positif.
```

## Difference avec une diagonalisation generique

Une diagonalisation generique de Nat peut donner :

```text
support
-> canonicalIntersection support
-> positive excess
```

Mais cette chaine ne suffit pas pour l'impair general.

Elle ne montre pas que le support vient de la relaxation maximale du role
mediateur. Elle ne montre pas que la diagonalisation est produite par la
divergence interne.

La bonne exigence est donc :

```text
pas seulement :
prendre un support isole et le diagonaliser apres coup

mais :
divergence maximale du mediateur -> temoin positif
```

## Consequence pour Collatz

Pour Collatz, la branche a comprendre ne doit pas etre lue comme une branche
sur une classe numerique.

Elle doit etre lue comme une action sur :

```text
impair general
=
mediation relaxee asymetrique maximale
```

Le point a formaliser est donc :

```text
la transformation Collatz exploite la divergence maximale
du role mediateur relaxe.
```

La cible n'est pas de recoder la branche. La cible est :

```text
exhiber la divergence maximale
et montrer qu'elle est le temoin positif de diagonalisation interne.
```

## Forme Lean attendue

La structure a viser doit separer les niveaux :

```lean
structure GeneralOddRelaxedMediation (Role : Type) where
  mediatorRole : Role
  leftLink : Role
  rightLink : Role
  relaxation : Prop
  asymmetry : Prop
  maximality : Prop
```

Le nom exact reste a fixer dans le code. Le point important est que la
structure doit porter distinctement, sans recoder le role mediateur comme
payload numerique :

```text
role mediateur
raccord gauche
raccord droit
relaxation
asymetrie
maximalite
```

Puis le vrai theoreme cible doit avoir la forme :

```lean
theorem positiveDiagonalWitness_of_maximalRelaxedMediation
    {Role : Type}
    (odd : GeneralOddRelaxedMediation Role) :
    PositiveInternalDiagonalWitness odd
```

La cible n'est pas encore de fournir ce code. La cible de ce document est de
fixer la lecture afin d'eviter de reconstruire une contraction non relaxee.

## Formule courte

```text
L'impair general est une mediation strictement relaxee et asymetrique.
Sa relaxation maximale produit une divergence maximale.
Cette divergence maximale est le vrai temoin positif de diagonalisation interne.
```
