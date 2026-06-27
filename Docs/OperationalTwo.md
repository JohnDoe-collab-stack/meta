# Structure operationnelle du 2

## Objectif

Ce document isole le `2` comme structure operationnelle interne au cadre,
independamment de Collatz.

Le but n'est pas de traiter une dynamique particuliere. Le but est de degager
la structure commune qui permet de lire le `2` autrement que comme une simple
valeur numerique.

## Statut formel

Ce document distingue trois niveaux.

Premier niveau, deja certifie dans Lean :

```text
countdownTerminalWindowCollision
countdownTerminalCollision_secondTime_eq
countdownTerminalExcess_eq_n_plus_two
```

Deuxieme niveau, notation de lecture :

```text
1 + gap + 1
1 + contract(gap) + 1
```

Ces expressions ne designent pas encore un objet Lean autonome. Elles servent a
lire la structure portee par les constructions deja formalisees.

Troisieme niveau, objet transversal a formaliser :

```text
OperationalTwo
TwoPoleInterface
```

La parite releve aussi de ce troisieme niveau : elle est ici indiquee comme
realisation separatrice possible, mais elle n'est pas encore formalisee comme
telle.

La lecture classique voit :

```text
2
```

comme quantite.

La notation enrichie expose :

```text
1 + gap + 1 >= 2
```

comme lecture d'une structure a deux poles portant une mediation.

La notation contractee est :

```text
1 + contract(gap) + 1 <= 2
```

avec :

```text
contract(gap) = 0
```

Dans cette lecture, le classique ne compense pas le gap. Il le contracte.

## Structure a degager

Le `2` operationnel doit etre compris comme une structure minimale a deux
poles.

Forme abstraite :

```text
pole gauche
+ mediation typable
+ pole droit
```

Dans le vocabulaire de l'operateur :

```text
1 + gap + 1
```

Le `2` classique se lit alors comme la contraction quantitative de cette
structure.

La structure operationnelle du `2` ne se reduit donc pas a :

```text
1 + 1
```

Elle contient le role de la mediation :

```text
1 + gap + 1
```

Le cas classique se lit comme le regime ou cette mediation est contractee :

```text
1 + contract(gap) + 1
```

## Trois lectures du meme 2

Le meme `2` admet trois regimes de lecture dans le cadre.

### Lecture quantitative

```text
2
```

Le `2` est lu comme nombre.

### Lecture projective enrichie

```text
1 + gap + 1 >= 2
```

Le `2` est lu comme structure a deux poles dont la mediation est explicite.

### Lecture contractee

```text
1 + contract(gap) + 1 <= 2
contract(gap) = 0
```

Le `2` est lu comme quantite obtenue apres contraction de la mediation.

Ces trois lectures ne sont pas encore trois objets formels separes. Elles sont
trois regimes de presentation de la meme structure.

## Realisation dynamique : countdown

Le countdown donne une realisation interne, deja formalisee, du `2`
operationnel cote fermeture.

Dans le code :

```lean
countdownStep
```

definit une dynamique terminale :

```text
0 -> 0
n + 1 -> n
```

Le countdown atteint le point fixe terminal puis le repete.

Declaration Lean :

```lean
countdownTerminalWindowCollision
```

Type porte :

```lean
NatTrajectoryWindowCollision countdownStep n 0 (n + 2)
```

avec :

```lean
leftOffset  = n
rightOffset = n + 1
```

Donc la dynamique donne deux occurrences terminales :

```text
temps n     : 0
temps n + 1 : 0
```

La collision terminale est bien une double occurrence du meme observable
terminal.

## Le 2 du countdown

Le verrou dynamique donne :

```lean
countdownTerminalCollision_secondTime_eq
```

c'est-a-dire :

```text
secondTime = n + 1
```

Puis :

```lean
countdownTerminalExcess_eq_n_plus_two
```

c'est-a-dire :

```text
formedPositiveExcess = n + 2
```

La raison est le verrou general de Nat dynamique :

```text
formedPositiveExcess = secondTime + 1
```

Donc, pour le countdown :

```text
formedPositiveExcess = (n + 1) + 1 = n + 2
```

Lecture exacte :

```text
n + 2
=
n etapes jusqu'au point fixe
+
1 premiere occurrence terminale
+
1 repetition terminale
```

Le terme terminal `+2` se lit alors comme :

```text
+2 = premiere occurrence terminale + repetition terminale
```

Ce `2` n'est pas ajoute de l'exterieur. Il est realise par la structure de
fermeture dynamique.

## Ce que le countdown etablit pour la structure

Le countdown n'etablit pas une propriete de Collatz. Il etablit que le
developpement Lean possede deja une realisation interne du `2` operationnel
cote fermeture.

Cette realisation est :

```text
point fixe atteint
+ retour sur le meme point fixe
```

ou encore :

```text
premiere occurrence terminale
+ repetition terminale
```

Dans le vocabulaire de lecture `1 + gap + 1`, cela donne :

```text
occurrence terminale
+ gap temporel de retour
+ repetition terminale
```

Dans cette notation, la contraction classique lit cette structure comme :

```text
2
```

Le regime enrichi garde visible la mediation :

```text
1 + gap + 1
```

## Rapport a la parite

Dans cette lecture, la parite releve du meme probleme de structure, mais par un
autre cote.

Elle doit etre comprise comme une realisation separatrice possible, encore a
formaliser, de la structure operationnelle du `2`, distincte de la realisation
terminale donnee par le countdown.

Countdown :

```text
2 = fermeture minimale par retour
```

Parite :

```text
2 = separation minimale de regimes
```

Ces deux lectures visent la meme structure operationnelle, mais elles ne sont
pas identiques.

Le countdown realise deja le `2` cote fermeture.

La parite doit encore etre formalisee comme realisation du `2` cote
separation.

Il faut donc degager la structure du `2` avant de l'appliquer a une dynamique
particuliere.

## Consequence pour la formalisation

La formalisation transversale ne doit pas commencer par une dynamique
particuliere.

Elle doit d'abord isoler un objet transversal encore absent du code, par
exemple :

```text
OperationalTwo
```

ou :

```text
TwoPoleInterface
```

Cet objet devrait porter au minimum :

```text
pole gauche
pole droit
mediation entre les deux poles
contraction classique de la mediation
```

Puis on peut raccorder deux realisations, avec des statuts differents :

```text
countdown, deja formalise :
deux poles comme double occurrence terminale

parite, a formaliser :
deux poles comme separation de regimes
```

Seulement apres ce raccord, une dynamique particuliere peut utiliser la parite
comme interface operationnelle.

## Formule centrale

```text
Le 2 classique se lit comme la contraction quantitative d'une structure
operationnelle a deux poles.
```

Le countdown fournit la realisation dynamique terminale de cette structure :

```text
+2 = premiere occurrence terminale + repetition terminale
```

La parite devra fournir sa realisation separatrice :

```text
2 = separation minimale de regimes
```

La structure commune se note :

```text
1 + gap + 1
```

et sa contraction classique se note :

```text
1 + contract(gap) + 1
```
