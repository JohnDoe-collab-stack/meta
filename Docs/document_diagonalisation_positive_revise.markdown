# Meta/Core — diagonalisation positive, fermeture formée et usage non contractif

Ce document donne une lecture mathématique structurée du noyau `Meta/Core` à partir des fichiers Lean fournis.

La thèse organisatrice est la suivante :

```text
la diagonalisation n’est pas d’abord une procédure négative
qui se termine dans une obstruction ;

elle est une formation positive :
deux pôles internes séparés sont coordonnés par une même projection,
et cette configuration porte un témoin dépendant positif,
un usage transportable, une réparation locale ou une vérité formée.
```

L’obstruction à la reconstruction globale est réelle, mais elle est une conséquence de cette formation. Elle n’en constitue ni la définition ni le sommet.

Les formules sont écrites en Unicode ordinaire. Les dépendances de types sont conservées explicitement.

---

## 0. Portée et conventions

### 0.1 Fichiers relus

Cette version s’appuie directement sur les modules fournis suivants :

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
OrderGap.lean
RelaxedUsageRegime.lean
```

Le fichier `ClosedStabilityTheorem.lean` est le socle autonome. Il contient notamment les cycles terminaux, les paquets de stabilité, les certificats diagonaux, les récupérations locales et la séparation entre formation géométrique et vérité projetée.

### 0.2 Types dépendants

Une famille :

```text
RepairOf : Interface → Type
```

ne fournit pas un type de réparation indépendant de l’interface. Pour chaque interface exacte `i`, elle fournit :

```text
RepairOf i
```

De même :

```text
WitnessOf :
  ProjectedIdentityCell Interface Visible project → Type
```

indexe un témoin par la cellule diagonale entière, et non seulement par son pôle formé.

### 0.3 Négation constructive

Une séparation :

```text
left = right → False
```

est une fonction qui transforme une preuve d’égalité en contradiction. Elle n’utilise pas le tiers exclu.

### 0.4 `Type` et `Prop`

Les champs à valeurs dans `Type` peuvent porter des données et plusieurs témoins distincts. Les champs à valeurs dans `Prop` expriment des propositions.

Le noyau emploie volontairement les deux niveaux. Par exemple :

```text
WitnessOf cell : Type
Positive cell witness : Prop
```

Le témoin est une donnée ; sa positivité est une proposition portant sur cette donnée.

---

# Partie I — La diagonalisation positive

## 1. Support diagonal non contractif

Le support élémentaire est :

```text
ProjectedIdentityCell Interface Visible project :=
  formed : Interface
  shadow : Interface
  sameVisible :
    project formed = project shadow
  separated :
    formed = shadow → False
```

Cette cellule porte positivement :

```text
un pôle formé
un pôle ombre
leur coïncidence visible
leur séparation interne
```

Elle n’affirme pas :

```text
formed = shadow
```

Elle affirme exactement :

```text
project formed = project shadow
```

tout en conservant la réfutation constructive de leur égalité interne.

Le mot « diagonale » désigne ici cette configuration :

```text
les deux pôles coïncident dans le référentiel projeté
sans être contractés dans le référentiel interne.
```

## 2. La forme positive complète

Le paquet Lean correspondant est :

```text
PositiveProjectedInvariant
```

avec :

```text
cell :
  ProjectedIdentityCell Interface Visible project

witness :
  WitnessOf cell

witness_pos :
  Positive cell witness
```

La lecture correcte est indivisible :

```text
cellule diagonale
+
témoin dépendant de cette cellule exacte
+
preuve positive portant sur ce témoin
```

Il ne faut pas reconstruire artificiellement une hiérarchie dans laquelle la cellule serait d’abord une obstruction et le témoin une couche ajoutée ensuite.

L’objet positif est le paquet entier. Le type :

```text
WitnessOf cell
```

peut dépendre conjointement de tout ce que contient `cell` :

```text
cell.formed
cell.shadow
cell.sameVisible
cell.separated
```

La diagonalisation peut donc porter une information qui n’est réductible ni au visible seul, ni à un pôle détaché de sa relation à l’autre.

Une version analogue existe au niveau d’une lecture :

```text
PositiveReadInvariant
```

Son témoin dépend d’une `ReadIdentityCell`, c’est-à-dire de la diagonalisation après composition avec une lecture.

## 3. Certificat diagonal et obstruction : vues par oubli

Le socle définit aussi :

```text
DiagonalCertificate Interface Visible project :=
  left
  right
  sameProjection
  separatedInterface
