# Meta/Core — lecture mathématique structurée du noyau

Ce document reconstruit le cadre mathématique porté par les fichiers Lean fournis autour de `Meta/Core`.

L’objectif n’est pas de traduire le code en slogans, mais de préserver exactement :

- les indices dépendants ;
- la différence entre données de type `Type` et propositions de type `Prop` ;
- la différence entre égalité interne et égalité projetée ;
- la portée réelle des théorèmes ;
- les endroits où le noyau transporte une donnée sans encore lui imposer une sémantique causale plus forte.

Les formules sont écrites en Unicode ordinaire, sans LaTeX.

---

## 0. Portée de la relecture

### 0.1 Fichiers directement relus

La présente version s’appuie directement sur les modules suivants :

```text
ClosedStabilityTheorem.lean
Gap.lean
ReferentialLength.lean
TwoPole.lean
ProjectedIdentity.lean
ParitySeparation.lean
DynamicStability.lean
DynamicTwoPole.lean
DynamicRoleCarrier.lean
DynamicParitySeparation.lean
OrderGap.lean
RelaxedUsageRegime.lean
```

Elle couvre donc les douze fichiers présents dans `Meta/Core` dans le checkout actuel.

### 0.2 Socle de base directement fourni

Plusieurs modules utilisent comme socle :

```text
Meta.Core.ClosedStabilityTheorem
Meta.Core.TwoPole
```

Dans le checkout actuel, ces deux fichiers sources sont présents et relus directement :

```text
Meta/Core/ClosedStabilityTheorem.lean
Meta/Core/TwoPole.lean
```

Dans ce document :

```text
socle directement vérifié
  := définition ou théorème présent dans un fichier Lean de Meta/Core
```

Les anciennes formulations prudentes parlant de socle seulement reconstruit ne s’appliquent donc pas à ce checkout.

### 0.3 Convention négative constructive

Une séparation est écrite :

```text
left = right → False
```

Elle signifie qu’une preuve de `left = right` peut être consommée pour produire une contradiction.

Aucun tiers exclu n’est nécessaire pour lire cette forme.

### 0.4 Familles dépendantes

Une famille telle que :

```text
RepairOf : Interface → Type
```

ne fournit pas une réparation globale non indexée.

Elle fournit, pour chaque interface exacte `i`, un type spécifique :

```text
RepairOf i
```

De même, les témoins peuvent être indexés par différents objets selon les modules :

```text
WitnessOfᵢ : Interface → Type
```

ou :

```text
WitnessOfᶜ :
  ProjectedIdentityCell Interface Visible project → Type
```

Il ne faut pas identifier ces deux formes.

---

## 1. Carte des dépendances

La structure générale des modules relus est la suivante :

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

RelaxedUsageRegime                      [branche autonome sans import]
```

Le noyau combine donc plusieurs niveaux qui doivent rester distincts :

```text
fermeture interne
projection visible
obstruction à la reconstruction
réparation locale
retour dynamique
lecture de rôles
transport d’usage
ordre visible
régime totalement relaxé
```

La thèse commune est :

```text
une coordination visible peut être disponible
sans contraction des pôles internes
et sans inverse global de la projection
```

---

# Partie I — Fermeture interne et cycles terminaux

## 2. Complétude bidirectionnelle

Le module `ClosedStabilityTheorem.lean` porte une structure :

```text
BidirectionalCompleteness Branch
```

avec quatre familles dépendantes :

```text
Complete     : Branch → Type
Forward      : Branch → Type
Backward     : Branch → Type
Intersection : Branch → Type
```

et quatre opérations internes :

```text
forwardOfComplete :
  ∀ b : Branch,
    Complete b →
    Forward b

backwardOfComplete :
  ∀ b : Branch,
    Complete b →
    Backward b

intersectionOfComplete :
  ∀ b : Branch,
    Complete b →
    Intersection b

completeOfIntersection :
  ∀ b : Branch,
    Intersection b →
    Complete b
```

Le point central est la présence positive de :

```text
Intersection b → Complete b
```

La recomposition terminale est donc fournie par le cadre lui-même.

Elle n’est pas ajoutée comme hypothèse externe au dernier moment.

### 2.1 Ce que « bidirectionnel » signifie ici

Dans le noyau exposé, `Forward`, `Backward` et `Intersection` sont tous lus depuis `Complete`.

Le code ne fournit pas une opération du type :

```text
Forward b → Backward b → Intersection b
```

Il ne fournit pas non plus une loi disant que l’intersection est construite par combinaison binaire des deux directions.

La dépendance formelle est donc :

```text
             Complete b
             /    |    \
            /     |     \
     Forward b  Backward b  Intersection b
                              |
                              v
                           Complete b
```

L’interaction entre les deux directions passe par `Complete`, non par une opération directe entre `Forward` et `Backward`.

---

## 3. Cycle terminal brut

Pour :

```text
b : Branch
complete : BidirectionalCompleteness Branch
```

un cycle terminal brut porte :

```text
TerminalCycle complete b :=
  completeIn   : complete.Complete b
  forward      : complete.Forward b
  backward     : complete.Backward b
  intersection : complete.Intersection b
  recomposed   : complete.Complete b
```

Ce paquet ne dit pas encore que ses cinq champs sont reliés de manière canonique.

Il enregistre seulement des habitants des familles correspondantes.

### 3.1 Cycle canonique issu d’une complétude

Pour :

```text
c : complete.Complete b
```

le cycle canonique prend :

```text
completeIn   := c
forward      := complete.forwardOfComplete b c
backward     := complete.backwardOfComplete b c
intersection := complete.intersectionOfComplete b c
recomposed   :=
  complete.completeOfIntersection b
    (complete.intersectionOfComplete b c)
```

### 3.2 Cycle canonique issu d’une intersection

Pour :

```text
ι : complete.Intersection b
```

on forme d’abord :

```text
complete.completeOfIntersection b ι : complete.Complete b
```

puis on applique la construction canonique précédente.

---

## 4. Cohérence d’un cycle

Un cycle cohérent est un cycle brut dont les champs sont identifiés aux lectures canoniques de `completeIn` :

```text
CoherentTerminalCycle complete b :=
  cycle : TerminalCycle complete b

  cycle.forward =
    complete.forwardOfComplete b cycle.completeIn

  cycle.backward =
    complete.backwardOfComplete b cycle.completeIn

  cycle.intersection =
    complete.intersectionOfComplete b cycle.completeIn

  cycle.recomposed =
    complete.completeOfIntersection b cycle.intersection
```

La cohérence est interne au paquet.

Elle ne dépend pas d’une extensionalité externe des objets concernés.

### 4.1 Ce que cette cohérence ne donne pas encore

Elle ne donne pas automatiquement :

```text
cycle.recomposed = cycle.completeIn
```

Elle assure seulement que `recomposed` est bien la recomposition de l’intersection enregistrée.

L’égalité de retour au point initial demande une loi supplémentaire.

---

## 5. Cohérences d’aller-retour

Deux lois sont distinguées.

### 5.1 Réextraction de la complétude

```text
ReextractionCoherence complete :=
  ∀ b : Branch,
  ∀ c : complete.Complete b,
    complete.completeOfIntersection b
      (complete.intersectionOfComplete b c)
    = c
