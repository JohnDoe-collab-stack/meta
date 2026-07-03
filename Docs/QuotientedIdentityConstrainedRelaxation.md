# Identite quotientee et relaxation contrainte

## Objet

Ce document fixe la theorie generale qui se degage du cadre Meta.

L'objectif n'est pas de renommer la couche `OOD`. L'objectif est plus
fondamental :

```text
interface
-> projection
-> lecture
-> identite quotientee
-> diagonalisation
-> obstruction de reconstruction
-> temoin positif interne
-> relaxation contrainte
```

La couche `OOD` devient alors une instance particuliere de cette theorie :
elle decrit un changement de regime visible. La theorie elle-meme porte sur la
maniere dont une interface produit une identite observable par quotient.

## Noyau theorique

Le cadre repose sur quelques primitives minimales.

### 1. Espace de phenomenes

```text
X
```

`X` est l'espace interne du phenomene.

### 2. Projection

Une interface contient d'abord une projection :

```text
q : X -> V
```

Elle envoie un phenomene interne vers une representation visible.

La projection ne lit pas encore le phenomene. Elle expose seulement une forme
visible du phenomene.

### 3. Lecture

Une interface contient aussi une lecture :

```text
read : V -> L
```

La lecture interprete la representation visible produite par la projection.

On distingue donc :

```text
q : X -> V
```

et :

```text
read ∘ q : X -> L
```

La projection produit une representation visible.

La lecture produit une valeur, une mesure, une etiquette, un score ou une
interpretation a partir de cette representation.

Cette distinction est centrale : le quotient peut etre pose au niveau de la
projection `q`, ou a un niveau plus pauvre, au niveau de la lecture
`read ∘ q`.

### 4. Identite quotientee

Deux etats :

```text
x, y : X
```

peuvent etre identifies par projection lorsque :

```text
q(x) = q(y)
```

Cette egalite est une identite relative au quotient projectif, pas forcement
une identite interne.

On peut aussi avoir une identite plus faible au niveau de la lecture :

```text
read(q(x)) = read(q(y))
```

Dans ce cas, deux etats peuvent produire la meme lecture, meme si leurs
representations visibles ne sont pas entierement identiques.

### 5. Separation interne

On peut avoir :

```text
x != y
```

meme si l'interface les identifie.

Autrement dit, deux etats peuvent etre structurellement differents tout en
etant traites comme identiques par le quotient.

### 6. Diagonalisation projective

La situation diagonale minimale est :

```text
x != y
```

mais :

```text
q(x) = q(y)
```

L'interface impose une identite visible entre deux etats structurellement
distincts.

La diagonalisation montre alors que l'identite produite par l'interface
n'epuise pas l'identite interne du phenomene.

### 7. Obstruction de reconstruction

Il n'existe pas de reconstruction parfaite :

```text
r : V -> X
```

telle que, pour tout :

```text
x : X
```

on ait :

```text
r(q(x)) = x
```

Autrement dit, l'interface a detruit de l'information structurelle.

Ce qui a ete quotiente ne peut pas etre reconstruit depuis la seule
representation visible.

### 8. Temoin positif interne

Il existe un temoin interne :

```text
w
```

verifiant une propriete positive :

```text
P(w)
```

ou, dans un cas arithmetique :

```text
0 < w
```

Ce temoin certifie qu'il reste une difference structurelle non nulle que le
quotient visible ne capture pas.

Il ne vient pas de la lecture exterieure. Il est porte par la structure interne
du phenomene.

### 9. Relaxation contrainte

Relaxer consiste a modifier la projection, la lecture, ou l'interface afin de
reveler davantage de structure.

Mais cette relaxation n'est pas arbitraire : elle doit conserver ou exposer le
temoin positif interne `w`.

La relaxation admissible est donc un changement de quotient sous contrainte
d'un invariant positif interne.

On ne relaxe pas pour produire n'importe quelle nouvelle representation. On
relaxe parce qu'un temoin positif interne indique que le quotient initial etait
trop contracte.

Dans le vocabulaire Lean du projet, on ne doit pas utiliser les quotients Lean
`Quot`. La theorie doit rester constructive et projective :

```lean
project : Interface -> Visible
read : Visible -> Label
```

L'identite quotientee projective est portee par :