```

et :

```text
ProjectionObstruction Interface Visible project
```

avec les mêmes données structurelles.

Ces paquets ne doivent pas être lus comme des niveaux supérieurs à la diagonalisation positive. Ils sont des **vues par oubli** :

```text
diagonalisation positive
  ── oubli du témoin et de sa positivité ──>
support diagonal
  ── lecture reconstructive ──>
obstruction projective
```

Dans `ProjectedIdentity.lean`, la cellule donne explicitement :

```text
diagonalCertificateOfProjectedIdentityCell :
  ProjectedIdentityCell ...
  → DiagonalCertificate ...
```

puis :

```text
projectionObstructionOfProjectedIdentityCell :
  ProjectedIdentityCell ...
  → ProjectionObstruction ...
```

Ce passage conserve les pôles, l’égalité visible et la séparation, mais oublie ce que la diagonalisation porte positivement.

## 4. Deux actions de la même diagonalisation

La même cellule agit dans deux directions.

### 4.1 Action positive d’usage

```text
sameVisible
→ identité d’usage
→ transport de lecture
```

Pour :

```text
read : Visible → Label
```

on obtient :

```text
read (project formed) = read (project shadow)
```

par congruence.

### 4.2 Limite reconstructive

```text
sameVisible
+
separated
→ aucune reconstruction uniforme Visible → Interface
```

Si une fonction :

```text
recover : Visible → Interface
```

reconstruisait toutes les interfaces, l’égalité visible des deux pôles forcerait leur égalité interne, consommée ensuite par `separated`.

La conséquence négative ne supprime pas l’action positive. Les deux proviennent de la même configuration :

```text
la projection est suffisante pour coordonner l’usage,
mais insuffisante pour reconstruire l’intériorité.
```

## 5. Identité interne, projetée et d’usage

Le module distingue :

```text
InternalIdentity project left right :=
  left = right
```

```text
ProjectedIdentity project left right :=
  project left = project right
```

```text
InterfaceIdentityOfUse project left right :=
  ProjectedIdentity project left right
```

L’identité d’usage est définitionnellement l’identité projetée :

```text
InterfaceIdentityOfUse project left right
↔
ProjectedIdentity project left right
```

par `Iff.rfl`.

Cela ne produit aucune égalité interne. Le choix formel est :

```text
utiliser l’égalité projetée comme médiateur d’action
sans la transformer en contraction des pôles.
```

## 6. Transport fixe et transport polymorphe

Pour une lecture fixe :

```text
InterfaceReadTransport project read left right :=
  read (project left) = read (project right)
```

Le transport polymorphe est :

```text
InterfaceTransport project left right :=
  (Label : Typeᵥ) →
  (read : Visible → Label) →
  InterfaceReadTransport project read left right
```

Le noyau prouve :

```text
InterfaceTransport project left right
↔
ProjectedIdentity project left right
```

La direction directe choisit :

```text
Label := Visible
read := identité
```

La direction inverse applique `congrArg` à chaque lecture.

Ainsi :

```text
le transport est l’égalité projetée considérée comme puissance d’action.
```

Il n’est pas une substitution globale dans `Interface`.

## 7. Chaîne constructive d’interface

La chaîne compacte est :

```text
ConstructiveInterfaceChain project read left right :=
  (left = right → False)
  ∧
  (
    project left = project right
    ∧
    read (project left) = read (project right)
  )
```

Elle conserve simultanément :

```text
différence interne
identité d’usage
transport de lecture
```

L’égalité visible ne remplace pas la séparation ; elle agit à côté d’elle.

---

# Partie II — Diagonalisation positive de la vérité et de la formation

## 8. Récupération locale d’un gap de vérité

Le socle définit :

```text
LocalTruthGapRecovery
  Interface
  Visible
  project
  RepairOf
  Truth
```

avec :

```text
localRecovery :
  LocalProjectiveRecovery Interface Visible project RepairOf

formed_truth :
  Truth localRecovery.formed

