# Plan de clôture après la stricte relaxation

## 0. Objet

Le résultat statique central est acquis et ne doit plus être réorganisé :

```text
identité interne
⊆
identité projetée
⊊
usage relaxé
```

La stricte inclusion porte exactement sur `HasUse`. Le régime directionnel
fournit `before → after`, refuse `after → before`, compose ses témoins d'usage
et réfute toute représentation exacte par égalité projetée.

Le prochain objectif est de fermer trois niveaux :

```text
obstruction statique générique
+
cohérence preuve-pertinente du transport composé
+
instance métamathématique dynamique fermée
```

Ce plan part de l'état réel du dépôt au 15 juillet 2026. Il corrige les étapes
devenues obsolètes et interdit de recréer des structures déjà compilées.

### 0.1 Rapport d'exécution

La livraison correspondant aux étapes 1 à 11 est implémentée :

```text
Phase A : terminée dans StrictRelaxation.lean ;
Phase B : terminée dans TransportCoherence.lean
          et TransportCoherenceModel.lean ;
Phase C : terminée dans DynamicRelaxedUsage.lean
          et son modèle switch ;
Phase D : terminée dans Tarski/DynamicRelaxedUsage.lean ;
Phase E : terminée dans Tarski/ConstructivePatchModel.lean ;
intégration publique : terminée dans Meta.lean.
```

Le raccord Tarski positif ne part pas d'une définition globale exacte. Chaque
candidat fournit son point fixe, son mismatch local, son repair indexé et son
candidat suivant. `advance` inspecte l'usage mémorisé dans l'état causal avant
d'exécuter le repair porté par le retour courant. Le `next` public est dérivé de
cet `advance` ; il n'est pas un paramètre extérieur.

L'instance fermée utilise une syntaxe finie effective :

```text
PatchCandidate
→ atome frais calculé
→ mismatch local
→ ajout syntaxique de l'atome
→ candidat distinct
→ nouvel atome frais
→ nouveau mismatch.
```

Elle prouve en outre la sensibilité de `applyQuote` au candidat, la
non-constance de la projection, deux transitions successives, et l'absence de
correction globale pour tout itéré. Une induction identifie l'itération du
système gap-driven à `iteratePredicate` à toute profondeur. Le paquet terminal
`constructiveTarskiClosedSystem` ne reçoit aucun algorithme ni aucune preuve
comme argument.

La phase F reste le jalon arithmétique distinct décrit plus bas. Elle n'est pas
remplacée par le modèle à support fini, ni par `FoundationBridge`, dont les
dépendances classiques sont incompatibles avec ce noyau constructif. La
livraison présente établit donc la clôture syntaxique et causale annoncée par
les étapes 1 à 11, sans revendiquer une arithmétisation du premier ordre.

## 1. État vérifié

### 1.1 Statique terminé

`Meta/Core/StrictRelaxation.lean` contient déjà :

```text
ExactProjectiveRepresentation
hasUse_refl_of_exactProjectiveRepresentation
hasUse_symm_of_exactProjectiveRepresentation
hasUse_trans_of_exactProjectiveRepresentation
relaxedRegimeOfProjection
exactProjectiveRepresentationOfProjection
compositionalUseOfProjection
directionalRelaxedRegime
directionalCompositionalUse
directionalNonContractiveUse_forward
directionalTransportChain_forward
directionalRelaxedRegime_not_exactProjective
projectedIdentityTransport_strictlyIncludedIn_relaxedUsageTransport
```

Les seules clôtures statiques manquantes sont :

```text
un théorème générique d'obstruction par asymétrie ;
un prédicat nommé de représentabilité projective ;
une formulation finale au niveau des classes représentables.
```

### 1.2 Dynamique déjà synthétisée

Il ne faut pas créer une seconde structure minimale appelée
`DynamicRelaxedUsage`. `Meta/Core/DynamicRelaxedUsage.lean` contient déjà une
construction plus forte :

