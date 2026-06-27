# Plan d'implementation : roles arithmetiques de la parite

## Statut

Ce document prepare la couche arithmetique qui doit interpreter les roles
operationnels de la parite dans le vocabulaire classique pair / impair.

La couche `Core` est deja posee :

```text
ParitySeparation
DynamicParitySeparation
OperationalParityRoles
```

Elle formalise :

```text
parite abstraite
-> raccord dynamique
-> roles operationnels
```

avec :

```text
formed = closing role
shadow = mediating role
```

Le nouveau fichier ne doit pas modifier cette couche. Il doit ajouter une
instance arithmetique separee.

## Emplacement

Nouveau fichier :

```text
Meta/Arithmetic/ParityRoles.lean
```

Imports attendus pour l'implementation exigeante :

```lean
import Meta.Core.OperationalParityRoles
import Meta.Arithmetic.CountdownDynamicGap
```

Le fichier doit contenir une couche auxiliaire d'interpretation des roles, mais
il ne doit pas s'arreter a cette couche. Il doit aussi construire une instance
arithmetique effective, fondee sur une dynamique concrete.

Les imports suivants sont deja couverts par `Meta.Arithmetic.CountdownDynamicGap`
ou ne doivent etre ajoutes separement que si l'implementation finale en a
vraiment besoin :

```lean
import Meta.Arithmetic.TwoPole
import Meta.Arithmetic.Countdown
import Meta.Arithmetic.CountdownDynamicGap
```

Le choix exact doit rester minimal. Pour la couche de nommage seule,
`Meta.Core.OperationalParityRoles` suffirait, mais ce ne serait pas
l'implementation exigeante demandee.

Integration dans l'agregateur :

```lean
import Meta.Arithmetic.ParityRoles
```

place apres les couches arithmetiques dont il depend.

## Objectif

Donner une lecture arithmetique des roles operationnels :

```text
pair   = role de fermeture locale
impair = role de mediation active
```

Cette lecture ne doit pas redefinir la parite abstraite. Elle doit montrer que
le vocabulaire arithmetique classique peut etre relu comme interpretation de
la structure deja formalisee.

La direction conceptuelle est :

```text
OperationalParityRoles
-> ArithmeticParityRoles
```

et non :

```text
pair / impair
-> reconstruction du Core
```

Cette couche de lecture ne suffit pas, a elle seule, a constituer l'instance
arithmetique exigeante. Elle est un auxiliaire de vocabulaire. L'instance
attendue doit ensuite raccorder une dynamique arithmetique effective a ces
roles.

L'objectif complet est donc en deux niveaux :

```text
niveau 1 : nommage structurel
OperationalParityRoles
-> ArithmeticParityRoles

niveau 2 : instance arithmetique forte
dynamique Nat concrete
-> DynamicParitySeparation
-> OperationalParityRoles
-> ArithmeticParityRoles
```

Le niveau 1 est utile, mais il ne doit pas etre presente comme le resultat
final. Le resultat final attendu est le niveau 2.

## Discipline conceptuelle

Le fichier ne doit pas figer trop tot une identification directe des
constructeurs neutres avec les noms arithmetiques.

Une telle identification donnerait l'impression qu'elle est absolue, alors
qu'elle doit rester portee par une orientation.

La couche `Core` garde volontairement deux constructeurs neutres :

```text
ParityRegime.left
ParityRegime.right
```

L'identification arithmetique doit etre portee par une orientation explicite.
Le raccord dynamique choisit quel constructeur joue le role de fermeture et
quel constructeur joue le role de mediation.

Ce qui doit etre fixe arithmetiquement, c'est le sens des roles :

```text
evenRole = closing role
oddRole  = mediating role
```

et non une interpretation globale et non orientee de `left` et `right`.

## Definitions attendues

La couche auxiliaire de nommage peut introduire une structure du type :

```lean
structure ArithmeticParityRoles
    {raccord : DynamicParitySeparation dynamicReturn}
    (roles : OperationalParityRoles raccord) where
  evenRegime : ParityRegime
  oddRegime : ParityRegime
  even_eq_closing :
    evenRegime = operationalParityRoles_closingRegime roles
  odd_eq_mediating :
    oddRegime = operationalParityRoles_mediatingRegime roles
```

Cette forme donne seulement le schema lisible. L'implementation Lean devra
reprendre les parametres universels exacts de `OperationalParityRoles`.

Un squelette Lean de cette forme a ete verifie contre les types actuels. La
couche de nommage seule passe avec le seul import :

```lean
import Meta.Core.OperationalParityRoles
```

Les noms attendus pour cette couche auxiliaire sont :

