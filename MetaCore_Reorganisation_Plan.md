# Plan de réorganisation du noyau `Meta/Core`

**Version : 1.0**
**Statut : plan d’implémentation exécutable**
**Périmètre : `Meta/Core` uniquement**
**Principe : refactoring conservatif, sans changement mathématique implicite**
**Convention : Markdown pur, sans LaTeX, avec symboles Unicode usuels**

---

# 0. Décision d’architecture

Le Core doit être réorganisé.

La raison n’est pas une insuffisance des preuves existantes. La raison est que
l’organisation actuelle place au premier plan les conséquences projectives du
gap, tandis que le principe conceptuel premier est la relaxation du droit de
transport :

```text
Sep + Coord
→ Use
→ transport autorisé.
```

L’ordre conceptuel cible est :

```text
relaxation du principe d’identification
→ identité projetée comme instance particulière
→ gap projectif et non-contraction
→ complétude bilatérale et capture
→ retour dynamique
→ lectures de rôles
→ spécialisations d’ordre et de parité.
```

La réorganisation doit conserver simultanément :

```text
les preuves ;
les noms publics ;
les univers ;
les sorties de #print axioms ;
les imports downstream ;
la distinction entre Type et Prop ;
les indices dépendants.
```

---

# 1. Objectifs

## 1.1 Objectif conceptuel

Faire apparaître dans le code l’ordre suivant :

```text
primitive :
  coordination relaxée et transport non contractif ;

instance particulière :
  identité interne ou identité projetée ;

conséquence :
  gap structurel ou opérationnel ;

stabilisation :
  intersection, cohérence bilatérale et cycle ;

dynamique :
  production, récupération et transport du gap ;

spécialisations :
  rôles, ordre, parité, Tarski.
```

## 1.2 Objectif mathématique immédiat

Ajouter au Core Lean le théorème central du document 0.5 :

> La classe des relations d’usage `HasUse` exactement représentables par une
> égalité projetée est strictement incluse dans la classe des relations d’usage
> réalisables par un régime relaxé cohérent et composable.

Sous forme condensée :

```text
InternalIdentityTransport
⊆
ProjectedIdentityTransport
⊊
RelaxedUsageTransport.
```

La stricte inclusion porte sur les relations :

```text
HasUse(I, γ, x, y)
:=
Nonempty (I.Use γ x y).
```

Elle ne compare pas l’expressivité générale de tous les formalismes.

## 1.3 Objectif technique

Réduire le nombre de modules conceptuellement redondants sans créer un nouveau
monolithe.

Le refactoring doit :

```text
extraire les deux racines du Core ;
consolider les couches d’alias ;
conserver des façades de compatibilité ;
éviter les cycles d’import ;
permettre une migration commit par commit.
```

---

# 2. Non-objectifs

Cette réorganisation ne doit pas :

```text
modifier les théorèmes Tarski ;
construire l’instance arithmétique Foundation ;
réparer TarskiCausalAlgorithm ;
introduire Collatz ;
changer les définitions de vérité ;
remplacer les preuves existantes par de nouvelles preuves ;
renommer massivement les déclarations publiques ;
ajouter Classical, Choice ou Quotient ;
transformer les structures dépendantes en propositions aplaties.
```

Ces travaux appartiennent à des chantiers ultérieurs.

---

# 3. État actuel

## 3.1 Modules actuels du Core

```text
ClosedStabilityTheorem.lean
Gap.lean
ReferentialLength.lean
TwoPole.lean
ProjectedIdentity.lean
DynamicStability.lean
DynamicTwoPole.lean
DynamicRoleCarrier.lean
ParitySeparation.lean
DynamicParitySeparation.lean
OrderGap.lean
RelaxedUsageRegime.lean
```

## 3.2 Graphe d’import actuel

```text
ClosedStabilityTheorem
├── Gap
│   ├── ReferentialLength
│   │   └── TwoPole
│   │       └── ParitySeparation
│   └── DynamicStability
└── ProjectedIdentity

TwoPole + DynamicStability
└── DynamicTwoPole
    └── DynamicRoleCarrier

DynamicRoleCarrier + ParitySeparation
└── DynamicParitySeparation

ReferentialLength + DynamicTwoPole
└── OrderGap

RelaxedUsageRegime
  [branche autonome, sans raccord central]
```

## 3.3 Problème d’architecture

Le fichier qui porte le principe le plus général :

```text
RelaxedUsageRegime.lean
```

est actuellement une branche périphérique.

À l’inverse, les vues dérivées :

```text
Gap
ReferentialLength
TwoPole
```

occupent trois niveaux de dépendance, alors qu’elles partagent essentiellement
les mêmes données.

## 3.4 Déclarations déjà présentes

Le Core possède déjà les primitives suivantes :

```text
RelaxedInterfaceRegime
NonContractiveUse
LocalTransportChain

BidirectionalCompleteness
TerminalCycle
RoundTripCoherence
StrongTerminalCycleFromIntersection
InterfaceWitness

ProjectionObstruction
ProjectionFiberFaithful
ProjectionInformationConserving
LocalProjectiveRecovery
LocalTruthGapRecovery

ProjectedIdentityCell
InterfaceIdentityOfUse
InterfaceTransport
ConstructiveInterfaceChain

ContractibleReferentialGap
StructuralReferentialGap
OperationalReferentialGap

ShortReferentialPresentation
EnrichedStructuralReferentialLength
EnrichedOperationalReferentialLength

StructuralTwoPole
OperationalTwoPole

FormedDynamicReturn
LocallyRecoveredDynamicReturn
DynamicRoleCarrier
DynamicParitySeparation.
```

