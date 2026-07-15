# `Meta/Core` — audit de clôture de la réorganisation

## 0. Statut

La réorganisation principale de `Meta/Core` est achevée. Elle n'est toutefois
qu'un préalable logiciel à l'objectif fondationnel.

Ce document décrit l'architecture présente, les propriétés effectivement
compilées et la synthèse mathématique qui raccorde désormais les racines. Il
ne confond pas la clôture du refactoring avec les spécialisations futures.

Validation de clôture effectuée le 15 juillet 2026 :

```text
12 élaborations unitaires du Core cible réussies
lake build réussi : 1230 tâches
aucun nom public historique perdu
aucun import Lean aval vers une façade historique
aucun axiome dans les nouveaux modules du Core
```

## Principe fondationnel

Le centre du travail n'est ni une projection particulière, ni un gap
particulier, ni le graphe d'import.

Le principe est :

> L'identité reste le principe strict d'individuation, mais elle cesse d'être
> l'unique fondement possible de la substitution et du transport.

Le régime classique concentre les pouvoirs logiques dans l'identité :

```text
x = y
→ substitution globale admissible
```

Le régime relaxé les distribue entre des données distinctes :

```text
Sep γ x y
+
Coord γ x y
→
Use γ x y
→
transport dans les lectures autorisées par γ
```

Ainsi :

```text
identité     : coïncidence interne
séparation   : individuation conservée
coordination : unité sans contraction
usage        : droit local de transport
contexte     : portée de ce droit
dynamique    : variation régulée de ce droit
```

Le cas projectif :

```text
x ≠ y
project x = project y
```

n'est qu'une réalisation minimale de ce principe. La rupture véritable est
l'existence d'un transport cohérent, composable et opératoire qui n'est pas
engendré par une identité.

Le théorème de rupture déjà compilé est :

```text
InternalIdentityTransport
⊆
ProjectedIdentityTransport
⊊
RelaxedUsageTransport
```

La seconde inclusion est stricte parce que le transport directionnel :

```text
before → after
```

n'admet aucun transport inverse. Il ne peut donc être exactement représenté
par une égalité interne ou projetée, qui imposerait la symétrie.

## 1. Architecture effective

```text
RelaxedUsageRegime
  → usages preuve-pertinents
  → séparation entre individuation, coordination et transport
  → composition intrinsèque

BilateralCore
  → complétude bilatérale
  → intersections typées
  → cycles terminaux
  → cohérences d'aller-retour
  → provenance et réalisation d'interface

ProjectiveCore
  → projection
  → obstruction de fibre
  → non-reconstruction
  → récupération locale
  → vérité projetée locale
  → gap, longueur référentielle et deux-pôles

ProjectedIdentity
  → identité projetée
  → transport de lecture
  → invariants projetés positifs

StrictRelaxation
  → inclusion des usages projectifs
  → contre-modèle directionnel composable
  → stricte non-réductibilité à l'égalité projetée

ClosedStabilityTheorem
  → combinaison BilateralCore + ProjectiveCore

DynamicCore
  → retour dynamique
  → provenance temporelle
  → récupération locale
  → vues gap et deux-pôles

DynamicRelaxedUsage
  → coordination et usage produits par le gap courant
  → mémoire bilatérale de l'autorisation
  → transition consommant l'état causal complet
  → variation intrinsèque du droit de transport

DynamicRelaxedUsageModel
  → instance finie non constante et non contractive
  → réparation exécutable
  → inversion effective de l'usage

DynamicRoleCarrier
  → lecture générique du retour dynamique en rôles

Parity
  → réalisation minimale autonome
  → spécialisation dynamique du porteur de rôles

OrderGap
  → test ordonné en aval
```

## 2. Graphe d'import vérifié

Le graphe critique est :

```text
RelaxedUsageRegime                         sans import
BilateralCore                              sans import
ProjectiveCore                             sans import

ProjectiveCore
  → ProjectedIdentity
  → StrictRelaxation

BilateralCore + ProjectiveCore
  → ClosedStabilityTheorem
  → DynamicCore
  → DynamicRoleCarrier
  → Parity

ProjectiveCore + DynamicCore
  → OrderGap

StrictRelaxation + DynamicCore
  → DynamicRelaxedUsage
  → DynamicRelaxedUsageModel
```

`ProjectiveCore` n'importe ni `BilateralCore`, ni `ProjectedIdentity`.
`DynamicCore` ne dépend pas de `Parity`. Aucun cycle n'apparaît dans cette
architecture.

## 3. Audit de `ProjectiveCore`

`Meta/Core/ProjectiveCore.lean` est une racine sans import. Il absorbe
effectivement les déclarations auparavant réparties entre le monolithe et les
petits modules projectifs.

### 3.1 Obstruction et reconstruction

```text
ProjectionObstruction
ProjectionFiberFaithful
ProjectionInformationConserving
projectionFiberFaithful_of_informationConserving
projectionObstruction_notFiberFaithful
projectionObstruction_notInformationConserving
noProjectiveReconstruction
```

### 3.2 Diagonale et récupération locale