```lean
project formed = project shadow
```

L'identite quotientee lue est portee par :

```lean
read (project formed) = read (project shadow)
```

et non par un objet `Quot`.

## Identite quotientee

Une projection fixe une relation d'indiscernabilite projective :

```text
x ~q y  iff  q x = q y
```

Une lecture fixe une relation d'indiscernabilite interpretee :

```text
x ~read,q y  iff  read(q x) = read(q y)
```

Donc l'identite observable peut etre relative a la projection, ou relative a la
lecture de cette projection.

Elle dit :

```text
ces deux etats sont identiques pour cette interface
```

Elle ne dit pas :

```text
ces deux etats sont identiques dans la structure
```

Le point central est donc :

```text
identite visible
!=
identite interne
```

## Diagonalisation

La diagonalisation projective apparait lorsqu'une meme projection identifie
deux roles internes separes.

Forme abstraite :

```text
formed != shadow
q formed = q shadow
```

Dans le code existant, ce noyau est deja porte par :

```lean
DiagonalCertificate Interface Visible project
```

dans :

```text
Meta/Core/ClosedStabilityTheorem.lean
```

La projection visible identifie :

```lean
sameProjection : project formed = project shadow
```

mais la structure separe :

```lean
separatedInterface : formed = shadow -> False
```

Cette situation produit une obstruction :

```lean
ProjectionObstruction Interface Visible project
```

et donc l'echec d'une reconstruction projective globale :

```lean
noProjectiveReconstruction
```

Il existe aussi une diagonalisation plus pauvre au niveau de la lecture :

```text
formed != shadow
read(q formed) = read(q shadow)
```

Cette version expose une indiscernabilite de lecture. Elle ne donne pas
necessairement une indiscernabilite projective `q formed = q shadow`.

## Probleme du quotient trop precoce

Quotienter trop tot signifie traiter l'identite visible comme si elle etait une
identite interne.

Le probleme n'est pas seulement une perte d'information. Le probleme est plus
precis :

```text
une interface impose une identite
qui peut effacer une difference structurelle encore active
```

Une interface pauvre peut donc produire une identite vraie dans la
representation, mais fausse comme identite interne.

La black box commence ici :

```text
une interface rend identiques des etats que la structure distingue
```

## Temoin positif interne

Une diagonalisation negative dit :

```text
on ne peut pas reconstruire toute la structure depuis la projection
```

Le cadre Meta ajoute une exigence plus forte :

```text
il existe un temoin positif interne conserve par la structure
```

Ce temoin ne vient pas de la projection visible. Il est porte par la cellule
interne et survit au passage par l'interface.

Dans le code actuel, la forme abstraite la plus proche est :

```lean
OODPositiveWitnessTransport
OODPositiveInvariant
```

dans :

```text
Meta/OOD/WitnessTransport.lean
```

Le dernier point est crucial :

```lean
invariant = witnessOfCell
witnessIn = invariant
witnessOut = invariant
0 < invariant
```

Donc le visible peut changer, mais le temoin positif reste transporte.

## Relaxation contrainte

Relaxer ne signifie pas inventer une autre representation.

Relaxer signifie relacher une projection ou une lecture trop contractee sous la
contrainte d'un temoin positif interne.

Forme conceptuelle :

```text
projection ou lecture initiale trop contractee
-> diagonalisation
-> obstruction de reconstruction
-> temoin positif interne
-> relaxation admissible
```

La relaxation admissible n'est pas libre. Elle doit respecter ou exposer le
temoin positif.

Dans la couche OOD actuelle, cette idee est portee par :

```lean
OODProjectionShift
OODRecoveredCell
OODPositiveWitnessTransport
OODPositiveInvariant
OODPositiveStructuralCertificate
```

Mais ces noms sont encore applicatifs. La theorie generale devrait extraire
ces notions sous des noms plus fondamentaux.

## Traduction Lean visee

La theorie devrait etre extraite dans un fichier nouveau, par exemple :

```text
Meta/Core/QuotientedIdentity.lean
```

ou, pour eviter toute confusion avec `Quot` :

```text
Meta/Core/ProjectedIdentity.lean
```

Le nom recommande est :

```text
Meta/Core/ProjectedIdentity.lean
```

Le noyau formel attendu :