```

Cette loi dit :

```text
Complete → Intersection → Complete
```

revient à la complétude de départ.

### 5.2 Recomposition de l’intersection

```text
IntersectionRecompositionCoherence complete :=
  ∀ b : Branch,
  ∀ ι : complete.Intersection b,
    complete.intersectionOfComplete b
      (complete.completeOfIntersection b ι)
    = ι
```

Cette loi dit :

```text
Intersection → Complete → Intersection
```

revient à l’intersection de départ.

### 5.3 Paquet total

```text
RoundTripCoherence complete :=
  completeRoundTrip     : ReextractionCoherence complete
  intersectionRoundTrip : IntersectionRecompositionCoherence complete
```

Avec les deux lois, les familles :

```text
complete.Complete b
complete.Intersection b
```

sont reliées fibre par fibre par deux fonctions inversement cohérentes.

Mathématiquement, cela a la forme d’une équivalence dépendante par branche, même si le noyau l’expose sous forme de fonctions et de lois séparées.

---

## 6. Cycle terminal fort depuis une intersection

Pour une intersection source :

```text
sourceIntersection : complete.Intersection b
```

la construction forte conserve explicitement sa provenance :

```text
StrongTerminalCycleFromIntersection complete b :=
  sourceIntersection : complete.Intersection b
  strongCycle : StrongTerminalCycle complete b
```

avec notamment :

```text
strongCycle.coherentCycle.cycle.completeIn =
  complete.completeOfIntersection b sourceIntersection
```

puis :

```text
strongCycle.coherentCycle.cycle.intersection =
  complete.intersectionOfComplete b
    (complete.completeOfIntersection b sourceIntersection)
```

et enfin la loi terminale :

```text
complete.intersectionOfComplete b
  (complete.completeOfIntersection b sourceIntersection)
=
sourceIntersection
```

Le dernier champ est une instance de la cohérence d’intersection.

La source n’est donc pas seulement utilisée pour amorcer le cycle ; elle est retrouvée par l’aller-retour interne.

---

## 7. Témoin d’interface

Un témoin d’interface est un paquet dépendant :

```text
InterfaceWitness Interface WitnessOf :=
  interface : Interface
  witness   : WitnessOf interface
```

Le second champ dépend de la valeur exacte du premier.

La forme correcte est :

```text
witness : WitnessOf interface
```

et non :

```text
witness : Witness
```

pour un type global indépendant de l’interface.

---

## 8. Fermeture référentielle formée

Le module `ClosedStabilityTheorem.lean` décrit une fermeture formée portant notamment :

```text
formedInterface    : Interface
shadowInterface    : Interface
sameProjection     :
  project formedInterface = project shadowInterface
separatedInterface :
  formedInterface = shadowInterface → False
repair             : RepairOf formedInterface
recoveredInterface : Interface
recovered_eq_formed :
  recoveredInterface = formedInterface
outcome            : OutcomeOf formedInterface
```

La réparation et l’issue sont indexées par le pôle formé :

```text
repair  : RepairOf formedInterface
outcome : OutcomeOf formedInterface
```

La forme conceptuelle est :

```text
formé et ombre sont séparés
mais ont la même projection
et le formé porte une réparation locale
```

### 8.1 Portée exacte du champ `repair`

Dans cette interface générique, le code ne dit pas que :

```text
repair
```

calcule :

```text
recoveredInterface
```

Il dit que ces données cohabitent dans le même paquet et que la récupération enregistrée est égale au formé.

Une causalité plus forte exigerait par exemple :

```text
applyRepair :
  ∀ i : Interface,
    RepairOf i → Interface

repair_correct :
  ∀ i repair,
    applyRepair i repair = i
```

ou une relation dépendante :

```text
Repairs :
  ∀ i : Interface,
    RepairOf i → Interface → Type
```

Le noyau actuel reste volontairement plus abstrait.

---

# Partie II — Projection, obstruction et gap référentiel

## 9. Projection visible

Le motif projectif part de :

```text
Interface : Typeᵤ
Visible   : Typeᵥ
project   : Interface → Visible
```

La projection peut oublier une distinction interne.

Deux notions doivent être séparées :

```text
égalité interne :
  left = right

égalité projetée :
  project left = project right
```

Le noyau ne postule jamais que la seconde implique toujours la première.

---

## 10. Fidélité de fibre

La fidélité projective porte une opération de la forme :

```text
ProjectionFiberFaithful Interface Visible project :=
  preserves :
    ∀ left right : Interface,
      project left = project right →
      left = right
```

Elle exprime l’injectivité de la projection sur ses fibres.

Dans le vocabulaire du gap, elle représente le régime contractible ou court.

---

## 11. Conservation globale de l’information

Une projection conservant globalement l’information porte :

```text
ProjectionInformationConserving Interface Visible project :=
  recover : Visible → Interface
  reconstructs :
    ∀ i : Interface,
      recover (project i) = i
```

`recover` est un inverse à gauche de `project`.

Le noyau en déduit constructivement la fidélité de fibre :

```text
ProjectionInformationConserving
→
ProjectionFiberFaithful
```

La preuve est la chaîne standard :

```text
project left = project right
⇒ recover (project left) = recover (project right)
⇒ left = right
```

à l’aide des égalités de reconstruction.

---

## 12. Obstruction projective

Une obstruction est un témoin positif de non-fidélité :

```text
ProjectionObstruction Interface Visible project :=
  left  : Interface
  right : Interface
  sameProjection :
    project left = project right
  separatedInterface :
    left = right → False
```

Elle ne se contente pas de nier abstraitement l’injectivité.

Elle expose une paire concrète :

```text
left ≠ right
project left = project right
```

### 12.1 Contradictions constructives

Le noyau fournit :

```text
ProjectionObstruction
→ ProjectionFiberFaithful
→ False
```

et donc :

```text
ProjectionObstruction
→ ProjectionInformationConserving
→ False
```

La contradiction est obtenue en appliquant la fidélité à `sameProjection`, puis en consommant l’égalité interne résultante avec `separatedInterface`.

### 12.2 Non-reconstruction fonctionnelle

La même obstruction donne :

```text
ProjectionObstruction
→
(
  ∀ recover : Visible → Interface,
    (∀ i : Interface, recover (project i) = i) →
    False
)
```

Le point exact est :

```text
aucune fonction uniforme Visible → Interface
ne peut reconstruire toutes les interfaces
```

L’obstruction ne nie pas une récupération locale d’un pôle choisi.

---

## 13. Récupération projective locale

La forme opérationnelle utilisée par `Gap.lean` est :

```text
LocalProjectiveRecovery Interface Visible project RepairOf
```

Elle porte essentiellement :

```text
formed : Interface
shadow : Interface
sameProjection :
  project formed = project shadow
separated :
  formed = shadow → False
repair : RepairOf formed
recovered : Interface
recovered_eq_formed :
  recovered = formed
