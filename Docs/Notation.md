# Notation enrichie de la cellule diagonale

## 1. Forme classique

```text
code(phi) -> ass(phi)
```

Symboles :

```text
phi        := phrase locale
code(phi) := projection syntaxique visible de phi
ass(phi)  := lecture assertive de phi
```

## 2. Forme enrichie

```text
D_r(phi) :=
[0 : code(phi) -> 1 : M_r(phi) -> 2 : ass(phi)]
```

avec :

```text
M_r(phi) :=
(I_r(phi), G_r(phi), Delta_r(phi), R_r(phi))
```

Symboles :

```text
r        := référentiel local
D_r(phi) := cellule diagonale locale de phi dans r
M_r(phi) := médiation locale de phi dans r
```

## 3. Médiation

```text
I_r(phi)      := interface locale de phi dans r
G_r(phi)      := gap de projection porté par I_r(phi)
Delta_r(phi)  := témoin diagonal porté par G_r(phi)
R_r(phi)      := récupération locale portée par I_r(phi)
```

## 4. Gap

```text
G_r(phi) :=
(sameProjection_r(phi), separatedInterface_r(phi))
```

avec :

```text
sameProjection_r(phi)
:
project(left_r(phi)) = project(right_r(phi))

separatedInterface_r(phi)
:
left_r(phi) = right_r(phi) -> False
```

Symboles :

```text
left_r(phi)               := interface formée de la cellule D_r(phi)
right_r(phi)              := shadow de la cellule D_r(phi)
project                   := projection vers le visible
sameProjection_r(phi)     := égalité visible des deux interfaces
separatedInterface_r(phi) := séparation enrichie des deux interfaces
```

## 5. Témoin diagonal

```text
Delta_r(phi) :=
DiagonalCertificate(left_r(phi), right_r(phi), project)
```

donc :

```text
Delta_r(phi).sameProjection
= sameProjection_r(phi)

Delta_r(phi).separatedInterface
= separatedInterface_r(phi)
```

Symbole :

```text
DiagonalCertificate(left, right, project)
:=
(left, right, sameProjection, separatedInterface)
```

## 6. Obstruction

```text
Obs_r(phi) :=
ProjectionObstruction(Delta_r(phi))
```

donc :

```text
Obs_r(phi).sameProjection
= Delta_r(phi).sameProjection

Obs_r(phi).separatedInterface
= Delta_r(phi).separatedInterface
```

Symboles :

```text
Obs_r(phi) := obstruction projective portée par Delta_r(phi)
ProjectionObstruction(Delta) :=
(Delta.sameProjection, Delta.separatedInterface)
```

## 7. Récupération locale

```text
R_r(phi) :=
LocalProjectiveRecovery(left_r(phi), right_r(phi), project)
```

avec :

```text
R_r(phi).formed = left_r(phi)
R_r(phi).shadow = right_r(phi)
R_r(phi).sameProjection = sameProjection_r(phi)
R_r(phi).separated = separatedInterface_r(phi)
```

Symbole :

```text
LocalProjectiveRecovery(left, right, project)
:=
(formed, shadow, sameProjection, separated, repair)
```

## 8. Projection contractée

```text
partial_02(D_r(phi)) :=
(code(phi), ass(phi))
```

et :

```text
partial_02([0 -> 1 -> 2]) = [0 -> 2]
```

Symbole :

```text
partial_02 := projection contractée qui oublie la position 1
```

## 9. Gap trivial

```text
G_r(phi) ~= 0
:=
ContractibleReferentialGap(left_r(phi), right_r(phi), project)
```

Symbole :

```text
ContractibleReferentialGap(left, right, project)
:=
la projection visible suffit à reconstruire l’interface enrichie
```

Forme contractée :

```text
D_r(phi) / G_r(phi) ~= 0
=
code(phi) -> ass(phi)
```

## 10. Gap non trivial

```text
G_r(phi) !~= 0
:=
StructuralReferentialGap(left_r(phi), right_r(phi), project)
```

Forme opératoire :

```text
G_r(phi) operational
:=
OperationalReferentialGap(left_r(phi), right_r(phi), project, RepairOf)
```

Symboles :

```text
StructuralReferentialGap(left, right, project)
:=
sameProjection + separatedInterface

RepairOf(left_r(phi))
:=
réparation locale indexée par l’interface formée

OperationalReferentialGap(left, right, project, RepairOf)
:=
StructuralReferentialGap + RepairOf(left)
```

## 11. Tarski

```text
Tarski(phi)
:=
partial_02(D_r(phi))
```

Donc :

```text
Tarski(phi)
=
code(phi) -> ass(phi)
```

et :

```text
D_r(phi)
=
Tarski(phi) + M_r(phi)
```

## 12. Clôture diagonale

```text
D_r(A, x) :=
[0 : A -> 1 : M_r(A, x) -> 2 : x]
```

avec :

```text
M_r(A, x) :=
(I_r(A, x), G_r(A, x), Delta_r(A, x), R_r(A, x))
```

Symboles :

```text
A          := source locale
x          := cible locale
D_r(A, x)  := cellule diagonale locale reliant A à x dans r
M_r(A, x)  := médiation locale entre A et x dans r
I_r(A, x)  := interface locale entre A et x
G_r(A, x)  := gap de projection porté par I_r(A, x)
Delta_r(A, x) := témoin diagonal porté par G_r(A, x)
R_r(A, x)  := récupération locale portée par I_r(A, x)
```

## 13. Appartenance à la clôture

```text
x in Cl_Delta(A)
:=
exists r, D_r(A, x)
```

c’est-à-dire :

```text
x in Cl_Delta(A)
<=>
exists r,
[0 : A -> 1 : M_r(A, x) -> 2 : x]
```

Symboles :

```text
Cl_Delta(A) := clôture diagonale de A
x in Cl_Delta(A) := x appartient à la clôture diagonale de A
exists r := il existe un référentiel local r
```

## 14. Formule centrale

```text
code(phi) -> ass(phi)
```

est la projection contractée de :

```text
code(phi) -> M_r(phi) -> ass(phi)
```

avec :

```text
M_r(phi)
=
(interface, gap, témoin diagonal, récupération locale)
```