```lean
structure ProjectedIdentityCell
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) where
  formed : Interface
  shadow : Interface
  sameVisible : project formed = project shadow
  separated : formed = shadow -> False
```

La version lue doit etre separee :

```lean
structure ReadIdentityCell
    (Interface : Type u)
    (Visible : Type v)
    (Label : Type w)
    (project : Interface -> Visible)
    (read : Visible -> Label) where
  formed : Interface
  shadow : Interface
  sameRead :
    read (project formed) = read (project shadow)
  separated : formed = shadow -> False
```

Puis :

```lean
def diagonalCertificateOfProjectedIdentityCell :
  DiagonalCertificate Interface Visible project
```

et :

```lean
def projectionObstructionOfProjectedIdentityCell :
  ProjectionObstruction Interface Visible project
```

Ensuite la couche positive :

```lean
structure PositiveProjectedInvariant
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (Witness : Type w)
    (Positive : Witness -> Prop) where
  cell : ProjectedIdentityCell Interface Visible project
  witness : Witness
  witness_pos : Positive witness
```

Pour le cas `Nat`, on pourra specialiser :

```lean
Witness := Nat
Positive witness := 0 < witness
```

Enfin la relaxation contrainte :

```lean
structure ConstrainedProjectionRelaxation
    (Interface : Type u)
    (VisibleIn : Type v)
    (VisibleOut : Type w)
    (Label : Type z)
    (projectIn : Interface -> VisibleIn)
    (projectOut : Interface -> VisibleOut)
    (readIn : VisibleIn -> Label)
    (readOut : VisibleOut -> Label)
    (Witness : Type a)
    (Positive : Witness -> Prop) where
  formed : Interface
  shadow : Interface
  sameIn : projectIn formed = projectIn shadow
  sameOut : projectOut formed = projectOut shadow
  visibleShift :
    readIn (projectIn formed) = readOut (projectOut formed) -> False
  separated : formed = shadow -> False
  invariant : Witness
  invariant_pos : Positive invariant
```

Cette structure dira :

```text
la relaxation change le regime projectif,
elle peut produire un shift de lecture,
mais conserve un temoin positif interne
```

## Raccord avec la couche OOD existante

La couche actuelle :

```text
Meta/OOD/WitnessTransport.lean
```

devrait devenir une instance ou une facade specialisee de la theorie generale.

Correspondance :

```text
OODProjectionShift
  -> relaxation entre deux projections visibles

OODRecoveredCell
  -> cellule projetee avec recuperation locale

OODPositiveWitnessTransport
  -> transport du temoin positif

OODPositiveInvariant
  -> invariant positif interne

OODPositiveStructuralCertificate
  -> paquet complet : obstruction + invariant positif
```

La theorie generale doit donc etre en amont de `OOD`.

## Raccord avec l'arithmetique enrichie

L'instance :

```text
Meta/Arithmetic/RelaxedOddOOD.lean
```

montre deja un cas concret :

```text
formed = closingExcess k
shadow = mediatingValue k
same projection
separation interne
shift visible
temoin positif relaxe
invariant positif transporte
```

Point important :

```text
2*k + 1
```

n'est pas la definition de l'impair relaxe. C'est une lecture visible source
contractee. L'impair relaxe est porte par la structure enrichie et par son
temoin positif.

## These centrale

Formule longue :

```text
Une interface produit une identite quotientee.
Cette identite peut etre projective ou lue.
Elle peut identifier visiblement deux etats que la structure distingue.
La diagonalisation expose cette difference comme obstruction projective.
Une relaxation admissible relache alors le quotient, non arbitrairement,
mais sous la contrainte d'un temoin positif interne conserve.
```

Formule courte :

```text
Une interface produit une identite quotientee.
Cette identite peut etre posee au niveau de la projection ou de la lecture.
Une relaxation admissible relache ce quotient sous la contrainte
d'un temoin positif interne de diagonalisation.
```

## Notation mathematique

Cette section donne la theorie sous forme mathematique, independamment des
noms Lean.

### 1. Interface projective et lecture

On fixe trois types ou ensembles :

```text
X = espace interne du phenomene
V = espace visible de representation
L = espace de lecture
```

Une interface contient une projection :

```text
q : X -> V
```

et une lecture :

```text
read : V -> L
```

