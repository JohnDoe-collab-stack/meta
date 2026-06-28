# Collatz et parite operationnelle

## Objet

Ce document fixe une contrainte de lecture pour un futur travail Collatz dans
le cadre Meta.

Le point de depart n'est pas une classification numerique. Le point de depart
est la structure abstraite deja presente dans le Core :

```text
LocallyRecoveredDynamicReturn
-> OperationalTwoPole
-> DynamicRoleCarrier
-> MediatedDynamicRoles
-> DynamicParitySeparation
-> OperationalParityRoles
```

La parite est ici une organisation operationnelle de deux roles. Le codage
numerique ne vient qu'apres.

## Niveau Core : retour dynamique

Le premier niveau est :

```lean
FormedDynamicReturn
LocallyRecoveredDynamicReturn
```

Un `FormedDynamicReturn` porte une source et l'intersection typee produite par
cette source.

Un `LocallyRecoveredDynamicReturn` ajoute :

```text
formedReturn
formed
realizes
localRecovery
localRecovery_sameInterface
```

Le point important est que la dynamique n'est pas seulement une suite de
valeurs. Elle produit une interface formee et une recuperation locale.

Donc une future instance Collatz ne doit pas commencer par une partition
arithmetique. Elle doit commencer par dire quelle source dynamique produit
quelle intersection, quelle interface est formee, et quelle recuperation
locale est portee.

## Niveau Core : two-pole operationnel

Un retour dynamique localement recupere expose un two-pole :

```lean
dynamicReturn_operationalTwoPole
dynamicReturn_structuralTwoPole
```

Le two-pole operationnel porte :

```text
formed
shadow
sameProjection
separated
repair
recovered
recovered_eq_formed
```

Ce niveau est essentiel.

La dynamique porte deux cotes :

```text
formed side
shadow side
```

Le cote `formed` porte la reparation locale.

Le cote `shadow` porte la separation qui ne doit pas etre contractee.

Collatz doit donc etre pense comme une dynamique pouvant agir sur cette
structure, pas comme une simple fonction numerique.

## Niveau Core : carrier de roles

Le fichier :

```text
Meta/Core/DynamicRoleCarrier.lean
```

introduit :

```lean
DynamicRoleCarrier
```

Un `DynamicRoleCarrier` lit le two-pole dynamique dans un espace de roles.

Il contient :

```text
roleOf
roleTwoPole
formed_role
shadow_role
formed_visible
shadow_visible
```

Le point central n'est pas le dernier codage. Le point central est :

```text
le cote formed est lu comme le pole gauche du roleTwoPole ;
le cote shadow est lu comme le pole droit du roleTwoPole.
```

Autrement dit, le retour dynamique est lu dans une structure de roles.

## Niveau Core : roles medies

Le Core extrait ensuite :

```lean
MediatedDynamicRoles
```

Cette structure porte :

```text
closingRole
mediatingRole
closing_eq_formed
mediating_eq_shadow
sameVisible
separated
dynamicRepair
roleRepair
noRoleVisibleReconstruction
```

Ici, la parite commence a prendre son sens operationnel.

Le role `closingRole` n'est pas une classe numerique. Il est le role lu depuis
le cote forme du retour dynamique.

Le role `mediatingRole` n'est pas une classe numerique. Il est le role lu
depuis le cote shadow du retour dynamique.

La structure donne donc :

```text
closingRole   = role du cote forme
mediatingRole = role du cote shadow
```

avec separation, reparation, et impossibilite de reconstruction globale par
contraction du role.

## Niveau Core : parite operationnelle

Le fichier :

```text
Meta/Core/DynamicParitySeparation.lean
```

specialise cette lecture vers la realisation minimale de parite :

```lean
DynamicParitySeparation
OperationalParityRoles
```

La structure `OperationalParityRoles` porte :

```text
closingRegime
mediatingRegime
closing_eq_formed
mediating_eq_shadow
sameVisible
separated
dynamicRepair
noParityVisibleReconstruction
```

La parite operationnelle est donc la structure qui organise :

```text
closingRegime
mediatingRegime
```

comme deux roles medies par un retour dynamique.

Le point a conserver pour Collatz est celui-ci :

```text
la parite est d'abord une structure de roles ;
elle n'est pas d'abord une classification de nombres.
```

## Instance Nat enrichie

Dans l'instance Nat enrichie, cette structure abstraite est realisee par :

```lean
NatEnrichedParityRole.closingExcess
NatEnrichedParityRole.mediatingValue
```

Le fichier :

```text
Meta/Arithmetic/Parity.lean
```

construit :

```lean
natEnrichedParityRoleOperationalTwoPole
arithmeticDynamicRoleCarrierOfIntersection
arithmeticMediatedDynamicRolesOfIntersection
arithmeticDynamicParitySeparationOfIntersection
arithmeticOperationalParityRolesOfIntersection
```

