# Preparation d'une abstraction core pour la stabilite dynamique

## Objectif

Ce document prepare l'implementation d'un fichier Lean abstrait :

```text
Meta/Core/DynamicStability.lean
```

L'objectif n'est pas de deplacer les couches concretes `Dynamics` ou
`Arithmetic` dans `Core`. L'objectif est d'extraire le schema formel commun
qui est deja present dans le code :

```text
retour dynamique
-> coincidence visible
-> intersection typee
-> interface formee
-> gap operationnel
-> recuperation locale
-> stabilite fermee
```

Le noyau doit donc porter la grammaire abstraite du retour forme, tandis que
les dossiers `Arithmetic` et `Dynamics` doivent rester les realisations
concretes de cette grammaire.

## Constat dans le code actuel

La dynamique concrete est actuellement distribuee ainsi :

```text
Meta/Dynamics/ObservedDiscrete.lean
Meta/Dynamics/ObservedWindow.lean
Meta/Dynamics/ObservedDynamicGap.lean
Meta/Arithmetic/RepeatedIndex.lean
Meta/Arithmetic/DynamicGap.lean
```

La chaine effective est :

```text
ObservedRepeatedCollision
-> RepeatedIndexCollision
-> repeatedIndexIntersection
-> formedTraceOfIntersection
-> localProjectiveRecoveryOfIntersection
-> repeatedIndexClosedStabilityInstance
```

Le point essentiel est que la collision observee n'est pas simplement lue
comme une egalite. Elle produit une intersection typee. Cette intersection
forme une interface enrichie dont la projection visible coincide avec une
ombre, mais dont le role forme reste separe.

Dans le code arithmetique, cette separation est explicite :

```text
formedTraceOfIntersection_same_payloadOnlyPayload
formedTraceOfIntersection_ne_payloadOnlyTrace
localProjectiveRecoveryOfIntersection
```

Autrement dit :

```text
project formed = project shadow
formed = shadow -> False
repair formed
recovered = formed
```

C'est exactement le motif abstrait du gap operationnel.

## Ce qui doit entrer dans Core

Le futur fichier `Meta/Core/DynamicStability.lean` devrait etre independant de :

```text
Nat
List NatTraceAtom
trajectoires
fenetres bornees
pigeonhole fini
countdown
```

Il devrait seulement formaliser le passage general :

```text
une source dynamique produit une intersection;
l'intersection forme une interface;
cette interface porte une recuperation projective locale;
la recuperation locale donne une stabilite fermee recuperee.
```

Le noyau existe deja en grande partie dans :

```text
BidirectionalCompleteness
StrongTerminalCycleFromIntersection
InterfaceWitness
LocalProjectiveRecovery
LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
```

La nouvelle couche ne doit donc pas recreer ces notions. Elle doit les
assembler sous une lecture dynamique abstraite.

## Proposition de structures

### Retour forme

La structure minimale utile doit lier une source dynamique a une intersection
typee. Une structure contenant seulement `source` et `branch` serait trop
faible : elle ne donnerait rien a consommer au theoreme de stabilite fermee.

La forme suivante a ete testee avec `lake env lean --stdin` :

```lean
structure FormedDynamicReturn
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Source : Type a) :
    Type (max u v w a) where
  source : Source
  intersection : complete.Intersection branch
```

Cette structure capture le vrai seuil formel :

```text
retour dynamique
-> intersection typee
```

Elle ne dit pas encore comment l'intersection a ete obtenue. C'est important :
dans les instances concretes, elle peut venir d'une collision observee, d'une
fenetre bornee, d'un repeated index, ou d'une autre source.

### Retour dynamique recupere

Le schema complet doit aussi lier l'intersection a une interface formee, a une
realisation, et a un gap operationnel.

```lean
structure LocallyRecoveredDynamicReturn
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    (branch : Branch)
    (Source : Type a)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z)
    (Visible : Type r)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v w a x y z r s) where
  formedReturn : FormedDynamicReturn complete branch Source
  formed : InterfaceWitness Interface WitnessOf
  realizes :
    RealizesInterface
      (strongTerminalCycleFromIntersection
        complete
        coherence
        formedReturn.intersection)
      formed.interface
  localRecovery :
    LocalProjectiveRecovery Interface Visible project RepairOf
  localRecovery_sameInterface :
    localRecovery.formed = formed.interface
```

Cette esquisse exprime le coeur :

```text
la source dynamique donne une intersection;
l'intersection forme une interface;
la meme interface porte une recuperation locale.
```

Le choix important est que `branch` reste un parametre externe de la structure.
C'est le style deja utilise par le noyau pour
`StrongTerminalCycleFromIntersection` et
`LocallyRecoveredNonProjectiveClosedStabilityFromIntersection`. Cela evite une
dependance impossible ou maladroite de `RealizesInterface` envers un champ
declare plus tard.

Cette forme evite aussi les difficultes d'elaboration que pourrait introduire
un `extends` dependent dans une premiere version.

## Theoreme attendu

Le theoreme principal ne devrait pas prouver une nouvelle mathematique. Il
devrait emballer proprement le theoreme deja existant :

```lean
def recoveredClosedStabilityOfDynamicReturn
    (return : LocallyRecoveredDynamicReturn ...)
    : LocallyRecoveredNonProjectiveClosedStabilityFromIntersection ... :=
  locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
    complete
    coherence
    return.formedReturn.intersection
    return.formed
    return.realizes
    return.localRecovery
    return.localRecovery_sameInterface
```