## 3.5 Déclarations centrales encore absentes

Le Core fourni ne contient pas encore les déclarations finales suivantes :

```text
HasUse
ExactProjectiveRepresentation
relaxedRegimeOfProjection
directionalRelaxedRegime
CompositionalUse
hasUse_symmetric_of_exactProjectiveRepresentation
directionalRelaxedRegime_not_projective
strictRelaxationOfIdentity.
```

Le premier chantier doit ajouter ces objets avant tout déplacement massif de
fichiers.

---

# 4. Principes non négociables de migration

## 4.1 Refactoring conservatif

Un déplacement de déclaration ne doit modifier ni son type ni sa preuve.

Le contrôle de base est :

```text
ancien type imprimé
=
nouveau type imprimé.
```

## 4.2 Compatibilité des imports

Pendant toute la migration, les imports historiques doivent continuer à
compiler :

```lean
import Meta.Core.ClosedStabilityTheorem
import Meta.Core.Gap
import Meta.Core.ReferentialLength
import Meta.Core.TwoPole
import Meta.Core.DynamicStability
import Meta.Core.DynamicTwoPole
import Meta.Core.ParitySeparation
import Meta.Core.DynamicParitySeparation
```

Les anciens fichiers deviennent temporairement des façades d’import.

## 4.3 Conservation des namespaces

Les déclarations existantes conservent :

```text
namespace Meta
namespace ClosedStabilityTheorem
```

Le régime relaxé conserve :

```text
namespace Meta
namespace RelaxedUsageRegime
```

Le nouveau théorème de stricte relaxation est défini dans :

```text
Meta.RelaxedUsageRegime
```

Un alias dans `Meta.ClosedStabilityTheorem` n’est ajouté que si un usage aval le
justifie.

## 4.4 Pas de changement d’alias silencieux

Les déclarations actuellement définies par :

```lean
abbrev
```

restent des `abbrev` pendant le refactoring.

Passer de `abbrev` à `def` ou inversement peut modifier la réduction
élaborationnelle et casser des preuves par `rfl`.

## 4.5 Aucun nouvel axiome

Chaque phase doit conserver les audits :

```lean
#print axioms ...
```

Aucune déclaration déplacée ne doit acquérir une dépendance à :

```text
Classical.choice
propext
Quot.sound
Classical.decEq
```

si elle n’en dépendait pas avant.

## 4.6 Un seul changement conceptuel par commit

Un commit de déplacement ne contient pas simultanément :

```text
un renommage ;
une généralisation ;
une nouvelle preuve ;
un changement de namespace.
```

---

# 5. Architecture cible

Le nombre de fichiers d’implémentation cible est inférieur au nombre actuel.

```text
Meta/Core/
├── RelaxedUsageRegime.lean
├── StrictRelaxation.lean
├── BilateralCore.lean
├── ProjectiveCore.lean
├── ProjectedIdentity.lean
├── ClosedStabilityTheorem.lean
├── DynamicCore.lean
├── DynamicRoleCarrier.lean
├── OrderGap.lean
└── Parity.lean
```

Les anciens petits modules restent temporairement comme façades :

```text
Gap.lean
ReferentialLength.lean
TwoPole.lean
DynamicStability.lean
DynamicTwoPole.lean
ParitySeparation.lean
DynamicParitySeparation.lean
```

Ils pourront être supprimés dans une phase ultérieure seulement après migration
de tous les imports aval.

---

# 6. Graphe d’import cible

```text
RelaxedUsageRegime
├── StrictRelaxation
└── [aucune dépendance projective primitive]

BilateralCore
  [indépendant des projections]

ProjectiveCore
  [indépendant des cycles bilatéraux]

ProjectiveCore
└── ProjectedIdentity

BilateralCore + ProjectiveCore
└── ClosedStabilityTheorem

ClosedStabilityTheorem + ProjectiveCore
└── DynamicCore

DynamicCore
└── DynamicRoleCarrier

ProjectiveCore + DynamicCore
└── OrderGap

ProjectiveCore + DynamicRoleCarrier
└── Parity

RelaxedUsageRegime + ProjectedIdentity
└── StrictRelaxation
```

Les deux racines véritables sont donc :

```text
RelaxedUsageRegime
BilateralCore.
```

La couche projective est une instance et une infrastructure dérivée ; elle
n’est plus la racine conceptuelle unique.

---

# 7. Responsabilité de chaque module cible

## 7.1 `RelaxedUsageRegime.lean`

Ce fichier conserve et étend la branche actuelle.

### Déclarations existantes conservées

```text
RelaxedInterfaceRegime
RelaxedInterfaceRegime.defaultContext
RelaxedInterfaceRegime.defaultContextRead
NonContractiveUse
NonContractiveUse.use
NonContractiveUse.transport
NonContractiveUse.defaultTransport
LocalTransportChain
localTransportChain
defaultLocalTransportChain.
```

### Déclarations nouvelles à ajouter

