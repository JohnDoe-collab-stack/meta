# Identite quotientee et relaxation contrainte

## Objet

Ce document fixe le noyau theorique abstrait suivant :

```text
interface
-> projection
-> lecture
-> identite quotientee
-> diagonalisation projective
-> obstruction de reconstruction
-> temoin positif interne
-> relaxation contrainte
```

Le point central est le suivant :

```text
une interface produit une identite observable par quotient ;
une relaxation admissible relache ce quotient sous la contrainte
d'un temoin positif interne porte par la cellule diagonale.
```

La couche `OOD` n'est donc pas la theorie generale. Elle devient une instance
ou une facade specialisee de cette theorie.

## Noyau mathematique

### Phenomenes

On fixe un espace interne de phenomenes :

```text
X
```

Un element :

```text
x : X
```

est un etat interne du phenomene.

### Projection

Une interface contient une projection :

```text
q : X -> V
```

Elle envoie un etat interne vers une representation visible.

La projection n'interprete pas encore ce qu'elle expose. Elle donne seulement
une forme visible.

### Lecture

Une interface peut aussi contenir une lecture :

```text
read : V -> L
```

La lecture interprete la representation visible.

On distingue donc strictement :

```text
q : X -> V
```

et :

```text
read o q : X -> L
```

La projection expose une representation visible.

La lecture produit une valeur, une etiquette, une mesure, un score ou une
interpretation a partir de cette representation.

Cette distinction est essentielle : l'identite peut etre imposee au niveau de
la projection, ou a un niveau plus pauvre, au niveau de la lecture.

## Identite quotientee

La projection induit une relation d'indiscernabilite :

```text
x ~q y  iff  q x = q y
```

La lecture induit une relation plus pauvre :

```text
x ~read,q y  iff  read(q x) = read(q y)
```

Donc une identite observable n'est pas forcement une identite interne.

Elle signifie :

```text
ces deux etats sont identiques pour cette interface
```

Elle ne signifie pas :

```text
ces deux etats sont identiques dans la structure
```

Le principe fondamental est :

```text
identite visible != identite interne
```

## Cellule diagonale

La situation diagonale minimale est donnee par deux etats :

```text
formed, shadow : X
```

tels que :

```text
formed != shadow
q formed = q shadow
```

La projection les identifie.

La structure interne les separe.

Cette cellule diagonale dit que l'interface impose une identite visible qui
n'epuise pas l'identite interne.

## Obstruction de reconstruction

Une cellule diagonale interdit une reconstruction projective parfaite.

Il n'existe pas de reconstruction :

```text
r : V -> X
```

telle que :

```text
forall x : X, r(q x) = x
```

La raison est directe : si `formed` et `shadow` ont la meme projection, une
reconstruction depuis `V` devrait produire le meme resultat pour les deux, alors
que la structure les separe.

Donc :

```text
q formed = q shadow
formed != shadow
--------------------------------
pas de reconstruction parfaite depuis V
```

## Temoin positif interne

Le cadre ne se contente pas d'une obstruction negative.

Pour une cellule diagonale :

```text
c := (formed, shadow, q formed = q shadow, formed != shadow)
```

on demande un type de temoins porte par la cellule :

```text
W(c)
```

et une propriete positive dependante de la cellule :

```text
P_c : W(c) -> Prop
```

Un temoin positif interne est alors :

```text
w : W(c)
P_c(w)
```

Ce temoin n'est pas externe. Il n'est pas ajoute apres coup. Il est porte par la
cellule diagonale elle-meme.

La forme arithmetique :

```text
0 < w
```

n'est qu'une specialisation possible. Le noyau abstrait ne depend pas de cette
specialisation.

## Relaxation contrainte

Relaxer ne signifie pas inventer une autre representation.

Relaxer signifie changer le regime projectif ou le regime de lecture afin de
laisser apparaitre une structure que le quotient precedent contractait.

Cette relaxation doit conserver un temoin positif interne.

Forme abstraite :

```text
cellule diagonale source c
temoin interne w : W(c)
P_c(w)
regime visible d'entree
regime visible de sortie
conservation explicite de w
```

La relaxation admissible est donc :

```text
un changement de quotient sous contrainte d'un temoin positif interne.
```

Elle n'est pas libre. Elle est justifiee par le fait que le quotient initial
contractait une difference structurelle deja certifiee par la cellule.

## Formalisation Lean actuelle

La formalisation actuelle est :

```text
Meta/Core/ProjectedIdentity.lean
```

Elle reste constructive et projective.

Elle n'utilise pas de quotient Lean `Quot`.

Elle formalise l'effet quotientant d'une projection par des egalites de
projection :

```lean
project formed = project shadow
```

et non par un objet quotient.

### Dependance architecturale

Le fichier `ProjectedIdentity.lean` est une extraction/facade core appuyee sur :

```text
Meta/Core/ClosedStabilityTheorem.lean
```

Il reutilise les briques deja formalisees :

```text
DiagonalCertificate
ProjectionObstruction
noProjectiveReconstruction
```

L'ordre architectural effectif est donc :

```text
ClosedStabilityTheorem
-> ProjectedIdentity
-> OOD / Arithmetic / Collatz / autres instances
```

Ce choix ne change pas le contenu conceptuel. Il signifie seulement que la
theorie de l'identite quotientee est extraite au-dessus d'un noyau core deja
present.

