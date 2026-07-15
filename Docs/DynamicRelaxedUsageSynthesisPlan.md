# Plan d'implémentation de la synthèse dynamique de l'usage relaxé

## 0. Objet

Ce plan prépare la formalisation du principe fondationnel suivant :

> L'identité reste le principe strict d'individuation, mais elle cesse d'être
> l'unique fondement possible de la coordination, de la substitution et du
> transport.

La chaîne primitive est :

```text
Sep γ x y
+
Coord γ x y
→
Use γ x y
→
transport dans les lectures autorisées par γ
```

La stricte relaxation est déjà démontrée :

```text
InternalIdentityTransport
⊆
ProjectedIdentityTransport
⊊
RelaxedUsageTransport
```

La dynamique bilatérale est également déjà formalisée :

```text
source
→ intersection typée
→ cycle fort
→ interface formée
→ récupération locale
→ gap opérationnel
```

Ce qui manque est leur synthèse interne :

```text
intersection dynamique courante
→ gap courant
→ coordination courante
→ usage courant
→ transport courant
→ état suivant
→ nouveau gap
→ nouveau droit de transport
```

Le but n'est pas d'ajouter un vocabulaire autour des structures existantes. Le
but est de construire un algorithme typé dans lequel le gap produit causalement
l'usage, et dans lequel une transition dynamique modifie effectivement cet
usage sans contracter les interfaces.

## 1. Verdict de départ

### 1.1 Déjà formalisé

Dans `Meta/Core/RelaxedUsageRegime.lean` :

```text
RelaxedInterfaceRegime
NonContractiveUse
LocalTransportChain
HasUse
CompositionalUse
```

Dans `Meta/Core/StrictRelaxation.lean` :

```text
ExactProjectiveRepresentation
relaxedRegimeOfProjection
directionalRelaxedRegime
directionalRelaxedRegime_not_exactProjective
projectedIdentityTransport_strictlyIncludedIn_relaxedUsageTransport
```

Dans `Meta/Core/BilateralCore.lean` :

```text
BidirectionalCompleteness
RoundTripCoherence
StrongTerminalCycleFromIntersection
strongTerminalCycleFromIntersection
```

Dans `Meta/Core/DynamicCore.lean` :

```text
FormedDynamicReturn
LocallyRecoveredDynamicReturn
dynamicReturn_operationalGap
dynamicReturn_structuralGap
```

### 1.2 Non encore formalisé

Il n'existe actuellement aucune déclaration Lean qui :

```text
1. construise un RelaxedInterfaceRegime depuis une famille dynamique
   de récupérations locales ;

2. fasse du gap courant le constructeur de Coord et de Use ;

3. indexe le contexte d'usage par l'intersection source du cycle ;

4. itère une transition interne source → source suivante ;

5. démontre qu'un même transport peut être autorisé dans un état
   et refusé dans l'état suivant ;

6. conserve la provenance de l'usage à travers
   Intersection → Complete → Intersection.
```

La présence simultanée des imports `StrictRelaxation` et `DynamicCore` dans un
agrégateur ne constitue pas cette preuve.

## 2. Contraintes non négociables

### 2.1 Constructivité

Les nouveaux fichiers Lean doivent respecter :

```text
aucun axiom
aucun sorry
aucun admit
aucun Classical
aucun propext
aucun Quot.sound
aucun noncomputable
aucun unsafe
```

### 2.2 Intrinsécité

La transition doit être une opération du système qui consomme le droit
d'usage courant :

```text
advance :
  (Σ source : Source, CurrentGapCausalState source) →
  Source

next source :=
  advance ⟨source, currentGapCausalState source⟩
```

Les retours dynamiques doivent être produits par le système :

```text
returnAt :
  (source : Source) →
    le LocallyRecoveredDynamicReturn entièrement indexé de la section 5.1
```

Il est interdit de conclure par une hypothèse externe de la forme :

```text
si un régime compatible existe, alors le gap autorise un usage ;

si un pont terminal existe, alors l'usage est mémorisé ;

si une variation est fournie séparément, alors le système est dynamique.
```

La famille de retours, la transition, les contextes et les gaps doivent être
des données internes du même paquet final. Il est interdit de stocker un
`next : Source → Source` indépendant du gap puis de lui attribuer après coup
une interprétation causale.

Il est également interdit d'identifier par définition les familles
`Complete`, `Forward`, `Backward` et `Intersection` dans le modèle de
validation. Elles doivent être des paquets typés distincts, reliés par des
fonctions explicites dont les lois d'aller-retour sont prouvées.

### 2.3 Causalité

Le champ `Use` d'une étape ne doit jamais être fourni librement et ne doit pas
être un simple alias de `Coord`.

Il doit être calculé par :

```text
localRecovery.separated
+
localRecovery.sameProjection
→ coordination courante
+
séparation courante
→ certificat d'usage causal
→ NonContractiveUse
→
NonContractiveUse.use
```

Le certificat d'usage doit conserver les deux données qui l'ont produit. Le
transport doit ensuite être calculé par :

```text
NonContractiveUse.transport
```

Chaque égalité de provenance doit être prouvée, de préférence par `rfl` lorsque
la construction est définitionnelle.

### 2.4 Non-trivialité

Le théorème final ne doit pas être validé seulement par :

```text
Ctx := Unit
Read := Unit
Use := Unit
RepairOf := Unit
WitnessOf := Unit
project := fonction constante
False.elim
Coord := Use
Complete := Forward := Backward := Intersection
```

Le modèle final doit posséder :

```text
au moins deux sources dynamiques distinctes ;
au moins trois interfaces distinctes ;
au moins deux visibles distincts ;
une projection globalement non constante ;
une fibre contenant deux interfaces séparées ;
quatre familles bilatérales distinctes ;
une coordination distincte du droit d'usage qu'elle autorise ;
deux lectures autorisées distinctes ;
un type d'usage inductif orienté ;
des témoins d'interface preuve-pertinents ;
des réparations preuve-pertinentes ;
une transition qui change réellement le droit de transport.
```

### 2.5 Séparation entre production et réfutation

Les structures productives ne doivent pas contenir un champ :

```text
contradiction : False
```

La séparation interne doit être portée localement :

```text
formed = shadow → False
```

Les théorèmes négatifs doivent consommer les données positives après leur
construction. Aucun champ productif ne doit pouvoir être rempli par
`False.elim`.

## 3. Fichiers cibles

### 3.1 Synthèse générique

Créer :

```text
Meta/Core/DynamicRelaxedUsage.lean
```

Imports exacts :

```lean
import Meta.Core.DynamicCore
import Meta.Core.StrictRelaxation
```

