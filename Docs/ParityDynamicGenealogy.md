# Genealogie dynamique de la parite

## Objet du document

Ce document expose ce que le cadre formalise sur la parite, sans supposer que
le lecteur connaisse deja le vocabulaire interne du projet.

Le point central est le suivant :

```text
la parite classique n'est pas introduite comme une classification modulo 2 ;
elle est reconstruite comme l'image arithmetique d'une separation
operationnelle portee par un retour dynamique.
```

Autrement dit, le cadre ne commence pas par dire :

```text
pair  = 2*k
impair = 2*k+1
```

Il commence par une situation dynamique :

```text
retour observable
-> intersection typee
-> trace formee
-> ombre visible
-> deux roles terminaux separes
-> code arithmetique
-> pair / impair classiques
```

Le vocabulaire classique arrive donc a la fin. Il n'est pas le principe de
construction.

## Enonce lisible

Une dynamique peut produire deux lectures qui ont le meme contenu observable,
mais qui ne jouent pas le meme role dans l'interface enrichie.

Dans l'instance Nat enrichie, ces deux lectures terminales sont :

```text
trace formee  : prefixe + excess k
ombre visible : prefixe + value k
```

Elles ont le meme payload terminal `k`, mais elles ne sont pas le meme objet
enrichi. Le cadre garde cette difference au lieu de l'ecraser en une egalite
visible.

Cette difference produit deux roles operationnels :

```text
closing role   = closingExcess k
mediating role = mediatingValue k
```

Puis ces roles recoivent un code arithmetique :

```text
closingExcess k  -> 2*k
mediatingValue k -> 2*k+1
```

C'est a ce stade seulement que la parite classique apparait.

## Chaine formelle generale

La couche arithmetique generale est dans :

```text
Meta/Arithmetic/Parity.lean
```

Elle definit d'abord les roles internes, que l'on peut lire
schematiquement comme :

```lean
NatEnrichedParityRole.closingExcess k
NatEnrichedParityRole.mediatingValue k
```

Puis elle definit leur code. En notation schematique :

```lean
natEnrichedParityRoleCode (closingExcess k)  = 2*k
natEnrichedParityRoleCode (mediatingValue k) = 2*k+1
```

Les definitions classiques locales sont les definitions constructives
suivantes :

```lean
EvenClassical n := exists k, n = 2*k
OddClassical n  := exists k, n = 2*k+1
```

Les equivalences prouvees sont :

```lean
isClosingCode_iff_evenClassical :
  IsClosingCode n <-> EvenClassical n

isMediatingCode_iff_oddClassical :
  IsMediatingCode n <-> OddClassical n
```

La partie paire est aussi raccordee au predicat `Even` de Mathlib :

```lean
evenClassical_iff_mathlib_even :
  EvenClassical n <-> Even n

isClosingCode_iff_mathlib_even :
  IsClosingCode n <-> Even n
```

La partie impaire reste raccordee a la definition constructive locale
`OddClassical`. Ce choix est volontaire : dans l'environnement actuel,
`Mathlib.Odd` introduit des dependances interdites par l'audit constructif du
projet, alors que `OddClassical` est exactement la forme constructive
`exists k, n = 2*k+1`.

## Extraction depuis une intersection dynamique

Pour une intersection exacte quelconque, le cadre prouve :

```lean
arithmeticClosingRoleOfIntersection_eq :
  closing role = closingExcess formedPositiveExcess

arithmeticMediatingRoleOfIntersection_eq :
  mediating role = mediatingValue formedPositiveExcess
```

Puis :

```lean
arithmeticClosingCodeOfIntersection_eq :
  closing code = 2 * formedPositiveExcess

arithmeticMediatingCodeOfIntersection_eq :
  mediating code = 2 * formedPositiveExcess + 1
```

Et enfin :

```lean
arithmeticClosingCodeOfIntersection_even :
  Even closing code

arithmeticMediatingCodeOfIntersection_oddClassical :
  OddClassical mediating code
```

Cela signifie que pair et impair ne sont pas seulement reconnus apres coup.
Ils sont obtenus comme les images arithmetiques de deux roles dynamiques
separes.

## Specialisation countdown