shadow_not_truth :
  Truth localRecovery.shadow → False
```

La configuration exacte est :

```text
Truth formed
project formed = project shadow
Truth shadow → False
formed = shadow → False
RepairOf formed
recovered = formed
```

C’est une réalisation directe de diagonalisation positive.

Le pôle formé ne porte pas seulement une différence ou une obstruction. Il porte positivement :

```text
Truth formed
```

L’ombre partage le même visible, mais ne porte pas cette vérité.

La vérité formée n’est donc pas récupérable comme simple fonction de la projection commune.

## 9. Formation géométrique

Une scène est :

```text
ReferentialScene Interface :=
  Interface → Prop
```

La formation géométrique est :

```text
GeometricFormation Truth scene :=
  ∃ interface,
    scene interface ∧ Truth interface
```

Elle affirme positivement qu’une interface vraie est formée dans la scène.

Pour le gap de vérité, la scène complète contient les deux pôles :

```text
interface = formed
∨
interface = shadow
```

Le noyau prouve la formation de cette scène en choisissant le pôle formé et le témoin :

```text
formed_truth : Truth formed
```

## 10. Vérité locale projetée

La vérité locale projetée est :

```text
ProjectedLocalTruth project Truth scene :=
  ∀ left right,
    scene left →
    scene right →
    project left = project right →
    (Truth left ↔ Truth right)
```

Elle exige que, dans la scène, l’égalité visible transporte la vérité dans les deux directions.

Sur la scène complète du gap :

```text
formed
shadow
```

cette propriété est impossible, car :

```text
project formed = project shadow
Truth formed
Truth shadow → False
```

Le noyau prouve donc :

```text
GeometricFormation Truth fullScene
```

et :

```text
ProjectedLocalTruth project Truth fullScene → False
```

La formation positive ne se réduit pas à une stabilité de vérité sous projection.

## 11. Indépendance constructive formation / vérité projetée

Le noyau construit également la scène contenant seulement l’ombre.

Sur cette scène :

```text
ProjectedLocalTruth project Truth shadowScene
```

est vraie : toute hypothèse de vérité sur l’unique pôle ombre conduit à `False`.

Mais :

```text
GeometricFormation Truth shadowScene → False
```

car l’ombre ne porte pas `Truth`.

Le théorème central est :

```text
localTruthGapRecovery_localFormation_projectedTruth_independent
```

de forme :

```text
(
  ∃ scene,
    GeometricFormation Truth scene
    ∧
    (ProjectedLocalTruth project Truth scene → False)
)
∧
(
  ∃ scene,
    ProjectedLocalTruth project Truth scene
    ∧
    (GeometricFormation Truth scene → False)
)
```

Le résultat est constructif et bidirectionnel :

```text
formation géométrique
n’implique pas
vérité locale projetée
```

et :

```text
vérité locale projetée
n’implique pas
formation géométrique
```

Ce résultat ne provient pas d’une diagonalisation qui ne ferait que produire une impossibilité. Il provient d’une diagonale positivement formée :

```text
le formé porte Truth ;
l’ombre de même visible ne la porte pas.
```

La négation de la vérité projetée est une conséquence de cette asymétrie positive.

## 12. Fermeture référentielle formée

Une autre forme positive est :

```text
FormedReferentialClosure
```

qui porte :

```text
formedInterface : Interface
shadowInterface : Interface

sameProjection :
  project formedInterface = project shadowInterface

separatedInterface :
  formedInterface = shadowInterface → False

repair :
  RepairOf formedInterface

recoveredInterface : Interface

recovered_eq_formed :
  recoveredInterface = formedInterface

outcome :
  OutcomeOf formedInterface
```

Le paquet contient à la fois :

```text
la diagonale
la réparation locale
la récupération du formé
l’issue dépendante du formé
```

Le noyau extrait positivement :

```text
outcomeWitnessOfFormedReferentialClosure :
  InterfaceWitness Interface OutcomeOf