Le sens d'import sera :

```text
RelaxedUsageRegime → StrictRelaxation
                            ↘
                              DynamicRelaxedUsage
                            ↗
BilateralCore → DynamicCore
```

`DynamicCore` ne doit pas importer le nouveau module. La synthèse reste en
aval des deux racines.

### 3.2 Modèle non trivial

Créer :

```text
Meta/Core/DynamicRelaxedUsageModel.lean
```

Import unique :

```lean
import Meta.Core.DynamicRelaxedUsage
```

Le modèle est séparé afin que le noyau générique ne soit pas confondu avec son
premier témoin fini.

### 3.3 Agrégation

Après compilation indépendante des deux fichiers, ajouter dans `Meta.lean` :

```lean
import Meta.Core.DynamicRelaxedUsage
import Meta.Core.DynamicRelaxedUsageModel
```

## 4. Namespace et paramètres

Le nouveau module doit utiliser :

```lean
namespace Meta
namespace DynamicRelaxedUsage
```

Les types historiques restent accessibles avec leurs namespaces actuels :

```text
Meta.RelaxedUsageRegime
Meta.ClosedStabilityTheorem
```

Dans une section principale, fixer les paramètres suivants :

```lean
universe u v w a x y z r s

variable {Branch : Type u}
variable {complete :
  ClosedStabilityTheorem.BidirectionalCompleteness.{u, v, w} Branch}
variable {coherence :
  ClosedStabilityTheorem.RoundTripCoherence complete}
variable {branch : Branch}
variable {Source : Type a}
variable {Interface : Type x}
variable {WitnessOf : Interface → Type y}
variable {RealizesInterface :
  ClosedStabilityTheorem.StrongTerminalCycleFromIntersection
      complete branch →
    Interface →
    Type z}
variable {Visible : Type r}
variable {project : Interface → Visible}
variable {RepairOf : Interface → Type s}
```

## 5. Famille dynamique intrinsèque

### 5.1 Structure centrale

Introduire :

```lean
structure IntrinsicDynamicReturnFamily
    {Branch : Type u}
    (complete :
      ClosedStabilityTheorem.BidirectionalCompleteness.{u, v, w} Branch)
    (coherence :
      ClosedStabilityTheorem.RoundTripCoherence complete)
    (branch : Branch)
    (Source : Type a)
    (Interface : Type x)
    (WitnessOf : Interface → Type y)
    (RealizesInterface :
      ClosedStabilityTheorem.StrongTerminalCycleFromIntersection
          complete branch →
        Interface →
        Type z)
    (Visible : Type r)
    (project : Interface → Visible)
    (RepairOf : Interface → Type s) where
  initial : Source

  returnAt :
    (source : Source) →
      ClosedStabilityTheorem.LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf

  returnAt_source :
    (source : Source) →
      (returnAt source).formedReturn.source = source
```

Cette structure ne contient ni régime arbitraire, ni fonction de pont vers un
régime, ni transition préalable au gap. Elle constitue l'atlas intrinsèque des
retours. L'algorithme de transition sera défini seulement après la construction
du droit d'usage canonique, afin que sa dépendance causale soit visible dans
son type.

### 5.2 Projections canoniques

Ajouter :

```text
IntrinsicDynamicReturnFamily.intersectionAt
IntrinsicDynamicReturnFamily.formedAt
IntrinsicDynamicReturnFamily.shadowAt
IntrinsicDynamicReturnFamily.sameProjectionAt
IntrinsicDynamicReturnFamily.separatedAt
IntrinsicDynamicReturnFamily.repairAt
```

Chaque définition doit être une projection de `returnAt source`.

En particulier :

```text
formedAt source
=
(returnAt source).localRecovery.formed

shadowAt source
=
(returnAt source).localRecovery.shadow
```

Le gap courant n'est donc pas fourni une seconde fois.

## 6. Contexte dynamique avec provenance

### 6.1 Structure du contexte

Définir :

```lean
structure DynamicUsageContext
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf) where
  source : Source

  intersection : complete.Intersection branch

  intersection_eq :
    intersection = family.intersectionAt source
```

Le contexte ne doit pas être réduit à `Source`. Il mémorise explicitement
l'intersection qui gouverne l'usage courant.

### 6.2 Contextes canoniques

Définir :

```text
IntrinsicDynamicReturnFamily.contextAt
IntrinsicDynamicReturnFamily.initialContext
```

avec :

```text
contextAt source :=
  source
  + intersectionAt source
  + preuve rfl de provenance
```

La source suivante n'est pas encore définie à ce niveau. Elle sera calculée
par le système piloté par le gap de la section 12. Aucun `target` libre ne sera
demandé à l'appelant d'une étape.

## 7. Lectures dynamiques autorisées

### 7.1 Deux lectures substantielles

Définir :

```lean
inductive DynamicGapReading where
  | formed
  | visible
```

Pour un contexte `γ` :

```text
Out γ formed  := Interface
Out γ visible := Visible

read γ formed  x := x
read γ visible x := project x
```

Le modèle ne repose donc pas sur une lecture unique dans `Unit`.

### 7.2 Sens des transports

La lecture formée conserve l'orientation du gap :

```text
formed γ → shadow γ
```

La lecture visible conserve la coordination projective :

```text
project (formed γ) = project (shadow γ)
```

Ces deux lectures rendent simultanément visibles :

```text
la séparation interne ;
la coordination visible.
```

## 8. Coordination et usage engendrés par le gap

### 8.1 Coordination indexée

Définir d'abord une coordination dont l'unique constructeur non réflexif est
indexé exactement par les deux pôles du gap courant :

```lean
inductive DynamicGapCoordination
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (gamma : DynamicUsageContext family) :
    Interface → Interface → Type (max x a v w) where
  | current :
      DynamicGapCoordination
        family
        gamma
        (family.formedAt gamma.source)
        (family.shadowAt gamma.source)
```

Ce constructeur n'est pas un jeton autonome. Ses indices fixent la source, le
contexte et les deux interfaces provenant de `returnAt gamma.source`. Le
transport visible associé doit être obtenu par
`family.sameProjectionAt gamma.source`.

Il n'existe aucun constructeur inverse et aucune coordination libre entre deux
interfaces arbitraires.

### 8.2 Droit d'usage causal

Définir ensuite un type preuve-pertinent distinct de la coordination :

```lean
inductive DynamicGapUse
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (γ : DynamicUsageContext family) :
    Interface → Interface → Type (max x a v w) where
  | refl (interface : Interface) :
      DynamicGapUse family γ interface interface

  | of_noncontractive
      {left right : Interface}
      (separation : PLift (left = right → False))
      (coordination :
        DynamicGapCoordination family γ left right) :
      DynamicGapUse family γ left right
```