```lean
ArithmeticParityRoles
arithmeticParityRolesOfOperationalRoles
arithmeticParityRoles_evenRegime
arithmeticParityRoles_oddRegime
arithmeticParityRoles_even_eq_closing
arithmeticParityRoles_odd_eq_mediating
arithmeticParityRoles_sameParityProjection
arithmeticParityRoles_separated
arithmeticParityRoles_dynamicRepair
arithmeticParityRoles_noParityVisibleReconstruction
```

Les consequences attendues sont :

```text
evenRegime et oddRegime ont le meme visible de parite
evenRegime et oddRegime restent separes
evenRegime porte la reparation dynamique locale
la reconstruction globale par le visible seul reste impossible
```

En Lean, ces consequences doivent etre obtenues par transport depuis :

```lean
operationalParityRoles_sameParityProjection
operationalParityRoles_separated
operationalParityRoles_dynamicRepair
operationalParityRoles_noParityVisibleReconstruction
```

## Exigence forte pour l'instance

L'instance arithmetique ne doit pas etre un simple emballage de roles deja
donnes. Elle doit produire les roles a partir d'une source arithmetique interne.

La forme minimale acceptable est :

```text
source arithmetique concrete
-> dynamic return localement recupere
-> raccord dynamique de parite
-> roles operationnels
-> roles arithmetiques
```

Autrement dit, le fichier ne doit pas seulement accepter :

```text
roles : OperationalParityRoles raccord
```

et les renommer. Il doit aussi fournir une construction qui part d'une donnee
arithmetique effective deja presente dans le projet.

Les sources candidates sont :

```text
ArithmeticDynamicGapRow
ArithmeticDynamicClosedStabilityRow
countdownTerminalDynamicGapRow
fullyConstructedCountdownDynamicClosedStabilityRow
```

La source la plus exigeante est la ligne countdown entierement construite,
parce qu'elle porte deja :

```text
collision terminale explicite
exces terminal n + 2
formed trace
payload-only shadow
meme visible
separation
reparation locale
stabilite fermee
```

Une instance fondee sur countdown serait donc plus forte qu'une simple instance
abstraite parametree.

## Implementation non triviale retenue

L'implementation la plus propre ne doit pas prendre `List NatTraceAtom`
directement comme interface de parite. Une liste brute ne dit pas, par elle-
meme, si elle joue le role forme ou le role shadow. L'utiliser directement
forcerait presque inevitablement une fonction :

```lean
regimeOf : List NatTraceAtom -> ParityRegime
```

trop artificielle.

La bonne construction consiste a introduire une interface arithmetique orientee
par une intersection concrete :

```lean
inductive ArithmeticIntersectionPole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  | formed
  | shadow
```

Cette interface n'est pas une etiquette vide. Chaque pole porte une trace
arithmetique deja definie dans le projet :

```lean
arithmeticIntersectionPoleTrace formed
  = formedTraceOfIntersection intersection

arithmeticIntersectionPoleTrace shadow
  = payloadOnlyTraceOfIntersection intersection
```

Le visible est alors le payload de la trace portee :

```lean
arithmeticIntersectionPoleVisible pole
  = tracePayloads (arithmeticIntersectionPoleTrace pole)
```

La separation n'est pas postulee. Elle vient de :

```lean
formedTraceOfIntersection_ne_payloadOnlyTrace
```

Le meme visible n'est pas postule non plus. Il vient de :

```lean
formedTraceOfIntersection_same_payloadOnlyPayload
```

La reparation locale du pole forme vient de :

```lean
natInterfaceRepairOfIntersection
```

On obtient donc un vrai :

```lean
LocalProjectiveRecovery
  (ArithmeticIntersectionPole intersection)
  (List Nat)
  arithmeticIntersectionPoleVisible
  arithmeticIntersectionPoleRepair
```

et non une classification externe des traces.

## Pipeline Lean attendu

La construction forte doit suivre ce pipeline :

```text
PrimitiveMemoryReadingIntersection branch
-> ArithmeticIntersectionPole intersection
-> arithmeticIntersectionLocalRecovery intersection
-> arithmeticIntersectionDynamicReturn intersection
-> arithmeticIntersectionParityRaccord intersection
-> arithmeticIntersectionOperationalParityRoles intersection
-> arithmeticIntersectionArithmeticParityRoles intersection
```

Les declarations attendues sont :

```lean
ArithmeticIntersectionPole
arithmeticIntersectionPoleTrace
arithmeticIntersectionPoleVisible
arithmeticIntersectionPoleRepair
arithmeticIntersectionLocalRecovery
arithmeticIntersectionPoleWitness
arithmeticIntersectionPoleRealization
arithmeticIntersectionDynamicReturn
arithmeticIntersectionParityRaccord
arithmeticIntersectionOperationalParityRoles
arithmeticIntersectionArithmeticParityRoles
```

