# Plan de redesign : lecture deux-poles du gap operationnel

## Objectif

Ce plan prepare une reorganisation sobre du code autour de la lecture
operationnelle du `2`.

Le but n'est pas d'ajouter une nouvelle notion concurrente au noyau. Le but est
de rendre explicite une lecture positive deja presente dans le cadre :

```text
pole gauche
+ mediation operationnelle
+ pole droit
```

Cette lecture correspond au vocabulaire documentaire :

```text
1 + gap + 1
```

Elle doit rester adossee aux objets formels existants :

```text
StructuralReferentialGap
OperationalReferentialGap
LocalProjectiveRecovery
LocallyRecoveredDynamicReturn
```

## Diagnostic

Le noyau formel existe deja.

Dans `Meta/Core/Gap.lean`, le code distingue :

```text
ContractibleReferentialGap
StructuralReferentialGap
OperationalReferentialGap
```

Dans `Meta/Core/ReferentialLength.lean`, le contraste documentaire :

```text
1 + 1
1 + gap + 1
```

est deja encode par le statut du fibre de projection, sans introduire une
fausse arithmetique numerique.

Dans `Meta/Core/DynamicStability.lean`, la dynamique abstraite existe deja :

```text
FormedDynamicReturn
LocallyRecoveredDynamicReturn
```

Le probleme n'est donc pas un manque de puissance formelle. Le probleme est
l'absence d'une couche de lecture positive qui expose le meme objet comme une
structure a deux poles medies.

## Probleme architectural

Certaines couches sont encore trop imbriquees.

### Dependances arithmetiques trop specialisees

`Meta/Arithmetic/DynamicGap.lean` importe actuellement `Meta.Arithmetic.Countdown`.

Cela rend la facade dynamique arithmetique dependante d'une instance terminale
particuliere. Conceptuellement, le dynamique arithmetique generique devrait
exister avant le countdown.

### Dynamique observee trop dependante de la facade arithmetique

`Meta/Dynamics/ObservedDiscrete.lean` importe actuellement
`Meta.Arithmetic.DynamicGap`.

Or ce fichier n'a besoin que de convertir une collision observee en
`RepeatedIndexCollision`. Il devrait dependre d'une couche plus basse, pas de la
facade dynamique arithmetique complete.

### Vocabulaire positif encore absent du Core

Le Core sait deja dire :

```text
projection non contractible
obstruction
gap operationnel
recuperation locale
```

Mais il ne nomme pas encore explicitement la lecture positive :

```text
deux poles
mediation
projection contractee
separation conservee
```

Cette absence favorise une lecture negative du cadre, alors que le code porte
deja une structure positive.

## Architecture cible

La cible proposee est :

```text
Meta/Core/
  ClosedStabilityTheorem.lean
  Gap.lean
  ReferentialLength.lean
  TwoPole.lean
  DynamicStability.lean
  OrderGap.lean

Meta/Arithmetic/
  Core.lean
  Canonical.lean
  RepeatedIndex.lean
  FinitePigeonhole.lean
  Trajectory.lean
  Window.lean
  HeightDiagonal.lean
  DynamicGap.lean
  GapContraction.lean
  Countdown.lean
  CountdownDynamicGap.lean
  CountdownGapContraction.lean

Meta/Dynamics/
  ObservedDiscrete.lean
  ObservedWindow.lean
  ObservedDynamicGap.lean
```

Cette architecture impose l'ordre conceptuel suivant :

```text
Core gap
-> lecture deux-poles
-> dynamique abstraite
-> instances arithmetiques
-> countdown
-> dynamiques observees
```

## Nouveau fichier Core propose

### `Meta/Core/TwoPole.lean`

Ce fichier ne doit pas redefinir le gap.

Il doit donner une lecture positive des objets existants.

Forme minimale :

