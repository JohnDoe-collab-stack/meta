# Couche temporelle de l'exces

## Point de depart

Le cadre possede deja l'exces forme, la separation formed/shadow et le raccord
vers la parite operationnelle.

La chaine actuellement visible est :

```text
intersection.excess
-> formedPositiveExcessOfIntersection = intersection.excess + 1
-> formedTraceOfIntersection
-> closingExcess
-> left / formed / repair
```

Dans l'instance arithmetique dynamique, `intersection.excess` provient deja
d'un temps terminal :

```text
collision.secondTime
-> repeatedIndexIntersection.collision.excess
-> formedPositiveExcess = collision.secondTime + 1
```

Dans le countdown, ce temps terminal est explicite :

```text
secondTime = n + 1
formedPositiveExcess = (n + 1) + 1 = n + 2
```

Le point a rendre explicite est donc :

```text
temps terminal
-> exces brut
-> exces forme
-> roles operationnels
```

## Ce que la couche abstraite doit nommer

La couche abstraite ne doit pas parler du countdown, ni d'une arithmetique
particuliere.

Elle doit isoler une structure minimale, mais cette structure doit etre
raccordee au retour dynamique forme. Sinon elle resterait un nom abstrait sans
transmission formelle.

Forme minimale :

```text
Time
Excess
advance : Time -> Excess
terminalTime : Time
formedExcess : Excess
formedExcess = advance terminalTime
```

Forme raccordee au cadre :

```text
formedReturn : FormedDynamicReturn complete branch Source
terminalTimeOf : Source -> Time
formedExcessOf : complete.Intersection branch -> Excess
advance : Time -> Excess

formedExcessOf formedReturn.intersection
=
advance (terminalTimeOf formedReturn.source)
```

Lecture conceptuelle :

```text
le temps terminal donne la provenance dynamique de l'exces forme.
```

Cette structure ne remplace pas le gap, la referential length ou le two-pole.
Elle se place avant eux :

```text
dynamic return
-> terminal time
-> formed excess
-> local recovery
-> two-pole
-> parity roles
```

## Emplacement probable

Le bon emplacement est la couche dynamique abstraite :

```text
Meta/Core/DynamicStability.lean
```

Raison :

```text
DynamicStability connait deja le retour dynamique forme.
DynamicTwoPole expose ensuite ce retour comme gap operationnel.
DynamicRoleCarrier et DynamicParitySeparation lisent ensuite les roles.
```

Le temps terminal appartient donc a la dynamique avant l'extraction des roles.

Il ne faut pas le mettre directement dans `ReferentialLength.lean`.
`ReferentialLength` lit le statut enrichi du gap :

```text
short presentation
vs
enriched referential length
```

Le temps terminal explique la provenance de l'exces, pas le statut
referentiel du gap.

## Instanciation arithmetique

Dans l'arithmetique, l'instance doit utiliser les donnees deja existantes :

```text
Time = Nat
Excess = Nat
advance t = t + 1
terminalTime = intersection.excess
formedExcess = formedPositiveExcessOfIntersection
```

Cette premiere instance est valable pour toute intersection primitive enrichie :

```text
intersection.excess
-> formedPositiveExcessOfIntersection intersection
= intersection.excess + 1
```

Ensuite, dans le cas repeated-index, on identifie ce temps interne a la donnee
de collision :

```text
intersection.excess = collision.secondTime
```

Les faits deja presents :

```text
repeatedIndexIntersection_excess_eq :
  repeatedIndexIntersection.collision.excess = collision.secondTime

repeatedIndexTerminalExcess_eq :
  formedPositiveExcessOfIntersection (...) = collision.secondTime + 1
```

L'ajout attendu est un packaging propre qui expose :

```text
terminalTimeOfIntersection = intersection.excess
formedExcessOfIntersection = terminalTimeOfIntersection + 1

terminalTimeOfRepeatedIndexCollision = collision.secondTime
formedExcessOfRepeatedIndexCollision = collision.secondTime + 1
```

La ligne `ArithmeticDynamicGapRow` devrait aussi conserver cette donnee :

```text
terminalTime : Nat
terminalExcess : Nat
terminalExcess_eq_terminalTime_succ :
  terminalExcess = terminalTime + 1
```

Aujourd'hui elle conserve `terminalExcess`, mais pas encore le temps qui le
precede.

## Propagation arithmetique obligatoire

La couche abstraite ne suffit pas. Une fois la provenance temporelle nommee dans
le Core, elle doit etre propagee dans l'instance arithmetique.

Propagation attendue :

```text
Meta/Core/DynamicStability.lean
-> Meta/Arithmetic/DynamicGap.lean
-> Meta/Arithmetic/CountdownDynamicGap.lean
-> Meta/Arithmetic/Parity.lean
-> Meta/Arithmetic/CountdownGapContraction.lean
```

Dans `Arithmetic/DynamicGap.lean`, il faut porter la donnee generale :

```text
terminalTime = intersection.excess
terminalExcess = terminalTime + 1
```

Dans `Arithmetic/CountdownDynamicGap.lean`, il faut specialiser :

```text
terminalTime = n + 1
terminalExcess = (n + 1) + 1
```

Dans `Arithmetic/Parity.lean`, il faut raccorder les roles a cette provenance :

```text
closingRole = closingExcess (terminalTime + 1)
mediatingRole = mediatingValue (terminalTime + 1)
```

Dans `Arithmetic/CountdownGapContraction.lean`, il faut exposer la version
countdown :

```text
closingRole = closingExcess ((n + 1) + 1)
mediatingRole = mediatingValue ((n + 1) + 1)
```