Une version plus invasive pourrait deplacer `DiagonalCertificate`,
`ProjectionObstruction` et `noProjectiveReconstruction` dans
`ProjectedIdentity.lean`, puis faire dependre `ClosedStabilityTheorem` de cette
couche. Ce refactor n'est pas requis pour stabiliser la theorie.

## Structures Lean principales

### Cellule projective

```lean
structure ProjectedIdentityCell
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) where
  formed : Interface
  shadow : Interface
  sameVisible : project formed = project shadow
  separated : formed = shadow -> False
```

Cette structure est la cellule diagonale projective :

```text
meme projection visible
separation interne
```

### Cellule lue

```lean
structure ReadIdentityCell
    (Interface : Type u)
    (Visible : Type v)
    (Label : Type w)
    (project : Interface -> Visible)
    (read : Visible -> Label) :
    Type (max u v w) where
  formed : Interface
  shadow : Interface
  sameRead :
    read (project formed) = read (project shadow)
  separated : formed = shadow -> False
```

Cette structure est plus pauvre :

```text
meme lecture
separation interne
```

Une cellule projective donne toujours une cellule lue, par composition avec
`read`.

La reciproque n'est pas posee.

### Obstruction

Le fichier fournit les raccords :

```lean
diagonalCertificateOfProjectedIdentityCell
projectionObstructionOfProjectedIdentityCell
noProjectiveReconstructionOfProjectedIdentityCell
```

et leurs variantes au niveau lecture :

```lean
diagonalCertificateOfReadIdentityCell
projectionObstructionOfReadIdentityCell
noProjectiveReconstructionOfReadIdentityCell
```

### Invariant positif

```lean
structure PositiveProjectedInvariant
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (WitnessOf : ProjectedIdentityCell Interface Visible project -> Type a)
    (Positive :
      (cell : ProjectedIdentityCell Interface Visible project) ->
        WitnessOf cell -> Prop) :
    Type (max u v (a + 1)) where
  cell : ProjectedIdentityCell Interface Visible project
  witness : WitnessOf cell
  witness_pos : Positive cell witness
```

Le temoin depend de la cellule.

Il n'est pas un parametre externe independant de la diagonalisation.

### Relaxation contrainte

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
    (WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a)
    (Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop) :
    Type (max u v w z (a + 1)) where
  sourceCell :
    ProjectedIdentityCell Interface VisibleIn projectIn
  sameOut : projectOut sourceCell.formed = projectOut sourceCell.shadow
  visibleShift :
    readIn (projectIn sourceCell.formed) =
      readOut (projectOut sourceCell.formed) -> False
  invariant : WitnessOf sourceCell
  invariant_pos : Positive sourceCell invariant
  witnessIn : WitnessOf sourceCell
  witnessOut : WitnessOf sourceCell
  witnessIn_eq : witnessIn = invariant
  witnessOut_eq : witnessOut = invariant
```

Cette structure dit exactement :

```text
la relaxation change le regime visible,
elle peut produire un shift de lecture,
mais elle conserve le temoin positif interne porte par la cellule source.
```

## Facades deja exposees

Le fichier `ProjectedIdentity.lean` expose les projections utiles d'une
relaxation contrainte :

```lean
projectedIdentityCellInOfConstrainedRelaxation
projectedIdentityCellOutOfConstrainedRelaxation
readIdentityCellInOfConstrainedRelaxation
readIdentityCellOutOfConstrainedRelaxation
positiveProjectedInvariantOfConstrainedRelaxation
projectionObstructionInOfConstrainedRelaxation
projectionObstructionOutOfConstrainedRelaxation
noProjectiveReconstructionInOfConstrainedRelaxation
noProjectiveReconstructionOutOfConstrainedRelaxation
constrainedProjectionRelaxation_witnessIn_eq_invariant
constrainedProjectionRelaxation_witnessOut_eq_invariant
```

Donc la relaxation donne immediatement :

```text
cellule projective entree
cellule projective sortie
cellule lue entree
cellule lue sortie
invariant positif porte par la cellule
obstruction entree
obstruction sortie
non-reconstruction entree
non-reconstruction sortie
conservation explicite du temoin
```

## Discipline formelle

La couche doit rester :

```text
constructive
projective
sans axiome
sans Classical
sans propext
sans Quot.sound
sans Quot
```

Le fichier Lean actuel respecte cette discipline.

Il contient un unique bloc :

```lean
/- AXIOM_AUDIT_BEGIN -/
...
/- AXIOM_AUDIT_END -/
```

place a la fin du fichier.

## Raccord avec OOD

Le raccord aval naturel est :

```text
OODProjectionShift
  -> changement de regime visible

OODRecoveredCell
  -> cellule projective specialisee

OODPositiveWitnessTransport
  -> transport du temoin positif

OODPositiveInvariant
  -> invariant positif specialise

OODPositiveStructuralCertificate
  -> certificat structurel positif specialise
```

Le travail a faire dans une couche aval n'est pas de modifier le noyau. Il est
de montrer que ces objets OOD sont des instances ou facades de
`ConstrainedProjectionRelaxation`.

## Formule finale

```text
Une interface produit une identite quotientee.

Une cellule diagonale expose une separation interne que cette identite
quotientee contracte.

Cette cellule produit une obstruction de reconstruction.

Une relaxation admissible relache le quotient sous la contrainte d'un temoin
positif interne porte par la cellule et conserve a travers le changement de
regime visible.
```