```lean
def HasUse
    {X : Type u}
    (I : RelaxedInterfaceRegime X)
    (gamma : I.Ctx)
    (x y : X) :
    Prop :=
  Nonempty (I.Use gamma x y)
```

```lean
structure CompositionalUse
    {X : Type u}
    (I : RelaxedInterfaceRegime X) where
  identity :
    (gamma : I.Ctx) ->
    (x : X) ->
      I.Use gamma x x

  compose :
    {gamma : I.Ctx} ->
    {x y z : X} ->
      I.Use gamma x y ->
      I.Use gamma y z ->
      I.Use gamma x z
```

Une seconde structure pourra formaliser la compatibilité du transport avec la
composition, mais elle ne doit pas bloquer le premier théorème de stricte
expressivité.

### Critère d’acceptation

```text
le fichier compile seul ;
aucun import supplémentaire ;
aucun axiome nouveau ;
les anciennes déclarations gardent le même type.
```

---

## 7.2 `StrictRelaxation.lean`

Nouveau fichier portant le théorème central.

### Imports

```lean
import Meta.Core.RelaxedUsageRegime
import Meta.Core.ProjectedIdentity
```

### Représentation projective exacte

```lean
structure ExactProjectiveRepresentation
    {X : Type u}
    (I : RelaxedInterfaceRegime X) where
  Visible :
    I.Ctx -> Type v

  project :
    (gamma : I.Ctx) ->
      X -> Visible gamma

  use_iff_projectedIdentity :
    (gamma : I.Ctx) ->
    (x y : X) ->
      HasUse I gamma x y <->
        project gamma x = project gamma y
```

Le mot `Exact` signifie :

```text
usage autorisé
↔
égalité projetée.
```

Une simple implication ne suffit pas, car une projection constante rendrait la
notion triviale.

### Théorèmes de fermeture d’une représentation projective

```lean
theorem hasUse_refl_of_exactProjectiveRepresentation
```

```lean
theorem hasUse_symm_of_exactProjectiveRepresentation
```

```lean
theorem hasUse_trans_of_exactProjectiveRepresentation
```

Ces trois théorèmes montrent que `HasUse` devient une relation d’équivalence
lorsqu’elle est exactement représentée par une égalité de projection.

### Inclusion de l’identité projetée

Construire :

```lean
def relaxedRegimeOfProjection
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) :
    RelaxedInterfaceRegime X
```

Choix recommandé :

```text
Ctx := Unit
Read := Unit
Out := Visible
read := project
Sep γ x y := x = y → False
Coord γ x y := project x = project y
Use γ x y := project x = project y
OutRel := equality.
```

Puis :

```lean
def exactProjectiveRepresentationOfProjection
```

### Inclusion de l’identité interne

Prendre :

```text
Visible := X
project := id.
```

Prouver :

```text
project x = project y
↔
x = y.
```

Le théorème d’inclusion est :

```lean
theorem internalIdentityTransport_in_projectedIdentityTransport
```

### Modèle directionnel minimal

```lean
inductive Phase where
  | before
  | after
```

```lean
inductive PhaseUse : Phase -> Phase -> Type where
  | reflBefore : PhaseUse Phase.before Phase.before
  | advance : PhaseUse Phase.before Phase.after
  | reflAfter : PhaseUse Phase.after Phase.after
```

Aucun constructeur ne produit :

```text
PhaseUse after before.
```

Construire :

```lean
def directionalRelaxedRegime :
  RelaxedInterfaceRegime Phase
```

avec :

```text
Use := PhaseUse
Coord := PhaseUse
OutRel := PhaseUse
read := id.
```

Puis construire :

```lean
def directionalCompositionalUse :
  CompositionalUse directionalRelaxedRegime
```

### Obstruction à la représentation projective

Prouver :

```lean
theorem directional_hasUse_forward
```

```lean
theorem directional_not_hasUse_backward
```

Puis :

```lean
theorem directionalRelaxedRegime_not_exactProjective :
  ExactProjectiveRepresentation directionalRelaxedRegime -> False
```

La preuve utilise uniquement :

```text
usage before → after ;
symétrie forcée par l’égalité ;
absence de after → before.
```

### Théorème final

```lean
structure StrictRelaxationOfIdentity where
  projectiveEmbedding : ...
  directionalModel : ...
  directionalNotProjective : ...
```

ou, plus simplement, deux théorèmes séparés et un théorème façade :

```lean
theorem projectedIdentityTransport_strictlyIncludedIn_relaxedUsageTransport
```

### Critère d’acceptation

```text
modèle habité ;
usage directionnel explicite ;
composition explicite ;
preuve de non-représentabilité ;
aucun axiome ;
aucune dépendance à Tarski ;
aucune dépendance à l’arithmétique.
```

---

## 7.3 `BilateralCore.lean`

Nouveau fichier extrait de `ClosedStabilityTheorem.lean`.

### Déclarations à déplacer sans changement

```text
BidirectionalCompleteness
forwardOfComplete
backwardOfComplete
intersectionOfComplete
completeOfIntersection

TerminalCycle
terminalCycleOfComplete
terminalCycleOfIntersection

CoherentTerminalCycle
coherentTerminalCycleOfComplete
coherentTerminalCycleOfIntersection

ReextractionCoherence
IntersectionRecompositionCoherence
RoundTripCoherence

StrongTerminalCycle
StrongTerminalCycleFromIntersection
strongTerminalCycleOfIntersection
strongTerminalCycleFromIntersection

InterfaceWitness
interfaceOf
witnessOf

WeakClosedStability
StrongClosedStability
StrongClosedStabilityFromIntersection
weakOfStrongClosedStability

SelfCoupling
commonStabilityOfStrongTerminalCycle.
```