```

La localité vient de deux faits :

```text
la réparation est indexée par formed
la récupération certifiée concerne formed
```

Il n’existe pas ici de fonction globale :

```text
Visible → Interface
```

### 13.1 Donnée locale contre inverse global

Le schéma cohérent est :

```text
une réparation locale du formé existe
mais une reconstruction uniforme de toutes les interfaces est impossible
```

Il n’y a aucune contradiction entre ces deux affirmations.

---

## 14. Les trois régimes de gap

`Gap.lean` introduit trois alias.

### 14.1 Gap contractible

```text
ContractibleReferentialGap Interface Visible project :=
  ProjectionFiberFaithful Interface Visible project
```

Le visible détermine alors l’interface dans chaque fibre.

### 14.2 Gap structurel

```text
StructuralReferentialGap Interface Visible project :=
  ProjectionObstruction Interface Visible project
```

Une même valeur visible couvre deux pôles séparés.

### 14.3 Gap opérationnel

```text
OperationalReferentialGap Interface Visible project RepairOf :=
  LocalProjectiveRecovery Interface Visible project RepairOf
```

Il ajoute au gap structurel :

```text
un pôle formé
une réparation indexée par ce pôle
une interface récupérée égale au formé
```

### 14.4 Projection opérationnel → structurel

Le fichier fournit :

```text
structuralGapOfOperationalGap :
  OperationalReferentialGap ...
  → StructuralReferentialGap ...
```

Cette projection oublie les données de réparation et de récupération, mais conserve :

```text
formed
shadow
sameProjection
separated
```

### 14.5 Réfutations

Le noyau prouve :

```text
StructuralReferentialGap
→ ContractibleReferentialGap
→ False
```

```text
StructuralReferentialGap
→ ProjectionInformationConserving
→ False
```

```text
OperationalReferentialGap
→ ContractibleReferentialGap
→ False
```

```text
OperationalReferentialGap
→ ProjectionInformationConserving
→ False
```

et expose directement :

```text
noProjectiveReconstructionOfOperationalGap
```

### 14.6 Sens précis de « plus riche »

Le gap opérationnel est plus riche comme structure de données :

```text
OperationalGap → StructuralGap
```

La réciproque n’est pas fournie.

Pour une famille arbitraire :

```text
RepairOf i := Empty
```

un gap structurel peut exister sans qu’un gap opérationnel soit constructible.

La richesse est donc réelle au niveau des champs requis ; elle ne doit pas être réduite à une simple reformulation logique de l’obstruction.

---

## 15. Longueur référentielle

`ReferentialLength.lean` ne définit aucun nombre de longueur.

Il renomme les trois régimes précédents.

### 15.1 Présentation courte

```text
ShortReferentialPresentation Interface Visible project :=
  ContractibleReferentialGap Interface Visible project
```

### 15.2 Longueur structurelle enrichie

```text
EnrichedStructuralReferentialLength Interface Visible project :=
  StructuralReferentialGap Interface Visible project
```

### 15.3 Longueur opérationnelle enrichie

```text
EnrichedOperationalReferentialLength
  Interface Visible project RepairOf :=
  OperationalReferentialGap Interface Visible project RepairOf
```

Le vocabulaire encode donc :

```text
court :
  le visible détermine l’interface

enrichi structurel :
  une valeur visible couvre des interfaces séparées

enrichi opérationnel :
  le pôle formé porte en plus une réparation locale
```

Les théorèmes sont :

```text
EnrichedStructuralReferentialLength
→ ShortReferentialPresentation
→ False
```

```text
EnrichedOperationalReferentialLength
→ ShortReferentialPresentation
→ False
```

et :

```text
EnrichedOperationalReferentialLength
→ EnrichedStructuralReferentialLength
```

---

## 16. Deux pôles

Le module `TwoPole.lean` expose le même contenu sous un vocabulaire polaire.

La lecture reconstruite est :

```text
StructuralTwoPole := StructuralReferentialGap
OperationalTwoPole := OperationalReferentialGap
```

Un deux-pôles opérationnel expose notamment :

```text
leftPole  := formed
rightPole := shadow
```

avec :

```text
project leftPole = project rightPole
leftPole = rightPole → False
RepairOf leftPole
```

Il réfute la présentation courte et toute reconstruction globale depuis le visible.

Le vocabulaire « deux pôles » ne crée pas une nouvelle structure mathématique indépendante du gap ; il fournit une façade adaptée aux lectures de rôles et de parité.

---

## 17. Réalisation minimale de parité

`ParitySeparation.lean` donne un modèle concret et minimal.

### 17.1 Régimes internes

```text
ParityRegime :=
  | left
  | right
```

### 17.2 Visible contracté

```text
ParityVisible :=
  | contracted
```

### 17.3 Projection constante

```text
parityProjection : ParityRegime → ParityVisible
parityProjection _ := contracted
```

Donc :

```text
parityProjection left = parityProjection right
```

par égalité définitionnelle.

En revanche :

```text
left = right → False
right = left → False
```

par élimination des constructeurs distincts.

### 17.4 Réparation de régime

```text
ParityRegimeRepair regime :=
  visible : ParityVisible
  recovered : ParityRegime
  visible_eq_projection :
    visible = parityProjection regime
  recovered_eq_regime :
    recovered = regime
```

La réparation canonique prend :

```text
visible   := parityProjection regime
recovered := regime
```

avec deux preuves `rfl`.

Ici, contrairement à une famille de réparations totalement abstraite, le type même de la réparation contient une valeur récupérée et sa correction.

### 17.5 Quatre réalisations

Le module construit :

```text
parityStructuralTwoPole
parityOperationalTwoPole
parityOppositeStructuralTwoPole
parityOppositeOperationalTwoPole
```

Les orientations sont :

```text
left → right
right → left
```

### 17.6 Conséquences

Les deux réalisations opérationnelles fournissent :

```text
même visible
séparation interne
réparation du pôle formé
réfutation de la présentation courte
réfutation de la contractibilité
impossibilité de reconstruction globale
```

La parité n’est pas arithmétique ici.

Elle est la réalisation minimale de :

```text
deux constructeurs internes distincts
une projection visible constante
```

---

# Partie III — Retours dynamiques et lectures de rôles

## 18. Retour dynamique formé

`DynamicStability.lean` introduit :

```text
FormedDynamicReturn complete branch Source :=
  source : Source
  intersection : complete.Intersection branch
```

La source dynamique est laissée abstraite.

Le seul lien exigé est qu’elle soit empaquetée avec une intersection typée de la branche considérée.

Il n’existe pas, dans cette structure, de champ du type :

```text
intersectionOfSource : Source → complete.Intersection branch
```

ni de preuve disant que `intersection` est calculée à partir de `source`. La provenance « la source fournit l’intersection » est représentée ici par leur cohabitation dans le même paquet. Une application peut renforcer ce lien avec une relation ou une fonction supplémentaire.

Le noyau ne suppose pas une forme particulière de dynamique, de temps ou d’évolution.

---

## 19. Provenance temporelle d’un excès formé

Le module contient aussi une structure absente des résumés les plus courts :

```text
TemporalExcessDynamicReturn
  complete
  branch
  Source
  dynamicReturn
  Time
  Excess