Le constructeur `of_noncontractive` conserve littéralement les deux causes
du droit de transport. `Use` n'est donc ni un alias de `Coord`, ni un témoin
fourni après coup. Le constructeur réflexif sert seulement à la composition et
ne donne aucun `NonContractiveUse x x`.

### 8.3 Composition

Définir :

```text
DynamicGapUse.compose
```

Cas exigés :

```text
refl ; refl  → refl
refl ; usage non contractif   → même usage
usage non contractif ; refl   → même usage
usage non contractif ; usage non contractif
  → branche impossible
```

Le dernier cas est éliminé par :

```text
les deux témoins `DynamicGapCoordination.current` ;
family.separatedAt γ.source
```

et non par une décision classique des interfaces.

### 8.4 Absence de retour inverse

Prouver :

```lean
theorem dynamicGapUse_noBackward
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (γ : DynamicUsageContext family) :
    DynamicGapUse
      family
      γ
      (family.shadowAt γ.source)
      (family.formedAt γ.source) →
    False
```

Cette preuve doit consommer uniquement :

```text
la forme inductive de DynamicGapUse ;
la forme indexée de DynamicGapCoordination ;
la séparation du gap courant.
```

Ajouter aussi :

```text
dynamicGapCoordination_noBackward
dynamicGapCoordination_not_composable
```

Ces deux lemmes isolent les impossibilités d'indices utilisées par les preuves
sur l'usage. Aucun `False.elim` ne doit apparaître comme raccourci de
construction ; la contradiction doit venir de `separatedAt`.

## 9. Régime relaxé canonique de la famille

### 9.1 Constructeur principal

Définir :

```text
dynamicRelaxedRegimeOfReturnFamily
```

avec les choix suivants :

```text
Ctx         := DynamicUsageContext family
defaultCtx  := family.initialContext
Read        := DynamicGapReading
defaultRead := formed

Sep γ x y   := PLift (x = y → False)
Coord γ x y := DynamicGapCoordination family γ x y
Use γ x y   := DynamicGapUse family γ x y
```

Pour la relation de sortie :

```text
OutRel γ formed x y
  := DynamicGapUse family γ x y

OutRel γ visible vx vy
  := PLift (vx = vy)
```

### 9.2 Production de l'usage

Le champ :

```text
use_of_noncontractive
```

doit retourner exactement :

```text
DynamicGapUse.of_noncontractive separation coordination
```

L'usage conserve donc la séparation et la coordination reçues. Il ne peut pas
être construit à partir de la coordination seule, et aucune de ces données
n'est recomputée ou remplacée par un jeton.

### 9.3 Transport par lecture

Le champ `transport` est défini par analyse du témoin d'usage :

```text
lecture formed :
  le témoin de sortie est le certificat DynamicGapUse lui-même ;

lecture visible + refl :
  rfl ;

lecture visible + of_noncontractive :
  analyser la coordination ;
  utiliser family.sameProjectionAt γ.source.
```

La causalité devient alors définitionnelle :

```text
gap local
→ constructeur DynamicGapCoordination.current
→ séparation locale
→ constructeur DynamicGapUse.of_noncontractive
→ transport formé orienté
→ transport visible par sameProjection
```

### 9.4 Composition du régime

Construire :

```text
dynamicCompositionalUseOfReturnFamily
```

à partir de :

```text
DynamicGapUse.refl
DynamicGapUse.compose
```

## 10. Extraction causale du gap courant

### 10.1 Non-contraction canonique

Définir :

```text
dynamicGapNonContractiveUse
```

Pour `family` et `source`, le résultat doit être :

```text
NonContractiveUse
  (dynamicRelaxedRegimeOfReturnFamily family)
  (family.contextAt source)
  (family.formedAt source)
  (family.shadowAt source)
```

Ses champs doivent être :

```text
separation   := PLift.up (family.separatedAt source)
coordination := DynamicGapCoordination.current
```

### 10.2 Usage dérivé

Définir :

```text
dynamicGapAuthorizedUse
```

uniquement par :

```text
NonContractiveUse.use
  (dynamicGapNonContractiveUse family source)
```

Prouver :

```text
dynamicGapAuthorizedUse_eq_of_noncontractive :
  dynamicGapAuthorizedUse family source =
    DynamicGapUse.of_noncontractive
      (PLift.up (family.separatedAt source))
      DynamicGapCoordination.current
```

La preuve attendue est `rfl`.

### 10.3 Deux transports dérivés

Définir :

```text
dynamicGapFormedTransport
dynamicGapVisibleTransport
```

Le premier doit être le témoin orienté :

```text
formedAt source → shadowAt source
```

Le second doit être la preuve :

```text
project (formedAt source) = project (shadowAt source)
```

Le premier conserve les champs `separation` et `coordination` du certificat
d'usage. Le second est obtenu par élimination de cette coordination et lecture
de `sameProjectionAt`; il ne doit pas réintroduire directement une égalité
visible sans passer par le droit d'usage.

Prouver que le second est exactement `family.sameProjectionAt source`.

### 10.4 Chaînes locales

Construire deux `LocalTransportChain` :

```text
dynamicGapFormedTransportChain
dynamicGapVisibleTransportChain
```

Leur champ `use_eq` doit être définitionnel.

## 11. Mémoire bilatérale de l'usage

### 11.1 Cycle du contexte

Définir :

```text
dynamicUsageStrongCycle
```

par :

```text
strongTerminalCycleFromIntersection
  complete
  coherence
  γ.intersection
```

### 11.2 Structure de mémoire

Introduire :

```lean
structure DynamicUsageMemory
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (γ : DynamicUsageContext family) where
  cycle :
    ClosedStabilityTheorem.StrongTerminalCycleFromIntersection
      complete branch

  cycle_eq :
    cycle =
      ClosedStabilityTheorem.strongTerminalCycleFromIntersection
        complete coherence γ.intersection

  cycleSource_eq_returnIntersection :
    cycle.sourceIntersection = family.intersectionAt γ.source

  nonContractive :
    RelaxedUsageRegime.NonContractiveUse
      (dynamicRelaxedRegimeOfReturnFamily family)
      γ
      (family.formedAt γ.source)
      (family.shadowAt γ.source)

  use :
    DynamicGapUse
      family
      γ
      (family.formedAt γ.source)
      (family.shadowAt γ.source)

  use_eq :
    use = RelaxedUsageRegime.NonContractiveUse.use nonContractive

  sourceIntersection_preserved :
    ClosedStabilityTheorem.intersectionOfComplete
        complete
        (ClosedStabilityTheorem.completeOfIntersection
          complete
          γ.intersection) =
      γ.intersection
```