### Raison du regroupement

Ces déclarations ne dépendent ni d’une projection, ni d’un gap, ni d’un ordre.
Elles forment la théorie de la fermeture bilatérale et de l’intersection typée.

### Critère d’acceptation

```text
aucun import ;
namespace inchangé ;
les preuves rfl restent rfl ;
ClosedStabilityTheorem importe BilateralCore ;
les imports aval historiques compilent encore.
```

---

## 7.4 `ProjectiveCore.lean`

Nouveau fichier consolidant le noyau projectif et les vues actuellement
réparties entre plusieurs fichiers.

### Déclarations à extraire de `ClosedStabilityTheorem.lean`

```text
ProjectionObstruction
ProjectionFiberFaithful
ProjectionInformationConserving
projectionFiberFaithful_of_informationConserving
projectionObstruction_notFiberFaithful
projectionObstruction_notInformationConserving
noProjectiveReconstruction

DiagonalCertificate
projectionObstructionOfDiagonalCertificate

LocalProjectiveRecovery
localProjectiveRecovery_obstruction
noProjectiveReconstructionOfLocalProjectiveRecovery
localProjectiveRecovery_notFiberFaithful
localProjectiveRecovery_notInformationConserving

ReferentialScene
GeometricFormation
ProjectedLocalTruth
LocalTruthGapRecovery
les scènes et théorèmes associés

RecoveryBundle
TerminalProjection.
```

### Déclarations à absorber depuis `Gap.lean`

```text
ContractibleReferentialGap
StructuralReferentialGap
OperationalReferentialGap
structuralGapOfOperationalGap
les théorèmes de non-contractibilité et non-reconstruction.
```

### Déclarations à absorber depuis `ReferentialLength.lean`

```text
ShortReferentialPresentation
EnrichedStructuralReferentialLength
EnrichedOperationalReferentialLength
les trois conversions et réfutations.
```

### Déclarations à absorber depuis `TwoPole.lean`

```text
StructuralTwoPole
OperationalTwoPole
les projections de pôles
les théorèmes de même visible et séparation
les réparations et récupérations
les réfutations de présentation courte.
```

### Pourquoi consolider ces fichiers

Les trois couches :

```text
Gap
ReferentialLength
TwoPole
```

ne définissent pas trois théories indépendantes.

Elles donnent trois lectures d’un même noyau projectif :

```text
obstruction ;
longueur référentielle ;
deux-pôles.
```

Le regroupement réduit le bruit d’import sans supprimer les noms publics.

### Façades transitoires

`Gap.lean` devient :

```lean
import Meta.Core.ProjectiveCore
```

Même stratégie pour :

```text
ReferentialLength.lean
TwoPole.lean.
```

### Critère d’acceptation

```text
les anciens modules compilent comme façades ;
les noms restent identiques ;
aucun cycle d’import avec ProjectedIdentity ;
les audits d’axiomes restent inchangés.
```

---

## 7.5 `ProjectedIdentity.lean`

Le fichier reste un module d’implémentation autonome.

### Changement d’import

Avant :

```lean
import Meta.Core.ClosedStabilityTheorem
```

Après :

```lean
import Meta.Core.ProjectiveCore
```

### Déclarations conservées

Toutes les déclarations actuelles restent dans le fichier :

```text
ProjectedIdentityCell
ReadIdentityCell
InternalIdentity
ProjectedIdentity
InterfaceIdentityOfUse
InterfaceReadTransport
InterfaceTransport
IdentityOfUseCell
ConstructiveInterfaceChain
PositiveProjectedInvariant
PositiveReadInvariant
ConstrainedProjectionRelaxation.
```

### Ajout de pont vers le régime relaxé

Le constructeur général :

```lean
relaxedRegimeOfProjection
```

reste dans `StrictRelaxation.lean` afin d’éviter de faire dépendre
`ProjectedIdentity.lean` du régime relaxé.

Le sens d’import est donc :

```text
ProjectedIdentity
→ StrictRelaxation
```

et jamais l’inverse.

---

## 7.6 `ClosedStabilityTheorem.lean`

Le fichier cesse d’être le monolithe primitif.

### Imports cibles

```lean
import Meta.Core.BilateralCore
import Meta.Core.ProjectiveCore
```

### Déclarations qui restent ici

Seulement les structures combinant fermeture bilatérale et données projectives :

```text
FormedReferentialClosure
outcomeWitnessOfFormedReferentialClosure

FormedReferentialClosure.diagonalCertificate
FormedReferentialClosure.projectionObstruction
FormedReferentialClosure.localProjectiveRecovery
les théorèmes associés

NonProjectiveStrongClosedStability
RecoveredNonProjectiveClosedStability
NonProjectiveStrongClosedStabilityFromIntersection
RecoveredNonProjectiveClosedStabilityFromIntersection
LocallyRecoveredNonProjectiveClosedStabilityFromIntersection

weakClosedStabilityTheorem
strongClosedStabilityTheorem
strongClosedStabilityFromIntersectionTheorem
strongClosedStabilityFromIntersectionLinkedTheorem
nonProjectiveStrongClosedStabilityTheorem
recoveredNonProjectiveClosedStabilityTheorem
nonProjectiveStrongClosedStabilityFromIntersectionTheorem
recoveredNonProjectiveClosedStabilityFromIntersectionTheorem
locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem.
```