```lean
import Meta.Core.ReferentialLength

namespace Meta
namespace ClosedStabilityTheorem

universe u v s

abbrev StructuralTwoPole
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) :=
  StructuralReferentialGap Interface Visible project

abbrev OperationalTwoPole
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v s) :=
  OperationalReferentialGap Interface Visible project RepairOf

end ClosedStabilityTheorem
end Meta
```

Puis ajouter des projections nominales :

```lean
def twoPole_leftPole := ...
def twoPole_rightPole := ...
def twoPole_sameVisible := ...
def twoPole_separated := ...
def operationalTwoPole_repair := ...
def operationalTwoPole_structural := ...
```

Ces noms doivent etre des vues sur `ProjectionObstruction` et
`LocalProjectiveRecovery`, pas de nouvelles donnees.

`TwoPole.lean` ne doit pas importer `DynamicStability.lean`. Le deux-poles pur
est une lecture du gap operationnel, pas encore une lecture du retour dynamique.
Les ponts entre retour dynamique et deux-poles peuvent rester dans
`OrderGap.lean`, ou etre deplaces plus tard vers un fichier dedie comme
`Meta/Core/DynamicTwoPole.lean` si la separation devient utile.

## Vocabulaire formel attendu

La lecture `1 + gap + 1` doit correspondre a :

```text
leftPole
mediation
rightPole
sameVisible
separatedPoles
localRepair
```

La lecture contractee doit correspondre a :

```text
ShortReferentialPresentation
ContractibleReferentialGap
ProjectionFiberFaithful
```

Les theoremes attendus dans `TwoPole.lean` sont donc des alias positifs des
theoremes existants :

```text
structuralTwoPole_refutes_shortPresentation
operationalTwoPole_refutes_shortPresentation
operationalTwoPole_not_contractible
operationalTwoPole_no_projective_reconstruction
```

Le but est lexical et architectural : rendre lisible le positif sans affaiblir
la preuve existante.

## Migration arithmetique

### Etape 1 : separer countdown de `DynamicGap`

`Meta/Arithmetic/DynamicGap.lean` doit contenir le noyau generique suivant :

```text
ArithmeticDynamicGapRow
ArithmeticDynamicClosedStabilityRow
arithmeticDynamicGapRowOfIntersection
repeatedIndexDynamicGapRow
trajectoryDynamicGapRow
windowCollisionDynamicGapRow
boundedWindowDynamicGapRow
postPeakWindowDynamicGapRow
```

La liste complete des declarations a conserver est fixee plus bas dans la
section de verification de precision.

Il ne doit plus importer `Meta.Arithmetic.Countdown`.

Import cible retenu :

```lean
import Meta.Arithmetic.HeightDiagonal
```

`HeightDiagonal` fournit deja `NatTrajectoryPostPeakWindow`,
`boundedWindow_of_postPeakWindow` et `postPeakWindowClosedStabilityInstance`.
Le countdown peut donc etre separe sans perdre la partie post-peak generique.

Les declarations countdown doivent migrer vers un fichier dedie :

```text
Meta/Arithmetic/CountdownDynamicGap.lean
```

Declarations a deplacer :

```text
countdownTerminalCollision_secondTime_eq
countdownTerminalExcess_eq_n_plus_two
countdownTerminalDynamicGapRow
countdownTerminalDynamicClosedStabilityRow
fullyConstructedCountdownDynamicGapRow
fullyConstructedCountdownDynamicClosedStabilityRow
```

Le bloc `AXIOM_AUDIT` de `DynamicGap.lean` devra etre reduit en consequence :
les lignes `#print axioms` relatives au countdown devront migrer dans
`CountdownDynamicGap.lean`.

### Etape 2 : separer countdown de `GapContraction`

`Meta/Arithmetic/GapContraction.lean` doit rester generique pour l'arithmetique.

Les declarations explicitement countdown doivent migrer vers :

```text
Meta/Arithmetic/CountdownGapContraction.lean
```

Declaration a deplacer :

