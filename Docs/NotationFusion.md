# Notation enrichie de la cellule diagonale

## 1. Idée générale

Dans le cadre classique, le schéma de Tarski met directement en relation deux pôles :

- le code syntaxique d’une phrase ;
- la phrase prise comme assertion.

Le cadre enrichi refuse cette relation directe comme forme première.

Il introduit une médiation explicite entre les deux pôles :

```text
code -> interface-gap-témoin-récupération -> assertion
```

Cette chaîne est appelée une cellule diagonale locale.

---

## 2. Cellule diagonale locale

On note :

```text
D_r(phi)
```

la cellule diagonale locale associée à la phrase `phi` dans le référentiel local `r`.

Définition :

```text
D_r(phi) :=
[0 : code(phi) -> 1 : M_r(phi) -> 2 : ass(phi)]
```

où :

```text
M_r(phi) :=
(I_r(phi), G_r(phi), Delta_r(phi), R_r(phi))
```

Lecture :

> Dans le référentiel local `r`, le code de `phi` passe par une médiation qui porte une interface, un gap, un témoin diagonal et une récupération locale, puis arrive à `phi` comme assertion.

---

## 3. Symboles de base

### `phi`

`phi` désigne une phrase formelle.

Une phrase formelle est un énoncé complet du langage, c’est-à-dire une formule sans variable libre.

Exemple :

```text
0 = 0
```

### `r`

`r` désigne un référentiel local.

Le cadre ne suppose pas de référentiel global absolu.

Chaque lecture se fait depuis un référentiel local déterminé.

### `code(phi)`

`code(phi)` désigne le code syntaxique de `phi`.

C’est `phi` vue comme objet formel manipulable.

### `ass(phi)`

`ass(phi)` désigne `phi` comme phrase assertée.

C’est `phi` prise du côté de ce qu’elle affirme.

---

## 4. Positions de la cellule

La cellule :

```text
D_r(phi) :=
[0 : code(phi) -> 1 : M_r(phi) -> 2 : ass(phi)]
```

contient trois positions ordonnées :

```text
0 -> 1 -> 2
```

Ces nombres ne sont pas des quantités. Ce sont des positions.

- `0` est le pôle de départ ;
- `1` est la médiation ;
- `2` est le pôle d’arrivée.

---

## 5. Médiation

La médiation est :

```text
M_r(phi) :=
(I_r(phi), G_r(phi), Delta_r(phi), R_r(phi))
```

avec :

```text
I_r(phi)     := interface locale de phi dans r
G_r(phi)     := gap de projection porté par I_r(phi)
Delta_r(phi) := témoin diagonal du gap G_r(phi)
R_r(phi)     := récupération locale portée par I_r(phi)
```

---

## 6. Interface formée et shadow

La cellule porte deux interfaces enrichies :

```text
left_r(phi)  := interface formée
right_r(phi) := shadow de l’interface formée
```

Elles sont reliées par une projection visible :

```text
project : interface enrichie -> visible
```

---

## 7. Gap

Le gap est :

```text
G_r(phi) :=
(sameProjection_r(phi), separatedInterface_r(phi))
```

avec :

```text
sameProjection_r(phi) :
project(left_r(phi)) = project(right_r(phi))

separatedInterface_r(phi) :
left_r(phi) = right_r(phi) -> False
```

Lecture :

> Le gap signifie que deux interfaces enrichies distinctes ont la même projection visible.

---

## 8. Témoin diagonal

Le témoin diagonal est :

```text
Delta_r(phi) :=
DiagonalCertificate(left_r(phi), right_r(phi), project)
```

Il porte exactement :

```text
Delta_r(phi).sameProjection
= sameProjection_r(phi)

Delta_r(phi).separatedInterface
= separatedInterface_r(phi)
```

Lecture :

> Le témoin diagonal atteste que le gap n’est pas accidentel : il est porté par une séparation structurée entre l’interface formée et son shadow.

---

## 9. Obstruction projective

À partir du témoin diagonal, on obtient :

```text
Obs_r(phi) :=
ProjectionObstruction(Delta_r(phi))
```

avec :

