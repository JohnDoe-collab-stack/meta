# Critique du plan OOD par temoin interne

## Verdict court

Le plan corrige le risque principal de la premiere version :

```text
visibleShift
```

n'est plus une preuve flottante.

Il est maintenant derive de :

```text
shiftSource
visibleShiftOfSource
```

C'est une vraie amelioration.

Le plan abstrait est donc pret a etre implemente comme couche de provenance
inspectable.

Mais le plan n'est pas encore blinde. Il reste des points a surveiller, surtout
pour l'instance arithmetique.

## Point positif principal

La nouvelle forme :

```lean
shiftSource : ShiftSource
visibleShiftOfSource :
  ShiftSource ->
    readIn (projectIn formed) = readOut (projectOut formed) -> False
```

puis :

```lean
visibleShift := visibleShiftOfSource shiftSource
```

est bonne.

Elle force la provenance du shift a etre inspectable.

Cela evite que le faux resultat suivant suffise comme preuve sans provenance
inspectable :

```text
Label := Bool
readIn  := fun _ => true
readOut := fun _ => false
```

pris seul comme preuve de shift.

Le plan impose maintenant :

```text
shift visible reel
+ source structurelle du shift
+ meme cellule operatoire
+ temoin interne conserve
+ visible seul insuffisant
```

C'est le bon contrat de non-trivialite.

## Critique 1 : ShiftSource peut encore etre pauvre

`ShiftSource` empeche le shift totalement flottant.

Mais abstraitement, il peut encore etre pauvre.

Par exemple, on pourrait choisir :

```text
ShiftSource := readIn (...) = readOut (...) -> False
```

et poser :

```text
shiftSource := preuve_ad_hoc
visibleShiftOfSource := fun h => h
```

Une telle implementation serait formellement conforme a la couche abstraite,
mais conceptuellement faible.

Donc il faut distinguer deux niveaux :

```text
couche abstraite :
  rend la provenance du shift inspectable ;

instance concrete :
  prouve que cette provenance est substantielle.
```

La couche abstraite ne peut pas garantir seule la richesse du shift.

Cette richesse doit etre verifiee dans l'instance.

## Critique 2 : le transport du temoin peut etre trop facile

Le plan propose :

```text
witnessIn = witness
witnessOut = witness
```

C'est correct comme forme minimale.

Mais cette egalite peut etre trop facile si l'implementation fait seulement :

```lean
witnessIn  := witness
witnessOut := witness
```

Dans ce cas, on aura bien une egalite, mais pas encore une demonstration forte
que le temoin est transporte par la structure.

Le certificat final doit donc garder explicitement le chemin :

```text
cellule
-> temoin interne
-> lectures visibles
```

et non seulement :

```text
temoin
-> temoin
```

Recommandation :

```text
le temoin doit etre attache a la cellule ou extrait d'elle,
pas seulement fourni comme un champ independant.
```

Dans l'instance arithmetique, cela signifie :

```text
le temoin doit etre exactement
NatEnrichedRelaxedOddRole.positiveWitness
```

ou une projection directe de ce champ.

## Critique 3 : noProjectiveReconstruction porte sur la projection, pas sur read

Le plan parle parfois de :

```text
lecture visible seule insuffisante
```

La preuve Lean disponible porte plus precisement sur :

```text
projection visible insuffisante pour reconstruire l'interface
```

via :

```text
ProjectionObstruction
noProjectiveReconstruction
```

C'est correct dans le cadre.

Mais il faut eviter de glisser vers une formulation trop forte :

```text
readIn/readOut ne reconstruisent pas
```

La preuve stricte sera plutot :

```text
projectIn ne reconstruit pas l'interface
projectOut ne reconstruit pas l'interface
```

Les fonctions :

```text
readIn
readOut
```

servent a exposer le shift visible.

Elles ne sont pas directement l'objet de `noProjectiveReconstruction`, sauf si
on construit une projection composee :

```text
readIn ∘ projectIn
readOut ∘ projectOut
```

Ce point doit rester clair dans l'implementation et dans la presentation.

## Critique 4 : projectOut/readOut est le vrai verrou technique

Dans l'instance arithmetique, le choix de :

```text
projectOut
readOut
```