La chaine est donc :

```text
intersection arithmetique
-> retour dynamique localement recupere
-> role carrier Nat enrichi
-> roles medies Nat enrichis
-> parite operationnelle Nat enrichie
```

Seulement ensuite vient le codage numerique :

```text
closingExcess k  -> 2*k
mediatingValue k -> 2*k+1
```

Ce codage ne doit pas commander l'analyse de Collatz. Il doit etre traite
comme la trace numerique finale d'une structure plus haute.

## Contrainte pour Collatz

Une future formalisation Collatz doit respecter la hierarchie suivante :

```text
1. source dynamique Collatz ;
2. intersection ou retour porte par cette source ;
3. interface formee ;
4. recuperation locale ;
5. two-pole operationnel ;
6. carrier de roles ;
7. roles medies ;
8. parite operationnelle ;
9. codage numerique.
```

Si l'on commence directement au niveau du codage numerique, on perd ce que le
cadre apporte.

La question correcte n'est donc pas :

```text
que fait la fonction sur les deux classes numeriques usuelles ?
```

La question correcte est :

```text
comment la dynamique Collatz agit-elle sur la structure operationnelle
de parite ?
```

Plus precisement :

```text
comment agit-elle sur closingRegime ?
comment agit-elle sur mediatingRegime ?
comment conserve-t-elle ou transforme-t-elle la reparation ?
comment relance-t-elle une nouvelle position de parite operationnelle ?
```

## Branche de fermeture

Le role `closingExcess` represente la realisation Nat enrichie du role de
fermeture.

Une branche Collatz qui consomme un code de fermeture ne doit pas etre
interpretee comme une simple operation numerique. Elle doit etre analysee
comme une operation sur le role de fermeture.

Question a formaliser :

```text
une operation sur closingExcess conserve-t-elle le role closing,
ou produit-elle une nouvelle position dans la structure de parite ?
```

## Branche de mediation

Le role `mediatingValue` represente la realisation Nat enrichie du role de
mediation.

Une branche Collatz qui agit sur ce role ne doit pas etre isolee comme un cas
arithmetique ordinaire. Elle doit etre analysee comme une operation sur le
role de mediation dans la structure complete.

Au niveau du codage, on peut obtenir une expression numerique. Mais cette
expression n'est pas l'analyse.

L'analyse attendue est :

```text
operation sur mediatingValue
-> transformation de role
-> eventuelle re-entree dans une position de fermeture
-> relance de la parite operationnelle
```

## Probleme central

Le probleme interne n'est pas d'abord une question de valeurs numeriques.

Le probleme interne est :

```text
la dynamique Collatz porte-t-elle une circulation forcee des roles
closing / mediating vers une fermeture globale ?
```

Cette formulation reste a formaliser.

Elle doit etre attaquee en partant du Core, pas en partant du codage final.

## Ce que l'on sait deja

Le cadre sait deja formaliser :

```text
1. retour dynamique forme ;
2. recuperation locale ;
3. two-pole operationnel ;
4. carrier de roles ;
5. roles medies ;
6. parite operationnelle ;
7. instance Nat enrichie de cette parite ;
8. codage numerique final.
```

Le countdown donne deja une specialisation dynamique :

```text
formedPositiveExcess = n + 2
closing code   = 2 * (n + 2)
mediating code = 2 * (n + 2) + 1
```

Ce n'est pas Collatz. Mais cela montre que l'instance Nat enrichie sait porter
une parite operationnelle specialisee par une dynamique interne.

## Ce qui reste a construire

Pour Collatz, il faudra construire explicitement :

```text
CollatzSource
CollatzIntersection
CollatzLocallyRecoveredDynamicReturn
CollatzDynamicRoleCarrier
CollatzMediatedDynamicRoles
CollatzOperationalParityRoles
```

Puis seulement ensuite etudier le codage numerique induit.

## Formule courte

Dans le cadre Meta, Collatz doit etre etudie comme une dynamique sur la parite
operationnelle :

```text
closing / mediating
```

Le codage numerique est une consequence, pas le point de depart.

## Lecture operationnelle stricte

```text
ParityRegime.left
=
regime forme
=
pole porteur de la reparation locale
=
n / 2

ParityRegime.right
=
shadow du regime forme
=
pole correle au regime forme par la meme projection contractee
=
pole maintenu separe du regime forme
=
3 * n + 1

parityProjection(ParityRegime.left)
=
parityProjection(ParityRegime.right)
=
ParityVisible.contracted

separation :
ParityRegime.left = ParityRegime.right -> False

reparation locale :
ParityRegime.left porte la reparation locale
```

La chaine Collatz inscrit la transformation `3 * n + 1` sur le shadow du
regime forme, tandis que la transformation `n / 2` reste portee par le regime
forme reparable ; les deux regimes ont la meme projection contractee, restent
separes, et seule la source formee porte la reparation locale.