Le countdown donne une realisation interne explicite du cas terminal.

Le fichier :

```text
Meta/Arithmetic/CountdownDynamicGap.lean
```

prouve :

```lean
countdownTerminalExcess_eq_n_plus_two :
  formedPositiveExcess = n + 2
```

Le fichier :

```text
Meta/Arithmetic/CountdownGapContraction.lean
```

raccorde ensuite cette egalite au packaging dynamique et a la parite
operationnelle.

Les declarations importantes sont :

```lean
countdownTerminalIntersection

countdownTerminalDynamicGapRow_terminalExcess_eq_n_plus_two :
  terminalExcess = n + 2

fullyConstructedCountdownDynamicGapRow_terminalExcess_eq_n_plus_two :
  terminalExcess = n + 2
```

Puis les roles specialises :

```lean
countdownTerminalClosingRole_eq_n_plus_two :
  closing role = closingExcess (n + 2)

countdownTerminalMediatingRole_eq_n_plus_two :
  mediating role = mediatingValue (n + 2)
```

Puis les codes specialises :

```lean
countdownTerminalClosingCode_eq_n_plus_two :
  closing code = 2 * (n + 2)

countdownTerminalMediatingCode_eq_n_plus_two :
  mediating code = 2 * (n + 2) + 1
```

Et enfin les statuts arithmetiques :

```lean
countdownTerminalClosingCode_even :
  Even (countdownTerminalClosingCode n)

countdownTerminalMediatingCode_oddClassical :
  OddClassical (countdownTerminalMediatingCode n)
```

La chaine countdown complete est donc :

```text
retour terminal du countdown
-> intersection terminale
-> formedPositiveExcess = n + 2
-> closingExcess (n + 2)
-> mediatingValue (n + 2)
-> 2 * (n + 2)
-> 2 * (n + 2) + 1
-> pair / impair constructifs
```

## Ce que cela change par rapport a la presentation classique

La presentation classique dit :

```text
un entier est pair s'il est de la forme 2*k ;
un entier est impair s'il est de la forme 2*k+1.
```

Cette presentation est correcte, mais elle est statique. Elle donne une
classification des entiers.

Le cadre dynamique ajoute une genealogie. Il montre dans ce cadre :

```text
comment deux formes sont produites ;
comment elles restent separees ;
comment elles ont le meme payload visible ;
comment l'une porte le role de fermeture et l'autre le role de mediation ;
comment leur image arithmetique devient 2*k et 2*k+1.
```

Le changement n'est donc pas de remplacer l'arithmetique classique. Le
changement est d'exhiber une origine structurelle de la parite
classique a l'interieur d'un cadre dynamique plus riche.

La forme classique :

```text
2*k / 2*k+1
```

devient l'image finale d'une separation operationnelle :

```text
closing / mediating
```

elle-meme portee par une mediation entre deux lectures d'un meme retour.

## Portee exacte

Ce qui est formellement etabli :

```text
1. Des roles operationnels internes a Nat enrichi existent.
2. Ces roles sont extraits d'intersections dynamiques.
3. Le role closing se code par 2*k.
4. Le role mediating se code par 2*k+1.
5. Ces codes sont equivalents aux definitions constructives classiques
   pair / impair.
6. Dans le countdown, le payload terminal est specialise en n+2.
7. Donc le countdown donne les codes explicites :
   2*(n+2) et 2*(n+2)+1.
```

Ce qui n'est pas affirme ici :

```text
1. On ne nie pas la definition classique de la parite.
2. On ne remplace pas l'arithmetique usuelle.
3. On ne prouve pas que toute presentation mathematique de la parite doit
   passer historiquement par ce cadre.
```

Ce que le cadre apporte est plus precis :

```text
il exhibe une genealogie dynamique constructive de la parite et des impairs,
dont la presentation classique apparait comme l'image arithmetique finale.
```

## Formule courte

La formule courte est :

```text
La parite classique est reconstruite comme l'image arithmetique d'une
separation dynamique entre un role de fermeture et un role de mediation.
```

Et pour le countdown :

```text
formedPositiveExcess = n + 2
closing code   = 2 * (n + 2)
mediating code = 2 * (n + 2) + 1
```