```text
IntrinsicDynamicReturnFamily
DynamicUsageContext
DynamicGapCoordination
DynamicGapUse
dynamicRelaxedRegimeOfReturnFamily
dynamicCompositionalUseOfReturnFamily
DynamicUsageMemory
DynamicGapCausalState
GapDrivenDynamicSystem
DynamicUsageStep
GenuineDynamicUsageVariation
GenuinelyVaryingDynamicUsageSystem
```

La chaîne suivante est déjà un calcul Lean :

```text
source
→ retour dynamique localement récupéré
→ intersection source
→ gap courant
→ séparation + coordination
→ usage courant
→ transports formé et visible
→ mémoire bilatérale
→ état causal
→ advance ⟨source, état causal⟩
→ next source
```

`next` est dérivé de `advance` appliqué au paquet causal canonique. La synthèse
dynamique abstraite demandée dans la proposition initiale existe donc déjà.

### 1.3 Modèle dynamique déjà habité

`Meta/Core/DynamicRelaxedUsageModel.lean` fournit déjà :

```text
2 états ;
3 interfaces ;
2 visibles ;
une projection non constante ;
une fibre non injective ;
4 familles bilatérales distinctes ;
une réparation indexée et exécutable ;
une transition qui inspecte l'usage causal ;
une variation effective ;
un paquet final fermé sans argument externe.
```

Un modèle à trois phases reste pertinent uniquement pour tester la composition
de deux transports non réflexifs. Il ne doit pas être présenté comme une
nouvelle preuve de l'habitabilité dynamique.

### 1.4 Voie Tarski syntaxique active

L'ancienne voie qui patchait directement un prédicat sémantique arbitraire
`Sentence → Prop` a été supprimée. Elle ne doit pas être réintroduite : son
état suivant vivait hors du type syntaxique des candidats.

`Meta/Tarski/TruthGap.lean` conserve la voie correcte :

```text
PatchableArithmeticTarskiContext
PatchableArithmeticTarskiContext.AlgorithmStep
```

Elle reste dans un type syntaxique `Predicate` et calcule :

```text
prédicat courant
→ phrase diagonale
→ mismatch local
→ patch syntaxique
→ prédicat suivant
→ nouveau mismatch.
```

Elle prouve la réparation au point courant, la conservation hors de ce point et
l'impossibilité d'une correction globale après toute itération. Son raccord au
système dynamique et son modèle fermé sont maintenant réalisés dans :

```text
Meta/Tarski/DynamicRelaxedUsage.lean
Meta/Tarski/ConstructivePatchModel.lean
```

Les deux objectifs restants sont la théorie exacte de cette orbite concrète et
l'arithmétisation Foundation véritable.

## 2. Contraintes non négociables

Chaque phase doit respecter :

```text
aucun axiom ;
aucun sorry ou admit ;
aucun Classical ;
aucun propext ;
aucun Quot.sound ;
aucun noncomputable ;
aucun unsafe.
```

Sont également interdits :

```text
Use := Unit ;
OutRel := Unit ;
RepairOf := Unit ;
WitnessOf := Unit ;
une projection constante comme seul modèle ;
False.elim pour fabriquer une donnée positive ;
un next fourni indépendamment du gap ;
un patch sémantique extérieur au type syntaxique Candidate ;
Complete, Forward, Backward et Intersection comme même alias ;
un résultat final conditionné par un pont terminal non construit.
```

L'élimination d'un cas réellement impossible reste autorisée dans une
réfutation. Elle ne doit jamais servir à habiter le paquet final.

## 3. Phase A — clôture de `StrictRelaxation`

### 3.1 Obstruction générique par asymétrie

Ajouter dans `Meta/Core/StrictRelaxation.lean` :

