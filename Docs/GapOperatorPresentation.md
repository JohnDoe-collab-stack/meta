# Presentation de l'operateur de gap

## Introduction

Ce document presente l'operateur de gap comme une structure formelle de
mediation entre referentiels. Le point de depart n'est pas l'egalite entre deux
poles, ni l'echec d'une identification, mais le passage constructif qui relie
un visible projete a une interface formee.

Dans la lecture dynamique, cette mediation est produite par un retour. Une
coincidence observable n'est pas contractee en simple egalite : elle est
formee comme source dynamique, intersection typee, interface formee, gap
operationnel, puis stabilite fermee recuperee. C'est ce passage du retour
observe vers la fermeture formee qui donne au cadre son contenu dynamique.

La notation de presentation :

```text
1 + gap + 1
```

designe cette mediation explicite. Elle ne doit pas etre lue comme une
arithmetique de longueurs, mais comme une decomposition de role : un pole
visible, une mediation typable, et un pole forme. L'egalite ou la presentation
courte correspond alors a un cas contracte de cette mediation.

Le noyau Lean formalise cette lecture par `LocalProjectiveRecovery` et par le
schema dynamique abstrait `FormedDynamicReturn` /
`LocallyRecoveredDynamicReturn`. Les sections suivantes precisent ces
definitions, les operations derivees qu'elles permettent, puis leurs lectures
dans les couches Tarski, Beth, Bell, Tsirelson, arithmetique enrichie et
dynamique arithmetique.

Dans cette perspective, le cas de Tarski n'est pas pris comme point de depart :
il apparait comme un cas diagonal particulier d'un schema de mediation plus
general.

## Statut formel

L'operateur de gap est formalise en Lean dans le noyau abstrait sous le nom
technique :

```lean
LocalProjectiveRecovery
```

Fichiers Lean de reference :

```text
Meta/Core/ClosedStabilityTheorem.lean
Meta/Core/DynamicStability.lean
```

Declaration Lean centrale :

```lean
structure LocalProjectiveRecovery
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max x y s) where
  formed : Interface
  shadow : Interface
  sameProjection : project formed = project shadow
  separated : formed = shadow -> False
  repair : RepairOf formed
  recovered : Interface
  recovered_eq_formed : recovered = formed
```

Le nom `operateur de gap` est le nom de presentation de cette structure dans
le cadre :

```text
1 + gap + 1
```

Il ne s'agit donc pas d'un objet absent du code. Il s'agit de la lecture
conceptuelle de `LocalProjectiveRecovery`.

La lecture dynamique abstraite est formalisee par :

```lean
FormedDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
```

Elle encode le passage :

```text
source dynamique
-> intersection typee
-> interface formee
-> recuperation locale
-> stabilite fermee recuperee
```

Les couches observees instancient ce schema par :

```lean
observedFormedDynamicReturn
observedLocallyRecoveredDynamicReturn
observedDynamicClosedStabilityRow
observedBoundedWindowFormedDynamicReturn
observedBoundedWindowLocallyRecoveredDynamicReturn
observedBoundedWindowDynamicClosedStabilityRow
```

## Definition mathematique

Soient :

```text
I : type des interfaces enrichies
V : type des visibles
p : I -> V
R : I -> Type
```

Un operateur de gap local au-dessus de `p` est un septuplet :

```text
G = (f, s, h, sep, r, rec, eta)
```

avec :

```text
f   : I
s   : I
h   : p(f) = p(s)
sep : f = s -> False
r   : R(f)
rec : I
eta : rec = f
```

Correspondance Lean :

```text
f   = formed
s   = shadow
h   = sameProjection
sep = separated
r   = repair
rec = recovered
eta = recovered_eq_formed
```

Donc le code encode directement :

```text
interface formee
+ shadow visible
+ meme projection
+ separation enrichie
+ reparation locale
+ recuperation du forme
```

## Lecture structurelle

Le gap porte la mediation constructive entre les referentiels.

Le cadre ne part pas de l'egalite comme norme premiere. Il part d'un passage
forme :

```text
 referentiel visible
+ mediation typable
+ referentiel forme
```

Dans ce passage, l'egalite est un cas particulier : le cas ou la mediation se
contracte. La presentation courte n'est donc pas le point de depart du cadre ;
elle est un regime derive, obtenu lorsque la fibre visible est fidele.

L'operateur de gap donne une forme positive a la mediation :

```text
forme
+ projection partagee
+ separation enrichie
+ reparation locale
+ recuperation du forme
```