Le constructeur canonique :

```text
dynamicUsageMemory
```

ne doit accepter aucun cycle ni aucun usage comme argument. Il les calcule.
Le champ `cycleSource_eq_returnIntersection` est dérivé de `cycle_eq` et de
`γ.intersection_eq`; il interdit qu'un cycle cohérent, mais provenant d'une
autre intersection, soit associé au gap courant.

### 11.3 État causal complet du gap

Introduire le paquet consommé par la transition :

```lean
structure DynamicGapCausalState
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) where
  memory :
    DynamicUsageMemory family (family.contextAt source)

  formedTransport :
    RelaxedUsageRegime.LocalTransportChain
      (dynamicRelaxedRegimeOfReturnFamily family)
      (family.contextAt source)
      (family.formedAt source)
      (family.shadowAt source)
      DynamicGapReading.formed

  visibleTransport :
    RelaxedUsageRegime.LocalTransportChain
      (dynamicRelaxedRegimeOfReturnFamily family)
      (family.contextAt source)
      (family.formedAt source)
      (family.shadowAt source)
      DynamicGapReading.visible

  formedUse_eq_memoryUse :
    formedTransport.use = memory.use

  visibleUse_eq_memoryUse :
    visibleTransport.use = memory.use
```

Le constructeur :

```text
dynamicGapCausalState
```

ne prend que `family` et `source`. Il calcule les trois composantes depuis le
même `dynamicGapNonContractiveUse`. Les deux égalités de provenance doivent
être `rfl` ou se réduire à la même normalisation définitionnelle ; si elles ne
le sont pas, il faut corriger les constructeurs en amont plutôt qu'ajouter un
champ d'identification externe.

Ce paquet est le profil interne du gap courant : sa localisation est donnée
par `source`, `formedAt` et `shadowAt`; sa portée est donnée par les lectures et
les transports effectivement autorisés. Aucun nombre externe appelé « degré »
n'est postulé.

## 12. Algorithme dynamique complet

### 12.1 Transition pilotée par l'usage

Introduire seulement après `dynamicGapAuthorizedUse` :

```lean
structure GapDrivenDynamicSystem
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf) where
  advance :
    (Σ source : Source, DynamicGapCausalState family source) →
    Source
```

Définir l'entrée canonique :

```lean
def canonicalCausalInput
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    Σ current : Source, DynamicGapCausalState family current :=
  ⟨source, dynamicGapCausalState family source⟩
```

Le successeur est une définition, jamais un champ indépendant :

```lean
def GapDrivenDynamicSystem.next
    (system : GapDrivenDynamicSystem family)
    (source : Source) :
    Source :=
  system.advance
    (canonicalCausalInput family source)
```

Le type de `advance` interdit de calculer une transition sans fournir l'état
causal qui contient exactement le cycle, le droit d'usage et les transports du
gap courant. Le modèle concret devra en outre éliminer le témoin d'usage porté
par cet état ; une fonction constante qui ignore son argument est refusée par
les tests anti-trivialité.

### 12.2 Itération des sources

Définir :

```lean
def GapDrivenDynamicSystem.iterateSource
    (system : GapDrivenDynamicSystem family) :
    Nat → Source → Source
  | 0, source => source
  | Nat.succ n, source =>
      system.next (system.iterateSource n source)
```

### 12.3 Étape causale

Introduire :

```lean
structure DynamicUsageStep
    (system : GapDrivenDynamicSystem family)
    (source : Source) where
  transitionCause : DynamicGapCausalState family source

  transitionCause_eq :
    transitionCause = dynamicGapCausalState family source

  nextSource : Source
  nextSource_eq :
    nextSource = system.advance ⟨source, transitionCause⟩

  nextSource_eq_canonical :
    nextSource = system.next source

  nextCausalState : DynamicGapCausalState family nextSource

  nextCausalState_eq :
    nextCausalState = dynamicGapCausalState family nextSource
```

Le constructeur :

```text
dynamicUsageStep
```

ne prend que `system` et `source`. Tous les autres champs sont calculés. Les
contextes apparaissent directement sous la forme canonique `family.contextAt` :
aucun transport dépendant ni aucune égalité de contexte ne sont demandés à
l'appelant. Les mémoires courante et suivante sont respectivement
`transitionCause.memory` et `nextCausalState.memory`; elles ne sont jamais
stockées une seconde fois.

### 12.4 Étapes itérées

Définir :

```text
GapDrivenDynamicSystem.iterationStep
GapDrivenDynamicSystem.iterationContext
GapDrivenDynamicSystem.iterationMemory
```

Prouver :

```text
chaque itération possède un gap ;
chaque gap produit un NonContractiveUse ;
chaque NonContractiveUse produit les deux transports ;
chaque source suivante est le résultat de `advance` appliqué à l'état causal
qui contient cet usage et sa mémoire bilatérale ;
chaque mémoire conserve son intersection source par aller-retour.
```

## 13. Variation dynamique réelle

Un système constant satisferait encore les sections précédentes. Il ne
suffit pas au théorème final.

### 13.1 Certificat de variation

Introduire :

```lean
structure GenuineDynamicUsageVariation
    (system : GapDrivenDynamicSystem family) where
  source : Source

  source_ne_next :
    source = system.next source → False

  next_formed_eq_current_shadow :
    family.formedAt (system.next source) =
      family.shadowAt source

  next_shadow_eq_current_formed :
    family.shadowAt (system.next source) =
      family.formedAt source
```

Cette structure impose une inversion réelle des pôles au pas suivant.

### 13.2 Changement du droit de transport

Prouver constructivement :

```text
à l'état courant :
  Use current formed shadow

à l'état suivant :
  Use next shadow formed

à l'état suivant :
  ¬ HasUse next formed shadow
```

Le dernier résultat doit utiliser :

```text
next_formed_eq_current_shadow
next_shadow_eq_current_formed
dynamicGapUse_noBackward
```

Nom cible :

```text
genuineVariation_currentUse_refutedAtNext
```

### 13.3 Paquet intrinsèque de variation

La variation ne doit pas rester un argument ajouté à côté de la dynamique.
Introduire :