```lean
theorem not_exactProjective_of_asymmetric_use
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (forward : HasUse I gamma x y)
    (noBackward : HasUse I gamma y x -> False)
    (representation : ExactProjectiveRepresentation I) :
    False :=
  noBackward
    (hasUse_symm_of_exactProjectiveRepresentation
      representation
      forward)
```

Le résultat ne dépend ni de `Phase`, ni d'une projection donnée, ni d'une
structure dynamique :

```text
usage asymétrique
→ non-projectivité exacte.
```

Refactorer ensuite :

```text
directionalRelaxedRegime_not_exactProjective
dynamicRelaxedRegime_not_exactProjective
```

pour qu'ils appliquent le théorème générique, sans changer leurs signatures.

### 3.2 Représentabilité nommée

Ajouter :

```lean
def ProjectivelyRepresentable
    {X : Type u}
    (I : RelaxedInterfaceRegime X) :
    Prop :=
  Nonempty (ExactProjectiveRepresentation I)
```

Puis :

```lean
theorem relaxedRegimeOfProjection_projectivelyRepresentable
    (project : X -> Visible) :
    ProjectivelyRepresentable
      (relaxedRegimeOfProjection project)

theorem directionalRelaxedRegime_not_projectivelyRepresentable :
    ProjectivelyRepresentable directionalRelaxedRegime -> False
```

Le premier conserve explicitement
`exactProjectiveRepresentationOfProjection`. Le second élimine le `Nonempty`
et applique l'obstruction générique.

### 3.3 Formulation finale et gel

Ajouter un paquet exposant :

```text
toute projection engendre un régime représentable ;
le régime directionnel est composable ;
le régime directionnel n'est pas représentable.
```

La stricte inclusion reste une comparaison des relations `HasUse`
représentables, pas une comparaison indéfinie de formalismes entiers.

Après compilation et audit, geler le fichier : plus aucun déplacement de
déclaration ni changement de structure primitive.

## 4. Phase B — cohérence du transport composé

### 4.1 Nouveau module de lois

Créer :

```text
Meta/Core/TransportCoherence.lean
```

avec :

```lean
import Meta.Core.RelaxedUsageRegime
```

Ce module ajoute des lois sans modifier `RelaxedInterfaceRegime`,
`CompositionalUse` ou `LocalTransportChain`.

`StrictRelaxation.lean` importe ensuite `TransportCoherence` à la place de son
import direct de `RelaxedUsageRegime`. `DynamicRelaxedUsage.lean` reçoit cette
couche transitivement par `StrictRelaxation`. `Meta.lean` importe néanmoins
explicitement `TransportCoherence` afin que l'architecture publique reste
lisible. Aucun import inverse vers `StrictRelaxation` ou `DynamicCore` n'est
autorisé depuis le nouveau module de lois.

### 4.2 Lois des usages preuve-pertinents

Définir :

```lean
structure LawfulCompositionalUse
    {X : Type u}
    (I : RelaxedInterfaceRegime X)
    (uses : CompositionalUse I) where

  leftIdentity :
    forall {gamma} {x y}
      (use : I.Use gamma x y),
      uses.compose (uses.identity gamma x) use = use

  rightIdentity :
    forall {gamma} {x y}
      (use : I.Use gamma x y),
      uses.compose use (uses.identity gamma y) = use

  associativity :
    forall {gamma} {w x y z}
      (first : I.Use gamma w x)
      (second : I.Use gamma x y)
      (third : I.Use gamma y z),
      uses.compose (uses.compose first second) third =
        uses.compose first (uses.compose second third)
```

Ces égalités portent sur les témoins eux-mêmes, pas seulement sur `HasUse`.

### 4.3 Lois des relations de sortie

Définir :