sera delicat.

Il faut simultanement obtenir :

```text
sameOut : projectOut formed = projectOut shadow
visibleShift :
  readIn (projectIn formed) = readOut (projectOut formed) -> False
```

Si `projectOut` encode trop d'information, on risque de perdre :

```text
sameOut
```

Si `projectOut` encode trop peu d'information, le shift devient faible ou
artificiel.

Le bon choix doit donc etre :

```text
projectOut assez contractant pour garder sameOut,
readOut assez structurel pour exposer le shift.
```

C'est probablement le verrou principal de l'instance.

## Critique 5 : rightPayload = k + positiveWitness ne suffit pas seul

Le plan dit que l'instance doit utiliser :

```text
positiveWitness
rightPayload = k + positiveWitness
```

C'est la bonne direction.

Mais cette egalite ne suffit pas a elle seule pour produire un OOD shift.

Elle montre :

```text
le payload de retour porte le temoin positif
```

mais il faut encore construire une separation effective entre :

```text
lecture source
lecture cible
```

Donc le vrai objectif arithmetique est :

```text
rightPayload = k + positiveWitness
+ 0 < positiveWitness
+ lecture source / lecture cible separees
+ meme cellule formed/shadow
+ sameIn/sameOut
```

Sans la separation effective des lectures, on n'a qu'un fait de payload, pas
encore un certificat OOD.

## Critique 6 : la separation de roles seule n'est pas suffisante

Une separation comme :

```text
closingExcess k != mediatingValue k
```

est importante.

Mais elle ne suffit pas seule comme instance OOD complete.

Elle donne une obstruction interne.

Pour obtenir le resultat OOD, elle doit encore etre raccordee a :

```text
projectIn
projectOut
readIn
readOut
visibleShift
```

Autrement dit :

```text
separation de roles
```

peut etre une source de shift, mais pas le certificat OOD complet.

## Ce qui est maintenant bien cadre

Le plan corrige plusieurs erreurs possibles :

```text
1. visibleShift n'est plus une preuve libre ;
2. le shift doit porter une source ;
3. la couche abstraite est separee de l'instance arithmetique ;
4. le temoin ne doit pas etre confondu avec rightPayload ;
5. la separation de roles seule est declaree insuffisante.
```

C'est un vrai progres.

## Ce qui reste a faire avant d'implementer l'instance

Avant l'instance arithmetique, il faut implementer la couche abstraite :

```text
Meta/OOD/WitnessTransport.lean
```

Cette couche doit prouver :

```text
OODProjectionShift.visibleShift
oodDiagonalIn
oodDiagonalOut
oodProjectionObstructionIn
oodProjectionObstructionOut
oodNoProjectiveReconstructionIn
oodNoProjectiveReconstructionOut
OODStructuralCertificate
```

Elle doit rester :

```text
sans arithmetique
sans instance concrete
sans choix de read artificiel
```

## Condition d'acceptation pour l'instance arithmetique

L'instance arithmetique ne sera acceptable que si elle produit :

```text
NatEnrichedRelaxedOddRole k
-> OODStructuralCertificate
```

avec :

```text
1. temoin = NatEnrichedRelaxedOddRole.positiveWitness ;
2. temoin positif ;
3. rightPayload = k + temoin ;
4. visibleShift derive d'une source structurelle ;
5. source structurelle non ad hoc ;
6. sameIn et sameOut prouves ;
7. obstruction projective des deux cotes ;
8. noProjectiveReconstruction des deux cotes ;
9. concordance visible avec le pas relaxe conservee ;
10. aucune reconstruction du temoin depuis le visible.
```

## Verdict final

Le plan corrige est bon pour lancer la couche abstraite.

Il reste fragile sur l'instance, mais cette fragilite est maintenant identifiee
au bon endroit.

La phrase la plus exacte est :

```text
Le plan abstrait est pret.
Le vrai verrou est l'instance arithmetique :
construire projectOut/readOut de maniere assez contractante pour sameOut,
mais assez structurelle pour produire un shift non artificiel.
```

Si ce verrou est resolu, le resultat sera substantiel :

```text
le visible change,
la reconstruction projective echoue,
mais le temoin interne reste transporte par la cellule.
```