### Rôle final

Le fichier devient :

```text
la couche de combinaison ;
la façade historique ;
le lieu des grands théorèmes de stabilité fermée.
```

Il ne doit plus définir les primitives bilatérales ni projectives.

---

## 7.7 `DynamicCore.lean`

Nouveau fichier fusionnant :

```text
DynamicStability.lean
DynamicTwoPole.lean.
```

### Imports

```lean
import Meta.Core.ClosedStabilityTheorem
import Meta.Core.ProjectiveCore
```

### Déclarations déplacées

```text
FormedDynamicReturn
TemporalExcessDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn

dynamicReturn_operationalGap
dynamicReturn_structuralGap
dynamicReturn_refutes_shortReferentialPresentation

dynamicReturn_operationalTwoPole
dynamicReturn_structuralTwoPole
dynamicReturn_twoPole_refutes_shortPresentation.
```

### Façades transitoires

```text
DynamicStability.lean
DynamicTwoPole.lean
```

importent `DynamicCore.lean`.

### Critère d’acceptation

```text
les théorèmes restent définitionnellement identiques ;
DynamicRoleCarrier importe uniquement DynamicCore ;
OrderGap importe DynamicCore ;
aucune dépendance à Parity.
```

---

## 7.8 `DynamicRoleCarrier.lean`

Le fichier reste séparé.

### Changement d’import

```lean
import Meta.Core.DynamicCore
```

### Raisons

Le module ajoute une structure réelle :

```text
lecture Interface → Role ;
lecture Visible → RoleVisible ;
deux-pôles au niveau des rôles ;
rôle fermant ;
rôle médiateur ;
réparations à deux niveaux.
```

Il ne s’agit pas d’un simple alias.

### Simplification interne

Les théorèmes spécialisés doivent utiliser autant que possible les projections
génériques déjà disponibles dans `DynamicCore` et `ProjectiveCore`.

Aucun changement de nom n’est requis dans la première migration.

---

## 7.9 `OrderGap.lean`

Le fichier reste séparé et en aval.

### Imports cibles

```lean
import Meta.Core.ProjectiveCore
import Meta.Core.DynamicCore
```

### Justification

L’ordre n’est pas une primitive du gap.

Il est un test externe :

```text
comparabilité visible mutuelle
→ tentative de contraction interne.
```

Le fichier doit donc rester une couche d’application du Core projectif.

### Déclarations conservées

```text
VisiblePreorder
VisiblePartialOrder
VisibleTotalOrder
VisibleOrderEquivalent
OrderContractiveProjection
les équivalences avec fidélité et contractibilité
les conséquences structurelles, opérationnelles et dynamiques.
```

---

## 7.10 `Parity.lean`

Nouveau fichier fusionnant :

```text
ParitySeparation.lean
DynamicParitySeparation.lean.
```

### Imports

```lean
import Meta.Core.ProjectiveCore
import Meta.Core.DynamicRoleCarrier
```

### Première partie : modèle minimal statique

```text
ParityRegime
ParityVisible
parityProjection
ParityRegimeRepair
parityStructuralTwoPole
parityOperationalTwoPole
les orientations opposées
les théorèmes de séparation et non-reconstruction.
```

### Deuxième partie : spécialisation dynamique

```text
DynamicParitySeparation
dynamicParitySeparation_roleCarrier
OperationalParityRoles
les quelques théorèmes propres à la parité.
```

### Règle de simplification

Les accès génériques déjà prouvés dans `DynamicRoleCarrier` ne doivent pas être
redémontrés sous dix noms spécialisés, sauf lorsqu’un nom de domaine apporte
une valeur documentaire réelle.

### Façades transitoires

```text
ParitySeparation.lean
DynamicParitySeparation.lean
```

importent `Parity.lean`.

---

# 8. Carte exacte des déplacements

## 8.1 Depuis `ClosedStabilityTheorem.lean`

| Bloc actuel | Destination |
|---|---|
| Complétude bidirectionnelle | `BilateralCore.lean` |
| Cycles et cohérences | `BilateralCore.lean` |
| Témoins d’interface | `BilateralCore.lean` |
| Weak/Strong closed stability | `BilateralCore.lean` |
| SelfCoupling | `BilateralCore.lean` |
| Projection obstruction | `ProjectiveCore.lean` |
| Fidélité et reconstruction | `ProjectiveCore.lean` |
| DiagonalCertificate | `ProjectiveCore.lean` |
| LocalProjectiveRecovery | `ProjectiveCore.lean` |
| LocalTruthGapRecovery | `ProjectiveCore.lean` |
| RecoveryBundle / TerminalProjection | `ProjectiveCore.lean` |
| FormedReferentialClosure | `ClosedStabilityTheorem.lean` |
| Paquets non projectifs combinés | `ClosedStabilityTheorem.lean` |
| Grands théorèmes de stabilité | `ClosedStabilityTheorem.lean` |