```lean
structure CompositionalTransport
    {X : Type u}
    (I : RelaxedInterfaceRegime X)
    (uses : CompositionalUse I) where

  useLaws :
    LawfulCompositionalUse I uses

  outIdentity :
    forall gamma rho x,
      I.OutRel gamma rho
        (I.read gamma rho x)
        (I.read gamma rho x)

  outCompose :
    forall {gamma} (rho : I.Read gamma) {x y z},
      I.OutRel gamma rho
        (I.read gamma rho x)
        (I.read gamma rho y) ->
      I.OutRel gamma rho
        (I.read gamma rho y)
        (I.read gamma rho z) ->
      I.OutRel gamma rho
        (I.read gamma rho x)
        (I.read gamma rho z)

  outLeftIdentity :
    forall {gamma} (rho : I.Read gamma) {x y}
      (relation :
        I.OutRel gamma rho
          (I.read gamma rho x)
          (I.read gamma rho y)),
      outCompose rho
        (outIdentity gamma rho x)
        relation = relation

  outRightIdentity :
    forall {gamma} (rho : I.Read gamma) {x y}
      (relation :
        I.OutRel gamma rho
          (I.read gamma rho x)
          (I.read gamma rho y)),
      outCompose rho
        relation
        (outIdentity gamma rho y) = relation

  outAssociativity :
    forall {gamma} (rho : I.Read gamma) {w x y z}
      (first :
        I.OutRel gamma rho
          (I.read gamma rho w)
          (I.read gamma rho x))
      (second :
        I.OutRel gamma rho
          (I.read gamma rho x)
          (I.read gamma rho y))
      (third :
        I.OutRel gamma rho
          (I.read gamma rho y)
          (I.read gamma rho z)),
      outCompose rho
        (outCompose rho first second)
        third =
      outCompose rho
        first
        (outCompose rho second third)

  transportIdentity :
    forall gamma rho x,
      I.transport (uses.identity gamma x) rho =
        outIdentity gamma rho x

  transportComposition :
    forall {gamma} (rho : I.Read gamma) {x y z}
      (first : I.Use gamma x y)
      (second : I.Use gamma y z),
      I.transport (uses.compose first second) rho =
        outCompose rho
          (I.transport first rho)
          (I.transport second rho)
```

Les trois lois de sortie doivent être conservées intégralement dans
l'implémentation.

Cette structure formalise :

```text
identité d'usage ↦ identité de transport
composition d'usages ↦ composition de transports.
```

### 4.4 Instances statiques obligatoires

Construire :

```text
lawfulCompositionalUseOfProjection
compositionalTransportOfProjection
directionalLawfulCompositionalUse
directionalCompositionalTransport
```

Le régime directionnel prouve les lois par analyse exhaustive de `PhaseUse`.
Le régime projectif les prouve sur les égalités projetées, sans `propext` ni
quotient.

### 4.5 Test à trois phases

Créer :

```text
Meta/Core/TransportCoherenceModel.lean
```

Il doit contenir trois objets et les témoins :

```text
before → during
during → after
before → after
```

Test central :

```text
transport(before → during)
;
transport(during → after)
=
transport(before → after).
```

Les deux premiers transports sont non réflexifs. Le test ne peut donc pas être
validé uniquement par une identité, un type vide ou `Unit`.

Ce modèle teste la composition horizontale dans un contexte fixé. Il ne
remplace pas le modèle dynamique existant.

## 5. Phase C — enrichir la synthèse dynamique existante

### 5.1 Limites de l'intervention

Modifier seulement `Meta/Core/DynamicRelaxedUsage.lean`. Ne pas modifier :

```text
BilateralCore.lean
DynamicCore.lean
GapDrivenDynamicSystem
DynamicGapCausalState
```

sauf impossibilité de type démontrée. Aucun champ `next` indépendant ne doit
être ajouté.

### 5.2 Transport dynamique cohérent

Construire pour chaque `IntrinsicDynamicReturnFamily` :

```text
dynamicLawfulCompositionalUseOfReturnFamily
dynamicCompositionalTransportOfReturnFamily
```

Traiter les deux lectures :