Les enonces de non-contractibilite ne definissent pas le gap. Ils apparaissent
seulement lorsque cette mediation est testee contre une lecture courte.

Dans la couche dynamique, cette lecture devient une construction de stabilite :
un retour sur le meme observable n'est pas contracte en simple egalite, mais
forme comme collision repetee, intersection, trace enrichie et recuperation
locale.

La stabilite dynamique vient donc de la formation du retour. La coincidence
visible fournit le point d'entree ; l'intersection typee et la recuperation
locale portent la fermeture.

## Operations derivees

A partir de `LocalProjectiveRecovery`, le code extrait plusieurs operations
projectives.

### Extraction d'obstruction projective

Declaration :

```lean
localProjectiveRecovery_obstruction
```

Enonce conceptuel :

```text
LocalProjectiveRecovery I V p R
-> ProjectionObstruction I V p
```

Le champ `formed` devient le cote gauche de l'obstruction, `shadow` devient le
cote droit, `sameProjection` donne la coincidence visible, et `separated`
donne la separation enrichie.

### Test de contraction de fibre

Declaration :

```lean
localProjectiveRecovery_notFiberFaithful
```

Enonce conceptuel :

```text
LocalProjectiveRecovery I V p R
-> ProjectionFiberFaithful I V p
-> False
```

Ainsi, si on tente de contracter la mediation en presentation courte, le gap
operationnel refute :

```text
meme visible -> meme interface
```

### Test de reconstruction projective globale

Declaration :

```lean
noProjectiveReconstructionOfLocalProjectiveRecovery
```

Enonce conceptuel :

```text
LocalProjectiveRecovery I V p R
-> aucun recover : V -> I ne reconstruit uniformement toutes les interfaces
```

### Consommation par le theoreme abstrait

Declaration :

```lean
locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
```

Ce theorem prend explicitement en entree :

```lean
(localRecovery :
  LocalProjectiveRecovery Interface Visible project RepairOf)
```

Puis il extrait :

```lean
localProjectiveRecovery_obstruction localRecovery
recoveryBundleOfLocalProjectiveRecovery localRecovery
terminalProjectionOfLocalProjectiveRecovery localRecovery
```

Donc le gap operator a un role operationnel : il est consomme par le theoreme
abstrait comme mediation formee, reparation et projection terminale.

## Table de reference Lean

| Role | Declaration Lean | Fichier |
|---|---|---|
| Definition formelle du gap operator | `LocalProjectiveRecovery` | [ClosedStabilityTheorem.lean](../Meta/Core/ClosedStabilityTheorem.lean) |
| Obstruction extraite | `localProjectiveRecovery_obstruction` | [ClosedStabilityTheorem.lean](../Meta/Core/ClosedStabilityTheorem.lean) |
| Refutation de la fidelite | `localProjectiveRecovery_notFiberFaithful` | [ClosedStabilityTheorem.lean](../Meta/Core/ClosedStabilityTheorem.lean) |
| Refutation de la reconstruction globale | `noProjectiveReconstructionOfLocalProjectiveRecovery` | [ClosedStabilityTheorem.lean](../Meta/Core/ClosedStabilityTheorem.lean) |
| Consommation par le theoreme abstrait | `locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem` | [ClosedStabilityTheorem.lean](../Meta/Core/ClosedStabilityTheorem.lean) |
| Retour dynamique forme | `FormedDynamicReturn` | [DynamicStability.lean](../Meta/Core/DynamicStability.lean) |
| Retour dynamique recupere | `LocallyRecoveredDynamicReturn` | [DynamicStability.lean](../Meta/Core/DynamicStability.lean) |
| Stabilite issue du retour dynamique | `locallyRecoveredClosedStabilityOfDynamicReturn` | [DynamicStability.lean](../Meta/Core/DynamicStability.lean) |
| Regime court | `ShortReferentialPresentation` | [ReferentialLength.lean](../Meta/Core/ReferentialLength.lean) |
| Gap structurel | `EnrichedStructuralReferentialLength` | [ReferentialLength.lean](../Meta/Core/ReferentialLength.lean) |
| Gap operationnel | `EnrichedOperationalReferentialLength` | [ReferentialLength.lean](../Meta/Core/ReferentialLength.lean) |

## Audit constructif

Le fichier [ClosedStabilityTheorem.lean](../Meta/Core/ClosedStabilityTheorem.lean)
contient un bloc `AXIOM_AUDIT` en fin de fichier. Ce bloc audite notamment :

```lean
#print axioms Meta.ClosedStabilityTheorem.LocalProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_obstruction
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfLocalProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_notFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_notInformationConserving
#print axioms Meta.ClosedStabilityTheorem.locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
```