Le raccord de parite doit etre obtenu par une lecture structurelle des deux
poles orientes :

```lean
formed -> ParityRegime.left
shadow -> ParityRegime.right
```

et par le visible contracte :

```lean
_ -> ParityVisible.contracted
```

Ce choix n'est pas une classification numerique externe : il est justifie par
la structure orientee `ArithmeticIntersectionPole`, elle-meme construite a
partir de l'intersection arithmetique.

## Specialisation countdown attendue

La specialisation forte doit partir de :

```lean
countdownTerminalWindowCollision n
```

et passer par l'intersection deja disponible :

```lean
repeatedIndexIntersection
  (repeatedIndexCollision_of_trajectoryCollision
    (trajectoryCollision_of_windowCollision
      (countdownTerminalWindowCollision n)))
```

Les declarations attendues sont :

```lean
countdownArithmeticParityIntersection
countdownArithmeticParityDynamicReturn
countdownArithmeticParityRaccord
countdownOperationalParityRoles
countdownArithmeticParityRoles
```

La specialisation doit transporter explicitement le verrou terminal :

```lean
countdownTerminalExcess_eq_n_plus_two
```

afin que le document formel montre bien :

```text
n etapes de descente
+ 1 premiere occurrence terminale
+ 1 repetition terminale
= n + 2
```

Cette partie est decisive : elle distingue une vraie instance dynamique d'un
simple renommage abstrait.

## Verification preliminaire effectuee

Un squelette Lean complet de la construction non triviale a ete teste contre
les types actuels avec :

```lean
import Meta.Core.OperationalParityRoles
import Meta.Arithmetic.CountdownDynamicGap
```

Le squelette construit effectivement :

```lean
arithmeticIntersectionOperationalParityRoles
  {branch : MemoryBranch}
  (intersection : PrimitiveMemoryReadingIntersection branch) :
  OperationalParityRoles (arithmeticIntersectionParityRaccord intersection)
```

Il construit aussi la specialisation countdown :

```lean
countdownArithmeticParityRoles
  (n : Nat) :
  ArithmeticParityRoles (countdownOperationalParityRoles n)
```

et le verrou terminal :

```lean
countdownArithmeticParity_terminalExcess_eq_n_plus_two
  (n : Nat) :
  formedPositiveExcessOfIntersection
    (countdownArithmeticParityIntersection n) = n + 2
```

La commande de verification a reussi :

```bash
lake env lean <squelette temporaire>
```

Cette verification montre que le pipeline suivant est compatible avec les
types actuels :

```text
PrimitiveMemoryReadingIntersection
-> ArithmeticIntersectionPole
-> LocallyRecoveredDynamicReturn
-> DynamicParitySeparation
-> OperationalParityRoles
-> ArithmeticParityRoles
```

L'implementation finale devra reprendre ce schema dans
`Meta/Arithmetic/ParityRoles.lean`, avec noms stables et audit axiomatique
final.

## Criteres non triviaux

Une implementation sera consideree trop faible si elle fait seulement :

```text
OperationalParityRoles -> ArithmeticParityRoles
```

sans source arithmetique concrete.

Elle sera consideree acceptable si elle fournit aussi une structure du type :

```lean
structure ArithmeticDynamicParityInstance (...) where
  dynamicReturn : LocallyRecoveredDynamicReturn ...
  parityRaccord : DynamicParitySeparation dynamicReturn
  operationalRoles : OperationalParityRoles parityRaccord
  arithmeticRoles : ArithmeticParityRoles operationalRoles
```

ou une forme equivalentement precise, adaptee aux types exacts du code.

Elle sera consideree forte si elle specialise cette structure a countdown :

```lean
countdownArithmeticParityInstance
```

avec une dependance explicite a la fermeture terminale :

```text
n etapes de descente
+ 1 premiere occurrence terminale
+ 1 repetition terminale
= n + 2
```

Cette specialisation doit montrer que le `2` operationnel n'est pas seulement
nomme : il est porte par une fermeture dynamique effective.

## Point technique a surveiller

`DynamicParitySeparation` demande une lecture totale :

```lean
regimeOf : Interface -> ParityRegime
visibleOf : Visible -> ParityVisible
```

Si l'interface arithmetique concrete est `List NatTraceAtom`, il ne faut pas
introduire une classification artificielle par egalite deciderable ou par
calcul externe.

Deux strategies sont acceptables :

```text
1. utiliser une interface arithmetique orientee, construite pour porter les
   deux poles formes par la dynamique ;

2. fournir une lecture totale intrinsique deja justifiee par la structure
   arithmetique disponible.
```