```

Elle porte :

```text
terminalTimeOf : Source → Time
formedExcessOf : complete.Intersection branch → Excess
advance : Time → Excess
```

et une égalité pour le retour dynamique fixé :

```text
formedExcessOf dynamicReturn.intersection
=
advance (terminalTimeOf dynamicReturn.source)
```

### 19.1 Portée exacte

Cette structure formalise une provenance commutative :

```text
source
  ──terminalTimeOf──> Time
  ──advance─────────> Excess

intersection
  ──formedExcessOf──> Excess
```

avec égalité des deux résultats pour le paquet donné.

Elle ne fournit pas :

```text
un ordre sur Time
une relation avant/après
une monotonie de advance
une causalité universelle
une dynamique itérée
```

Le mot « temporel » nomme ici les types et la factorisation portée par les champs ; la structure mathématique exigée reste une égalité de provenance.

---

## 20. Retour dynamique localement récupéré

La structure centrale est :

```text
LocallyRecoveredDynamicReturn
```

Elle dépend de :

```text
complete : BidirectionalCompleteness Branch
coherence : RoundTripCoherence complete
branch : Branch
Source : Type
Interface : Type
WitnessOf : Interface → Type
RealizesInterface :
  StrongTerminalCycleFromIntersection complete branch
  → Interface
  → Type
Visible : Type
project : Interface → Visible
RepairOf : Interface → Type
```

Elle porte :

```text
formedReturn :
  FormedDynamicReturn complete branch Source

formed :
  InterfaceWitness Interface WitnessOf

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

### 20.1 Raccord essentiel

Le champ décisif est :

```text
localRecovery.formed = formed.interface
```

Il empêche de lire :

```text
l’interface réalisée par le cycle
```

et :

```text
l’interface localement réparée
```

comme deux pôles sans relation.

La même interface est utilisée des deux côtés, à égalité près.

### 20.2 Fermeture récupérée

Le module fournit :

```text
locallyRecoveredClosedStabilityOfDynamicReturn
```

qui applique un théorème déjà présent dans `ClosedStabilityTheorem.lean` :

```text
locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
```

Le retour dynamique n’ajoute donc pas un nouvel axiome de stabilité.

Il assemble les données requises par le théorème existant.

---

## 21. Retour dynamique comme gap et deux-pôles

`DynamicTwoPole.lean` expose directement :

```text
dynamicReturn_operationalGap :
  LocallyRecoveredDynamicReturn ...
  → OperationalReferentialGap ...
```

La définition est simplement :

```text
dynamicReturn.localRecovery
```

Puis :

```text
dynamicReturn_structuralGap
```

est obtenu en oubliant les données opérationnelles.

Le même objet est ensuite relu comme :

```text
dynamicReturn_operationalTwoPole
dynamicReturn_structuralTwoPole
```

### 21.1 Conséquence de longueur

Tout retour dynamique localement récupéré réfute :

```text
ShortReferentialPresentation Interface Visible project
```

car sa récupération locale contient déjà une obstruction projective.

Le caractère dynamique ne crée pas une nouvelle preuve de non-contractibilité ; il transporte une instance opérationnelle du gap.

---

## 22. Porteur dynamique de rôles

`DynamicRoleCarrier.lean` ajoute une seconde couche projective.

On part d’un retour dynamique fixé et de :

```text
Role : Type
RoleVisible : Type
roleProject : Role → RoleVisible
RoleRepairOf : Role → Type
```

Le porteur contient :

```text
roleOf : Interface → Role
visibleRoleOf : Visible → RoleVisible

roleTwoPole :
  OperationalTwoPole
    Role
    RoleVisible
    roleProject
    RoleRepairOf
```

avec quatre compatibilités ponctuelles :

```text
roleOf dynamicReturn.localRecovery.formed =
  leftPole roleTwoPole

roleOf dynamicReturn.localRecovery.shadow =
  rightPole roleTwoPole

visibleRoleOf
  (project dynamicReturn.localRecovery.formed)
=
roleProject
  (roleOf dynamicReturn.localRecovery.formed)

visibleRoleOf
  (project dynamicReturn.localRecovery.shadow)
=
roleProject
  (roleOf dynamicReturn.localRecovery.shadow)
```

### 22.1 Deux niveaux de deux-pôles

Le porteur conserve simultanément :

```text
un deux-pôles sur Interface
un deux-pôles sur Role
```

Le premier vient du retour dynamique.

Le second est un champ positif supplémentaire.

### 22.2 Égalité visible des rôles

Le module prouve :

```text
formedVisibleRole = shadowVisibleRole
```

par la chaîne :

```text
visible dynamique formé
= projection du rôle formé
= projection du pôle gauche de rôle
= projection du pôle droit de rôle
= projection du rôle ombre
= visible dynamique ombre
```

Le terme fourni par le code passe volontairement par :

```text
roleTwoPole
```

et les quatre compatibilités ponctuelles. Comme `visibleRoleOf` est une fonction, l’égalité pourrait aussi être obtenue directement par congruence à partir de la projection égale du deux-pôles dynamique. La preuve choisie certifie explicitement que le second référentiel de rôles reproduit lui-même le motif projectif.

### 22.3 Séparation des rôles

Il prouve aussi :

```text
formedRole = shadowRole → False
```

La preuve transporte une égalité supposée vers une égalité entre les deux pôles du `roleTwoPole`, puis utilise sa séparation.

### 22.4 Compatibilité seulement ponctuelle

Le porteur ne demande pas une loi globale :

```text
∀ i : Interface,
  visibleRoleOf (project i) = roleProject (roleOf i)
```

Il demande seulement cette compatibilité sur :

```text
localRecovery.formed
localRecovery.shadow
```

Le carré projectif est donc local au deux-pôles dynamique choisi.

### 22.5 Réparations et obstruction de rôle

Le porteur expose :

```text
dynamicRepair : RepairOf (leftPole dynamicTwoPole)
roleRepair : RoleRepairOf (leftPole roleTwoPole)
```

ainsi que :

```text
aucune reconstruction globale RoleVisible → Role
```

compatible avec tous les rôles.

Il réfute également la présentation courte du référentiel de rôles.

---

## 23. Rôles dynamiques médiés

Le module définit ensuite :

```text
MediatedDynamicRoles carrier
```

avec :

```text
closingRole : Role
mediatingRole : Role

closing_eq_formed :
  closingRole = formedRole

mediating_eq_shadow :
  mediatingRole = shadowRole

sameVisible :
  formedVisibleRole = shadowVisibleRole

separated :
  closingRole = mediatingRole → False

dynamicRepair
roleRepair
noRoleVisibleReconstruction
```

Le constructeur canonique :

```text
mediatedDynamicRolesOfCarrier
```

ne demande aucune hypothèse nouvelle.

Il réemballe les conséquences déjà dérivables du porteur.

### 23.1 Projection de rôle des deux rôles médiés

Le module prouve :