On distingue donc :

```text
q : X -> V
```

et :

```text
read ∘ q : X -> L
```

La projection expose une representation visible. La lecture interprete cette
representation.

La projection induit une relation d'indiscernabilite projective :

```text
x ~_q y  <=>  q(x) = q(y)
```

La lecture induit une relation d'indiscernabilite lue :

```text
x ~_{read,q} y  <=>  read(q(x)) = read(q(y))
```

Ces relations ne sont pas l'identite interne sur `X`. Elles sont des identites
produites par l'interface.

### 2. Identite quotientee

Une identite quotientee projective est une paire :

```text
(x, y) in X x X
```

telle que :

```text
q(x) = q(y)
```

On peut donc ecrire :

```text
Id_q(x, y) := q(x) = q(y)
```

Cette identite est relative a `q`.

Une identite quotientee lue est plus faible :

```text
Id_read,q(x, y) := read(q(x)) = read(q(y))
```

On peut avoir :

```text
Id_read,q(x, y)
```

sans avoir necessairement :

```text
Id_q(x, y)
```

Donc une lecture peut contracter davantage que la projection.

### 3. Identite quotientee separee

Le cas diagonal apparait lorsque l'identite quotientee coexiste avec une
separation interne :

```text
x != y
q(x) = q(y)
```

On note :

```text
Diag_q(x, y) :=
  (q(x) = q(y)) and (x != y)
```

Au niveau de la lecture, on note :

```text
Diag_read,q(x, y) :=
  (read(q(x)) = read(q(y))) and (x != y)
```

La diagonalisation projective implique une diagonalisation de lecture si les
lectures sont appliquees a la meme projection :

```text
Diag_q(x, y) -> Diag_read,q(x, y)
```

mais la reciproque n'est pas garantie.

Dans le vocabulaire du cadre :

```text
x = formed
y = shadow
```

Donc :

```text
Diag_q(formed, shadow)
```

signifie :

```text
q(formed) = q(shadow)
formed != shadow
```

La forme lue :

```text
Diag_read,q(formed, shadow)
```

signifie :

```text
read(q(formed)) = read(q(shadow))
formed != shadow
```

### 4. Obstruction de reconstruction

Une reconstruction projective globale serait une application :

```text
r : V -> X
```

telle que :

```text
forall z in X, r(q(z)) = z
```

Une diagonalisation separee interdit une telle reconstruction.

En effet, si :

```text
q(x) = q(y)
```

alors une reconstruction globale donnerait :

```text
r(q(x)) = x
r(q(y)) = y
```

mais comme :

```text
q(x) = q(y)
```

on obtient :

```text
r(q(x)) = r(q(y))
```

donc :

```text
x = y
```

ce qui contredit :

```text
x != y
```

Ainsi :

```text
Diag_q(x, y) -> not exists r : V -> X,
  forall z in X, r(q(z)) = z
```

Au niveau de la lecture, une reconstruction globale depuis la lecture serait :

```text
s : L -> X
```

telle que :

```text
forall z in X, s(read(q(z))) = z
```

Une diagonalisation lue separee interdit cette reconstruction depuis `L` :

```text
Diag_read,q(x, y) -> not exists s : L -> X,
  forall z in X, s(read(q(z))) = z
```

Donc il y a deux niveaux possibles d'obstruction :

```text
obstruction projective : depuis V
obstruction lue        : depuis L
```

Dans le code, c'est exactement le contenu de :

```text
DiagonalCertificate -> ProjectionObstruction -> noProjectiveReconstruction
```

### 5. Temoin positif interne

On introduit un espace de temoins :

```text
W
```

et une notion de positivite :

```text
P : W -> Prop
```

Un temoin positif interne associe a une diagonalisation est une donnee :

```text
w in W
```

telle que :

```text
P(w)
```

et telle que `w` est porte par la structure interne, non reconstruit depuis la
projection visible.

On note :

```text
PosDiag_q(x, y, w) :=
  Diag_q(x, y) and P(w)
```

Dans le cas numerique du cadre :

```text
W = Nat
P(w) := 0 < w
```

### 6. Relaxation contrainte

Une relaxation compare deux regimes projectifs :

```text
q_in  : X -> V_in
q_out : X -> V_out
```

