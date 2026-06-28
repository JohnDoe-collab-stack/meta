# Temoin diagonal positif de vol Collatz

## Objet

Ce document fixe la lecture correcte du temoin diagonal positif attendu pour
Collatz dans le cadre Meta.

La construction doit respecter quatre niveaux distincts :

```text
1. divergence maximale locale propre a la fibre n ;
2. support de vol / hauteur complete lu depuis cette divergence ;
3. conversion vers le certificat generique Nat ;
4. temoin diagonal positif interne fourni par Nat enrichi.
```

Ces niveaux ne doivent pas etre melanges.

## Donnee Collatz reelle attendue

La source Collatz n'est pas une diagonale.

La source Collatz n'est pas non plus le calcul :

```text
3*k + 2
```

La source attendue n'est pas une hauteur nue. La source attendue est la
divergence maximale locale propre a une fibre initiale `n`.

Cette divergence maximale est le mecanisme interne qui produit le support de
vol de la fibre. La hauteur complete est donc une lecture du support produit
par cette divergence, pas une borne ajoutee de l'exterieur.

Formulation a conserver :

```text
divergence maximale locale propre a la fibre n
```

Formulation a eviter :

```text
Collatz fournit directement une hauteur globale
```

## Support de vol fibrewise

Forme visee :

```lean
structure CollatzVisibleFlightMaximum (n : Nat) where
  height : Nat
  peakTime : Nat
  peak_realizes_height :
    natTrajectory collatzStep n peakTime = height
  bounds_all :
    forall t : Nat, natTrajectory collatzStep n t <= height
```

Cette structure est indexee par `n`.

Elle ne donne donc pas une hauteur globale de Collatz. Elle donne une hauteur
complete propre a la trajectoire issue de `n`.

La donnee signifie :

```text
pour la fibre n,
height est realisee par la trajectoire,
et height borne tous les temps de cette meme trajectoire.
```

Formulation a conserver :

```text
hauteur complete propre a la fibre n
```

Formulation a eviter :

```text
hauteur globale de Collatz
```

Point de calibration :

```text
CollatzVisibleFlightMaximum n
```

est deja une donnee forte. Elle ne doit pas etre presentee comme produite
gratuitement par Collatz. Dans la route attendue, elle doit etre obtenue ou
remplacee par le paquet forme de divergence maximale locale :

```text
CollatzRoleDivergenceMaximum
```

Ce paquet doit porter :

```text
donnee fibrewise de role
raccord gauche
raccord droit
independance des deux raccords
relaxation locale du raccord concerne
support de hauteur produit par cette relaxation
```

Il ne doit pas seulement reprendre une hauteur deja donnee. Il doit expliquer
comment le support de hauteur est obtenu depuis une divergence de roles.

Le modele deja disponible dans Nat enrichi est :

```lean
NatEnrichedParityBilateralGap
```

avec deux champs separes :

```lean
leftStep : Nat
rightStep : Nat
```

Dans l'instance classique de Nat enrichi, les deux valent `1`, mais ils ne sont
pas identifies par la structure. C'est exactement cette absence d'identification
qu'il faut preserver pour Collatz.

Donc le futur paquet Collatz ne doit pas dire :

```text
leftStep = rightStep
```

Il doit au contraire isoler :

```text
leftStep
rightStep
support produit par le raccord relaxe
```

La divergence maximale locale est alors une donnee bilaterale relaxee. Elle
n'est pas une hauteur rebaptisee.

La phrase exacte devient :

```text
une fibre Collatz munie de sa divergence maximale locale fournit le support H(n)
```

et non :

```text
Collatz fournit directement le support H(n)
```

## Conversion vers le certificat generique Nat

A partir du support de hauteur produit par la divergence maximale locale de la
fibre `n`, on produit le certificat attendu par la couche `HeightDiagonal` :

```lean
NatTrajectoryFinitePrefixHeightCertificate collatzStep n
```

Le type Lean reel demande aussi un horizon et une preuve que le temps du pic
appartient a cet horizon :

```lean
horizon : Nat
peak_le_horizon : peakTime <= horizon
```

Pour transformer une hauteur complete de fibre en certificat Nat, le paquet
doit donc fournir un horizon.

Pour le temoin diagonal positif seul, le choix minimal est :

```lean
horizon := maximum.peakTime
```

La preuve `peak_le_horizon` est alors reflexive, et `bounds_prefix` est obtenu
en restreignant `bounds_all` :

```lean
height := maximum.height
horizon := maximum.peakTime
peakTime := maximum.peakTime
peak_le_horizon := Nat.le_refl maximum.peakTime
peak_realizes_height := maximum.peak_realizes_height
bounds_prefix := fun t _ => maximum.bounds_all t
```