```text
roleProject closingRole = roleProject mediatingRole
```

alors que :

```text
closingRole = mediatingRole → False
```

La forme obtenue est exactement un gap structurel au niveau des rôles, enrichi des réparations déjà présentes.

---

## 24. Statut de la spécialisation dynamique de parité

Le fichier `DynamicParitySeparation.lean` est présent dans le checkout actuel.

Il formalise directement le raccord entre un retour dynamique localement récupéré et la séparation minimale de parité.

La spécialisation fixe :

```text
Role         := ParityRegime
RoleVisible  := ParityVisible
roleProject  := parityProjection
RoleRepairOf := ParityRegimeRepair
```

et introduit une structure qui porte explicitement :

```text
regimeOf
visibleOf
parityTwoPole
formed_regime
shadow_regime
formed_visible
shadow_visible
```

Le fichier construit ensuite le `DynamicRoleCarrier` correspondant et les rôles opérationnels de parité.

L’existence d’une telle séparation exige toujours les champs :

```text
regimeOf
visibleOf
formed_regime
shadow_regime
formed_visible
shadow_visible
```

Elle n’est pas automatique pour tout retour dynamique.

La conclusion exacte est :

```text
si ces lectures de parité sont fournies comme données de raccord,
alors DynamicParitySeparation produit les conséquences opérationnelles
```

et non :

```text
tout retour dynamique possède canoniquement une séparation de parité
```

---

# Partie IV — Identité projetée et transport d’usage

## 25. Cellule d’identité projetée

`ProjectedIdentity.lean` introduit :

```text
ProjectedIdentityCell Interface Visible project :=
  formed : Interface
  shadow : Interface
  sameVisible :
    project formed = project shadow
  separated :
    formed = shadow → False
```

Cette cellule est une obstruction projective orientée :

```text
formed
shadow
```

Elle porte simultanément :

```text
égalité visible
séparation interne
```

Aucun quotient n’est construit.

---

## 26. Cellule d’identité lue

Pour :

```text
read : Visible → Label
```

le module définit la projection composée :

```text
readProjection project read : Interface → Label
readProjection project read i := read (project i)
```

Puis :

```text
ReadIdentityCell Interface Visible Label project read :=
  formed : Interface
  shadow : Interface
  sameRead :
    read (project formed) = read (project shadow)
  separated :
    formed = shadow → False
```

Une cellule projetée produit une cellule lue par congruence :

```text
congrArg read cell.sameVisible
```

Le module ne suppose aucune propriété supplémentaire de `read`.

---

## 27. Trois identités distinctes

### 27.1 Identité interne

```text
InternalIdentity project left right :=
  left = right
```

Le paramètre `project` est présent pour harmoniser l’interface de la notion, mais l’égalité elle-même ne dépend pas de la projection.

### 27.2 Identité projetée

```text
ProjectedIdentity project left right :=
  project left = project right
```

### 27.3 Identité d’usage

```text
InterfaceIdentityOfUse project left right :=
  ProjectedIdentity project left right
```

C’est un alias définitionnel.

Le théorème :

```text
InterfaceIdentityOfUse project left right
↔
ProjectedIdentity project left right
```

est `Iff.rfl`.

L’identité d’usage ne transforme donc pas l’égalité projetée en égalité interne.

Elle nomme la décision d’utiliser l’égalité visible comme principe de coordination.

---

## 28. Transport par une lecture fixe

Le transport associé à une lecture est :

```text
InterfaceReadTransport project read left right :=
  read (project left) = read (project right)
```

Une identité projetée donne ce transport :

```text
ProjectedIdentity project left right
→
InterfaceReadTransport project read left right
```

par :

```text
congrArg read
```

La même conclusion part de l’identité d’usage puisque celle-ci est définitionnellement l’identité projetée.

### 28.1 Lecture identité

Pour :

```text
read := fun visible => visible
```

on a définitionnellement :

```text
InterfaceReadTransport project id left right
↔
ProjectedIdentity project left right
```

---

## 29. Transport polymorphe

Le module définit :

```text
InterfaceTransport project left right :=
  (Label : Typeᵥ) →
  (read : Visible → Label) →
  InterfaceReadTransport project read left right
```

La quantification sur `Label` est située au même niveau d’univers que `Visible` dans la définition fournie.

Le théorème principal est :

```text
InterfaceTransport project left right
↔
ProjectedIdentity project left right
```

### 29.1 Direction d’action

```text
ProjectedIdentity
→ InterfaceTransport
```

par congruence pour chaque lecture.

### 29.2 Direction de récupération

```text
InterfaceTransport
→ ProjectedIdentity
```

par le choix :

```text
Label := Visible
read  := identité
```

Le transport polymorphe n’est donc pas plus fort que l’égalité projetée.

Il est sa forme opérationnelle sur les lectures visibles du niveau d’univers autorisé.

---

## 30. Cellule d’identité d’usage

Le module introduit une façade :

```text
IdentityOfUseCell Interface Visible project :=
  formed : Interface
  shadow : Interface
  usedIdentity :
    InterfaceIdentityOfUse project formed shadow
  internalSeparation :
    InternalIdentity project formed shadow → False
```

Une `ProjectedIdentityCell` produit directement cette cellule.

La différence est terminologique :

```text
ProjectedIdentityCell
  nomme le champ sameVisible

IdentityOfUseCell
  nomme le même champ usedIdentity
```

Dans les deux cas, la séparation interne reste portée dans le même paquet.

---

## 31. Chaîne constructive d’interface

Pour une lecture fixe :

```text
ConstructiveInterfaceChain project read left right :=
  (InternalIdentity project left right → False)
  ∧
  (
    InterfaceIdentityOfUse project left right
    ∧
    InterfaceReadTransport project read left right
  )
```

La chaîne contient exactement :

```text
séparation interne
égalité projetée utilisée
transport de la lecture
```

Une cellule projetée ou une cellule d’identité d’usage fournit cette chaîne.

La séquence logique est :

```text
sameVisible
  ⇒ identityOfUse
  ⇒ read transport
```

pendant que :

```text
formed = shadow → False
```

reste disponible séparément.

---

## 32. Obstructions extraites des cellules

Une cellule projetée est convertie en :

```text
DiagonalCertificate
```

puis en :

```text
ProjectionObstruction
```

Elle interdit donc une reconstruction globale :

```text
Visible → Interface
```

qui reconstruirait toutes les interfaces.

De même, une cellule lue interdit une reconstruction globale depuis `Label` pour la projection composée :

```text
read ∘ project : Interface → Label
```

Le résultat est plus fort qu’un simple transport positif :

```text
le même paquet permet le transport au niveau lu
et produit une obstruction à la reconstruction depuis ce niveau
```

---

## 33. Invariants positifs

Le module définit :

```text
PositiveProjectedInvariant
```

avec :

```text
cell : ProjectedIdentityCell ...
witness : WitnessOf cell
witness_pos : Positive cell witness
```

La famille `WitnessOf` est indexée par la cellule entière, pas seulement par l’interface formée.

Il existe une version analogue pour les cellules lues :