La validation attendue est :

```text
does not depend on any axioms
```

pour chacune de ces declarations.

## Idee centrale

L'operateur donne une forme explicite au passage entre referentiels :

```text
1 + gap + 1 >= 2
```

La presentation courte est le cas contracte :

```text
1 + 1 <= 2
```

Il ne s'agit pas d'inserer un nombre entre deux nombres. Il s'agit de rendre
explicite la mediation constructive, ou elle devient :

```text
typable
indexable
transportable
refutable par contraction
localement reparable
```

L'operateur donne un usage constructif au gap : la separation devient une
donnee formee, indexee par `formed`, portant sa propre reparation et
consommable par les theoremes de stabilite. Les echecs de contraction sont des
consequences de cette structure, pas son point de depart.

La forme generale est :

```text
visible gauche
+ gap referentiel
+ interface formee droite
```

ou encore :

```text
projection visible
+ separation enrichie
+ recuperation locale
```

## Forme abstraite

Dans sa forme projective stricte, l'operateur travaille autour d'une projection :

```lean
project : Interface -> Visible
```

La presentation courte correspond au cas ou le visible determine l'interface :

```lean
ProjectionFiberFaithful
```

Lecture :

```text
meme visible
-> meme interface enrichie
```

Dans le vocabulaire transversal :

```lean
ShortReferentialPresentation
```

Le gap structurel apparait lorsque deux interfaces separees partagent le meme
visible :

```lean
ProjectionObstruction
StructuralReferentialGap
EnrichedStructuralReferentialLength
```

Lecture :

```text
meme visible
+ interfaces enrichies separees
```

Le gap operationnel apparait lorsque cette obstruction porte aussi une
reparation locale attachee au forme :

```lean
LocalProjectiveRecovery
OperationalReferentialGap
EnrichedOperationalReferentialLength
```

Lecture :

```text
obstruction
+ interface formee
+ shadow visible
+ recuperation locale indexee
```

Cette structure est l'operateur de gap formel.

Les theoremes transversaux donnent la discipline :

```lean
structuralLength_refutes_shortPresentation
operationalLength_refutes_shortPresentation
structuralLengthOfOperationalLength
```

Donc l'operateur de gap peut se lire comme :

```text
Gap(project)
=
statut de la fibre visible de project
```

Cette ligne est une lecture transversale. Dans le code, il n'existe pas une
declaration unique `Gap(project)` : le statut est distribue entre
`ProjectionFiberFaithful`, `ProjectionObstruction` et `LocalProjectiveRecovery`,
puis nomme par les regimes de `ReferentialLength`.

avec trois regimes :

```text
gap contractible  : la fibre visible est fidele
gap structurel    : la fibre visible contient une separation
gap operationnel  : la separation porte une recuperation locale
```

## Ce que fait l'operateur

L'operateur de gap donne une forme explicite a un passage :

```text
A + gap + B
```

La relation comprimee est le cas ou cette mediation est contractee :

```text
A -> B
```

Il expose alors les sept donnees de `LocalProjectiveRecovery` :

```text
1. formed
2. shadow
3. sameProjection
4. separated
5. repair
6. recovered
7. recovered_eq_formed
```

Dans les couches projectives, arithmetiques et dynamiques, cela se manifeste
par le meme motif :

```text
formed side
shadow side
sameVisible
separated
localRecovery
```

La projection conserve le payload visible. Le forme conserve le role enrichi.
Le gap est l'operateur qui rend ce passage explicite et utilisable : il ne
reste pas au statut d'obstruction externe, il porte la reparation locale du
forme.

## Lecture `1 + gap + 1`

La formule doit etre lue par roles :

```text
1 gauche
= pole visible, code, contexte, etat, occurrence, source

gap
= mediation que la presentation courte contracte

1 droite
= pole forme, assertion, co-indexation, retour, fermeture, borne
```

Le premier `1` et le second `1` n'ont pas toujours le meme role. Le point du
cadre est precisement que le gap porte leur mediation constructive. La
projection visible peut ensuite contracter cette mediation en lecture courte,
mais cette contraction n'est qu'un regime particulier.

## Tarski

Presentation courte :

```text
True(code(phi)) <-> phi
```

Lecture par l'operateur :

```text
code syntaxique
+ gap diagonal
+ assertion semantique
```

Le gap diagonal apparait lorsque la syntaxe projetee ne suffit plus a
contracter l'interface semantique enrichie.

Dans le code :