puis conserver les formes deja utiles :

```text
closingRole = closingExcess (n + 2)
mediatingRole = mediatingValue (n + 2)
```

Le but est que l'arithmetique ne lise plus seulement :

```text
role index = formedPositiveExcess
```

mais aussi :

```text
role index = successor of terminalTime
```

## Specialisation countdown

Dans le countdown, il faut distinguer les deux etages :

```text
terminalTime = n + 1
formedExcess = terminalTime + 1
```

Aujourd'hui le code prouve deja :

```text
countdownTerminalCollision_secondTime_eq :
  secondTime = n + 1

countdownTerminalExcess_eq_n_plus_two :
  formedPositiveExcess = n + 2
```

Le raccord plus propre doit prouver explicitement :

```text
formedPositiveExcess = (n + 1) + 1
```

puis seulement en consequence :

```text
formedPositiveExcess = n + 2
```

## Impact sur la parite

La parite operationnelle ne doit plus seulement etre lue comme :

```text
closingExcess k
mediatingValue k
```

Elle doit pouvoir etre lue comme :

```text
k = advance terminalTime

left  = closingExcess (advance terminalTime)
right = mediatingValue (advance terminalTime)
```

Donc `right` n'est pas seulement indexe par l'exces forme.
Il est indexe par l'exces forme issu du temps terminal.

La chaine complete devient :

```text
terminal time
-> formed excess
-> closingExcess / mediatingValue
-> left / right
```

Les theoremes attendus sont donc de cette forme :

```text
closingRole = closingExcess (advance terminalTime)
mediatingRole = mediatingValue (advance terminalTime)

formedRegime = left
shadowRegime = right
```

## Critere de bonne implementation

L'implementation sera correcte si elle etablit ces raccords sans postulat :

```text
1. une structure abstraite de provenance temporelle raccordee a
   FormedDynamicReturn ;
2. une instance arithmetique generale pour PrimitiveMemoryReadingIntersection ;
3. une conservation de terminalTime dans ArithmeticDynamicGapRow ;
4. une instance repeated-index donnant terminalTime = collision.secondTime ;
5. une specialisation countdown donnant terminalTime = n + 1 ;
6. une preuve que formedExcess = terminalTime + 1 ;
7. une preuve que les roles de parite sont indexes par cet exces temporel ;
8. une conservation de la chaine existante formed/shadow/projection/repair.
```

Le resultat attendu n'est pas une nouvelle definition de la parite.
C'est le chainon manquant qui explique d'ou vient l'exces utilise par la
parite operationnelle :

```text
temps terminal
-> exces forme
-> separation operationnelle
```

## Verification d'implementabilite

La forme proposee a ete verifiee contre les signatures actuelles du projet.

### Couche Core

Une structure raccordee a `FormedDynamicReturn` est typable :

```text
TemporalExcessDynamicReturn
  formedReturn
  terminalTimeOf
  formedExcessOf
  advance
  formedExcessOf formedReturn.intersection
    =
  advance (terminalTimeOf formedReturn.source)
```

Le point important est que `terminalTime` doit etre lu depuis la `source` du
retour dynamique, tandis que l'exces forme doit etre lu depuis
`formedReturn.intersection`.

### Couche arithmetique generale

L'instance arithmetique generale est typable avec :

```text
Time = Nat
Excess = Nat
terminalTimeOf source = source.down.excess
formedExcessOf intersection = formedPositiveExcessOfIntersection intersection
advance time = time + 1
```

Pour `arithmeticFormedDynamicReturnOfIntersection intersection`, la preuve :

```text
formedExcess = advance terminalTime
```

se ferme par reduction definitoire.

### Repeated-index

Les raccords repeated-index sont typables :

```text
terminalTimeOfIntersection (repeatedIndexIntersection collision)
  =
collision.secondTime

arithmeticClosingRoleOfIntersection (...)
  =
closingExcess (terminalTime + 1)

arithmeticMediatingRoleOfIntersection (...)
  =
mediatingValue (terminalTime + 1)
```

Donc la propagation vers les deux roles operationnels est faisable directement.

### Countdown

Les raccords countdown sont typables :

```text
countdownTerminalTime n = n + 1

formedPositiveExcessOfIntersection (countdownTerminalIntersection n)
  =
countdownTerminalTime n + 1

arithmeticClosingRoleOfIntersection (countdownTerminalIntersection n)
  =
closingExcess (countdownTerminalTime n + 1)

arithmeticMediatingRoleOfIntersection (countdownTerminalIntersection n)
  =
mediatingValue (countdownTerminalTime n + 1)
```

La forme `n + 2` reste une consequence de cette chaine, pas le point de depart.

### Impact sur les constructeurs existants

Ajouter `terminalTime` et la preuve :

```text
terminalExcess = terminalTime + 1
```

a `ArithmeticDynamicGapRow` est implementable proprement.

Le constructeur direct de `ArithmeticDynamicGapRow` se trouve dans :

```text
arithmeticDynamicGapRowOfIntersection
```

Les autres lignes publiques deleguent a cette construction :

```text
repeatedIndexDynamicGapRow
trajectoryDynamicGapRow
windowCollisionDynamicGapRow
boundedWindowDynamicGapRow
postPeakWindowDynamicGapRow
countdownTerminalDynamicGapRow
fullyConstructedCountdownDynamicGapRow
```

Donc la modification n'exige pas une reconstruction dispersee de toutes les
lignes dynamiques. Elle exige une extension de la row centrale, puis des
theoremes de propagation.