```

et, par oubli :

```text
diagonalCertificate
projectionObstruction
localProjectiveRecovery
```

L’ordre conceptuel est important :

```text
la fermeture formée porte une issue et une réparation ;
son obstruction projective est une projection de ce paquet plus riche.
```

---

# Partie III — Fermeture interne et formation d’interface

## 13. Complétude bidirectionnelle

La structure fondamentale est :

```text
BidirectionalCompleteness Branch
```

avec :

```text
Complete     : Branch → Type
Forward      : Branch → Type
Backward     : Branch → Type
Intersection : Branch → Type
```

et :

```text
Complete b → Forward b
Complete b → Backward b
Complete b → Intersection b
Intersection b → Complete b
```

La recomposition :

```text
completeOfIntersection :
  Intersection b → Complete b
```

est interne au cadre.

Le noyau ne fournit pas une opération :

```text
Forward b → Backward b → Intersection b
```

`Forward`, `Backward` et `Intersection` sont lus depuis `Complete`. Leur interaction formelle passe par cette donnée complète.

## 14. Cycles terminaux

Un cycle brut porte :

```text
completeIn
forward
backward
intersection
recomposed
```

Un cycle cohérent ajoute les égalités certifiant que chacun de ces champs est bien relu depuis `completeIn`.

La cohérence du paquet ne donne pas encore :

```text
recomposed = completeIn
```

Cette stabilité demande la cohérence d’aller-retour.

## 15. Aller-retour interne

Deux structures sont distinguées :

```text
ReextractionCoherence
```

pour :

```text
Complete → Intersection → Complete
```

et :

```text
IntersectionRecompositionCoherence
```

pour :

```text
Intersection → Complete → Intersection
```

Le paquet :

```text
RoundTripCoherence
```

contient les deux.

À partir d’une intersection source, le noyau construit :

```text
StrongTerminalCycleFromIntersection
```

qui conserve explicitement :

```text
sourceIntersection
```

et prouve :

```text
intersectionOfComplete
  (completeOfIntersection sourceIntersection)
=
sourceIntersection
```

La fermeture terminale ne perd donc pas la provenance typée de l’intersection.

## 16. Interface formée et réalisation

Un témoin d’interface est :

```text
InterfaceWitness Interface WitnessOf :=
  interface : Interface
  witness : WitnessOf interface
```

Les paquets :

```text
WeakClosedStability
StrongClosedStability
StrongClosedStabilityFromIntersection
```

ne placent pas ce témoin à côté d’un cycle sans relation. Ils portent un champ :

```text
interface_coherent :
  RealizesInterface cycle formed.interface
```

ou sa variante forte.

La formation d’interface est ainsi liée au cycle terminal qui la réalise.

Le schéma est :

```text
intersection typée
→ cycle terminal fort
→ interface réalisée
→ témoin dépendant de cette interface
```

## 17. Stabilité commune

Le socle contient également :

```text
SelfCoupling Branch Support
```

avec :

```text
memory : Branch → Support
source : Branch → Support
Coupled : Branch → Type

coupled_conserves :
  Coupled b →
  memory b = source b
```

Si toute complétude entre dans le couplage :

```text
Complete b → Coupled b
```

alors un cycle terminal fort donne :

```text
memory b = source b
```

par le théorème :

```text
commonStabilityOfStrongTerminalCycle
```

Cette stabilité commune est une conséquence positive de la complétude recomposée portée par le cycle.

---

# Partie IV — Récupération locale et fermeture non projective

## 18. Récupération projective locale

La structure :

```text
LocalProjectiveRecovery
```

porte :

```text
formed
shadow
project formed = project shadow
formed = shadow → False
repair : RepairOf formed
recovered
recovered = formed
```

La récupération est locale parce que :

```text
repair
```

est indexée par le pôle formé exact.

Le paquet n’affirme pas l’existence d’un inverse global :

```text
Visible → Interface
```

Au contraire, sa diagonale interdit un tel inverse uniforme.

Dans la forme générique, aucune fonction n’est imposée qui calculerait `recovered` à partir de `repair`. Le code porte conjointement la réparation et sa récupération certifiée. Certaines spécialisations, comme la parité, donnent un type de réparation contenant explicitement le récupéré et sa correction.

## 19. Stabilité forte non projective

Le socle combine la fermeture terminale et l’obstruction dans :

```text
NonProjectiveStrongClosedStability
```

puis ajoute une récupération et une projection terminale dans :

```text
RecoveredNonProjectiveClosedStability
```

Il existe des variantes qui conservent l’intersection source :

```text
NonProjectiveStrongClosedStabilityFromIntersection