## 8.2 Depuis les petits modules

| Fichier actuel | Destination d’implémentation | Statut transitoire |
|---|---|---|
| `Gap.lean` | `ProjectiveCore.lean` | façade |
| `ReferentialLength.lean` | `ProjectiveCore.lean` | façade |
| `TwoPole.lean` | `ProjectiveCore.lean` | façade |
| `DynamicStability.lean` | `DynamicCore.lean` | façade |
| `DynamicTwoPole.lean` | `DynamicCore.lean` | façade |
| `ParitySeparation.lean` | `Parity.lean` | façade |
| `DynamicParitySeparation.lean` | `Parity.lean` | façade |

---

# 9. Phases d’implémentation

## Phase 0 — Geler la base

### Actions

```text
créer un commit de référence ;
compiler tous les fichiers Core ;
compiler les fichiers Tarski consommateurs ;
enregistrer les sorties de #print axioms ;
enregistrer le graphe d’import ;
enregistrer les types des déclarations publiques.
```

### Livrables

```text
baseline-build.log
baseline-axioms.log
baseline-declarations.txt
baseline-imports.txt.
```

### Critère de sortie

```text
le dépôt est vert avant toute modification.
```

---

## Phase 1 — Formaliser la stricte relaxation sans déplacer le Core

### Actions

```text
ajouter HasUse ;
ajouter CompositionalUse ;
créer StrictRelaxation.lean ;
construire le régime projectif ;
construire le régime directionnel ;
prouver la non-représentabilité exacte ;
prouver la chaîne d’inclusions.
```

### Pourquoi cette phase est première

Elle ajoute le théorème central sans perturber les imports existants.

Elle fournit un test mathématique du nouvel ordre conceptuel avant le
refactoring de fichiers.

### Critère de sortie

```text
ProjectedIdentityTransport ⊊ RelaxedUsageTransport
est compilé sans axiomes nouveaux.
```

---

## Phase 2 — Extraire `BilateralCore`

### Actions

```text
créer BilateralCore.lean ;
déplacer les déclarations bilatérales sans modification ;
faire importer BilateralCore par ClosedStabilityTheorem ;
supprimer les doublons du fichier historique ;
compiler tous les consommateurs.
```

### Critère de sortie

```text
aucun changement d’API ;
aucun import cycle ;
les anciennes preuves rfl compilent.
```

---

## Phase 3 — Extraire et consolider `ProjectiveCore`

### Actions

```text
créer ProjectiveCore.lean ;
déplacer obstruction, reconstruction, récupération et vérité locale ;
absorber Gap, ReferentialLength et TwoPole ;
transformer les trois anciens fichiers en façades ;
mettre à jour ProjectedIdentity.
```

### Critère de sortie

```text
les anciens imports compilent ;
ProjectedIdentity ne dépend plus du monolithe ;
ProjectiveCore ne dépend pas de BilateralCore.
```

---

## Phase 4 — Réduire `ClosedStabilityTheorem` à la combinaison

### Actions

```text
laisser uniquement les paquets qui combinent bilatéral et projectif ;
réordonner le fichier par dépendance réelle ;
conserver tous les noms historiques ;
mettre à jour les commentaires de module.
```

### Critère de sortie

```text
ClosedStabilityTheorem n’est plus une racine primitive ;
il devient une couche de combinaison stable.
```

---

## Phase 5 — Créer `DynamicCore`

### Actions

```text
fusionner DynamicStability et DynamicTwoPole ;
mettre à jour DynamicRoleCarrier ;
mettre à jour OrderGap ;
conserver les anciennes façades.
```

### Critère de sortie

```text
un seul module porte le retour dynamique et ses vues gap/deux-pôles.
```

---

## Phase 6 — Consolider la parité

### Actions

```text
créer Parity.lean ;
réunir modèle minimal et instance dynamique ;
réduire les théorèmes spécialisés redondants ;
conserver les façades historiques.
```

### Critère de sortie

```text
Parity reste une spécialisation mince de DynamicRoleCarrier.
```

---

## Phase 7 — Nettoyer les imports aval

### Actions

Migrer progressivement :

```text
Meta/Tarski
Meta/Collatz éventuel
plans et tests
fichiers d’agrégation.
```

Ordre recommandé :

```text
imports génériques nouveaux d’abord ;
façades historiques ensuite supprimées une par une.
```

### Critère de sortie

```text
aucun consommateur n’importe une façade obsolète.
```

---

## Phase 8 — Supprimer les façades obsolètes

Cette phase n’est exécutée qu’après une recherche complète :

```bash
grep -R "Meta.Core.Gap" .
grep -R "Meta.Core.ReferentialLength" .
grep -R "Meta.Core.TwoPole" .
grep -R "Meta.Core.DynamicStability" .
grep -R "Meta.Core.DynamicTwoPole" .
grep -R "Meta.Core.ParitySeparation" .
grep -R "Meta.Core.DynamicParitySeparation" .
```

Si toutes les recherches sont vides hors façades, les fichiers peuvent être
supprimés.

---

# 10. Série de commits recommandée

## Commit 1

```text
core: add HasUse and compositional-use vocabulary
```

## Commit 2

```text
core: formalize strict relaxation of projected identity
```

## Commit 3

```text
core: extract bilateral completeness and terminal cycles
```

## Commit 4