```text
PositiveReadInvariant
```

Le terme « positif » signifie ici qu’une preuve :

```text
Positive cell witness
```

est portée comme donnée.

Aucune notion globale de positivité n’est imposée par le noyau ; elle est paramétrée.

---

## 34. Relaxation de projection contrainte

La structure :

```text
ConstrainedProjectionRelaxation
```

met en relation deux régimes visibles sur les mêmes interfaces internes.

Elle dépend de :

```text
projectIn  : Interface → VisibleIn
projectOut : Interface → VisibleOut
readIn     : VisibleIn → Label
readOut    : VisibleOut → Label
```

et d’une famille :

```text
WitnessOf :
  ProjectedIdentityCell Interface VisibleIn projectIn → Type
```

avec :

```text
Positive :
  ∀ cell,
    WitnessOf cell → Prop
```

### 34.1 Champs principaux

```text
sourceCell :
  ProjectedIdentityCell Interface VisibleIn projectIn

sameOut :
  projectOut sourceCell.formed =
  projectOut sourceCell.shadow

visibleShift :
  readIn (projectIn sourceCell.formed) =
  readOut (projectOut sourceCell.formed)
  → False

invariant : WitnessOf sourceCell
invariant_pos : Positive sourceCell invariant

witnessIn  : WitnessOf sourceCell
witnessOut : WitnessOf sourceCell

witnessIn_eq  : witnessIn = invariant
witnessOut_eq : witnessOut = invariant
```

### 34.2 Cellule d’entrée et cellule de sortie

L’entrée est simplement :

```text
sourceCell
```

La sortie est construite sur les mêmes pôles :

```text
formed := sourceCell.formed
shadow := sourceCell.shadow
```

avec :

```text
sameVisible := sameOut
separated   := sourceCell.separated
```

La relaxation conserve donc la paire interne et sa séparation, tout en changeant la projection visible.

### 34.3 Deux chaînes constructives

Le module dérive :

```text
ConstructiveInterfaceChain
  projectIn readIn formed shadow
```

et :

```text
ConstructiveInterfaceChain
  projectOut readOut formed shadow
```

Il dérive également des obstructions et des théorèmes de non-reconstruction pour les deux projections.

### 34.4 Déplacement visible

Le champ `visibleShift` concerne exactement le pôle formé :

```text
readIn (projectIn formed)
=
readOut (projectOut formed)
→ False
```

Il ne fournit pas une séparation analogue sur le pôle ombre, sauf donnée supplémentaire.

### 34.5 Portée exacte de la conservation du témoin

Les trois termes :

```text
invariant
witnessIn
witnessOut
```

ont tous le même type :

```text
WitnessOf sourceCell
```

Le module montre :

```text
witnessIn  = invariant
witnessOut = invariant
```

Il ne construit pas un transport dépendant vers une famille indexée par la cellule de sortie :

```text
WitnessOfOut outputCell
```

Une telle famille n’est pas un paramètre de la structure.

La conservation est donc littérale sur l’indice source : les témoins d’entrée et de sortie sont identifiés au même invariant de `sourceCell`.

### 34.6 Portée exacte de la positivité

La preuve disponible est :

```text
Positive sourceCell invariant
```

La structure ne porte pas séparément une proposition de positivité indexée par la cellule de sortie.

Cela n’empêche pas une application d’en définir une, mais ce n’est pas un champ du noyau actuel.

---

# Partie V — Test par ordre visible

## 35. Préordre, ordre partiel et ordre total visibles

`OrderGap.lean` définit ses propres structures minimales.

### 35.1 Préordre visible

```text
VisiblePreorder Visible :=
  le : Visible → Visible → Prop
  refl :
    ∀ v : Visible,
      le v v
  trans :
    ∀ a b c : Visible,
      le a b →
      le b c →
      le a c
```

### 35.2 Ordre partiel visible

```text
VisiblePartialOrder Visible
```

étend le préordre avec :

```text
antisymm :
  ∀ a b : Visible,
    le a b →
    le b a →
    a = b
```

### 35.3 Ordre total visible

```text
VisibleTotalOrder Visible
```

ajoute :

```text
total :
  ∀ a b : Visible,
    le a b ∨ le b a
```

Le module n’importe pas une bibliothèque d’ordre plus large ; il ne requiert que les lois utilisées par les théorèmes du gap.

---

## 36. Équivalence visible par ordre

La relation est :

```text
VisibleOrderEquivalent order left right :=
  order.le left right
  ∧
  order.le right left
```

Elle exprime la comparabilité mutuelle dans le préordre.

Le module prouve explicitement sa réflexivité.

Dans un ordre partiel, l’antisymétrie donne :

```text
VisibleOrderEquivalent order left right
→ left = right
```

---

## 37. Projection contractive pour l’ordre

La propriété centrale est :

```text
OrderContractiveProjection
  Interface Visible project order :=
  ∀ left right : Interface,
    order.le (project left) (project right) →
    order.le (project right) (project left) →
    left = right
```

Elle dit que la comparabilité mutuelle au niveau visible contracte les interfaces internes.

### 37.1 Du contractif ordonné à la fidélité

Pour tout préordre visible :

```text
OrderContractiveProjection
→ ProjectionFiberFaithful
```

Une égalité visible permet d’obtenir les deux comparaisons par réécriture et réflexivité.

### 37.2 De la fidélité au contractif ordonné

Pour un ordre partiel :

```text
ProjectionFiberFaithful
→ OrderContractiveProjection
```

L’antisymétrie donne d’abord l’égalité visible, puis la fidélité relève cette égalité vers l’interface.

### 37.3 Équivalences

Dans un ordre partiel :

```text
OrderContractiveProjection
↔ ProjectionFiberFaithful
```

puis, par alias :

```text
OrderContractiveProjection
↔ ContractibleReferentialGap
```

et :

```text
OrderContractiveProjection
↔ ShortReferentialPresentation
```

### 37.4 Information conservée

Toujours dans un ordre partiel :

```text
ProjectionInformationConserving
→ OrderContractiveProjection
```

par passage à la fidélité de fibre.

---

## 38. Gaps vus par l’ordre

Pour un gap structurel :

```text
project gap.left = project gap.right
```

Le module en déduit, pour tout préordre :

```text
order.le (project gap.left) (project gap.right)
order.le (project gap.right) (project gap.left)
```

Donc :

```text
VisibleOrderEquivalent
  order
  (project gap.left)
  (project gap.right)
```

Dans un ordre partiel, l’antisymétrie redonne l’égalité projetée.

Cette égalité était déjà un champ du gap ; le détour par l’ordre sert à montrer que le test de comparabilité mutuelle n’apporte aucune séparation supplémentaire au niveau visible.

La séparation interne demeure :

```text
gap.left = gap.right → False
```

### 38.1 Incompatibilité avec la contraction ordonnée

Le module prouve :

```text
StructuralReferentialGap
→ OrderContractiveProjection
→ False
```

et de même pour :

```text
EnrichedStructuralReferentialLength
OperationalReferentialGap
EnrichedOperationalReferentialLength
LocallyRecoveredDynamicReturn
```

