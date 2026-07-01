# Notation opératoire de la cellule diagonale

## 1. Principe

Le cadre ne prend pas le gap comme un simple écart.

Il le rend opératoire.

La forme centrale n’est pas :

```text
code(phi) -> ass(phi)
```

mais :

```text
formed -> shadow -> gap -> repair -> recovered -> outcome
```

La cellule diagonale locale est donc une structure de passage, de séparation et
de récupération.

---

## 2. Cellule opératoire

On note :

```text
C(phi)
```

la cellule opératoire portée par `phi`.

Définition :

```text
C(phi) :=
(
  formed(phi),
  shadow(phi),
  sameProjection(phi),
  separatedInterface(phi),
  repair(phi),
  recovered(phi),
  recovered_eq_formed(phi),
  outcome(phi)
)
```

Cette notation correspond au noyau formel :

```text
FormedReferentialClosure
```

---

## 3. Interface formée

```text
formed(phi)
```

désigne l’interface formée de la cellule.

Dans le code :

```text
formedInterface
```

C’est le pôle porteur de la réparation locale.

---

## 4. Shadow

```text
shadow(phi)
```

désigne le shadow de l’interface formée.

Dans le code :

```text
shadowInterface
```

Le shadow n’est pas un second objet indépendant.

Il est le pôle séparé corrélé au formé par la même projection visible.

---

## 5. Projection commune

```text
sameProjection(phi)
:
project(formed(phi)) = project(shadow(phi))
```

Dans le code :

```text
sameProjection
```

La projection visible identifie les deux pôles.

La structure enrichie les maintient séparés.

---

## 6. Séparation enrichie

```text
separatedInterface(phi)
:
formed(phi) = shadow(phi) -> False
```

Dans le code :

```text
separatedInterface
```

La cellule porte donc simultanément :

```text
même projection visible
+
séparation enrichie
```

C’est le gap opératoire minimal.

---

## 7. Témoin diagonal

Le témoin diagonal de la cellule est :

```text
Delta(phi) :=
DiagonalCertificate(formed(phi), shadow(phi), project)
```

avec :

```text
Delta(phi).sameProjection
= sameProjection(phi)

Delta(phi).separatedInterface
= separatedInterface(phi)
```

Le témoin diagonal ne constate pas seulement le gap.

Il porte la séparation qui rend la contraction impossible.

---

## 8. Obstruction projective

L’obstruction projective est produite par le témoin diagonal :

```text
Obs(phi) :=
projectionObstructionOfDiagonalCertificate(Delta(phi))
```

Elle porte :

```text
Obs(phi).left  = formed(phi)
Obs(phi).right = shadow(phi)
Obs(phi).sameProjection = sameProjection(phi)
Obs(phi).separatedInterface = separatedInterface(phi)
```

Elle exprime :

```text
la projection visible ne reconstruit pas l’interface enrichie
```

---

## 9. Réparation locale

```text
repair(phi)
```

désigne la réparation attachée à l’interface formée.

Dans le code :

```text
repair : RepairOf formedInterface
```

La réparation est indexée par le formé.

Elle n’est pas portée par le visible seul.

---

## 10. Récupération locale

La récupération locale complète est :

```text
R(phi) :=
LocalProjectiveRecovery(formed(phi), shadow(phi), project, RepairOf)
```

Elle porte :

```text
R(phi).formed = formed(phi)
R(phi).shadow = shadow(phi)
R(phi).sameProjection = sameProjection(phi)
R(phi).separated = separatedInterface(phi)
R(phi).repair = repair(phi)
R(phi).recovered = recovered(phi)
R(phi).recovered_eq_formed = recovered_eq_formed(phi)
```

Dans la cellule :

```text
recovered_eq_formed(phi)
:
recovered(phi) = formed(phi)
```

La récupération locale ne supprime pas le gap.

Elle ramène localement la structure vers le formé.

---

## 11. Outcome

```text
outcome(phi)
```

désigne le résultat porté par l’interface formée.

Dans le code :

```text
outcome : OutcomeOf formedInterface
```

Le résultat dépend du formé.

Il n’est pas un résultat détaché de la cellule.

---

## 12. Forme contractée

La forme contractée oublie la médiation opératoire :

```text
contract(C(phi)) :=
project(formed(phi))
```

Dans le vocabulaire classique, cela se lit comme :

```text
code(phi) -> ass(phi)
```

Mais cette lecture contracte :

```text
shadow
sameProjection
separatedInterface
repair
recovered
outcome dépendant du formé
```

---

## 13. Gap trivial

Le gap est trivial lorsque la projection visible suffit à reconstruire
l’interface enrichie :

```text
ContractibleReferentialGap Interface Visible project
```

Dans ce cas :

```text
visible -> interface
```

est déjà fidèle.

---

## 14. Gap non trivial

Le gap est structurel lorsque la cellule porte :

```text
sameProjection
+
separatedInterface
```

Dans le code :

```text
StructuralReferentialGap Interface Visible project
```

Le gap devient opératoire lorsque cette séparation porte aussi une réparation :

```text
OperationalReferentialGap Interface Visible project RepairOf
```

---

## 15. Non-reconstruction

La cellule opératoire produit :

```text
noProjectiveReconstructionOfFormedReferentialClosure(C(phi))
```

Elle refute aussi :

```text
formedReferentialClosure_notFiberFaithful
formedReferentialClosure_notInformationConserving
```

Donc la cellule ne dit pas seulement :

```text
il y a un gap
```

Elle dit :

```text
le gap empêche la reconstruction projective uniforme
```

---

## 16. Tarski

Tarski apparaît comme la forme limite contractée :

```text
Tarski(phi) :=
contract(C(phi))
```

La lecture tarskienne voit :

```text
code(phi) -> ass(phi)
```

La cellule opératoire porte :

```text
formed(phi)
-> shadow(phi)
-> sameProjection(phi)
-> separatedInterface(phi)
-> repair(phi)
-> recovered(phi)
-> outcome(phi)
```

Donc Tarski n’est pas le point de départ du cadre.

Il est un cas contracté de l’usage opératoire du gap.

---

## 17. Formule centrale

```text
C(phi)
=
formed
+ shadow
+ sameProjection
+ separatedInterface
+ repair
+ recovered
+ recovered_eq_formed
+ outcome
```

La projection classique voit seulement :

```text
project(formed)
```

Le cadre enrichi conserve la cellule opératoire complète.