```text
DynamicGapReading.formed
DynamicGapReading.visible.
```

Pour la lecture formée, `OutRel` est l'usage dynamique. Pour la lecture visible,
la composition est celle des égalités portées par
`DynamicVisibleTransportRelation`.

Les preuves couvrent :

```text
réflexif ;
réflexif puis causal ;
causal puis réflexif ;
causal puis causal impossible par séparation des pôles.
```

### 5.3 Cohérence de l'état causal

Ajouter des théorèmes, sans dupliquer ses champs :

```text
le transport formé mémorisé est l'image de memory.use ;
le transport visible mémorisé est l'image du même memory.use ;
la composition des usages mémorisés est envoyée sur la composition
des transports correspondants.
```

L'état causal conserve alors deux images cohérentes du même droit d'usage, et
non deux relations seulement juxtaposées.

### 5.4 Obstruction générique et modèle fermé

Réécrire `dynamicRelaxedRegime_not_exactProjective` comme application de
`not_exactProjective_of_asymmetric_use`.

Étendre `DynamicRelaxedUsageModel.lean` avec un paquet fermé qui conserve :

```text
composition légale des usages ;
composition légale des transports ;
causalité de advance ;
variation des contextes ;
réparation exécutable ;
non-représentabilité projective.
```

## 6. Phase D — raccord Tarski dynamique

### 6.1 Module aval

Créer :

```text
Meta/Tarski/DynamicRelaxedUsage.lean
```

avec :

```lean
import Meta.Core.DynamicRelaxedUsage
import Meta.Core.TransportCoherence
import Meta.Tarski.TruthGap
```

La source dynamique est le prédicat courant :

```text
Source := patchable.context.Predicate.
```

Ne pas redéfinir `LocalTruthMismatch`, `AlgorithmStep`, `nextPredicate` ou
`iteratePredicate`.

Le nouveau raccord ne remplace pas `TarskiDiagonalReturnSource`. Les deux
constructions ont des fonctions logiques différentes :

```text
TarskiDiagonalReturnSource
= point fixe + prétention globale exacte
→ gap orienté
→ réfutation de la prétention ;

PatchableArithmeticTarskiContext.AlgorithmStep
= candidat syntaxique + point fixe
→ mismatch local
→ patch
→ candidat suivant.
```

La première reste la factorisation négative correcte du théorème de Tarski. La
seconde porte la dynamique positive et habitée. Il est interdit d'affaiblir le
gap orienté de la première en le remplaçant par un mismatch, comme il est
interdit de rendre la seconde contradictoire en lui ajoutant une définition
exacte globale.

### 6.2 Retour positif à chaque candidat

Pour chaque `tau`, construire un retour depuis :

```text
step tau ;
step tau.fixedPoint ;
step tau.mismatch ;
step tau.nextPredicate.
```

Les pôles sont :

```text
formed := semantic step.diagonalSentence
shadow := syntactic step.diagonalSentence.
```

Le retour conserve leur projection commune, leur séparation, la provenance du
candidat, le mismatch, le patch et le prochain candidat. Il ne suppose aucune
définition exacte globale de vérité.

### 6.3 Témoins et réparations non triviaux

Les types indexés doivent contenir réellement :

```text
le candidat courant ;
la phrase diagonale ;
le point fixe ;
le mismatch ;
le prochain candidat ;
la preuve qu'il est le patch courant.
```

La réparation possède :

```text
applyCandidate : Candidate
applyCandidate_eq : applyCandidate = step.nextPredicate.
```

L'application locale à l'interface reste compatible avec
`LocalProjectiveRecovery`, mais ne remplace pas la réparation du candidat. Les
deux effets sont nommés séparément.

### 6.4 Complétude bilatérale distincte

Construire quatre paquets non aliasés :

```text
TarskiPatchComplete
TarskiPatchForward
TarskiPatchBackward
TarskiPatchIntersection.
```

