# Egalite d'interface comme chaine constructive

## Objet

Ce document fixe la lecture dynamique de l'egalite d'interface.

Nom conceptuel utile :

```text
interface-induced observational equivalence
```

En francais :

```text
equivalence observationnelle induite par l'interface
```

Dans le code Lean, cette notion est portee par le nom technique
`ProjectedIdentity`. On ne renomme pas le noyau Lean : on clarifie sa lecture.

Le cadre part d'une projection :

```text
q : X -> V
```

et d'une cellule avec deux poles internes :

```text
x, y : X
```

La cellule porte deux donnees simultanees :

```text
separation interne : x != y
egalite projective : q(x) = q(y)
```

Le contenu important n'est pas seulement que `q` identifie deux poles.

Le contenu important est que l'egalite projective devient une identite d'usage
qui agit dans une chaine constructive.

Formule directrice :

```text
l'egalite quitte le niveau interne des poles ;
elle agit au niveau du mediateur projectif.
```

## Trois regimes d'identite

### Regime interne

L'identite interne est :

```text
Id_X(x, y) := (x = y)
```

Dans la cellule diagonale, les poles sont distincts :

```text
x != y
```

La structure interne conserve donc deux poles.

### Regime projectif

L'identite projective est :

```text
Id_q(x, y) := (q(x) = q(y))
```

Elle identifie les deux poles par leur image visible.

Elle est l'equivalence observationnelle induite par l'interface :

```text
x =_q y
```

Elle fournit le mediateur :

```text
q(x) = q(y)
```

### Regime d'usage

Le deplacement central est :

```text
Id_use := Id_q
```

L'identite utilisee dans la chaine est donc l'identite produite par
l'interface. Autrement dit, l'equivalence observationnelle induite par
l'interface devient l'identite operatoire de la chaine :

```text
Id_use(x, y) := q(x) = q(y)
```

La cellule complete porte :

```text
x != y
Id_use(x, y)
```

Elle conserve la separation interne tout en activant une identite d'usage.

## Chaine longue

La lecture contractee chercherait :

```text
x = y
```

La lecture longue garde la chaine :

```text
x  --q-->  q(x) = q(y)  <--q--  y
```

La structure portee est :

```text
pole gauche       : x
mediateur visible : q(x) = q(y)
pole droit        : y
separation        : x != y
identite d'usage  : Id_use := Id_q
```

Dans la notation du cadre :

```text
1 + gap + 1
```

les deux `1` sont les deux poles internes.

Le `gap` est organise par l'egalite projective utilisee comme mediateur.

## Dynamique de l'egalite

La forme statique de la cellule est :

```text
x != y
q(x) = q(y)
```

La forme dynamique est :

```text
q(x) = q(y)
-> Id_use(x, y)
-> transport par lecture
-> coordination de la chaine longue
```

Le signe egal dynamique encode donc une variation de regime :

```text
Id_X : regime interne des poles
Id_q : regime projectif de l'interface
Id_use := Id_q : regime effectivement utilise par la chaine
```

La variation porte sur le regime d'identite.

Elle garde les poles comme poles internes distincts.

Elle active leur coordination projective.

## Transport d'interface

Une lecture est une application :

```text
r : V -> L
```

A partir de :

```text
Id_use(x, y)
```

on obtient :

```text
r(q(x)) = r(q(y))
```

Le transport a type de lecture `L` fixe est :

```text
Transport_q^L(x, y) :=
  forall r : V -> L,
    r(q(x)) = r(q(y))
```

Le transport pleinement polymorphe est :

```text
Transport_q(x, y) :=
  forall {L} (r : V -> L),
    r(q(x)) = r(q(y))
```

Dans cette forme polymorphe :

```text
Transport_q(x, y) <-> Id_q(x, y)
```

La direction :

```text
Id_q(x, y) -> Transport_q(x, y)
```

vient de l'application de toute lecture `r`.

La direction :

```text
Transport_q(x, y) -> Id_q(x, y)
```

s'obtient avec :

```text
L := V
r := id
```

Ainsi :

```text
Id_q          = egalite projective
Transport_q  = meme egalite vue comme principe d'action
```

`Transport_q` n'ajoute pas une hypothese supplementaire.

Il deploie la puissance operatoire de `Id_q`.

Donc :

```text
interface-induced observational equivalence
=
Id_q vu comme regime d'egalite utilisable et transportable par lecture.
```

## Schema