```text
DiagonalCertificate
projectionObstructionOfDiagonalCertificate
LocalProjectiveRecovery
localProjectiveRecovery_obstruction
noProjectiveReconstructionOfLocalProjectiveRecovery
localProjectiveRecovery_notFiberFaithful
localProjectiveRecovery_notInformationConserving
```

### 3.3 Vérité projetée locale

```text
ReferentialScene
GeometricFormation
ProjectedLocalTruth
LocalTruthGapRecovery
RecoveryBundle
TerminalProjection
```

### 3.4 Vues consolidées

```text
ContractibleReferentialGap
StructuralReferentialGap
OperationalReferentialGap

ShortReferentialPresentation
EnrichedStructuralReferentialLength
EnrichedOperationalReferentialLength

StructuralTwoPole
OperationalTwoPole
```

Il n'existe aucune déclaration dupliquée entre `ProjectiveCore` et
`ClosedStabilityTheorem`. Le second conserve uniquement les structures et les
théorèmes combinant les racines bilatérale et projective.

## 4. Audit de la stricte relaxation

Le théorème central est formalisé dans
`Meta/Core/StrictRelaxation.lean`.

### 4.1 Relation comparée

```text
HasUse I γ x y := Nonempty (I.Use γ x y)
```

Une représentation projective est dite exacte lorsque :

```text
HasUse I γ x y ↔ project γ x = project γ y
```

L'équivalence exacte empêche une projection constante de servir de
pseudo-représentation par une implication unilatérale.

### 4.2 Inclusion

Toute projection induit :

```text
relaxedRegimeOfProjection
exactProjectiveRepresentationOfProjection
compositionalUseOfProjection
projectedIdentityTransport_in_relaxedUsageTransport
```

L'identité interne est obtenue par la spécialisation :

```text
project := id
```

### 4.3 Témoin strict

Le modèle `PhaseUse` porte exactement :

```text
before → before
before → after
after  → after
```

Il ne porte aucun témoin `after → before`. Le transport avant vers après est un
`NonContractiveUse` complet et possède sa `LocalTransportChain`. La composition
des deux chemins non triviaux est calculée explicitement.

Toute représentation projective exacte forcerait la symétrie de `HasUse` et
produirait le transport arrière impossible. Le théorème compilé est :

```text
projectedIdentityTransport_strictlyIncludedIn_relaxedUsageTransport
```

Sa portée exacte est :

```text
relations HasUse exactement représentables par égalité projetée
⊊
relations HasUse admises par RelaxedInterfaceRegime
```

Il ne revendique pas une supériorité absolue sur tout autre formalisme.

## 5. Consolidations vérifiées

### 5.1 Bilatéral

`BilateralCore.lean` est sans import. Les déclarations de complétude, cycles,
cohérences, témoins d'interface et stabilité fermée y ont été déplacées sans
changement de namespace ni de signature publique.

### 5.2 Dynamique

`DynamicCore.lean` contient :

```text
FormedDynamicReturn
TemporalExcessDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
dynamicReturn_operationalGap
dynamicReturn_structuralGap
dynamicReturn_operationalTwoPole
dynamicReturn_structuralTwoPole
```

### 5.3 Parité

`Parity.lean` contient à la fois le modèle minimal autonome et sa lecture
dynamique. `DynamicParitySeparation` y est construit comme une spécialisation
positive de `DynamicRoleCarrier`, et non comme une théorie parallèle.

## 6. Façades de compatibilité

Les sept modules historiques suivants sont tous devenus des façades minces :

| Façade | Module cible |
|---|---|
| `Gap.lean` | `ProjectiveCore.lean` |
| `ReferentialLength.lean` | `ProjectiveCore.lean` |
| `TwoPole.lean` | `ProjectiveCore.lean` |
| `DynamicStability.lean` | `DynamicCore.lean` |
| `DynamicTwoPole.lean` | `DynamicCore.lean` |
| `ParitySeparation.lean` | `Parity.lean` |
| `DynamicParitySeparation.lean` | `Parity.lean` |

Chaque façade contient seulement l'import cible, un avis de compatibilité et
son bloc d'audit historique.

Aucun fichier Lean consommateur n'importe encore ces façades. Elles restent
néanmoins présentes pour un cycle de compatibilité, car des documents
historiques citent encore leurs anciens chemins. Leur suppression est un
nettoyage optionnel ultérieur, pas une condition manquante de l'architecture.

## 7. Compatibilité de l'API

La comparaison entre la base gelée et l'état final établit :

```text
aucune disparition de structure publique
aucune disparition d'inductive public
aucune disparition d'abbrev public
aucune disparition de def publique
aucune disparition de theorem public
aucun nom dupliqué dans Meta/Core
```

Les namespaces historiques restent inchangés. Les consommateurs Tarski, Beth,
Bell, arithmétiques et dynamiques compilent après migration directe vers les
modules cibles.

Les types des structures critiques ont été contrôlés explicitement :