```lean
structure GenuinelyVaryingDynamicUsageSystem
    (complete :
      ClosedStabilityTheorem.BidirectionalCompleteness Branch)
    (coherence :
      ClosedStabilityTheorem.RoundTripCoherence complete)
    (branch : Branch)
    (Source : Type a)
    (Interface : Type x)
    (WitnessOf : Interface → Type y)
    (RealizesInterface :
      ClosedStabilityTheorem.StrongTerminalCycleFromIntersection
          complete branch →
        Interface →
        Type z)
    (Visible : Type r)
    (project : Interface → Visible)
    (RepairOf : Interface → Type s) where
  family :
    IntrinsicDynamicReturnFamily
      complete coherence branch Source Interface WitnessOf
      RealizesInterface Visible project RepairOf

  dynamics : GapDrivenDynamicSystem family

  variation : GenuineDynamicUsageVariation dynamics
```

Le système final porte donc dans un même objet :

```text
les retours de tous les états ;
la règle qui consomme l'usage courant ;
la source où une variation effective est observée ;
les preuves d'inversion des pôles.
```

Les théorèmes de synthèse doivent recevoir ce paquet unique, jamais une
famille, une transition et une variation comme trois arguments indépendants.

### 13.4 Contextes distincts

Prouver :

```text
system.family.contextAt system.variation.source =
  system.family.contextAt
    (system.dynamics.next system.variation.source)
→ False
```

par projection sur le champ `source`, puis `source_ne_next`.

### 13.5 Non-réductibilité projective

La non-réductibilité vaut déjà pour toute famille ayant son gap initial ; ne
pas l'affaiblir en exigeant une variation dont la preuve n'a pas besoin :

```lean
theorem dynamicRelaxedRegime_not_exactProjective
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (representation :
      RelaxedUsageRegime.ExactProjectiveRepresentation
        (dynamicRelaxedRegimeOfReturnFamily family)) :
    False
```

La preuve utilise seulement :

```text
usage courant formé → ombre ;
symétrie forcée par la représentation exacte ;
absence d'usage ombre → formé.
```

Ajouter ensuite le corollaire :

```text
GenuinelyVaryingDynamicUsageSystem.not_exactProjective
```

qui applique le théorème précédent à `system.family`. La variation temporelle
ne remplace donc pas la stricte relaxation ; elle la porte et la transforme
d'un état à l'autre.

## 14. Modèle fini non trivial obligatoire

Le fichier `DynamicRelaxedUsageModel.lean` doit construire un habitant complet,
sans donnée vide et sans projection globale constante.

### 14.1 États

```lean
inductive SwitchState where
  | leftToRight
  | rightToLeft
```

Transition :

```text
leftToRight → rightToLeft
rightToLeft → leftToRight
```

Prouver que chaque état est distinct de son successeur.

### 14.2 Interfaces

```lean
inductive SwitchInterface where
  | leftPole
  | rightPole
  | marker
```

Le troisième constructeur interdit que tout le modèle soit réduit à la seule
fibre diagonale.

### 14.3 Visibles et projection

```lean
inductive SwitchVisible where
  | coordinated
  | marked
```

Projection :

```text
leftPole  ↦ coordinated
rightPole ↦ coordinated
marker    ↦ marked
```

Théorèmes obligatoires :

```text
project leftPole = project rightPole
leftPole ≠ rightPole
project leftPole ≠ project marker
∃ x y, project x ≠ project y
```

La projection possède donc une fibre non injective sans être constante.

### 14.4 Complétude bilatérale

Les quatre familles ne doivent pas être des alias de `SwitchState`. Définir
quatre paquets distincts :

```lean
structure SwitchComplete (_branch : SwitchState) where
  state : SwitchState

structure SwitchForward (_branch : SwitchState) where
  state : SwitchState

structure SwitchBackward (_branch : SwitchState) where
  state : SwitchState

structure SwitchIntersection (_branch : SwitchState) where
  state : SwitchState
```

Construire ensuite :

```text
BidirectionalCompleteness SwitchState
```

avec :

```text
Complete     := SwitchComplete
Forward      := SwitchForward
Backward     := SwitchBackward
Intersection := SwitchIntersection
```

Les quatre opérations recopient explicitement le champ `state` dans le paquet
cible. Elles ne sont pas des fonctions identité, puisque leurs domaines et
codomaines sont différents.

Construire ensuite :

```text
switchRoundTripCoherence
```

par analyse du paquet source, puis `rfl` sur son champ `state`. Les preuves
d'aller-retour doivent porter sur les paquets complets, pas seulement sur leurs
projections `state`.

Le type `Branch` lui-même est non trivial ; ne pas utiliser `Unit` comme
branche cachée.

Ajouter les lemmes d'observation :

```text
switchCompleteRoundTrip_state
switchIntersectionRoundTrip_state
```

et vérifier que les quatre types ne sont jamais remplacés par des `abbrev`.

### 14.5 Pôles formés selon l'état

```text
formedAt leftToRight  := leftPole
shadowAt leftToRight  := rightPole

formedAt rightToLeft := rightPole
shadowAt rightToLeft := leftPole
```

La transition inverse réellement l'orientation du gap.

### 14.6 Témoins d'interface

Définir une famille preuve-pertinente :

```lean
structure SwitchInterfaceWitness
    (interface : SwitchInterface) where
  source : SwitchState
  interface_eq_formed :
    interface = switchFormedAt source
```

Ne pas utiliser `Unit`.

### 14.7 Réalisation par le cycle

Définir :

```lean
structure SwitchRealizesInterface
    (cycle :
      ClosedStabilityTheorem.StrongTerminalCycleFromIntersection
        switchCompleteness
        SwitchState.leftToRight)
    (interface : SwitchInterface) where
  interface_eq_formed :
    interface = switchFormedAt cycle.sourceIntersection.state
```

Cette relation lie réellement l'interface à l'intersection source du cycle.

### 14.8 Réparation non triviale

Définir une instruction indexée par l'état et l'interface :

```lean
inductive SwitchRepairInstruction :
    SwitchState → SwitchInterface → Type where
  | restoreLeft :
      SwitchRepairInstruction
        SwitchState.leftToRight
        SwitchInterface.leftPole

  | restoreRight :
      SwitchRepairInstruction
        SwitchState.rightToLeft
        SwitchInterface.rightPole

  | preserveMarker (source : SwitchState) :
      SwitchRepairInstruction source SwitchInterface.marker

structure SwitchRepair
    (interface : SwitchInterface) where
  source : SwitchState
  instruction : SwitchRepairInstruction source interface
```

Définir ensuite par analyse de l'instruction :

```lean
def SwitchRepair.apply
    {interface : SwitchInterface}
    (repair : SwitchRepair interface) :
    SwitchInterface

theorem SwitchRepair.apply_correct
    {interface : SwitchInterface}
    (repair : SwitchRepair interface) :
    repair.apply = interface
```