Le meme couple interne peut etre contracte par les deux projections :

```text
q_in(x)  = q_in(y)
q_out(x) = q_out(y)
```

tout en restant separe dans `X` :

```text
x != y
```

La relaxation n'est admissible que si elle transporte un temoin positif
interne :

```text
w in W
P(w)
```

On note :

```text
Relax(q_in, q_out, x, y, w) :=
  q_in(x) = q_in(y)
  and q_out(x) = q_out(y)
  and x != y
  and P(w)
```

Ce n'est pas encore suffisant : il faut aussi que le meme temoin soit conserve
entre les deux lectures.

On introduit donc deux lectures internes du temoin :

```text
w_in  : W
w_out : W
```

et l'invariant positif est :

```text
w_in = w
w_out = w
P(w)
```

On note :

```text
InvRelax(q_in, q_out, x, y, w, w_in, w_out) :=
  Relax(q_in, q_out, x, y, w)
  and w_in = w
  and w_out = w
```

Le point central est :

```text
q_in et q_out peuvent donner des lectures visibles differentes,
mais le temoin positif interne reste invariant.
```

### 7. Shift visible

Dans les applications OOD, on ajoute des lectures visibles :

```text
read_in  : V_in -> L
read_out : V_out -> L
```

Le shift visible est l'ecart :

```text
read_in(q_in(x)) != read_out(q_out(x))
```

Mais le shift visible ne produit pas l'invariant. Il expose seulement que la
lecture visible a change de regime.

La forme complete est donc :

```text
q_in(x) = q_in(y)
q_out(x) = q_out(y)
x != y
read_in(q_in(x)) != read_out(q_out(x))
w_in = w
w_out = w
P(w)
```

Autrement dit :

```text
shift visible
+ invariant positif interne
```

### 8. Enonce synthetique

Theorie de l'identite quotientee :

```text
Une interface (q, read) produit des identites observables :
  ~_q
  ~_{read,q}
Ces identites peuvent identifier des etats internes separes.
Une telle separation produit une obstruction de reconstruction depuis V ou L.
Si un temoin positif interne w est transporte a travers une relaxation
de projection et de lecture, alors la relaxation est contrainte par w.
```

Forme compacte :

```text
q(x) = q(y), x != y
=> obstruction(q)

read(q(x)) = read(q(y)), x != y
=> obstruction(read ∘ q)

q_in(x) = q_in(y),
q_out(x) = q_out(y),
read_in(q_in(x)) != read_out(q_out(x)),
x != y,
P(w),
w_in = w = w_out
=> relaxation contrainte par invariant positif
```

## Ce qui est deja prouve

Dans `Meta/Core/ClosedStabilityTheorem.lean` :

```text
DiagonalCertificate
ProjectionObstruction
noProjectiveReconstruction
LocalProjectiveRecovery
```

Dans `Meta/OOD/WitnessTransport.lean` :

```text
OODProjectionShift
OODRecoveredCell
OODWitnessTransport
OODPositiveWitnessTransport
OODPositiveInvariant
OODStructuralCertificate
OODPositiveStructuralCertificate
```

Dans `Meta/Arithmetic/RelaxedOddOOD.lean` :

```text
natEnrichedRelaxedOddOODStructuralCertificate
natEnrichedRelaxedOddOODPositiveStructuralCertificate
natEnrichedRelaxedOddOODPositiveInvariant
```

Ces fichiers prouvent deja que :

```text
une cellule peut porter deux roles internes separes,
identifies par projection,
avec obstruction de reconstruction,
et avec un invariant positif transporte.
```

## Ce qui reste a extraire

Il reste a creer une couche Lean plus fondamentale :

```text
Meta/Core/ProjectedIdentity.lean
```

Cette couche doit :

1. nommer l'identite projetee ;
2. montrer que la diagonalisation est une identite projetee separee ;
3. extraire l'obstruction de reconstruction ;
4. nommer le temoin positif interne ;
5. nommer la relaxation contrainte ;
6. montrer que `OODPositiveInvariant` est une instance de cette relaxation.

La regle de discipline :

```text
pas de Quot
pas de quotient Lean
pas de propext
pas de Classical
pas d'axiome
```

Tout doit rester sous forme projective constructive :

```lean
project : Interface -> Visible
```