```text
BidirectionalCompleteness
ProjectionObstruction
LocalProjectiveRecovery
RelaxedInterfaceRegime
ExactProjectiveRepresentation
DynamicRoleCarrier
```

Les déplacements structurels n'ont pas modifié leurs univers historiques.

## 8. Audit constructif

Tous les fichiers Lean créés ou modifiés possèdent exactement un bloc
`AXIOM_AUDIT`, placé à la fin du fichier.

Les nouveaux noyaux et le théorème de stricte relaxation ne dépendent d'aucun
axiome. Ils n'utilisent notamment ni :

```text
axiom
sorry
admit
Classical
propext
Quot.sound
noncomputable
unsafe
```

Réserve de périmètre : `Meta/Tarski/FoundationBridge.lean`, inchangé par cette
réorganisation, conserve les dépendances classiques déjà présentes dans la
base :

```text
propext
Classical.choice
Quot.sound
```

Elles ne sont pas introduites ni propagées par le nouveau Core.

## 9. Validation rejouable

Les élaborations unitaires de clôture sont :

```bash
lake env lean Meta/Core/RelaxedUsageRegime.lean
lake env lean Meta/Core/StrictRelaxation.lean
lake env lean Meta/Core/BilateralCore.lean
lake env lean Meta/Core/ProjectiveCore.lean
lake env lean Meta/Core/ProjectedIdentity.lean
lake env lean Meta/Core/ClosedStabilityTheorem.lean
lake env lean Meta/Core/DynamicCore.lean
lake env lean Meta/Core/DynamicRelaxedUsage.lean
lake env lean Meta/Core/DynamicRelaxedUsageModel.lean
lake env lean Meta/Core/DynamicRoleCarrier.lean
lake env lean Meta/Core/OrderGap.lean
lake env lean Meta/Core/Parity.lean
```

La validation globale est :

```bash
lake build
```

Résultat de clôture :

```text
Build completed successfully (1230 jobs).
```

## 10. Verdict

```text
réorganisation conceptuelle principale : terminée
extraction bilatérale                  : terminée
consolidation projective               : terminée
réduction du monolithe                 : terminée
consolidation dynamique                : terminée
consolidation de la parité             : terminée
stricte relaxation                     : formalisée
synthèse dynamique de l'usage         : formalisée
modèle dynamique non trivial          : construit
migration des imports Lean             : terminée
compatibilité API                      : vérifiée
audits constructifs du nouveau Core    : vérifiés
```

Ce verdict clôt uniquement la réorganisation architecturale.

## 11. Synthèse fondationnelle accomplie

Les modules suivants ferment maintenant le raccord entre les deux résultats :

```text
Meta/Core/DynamicRelaxedUsage.lean
Meta/Core/DynamicRelaxedUsageModel.lean
```

Le nouveau graphe aval est :

```text
StrictRelaxation + DynamicCore
  → DynamicRelaxedUsage
  → DynamicRelaxedUsageModel
```

`DynamicRelaxedUsage` fournit :

```text
IntrinsicDynamicReturnFamily
DynamicUsageContext
DynamicGapCoordination
DynamicGapUse
dynamicRelaxedRegimeOfReturnFamily
DynamicUsageMemory
DynamicGapCausalState
GapDrivenDynamicSystem
DynamicUsageStep
GenuineDynamicUsageVariation
GenuinelyVaryingDynamicUsageSystem
dynamicRelaxedRegime_not_exactProjective
```

La causalité formalisée est :

```text
retour localement récupéré
→ intersection et gap courants
→ coordination indexée
+ séparation
→ usage preuve-pertinent
→ transports formé et visible
→ mémoire du cycle bilatéral
→ état causal complet
→ advance
→ prochaine source
```

`next` n'est pas un champ du système. Il est défini en appliquant `advance` à
la somme dépendante contenant la source et son état causal canonique.

## 12. Validation de non-trivialité

Le modèle `DynamicRelaxedUsageModel` ne repose sur aucun jeton universel ni
sur aucune projection constante. Il construit :

```text
2 sources dynamiques distinctes ;
3 interfaces distinctes ;
2 visibles distincts ;
une projection non constante avec une fibre non injective ;
4 familles bilatérales distinctes ;
2 orientations opposées de l'usage ;
des réparations indexées avec une fonction apply ;
une transition qui inspecte l'usage mémorisé ;
un paquet final fermé sans argument externe.
```

Les droits changent effectivement :

```text
leftToRight : leftPole → rightPole
              aucun usage inverse

rightToLeft : rightPole → leftPole
              aucun usage inverse
```

La projection conserve le visible commun des deux pôles, tout en distinguant
le `marker`. L'impossibilité d'une reconstruction globale et l'impossibilité
d'une représentation projective exacte sont dérivées de ces données.

Le paquet final :

```text
switchDynamicRelaxationSynthesis
```

conserve la famille, la dynamique, la variation, l'étape initiale, les deux
usages, les réparations et les réfutations de trivialisation.

Le nettoyage restant des façades historiques demeure optionnel. La synthèse
dynamique de l'usage relaxé n'est plus un objectif futur : elle est une couche
compilée du Core.