RecoveredNonProjectiveClosedStabilityFromIntersection

LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
```

Le dernier paquet raccorde :

```text
cycle terminal fort issu de l’intersection
interface formée et témoignée
obstruction projective
récupération locale
projection terminale
```

avec des égalités certifiant qu’il s’agit de la même interface formée.

Le théorème :

```text
locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
```

construit ce paquet sans postulat terminal supplémentaire.

## 20. Retour dynamique

Un retour dynamique formé est :

```text
FormedDynamicReturn complete branch Source :=
  source : Source
  intersection : complete.Intersection branch
```

Un retour localement récupéré ajoute :

```text
formed :
  InterfaceWitness Interface WitnessOf

realizes :
  RealizesInterface
    (strongTerminalCycleFromIntersection ...)
    formed.interface

localRecovery :
  LocalProjectiveRecovery ...

localRecovery_sameInterface :
  localRecovery.formed = formed.interface
```

Le champ décisif est :

```text
localRecovery.formed = formed.interface
```

Il raccorde exactement :

```text
l’interface formée par le cycle
```

et :

```text
le pôle positivement réparé.
```

Le retour dynamique n’ajoute pas une stabilité extérieure. Il fournit les données nécessaires au théorème de fermeture localement récupérée.

## 21. Provenance temporelle

La structure :

```text
TemporalExcessDynamicReturn
```

porte :

```text
terminalTimeOf : Source → Time
formedExcessOf : Intersection branch → Excess
advance : Time → Excess
```

avec :

```text
formedExcessOf dynamicReturn.intersection
=
advance (terminalTimeOf dynamicReturn.source)
```

Elle formalise une factorisation de provenance pour le retour fixé.

Elle ne postule ni ordre sur `Time`, ni monotonie, ni dynamique itérée.

---

# Partie V — Gap, longueur et deux pôles

## 22. Les trois lectures du gap

Le vocabulaire est :

```text
ContractibleReferentialGap :=
  ProjectionFiberFaithful
```

```text
StructuralReferentialGap :=
  ProjectionObstruction
```

```text
OperationalReferentialGap :=
  LocalProjectiveRecovery
```

La lecture courte exige :

```text
project left = project right
→
left = right
```

La lecture structurelle expose une diagonale séparée.

La lecture opérationnelle conserve en plus :

```text
RepairOf formed
recovered = formed
```

Le passage :

```text
OperationalReferentialGap
→ StructuralReferentialGap
```

est un oubli de données positives.

## 23. Longueur référentielle

Les alias sont :

```text
ShortReferentialPresentation :=
  ContractibleReferentialGap
```

```text
EnrichedStructuralReferentialLength :=
  StructuralReferentialGap
```

```text
EnrichedOperationalReferentialLength :=
  OperationalReferentialGap
```

La longueur n’est pas un nombre artificiel. Elle distingue :

```text
visible suffisant pour reconstruire
```

de :

```text
visible commun à des pôles séparés
```

et de :

```text
pôle formé enrichi d’une récupération locale.
```

Les longueurs enrichies réfutent la présentation courte.

## 24. Lecture positive en deux pôles

`TwoPole.lean` indique explicitement qu’il donne une **lecture positive en deux pôles** du vocabulaire de gap.

```text
StructuralTwoPole :=
  StructuralReferentialGap

OperationalTwoPole :=
  OperationalReferentialGap
```

Cette façade expose :

```text
leftPole
rightPole
sameVisible
separatedPoles
repair du pôle formé
recovered = pôle formé
```

Elle n’ajoute pas de nouvelles données d’obstruction. Elle rend lisible la configuration positive déjà portée :

```text
deux pôles
une coordination visible
une séparation interne
une récupération locale du formé.
```

L’impossibilité de reconstruction globale est une conséquence de cette lecture.

## 25. Parité minimale

La spécialisation minimale prend :

```text
ParityRegime :=
  left | right

ParityVisible :=
  contracted