Si la meme conversion doit aussi servir a produire une fenetre post-pic, il
faudra prendre un horizon plus long, par exemple :

```lean
horizon := maximum.peakTime + (maximum.height + 1)
```

Mais pour le temoin diagonal positif de hauteur, l'horizon minimal suffit : la
diagonale utilise le support realise au pic, pas une fenetre post-pic.

Le certificat obtenu n'invente pas un support. Il transporte dans la couche Nat
le support deja produit par la divergence maximale locale de la fibre :

```text
support = maximum.height
```

## Temoin diagonal positif interne

Une fois le certificat Nat obtenu, on applique la mecanique deja formalisee :

```lean
natTrajectoryPositiveDiagonalHeightWitness cert
```

Ce temoin porte :

```lean
support = cert.height
diagonalIntersection = canonicalIntersection support
positiveWitness =
  formedPositiveExcessOfIntersection diagonalIntersection
positiveWitness_pos
```

La diagonale positive vient donc de Nat enrichi, mais son support vient de la
divergence maximale locale de la fibre Collatz.

Le temoin `NatTrajectoryPositiveDiagonalHeightWitness` ne porte pas directement
un champ `DiagonalCertificate`. Il porte l'intersection diagonale et le temoin
positif. Le certificat diagonal strict s'extrait ensuite de cette intersection :

```lean
diagonalCertificateOfIntersection positiveDiagonal.diagonalIntersection
```

La chaine correcte est :

```text
CollatzRoleDivergenceMaximum
-> support H(n)
-> CollatzVisibleFlightMaximum n / certificat de hauteur fibrewise
-> NatTrajectoryFinitePrefixHeightCertificate collatzStep n
-> NatTrajectoryPositiveDiagonalHeightWitness
-> diagonalCertificateOfIntersection positiveDiagonal.diagonalIntersection
```

## Paquet final attendu

Le paquet final peut etre formule ainsi :

```lean
structure CollatzPositiveFlightDiagonalWitness (n : Nat) where
  roleDivergence :
    CollatzRoleDivergenceMaximum n
  maximum :
    CollatzVisibleFlightMaximum n
  support_eq_divergenceSupport :
    maximum.height = roleDivergence.support
  heightCert :
    NatTrajectoryFinitePrefixHeightCertificate collatzStep n
  heightCert_horizon_eq_peakTime :
    heightCert.horizon = maximum.peakTime
  heightCert_eq_maximum :
    heightCert.height = maximum.height
  positiveDiagonal :
    NatTrajectoryPositiveDiagonalHeightWitness heightCert
  diagonal :
    DiagonalCertificate
      (List NatTraceAtom)
      (List Nat)
      tracePayloads
  diagonal_eq :
    diagonal =
      diagonalCertificateOfIntersection
        positiveDiagonal.diagonalIntersection
```

Ce paquet dit exactement :

```text
la divergence maximale locale de la fibre Collatz n produit son support ;
Nat enrichi diagonalise ce support ;
le temoin positif interne est porte par canonicalIntersection maximum.height ;
le DiagonalCertificate est extrait explicitement de l'intersection diagonale.
```

Point verrouille dans l'implementation locale :

```text
roleDivergence.support
```

est un champ reel de `CollatzRoleDivergenceMaximum`. Dans
`Meta.Collatz.OperationalParity`, il est produit par le role droit relaxe via :

```lean
natEnrichedParityRolePayload (collatzShadowReturnRole n)
```

Il n'est donc pas une hauteur deja posee puis renommee.

## Point de rigueur

Il ne faut pas appeler diagonale Collatz :

```text
la branche 3*n+1 ;
le fait qu'un retour soit pair ;
le calcul 3*k+2 ;
un simple passage shadow -> closing.
```

La diagonale positive attendue est :

```text
support produit par la divergence maximale locale de la fibre Collatz n
-> canonicalIntersection support
-> positiveWitness > 0
-> diagonalCertificateOfIntersection de cette intersection
-> formedPositiveExcessOfIntersection > 0
```

Le role de Collatz n'est pas de donner directement une hauteur nue. Le role de
Collatz est de produire une divergence maximale locale propre a la fibre `n`.
Cette divergence maximale fournit le support.

Le role de Nat enrichi est de transformer ce support en temoin diagonal positif
interne.

## Formule courte

```text
Pour chaque fibre n munie de sa divergence maximale locale,
Collatz fournit le support H(n) via cette divergence maximale.
Nat enrichi transforme H(n) en temoin diagonal positif interne.
```