```text
countdownArithmeticGapTerminalExcess_eq_n_plus_two
```

Si `canonicalArithmeticGapTerminalExcess_eq_one` est purement canonique, elle
peut rester dans `GapContraction.lean`.

## Migration dynamique observee

### Etape 3 : alleger `ObservedDiscrete`

`Meta/Dynamics/ObservedDiscrete.lean` ne devrait pas importer
`Meta.Arithmetic.DynamicGap`.

Il devrait importer une couche suffisante pour construire :

```text
RepeatedIndexCollision
```

Import cible retenu :

```lean
import Meta.Arithmetic.RepeatedIndex
```

Cet import suffit pour `RepeatedIndexCollision` et evite de tirer toute la
facade `DynamicGap`.

### Etape 4 : garder `ObservedDynamicGap` comme facade complete

`Meta/Dynamics/ObservedDynamicGap.lean` peut importer :

```lean
import Meta.Dynamics.ObservedWindow
import Meta.Core.DynamicStability
import Meta.Arithmetic.DynamicGap
```

Ce fichier est le bon endroit pour raccorder les collisions observees au row
arithmetique dynamique complet.

Apres l'allegement de `ObservedDiscrete.lean`, l'import
`Meta.Arithmetic.DynamicGap` devra etre explicite dans `ObservedDynamicGap.lean`,
car il ne viendra plus indirectement par `ObservedDiscrete.lean`.

## Integration de `TwoPole`

### Etape 5 : exposer les lignes dynamiques comme deux-poles

Une fois `Meta/Core/TwoPole.lean` cree, ajouter des ponts sobres.

Dans `Meta/Arithmetic/GapContraction.lean` ou dans un nouveau fichier
`Meta/Arithmetic/TwoPole.lean` :

```text
arithmeticDynamicRowOperationalTwoPole
arithmeticDynamicRowStructuralTwoPole
```

Ces definitions doivent etre de simples vues sur :

```text
arithmeticDynamicRowOperationalGap
arithmeticDynamicRowStructuralGap
```

Point de precision : les definitions generiques
`dynamicReturn_operationalGap` et `dynamicReturn_structuralGap` vivent
actuellement dans `Meta/Core/OrderGap.lean`, alors qu'elles ne sont pas
specifiques aux ordres. Il n'est pas obligatoire de les deplacer dans la
premiere passe, mais une passe ulterieure pourrait creer :

```text
Meta/Core/DynamicTwoPole.lean
```

pour y placer les ponts :

```text
dynamicReturn_operationalTwoPole
dynamicReturn_structuralTwoPole
```

Si ces definitions sont deplacees hors de `OrderGap.lean`, il faudra ajuster les
imports de `Meta/Tarski/DynamicReturn.lean`, qui les utilise actuellement par
l'intermediaire de `OrderGap.lean`.

### Etape 6 : exposer countdown comme realisation terminale

Dans `Meta/Arithmetic/CountdownDynamicGap.lean` ou
`Meta/Arithmetic/CountdownGapContraction.lean` :

```text
countdownTerminalOperationalTwoPole
countdownTerminalStructuralTwoPole
```

Ces definitions doivent montrer que le countdown realise le deux-poles cote
fermeture.

Ne pas prouver une nouvelle stabilite. Utiliser les theoremes deja portes par :

```text
countdownTerminalWindowCollision
countdownTerminalExcess_eq_n_plus_two
countdownTerminalDynamicGapRow
```

## Ce qu'il ne faut pas faire

Ne pas creer une nouvelle structure lourde qui duplique :

```text
ProjectionObstruction
LocalProjectiveRecovery
OperationalReferentialGap
```

Ne pas faire dependre `Core` de `Arithmetic`, `Countdown`, `Tarski`, `Bell` ou
`Dynamics`.

Ne pas transformer les notations :

```text
1 + gap + 1
1 + contract(gap) + 1
```