```

avec projection constante :

```text
parityProjection left
=
parityProjection right
=
contracted
```

et séparation des constructeurs.

La réparation :

```text
ParityRegimeRepair regime
```

porte :

```text
visible
recovered
visible = parityProjection regime
recovered = regime
```

Les réalisations gauche-droite et droite-gauche fournissent deux orientations du même motif.

La parité n’est pas arithmétique. Elle montre que la diagonalisation positive et la récupération locale possèdent un modèle fini minimal.

---

# Partie VI — Médiations dynamiques

## 26. Retour dynamique comme deux-pôles

`DynamicTwoPole.lean` expose :

```text
dynamicReturn_operationalGap
```

comme la récupération locale déjà portée par le retour dynamique, puis :

```text
dynamicReturn_operationalTwoPole
```

comme sa lecture positive en deux pôles.

La dynamique ne crée pas après coup une obstruction. Elle forme une interface, lui raccorde une récupération locale, puis expose la diagonalisation que ce paquet contient.

## 27. Porteur dynamique de rôles

Un :

```text
DynamicRoleCarrier
```

ajoute un second référentiel :

```text
Role
RoleVisible
roleProject
RoleRepairOf
```

avec :

```text
roleOf : Interface → Role
visibleRoleOf : Visible → RoleVisible

roleTwoPole :
  OperationalTwoPole Role RoleVisible roleProject RoleRepairOf
```

Les compatibilités relient les pôles dynamiques aux pôles de rôle.

Le module dérive :

```text
formedVisibleRole = shadowVisibleRole
```

et :

```text
formedRole = shadowRole → False
```

ainsi que :

```text
réparation du pôle dynamique formé
réparation du rôle formé
impossibilité de reconstruction RoleVisible → Role
```

Le même motif est donc médié sans perdre sa positivité :

```text
interface formée
→ rôle formé
→ réparation au niveau du rôle
```

## 28. Rôles médiés

Le paquet :

```text
MediatedDynamicRoles
```

nomme :

```text
closingRole
mediatingRole
```

et conserve :

```text
closingRole = formedRole
mediatingRole = shadowRole
même visible de rôle
séparation des rôles
deux réparations
non-reconstruction globale des rôles
```

Ce paquet n’introduit pas une nouvelle couche mathématique ; il donne une lecture nommée des données déjà produites par le porteur.

---

# Partie VII — Test de contraction par l’ordre visible

## 29. Ordre visible

Le noyau définit :

```text
VisiblePreorder
VisiblePartialOrder
VisibleTotalOrder
```

et :

```text
VisibleOrderEquivalent order a b :=
  order.le a b ∧ order.le b a
```

Une projection est contractive pour l’ordre si :

```text
OrderContractiveProjection :=
  ∀ left right,
    le (project left) (project right) →
    le (project right) (project left) →
    left = right
```

## 30. Équivalence avec la présentation courte

Pour tout préordre :

```text
OrderContractiveProjection
→ ProjectionFiberFaithful
```

Pour un ordre partiel :

```text
ProjectionFiberFaithful
→ OrderContractiveProjection
```

Donc :

```text
OrderContractiveProjection
↔ ProjectionFiberFaithful
↔ ShortReferentialPresentation
```

Le test ordonné mesure exactement une tentative de contraction de la diagonale visible vers l’égalité interne.

## 31. Réfutation par la diagonalisation

Une diagonale structurelle ou opérationnelle donne les deux comparaisons visibles par réécriture et réflexivité.

Si la projection était contractive pour l’ordre, ces comparaisons produiraient :

```text
left = right
```

en contradiction avec la séparation.

Les gaps, les deux-pôles et les retours dynamiques réfutent donc tous une lecture ordonnée contractive.

L’ordre n’est pas un second fondement du cadre. Il est un test externe précis de la non-contractibilité déjà portée par la diagonalisation.

---

# Partie VIII — Conservation sous relaxation

## 32. Relaxation de projection contrainte

La structure :

```text
ConstrainedProjectionRelaxation
```

garde les mêmes pôles internes sous deux projections :

```text
projectIn  : Interface → VisibleIn
projectOut : Interface → VisibleOut
```

avec deux lectures :

```text
readIn
readOut
```

Elle porte :

```text
sourceCell :
  ProjectedIdentityCell Interface VisibleIn projectIn

sameOut :
  projectOut sourceCell.formed =
  projectOut sourceCell.shadow