Le motif est toujours :

```text
comparabilité mutuelle visible
+
contraction ordonnée
⇒ égalité interne
⇒ contradiction avec la séparation
```

### 38.2 Ordre total

Le théorème spécifique à l’ordre total dit seulement que deux projections quelconques sont comparables dans au moins une direction :

```text
le (project left) (project right)
∨
le (project right) (project left)
```

La contraction du gap demande les deux directions, pas seulement la totalité.

---

## 39. Retours dynamiques vus par l’ordre

Puisqu’un retour dynamique localement récupéré expose un gap opérationnel, il hérite de tous les résultats ordonnés :

```text
le (project formed) (project shadow)
le (project shadow) (project formed)
```

et donc :

```text
VisibleOrderEquivalent order
  (project formed)
  (project shadow)
```

Dans un ordre partiel :

```text
project formed = project shadow
```

mais toujours :

```text
formed = shadow → False
```

Enfin :

```text
LocallyRecoveredDynamicReturn
→ OrderContractiveProjection
→ False
```

Le module d’ordre ne modifie pas le retour dynamique ; il teste la compatibilité de sa projection avec une hypothèse de contraction visible.

---

# Partie VI — Régime d’usage totalement relaxé

## 40. Branche autonome

`RelaxedUsageRegime.lean` vit dans :

```text
Meta.RelaxedUsageRegime
```

et ne dépend pas du vocabulaire :

```text
project
ProjectedIdentity
ProjectionObstruction
RepairOf
```

Il formalise un régime plus général où le transport est une opération primitive autorisée par le contexte.

---

## 41. Structure du régime relaxé

Pour :

```text
X : Typeᵤ
```

un régime porte :

```text
Ctx : Typeᶜ
defaultCtx : Ctx

Read : Ctx → Typeʳ
defaultRead :
  ∀ γ : Ctx,
    Read γ

Out :
  ∀ γ : Ctx,
  ∀ ρ : Read γ,
    Typeᵒ

read :
  ∀ γ : Ctx,
  ∀ ρ : Read γ,
    X → Out γ ρ
```

puis quatre familles :

```text
Sep   : Ctx → X → X → Typeˢ
Coord : Ctx → X → X → Typeᵏ
Use   : Ctx → X → X → Typeˡ

OutRel :
  ∀ γ : Ctx,
  ∀ ρ : Read γ,
    Out γ ρ → Out γ ρ → Typeᵐ
```

Ces familles sont à valeurs dans `Type`, pas nécessairement dans `Prop`.

Elles peuvent donc porter des données calculatoires ou plusieurs témoins distincts.

---

## 42. Deux opérations internes

Le régime fournit :

```text
use_of_noncontractive :
  Sep γ x y →
  Coord γ x y →
  Use γ x y
```

et :

```text
transport :
  Use γ x y →
  ∀ ρ : Read γ,
    OutRel γ ρ
      (read γ ρ x)
      (read γ ρ y)
```

La chaîne fondamentale est donc :

```text
Sep + Coord
→ Use
→ relation entre les sorties lues
```

Aucune égalité, projection ou substitution globale n’est présupposée.

---

## 43. Usage non contractif

La structure :

```text
NonContractiveUse I γ x y :=
  separation : I.Sep γ x y
  coordination : I.Coord γ x y
```

ne définit pas le non-contractif par :

```text
x ≠ y
```

Il est défini intrinsèquement par les deux témoins du régime.

À partir de ce paquet, le module construit :

```text
NonContractiveUse.use
```

puis, pour toute lecture autorisée :

```text
NonContractiveUse.transport
```

et pour la lecture par défaut du contexte :

```text
NonContractiveUse.defaultTransport
```

Il expose aussi séparément les témoins de séparation et de coordination.

---

## 44. Chaîne locale de transport

La structure :

```text
LocalTransportChain I γ x y ρ
```

porte :

```text
nonContractive : NonContractiveUse I γ x y

use : I.Use γ x y

use_eq :
  use = NonContractiveUse.use nonContractive

transported :
  I.OutRel γ ρ
    (I.read γ ρ x)
    (I.read γ ρ y)
```

Le constructeur canonique :

```text
localTransportChain
```

prend un `NonContractiveUse` et une lecture `ρ`, puis choisit :

```text
use := NonContractiveUse.use h
transported := NonContractiveUse.transport h ρ
```

Le champ :

```text
use_eq
```

relie explicitement `use` à l’usage construit depuis les témoins de séparation et de coordination.

En revanche, une valeur arbitraire de `LocalTransportChain` ne porte pas une égalité supplémentaire disant :

```text
transported = I.transport use ρ
```

Une telle égalité ne serait d’ailleurs pas toujours le bon niveau de formulation, puisque `transported` et `I.transport use ρ` sont des témoins d’un type `OutRel`, potentiellement non propositionnel. Le constructeur canonique choisit bien le témoin produit par `I.transport` ; la structure générale exige seulement un témoin de la relation de sortie attendue.

La chaîne par défaut choisit :

```text
ρ := I.defaultRead γ
```

mais exige toujours un argument :

```text
h : NonContractiveUse I γ x y
```

---

## 45. Non-vacuité exacte

Les champs :

```text
defaultCtx : Ctx
defaultRead : ∀ γ, Read γ
```

assurent :

```text
Ctx est habité
chaque Read γ est habité
```

Ils n’assurent pas :

```text
X est habité
Sep γ x y est habité
Coord γ x y est habité
Use γ x y est habité
NonContractiveUse I γ x y existe
```

Ils garantissent donc la disponibilité d’un contexte et d’une lecture dès que des objets et un usage non contractif sont fournis.

Ils ne construisent pas à eux seuls une chaîne concrète sans argument `h`.

La formulation exacte est :

```text
le niveau contexte/lecture est non vide
le niveau usage reste conditionnel aux témoins du régime
```

---

# Partie VII — Lecture unifiée du cadre

## 46. Trois mécanismes fondamentaux

Le noyau rassemble trois mécanismes qui ne doivent pas être confondus.

### 46.1 Fermeture interne

```text
Complete
↔
Intersection
```

sous les lois de cohérence d’aller-retour.

### 46.2 Non-contractibilité projective

```text
left = right → False
project left = project right
```

avec obstruction à tout inverse global.

### 46.3 Transport d’usage

Soit par congruence d’une égalité projetée :

```text
project left = project right
⇒ read (project left) = read (project right)
```

soit, dans le régime totalement relaxé, par une opération primitive :

```text
Sep + Coord
⇒ Use
⇒ OutRel
```

Le retour dynamique raccorde le premier mécanisme au second par une interface réalisée et localement récupérée.

Le porteur de rôles répète ensuite le motif projectif sur un second référentiel.

---

## 47. Diagramme conceptuel principal

```text
intersection dynamique typée
          |
          v
cycle terminal fort
          |
          v
interface formée avec témoin
          |
          |  localRecovery_sameInterface
          v
récupération projective locale
          |
          +----------------------------+
          |                            |
          v                            v
gap opérationnel                 deux-pôles dynamique
          |                            |
          v                            v
obstruction globale              lecture de rôles
          |                            |
          v                            v
pas d’inverse Visible→Interface   même rôle visible
                                  rôles séparés
                                  réparations locales
                                  pas d’inverse RoleVisible→Role
```