en fausses operations numeriques Lean.

Ne pas introduire une preuve conditionnelle du type :

```text
si un pont externe existe alors...
```

La fermeture doit rester portee par les donnees internes deja presentes.

## Validation Lean

Chaque fichier Lean modifie ou cree doit respecter les regles du projet :

```text
aucun axiome
pas de Classical
pas de propext
pas de Quot.sound
un unique bloc AXIOM_AUDIT a la fin
```

Apres chaque etape :

```bash
lake build
```

Puis verifier les audits pertinents :

```text
#print axioms ...
```

Les audits ne doivent mentionner aucun axiome interdit.

## Verification de precision avant implementation

Cette section fixe les points controles directement dans le code actuel.

### `DynamicGap.lean`

Fichier actuel :

```text
Meta/Arithmetic/DynamicGap.lean
```

Import actuel :

```lean
import Meta.Arithmetic.Countdown
```

Import cible :

```lean
import Meta.Arithmetic.HeightDiagonal
```

Declarations qui doivent rester dans `DynamicGap.lean` :

```text
ArithmeticDynamicGapRow
ArithmeticDynamicClosedStabilityRow
arithmeticDynamicGapRowOfIntersection
repeatedIndexIntersection_excess_eq
repeatedIndexTerminalExcess_eq
repeatedIndexDynamicGap_sameVisible
repeatedIndexDynamicGap_separated
repeatedIndexDynamicGapRow
repeatedIndexDynamicClosedStabilityRow
trajectoryCollision_terminalExcess_eq
trajectoryDynamicGapRow
trajectoryDynamicClosedStabilityRow
windowCollision_terminalExcess_eq
windowCollisionDynamicGapRow
windowCollisionDynamicClosedStabilityRow
boundedWindowDynamicGapRow
boundedWindowDynamicClosedStabilityRow
canonicalPositiveDiagonalTerminalExcess_eq_one
postPeakWindowDynamicGapRow
postPeakWindowDynamicClosedStabilityRow
```

Declarations qui doivent migrer vers `CountdownDynamicGap.lean` :

```text
countdownTerminalCollision_secondTime_eq
countdownTerminalExcess_eq_n_plus_two
countdownTerminalDynamicGapRow
countdownTerminalDynamicClosedStabilityRow
fullyConstructedCountdownDynamicGapRow
fullyConstructedCountdownDynamicClosedStabilityRow
```

### `GapContraction.lean`

Fichier actuel :

```text
Meta/Arithmetic/GapContraction.lean
```

Il doit continuer a importer :

```lean
import Meta.Arithmetic.DynamicGap
import Meta.Core.ReferentialLength
```

Declarations qui doivent rester :

```text
ArithmeticShortPayloadPresentation
arithmeticGapTerminalExcessOfIntersection
arithmeticGapTerminalExcess_pos
arithmeticGapFormedTrace
arithmeticGapPayloadShadow
arithmeticGap_sameVisible
arithmeticGap_separated
arithmeticStructuralGapOfIntersection
arithmeticOperationalGapOfIntersection
arithmeticStructuralGapOfOperationalIntersection
arithmeticStructuralGap_refutes_shortPresentation
arithmeticOperationalGap_refutes_shortPresentation
arithmeticTruthGapRecoveryOfIntersection
arithmeticDynamicRowStructuralGap
arithmeticDynamicRowOperationalGap
arithmeticDynamicRow_refutes_shortPresentation
repeatedIndexArithmeticOperationalGap
trajectoryArithmeticOperationalGap
boundedWindowArithmeticOperationalGap
postPeakWindowArithmeticOperationalGap
canonicalArithmeticGapTerminalExcess_eq_one
```

Declaration qui doit migrer vers `CountdownGapContraction.lean` :

```text
countdownArithmeticGapTerminalExcess_eq_n_plus_two
```

### `ObservedDiscrete.lean`

Import actuel :