La premiere strategie est probablement la plus propre si les listes brutes ne
portent pas assez d'information de role.

Ce qui est interdit :

```text
forcer une fonction regimeOf arbitraire ;
classer les listes par un calcul externe sans lien avec le gap ;
faire dependre l'instance d'une decidabilite globale inutile ;
reduire le role impair a "tout ce qui n'est pas pair".
```

L'instance doit conserver l'information dynamique :

```text
formed = fermeture locale
shadow = mediation active
```

et non la reconstruire apres coup depuis une classification numerique.

## Constructeurs d'orientation

La couche peut aussi fournir deux constructeurs de confort, correspondant aux
deux orientations deja disponibles :

```text
left/right orientation
right/left orientation
```

Mais dans les deux cas, le role arithmetique doit rester :

```text
even = closing / formed
odd  = mediating / shadow
```

L'orientation inverse ne doit donc pas inverser les roles arithmetiques. Elle
change seulement quel constructeur neutre de `ParityRegime` realise le role
arithmetique.

Ces constructeurs doivent etre obtenus en composant :

```lean
operationalParityRoles_leftRight
operationalParityRoles_rightLeft
```

avec :

```lean
arithmeticParityRolesOfOperationalRoles
```

## Ce que le fichier doit prouver

La couche auxiliaire de nommage doit etablir :

```text
la lecture pair / impair nomme les roles operationnels
et transporte leurs proprietes deja formalisees
```

Elle doit rendre explicite que :

```text
pair n'est pas seulement une classe numerique ;
pair est la lecture arithmetique du role de fermeture locale.
```

et que :

```text
impair n'est pas seulement le complement de pair ;
impair est la lecture arithmetique du role de mediation active.
```

La force du fichier est donc de donner au vocabulaire arithmetique de la
parite une lecture structurelle :

```text
even / odd
=
interpretation arithmetique d'une interface operationnelle a deux roles
```

## Non-objectifs

Ne pas introduire ici :

```text
theoremes classiques sur Nat.mod
decision globale de parite
calculs arithmetiques de congruence
identification non orientee de left/right avec pair/impair
nouvelle dynamique
nouvelle theorie de la parite dans Core
affirmation que les predicats standard `Nat` pair / impair sont deja raccordes
```

Le but n'est pas de refaire l'arithmetique standard de la parite. Le but est de
raccorder le vocabulaire arithmetique pair / impair a la structure
operationnelle deja formalisee.

Une couche ulterieure pourra isoler encore davantage le raccord a une
dynamique Nat concrete, par exemple une ligne issue de countdown. Mais pour que
l'implementation soit vraiment exigeante, le fichier ne doit pas s'arreter a
la couche de nommage.

## Limite exacte de la couche de nommage

La couche de nommage ne doit pas pretendre prouver :

```text
les predicats standard de parite sur Nat realisent deja la dynamique
```

si aucun pont explicite vers ces predicats n'est donne.

La couche de nommage doit prouver plus exactement :

```text
quand une dynamique porte deja des OperationalParityRoles,
alors le vocabulaire arithmetique pair / impair peut etre attache
constructivement a ces roles.
```

Cela suffit pour nommer le statut operationnel :

```text
pair   = nom arithmetique du role de fermeture locale
impair = nom arithmetique du role de mediation active
```

Le raccord avec une dynamique Nat concrete devra ensuite fournir la source
effective de ces `OperationalParityRoles`.

L'instance forte doit aller plus loin :

```text
il existe une source arithmetique interne qui produit ces roles,
et pas seulement une facon de les renommer une fois donnes.
```

## Critere de validation

Le fichier Lean final devra respecter les regles constructives du projet :

```text
pas d'axiome
pas de Classical
pas de propext
pas de Quot.sound
un seul bloc AXIOM_AUDIT final
```

La validation attendue est :

```bash
lake env lean Meta/Arithmetic/ParityRoles.lean
lake build
```

Les declarations principales devront afficher :

```text
does not depend on any axioms
```

Pour l'instance forte, l'audit doit inclure au minimum :

```text
ArithmeticDynamicParityInstance
countdownArithmeticParityInstance
```

ou les noms finaux equivalents choisis dans le code.

## Resultat attendu

Apres implementation, l'architecture devra etre :

```text
Meta/Core/ParitySeparation.lean
Meta/Core/DynamicParitySeparation.lean
Meta/Core/OperationalParityRoles.lean
Meta/Arithmetic/ParityRoles.lean
```

La couche `Core` gardera la structure pure :

```text
formed / shadow
closing / mediating
left / right
```

La couche `Arithmetic` ajoutera l'interpretation :

```text
even / odd
```

comme interpretation arithmetique des roles :

```text
even = fermeture locale
odd  = mediation active
```