En parallèle :

```text
égalité projetée
      |
      v
identité d’usage
      |
      v
transport de toute lecture visible autorisée
```

et, dans la branche relaxée :

```text
séparation interne au régime
+
coordination interne au régime
      |
      v
usage autorisé
      |
      v
relation transportée entre sorties
```

---

## 48. Ce que le noyau établit positivement

Les fichiers relus établissent les formes suivantes.

### 48.1 Séparation sans distinction visible

```text
project left = project right
```

peut coexister avec :

```text
left = right → False
```

### 48.2 Transport sans fusion interne

L’égalité projetée peut être utilisée pour transporter toute lecture visible appropriée, sans produire :

```text
left = right
```

### 48.3 Obstruction globale

Une paire séparée dans une même fibre interdit une reconstruction uniforme depuis le visible.

### 48.4 Réparation locale

Un pôle formé peut porter :

```text
RepairOf formed
```

et une récupération certifiée de ce pôle, même si aucune reconstruction globale n’existe.

### 48.5 Raccord dynamique

L’interface réalisée par le cycle issu de l’intersection est identifiée au pôle formé de la récupération locale.

### 48.6 Répétition du motif au niveau des rôles

Un retour dynamique peut être lu dans un deux-pôles de rôles :

```text
même rôle visible
rôles séparés
réparation dynamique
réparation de rôle
obstruction à la reconstruction de rôle
```

### 48.7 Test ordonné

Toute hypothèse qui contracte la comparabilité mutuelle visible en égalité interne est incompatible avec un gap.

### 48.8 Usage totalement relaxé

Le transport peut être abstrait de l’égalité et reposer sur des témoins propres au régime :

```text
Sep
Coord
Use
OutRel
```

---

## 49. Ce que le noyau ne prétend pas établir

### 49.1 Pas de non-injectivité universelle

Il ne dit pas que toute projection est non fidèle.

Il distingue :

```text
projections fidèles
projections portant une obstruction
```

### 49.2 Pas de quotient

Il ne construit pas un type quotient où les pôles de même projection seraient fusionnés.

### 49.3 Pas d’égalité interne issue du transport

Le transport de lecture ne permet pas de conclure :

```text
left = right
```

### 49.4 Pas de construction de l’intersection depuis les deux directions

Le socle fourni expose :

```text
Complete → Forward
Complete → Backward
Complete → Intersection
```

mais pas :

```text
Forward → Backward → Intersection
```

### 49.5 Pas de causalité générique de la réparation

Dans le gap générique, `repair` et `recovered` sont deux champs compatibles avec le pôle formé, mais aucune opération générale n’impose que le premier calcule le second.

### 49.6 Pas de rôle ou de parité automatique

Un `DynamicRoleCarrier` est une donnée supplémentaire.

Tout retour dynamique n’en possède pas automatiquement un.

### 49.7 Pas de temporalité ordonnée automatique

`TemporalExcessDynamicReturn` porte une factorisation par égalité, sans ordre ni loi dynamique supplémentaire sur `Time`.

### 49.8 Pas de témoin de sortie dépendamment transporté dans la relaxation

`witnessOut` reste de type :

```text
WitnessOf sourceCell
```

Il n’est pas indexé par la cellule de sortie.

### 49.9 Pas d’usage non contractif globalement habité

Le régime relaxé garantit un contexte et des lectures par défaut, mais un `NonContractiveUse` concret reste une donnée à fournir.

---

## 50. Nature des preuves

Dans les fichiers de `Meta/Core`, les constructions visibles utilisent principalement :

```text
projection de champs
construction de structures
rfl
Iff.rfl
congrArg
réécriture par égalité
composition de fonctions
application d’une séparation à une égalité
```

Les preuves négatives ont la forme constructive :

```text
hypothèse contractive
⇒ égalité interne
⇒ False
```

Les preuves positives ont souvent la forme :

```text
réemballage d’un paquet existant
projection vers une façade plus faible
transport par congruence
```

Une partie importante de l’architecture consiste donc à rendre explicites et réutilisables des données déjà présentes, plutôt qu’à ajouter des axiomes de fermeture.

---

## 51. Statut de l’audit axiomatique dans le checkout actuel

Les douze fichiers Lean de `Meta/Core` se terminent par des commandes telles que :

```text
#print axioms ...
```

Une inspection textuelle des fichiers de `Meta/Core` ne montre pas d’usage explicite de :

```text
Classical
propext
Quot.sound
sorry
admit
axiom
noncomputable
```

Dans ce checkout, les sources du socle `ClosedStabilityTheorem` et `TwoPole` sont présentes. Il n’est donc pas nécessaire de les reconstruire indirectement depuis leurs usages.

### 51.1 Commandes d’audit et sorties

Les fichiers contiennent les commandes d’audit. Leur résultat est obtenu en exécutant Lean, par exemple :

```text
lake env lean Meta/Core/ClosedStabilityTheorem.lean
```

La conclusion vérifiable pour le checkout actuel est :

```text
les sources de Meta/Core sont présentes ;
chaque fichier porte un bloc AXIOM_AUDIT final ;
la certification sans axiome exige l’exécution de ces audits par Lean.
```

### 51.2 Portée de la certification

Ce document Markdown n’est pas lui-même une preuve Lean. La certification constructive appartient aux fichiers `.lean` et à leurs sorties `#print axioms`.

Il serait donc excessif d’utiliser ce document seul comme certificat. Dans le checkout actuel, en revanche, les modules de base mentionnés sont bien inspectables directement.

---

## 52. Conclusion mathématique

Le noyau formalise une théorie constructive de la coordination non contractive.

Sa forme minimale est :

```text
pôles internes séparés
∧
même projection visible
∧
transport possible au niveau d’usage
∧
obstruction à la reconstruction globale
```

Sa forme opérationnelle ajoute :

```text
réparation locale indexée par le pôle formé
∧
récupération certifiée de ce pôle
```

Sa forme dynamique ajoute :

```text
intersection source
→ cycle terminal fort
→ interface réalisée
→ même interface localement récupérée
```

Sa forme médiée ajoute un second référentiel :

```text
interfaces dynamiques
→ rôles séparés
→ même visible de rôle
→ réparation de rôle
→ obstruction à la reconstruction des rôles
```

Enfin, sa forme totalement relaxée abstrait même l’égalité projetée :

```text
séparation propre au régime
+
coordination propre au régime
→ usage
→ transport
```

La conclusion centrale peut être formulée ainsi :

```text
une interface peut coordonner des pôles pour un usage commun
sans les identifier intérieurement,
sans les quotienter,
et sans rendre leur structure reconstructible depuis le visible seul
```

Cette distinction entre :

```text
identité interne
identité projetée
identité d’usage
transport
réparation locale
reconstruction globale
```

est le principe organisateur de l’ensemble du cadre.
