# Notation enrichie de la cellule diagonale

## 1. Idée générale

Dans le cadre classique, le schéma de Tarski met directement en relation deux pôles :

- le code syntaxique d’une phrase ;
- la phrase prise comme assertion.

Le cadre enrichi refuse cette relation directe comme forme première.

Il introduit une médiation explicite entre les deux pôles :

```text
code -> interface-gap-témoin -> assertion
```

Cette chaîne est appelée une cellule diagonale locale.

---

## 2. Définition de la cellule diagonale locale

On note :

```text
D_r(phi)
```

la cellule diagonale locale associée à la phrase `phi` dans le référentiel local `r`.

Définition :

```text
D_r(phi) :=
[0: code(phi) -> 1: (I_r_phi, g_r_phi, delta_r_phi) -> 2: ass(phi)]
```

Lecture :

> Dans le référentiel local `r`, le code de `phi` passe par une interface qui porte un gap et un témoin diagonal, puis arrive à `phi` comme assertion.

---

## 3. Définition des termes

### `phi`

`phi` désigne une phrase formelle.

Une phrase formelle est un énoncé complet du langage, c’est-à-dire une formule sans variable libre.

Exemple :

```text
0 = 0
```

---

### `code(phi)`

`code(phi)` désigne le code syntaxique de `phi`.

C’est `phi` vue comme objet formel manipulable.

En langage courant :

> le côté écriture, code, syntaxe, forme visible.

---

### `ass(phi)`

`ass(phi)` désigne `phi` comme phrase assertée.

C’est `phi` prise du côté de ce qu’elle affirme.

En langage courant :

> le côté énoncé, affirmation, assertion.

---

### `r`

`r` désigne un référentiel local.

Le cadre ne suppose pas de référentiel global absolu.

Chaque lecture se fait depuis un référentiel local déterminé.

---

### `D_r(phi)`

`D_r(phi)` désigne la cellule diagonale locale de `phi` dans le référentiel `r`.

Elle contient trois positions ordonnées :

```text
0 -> 1 -> 2
```

Ces nombres ne sont pas des quantités. Ce sont des positions.

- `0` est le pôle de départ ;
- `1` est la médiation ;
- `2` est le pôle d’arrivée.

---

### `I_r_phi`

`I_r_phi` désigne l’interface locale entre le code et l’assertion.

Elle dépend :

- du référentiel local `r` ;
- de la phrase `phi`.

En langage courant :

> l’interface est le lieu où le passage entre le code et l’assertion devient visible.

---

### `g_r_phi`

`g_r_phi` désigne le gap porté par l’interface.

Le gap est l’écart entre ce qui est visible dans la projection classique et ce qui est effectivement porté par la structure enrichie.

Important :

> `g_r_phi` n’est pas forcément un nombre. C’est un marqueur structurel d’écart.

---

### `delta_r_phi`

`delta_r_phi` désigne le témoin diagonal du gap.

Il atteste que le gap n’est pas accidentel, mais forcé par la diagonalisation.

En langage courant :

> le témoin diagonal prouve que l’écart est structurel.

---

## 4. Projection classique

On note :

```text
partial_02
```

la projection qui garde seulement les positions `0` et `2`.

Elle oublie la position `1`.

Donc :

```text
partial_02(D_r(phi)) = (code(phi), ass(phi))
```

Lecture :

> La présentation classique ne voit que le code et l’assertion. Elle efface l’interface, le gap et le témoin diagonal.

Le schéma classique de Tarski correspond donc à la forme contractée de la cellule enrichie.

---

## 5. Cas du gap trivial

On écrit :

```text
g_r_phi ~= 0
```

pour dire que le gap est trivial.

Cela signifie :

> l’interface ne porte pas de médiation réelle ; elle peut être contractée.

Dans ce cas, la cellule enrichie revient à la présentation classique :

```text
code(phi) -> ass(phi)
```

---

## 6. Cas du gap non trivial

On écrit :

```text
g_r_phi !~= 0
```

pour dire que le gap est non trivial.

Cela signifie :

> l’interface porte une médiation réelle.

Dans ce cas, la présentation classique contracte une structure plus riche :

```text
code(phi) -> interface-gap-témoin -> ass(phi)
```

---

## 7. Application à la clôture

Pour la clôture, on utilise une cellule analogue.

On note :

```text
D_r(A, x)
```

la cellule diagonale locale reliant une source `A` à un élément `x`.

Définition :

```text
D_r(A, x) :=
[0: A -> 1: (I_r_A_x, g_r_A_x, delta_r_A_x) -> 2: x]
```

Lecture :

> Dans le référentiel local `r`, la source `A` est reliée à `x` par une interface qui porte un gap et son témoin diagonal.

---

## 8. Définition de la clôture diagonale

On note :

```text
Cl_Delta(A)
```

la clôture diagonale de `A`.

Définition :

```text
x appartient à Cl_Delta(A)
si et seulement s’il existe une cellule D_r(A, x)
```

Autrement dit :

```text
x in Cl_Delta(A)
<=> il existe r tel que D_r(A, x) existe
```

Lecture :

> `x` appartient à la clôture de `A` lorsqu’il existe une chaîne ordonnée source -> interface-gap-témoin -> cible qui relie `A` à `x`.

---

## 9. Formule centrale du cadre

La forme fondamentale n’est pas :

```text
code <-> assertion
```

mais :

```text
code -> interface-gap-témoin -> assertion
```

La clôture n’est donc pas une clôture par vérité globale.

Elle est une clôture par interface locale portant un gap et son témoin diagonal.