La réparation porte ainsi une provenance et une action. Dans
`switchLocallyRecoveredDynamicReturn source`, imposer :

```text
localRecovery.recovered = localRecovery.repair.apply
localRecovery.recovered_eq_formed
  est dérivé de SwitchRepair.apply_correct
```

Il est interdit de choisir `recovered := formed` indépendamment de `repair`.
La branche `marker` rend en outre la famille de réparations habitée sur toute
interface sans utiliser un jeton universel.

### 14.9 Retour dynamique à chaque état

Construire :

```text
switchLocallyRecoveredDynamicReturn :
  (source : SwitchState) →
    LocallyRecoveredDynamicReturn
      switchCompleteness
      switchRoundTripCoherence
      SwitchState.leftToRight
      SwitchState
      SwitchInterface
      SwitchInterfaceWitness
      SwitchRealizesInterface
      SwitchVisible
      switchProjection
      SwitchRepair
```

Chaque retour doit satisfaire définitionnellement :

```text
formedReturn.source = source
formedReturn.intersection.state = source
localRecovery.formed = switchFormedAt source
localRecovery.shadow = switchShadowAt source
```

Le champ `formedReturn.intersection` doit être construit comme un
`SwitchIntersection` contenant `source`. Il ne doit pas être obtenu par une
conversion externe entre la source et l'intersection.

La réparation est `SwitchRepair`, jamais `Unit`.

### 14.10 Famille, transition causale et variation

Construire :

```text
switchIntrinsicDynamicReturnFamily
switchGapDrivenDynamicSystem
switchGenuineDynamicUsageVariation
switchGenuinelyVaryingDynamicUsageSystem
```

`switchGapDrivenDynamicSystem.advance` doit analyser son argument
`DynamicGapCausalState`, puis le `DynamicGapUse` porté par sa mémoire. Pour
l'usage canonique non contractif, il renvoie l'état opposé. Il est interdit de
le définir par une fonction constante qui ignore le témoin.

Prouver :

```text
switchAdvance_leftToRight_of_currentUse = rightToLeft
switchAdvance_rightToLeft_of_currentUse = leftToRight
switchNext_leftToRight = rightToLeft
switchNext_rightToLeft = leftToRight
```

La variation choisit `leftToRight` comme source et prouve l'inversion des pôles
au pas suivant. `switchGenuinelyVaryingDynamicUsageSystem` rassemble la famille,
la transition et ce certificat ; aucun théorème final ne les recevra
séparément.

## 15. Théorèmes finaux du modèle

Le modèle doit établir sans hypothèse ajoutée :

```text
1. le contexte initial est leftToRight ;

2. le contexte suivant est rightToLeft ;

3. les contextes sont distincts ;

4. à leftToRight :
     leftPole → rightPole ;

5. à leftToRight :
     ¬(rightPole → leftPole) ;

6. à rightToLeft :
     rightPole → leftPole ;

7. à rightToLeft :
     ¬(leftPole → rightPole) ;

8. le transport visible conserve coordinated = coordinated ;

9. le transport formé conserve un témoin orienté preuve-pertinent ;

10. chaque cycle préserve son intersection source ;

11. la projection est non constante ;

12. le régime dynamique n'admet aucune ExactProjectiveRepresentation ;

13. toutes les itérations possèdent une mémoire de gap et d'usage ;

14. deux itérations successives inversent le droit de transport ;

15. `next` est le calcul de `advance` sur l'état causal canonique ;

16. la récupération locale est le résultat de `SwitchRepair.apply` ;

17. le certificat d'usage contient séparément sa séparation et sa
    coordination.
```

Le résultat façade ne doit pas oublier les données produites derrière un
simple `Nonempty`. Définir un paquet final preuve-pertinent :

```lean
structure SwitchDynamicRelaxationSynthesis where
  varyingSystem :
    GenuinelyVaryingDynamicUsageSystem
      switchCompleteness
      switchRoundTripCoherence
      SwitchState.leftToRight
      SwitchState
      SwitchInterface
      SwitchInterfaceWitness
      SwitchRealizesInterface
      SwitchVisible
      switchProjection
      SwitchRepair

  varyingSystem_eq :
    varyingSystem = switchGenuinelyVaryingDynamicUsageSystem

  initialStep :
    DynamicUsageStep
      switchGapDrivenDynamicSystem
      SwitchState.leftToRight

  projection_nonconstant :
    switchProjection SwitchInterface.leftPole =
      switchProjection SwitchInterface.marker →
    False

  currentUse :
    DynamicGapUse
      switchIntrinsicDynamicReturnFamily
      (switchIntrinsicDynamicReturnFamily.contextAt
        SwitchState.leftToRight)
      SwitchInterface.leftPole
      SwitchInterface.rightPole

  nextUse :
    DynamicGapUse
      switchIntrinsicDynamicReturnFamily
      (switchIntrinsicDynamicReturnFamily.contextAt
        SwitchState.rightToLeft)
      SwitchInterface.rightPole
      SwitchInterface.leftPole

  notExactProjective :
    RelaxedUsageRegime.ExactProjectiveRepresentation
        (dynamicRelaxedRegimeOfReturnFamily
          switchIntrinsicDynamicReturnFamily) →
      False

def switchDynamicRelaxationSynthesis :
    SwitchDynamicRelaxationSynthesis
```

Cette valeur ne doit recevoir aucun argument. Elle expose le certificat de
variation dans son paquet système, l'étape calculée depuis le gap, les deux
usages orientés, la non-constance visible et la non-réductibilité projective au
lieu de les effacer dans une conjonction propositionnelle.

## 16. Tests anti-trivialité

### 16.1 Pas de contexte constant

```text
contextAt leftToRight = contextAt rightToLeft → False
```

### 16.2 Pas de politique constante

```text
HasUse leftToRight leftPole rightPole

HasUse rightToLeft leftPole rightPole → False
```

### 16.3 Pas de projection constante

```text
project leftPole = project marker → False
```

### 16.4 Pas de contraction

```text
formedAt source = shadowAt source → False
```

pour chaque source.

### 16.5 Pas de reconstruction globale

Depuis la fibre :

```text
project leftPole = project rightPole
leftPole ≠ rightPole
```

dériver l'impossibilité d'un inverse à gauche global de la projection.

### 16.6 Pas de symétrisation cachée

Vérifier séparément les deux réfutations :

```text
¬ Use leftToRight rightPole leftPole
¬ Use rightToLeft leftPole rightPole
```

### 16.7 Pas de témoin vide

Construire et exposer concrètement :

```text
SwitchInterfaceWitness leftPole
SwitchInterfaceWitness rightPole
SwitchRepair leftPole
SwitchRepair rightPole
```