```

La diagonale demeure donc disponible dans les deux régimes visibles.

## 33. Invariant positif conservé

Le paquet contient :

```text
invariant :
  WitnessOf sourceCell

invariant_pos :
  Positive sourceCell invariant

witnessIn :
  WitnessOf sourceCell

witnessOut :
  WitnessOf sourceCell

witnessIn = invariant
witnessOut = invariant
```

La conservation est littérale :

```text
le même témoin dépendant de la même cellule source
est nommé à l’entrée et à la sortie.
```

Ce n’est pas un oubli du témoin au profit d’une simple obstruction. La relaxation transporte simultanément :

```text
les pôles
leur séparation
leur égalité dans chaque projection
les chaînes de transport
l’invariant positif.
```

Le type exact de `witnessOut` reste `WitnessOf sourceCell`. Le noyau exprime ainsi la conservation du même invariant, et non la construction d’un nouveau témoin indexé par une cellule de sortie distincte.

## 34. Changement visible

Le champ :

```text
visibleShift :
  readIn (projectIn formed)
  =
  readOut (projectOut formed)
  → False
```

certifie que le changement de régime visible n’est pas une identité de lecture sur le pôle formé.

Le cadre conserve donc l’invariant à travers un changement visible réel, sans contracter les deux pôles internes.

---

# Partie IX — Usage totalement relaxé

## 35. Régime autonome

`RelaxedUsageRegime.lean` abstrait le mécanisme d’usage sans partir d’une projection ou d’une égalité.

Un régime porte :

```text
Ctx
Read
Out
read
Sep
Coord
Use
OutRel
```

avec :

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
  ∀ ρ,
    OutRel γ ρ
      (read γ ρ x)
      (read γ ρ y)
```

## 36. Usage non contractif

Un :

```text
NonContractiveUse I γ x y
```

porte :

```text
separation : I.Sep γ x y
coordination : I.Coord γ x y
```

La chaîne est :

```text
Sep
+
Coord
→ Use
→ transport
```

Le non-contractif n’est pas réduit à :

```text
x ≠ y
```

Il est défini par les données positives internes au régime.

Cette branche généralise le principe du noyau :

```text
la séparation n’empêche pas la coordination ;
la coordination autorise un usage ;
l’usage produit un transport.
```

## 37. Chaîne locale

```text
LocalTransportChain
```

porte :

```text
nonContractive
use
use = useOfNonContractive nonContractive
transported
```

Le constructeur canonique conserve explicitement la provenance de l’usage depuis les témoins de séparation et de coordination.

Les champs :

```text
defaultCtx
defaultRead
```

garantissent l’habitation du niveau contexte/lecture. Ils ne produisent pas à eux seuls un `NonContractiveUse`.

---

# Partie X — Lecture unifiée

## 38. Forme centrale

Le motif complet est :

```text
pôle formé
+
pôle ombre
+
séparation interne
+
égalité projetée
+
témoin positif dépendant
+
action d’usage
+
récupération locale du formé
```

Les conséquences reconstructives sont ensuite :

```text
pas de fidélité globale de la fibre
pas d’inverse uniforme depuis le visible
pas de contraction ordonnée.
```

La conséquence négative ne définit pas la diagonalisation positive. Elle montre seulement que son contenu ne peut pas être absorbé par le visible.

## 39. Diagramme principal

```text
intersection typée
        |
        v
cycle terminal fort
        |
        v
interface formée ─────── witness : WitnessOf interface
        |
        | même interface
        v
pôle formé de la récupération locale
        |
        +---------------------------+
        |                           |
        v                           v
pôle ombre de même visible      repair : RepairOf formed
        |                           |
        v                           v
séparation interne              recovered = formed
        |
        +---------------------------+
        |
        v
diagonalisation positive
        |
        +-------------+----------------+----------------+
        |             |                |                |
        v             v                v                v
identité d’usage   transport       Truth formed     invariant positif
        |                              |
        v                              v
lectures communes          Truth shadow impossible
        |
        v
coordination sans contraction

Après oubli du contenu positif :

diagonale séparée
        |
        v
obstruction projective
        |
        v
pas de reconstruction globale
```

## 40. Résultat métamathématique interne le plus net