Le gain est architectural et conceptuel :

```text
la stabilite fermee recuperee devient le resultat naturel d'un retour
dynamique forme.
```

## Lecture conceptuelle

Le coeur abstrait ne doit pas dire :

```text
une dynamique revient au meme point, donc il y a stabilite.
```

Il doit dire :

```text
une dynamique produit un retour;
ce retour devient une intersection typee;
l'intersection forme une interface;
la projection visible peut identifier cette interface a une ombre;
le gap operationnel conserve la separation et fournit la recuperation;
la stabilite fermee est recuperee sur l'interface formee.
```

La stabilite vient donc de la formation du retour, pas de la seule egalite
visible.

## Ce qui doit rester hors de Core

Les objets suivants doivent rester dans les couches concretes :

```text
ObservedDiscreteSystem
ObservedRepeatedCollision
ObservedBoundedWindow
RepeatedIndexCollision
NatTrajectoryRepeatedIndexCollision
NatTrajectoryWindowCollision
NatFiniteWindowCollisionData
CountdownClosedStabilityHeightPackage
ArithmeticDynamicGapRow
ArithmeticDynamicClosedStabilityRow
```

Ces objets sont des realisations du schema abstrait. Ils ne sont pas le schema
lui-meme.

## Effet sur l'architecture

L'architecture visee serait :

```text
Meta.Core.ClosedStabilityTheorem
Meta.Core.Gap
Meta.Core.ReferentialLength
Meta.Core.DynamicStability

Meta.Arithmetic.Core
Meta.Arithmetic.RepeatedIndex
Meta.Arithmetic.DynamicGap

Meta.Dynamics.ObservedDiscrete
Meta.Dynamics.ObservedWindow
Meta.Dynamics.ObservedDynamicGap
```

Les dependances doivent rester orientees ainsi :

```text
Core -> rien de specifique
Arithmetic -> Core
Dynamics -> Arithmetic + Core
Tarski/Beth/Bell -> Core
Synthesis -> instances particulieres
```

Il faut eviter absolument :

```text
Core -> Arithmetic
Core -> Dynamics
Core -> Tarski
```

## Risques d'implementation

### Risque 1 : abstraction trop faible

Une structure qui contient seulement une source et une branche ne sert presque
a rien. Le vrai seuil est l'intersection typee.

Donc la premiere structure utile doit probablement contenir :

```text
source
branch
intersection
```

### Risque 2 : abstraction trop concrete

Si le fichier core mentionne `Nat`, `List`, `tracePayloads`, `excess`,
`RepeatedIndexCollision` ou `ObservedRepeatedCollision`, l'extraction echoue.
Ces noms appartiennent aux instances.

### Risque 3 : doublonner le noyau existant

Le fichier ne doit pas recreer :

```text
LocalProjectiveRecovery
RecoveredNonProjectiveClosedStabilityFromIntersection
LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
```

Il doit seulement donner leur lecture dynamique et fournir un emballage
canonique.

### Risque 4 : imposer une temporalite artificielle

Le core ne doit pas forcer une notion de temps. Dans les instances actuelles,
le temps est souvent `Nat`, mais le schema abstrait n'en depend pas. Le retour
peut etre indexe par une source dynamique quelconque.

## Plan d'implementation

1. Creer `Meta/Core/DynamicStability.lean`.

2. Importer seulement :

```lean
import Meta.Core.Gap
```

ou, si necessaire :

```lean
import Meta.Core.ReferentialLength
```

3. Definir une structure minimale du retour forme :

```lean
structure FormedDynamicReturn ...
```

4. Definir une structure complete du retour recupere :

```lean
structure LocallyRecoveredDynamicReturn ...
```

5. Definir le theoreme d'emballage :

```lean
def locallyRecoveredClosedStabilityOfDynamicReturn ...
```

6. Ajouter les audits d'axiomes.

7. Importer le nouveau fichier dans `Meta.lean`.

8. Ne modifier les couches `Arithmetic` et `Dynamics` qu'apres compilation du
   noyau abstrait. Dans un second temps, ajouter des fonctions qui emballent
   les lignes existantes comme instances de `LocallyRecoveredDynamicReturn`.

## Critere de reussite

La premiere etape est reussie si :

```text
lake build
```

compile avec :

```text
Meta.Core.DynamicStability
```

sans axiomes nouveaux, et sans import de couche concrete.

Le test architectural est :

```text
rg "import Meta.Arithmetic|import Meta.Dynamics|import Meta.Tarski" Meta/Core
```

ne doit pas montrer de dependance interdite pour `DynamicStability.lean`.

Le prototype minimal suivant a ete verifie avec `lake env lean --stdin` :

```text
import Meta.Core.Gap

FormedDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
```

Resultat de l'audit :

```text
FormedDynamicReturn does not depend on any axioms
LocallyRecoveredDynamicReturn does not depend on any axioms
locallyRecoveredClosedStabilityOfDynamicReturn does not depend on any axioms
```

## Formule de synthese

La dynamique fournit le retour. Le retour forme une intersection. L'intersection
porte une interface. La projection visible produit une ombre. Le gap
operationnel maintient la separation et fournit la recuperation. La stabilite
fermee est alors recuperee sur l'interface formee.