```text
core: extract projective obstruction and local recovery
```

## Commit 5

```text
core: consolidate gap, referential length, and two-pole views
```

## Commit 6

```text
core: reduce ClosedStabilityTheorem to combination layer
```

## Commit 7

```text
core: consolidate dynamic return and dynamic two-pole
```

## Commit 8

```text
core: consolidate parity specialization
```

## Commit 9

```text
core: migrate downstream imports to target architecture
```

## Commit 10

```text
core: remove compatibility facades after downstream migration
```

Chaque commit doit compiler indépendamment.

---

# 11. Validation technique

## 11.1 Compilation unitaire

Depuis la racine du dépôt :

```bash
lake env lean Meta/Core/RelaxedUsageRegime.lean
lake env lean Meta/Core/StrictRelaxation.lean
lake env lean Meta/Core/BilateralCore.lean
lake env lean Meta/Core/ProjectiveCore.lean
lake env lean Meta/Core/ProjectedIdentity.lean
lake env lean Meta/Core/ClosedStabilityTheorem.lean
lake env lean Meta/Core/DynamicCore.lean
lake env lean Meta/Core/DynamicRoleCarrier.lean
lake env lean Meta/Core/OrderGap.lean
lake env lean Meta/Core/Parity.lean
```

## 11.2 Compilation globale

```bash
lake build
```

## 11.3 Audit des axiomes

Pour chaque nouveau théorème central :

```lean
#print axioms Meta.RelaxedUsageRegime.HasUse
#print axioms Meta.RelaxedUsageRegime.directionalRelaxedRegime_not_exactProjective
#print axioms Meta.RelaxedUsageRegime.projectedIdentityTransport_strictlyIncludedIn_relaxedUsageTransport
```

Les résultats attendus ne doivent pas introduire d’axiome non déjà présent.

## 11.4 Contrôle des imports

Aucun cycle ne doit apparaître dans :

```text
RelaxedUsageRegime
StrictRelaxation
ProjectedIdentity
ProjectiveCore.
```

Le sens imposé est :

```text
ProjectiveCore
→ ProjectedIdentity
→ StrictRelaxation.
```

## 11.5 Contrôle de l’API

Produire avant et après :

```bash
grep -R -E "^(structure|inductive|abbrev|def|theorem) " Meta/Core
```

Comparer les noms publics.

Aucune disparition n’est admise avant la phase de suppression explicite des
façades.

## 11.6 Contrôle des univers

Pour les structures principales, imprimer les types :

```lean
#check BidirectionalCompleteness
#check ProjectionObstruction
#check LocalProjectiveRecovery
#check RelaxedInterfaceRegime
#check ExactProjectiveRepresentation
#check DynamicRoleCarrier
```

Les niveaux d’univers existants doivent être inchangés.

---

# 12. Tests mathématiques obligatoires

## 12.1 Test de réflexivité projective

```text
Toute représentation projective exacte rend HasUse réflexive.
```

## 12.2 Test de symétrie projective

```text
Toute représentation projective exacte rend HasUse symétrique.
```

## 12.3 Test de transitivité projective

```text
Toute représentation projective exacte rend HasUse transitive.
```

## 12.4 Test du modèle directionnel

```text
HasUse before before
HasUse before after
HasUse after after
¬ HasUse after before.
```

## 12.5 Test de composition

```text
before → before → after
se compose en
before → after.
```

```text
before → after → after
se compose en
before → after.
```

## 12.6 Test de stricte non-réductibilité

```text
ExactProjectiveRepresentation directionalRelaxedRegime
→ False.
```

## 12.7 Test de l’inclusion interne

Avec :

```text
project := id
```

la représentation projective exacte coïncide avec l’identité interne.

---

# 13. Risques et mesures de contrôle

## 13.1 Cycle d’import

### Risque

`ProjectedIdentity` utilise les obstructions projectives, tandis que le nouveau
théorème de relaxation utilise `ProjectedIdentity`.

### Mesure

Imposer :

```text
ProjectiveCore
→ ProjectedIdentity
→ StrictRelaxation.
```

`ProjectiveCore` ne doit jamais importer `ProjectedIdentity`.

## 13.2 Rupture de preuves par `rfl`

### Risque

Changer un `abbrev`, un ordre d’arguments ou un niveau d’univers peut casser des
preuves définitionnelles.

### Mesure

Déplacer le texte des déclarations sans le réécrire pendant les phases
structurelles.

## 13.3 Façades provoquant des imports en diamant

### Risque

Les anciens wrappers peuvent importer les nouveaux modules par plusieurs
chemins.

### Mesure

Les façades ne contiennent qu’un import et aucun redéveloppement.

Lean gère les imports répétés, mais le graphe doit rester acyclique.

## 13.4 Confusion entre usage et non-contractive use

### Risque

`HasUse` porte :

```text
Nonempty (Use γ x y)
```

et non :

```text
Nonempty (NonContractiveUse I γ x y).
```

Le modèle directionnel possède des usages réflexifs qui ne sont pas des usages
séparés.

### Mesure

Documenter explicitement :

```text
Use décrit tous les transports autorisés ;
NonContractiveUse décrit ceux obtenus par Sep + Coord.
```

## 13.5 Revendication trop large

### Risque

Présenter la stricte inclusion comme une supériorité absolue du formalisme.