Le résultat le plus directement métamathématique du socle est la séparation constructive entre :

```text
formation géométrique
```

et :

```text
vérité locale projetée.
```

À partir d’un `LocalTruthGapRecovery`, le noyau construit :

```text
une scène formée où la vérité projetée échoue
```

et :

```text
une scène projectivement stable où aucune formation vraie n’existe.
```

Cette indépendance est rendue possible par la diagonalisation positive :

```text
le pôle formé porte la vérité ;
l’ombre de même projection ne la porte pas.
```

Le visible ne décide donc ni la formation ni la vérité interne du pôle formé.

## 41. Ce que le cadre établit

Il établit constructivement que :

```text
1. une diagonale projetée peut rester intérieurement séparée ;

2. cette diagonale peut être habitée par un témoin positif dépendant ;

3. le témoin, la vérité, l’issue ou la réparation peuvent être attachés
   au pôle formé ou à la cellule entière ;

4. l’égalité projetée agit comme identité d’usage et transporte les lectures ;

5. cette action ne produit aucune identité interne ;

6. une récupération locale peut coexister avec l’impossibilité
   d’une reconstruction globale ;

7. la formation géométrique et la vérité locale projetée
   sont constructivement indépendantes ;

8. le même motif se conserve dans les retours dynamiques,
   les rôles, la parité, l’ordre visible et les relaxations.
```

## 42. Ce que le cadre ne confond pas

Il maintient les distinctions suivantes :

```text
identité interne
≠
identité projetée
```

```text
identité projetée
=
identité d’usage
```

```text
usage commun
≠
fusion des pôles
```

```text
réparation locale
≠
inverse global
```

```text
formation positive
≠
vérité déterminée par la projection
```

```text
certificat d’obstruction
≠
contenu positif complet de la diagonale
```

## 43. Portée exacte de certaines données

Le noyau ne postule pas :

```text
Forward → Backward → Intersection
```

Il ne postule pas non plus une causalité générique :

```text
repair ↦ recovered
```

dans toutes les familles `RepairOf`.

Un rôle dynamique, une lecture de parité ou un invariant particulier sont des données positives à fournir dans leurs structures respectives.

Ces précisions ne diminuent pas le cadre. Elles indiquent exactement où se trouve son contenu :

```text
dans les paquets dépendants effectivement portés,
et non dans des principes externes ajoutés après coup.
```

---

# Partie XI — Discipline constructive et audit

## 44. Forme des preuves

Les preuves relues utilisent principalement :

```text
construction et projection de structures
rfl
Iff.rfl
congrArg
réécriture par égalité
composition de fonctions
consommation constructive d’une séparation
```

Le théorème d’indépendance formation / vérité projetée utilise seulement :

```text
témoins existentiels explicites
réécriture
application de formed_truth
application de shadow_not_truth
```

## 45. Audit textuel et audit Lean

Les fichiers contiennent des blocs :

```text
#print axioms ...
```

Une inspection textuelle des sources fournies ne montre pas d’usage explicite de :

```text
Classical
propext
Quot.sound
sorry
admit
axiom
noncomputable
```

La certification définitive appartient toutefois à l’exécution de Lean et aux sorties de `#print axioms`.

Le Markdown décrit les constructions ; il ne remplace pas leur vérification par le noyau Lean.

---

# Conclusion

Le noyau `Meta/Core` ne formalise pas principalement une théorie de l’échec de reconstruction.

Il formalise une **diagonalisation positive non contractive** :

```text
deux pôles restent séparés,
coïncident dans un visible commun,
et la configuration porte un contenu positif
qui peut être formé, témoigné, réparé, transporté et conservé.
```

L’obstruction globale apparaît parce que ce contenu positif ne peut pas être réduit au visible seul.

La forme la plus forte du principe est :

```text
le visible coordonne les pôles
sans contenir leur intériorité ;

la diagonalisation porte positivement cette intériorité
sans abolir leur usage commun.
```

Le théorème de séparation entre formation géométrique et vérité locale projetée en donne une expression métamathématique directe :

```text
ce qui est positivement formé
n’est pas déterminé par la seule stabilité de sa projection,
et la stabilité projetée ne suffit pas à produire une formation.
```