Leur contenu correspond respectivement à :

```text
étape complète ;
challenge diagonal ;
réparation syntaxique ;
mismatch + provenance + prochain candidat.
```

Les deux cohérences d'aller-retour sont prouvées sur ces données.

### 6.5 Transition réellement causale

Construire une `IntrinsicDynamicReturnFamily` puis un
`GapDrivenDynamicSystem` dont `advance` :

```text
1. inspecte l'usage stocké dans DynamicGapCausalState ;
2. retrouve la réparation portée par le retour courant ;
3. applique cette réparation ;
4. retourne exactement step.nextPredicate.
```

La définition interdite est :

```text
advance ⟨tau, _⟩ := patchable.nextPredicate tau
```

si elle ignore le paquet causal et la réparation du retour.

### 6.6 Variation issue du mismatch

Prouver :

```text
tau = nextPredicate tau
→ accord du candidat courant au point diagonal
→ contradiction avec mismatch.
```

Donc `tau ≠ nextPredicate tau`.

Cette variation n'est pas une permutation des pôles. Ne pas forcer Tarski dans
`GenuineDynamicUsageVariation`. Créer au besoin une structure aval
`IntrinsicGapDrivenStateChange` conservant l'étape causale et
`source ≠ nextSource`.

### 6.7 Paquet final Tarski

Il expose :

```text
candidat courant ;
challenge diagonal ;
gap semantic/syntactic ;
usage non identitaire ;
transport cohérent ;
patch interne ;
candidat suivant ;
réparation locale ;
nouveau mismatch ;
absence de correction globale.
```

Chaîne certifiée :

```text
Candidateₙ
→ Diagonalₙ
→ Gapₙ
→ Useₙ
→ Transportₙ
→ Patchₙ
→ Candidateₙ₊₁
→ Gapₙ₊₁.
```

## 7. Phase E — instance syntaxique constructive fermée

### 7.1 Nécessité

`PatchableArithmeticTarskiContext` reste une interface tant qu'aucun habitant
concret n'est construit. Créer :

```text
Meta/Tarski/ConstructivePatchModel.lean
```

Le modèle est infini, syntaxique et exécutable. Un modèle fini fermé sous tous
les patchs finirait par représenter toute sa sémantique, en conflit avec la
diagonale.

### 7.2 Modèle recommandé à support fini

Utiliser des données syntaxiques, jamais un champ `Sentence → Prop` :

```text
Sentence := atom Nat | literal Bool
Candidate := liste finie d'atomes validés.
```

Interprétation :

```text
models (atom n)        := True
models (literal true)  := True
models (literal false) := False.
```

Application :

```text
applyQuote candidate (atom n)
  := literal (candidate contient n)

applyQuote candidate (literal b)
  := literal b.
```

La diagonale choisit un atome frais absent du support :

```text
diagonal candidate := atom (fresh candidate).
```

Alors :

```text
models (diagonal candidate)
↔
¬models (applyQuote candidate (diagonal candidate)).
```

Le patch ajoute un atome au support lorsque l'index est un atome et conserve
le candidat lorsque l'index est un littéral. Il satisfait les lois du contexte
patchable pour tout index, pas seulement la diagonale.

### 7.3 Non-trivialité obligatoire

Prouver :

```text
deux phrases distinctes ;
deux candidats distincts ;
models possède une valeur vraie et une valeur fausse ;
applyQuote dépend du candidat ;
la diagonale est fraîche ;
le patch modifie le candidat au point diagonal ;
le candidat suivant diffère du candidat courant ;
deux itérations sont causalement liées ;
aucun candidat fini n'est globalement correct.
```

Le paquet final est fermé : aucun `algorithm`, `patch`, `fresh`, `next` ou
preuve de correction n'est reçu comme argument.

### 7.4 Portée exacte