### Mesure

Toujours préciser :

```text
la stricte inclusion concerne les relations HasUse
exactement représentables par égalité projetée.
```

## 13.6 Monolithe déplacé

### Risque

Créer `ProjectiveCore.lean` trop grand et reproduire le problème initial.

### Mesure

Accepter un fichier projectif substantiel tant qu’il possède une responsabilité
unique :

```text
projection, obstruction, récupération et vues équivalentes.
```

Si le fichier dépasse un seuil réellement gênant, le séparer ultérieurement en :

```text
ProjectiveObstruction.lean
ProjectiveViews.lean.
```

Cette séparation n’appartient pas à la première migration.

---

# 14. Politique de compatibilité

## 14.1 Durée des façades

Conserver les façades pendant au moins un cycle complet de migration des
consommateurs.

## 14.2 Commentaires de dépréciation

Chaque façade indique :

```text
Compatibility facade.
Import Meta.Core.ProjectiveCore instead.
```

Ne pas utiliser immédiatement des attributs `deprecated` si le dépôt compile
avec plusieurs versions de Lean dont la syntaxe diffère.

## 14.3 Suppression

Une façade est supprimée seulement lorsque :

```text
aucun import aval ne la mentionne ;
la documentation ne la recommande plus ;
le build complet est vert ;
les audits d’axiomes ont été rejoués.
```

---

# 15. Documentation à mettre à jour

## 15.1 En-tête de `RelaxedUsageRegime.lean`

Il doit annoncer :

```text
la relaxation du principe d’identification ;
la séparation entre individuation et transport ;
la chaîne Sep + Coord → Use → transport.
```

## 15.2 En-tête de `StrictRelaxation.lean`

Il doit annoncer le résultat exact :

```text
les usages exactement projectifs forment des relations d’équivalence ;
un régime directionnel relaxé n’est pas exactement projectif ;
la relaxation est donc stricte au niveau de HasUse.
```

## 15.3 En-tête de `BilateralCore.lean`

Il doit éviter de présenter les cycles comme la nouveauté principale.

Le rôle du module est :

```text
fermeture, intersection, recomposition et provenance.
```

## 15.4 En-tête de `ProjectiveCore.lean`

Il doit préciser :

```text
le gap projectif est une instance du régime relaxé ;
la non-injectivité est une réalisation minimale, non le principe fondateur.
```

## 15.5 Document Markdown conceptuel

`Systeme_dynamique_bilateral.md` doit être mis à jour uniquement après
compilation de `StrictRelaxation.lean`.

Le statut changera alors de :

```text
théorème démontré sur papier
```

à :

```text
théorème formalisé dans Meta/Core/StrictRelaxation.lean.
```

---

# 16. Définition de terminé

La réorganisation est terminée lorsque toutes les conditions suivantes sont
satisfaites.

## 16.1 Théorème central

```text
HasUse existe ;
ExactProjectiveRepresentation existe ;
le modèle directionnel compile ;
la non-représentabilité compile ;
la stricte inclusion compile.
```

## 16.2 Architecture

```text
RelaxedUsageRegime est une racine ;
BilateralCore est une racine ;
ProjectiveCore est indépendant de BilateralCore ;
ClosedStabilityTheorem combine les deux ;
DynamicCore est en aval ;
Parity et Order sont des spécialisations.
```

## 16.3 Compatibilité

```text
lake build réussit ;
les imports historiques réussissent pendant la transition ;
aucun nom public n’a disparu sans décision explicite.
```

## 16.4 Axiomes

```text
les sorties de #print axioms sont stables ;
le nouveau théorème de stricte relaxation est constructif ;
aucun choix classique n’est introduit.
```

## 16.5 Lisibilité

Un lecteur du graphe d’import doit pouvoir lire immédiatement :

```text
relaxation
→ instance projective
→ gap
→ capture
→ dynamique
→ spécialisations.
```

---

# 17. Ordre de priorité final

```text
Priorité 1
  formaliser StrictRelaxation.lean.

Priorité 2
  extraire BilateralCore sans changer les preuves.

Priorité 3
  consolider ProjectiveCore et alléger les alias.

Priorité 4
  réduire ClosedStabilityTheorem à la combinaison.

Priorité 5
  fusionner les couches dynamiques redondantes.

Priorité 6
  simplifier les spécialisations de parité.

Priorité 7
  migrer les consommateurs et supprimer les façades.
```

La première étape produit la valeur mathématique nouvelle.

Les étapes suivantes font correspondre l’architecture du code à cette valeur.

---

# 18. Résumé opérationnel

```text
Ne pas commencer par déplacer les fichiers.

Commencer par ajouter le théorème manquant :
  ProjectedIdentityTransport
  ⊊
  RelaxedUsageTransport.

Ensuite :
  extraire BilateralCore ;
  extraire ProjectiveCore ;
  conserver ClosedStabilityTheorem comme couche de combinaison ;
  fusionner DynamicStability et DynamicTwoPole ;
  faire de Parity une spécialisation mince ;
  garder OrderGap en aval ;
  conserver des façades jusqu’à migration complète.
```

La règle directrice du refactoring est :

> La relaxation du principe d’identification est primitive. L’identité
> projetée est une instance. Le gap est une structure dérivée. La capture et la
> dynamique exploitent cette structure sans la contracter.