```text
x          y
|          |
q          q
|          |
q(x) = q(y)
     |
  Id_use
     |
r(q(x)) = r(q(y))

avec x != y
```

Ce schema montre le point central :

```text
l'egalite projective transporte les lectures ;
la separation interne reste portee par la cellule.
```

Dans cette lecture, l'interdependance n'est pas une relation ajoutee apres
coup. Elle est produite par l'equivalence observationnelle induite par
l'interface : les poles restent separes, mais toute lecture factorisee par
l'interface les coordonne.

## Interdependance

L'interdependance a une signification precise :

```text
les poles restent separes dans X,
mais toute operation qui passe par l'interface respecte leur identite d'usage.
```

Elle combine :

```text
separation interne
+
co-indexation projective
+
transport par lecture
```

Elle transforme l'egalite visible en regle de coordination pour les lectures
admissibles.

## Ce qui est encode dans Lean

Dans `Meta/Core/ProjectedIdentity.lean`, la structure :

```lean
ProjectedIdentityCell Interface Visible project
```

porte :

```lean
formed
shadow
sameVisible : project formed = project shadow
separated   : formed = shadow -> False
```

Elle encode :

```text
separation interne
+
egalite projective
+
equivalence observationnelle induite par l'interface
```

La structure :

```lean
IdentityOfUseCell Interface Visible project
```

renomme l'egalite projective comme identite utilisee :

```lean
usedIdentity : InterfaceIdentityOfUse project formed shadow
```

avec :

```lean
InterfaceIdentityOfUse project formed shadow
  := project formed = project shadow
```

Le theoreme :

```lean
projectedIdentityCell_internalDifference_usedIdentity
```

donne :

```lean
(InternalIdentity project formed shadow -> False)
and
InterfaceIdentityOfUse project formed shadow
```

Il formalise :

```text
separation interne conservee
+
identite d'usage projective
```

Enfin :

```lean
readIdentityCellOfProjectedIdentityCell
```

encode le transport par lecture :

```text
project formed = project shadow
--------------------------------
read(project formed) = read(project shadow)
```

Le transport est donc deja present dans le noyau Lean.

## Contraintes de lecture

Le document doit conserver trois contraintes.

Premiere contrainte :

```text
Id_use := Id_q
```

Deuxieme contrainte :

```text
les poles internes restent distincts
```

Troisieme contrainte :

```text
les transports autorises passent par l'interface
```

La formule stabilisee est :

```text
Une egalite d'interface devient constructive lorsqu'elle est utilisee comme
identite d'usage entre deux poles internes distincts.
```

Forme compacte :

```text
x != y
Id_use(x, y)
Transport_q(x, y)

avec

Id_use := Id_q.
```

Forme conceptuelle :

```text
l'egalite visible est un mediateur operatoire ;
elle coordonne sans contracter.
```

## Facades Lean explicites

Le nom conceptuel :

```text
interface-induced observational equivalence
```

correspond dans Lean a :

```text
ProjectedIdentity
ProjectedIdentityCell
InterfaceIdentityOfUse
InterfaceTransport
```

Le noyau est code par :

```text
ProjectedIdentityCell
IdentityOfUseCell
ReadIdentityCell
readIdentityCellOfProjectedIdentityCell
```

Le transport d'interface est expose par :

```text
InterfaceReadTransport
InterfaceTransport
interfaceReadTransportOfProjectedIdentity
interfaceReadTransportOfIdentityOfUse
interfaceReadTransport_id_iff_projectedIdentity
interfaceTransportOfProjectedIdentity
projectedIdentityOfInterfaceTransport
interfaceTransport_iff_projectedIdentity
interfaceTransportOfIdentityOfUse
```

La chaine constructive est exposee par :

```text
projectedIdentityCell_readTransport
identityOfUseCell_readTransport
ConstructiveInterfaceChain
projectedIdentityCell_constructiveChain
identityOfUseCell_constructiveChain
projectedIdentityCell_interfaceTransport
identityOfUseCell_interfaceTransport
```

La dynamique de changement de regime pour une relaxation contrainte est exposee
par :

```text
constructiveChainInOfConstrainedRelaxation
constructiveChainOutOfConstrainedRelaxation
constrainedProjectionRelaxation_constructiveRegimeChange
```

Ainsi, la dynamique n'est pas seulement decrite dans le document :

```text
egalite projective
-> identite d'usage
-> transport
-> chaine constructive
-> changement de regime
```

Elle est exposee par des declarations nommees dans `ProjectedIdentity.lean`.