Ce modèle ferme constructivement l'interface syntaxique et l'algorithme causal.
Il ne doit pas être appelé « arithmétisation de Tarski » : ses candidats sont à
support fini, pas des formules arithmétiques du premier ordre.

## 8. Phase F — arithmétisation véritable

### 8.1 Jalon scientifique indispensable

La clôture complète exige une instance où :

```text
Sentence est une syntaxe arithmétique codée ;
Predicate est une syntaxe unaire codée ;
applyQuote est la substitution d'un code de phrase ;
models est l'interprétation arithmétique visée ;
diagonal est construit par le lemme diagonal ;
patchPredicate reste dans la syntaxe arithmétique.
```

La réparation syntaxique visée est la formule unaire codée correspondant à :

```text
patch(τ, σ)(x)
:=
(x = code(σ) ∧ σ)
∨
(τ(x) ∧ x ≠ code(σ)).
```

Il faut construire cette formule avec les constructeurs de syntaxe, sa
substitution et son code. L'équation ci-dessus est une spécification à prouver,
pas une définition sémantique admise comme champ externe.

Ce jalon ne peut pas être remplacé par :

```text
Predicate := Sentence → Prop ;
une fonction sémantique extérieure ;
un appel direct au théorème officiel ;
un alias du résultat de Foundation.
```

### 8.2 Limite actuelle de `FoundationBridge`

`Meta/Tarski/FoundationBridge.lean` redirige actuellement le théorème local
vers Foundation. Son audit signale :

```text
propext
Classical.choice
Quot.sound.
```

Il ne peut pas servir de preuve constructive du nouveau paquet et ne doit pas
être importé par le noyau constructif.

La phase F exige un sous-développement arithmétique constructif autonome, ou
une extraction de Foundation dont l'audit final est vide. Un théorème
conditionnel « si le pont existe » n'est pas une livraison acceptable.

### 8.3 Critère de clôture arithmétique

Un terme fermé doit construire :

```text
ArithmeticTarskiContext
+
PatchableArithmeticTarskiContext
+
le système DynamicRelaxedUsage associé
+
le théorème d'indéfinissabilité dérivé de cette chaîne.
```

## 9. Deux compositions à ne pas confondre

### 9.1 Composition horizontale

Dans un contexte fixé `gamma` :

```text
Use gamma x y
+
Use gamma y z
→
Use gamma x z.
```

`CompositionalTransport` garantit que le transport respecte cette composition.

### 9.2 Enchaînement temporel

Entre deux états :

```text
contextAt state
→
contextAt (next state).
```

`Read`, `Out` et `OutRel` peuvent dépendre du contexte. Leur composition
temporelle n'est donc pas automatique.

Pour une instance qui compose plusieurs pas, ajouter en aval :

```text
reindexRead ;
reindexOutput ;
reindexRelation ;
compatibilité avec next.
```

Cette donnée est construite par l'instance, jamais ajoutée comme axiome au
régime général.

## 10. Ordre d'implémentation

```text
1. ajouter l'obstruction générique par asymétrie ;
2. ajouter ProjectivelyRepresentable ;
3. compiler et geler StrictRelaxation ;
4. créer TransportCoherence ;
5. prouver les instances projective et directionnelle ;
6. construire le test à trois phases ;
7. enrichir DynamicRelaxedUsage par les lois de transport ;
8. revalider le modèle switch fermé ;
9. créer le raccord Tarski dynamique ;
10. construire ConstructivePatchModel ;
11. fermer le paquet Tarski dynamique concret ;
12. entreprendre l'arithmétisation constructive véritable.
```

Les étapes 1 à 11 forment une livraison cohérente. L'étape 12 est nécessaire
pour revendiquer une réalisation arithmétique de Tarski plutôt qu'un modèle
syntaxique constructif de son schéma causal.

## 11. Audits obligatoires