Les audits doivent imprimer ces constructeurs principaux.

### 16.8 Pas d'identification de la coordination et de l'usage

Vérifier que le modèle expose successivement :

```text
DynamicGapCoordination.current
PLift.up separatedAt
DynamicGapUse.of_noncontractive
NonContractiveUse.use
NonContractiveUse.transport
```

Ajouter un théorème d'inversion montrant que tout usage non réflexif du
modèle contient un certificat `of_noncontractive`. La preuve ne doit pas
reconstruire ce certificat depuis le seul type de ses extrémités.

### 16.9 Pas de cycle bilatéral par alias

Les contrôles textuels et de type doivent confirmer :

```text
SwitchComplete      ≠ alias de SwitchState
SwitchForward       ≠ alias de SwitchState
SwitchBackward      ≠ alias de SwitchState
SwitchIntersection  ≠ alias de SwitchState
```

Le cycle est minimal, mais ses changements de régime sont de vraies fonctions
entre paquets distincts.

### 16.10 Pas de transition indépendante du gap

Le modèle doit prouver les deux calculs de `advance` sur les états causaux
canoniques
et les deux calculs de `next`. Le corps de
`switchGapDrivenDynamicSystem.advance` doit effectuer une élimination de son
argument `DynamicGapCausalState`, puis de `memory.use`.

Sont interdits :

```text
advance := fun ⟨source, _⟩ => switchState source
next stocké comme champ indépendant
transition obtenue depuis une table externe non indexée par l'usage
```

Le test d'élaboration doit également montrer qu'il est impossible d'appeler
`advance` sans fournir la somme dépendante contenant une source et l'état
causal de son propre gap.

## 17. Ce que le premier modèle ne doit pas prétendre

Le modèle fini démontre :

```text
la satisfaisabilité du noyau ;
la causalité gap → usage → transport ;
la variation réelle du droit de transport ;
la compatibilité avec les cycles bilatéraux ;
la stricte non-réductibilité projective.
```

Il ne démontre pas encore :

```text
que toute dynamique arbitraire porte une telle variation ;
que Tarski, Bell, Beth ou Collatz instancient automatiquement le noyau ;
que toute coordination non identitaire est souhaitable ;
que tous les usages doivent être globaux ou réversibles.
```

Ces spécialisations devront construire leur propre
`IntrinsicDynamicReturnFamily`. Aucun constructeur générique ne doit fabriquer
une famille dynamique complète depuis un seul `LocallyRecoveredDynamicReturn`,
car ce dernier ne contient ni `next`, ni les retours futurs.

## 18. Phases d'implémentation

### Phase 0 — Geler l'API actuelle

```text
compiler DynamicCore ;
compiler StrictRelaxation ;
enregistrer les sorties d'audit ;
enregistrer les signatures publiques ;
vérifier le worktree avant modification.
```

### Phase 1 — Famille et contextes

```text
créer DynamicRelaxedUsage.lean ;
ajouter IntrinsicDynamicReturnFamily ;
ajouter les projections canoniques ;
ajouter DynamicUsageContext ;
compiler et auditer.
```

### Phase 2 — Usage engendré

```text
ajouter DynamicGapReading ;
ajouter DynamicGapCoordination ;
ajouter DynamicGapUse ;
ajouter DynamicGapUse.of_noncontractive ;
prouver la composition ;
prouver l'absence de retour inverse ;
compiler et auditer.
```

### Phase 3 — Régime et causalité

```text
construire dynamicRelaxedRegimeOfReturnFamily ;
construire dynamicCompositionalUseOfReturnFamily ;
construire dynamicGapNonContractiveUse ;
construire les deux transports et leurs chaînes ;
vérifier les égalités définitionnelles.
```

### Phase 4 — Mémoire bilatérale

```text
ajouter DynamicUsageMemory ;
construire le cycle depuis l'intersection du contexte ;
prouver sourceIntersection_preserved ;
ajouter DynamicGapCausalState ;
relier ses deux chaînes de transport au même usage mémorisé ;
interdire tout cycle fourni en argument.
```

### Phase 5 — Algorithme

```text
ajouter GapDrivenDynamicSystem ;
faire de next une définition appliquant advance à l'état causal canonique ;
ajouter iterateSource ;
ajouter DynamicUsageStep ;
ajouter dynamicUsageStep ;
ajouter les étapes et mémoires itérées.
```

### Phase 6 — Variation stricte

```text
ajouter GenuineDynamicUsageVariation ;
ajouter GenuinelyVaryingDynamicUsageSystem ;
prouver le changement de contexte ;
prouver le changement du droit de transport ;
prouver la non-représentabilité projective exacte.
```

### Phase 7 — Modèle fini

```text
créer DynamicRelaxedUsageModel.lean ;
construire tous les types non triviaux ;
construire les quatre paquets bilatéraux distincts ;
construire la projection non constante ;
construire les témoins et réparations ;
construire la famille de retours ;
construire la transition qui consomme le témoin d'usage ;
construire la variation ;
construire le paquet système fermé ;
prouver les tests finaux.
```

### Phase 8 — Intégration

```text
ajouter les imports dans Meta.lean ;
mettre à jour Systeme_dynamique_bilateral.md ;
mettre à jour l'audit de clôture ;
compiler les consommateurs Tarski ;
exécuter lake build.
```

## 19. Série de commits

```text
1. core: add intrinsic dynamic return families and usage contexts

2. core: derive directional use from dynamic gaps

3. core: preserve dynamic use through bilateral cycles

4. core: add intrinsic dynamic usage steps and iteration

5. core: prove genuine variation of gap-regulated use

6. core: add a nontrivial finite dynamic relaxation model

7. docs: state the formal dynamic relaxation synthesis
```

Chaque commit Lean doit compiler indépendamment.

## 20. Audit obligatoire

### 20.1 `DynamicRelaxedUsage.lean`