```lean
import Meta.Arithmetic.DynamicGap
```

Import cible :

```lean
import Meta.Arithmetic.RepeatedIndex
```

Declarations qui doivent rester :

```text
ObservedDiscreteSystem
observedTrajectory
observedNatTrajectory
ObservedRepeatedCollision
repeatedIndexCollision_of_observedCollision
```

Ce fichier ne doit pas utiliser :

```text
ArithmeticDynamicGapRow
LocallyRecoveredDynamicReturn
ArithmeticDynamicClosedStabilityRow
```

Ces raccords appartiennent a `ObservedDynamicGap.lean`.

### `ObservedDynamicGap.lean`

Imports cibles :

```lean
import Meta.Dynamics.ObservedWindow
import Meta.Core.DynamicStability
import Meta.Arithmetic.DynamicGap
```

Ce fichier est celui qui doit utiliser :

```text
repeatedIndexDynamicGapRow
ArithmeticDynamicClosedStabilityRow
LocallyRecoveredDynamicReturn
```

### `Meta.lean`

Apres implementation, `Meta.lean` devra importer les nouveaux fichiers dans un
ordre coherent :

```lean
import Meta.Core.TwoPole
import Meta.Arithmetic.CountdownDynamicGap
import Meta.Arithmetic.CountdownGapContraction
```

`Meta.Core.TwoPole` doit apparaitre apres `Meta.Core.ReferentialLength` et avant
les ponts qui s'en servent.

## Ordre d'implementation recommande

### Phase 1 : core positif

1. Creer `Meta/Core/TwoPole.lean`.
2. Ajouter les alias `StructuralTwoPole` et `OperationalTwoPole`.
3. Ajouter les projections nominales.
4. Ajouter les theoremes de refus de contraction en vocabulaire deux-poles.
5. Importer `Meta.Core.TwoPole` dans `Meta.lean`.

### Phase 2 : nettoyage arithmetique

1. Extraire le countdown hors de `Meta/Arithmetic/DynamicGap.lean`.
2. Creer `Meta/Arithmetic/CountdownDynamicGap.lean`.
3. Ajuster les imports.
4. Verifier que `DynamicGap.lean` compile sans importer countdown.

### Phase 3 : nettoyage contraction arithmetique

1. Extraire les declarations countdown hors de `Meta/Arithmetic/GapContraction.lean`.
2. Creer `Meta/Arithmetic/CountdownGapContraction.lean`.
3. Ajuster `Meta.lean`.

### Phase 4 : dynamique observee

1. Alleger `ObservedDiscrete.lean`.
2. Garder le raccord dynamique complet dans `ObservedDynamicGap.lean`.
3. Verifier que la dynamique observee reste strictement constructive.

### Phase 5 : ponts deux-poles

1. Ajouter les vues deux-poles arithmetiques.
2. Ajouter les vues deux-poles countdown.
3. Ne pas encore formaliser la parite.
4. Laisser la parite comme prochaine realisation separatrice.

## Critere de reussite

Le redesign est reussi si :

```text
Core ne depend d'aucune instance.
DynamicGap arithmetique ne depend plus du countdown.
ObservedDiscrete ne depend plus de DynamicGap.
TwoPole expose le gap operationnel en vocabulaire positif.
Countdown devient une realisation terminale explicite.
La documentation `OperationalTwo.md` correspond au code.
Tout compile sans axiome interdit.
```

## Resultat conceptuel attendu

Apres redesign, le cadre dira formellement :

```text
Un gap operationnel est une structure a deux poles medies.
La projection visible peut contracter les poles.
La mediation conserve leur separation enrichie.
La dynamique peut produire une telle structure.
Le countdown en donne une realisation terminale.
La parite pourra en donner une realisation separatrice.
```

Ce n'est donc pas une nouvelle couche decorative. C'est une remise en ordre du
vocabulaire formel pour faire apparaitre ce que le code porte deja.