Chaque fichier Lean créé ou modifié possède exactement un bloc terminal :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedUsageRegime.CompositionalTransport
/- AXIOM_AUDIT_END -/
```

La ligne affichée illustre la forme du bloc. Chaque fichier remplace le nom par
ses propres déclarations principales et peut contenir plusieurs lignes
`#print axioms`.

Déclarations minimales à auditer :

```text
not_exactProjective_of_asymmetric_use
ProjectivelyRepresentable
directionalRelaxedRegime_not_projectivelyRepresentable
LawfulCompositionalUse
CompositionalTransport
directionalCompositionalTransport
dynamicCompositionalTransportOfReturnFamily
la famille de retours Tarski
le système gap-driven Tarski
constructivePatchableTarskiContext
le paquet de synthèse Tarski concret.
```

Commandes de validation :

```bash
lake env lean Meta/Core/StrictRelaxation.lean
lake env lean Meta/Core/TransportCoherence.lean
lake env lean Meta/Core/TransportCoherenceModel.lean
lake env lean Meta/Core/DynamicRelaxedUsage.lean
lake env lean Meta/Core/DynamicRelaxedUsageModel.lean
lake env lean Meta/Tarski/DynamicRelaxedUsage.lean
lake env lean Meta/Tarski/ConstructivePatchModel.lean
lake env lean Meta.lean
lake build
```

Contrôle textuel :

```bash
rg -n "axiom|sorry|admit|Classical|propext|Quot.sound|noncomputable|unsafe" \
  Meta/Core/StrictRelaxation.lean \
  Meta/Core/TransportCoherence.lean \
  Meta/Core/TransportCoherenceModel.lean \
  Meta/Core/DynamicRelaxedUsage.lean \
  Meta/Core/DynamicRelaxedUsageModel.lean \
  Meta/Tarski/DynamicRelaxedUsage.lean \
  Meta/Tarski/ConstructivePatchModel.lean
```

## 12. Critères d'arrêt

### 12.1 Clôture statique

```text
obstruction par asymétrie générique ;
représentabilité nommée ;
régime projectif représentable ;
régime directionnel non représentable ;
audit constructif vide.
```

### 12.2 Calcul de transport

```text
lois des usages preuve-pertinents ;
lois des relations de sortie ;
transport des identités ;
transport des compositions ;
composition de deux pas non réflexifs dans un modèle habité.
```

### 12.3 Dynamique abstraite

```text
le gap produit l'usage ;
l'usage produit deux transports cohérents ;
la mémoire conserve leur source commune ;
advance consomme l'état causal ;
next reste dérivé ;
la non-projectivité utilise l'obstruction générique.
```

### 12.4 Tarski syntaxique

```text
candidats concrets ;
diagonale calculée ;
mismatch calculé ;
patch interne calculé ;
candidat suivant calculé depuis le paquet causal ;
variation démontrée ;
itération habitée ;
absence de correction globale ;
paquet final sans argument externe.
```

### 12.5 Tarski arithmétique

```text
codes arithmétiques réels ;
substitution réelle ;
diagonalisation réelle ;
patch syntaxiquement définissable ;
aucun appel terminal au théorème officiel ;
aucune dépendance classique dans l'audit.
```

## 13. Résultat final visé

La chaîne constructive complète doit être :

```text
séparation
+
coordination
→
usage preuve-pertinent
→
transport cohérent et composable
→
mémoire bilatérale
→
transition causale
→
nouvel état
→
nouveau gap.
```

Dans l'instance Tarski :

```text
candidat syntaxique
→ phrase diagonale
→ gap syntaxe/sémantique
→ droit local de transport
→ patch syntaxique interne
→ nouveau candidat
→ nouvelle phrase diagonale.
```

L'identité conserve l'individuation. La coordination autorise un transport
local sans contraction. Le gap devient la cause typée de la réparation et du
passage à l'état suivant. La cohérence du transport garantit enfin que ces
passages forment un calcul, et non une simple collection de relations.