```lean
TarskiDiagonalObstruction
TarskiSyntaxFiberContractible
TarskiDiagonalObstruction.notContractible
TarskiDiagonalObstruction.structuralGap
TarskiDiagonalObstruction.operationalGap
TarskiDiagonalObstruction.operationalLength
TarskiDiagonalObstruction.refutesShortPresentation
TarskiDiagonalObstruction.visibleOrderEquivalent
TarskiDiagonalObstruction.visible_eq_of_partialOrder
TarskiDiagonalObstruction.partialOrder_visible_eq_not_interface_eq
TarskiDiagonalObstruction.notOrderContractive
TarskiDiagonalReturnSource
TarskiDiagonalIntersection
tarskiFormedDynamicReturn
tarskiLocallyRecoveredDynamicReturn
tarskiLocallyRecoveredClosedStabilityOfDynamicReturn
tarskiDynamicReturn_operationalGap
tarskiDynamicReturn_visibleOrderEquivalent
tarskiDynamicReturn_visible_eq_of_partialOrder
tarskiDynamicReturn_partialOrder_visible_eq_not_interface_eq
tarskiDynamicReturn_notOrderContractive
tarskiDynamicReturn_refutesShortPresentation
```

Lecture :

```text
Tarski fournit un gap diagonal operationnel.
Il expose aussi une ligne de longueur referentielle enrichie et une ligne de
refutation de contraction par ordre visible.
Il expose enfin le processus diagonal comme retour dynamique forme :
source diagonale, intersection typee, interface semantique formee,
recuperation locale et stabilite fermee recuperee.
```

Dans cette presentation, Tarski n'est pas le point de depart du cadre. Il est
une instance derivee : le cas ou la mediation constructive entre code syntaxique
et assertion semantique est forcee dans une presentation courte. La couche
dynamique precise ce point positivement : elle ne part pas de l'obstruction
deja produite, mais des donnees diagonales productrices, puis forme
l'intersection ou le retour devient recuperable.

La hierarchie de lecture est donc :

```text
operateur de gap
-> mediation constructive entre referentiels
-> regimes de contraction ou non-contraction
-> Tarski comme gap diagonal particulier
-> Tarski sur les ordres visibles : meme syntaxe projetee, interface separee
-> Tarski comme retour diagonal forme : source, intersection, recuperation
```

## Beth

Beth donne le test de contractibilite du gap.

Dans la lecture courte :

```text
le visible determine implicitement l'enrichi
```

Dans la lecture enrichie :

```text
gap = 0
<-> fibre visible fidele
<-> definition explicite sur fibres visibles realisees
```

Dans le code :

```lean
ImplicitlyDeterminedByVisible
ExplicitDefinitionOnRealizedVisible
BethContractibleGap
bethCollapse_iff_implicitDetermination
bethCollapse_iff_explicitDefinitionOnRealizedVisible
```

Les gaps structurels et operationnels refutent le collapse Beth :

```lean
structuralGap_refutes_bethCollapse
operationalGap_refutes_bethCollapse
```

Lecture :

```text
Beth mesure si l'operateur de gap se contracte.
```

## Bell

Bell donne une instance pre-probabiliste de l'operateur.

Presentation courte :

```text
A0, A1, B0, B1
dans un meme index global
```

Ce regime produit la borne pointwise :

```text
S = +/- 2
```

Lecture enrichie :

```text
contextes locaux
+ gap d'amalgamation
+ co-indexation globale
```

Dans le code :

```lean
BellContextAmalgamation
BellAmalgamationCompatibility
BellShortCoindexationOfContexts
BellAmalgamationGap
bellAmalgamationGap_refutes_shortCoindexation
```

Lecture :

```text
Bell classique mesure la possibilite d'une co-indexation courte.
Bell gap mesure l'obstruction pre-probabiliste a cette co-indexation.
```

## Tsirelson