```text
Obs_r(phi).sameProjection
= Delta_r(phi).sameProjection

Obs_r(phi).separatedInterface
= Delta_r(phi).separatedInterface
```

Lecture :

> L’obstruction projective dit que la projection visible ne suffit pas à reconstruire l’interface enrichie.

---

## 10. Récupération locale

La récupération locale est :

```text
R_r(phi) :=
LocalProjectiveRecovery(left_r(phi), right_r(phi), project)
```

Elle porte :

```text
R_r(phi).formed = left_r(phi)
R_r(phi).shadow = right_r(phi)
R_r(phi).sameProjection = sameProjection_r(phi)
R_r(phi).separated = separatedInterface_r(phi)
```

Lecture :

> La récupération locale ne supprime pas le gap ; elle réinscrit localement l’interface formée.

---

## 11. Projection classique

On note :

```text
partial_02
```

la projection qui garde seulement les positions `0` et `2`.

Elle oublie la position `1`.

Donc :

```text
partial_02(D_r(phi)) =
(code(phi), ass(phi))
```

et :

```text
partial_02([0 -> 1 -> 2]) =
[0 -> 2]
```

Lecture :

> La présentation classique ne voit que le code et l’assertion. Elle efface l’interface, le gap, le témoin diagonal et la récupération locale.

---

## 12. Gap trivial

On écrit :

```text
G_r(phi) ~= 0
```

pour dire que le gap est trivial.

Cela signifie :

```text
ContractibleReferentialGap(left_r(phi), right_r(phi), project)
```

Lecture :

> La projection visible suffit à reconstruire l’interface enrichie.

Dans ce cas, la cellule enrichie revient à la présentation classique :

```text
code(phi) -> ass(phi)
```

---

## 13. Gap non trivial

On écrit :

```text
G_r(phi) !~= 0
```

pour dire que le gap est non trivial.

Cela signifie :

```text
StructuralReferentialGap(left_r(phi), right_r(phi), project)
```

Dans le cas opératoire :

```text
OperationalReferentialGap(left_r(phi), right_r(phi), project, RepairOf)
```

Lecture :

> L’interface porte une médiation réelle : la projection visible contracte une structure plus riche.

---

## 14. Tarski

Le schéma classique de Tarski correspond à la forme contractée de la cellule enrichie :

```text
Tarski(phi) :=
partial_02(D_r(phi))
```

donc :

```text
Tarski(phi) =
code(phi) -> ass(phi)
```

alors que :

```text
D_r(phi) =
code(phi) -> M_r(phi) -> ass(phi)
```

Lecture :

> Tarski apparaît comme le cas où la médiation diagonale est lue après projection contractée.

---

## 15. Application à la clôture

Pour la clôture, on utilise une cellule analogue.

On note :

```text
D_r(A, x)
```

la cellule diagonale locale reliant une source `A` à un élément `x`.

Définition :

```text
D_r(A, x) :=
[0 : A -> 1 : M_r(A, x) -> 2 : x]
```

où :

```text
M_r(A, x) :=
(I_r(A, x), G_r(A, x), Delta_r(A, x), R_r(A, x))
```

Lecture :

> Dans le référentiel local `r`, la source `A` est reliée à `x` par une interface qui porte un gap, son témoin diagonal et sa récupération locale.

---

## 16. Clôture diagonale

On note :

```text
Cl_Delta(A)
```

la clôture diagonale de `A`.

Définition :

```text
x in Cl_Delta(A)
:=
exists r, D_r(A, x)
```

Autrement dit :

```text
x in Cl_Delta(A)
<=>
exists r,
[0 : A -> 1 : M_r(A, x) -> 2 : x]
```

Lecture :

> `x` appartient à la clôture de `A` lorsqu’il existe une chaîne ordonnée source -> interface-gap-témoin-récupération -> cible qui relie `A` à `x`.

---

## 17. Formule centrale du cadre

La forme fondamentale n’est pas :

```text
code <-> assertion
```

mais :

```text
code -> interface-gap-témoin-récupération -> assertion
```

La clôture n’est donc pas une clôture par vérité globale.

Elle est une clôture par interface locale portant un gap, son témoin diagonal et sa récupération.