Un unique bloc terminal :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.DynamicRelaxedUsage.IntrinsicDynamicReturnFamily
#print axioms Meta.DynamicRelaxedUsage.DynamicGapCoordination
#print axioms Meta.DynamicRelaxedUsage.DynamicGapUse
#print axioms Meta.DynamicRelaxedUsage.dynamicRelaxedRegimeOfReturnFamily
#print axioms Meta.DynamicRelaxedUsage.dynamicGapNonContractiveUse
#print axioms Meta.DynamicRelaxedUsage.DynamicUsageMemory
#print axioms Meta.DynamicRelaxedUsage.DynamicGapCausalState
#print axioms Meta.DynamicRelaxedUsage.GapDrivenDynamicSystem
#print axioms Meta.DynamicRelaxedUsage.dynamicUsageStep
#print axioms Meta.DynamicRelaxedUsage.GenuineDynamicUsageVariation
#print axioms Meta.DynamicRelaxedUsage.GenuinelyVaryingDynamicUsageSystem
#print axioms Meta.DynamicRelaxedUsage.dynamicRelaxedRegime_not_exactProjective
/- AXIOM_AUDIT_END -/
```

### 20.2 `DynamicRelaxedUsageModel.lean`

Un unique bloc terminal :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.DynamicRelaxedUsageModel.SwitchState
#print axioms Meta.DynamicRelaxedUsageModel.SwitchInterface
#print axioms Meta.DynamicRelaxedUsageModel.switchProjection
#print axioms Meta.DynamicRelaxedUsageModel.SwitchComplete
#print axioms Meta.DynamicRelaxedUsageModel.SwitchForward
#print axioms Meta.DynamicRelaxedUsageModel.SwitchBackward
#print axioms Meta.DynamicRelaxedUsageModel.SwitchIntersection
#print axioms Meta.DynamicRelaxedUsageModel.SwitchInterfaceWitness
#print axioms Meta.DynamicRelaxedUsageModel.SwitchRepairInstruction
#print axioms Meta.DynamicRelaxedUsageModel.SwitchRepair
#print axioms Meta.DynamicRelaxedUsageModel.SwitchRepair.apply_correct
#print axioms Meta.DynamicRelaxedUsageModel.switchIntrinsicDynamicReturnFamily
#print axioms Meta.DynamicRelaxedUsageModel.switchGapDrivenDynamicSystem
#print axioms Meta.DynamicRelaxedUsageModel.switchGenuineDynamicUsageVariation
#print axioms Meta.DynamicRelaxedUsageModel.switchGenuinelyVaryingDynamicUsageSystem
#print axioms Meta.DynamicRelaxedUsageModel.SwitchDynamicRelaxationSynthesis
#print axioms Meta.DynamicRelaxedUsageModel.switchDynamicRelaxationSynthesis
/- AXIOM_AUDIT_END -/
```

Tous les noms doivent exister. Aucun placeholder ne doit rester.

## 21. Commandes de validation

```bash
lake env lean Meta/Core/DynamicRelaxedUsage.lean
lake env lean Meta/Core/DynamicRelaxedUsageModel.lean
lake env lean Meta.lean
lake build
```

Contrôles textuels :

```bash
rg -n "axiom|sorry|admit|Classical|propext|Quot.sound|noncomputable|unsafe" \
  Meta/Core/DynamicRelaxedUsage.lean \
  Meta/Core/DynamicRelaxedUsageModel.lean

rg -n "Unit|PUnit|False.elim" \
  Meta/Core/DynamicRelaxedUsageModel.lean
```

Le second contrôle doit être vide dans le modèle final. Une occurrence de
`False` comme codomaine d'une réfutation locale est autorisée ; `False.elim`
comme mécanisme de construction ne l'est pas.

## 22. Critère de terminé

L'implémentation est terminée seulement si la chaîne suivante est un calcul
Lean effectif :

```text
source n
→ returnAt (source n)
→ intersection n
→ contexte n
→ localRecovery n
→ séparation n
→ coordination n
→ usage orienté n
→ transports formé et visible n
→ mémoire bilatérale n
→ état causal n
→ advance ⟨source n, état causal n⟩
→ next (source n), défini par ce calcul
→ gap inversé n+1
→ droit de transport inversé n+1
```

et si le fichier prouve simultanément :

```text
les pôles restent intérieurement distincts ;
leur coordination visible est conservée ;
leur usage est local et directionnel ;
l'usage est composable ;
l'usage est distinct de la coordination qui le produit ;
l'usage change avec l'état ;
la transition consomme le certificat d'usage courant ;
le cycle conserve l'intersection qui l'autorise ;
la projection globale n'est pas constante ;
aucune égalité projetée exacte ne représente le régime ;
aucune hypothèse externe ne ferme la construction.
```

La formulation finale visée est :

> Un gap produit par l'état bilatéral courant engendre intrinsèquement un droit
> local de transport. La transition interne du système produit un nouveau gap
> et peut inverser ce droit. Les transports restent composables et les pôles
> restent séparés ; l'identité individue, mais elle ne gouverne plus seule
> l'usage.

## 23. Rapport d'implémentation

Le plan est implémenté dans :

```text
Meta/Core/DynamicRelaxedUsage.lean
Meta/Core/DynamicRelaxedUsageModel.lean
```

La causalité finale est plus stricte que la première esquisse du plan :

```text
IntrinsicDynamicReturnFamily
  ne contient aucun next ;

DynamicGapCausalState
  contient mémoire bilatérale, usage et deux transports ;

GapDrivenDynamicSystem.advance
  reçoit Σ source, DynamicGapCausalState source ;

GapDrivenDynamicSystem.next
  est défini par l'application de advance
  à l'état causal canonique.
```

`Coord` et `Use` sont distincts. `DynamicGapUse.of_noncontractive` conserve
les deux causes reçues. La composition et les réfutations inverses utilisent
des vues constructives des indices, sans décision classique.

### 23.1 Ajustement d'univers sans affaiblissement

`RelaxedInterfaceRegime.Out` exige un univers de sortie commun à toutes les
lectures. L'implémentation utilise donc :

```text
ULift Interface
ULift Visible
DynamicVisibleTransportRelation
```

La relation visible conserve exactement l'égalité
`project formed = project shadow` et sa provenance dynamique. Ce relèvement ne
change ni le contenu mathématique, ni la direction du transport, ni la preuve
de non-réductibilité projective.

### 23.2 Modèle fermé

Le modèle construit effectivement :

```text
2 SwitchState ;
3 SwitchInterface ;
2 SwitchVisible ;
une projection non constante ;
4 paquets bilatéraux distincts ;
une réparation indexée avec apply et apply_correct ;
une transition qui inspecte memory.use ;
une variation qui inverse les pôles ;
un paquet final sans argument externe.
```

Les noms centraux sont :

```text
switchIntrinsicDynamicReturnFamily
switchGapDrivenDynamicSystem
switchGenuineDynamicUsageVariation
switchGenuinelyVaryingDynamicUsageSystem
switchDynamicRelaxationSynthesis
```

Validation effective :

```text
DynamicRelaxedUsage.lean      : élaboré sans erreur
DynamicRelaxedUsageModel.lean : élaboré sans erreur
Meta.lean                     : élaboré sans erreur
lake build                    : 1230 tâches réussies
audits des nouveaux modules   : aucune dépendance axiomatique
```