Tsirelson est le cas ou le vocabulaire de gap est repris sous forme de gap
structure certifie par une borne. Cette couche est soutenue par le code comme
`BellTsirelsonStructuredGap`, mais elle n'est pas encore encodee comme un
`EnrichedOperationalReferentialLength` issu d'une projection `Interface ->
Visible`.

Presentation classique :

```text
borne classique : 2
borne quantique : 2 sqrt(2)
borne algebrique : 4
```

Lecture enrichie, au niveau de presentation :

```text
co-indexation courte
+ gap quantique structure
+ borne certifiee
```

Dans le code, la borne vient d'un certificat positif interne :

```lean
BellTsirelsonObservableTuple
BellTsirelsonSumOfSquaresCertificate
BellTsirelsonStructuredGap
BellTsirelsonRow
BellTsirelsonRow.tsirelson_bound
```

La couche standard fixe la forme constructive :

```lean
StandardTsirelsonCertificateData
StandardTsirelsonIntrinsicPackage
standardTsirelsonRow
standardTsirelsonRow_bound
```

Lecture strictement soutenue :

```text
Tsirelson fournit une ligne de gap structure certifie :
tuple CHSH structure + certificat somme-de-carres positif + borne interne.
```

## Arithmetique enrichie

Dans l'arithmetique enrichie, l'operateur de gap agit sur la projection payload :

```lean
tracePayloads : List NatTraceAtom -> List Nat
```

La projection visible oublie le role de l'atome :

```text
payload(excess k) = k
payload(value k)  = k
```

mais l'interface enrichie distingue :

```text
excess k
value k
```

Le gap arithmetique est donc :

```text
nombre comme valeur
+ gap de role
+ nombre comme exces de recomposition
```

Dans le code :

```lean
formedPositiveExcessOfIntersection
arithmeticGapFormedTrace
arithmeticGapPayloadShadow
arithmeticGap_sameVisible
arithmeticGap_separated
arithmeticOperationalGapOfIntersection
```

Cas canonique :

```text
intersection.excess = 0
formedPositiveExcess = 1
```

Lecture :

```text
le `1` final est l'exces positif de fermeture.
```

## Dynamique arithmetique

La dynamique est le lieu ou le retour observable est transforme en stabilite
fermee. Elle porte l'index temporel et convertit une repetition en donnee
formee. Au niveau abstrait, cette conversion est le schema :

```lean
FormedDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
```

Ce schema ne depend pas de `Nat`, d'une trajectoire particuliere, ni d'une
fenetre bornee. Les couches arithmetiques et observees en sont des
realisations concretes.

Presentation courte :

```text
meme observable Nat
```

Lecture enrichie :

```text
premiere occurrence
+ gap temporel de retour
+ seconde occurrence comme fermeture
```

Une collision repetee donne :

```lean
RepeatedIndexCollision
repeatedIndexIntersection
ArithmeticDynamicGapRow
ArithmeticDynamicClosedStabilityRow
```

Le gap dynamique porte un exces terminal :

```text
secondTime + 1
```

Lecture :

```text
le retour sur le meme observable transforme une coincidence visible
en index dynamique enrichi, puis en fermeture typee recuperee.
```

Le pont observe etend cette construction a un systeme discret arbitraire muni
d'une observation naturelle :

```lean
ObservedDiscreteSystem
ObservedRepeatedCollision
ObservedBoundedWindow
observedFormedDynamicReturn
observedLocallyRecoveredDynamicReturn
observedDynamicClosedStabilityRow
observedBoundedWindowFormedDynamicReturn
observedBoundedWindowLocallyRecoveredDynamicReturn
observedBoundedWindowDynamicClosedStabilityRow
```

Ainsi, une fenetre observee bornee produit constructivement une collision, et
cette collision produit une ligne de stabilite fermee. La stabilite ne vient
pas d'une egalite nue, mais du retour forme comme mediation dynamique.

## Synthese

L'operateur de gap fournit le schema transversal :

```text
Tarski :
code + gap diagonal + assertion + retour diagonal forme

Beth :
visible + test de contractibilite + definition explicite

Bell :
contextes + gap d'amalgamation + co-indexation

Tsirelson :
observables + gap structure certifie + borne positive

Nat :
valeur visible + gap de role + exces de recomposition

Nat dynamique :
occurrence + gap de retour + occurrence fermante
```

Dans les couches dynamiques, ce schema a une fonction precise : transformer un
retour observable en stabilite fermee recuperee. La dynamique donne ainsi une
lecture positive du gap : le retour n'est pas efface dans l'egalite visible, il
est forme, separe de son ombre, puis recupere localement.

Le cadre ne reduit pas ces cas a une analogie. Pour Tarski, Beth, Bell, Nat et
Nat dynamique, il leur donne directement une forme projective ou operationnelle
dans l'arbre Lean courant :

```text
projection
+ obstruction de fibre
+ recuperation locale
```

Pour Tsirelson, le raccord formel courant a un statut precis different :

```text
tuple structure
+ certificat positif
+ borne certifiee
```

Il appartient donc a la meme famille conceptuelle des gaps structures, tandis
que la couche Lean courante le maintient hors du type projectif transversal.

La phrase finale est :

```text
L'operateur de gap porte la mediation constructive entre les referentiels :
il la rend typable, indexable, transportable, reparable et consommable.
```
