# Plan de validation intégrale de la fermeture sémantique dynamique pour l'IA

## 0. Statut et objet

Ce document ne propose ni une nouvelle réorganisation du Core, ni une nouvelle
reformulation générale de la théorie. Les couches abstraites pertinentes sont
déjà présentes :

```text
ProjectiveCore
StrictRelaxation
TransportCoherence
DynamicCore
DynamicRelaxedUsage
Semantics/FoundationalStability
Tarski/ConstructivePatchOrbit
```

Le travail restant est une validation intégrale, c'est-à-dire une chaîne dans
laquelle la théorie, une instance constructive exécutable, une réalisation
apprise et leurs certificats désignent exactement les mêmes opérations.

La thèse à valider est :

> Un système peut conserver l'identité stricte pour l'individuation, détecter
> une non-coïncidence sémantique locale entre deux pôles coordonnés, transformer
> ce gap en droit d'usage non identitaire, en dériver une requête et une
> réparation intrinsèques, puis produire son état suivant sans contracter les
> pôles ni recevoir sa transition d'un ordonnanceur externe.

La chaîne complète est :

```text
étatₙ
→ projection visibleₙ
→ gapₙ
→ usageₙ
→ transportₙ
→ requêteₙ
→ réponseₙ
→ réparationₙ
→ étatₙ₊₁
→ projection visibleₙ₊₁
→ gapₙ₊₁.
```

Une validation n'est intégrale que si chaque flèche est simultanément :

```text
définie dans le système ;
typée par la théorie ;
exécutée par l'instance ;
observable dans les traces ;
testée par intervention ;
recalculée par le vérificateur ;
et raccordée à un théorème Lean sans axiome.
```

### 0.1 Socle déjà fermé et à réutiliser

Le plan ne doit pas redémontrer sous de nouveaux noms les résultats existants.
Les raccords obligatoires sont :

```text
Meta/Core/ProjectiveCore.lean
  ProjectionObstruction
  LocalProjectiveRecovery

Meta/Core/StrictRelaxation.lean
  ExactProjectiveRepresentation
  not_exactProjective_of_asymmetric_use

Meta/Core/TransportCoherence.lean
  LawfulCompositionalUse
  CompositionalTransport

Meta/Core/DynamicRelaxedUsage.lean
  IntrinsicDynamicReturnFamily
  DynamicGapCausalState
  GapDrivenDynamicSystem

Meta/Semantics/DynamicFoundationalStability.lean
  GapRepairAlgebra
  InternalRepairDrivenStep
  EffectiveRepairAt
  RepairDrivenInvariant

Meta/Semantics/FoundationalStability.lean
  generalRelaxedFoundationalSemantics

Meta/Tarski/ConstructivePatchOrbit.lean
  constructiveTarskiOrbitTheorem.
```

Les nouveaux modules sont des spécialisations ou des vérificateurs. Aucun
module générique du Core ou de `Meta/Semantics` ne doit importer `Meta/AI` ou
les artefacts empiriques.

### 0.2 Travail réellement nouveau

Les éléments qui ne sont pas encore fermés ensemble sont :

```text
une frontière typée entre monde sémantique et vue de l'agent ;
une requête calculée depuis l'usage courant ;
une réponse environnementale calculée après cette requête ;
un patch calculé depuis la réponse sans accès direct au monde ;
un théorème d'effet causal observable ;
une tâche apprise multi-étapes ;
des interventions causales systématiques ;
un certificat Lean calculé depuis les traces ;
une comparaison empirique indépendante et OOD scellée.
```

## 1. Nature exacte de la revendication

### 1.1 Ce qui doit être démontré

La validation doit établir quatre résultats distincts.

#### Résultat formel général

Il existe une sémantique constructive dans laquelle :

```text
identité stricte
⊆
identité projetée
⊊
usage relaxé,
```

et dans laquelle le gap courant détermine causalement une transition stable.

#### Résultat constructif fermé

Il existe une instance non triviale et entièrement calculable où :

```text
gapₙ
→ usageₙ
→ requêteₙ
→ réponseₙ
→ réparationₙ
→ étatₙ₊₁
```

est une égalité de programme, où les réparations antérieures persistent, et où
les gaps successifs sont séparés.

#### Résultat empirique causal

Un système appris réalise cette architecture sur des observations non
symboliques. Son succès disparaît ou se transforme de la manière prédite quand
on intervient sur le gap, l'usage, la requête, la réponse ou la réparation.

#### Résultats informationnels et comparatifs

Deux impossibilités exactes doivent être prouvées sur des classes définies :

```text
une politique passive recevant la même vue ne sépare pas une paire aliasée ;

un contrôleur dont toutes les décisions factorisent par le même visible
ne ferme pas une paire exigeant des actions incompatibles sous le budget fixé.
```

Séparément, l'expérience doit montrer que les baselines effectivement
implémentées n'atteignent pas la même fermeture sous des budgets appariés :

```text
lectures marginales passives ;
mémoires sans requête ;
agents actifs sans gap typé ;
agents avec réparation externe ;
contrôleurs visibles factorisés.
```

La première partie est un no-go mathématique borné. La seconde est une
comparaison empirique, pas une impossibilité universelle.

### 1.2 Ce qui ne doit pas être revendiqué

La validation ne démontrera pas à elle seule :

```text
une intelligence générale ;
une conscience ;
une compréhension sémantique universelle ;
la supériorité sur tout agent actif ;
la vérité d'un schéma infini par énumération finie ;
la correction universelle d'un réseau neuronal hors des états vérifiés.
```

Elle peut démontrer un résultat plus précis et plus défendable :

> Une architecture de régulation par gaps typés peut être formalisée,
> exécutée, apprise et causalement vérifiée sans réduire son transport à
> l'identité ni sa dynamique à une transition extérieure.

### 1.3 Enoncé opérationnel exact

L'énoncé que le programme complet doit valider est :

> Un agent peut détecter une non-coïncidence locale, en dériver lui-même un
> droit d'interrogation, obtenir l'information pertinente, appliquer une
> réparation intrinsèque, conserver les réparations antérieures et poursuivre
> cette dynamique, alors qu'aucun système passif ou purement projectif de
> capacité comparable ne peut réaliser la même fermeture.

Cet énoncé n'est accepté qu'avec les définitions restrictives données ci-dessous.
Sans elles, chacune de ses expressions admet une lecture triviale ou trop forte.

### 1.4 Décomposition en obligations indépendantes

#### Détecter une non-coïncidence locale

« Détecter » signifie produire depuis `AgentView` un objet opérationnel
contenant un indice et une évidence observable. Cela ne signifie pas accéder
directement à la vérité cachée. Le vérificateur sémantique doit ensuite établir :

```text
soundness : gap détecté → mismatch réel ;
completeness : mismatch admissible → gap détectable ;
localization : l'indice annoncé est celui du mismatch ;
calibration : la confiance annoncée correspond aux fréquences observées.
```

Dans l'instance constructive, soundness et completeness sont des théorèmes.
Dans l'agent appris, elles sont des obligations mesurées et certifiées sur les
domaines finis évalués.

#### Dériver un droit d'interrogation

Le droit n'est ni une action libre ni une étiquette de supervision renommée.
Il est une donnée `Use` calculée depuis :

```text
séparation
+ coordination
+ évidence du gap
+ règle d'admissibilité du contexte.
```

La requête doit être calculée depuis ce droit. Une tête de requête possédant un
chemin direct depuis le monde, la cible ou une action oracle invalide la chaîne.

#### Obtenir une information pertinente

Une réponse est pertinente si elle satisfait au moins une propriété d'effet
formelle et une propriété contrefactuelle :

```text
effet formel :
  la réponse permet de construire un patch qui ferme le gap courant ;

effet contrefactuel :
  remplacer la réponse par une réponse incompatible change le patch
  ou fait échouer son certificat ;

effet informationnel :
  la réponse réduit strictement la fibre des mondes encore compatibles
  avec la vue et l'historique.
```

Une réponse corrélée avec la cible mais ignorée par le patch n'est pas
pertinente au sens de la théorie.

#### Appliquer une réparation intrinsèque

Une réparation est intrinsèque si :

```text
elle est calculée par le système depuis gap, usage et réponse ;
elle n'accède pas à SemanticWorld ;
elle est un programme syntaxique rejouable ;
son exécution est l'unique définition de l'état suivant ;
son effet de correction est démontré après exécution ;
elle change effectivement la candidate lorsque le gap est ouvert.
```

Le simple paquet `recovered = formed`, un jeton `Unit` ou un `next` fourni
séparément ne satisfait pas cette obligation.

#### Conserver les réparations antérieures

La conservation ne signifie pas seulement garder une liste dans `history`.
Après chaque transition, le vérificateur doit réévaluer tous les indices déjà
fermés :

```text
∀ i ∈ repairedBefore(stateₙ),
  Agrees(
    interpret(candidateₙ₊₁, i),
    evaluate(world, i)).
```

La provenance des patches doit également rester disponible. Une mémoire qui
contient l'ancien patch mais dont la candidate recommence à échouer ne conserve
pas la réparation.

#### Poursuivre la dynamique

Dans le cas fini, poursuivre signifie fermer successivement les gaps jusqu'à
un état stable. Dans le cas ouvert, cela signifie produire à tout rang fini un
nouveau gap tout en conservant le préfixe réparé. Un paramètre statique du rendu
ou plusieurs évaluations indépendantes ne constituent pas une dynamique.

#### Réfuter les alternatives

Cette clause se divise impérativement en trois résultats :

```text
no-go passif informationnel ;
no-go d'un contrôleur exactement factorisé par le visible ;
supériorité empirique sur un ensemble déclaré de baselines comparables.
```

Ces résultats ne sont pas interchangeables.

### 1.5 Portée exacte de « purement projectif »

Le théorème existant :

```text
not_exactProjective_of_asymmetric_use
```

concerne `HasUse` dans un régime fixé. Il prouve qu'un usage asymétrique ne peut
pas être exactement équivalent à une égalité de projections. Comme le précise
`StrictRelaxation.lean`, ce n'est pas une comparaison de la puissance totale de
formalismes sans relation entre eux.

Le document interdit donc la conclusion non bornée :

```text
aucune architecture utilisant une projection ne peut résoudre la tâche.
```

Une architecture peut enrichir son état, multiplier les requêtes ou ajouter
une mémoire jusqu'à simuler le comportement. La cible formelle supplémentaire
doit porter sur une classe définie :

```lean
structure VisibleFactoredClosureController where
  queryFromVisible : VisibleState → Query
  patchFromVisibleResponse :
    VisibleState → Response → CandidatePatch
  queryAt : FullState → Query
  queryAt_eq :
    ∀ state,
      queryAt state = queryFromVisible (visibleState state)
  patchAt : FullState → Response → CandidatePatch
  patchAt_eq :
    ∀ state response,
      patchAt state response =
        patchFromVisibleResponse (visibleState state) response
```

Le no-go attendu est :

```text
deux états exigent des requêtes ou patches incompatibles
+ leurs états visibles et historiques visibles sont égaux
+ le budget interdit d'interroger toutes les branches
→
aucun VisibleFactoredClosureController ne ferme les deux.
```

Ce théorème de politique factorisée est distinct de la stricte relaxation de
`HasUse`. Les deux doivent être présents dans la validation finale.

### 1.6 Portée exacte de « capacité comparable »

La capacité n'est pas le seul nombre de paramètres. Le vecteur de ressources
est :

```text
R = (
  paramètres entraînables,
  bits d'état persistant,
  cardinalité ou dimension du médiateur,
  nombre de requêtes,
  bits reçus par réponse,
  FLOPs d'inférence,
  FLOPs d'entraînement,
  nombre d'exemples,
  accès aux modalités,
  horizon autorisé
).
```

Une baseline est appariée si elle reçoit les mêmes informations initiales et
n'a pas un budget strictement inférieur sur une dimension pertinente sans que
cette différence soit explicitement étudiée. Les résultats doivent être
rapportés sur plusieurs budgets et sous forme de frontière de Pareto.

La formulation statistique autorisée est :

> Aucun système de la classe de baselines exécutée, sous les budgets déclarés,
> n'atteint la même fermeture.

La formulation universelle « aucun système imaginable de capacité comparable »
n'est pas autorisée par une campagne finie.

## 2. Frontière avec le résultat empirique v22

Le dossier `Empirical/v22_aslmt_perceptual_localglobal_dynamic_infinite` est un
résultat historique. Il doit être conservé inchangé avec son exécution figée :

```text
Empirical/
  aslmt_v22_perceptual_localglobal_dynamic_infinite_20260510_013011_c338ee97f453
```

Il fournit déjà :

```text
deux lectures marginales insuffisantes ;
une représentation médiatrice nécessaire ;
une requête active ;
une réponse environnementale discriminante ;
une reconstruction perceptuelle réussie ;
un seuil empirique z = n ;
des certificats structuraux finis ;
des checkpoints et artefacts liés par hash.
```

Il ne valide pas encore la chaîne intégrale. Les limites suivantes sont des
obligations de correction, pas des détails éditoriaux.

### 2.1 Défaut du certificat minimal

Le certificat actuel transmet directement `k_fixed` comme bit de réponse dans
une partie du test minimal, au lieu de recalculer la véritable réponse :

```text
response = environment(h, k, action).
```

Pour les collisions de politiques opposées et `k = 1`, les deux réponses
réelles peuvent différer. L'identité prétendue des entrées complètes du
décodeur n'est alors pas établie.

La version corrigée doit fixer `k = 0`, ou prouver une autre condition interne
qui rende la réponse réelle identique pour les deux états. Le vérificateur doit
toujours recalculer la réponse par la fonction d'environnement.

### 2.2 Politique de requête trop simple

La politique décrite comme xorshift coïncide exactement, sur les huit valeurs
utilisées, avec la parité :

```text
0, 1, 0, 1, 0, 1, 0, 1.
```

Le prochain protocole doit employer une table équilibrée explicitement
non réductible à la parité, au seuil, à un bit isolé ou à une permutation
affine évidente sur le domaine testé.

### 2.3 OOD non tenu à l'écart de l'entraînement

Le run v22 utilise un ratio OOD d'entraînement non nul. Le régime nommé OOD est
donc une seconde distribution d'entraînement. La validation intégrale doit
réserver des familles structurelles entièrement absentes :

```text
aucun exemple d'entraînement ;
aucune perte auxiliaire ;
aucun réglage d'hyperparamètre ;
aucune sélection de checkpoint ;
aucun choix de seuil sur ces familles.
```

### 2.4 Supervision architecturale forte

Le latent, l'action de requête et plusieurs obligations structurales sont
directement supervisés. Cela valide une architecture capable d'exécuter le
mécanisme, mais pas encore l'émergence du mécanisme depuis sa seule valeur
causale.

La nouvelle expérience doit séparer :

```text
un régime supervisé de contrôle ;
un régime faiblement supervisé ;
un régime où requête et réparation sont apprises depuis la réussite finale.
```

### 2.5 Paramètre de rendu et temps dynamique

Le paramètre `t` du rendu actuel modifie une géométrie statique. Il ne
constitue pas une orbite d'états :

```text
stateₙ → gapₙ → repairₙ → stateₙ₊₁.
```

La validation dynamique doit enregistrer des transitions réellement produites
par les réparations successives.

### 2.6 Pont déclaratif

Le pont actuel vérifie principalement la cohérence d'un schéma JSON et de
chaînes attendues. Il ne dérive pas son universalité depuis le moteur, le
modèle ou une preuve Lean.

Le nouveau pont doit être supprimé comme source de vérité. Les propriétés
doivent être recalculées depuis :

```text
les définitions exécutables ;
les traces brutes ;
les poids liés par hash ;
et les théorèmes constructifs.
```

### 2.7 Certificat Lean axiomatique

Le certificat v22 contient des déclarations `axiom`. Il est un schéma de
traçabilité, pas une preuve compatible avec les exigences du projet.

La validation intégrale exige un certificat Mode B : données finies réifiées,
prédicats décidables, preuves calculées et audit final sans axiome.

### 2.8 Contextes fournis au vérificateur

Les vérificateurs v22 recalculent des sorties sur les contextes présents dans
les certificats, mais ne reconstruisent pas systématiquement la liste canonique
complète depuis les seeds de campagne. Une liste sélectionnée pourrait donc
passer les calculs locaux sans représenter le protocole annoncé.

Le vérificateur v23 doit dériver lui-même la liste attendue, puis exiger égalité
de longueur, d'ordre, de multiplicité et de contenu avant toute métrique.

### 2.9 Paramètres déclarés mais non consommés

Des paramètres du protocole v22, notamment des réglages de ratio ou de poids,
ne contrôlent pas tous le calcul annoncé. Le protocole v23 doit instrumenter la
consommation de chaque champ de configuration :

```text
champ déclaré
→ composant qui le lit
→ valeur effective dans le run
→ présence dans le manifeste.
```

Un argument CLI inutilisé, écrasé silencieusement ou absent du manifeste est
une erreur bloquante.

### 2.10 Familles d'entraînement et familles de certification

Les pertes structurales v22 entraînent déjà le modèle sur une famille proche de
celle que le vérificateur structural évalue. Cela démontre l'acquisition des
obligations supervisées, mais pas leur généralisation à de nouvelles familles
d'obligations.

Le protocole v23 doit séparer :

```text
familles de pertes d'entraînement ;
familles de validation structurelle ;
familles de certification scellées.
```

Le générateur de certificats scellés ne peut pas être importé par le code
d'entraînement.

### 2.11 Echec de baseline et impossibilité

Une baseline entraînée avec une perte qui s'effondre vers une sortie constante
peut obtenir un score nul sans que ce score constitue un no-go mathématique.
La validation v23 doit donc distinguer :

```text
borne exacte issue d'une collision informationnelle ;
meilleure performance obtenue après réglage équitable ;
diagnostic d'optimisation de chaque baseline.
```

Le no-go ne dépend jamais du fait qu'un U-Net particulier a convergé vers zéro.

## 3. Contraintes non négociables

### 3.1 Constructivité Lean

Tout nouveau fichier Lean doit respecter :

```text
aucun axiom ;
aucun sorry ou admit ;
aucun Classical ;
aucun propext ;
aucun Quot.sound ;
aucun noncomputable ;
aucun unsafe ;
un unique bloc AXIOM_AUDIT à la fin.
```

Une propriété de fermeture ne peut pas être remplacée par une hypothèse
externe `windowFor`, `actualReducts`, `rank`, pont terminal ou adaptateur final.

### 3.2 Non-trivialité

L'instance de validation ne peut pas être fermée par :

```text
Visible := Unit ;
project := fonction constante ;
Gap := Unit ;
Use := Unit ;
Repair := Unit ;
Witness := Unit ;
OutRel := Use par définition ;
next := fonction fournie séparément ;
False.elim ;
Complete := Forward := Backward := Intersection ;
une table contenant déjà la sortie attendue du vérificateur.
```

Elle doit posséder au minimum :

```text
plusieurs états sémantiques ;
plusieurs candidats syntaxiques ;
plusieurs indices visibles ;
une projection non constante ;
au moins une fibre non triviale ;
des gaps preuve-pertinents ;
des usages orientés ;
des réponses dépendant réellement de l'action ;
des réparations modifiant réellement le candidat ;
des lectures de sortie distinctes des usages ;
une orbite d'au moins trois transitions ;
des états successifs séparés ;
une généralisation tenue à l'écart de l'entraînement.
```

Les familles introduites plus loin :

```text
GapEvidence ;
UseEvidence ;
RepairDerivedFrom ;
RepairProvenance ;
QueryAdmissible
```

ne peuvent pas être `Unit` sous un autre nom. L'instance doit exhiber deux
gaps dont les évidences sont distinguables, deux usages orientés distinguables,
et deux réponses induisant des patches distinguables. Les fonctions `query` et
`buildRepair` doivent être non constantes sur ces témoins.

### 3.3 Intrinsécité causale

La transition doit être définitionnellement issue du statut de gap courant.
La détection ne reçoit que la vue de l'agent :

```text
statusₙ := detectGap(agentView(stateₙ))

si statusₙ = closed :
  stateₙ₊₁ := stateₙ

si statusₙ = open gapₙ :
  useₙ       := authorize(gapₙ)
  queryₙ     := selectQuery(gapₙ, useₙ)
  responseₙ  := environment(stateₙ.world, queryₙ)
  repairₙ    := buildRepair(
                  agentView(stateₙ),
                  gapₙ,
                  useₙ,
                  responseₙ)
  stateₙ₊₁   := executeRepair(stateₙ, repairₙ).
```

Il est interdit de définir d'abord :

```text
next : State → State
```

puis de construire après coup un gap qui décrit cette transition.

### 3.4 Séparation syntaxe-sémantique

La syntaxe et la sémantique doivent être des types ou structures distincts :

```text
SemanticWorld
Candidate
VisibleIndex
```

La candidate ne doit pas être une fonction sémantique arbitraire contenant
déjà la vérité du monde. Son interprétation doit passer par une fonction
explicite :

```text
interpret : Candidate → VisibleIndex → Prediction.
```

La vérité locale doit venir de :

```text
evaluate : SemanticWorld → VisibleIndex → Target.

Agrees : Prediction → Target → Prop.
```

`Agrees` est une relation constructive et calculable dans l'instance finie. Elle
permet notamment une candidate partielle avec `Prediction := Option Target`.
Le gap compare ces deux lectures sur un indice commun sans identifier le monde
et la candidate.

### 3.5 Frontière d'information

Le système global connaît le monde afin de produire les observations et de
vérifier les effets. L'agent ne reçoit qu'une projection explicite :

```text
agentView : ClosedState → AgentView.
```

Les fonctions suivantes ne peuvent prendre ni `SemanticWorld`, ni
`ClosedState` comme argument :

```text
detectGap ;
authorize ;
selectQuery ;
buildRepair ;
executeCandidatePatch.
```

Seules les fonctions environnementales et les théorèmes de correction peuvent
consommer le monde :

```text
observe ;
respond ;
evaluate ;
validateGap ;
proveRepairEffect.
```

Cette frontière doit être visible dans les types Lean, dans les signatures
Python et dans les tenseurs réellement transmis au modèle. Une convention
documentaire disant que le réseau « ignore » un champ présent dans son entrée
n'est pas acceptable.

### 3.6 Immutabilité et traçabilité Python

Les scripts v22 et les runs cités restent immuables. Toute correction ou
extension est créée dans un nouveau dossier et de nouveaux fichiers.

Chaque run scientifique doit :

```text
exécuter une copie figée du script ;
inclure timestamp et SHA-256 dans son nom ;
propager le même suffixe aux sorties ;
enregistrer la commande complète ;
enregistrer versions, seed, plateforme et dépendances ;
lier chaque checkpoint et certificat par hash.
```

Les smoke tests écrivent uniquement dans `/tmp` ou dans des sorties nommées
explicitement `smoke`.

## 4. Objet mathématique de validation

### 4.1 Etat de l'agent et état fermé

L'état manipulable par l'agent et le monde fermé doivent être séparés :

```lean
structure AgentClosureState where
  candidate : Candidate
  observation : Observation
  history : List ClosedGapRecord

structure ActiveSemanticClosureState where
  world : SemanticWorld
  agent : AgentClosureState
```

La projection :

```text
agentView : ActiveSemanticClosureState → AgentClosureState
```

oublie définitionnellement `world`. `candidate` est syntaxique et modifiable.
`history` n'est pas une source de vérité cachée : il conserve uniquement les
actions, réponses et réparations déjà exécutées.

### 4.2 Gap opérationnel et témoin sémantique

Le gap utilisé par l'agent doit être distinct de son certificat sémantique.
L'agent produit :

```lean
structure OperationalGap
    (view : AgentClosureState) where
  index : VisibleIndex
  proposedQueryClass : QueryClass
  observableEvidence : GapEvidence view index
```

Le système fermé et le vérificateur établissent ensuite :

```lean
structure TypedSemanticGap
    (state : ActiveSemanticClosureState)
    (operational : OperationalGap state.agent) where
  semanticPole : Interface
  syntacticPole : Interface
  semantic_projects :
    project semanticPole = operational.index
  syntactic_projects :
    project syntacticPole = operational.index
  separated :
    semanticPole = syntacticPole → False
  mismatch :
    Agrees
      (interpret state.agent.candidate operational.index)
      (evaluate state.world operational.index) → False
```

Le champ `mismatch` localise la non-coïncidence. Il ne contient pas `False` et
ne rend pas l'état incohérent. Dans l'instance constructive fermée, la détection
produit toujours un gap sémantiquement certifié. Dans l'expérience apprise, le
certificat est recalculé par le vérificateur et peut échouer.

Le statut de détection doit distinguer explicitement :

```lean
inductive OperationalGapStatus
    (view : AgentClosureState) where
  | closed
  | open (gap : OperationalGap view)
```

Un théorème de correction séparé relie `closed` à la correction globale sur le
domaine fini. Le constructeur `closed` ne porte pas cette vérité par simple
nomination.

### 4.3 Usage dérivé

L'usage doit conserver sa provenance :

```lean
structure GapAuthorizedUse
    (view : AgentClosureState)
    (gap : OperationalGap view) where
  direction : UseDirection
  evidence : UseEvidence view gap direction
  queryAdmissible : QueryAdmissible view gap.index direction
```

Le théorème sémantique correspondant consomme le témoin de validité du gap et
reconstruit :

```text
separation := semanticGap.separated
coordination :=
  semanticGap.semantic_projects.trans
    semanticGap.syntactic_projects.symm.
```

`UseDirection` doit contenir au moins une direction non inversible. Un théorème
doit réfuter l'usage inverse et déclencher le critère générique de
non-représentabilité projective exacte.

### 4.4 Requête et réponse

La requête est calculée depuis l'usage :

```text
Query : VisibleIndex → Type

query :
  GapAuthorizedUse view gap →
  Query gap.index
```

La réponse est calculée par l'environnement fermé :

```text
Response : VisibleIndex → Type

respond :
  (world : SemanticWorld) →
  (query : Query index) →
  Response index.
```

Elle ne doit pas être stockée dans le gap avant l'exécution de la requête.
L'agent ne reçoit jamais directement la variable sémantique cachée.

La réponse vient de l'environnement, mais elle n'est pas une externalité au sens
du système fermé : `SemanticWorld` et `respond` appartiennent à l'instance
complète. Aucun humain, oracle de test ou fonction ajoutée après coup ne choisit
la réponse. Si l'environnement est stochastique, son seed et son état aléatoire
sont des composantes explicites du monde fermé et de la provenance de trace.

### 4.5 Réparation intrinsèque

La réparation calculée par l'agent est un programme syntaxique avec provenance.
Elle ne reçoit pas `world` et ne contient pas comme champ libre la conclusion
sémantique qu'elle doit produire :

```lean
structure IntrinsicRepair
    (view : AgentClosureState)
    (gap : OperationalGap view)
    (use : GapAuthorizedUse view gap)
    (response : Response gap.index) where
  patchedCandidate : Candidate
  responseUsed : RepairDerivedFrom response patchedCandidate
  provenance : RepairProvenance view gap use response patchedCandidate
```

La fonction :

```text
buildRepair :
  (view : AgentClosureState) →
  (gap : OperationalGap view) →
  (use : GapAuthorizedUse view gap) →
  (response : Response gap.index) →
  IntrinsicRepair view gap use response
```

doit utiliser la réponse. Une réparation indépendante de la réponse échoue au
test de causalité.

Les effets sémantiques sont des théorèmes, pas des entrées du constructeur :

```text
buildRepair_closesCurrentGap ;
buildRepair_preservesRepairedHistory.
```

Leur preuve peut utiliser `state.world`, le témoin sémantique du gap et la loi
de correction de `respond`. La fonction calculant le patch, elle, ne le peut
pas.

### 4.6 Transition

La seule transition admise est une analyse du statut opérationnel :

```text
nextState state =
  match detectGap state.agent with
  | closed =>
      state
  | open gap =>
      let use := authorize state.agent gap
      let request := query use
      let response := respond state.world request
      let repair :=
        buildRepair state.agent gap use response
      executeRepair state repair
```

`executeRepair` doit être une enveloppe qui conserve le monde et appelle une
fonction agent-side :

```text
executeRepair state repair =
  { world := state.world
    agent := executeAgentRepair state.agent repair }
```

Prouver :

```text
(nextState state).world = state.world.
```

Ainsi le monde peut produire la réponse, mais l'exécuteur du patch ne peut pas
le consulter pour fabriquer la candidate suivante.

Des lemmes séparés doivent exposer chaque égalité de provenance afin que le
vérificateur et les tests d'intervention puissent viser chaque maillon.

### 4.7 Définition de la fermeture

Le mot « fermeture » doit désigner des prédicats explicites :

```lean
def CorrectAt
    (world : SemanticWorld)
    (candidate : Candidate)
    (index : VisibleIndex) : Prop :=
  Agrees (interpret candidate index) (evaluate world index)

def ClosedOn
    (world : SemanticWorld)
    (candidate : Candidate)
    (domain : List VisibleIndex) : Prop :=
  ∀ index, index ∈ domain → CorrectAt world candidate index

def GloballyClosed
    (world : SemanticWorld)
    (candidate : Candidate) : Prop :=
  ∀ index, CorrectAt world candidate index
```

Pour le domaine fini, la cible est `ClosedOn` sur le domaine canonique complet.
Pour l'orbite ouverte, la cible n'est jamais une fausse fermeture globale :

```text
ClosedOn world candidateₙ repairedPrefixₙ
+
¬ CorrectAt world candidateₙ currentIndexₙ.
```

Deux systèmes réalisent « la même fermeture » seulement s'ils sont évalués sur
le même monde, la même candidate initiale, le même domaine, le même budget
d'interaction et le même prédicat `ClosedOn`. Une métrique approximative égale
ne suffit pas.

### 4.8 Graphe causal autorisé

Le système doit publier ses équations structurelles :

```text
Oₙ = observe(W, Aₙ)
Gₙ = detectGap(Aₙ, Oₙ)
Uₙ = authorize(Aₙ, Gₙ)
Qₙ = selectQuery(Aₙ, Gₙ, Uₙ)
Rₙ = respond(W, Qₙ)
Pₙ = buildRepair(Aₙ, Gₙ, Uₙ, Rₙ)
Aₙ₊₁ = executeRepair(Aₙ, Pₙ).
```

où `W` est le monde et `Aₙ` l'état de l'agent. Les seules arêtes directes
depuis `W` sont :

```text
W → Oₙ ;
W → Rₙ ;
W → validation externe.
```

Les chemins suivants sont interdits dans le modèle validé :

```text
W → Gₙ ;
W → Uₙ ;
W → Pₙ ;
target → Qₙ ;
target → Pₙ ;
Aₙ → Aₙ₊₁ en contournant Pₙ ;
Oₙ → Qₙ en contournant Gₙ et Uₙ dans la variante causale stricte.
```

La dépendance syntaxique dans le graphe de calcul ne suffit pas. Pour chaque
arête revendiquée, il faut au moins une paire d'interventions valides montrant
un effet observable. Pour chaque chemin interdit, un audit de flux de données
et une ablation doivent montrer son absence.

### 4.9 Sémantique des interventions

Les interventions ne doivent pas créer silencieusement un objet mal typé. Une
intervention sur un gap remplace l'équation `Gₙ = detectGap(Aₙ, Oₙ)` par une valeur
opérationnelle provenant d'un autre état compatible avec le même type. Les
étapes en aval sont ensuite recalculées ; elles ne sont pas copiées depuis la
trace d'origine.

Définir au minimum :

```text
runNatural state ;
runWithGap state intervenedGap ;
runWithQuery state intervenedQuery ;
runWithResponse state intervenedResponse ;
runWithPatch state intervenedPatch.
```

Chaque variante partage le monde, la candidate et le bruit contrôlé pertinents.
Cette sémantique évite d'appeler « causal » un simple mélange de sorties issues
d'épisodes différents.

## 5. Deux instances constructives requises

### 5.1 Fermeture finie

La première instance possède un domaine fini de challenges. Elle doit prouver :

```text
chaque étape ferme le gap courant ;
toute réparation antérieure persiste ;
le nombre de gaps ouverts décroît strictement ;
la fermeture est atteinte en au plus N étapes ;
aucune transition n'est possible après fermeture ;
la candidate finale est correcte sur tout le domaine fini.
```

Ce modèle valide la notion de clôture locale cumulée.

« Aucune transition » signifie ici :

```text
detectGap view = closed
→
nextState state = state.
```

Le système reste total sans inventer un faux gap terminal.

### 5.2 Orbite ouverte

La seconde instance possède une famille de challenges indexée par `Nat`. Elle
doit prolonger la géométrie déjà prouvée dans
`Meta/Tarski/ConstructivePatchOrbit.lean` :

```text
à tout rang fini, tous les gaps antérieurs sont réparés ;
un nouveau gap est produit ;
les indices successifs sont distincts ;
les candidats successifs sont distincts ;
aucune période positive ne ramène au même candidat ;
aucune étape finie ne prétend énumérer ou fermer l'infini.
```

Ce modèle valide une régulation ouverte sans confondre préfixe fini et preuve
par exhaustion infinie.

## 6. Théorèmes Lean requis

Créer une spécialisation en aval du Core, sans import inverse depuis le Core :

```text
Meta/AI/
  ActiveSemanticClosure.lean
  FiniteActiveSemanticClosure.lean
  OpenActiveSemanticClosure.lean
  VisibleFactoredClosureNoGo.lean
  CertifiedInference.lean
  EmpiricalTraceSchema.lean
  EmpiricalTraceVerifier.lean
  AIFoundationalValidation.lean
```

Le nom exact du dossier peut être ajusté avant l'implémentation, mais la
séparation générique/spécialisation est obligatoire.

Graphe d'import cible :

```text
Meta.Core.ProjectiveCore
Meta.Core.StrictRelaxation
Meta.Core.DynamicRelaxedUsage
Meta.Semantics.DynamicFoundationalStability
        |
        v
Meta.AI.ActiveSemanticClosure
        |
        +------------------------------+
        |                              |
        v                              v
Meta.AI.FiniteActiveSemanticClosure  Meta.AI.OpenActiveSemanticClosure
        |                              |
        v                              |
Meta.AI.VisibleFactoredClosureNoGo     |
        |                              |
        +---------------+--------------+
                        |
                        v
              Meta.AI.EmpiricalTraceSchema
                        |
                        v
              Meta.AI.CertifiedInference
                        |
                        v
              Meta.AI.EmpiricalTraceVerifier

Meta.Semantics.FoundationalStability
        |
        +------------------------------+
                                       v
                         Meta.AI.AIFoundationalValidation
                                       ^
                                       |
                         Meta.AI.EmpiricalTraceVerifier
```

Le raccord à `Meta.Tarski.ConstructivePatchOrbit` appartient à
`OpenActiveSemanticClosure.lean` ou à un fichier de spécialisation dédié. Il ne
doit pas forcer toute l'API IA générique à dépendre de Tarski.

### 6.1 Noyau de spécialisation

`ActiveSemanticClosure.lean` doit définir l'instance de synthèse entre :

```text
RelaxedInterfaceRegime
CompositionalTransport
GapRepairAlgebra
GapDrivenDynamicSystem.
```

Le certificat final `AIFoundationalValidation.lean` combine ensuite cette
spécialisation avec `generalRelaxedFoundationalSemantics`. Cette combinaison est
en aval et ne modifie pas la sémantique générale déjà fermée.

Déclarations principales attendues :

```text
ActiveSemanticClosureState
AgentClosureState
OperationalGap
OperationalGapStatus
TypedSemanticGap
GapAuthorizedUse
IntrinsicRepair
ActiveSemanticClosureSystem
CorrectAt
ClosedOn
VisibleFactoredClosureController
activeSemanticClosure_next_eq_executeRepair
activeSemanticClosure_nonProjective
activeSemanticClosure_transportCoherent
```

### 6.2 Théorèmes de causalité structurelle

Prouver :

```text
gap différent sous hypothèses discriminantes
→ requête différente ;

réponse différente sous requête informative
→ réparation différente ;

réparation différente et effective
→ état suivant différent ;

absence de gap
→ stabilité ;

présence d'un gap
→ transition effective ;

fermeture du gap courant
→ persistance de la séparation des pôles ;

usage avant → après existe ;
usage après → avant est réfuté ;

aucune ExactProjectiveRepresentation du régime d'usage.
```

La causalité ne doit pas être attestée uniquement par le fait que la fonction
`next` reçoit un argument appelé `gap`. Il faut un théorème d'effet observable.

Ajouter également les égalités d'équations structurelles :

```text
detectedGap_eq_detectGap ;
authorizedUse_eq_authorize ;
selectedQuery_eq_selectQuery ;
environmentResponse_eq_respond ;
builtRepair_eq_buildRepair ;
nextAgent_eq_executeRepair.
```

Elles établissent la provenance ; les théorèmes de sensibilité établissent
l'effectivité. Les deux niveaux sont nécessaires.

### 6.3 Lois de transport

Prouver dans l'instance :

```text
transport de l'identité ;
composition de deux usages ;
composition des transports associés ;
associativité ;
naturalité sous changement de contexte admissible ;
préservation des jugements déjà réparés ;
absence de transport vers une lecture non autorisée.
```

`OutRel` doit exprimer une relation sémantique sur les sorties et ne doit pas
être définitionnellement identique à `Use`.

### 6.4 Non-réduction

L'instance doit satisfaire simultanément :

```text
non-fidélité de la projection ;
non-reconstruction globale depuis le visible ;
non-représentabilité projective exacte de l'usage ;
non-réduction de la sémantique au graphe d'usage ;
conservativité du fragment identitaire ;
consistance du calcul de transport.
```

### 6.5 No-go passif et no-go de factorisation visible

Définir séparément :

```text
PassiveClosurePolicy
VisibleFactoredClosureController
SameInitialInformation
IncompatibleRequiredRepairs
ResourceBudget
```

Le no-go passif doit partir d'une paire explicite :

```text
state₀ ≠ state₁ ;
agentView₀ = agentView₁ ;
requiredClosure₀ ≠ requiredClosure₁.
```

Pour toute politique déterministe sans interaction, la sortie est la même sur
les deux vues ; elle ne peut donc fermer les deux états.

Pour une politique randomisée, modéliser d'abord le seed comme une entrée
explicite. A seed commun fixé, le même no-go déterministe s'applique. Sur une
paire équiprobable exigeant des sorties disjointes, le taux de succès moyen est
au plus `1/2`. Si aucune bibliothèque probabiliste constructive adaptée n'est
disponible, la partie Lean peut prouver le résultat seed-par-seed et le
vérificateur fini calcule la borne moyenne.

Le no-go projectif doit utiliser deux états ayant :

```text
même visible ;
même historique visible ;
requêtes initiales nécessaires incompatibles ;
budget d'une requête ;
réponse neutre ou non informative pour la mauvaise requête.
```

Prouver alors qu'un contrôleur dont requête et patch factorisent exactement par
ce visible ne ferme pas les deux états. Ce théorème ne doit pas être obtenu par
simple réutilisation de `not_exactProjective_of_asymmetric_use` : il porte sur
la fermeture de tâche, tandis que ce dernier porte sur la représentation de
`HasUse`.

La randomisation ne restaure pas une garantie de fermeture : à seed commun, le
contrôleur choisit la même action sur les deux visibles égaux. Sur la paire
équiprobable et sous le budget d'une requête, calculer également le meilleur
taux moyen atteignable par la classe factorisée.

### 6.6 Correction de la détection et de la fermeture

Prouver dans l'instance finie :

```text
detectedGap_sound ;
detectedGap_complete ;
detectedGap_index_correct ;
closedStatus_sound ;
repair_closes_detectedGap ;
repair_preserves_closedPrefix ;
finiteOrbit_reachesClosedOn ;
openOrbit_preservesPrefix ;
openOrbit_hasFreshMismatch.
```

Les théorèmes de l'orbite ouverte doivent réutiliser
`constructiveTarskiOrbitTheorem` lorsqu'ils parlent de l'instance Tarski. Une
nouvelle instance IA peut avoir sa propre preuve, mais ne doit pas renommer la
preuve Tarski comme si elle certifiait les poids appris.

### 6.7 Audit

Chaque fichier possède exactement un bloc final :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms activeSemanticClosureSystem
/- AXIOM_AUDIT_END -/
```

L'audit doit afficher zéro axiome inattendu et ne mentionner ni `Classical`, ni
`propext`, ni `Quot.sound`.

## 7. Protocole expérimental v23

Créer un nouveau dossier, sans modifier les scripts v22 :

```text
Empirical/v23_gap_driven_active_semantic_closure/
```

Le protocole comporte un environnement de référence fini, une extension à
horizon variable et au moins une famille perceptuelle tenue hors entraînement.

### 7.1 Etat sémantique

Chaque épisode possède :

```text
world             état caché structuré ;
candidate₀        théorie syntaxique initiale partielle ;
visibleContext    observation non injective ;
challengeFamily   famille calculable de distinctions ;
```

Le monde doit contenir plusieurs facteurs indépendants. Au moins deux mondes
distincts doivent produire exactement la même observation initiale.

### 7.2 Candidate syntaxique

La candidate est une structure finie manipulable, par exemple :

```text
une liste de règles ;
une table partielle typée ;
un petit programme ;
un automate fini ;
une mémoire de faits avec provenance.
```

Elle ne contient pas directement le tenseur cible final et ne peut pas lire le
monde caché.

### 7.3 Détection du gap

Le système doit produire :

```text
un indice visible ;
deux pôles coordonnés ;
un score ou certificat local de mismatch ;
une provenance de la détection ;
```

Le protocole doit distinguer :

```text
gap de référence calculé par l'environnement ;
gap prédit par le modèle ;
gap effectivement utilisé pour l'action.
```

Cette distinction permet de mesurer séparément détection, décision et effet.

L'évidence opérationnelle doit être accessible à l'agent. Elle peut être :

```text
une prédiction localement réfutée par une observation ;
une règle manquante dans une candidate partielle ;
deux lectures accessibles incompatibles ;
une fibre de possibilités non singleton ;
une incertitude certifiée par le protocole.
```

Le seul fait que l'environnement ou le vérificateur connaisse un mismatch ne
constitue pas une détection par l'agent. Lorsque l'observation ne permet que de
détecter une sous-détermination, le gap opérationnel doit l'énoncer ainsi ; il
ne doit pas prétendre connaître la valeur sémantique encore cachée.

### 7.4 Requête active

L'espace des requêtes doit contenir :

```text
plusieurs actions informatives ;
des actions non informatives ;
des actions informatives pour un gap mais pas pour un autre ;
un coût explicite ;
```

La meilleure action ne doit pas être identifiable depuis un indice trivial ou
un seul bit constant du rendu.

### 7.5 Réponse environnementale

La réponse doit dépendre réellement du triplet :

```text
(world, gap concerné, query).
```

Le vérificateur recalcule la réponse. Aucun certificat ne peut fournir un bit
de réponse sans démontrer qu'il est égal à la fonction d'environnement.

### 7.6 Réparation

Le modèle produit une opération de patch sur la candidate. Le patch doit :

```text
modifier la candidate ;
fermer le gap ciblé ;
préserver les gaps déjà fermés ;
ne pas contenir le monde complet ;
être sérialisable et rejouable ;
```

Le prochain état est obtenu uniquement en exécutant ce patch.

### 7.7 Episode multi-étapes

Un épisode scientifique doit contenir au moins :

```text
trois gaps successifs ;
trois requêtes ;
trois réponses ;
trois réparations effectives ;
quatre candidats distincts.
```

Les horizons d'évaluation doivent dépasser ceux vus pendant l'entraînement.

### 7.8 Deux niveaux de tâche obligatoires

Une seule tâche de table finie serait insuffisante pour la revendication sur
l'IA. Le protocole doit contenir deux niveaux explicitement distingués.

#### Niveau A — Conformance finie exhaustive

Le monde est une petite structure finie entièrement énumérable. La candidate
est une théorie partielle de ce monde. Ce niveau sert à démontrer :

```text
concordance Lean/Python ;
exactitude des gaps ;
exactitude des réponses ;
exactitude des patches ;
fermeture et persistance ;
sensibilité des vérificateurs.
```

Une table partielle est acceptable ici parce que la finalité est la
conformance mécanique, pas la généralisation cognitive.

#### Niveau B — Règles compositionnelles perceptuelles

Le monde est généré par un petit langage de règles ou de programmes. Une
candidate est un objet syntaxique distinct : AST, automate ou ensemble de
règles avec provenance. Une observation est un rendu non injectif d'une
exécution. Une requête déclenche une intervention ou une expérience dont la
réponse est une trace partielle, et non l'étiquette finale directement donnée.

Le patch modifie une sous-structure de la candidate. Il doit pouvoir fermer
plusieurs occurrences relevant de la même règle tout en préservant les règles
déjà validées. Les partitions d'évaluation retiennent hors entraînement :

```text
des programmes ;
des profondeurs de composition ;
des ordres de règles ;
des horizons ;
des rendus perceptuels.
```

Ce niveau est obligatoire pour exclure l'interprétation :

```text
gap = adresse d'une case ;
query = lecture directe de la case ;
repair = écriture de la réponse dans la case.
```

### 7.9 Frontière d'accès instrumentée

Chaque tenseur et structure transmis au modèle doit être enregistré par nom,
forme, dtype et origine. Un audit automatique vérifie que :

```text
world n'est jamais dans les entrées du modèle ;
target n'est pas présent avant la réponse ;
les futures réponses ne sont pas dans history ;
le patch ne reçoit pas l'état suivant ;
la tête de requête ne reçoit pas une étiquette de requête cachée ;
les données OOD ne participent pas à la sélection.
```

Le test doit échouer si un canal interdit est ajouté, même sous un nom neutre.

### 7.10 Architecture de calcul contrainte

La variante validant la chaîne causale stricte doit avoir des modules séparés :

```text
gapEncoder      : AgentView → OperationalGapStatus ;
useConstructor  : AgentView → OperationalGap → GapAuthorizedUse ;
queryPolicy     : AgentView → OperationalGap → GapAuthorizedUse → Query ;
repairBuilder   : AgentView → OperationalGap → GapAuthorizedUse
                  → Response → IntrinsicRepair ;
repairExecutor  : Candidate → IntrinsicRepair → Candidate.
```

La candidate suivante est exactement la sortie de `repairExecutor`. Il n'existe
pas de tête parallèle `nextCandidate`. Les architectures plus libres peuvent
être étudiées comme baselines, mais elles ne certifient pas la causalité interne
de la théorie.

Les objets intermédiaires ont une représentation discrète ou symbolique
sérialisable. Un vecteur latent sans décodeur, sans champs vérifiables et sans
sémantique d'intervention ne suffit pas comme `OperationalGap`.

### 7.11 Non-constance et sensibilité minimales

Avant tout entraînement à grande échelle, construire des tests unitaires avec :

```text
deux vues produisant deux gaps distincts ;
deux gaps autorisant deux usages distincts ;
deux usages sélectionnant deux requêtes distinctes ;
deux réponses produisant deux patches distincts ;
deux patches produisant deux candidates distinctes.
```

Chaque module doit réussir son test de non-constance. Cela bloque les solutions
où les types sont riches mais où la fonction apprise ignore leur contenu.

## 8. Régimes d'apprentissage

Trois régimes sont nécessaires pour séparer capacité et découverte.

### 8.1 Contrôle entièrement supervisé

Superviser :

```text
gap ;
requête ;
réparation ;
état suivant.
```

Ce régime vérifie que l'architecture peut représenter et exécuter la chaîne.
Il ne suffit pas pour la revendication principale.

### 8.2 Supervision intermédiaire

Superviser le gap de référence mais pas la requête ni la réparation. Le modèle
apprend les actions depuis :

```text
réduction du mismatch ;
coût de requête ;
préservation des réparations antérieures ;
réussite finale.
```

### 8.3 Apprentissage causal final

Ne superviser directement ni la requête ni le patch. Les signaux autorisés
sont :

```text
observation ;
réponse à l'action choisie ;
évaluation locale après patch ;
coût de l'action ;
critère terminal ou cumulatif.
```

Le modèle doit encore produire des objets intermédiaires typés et auditables.
Une politique opaque qui atteint la cible sans exposer gap, usage et patch ne
valide pas la théorie, même si sa performance est élevée.

## 9. Interventions causales obligatoires

La causalité est testée par interventions contrôlées sur une trace identique.

### 9.1 Suppression du gap

```text
do(gap := absent)
```

Attendu : aucune réparation effective, ou transition explicite vers un état de
demande d'information. Le système ne doit pas inventer le patch attendu.

### 9.2 Permutation des gaps

```text
do(gap₁ := gap₂)
```

à monde, observation et candidate constants.

Attendu : la requête et la cible du patch suivent le gap permuté. Si elles
restent inchangées, le gap est décoratif.

### 9.3 Neutralisation de la requête

Remplacer l'action choisie par une action non informative.

Attendu : la réponse ne suffit plus à construire une réparation certifiée.

### 9.4 Permutation des réponses

Injecter la réponse valide d'un autre monde ou d'un autre gap.

Attendu : le patch change de manière prédite ou son certificat d'applicabilité
échoue. Une performance inchangée signale que la réponse est ignorée.

### 9.5 Neutralisation de la réparation

Exécuter un patch identité.

Attendu : le gap courant persiste et l'état suivant n'est pas déclaré fermé.

### 9.6 Permutation des réparations

Exécuter le patch d'un autre gap.

Attendu : le gap ciblé par ce patch peut changer, mais le gap courant ne doit
pas être déclaré fermé sans preuve.

### 9.7 Contournement direct

Fournir au décodeur final la réponse ou l'état caché en dehors de l'API de
réparation.

Ce test sert uniquement de plafond. Cette variante est exclue de la validation
principale et doit être marquée comme oracle.

### 9.8 Médiation causale

Mesurer séparément :

```text
effet du gap sur la requête ;
effet de la requête sur la réponse reçue ;
effet de la réponse sur le patch ;
effet du patch sur l'état suivant ;
effet total du gap sur la fermeture ;
effet résiduel quand le médiateur est fixé.
```

L'objectif n'est pas seulement une corrélation. Les interventions doivent
établir que les variables intermédiaires sont utilisées dans l'ordre annoncé.

### 9.9 Invariance des variables non intervenues

Pour chaque intervention, enregistrer les variables qui doivent rester fixes et
les comparer bit à bit lorsque le calcul est déterministe. Par exemple :

```text
do(gap := autreGap)
conserve : world, candidate, observation, seed de bruit ;
recalcule : use, query, response, patch, next.
```

Une intervention qui change simultanément le monde et le gap ne permet pas
d'attribuer l'effet au gap.

### 9.10 Recherche de chemins de contournement

En plus des ablations, entraîner des sondes et inspecter le graphe de calcul :

```text
la tête query ne reçoit que les tenseurs autorisés ;
la tête patch ne reçoit que candidate, gap, use et response ;
le décodeur de next exécute le patch au lieu de prédire next ;
aucune skip connection ne relie observation à next hors patch ;
aucun identifiant d'épisode ne code le monde ;
aucun ordre de batch ne code la cible.
```

Le protocole doit inclure un test synthétique où un canal de fuite est ajouté
volontairement et où l'audit le détecte. Sinon l'audit de frontière n'est pas
lui-même validé.

## 10. Bornes informationnelles

### 10.1 No-go marginal

Construire des paires d'états :

```text
s₀ ≠ s₁
observation(s₀) = observation(s₁)
target(s₀) ≠ target(s₁).
```

Tout reconstructeur déterministe depuis cette observation seule échoue sur au
moins un membre de chaque paire.

Pour un reconstructeur randomisé, fixer le même seed interne sur les deux états
réduit le problème au cas déterministe. Si les deux états sont équiprobables et
exigent des sorties disjointes, le succès moyen est au plus `1/2`. Toute autre
distribution doit annoncer sa borne optimale explicite.

### 10.2 No-go de capacité

Pour `n` classes sémantiques et un médiateur discret de capacité `z < n`, le
certificat doit :

```text
énumérer ou construire une collision par pigeonhole ;
fixer toutes les autres entrées du décodeur ;
recalculer la véritable réponse environnementale ;
prouver que les deux entrées complètes du décodeur sont identiques ;
prouver que les cibles diffèrent.
```

Dans la correction directe de v22, fixer `k = 0` neutralise la réponse pour
toute action et rend l'argument valide.

### 10.3 Suffisance active

Au seuil annoncé, démontrer ou vérifier exhaustivement que :

```text
observation
+ médiateur
+ réponse à la requête autorisée
```

suffisent à distinguer tous les états du domaine fini pertinent.

### 10.4 Composition des informations

Pour plusieurs gaps successifs, vérifier :

```text
la réponseₙ ferme gapₙ ;
elle ne contient pas directement toutes les réponses futures ;
les réponses cumulées suffisent au préfixe réparé ;
retirer une réponse antérieure détruit au moins une obligation persistante.
```

### 10.5 Fibre de mondes compatibles

Définir constructivement, sur le domaine fini :

```text
CompatibleWorlds(view, history) =
  { world |
      observe(world) = view.observation
      et world reproduit toutes les réponses de history }.
```

La pertinence d'une réponse à une requête est :

```text
CompatibleWorlds(view, history ++ [query, response])
⊊
CompatibleWorlds(view, history).
```

Le caractère strict doit être accompagné d'un monde éliminé et d'un monde
encore compatible. Une fibre vide signale une trace incohérente, pas une
acquisition parfaite.

### 10.6 Capacité totale du transcript

La borne ne doit pas compter uniquement `z`. Comptabiliser :

```text
capacité de l'observation initiale ;
capacité du latent ;
nombre de choix de requête ;
nombre de réponses possibles ;
mémoire persistante ;
nombre d'étapes adaptatives.
```

Pour une suite de `q` requêtes, le transcript complet est :

```text
(observation, z, [(queryᵢ, responseᵢ) | 0 ≤ i ≤ q]).
```

Le no-go doit produire deux mondes ayant le même transcript complet pour la
politique considérée mais des fermetures requises différentes. Il est invalide
de prouver une collision sur `z` si la réponse ou l'historique distingue déjà
les états.

### 10.7 Politiques adaptatives

Une politique multi-étapes choisit `queryₙ` depuis le préfixe du transcript.
Les bornes doivent donc porter sur des arbres de décision, pas seulement sur
des listes fixes d'actions.

Pour le petit domaine, calculer exhaustivement :

```text
profondeur minimale de fermeture ;
nombre minimal de feuilles ;
coût minimal au pire cas ;
coût moyen sous la distribution préenregistrée.
```

Le système complet doit être comparé au meilleur contrôleur passif ou factorisé
dans la même classe de budget, pas à une politique volontairement sous-optimale.

### 10.8 No-go de contrôleur visible factorisé

Le certificat fini doit fournir :

```text
deux états à visible identique ;
deux actions requises incompatibles ;
un budget commun ;
la preuve qu'une mauvaise première action ne peut être compensée dans ce budget ;
la preuve que le contrôleur factorisé choisit la même première action.
```

La conclusion est limitée à `VisibleFactoredClosureController` sous ce budget.
Elle complète, sans la remplacer, la non-représentabilité projective de
`HasUse`.

## 11. Baselines et ablations

Toutes les comparaisons doivent utiliser des budgets documentés et aussi
proches que possible en paramètres, calcul, données et nombre d'interactions.

### 11.1 Baselines minimales

```text
modèle passif image seule ;
modèle passif cue seule ;
modèle passif toutes observations initiales ;
mémoire récurrente sans action ;
apprentissage actif classique sans gap typé ;
world model avec planification ;
agent avec requête mais sans réparation structurée ;
agent avec réparation externe ;
système complet gap-driven.
```

### 11.2 Ablations internes

```text
sans séparation ;
sans coordination ;
sans usage orienté ;
sans coût de requête ;
sans réponse ;
sans preuve d'applicabilité du patch ;
sans préservation de l'historique ;
sans transport composé ;
gap remplacé par un vecteur aléatoire de même dimension ;
gap calculé mais non transmis ;
next appris directement sans exécution du patch.
```

### 11.3 Contrôle de fuite

Entraîner des sondes pour prédire l'état caché depuis chaque canal disponible.
Documenter explicitement toute fuite. Une observation initiale qui permet déjà
la reconstruction globale annule le test de nécessité du gap.

### 11.4 Appariement des ressources

Pour chaque système, publier le vecteur `R` de la section 1.6. Une comparaison
principale doit satisfaire :

```text
mêmes données d'entraînement ;
mêmes modalités initiales ;
même nombre maximal de requêtes ;
même capacité totale des réponses ;
même horizon ;
paramètres et FLOPs dans une marge préenregistrée ;
même procédure de sélection de checkpoint.
```

Si l'appariement exact est impossible, exécuter une courbe de budgets. La
conclusion porte sur la frontière de Pareto coût/fermeture et non sur un seul
point choisi.

### 11.5 Même critère de fermeture

Toutes les baselines doivent produire une `Candidate` évaluée par le même
`ClosedOn`. Il est interdit de comparer :

```text
le système complet sur exact match
à
une baseline sur une métrique plus stricte ou avec moins d'informations.
```

Les systèmes opaques peuvent être munis d'un décodeur vers `Candidate`, mais le
coût et la supervision de ce décodeur appartiennent à leur budget.

### 11.6 Meilleure baseline et contrôles oracle

Les hyperparamètres de chaque baseline sont réglés avec le même budget de
recherche. Les contrôles oracle sont publiés séparément :

```text
oracle world ;
oracle gap ;
oracle query ;
oracle response ;
oracle patch.
```

Ils mesurent les plafonds et localisent le goulot d'étranglement. Ils ne sont
jamais inclus parmi les systèmes admissibles pour la revendication causale.

## 12. Généralisation et OOD

### 12.1 Partitions

Séparer avant tout entraînement :

```text
IID train ;
IID validation ;
IID test ;
OOD structurel validation ;
OOD structurel test scellé ;
OOD horizon ;
OOD composition ;
OOD action-réponse.
```

### 12.2 OOD structurel

Les familles OOD doivent changer des lois de présentation sans changer les
lois abstraites du gap :

```text
géométrie du rendu ;
position des marqueurs ;
permutation des modalités ;
nouveaux distracteurs ;
nouveaux supports de candidate ;
nouveaux ordres de présentation.
```

### 12.3 OOD de composition

Tester des suites de gaps dont chaque étape locale a été vue, mais dont la
composition et l'ordre sont nouveaux.

### 12.4 OOD d'horizon

Entraîner sur des orbites courtes et évaluer sur des horizons strictement plus
longs. Mesurer la persistance des réparations et le taux d'erreur cumulé.

### 12.5 OOD sémantique

Introduire de nouvelles valeurs ou règles qui conservent l'interface abstraite
mais exigent de nouvelles requêtes. Ce test distingue l'apprentissage d'une
table de la maîtrise du mécanisme.

### 12.6 Validation multi-domaines

Une seule famille visuelle ne suffit pas pour qualifier l'architecture de
générale. Après la tâche de conformance, valider au moins deux spécialisations
substantiellement différentes partageant la même API abstraite :

```text
une tâche perceptuelle partiellement observable ;
une tâche symbolique ou de réparation de programme/règles.
```

Le code de domaine peut différer. Les objets suivants doivent garder la même
signification et les mêmes lois :

```text
OperationalGap ;
GapAuthorizedUse ;
Query ;
Response ;
IntrinsicRepair ;
ClosedOn ;
provenance de next ;
interventions causales.
```

Les frontières `gapEncoder → useConstructor → queryPolicy → repairBuilder →
repairExecutor`, les pertes causales principales et les vérificateurs de
provenance restent identiques. Seuls les encodeurs d'observation, les types de
requête/réponse et l'interpréteur de candidate peuvent être spécialisés. Toute
branche de contrôle propre à un domaine doit être déclarée et ne peut pas
contourner le gap.

Rapporter séparément :

```text
réinstanciation : même architecture réentraînée dans le second domaine ;
transfert : composants ou poids appris dans un domaine réutilisés dans l'autre.
```

La réinstanciation suffit pour valider la généralité du schéma architectural.
Une revendication de transfert exige le second résultat.

La conclusion « architecture générale » n'est autorisée qu'après succès dans
les deux domaines. Avant cela, la conclusion porte sur l'instance étudiée.

### 12.7 Scellement et journal d'accès

Les données OOD test sont chiffrées, archivées ou détenues séparément jusqu'au
gel des checkpoints. Tout accès est journalisé. Une exécution sur le test pour
choisir un seuil, corriger un bug de modèle ou sélectionner une seed transforme
ce test en validation et exige un nouveau test scellé.

## 13. Mesures

### 13.1 Mesures de structure

```text
taux de gaps correctement localisés ;
taux de séparation des pôles ;
taux de coordination correcte ;
taux d'usages admissibles ;
taux d'usages inverses indûment acceptés ;
taux de patches applicables ;
taux de provenance complète ;
violations des lois de composition.
```

### 13.2 Mesures causales

```text
changement de requête sous permutation du gap ;
changement de patch sous permutation de réponse ;
persistance du gap sous patch identité ;
fermeture du gap sous patch correct ;
effet indirect gap → patch → fermeture ;
effet direct résiduel après fixation du patch.
```

### 13.3 Mesures dynamiques

```text
gaps fermés par étape ;
gaps antérieurs rouverts ;
distance entre candidats successifs ;
longueur avant fermeture finie ;
taux de cycles ;
nouveauté des indices ;
performance selon l'horizon ;
coût cumulatif des requêtes.
```

### 13.4 Mesures informationnelles

```text
capacité minimale du médiateur ;
information portée par chaque réponse ;
erreur marginale incompressible ;
succès actif au seuil ;
écart actif-passif à budget égal ;
robustesse lorsque la capacité est réduite.
```

### 13.5 Mesures de tâche

```text
exact match ;
IoU ou métrique perceptuelle pertinente ;
précision de reconstruction ;
calibration du mismatch ;
succès terminal ;
succès cumulatif ;
coût total de fermeture.
```

Les métriques de tâche ne remplacent aucune obligation structurelle.

## 14. Vérificateurs indépendants

### 14.1 Principe

Le générateur produit des traces. Le vérificateur ne fait confiance ni aux
booléens résumés, ni aux listes de contextes, ni aux réponses enregistrées.

Il reconstruit :

```text
les contextes depuis les seeds et la configuration ;
les mondes depuis les règles de l'environnement ;
les réponses depuis monde et action ;
les gaps depuis monde et candidate ;
les patches depuis les sorties sérialisées ;
les états suivants par exécution ;
les métriques depuis les prédictions brutes.
```

### 14.2 Vérification canonique des contextes

La liste de contextes est dérivée par une fonction canonique versionnée. Le
certificat ne peut ni en omettre ni en ajouter. Le vérificateur compare la
liste exacte, l'ordre, les multiplicité et les seeds.

### 14.3 Vérification des hashes

Le vérificateur recalcule les hashes de :

```text
source figée ;
configuration ;
checkpoint ;
traces ;
certificats ;
module Lean généré.
```

### 14.4 Falsification

Le falsificateur doit muter au minimum :

```text
un contexte ;
un gap ;
une action ;
une réponse ;
un patch ;
un état suivant ;
un hash ;
une obligation de composition ;
une collision du certificat minimal ;
une frontière IID/OOD.
```

Chaque mutation doit être rejetée pour la bonne raison.

## 15. Certificat Lean Mode B

### 15.1 Séparation des responsabilités

Le certificat Lean ne prouve pas la généralisation statistique du réseau. Il
prouve que la trace finie réifiée satisfait exactement le schéma formel fini.

Les revendications sont séparées :

```text
théorie abstraite       preuve Lean générale ;
instance de référence   preuve Lean constructive ;
run fini                certificat Lean calculé ;
généralisation          analyse empirique préenregistrée.
```

### 15.2 Données réifiées

Le générateur de certificat écrit uniquement des définitions :

```text
configuration ;
états ;
observations ;
gaps ;
requêtes ;
réponses ;
patches ;
états suivants ;
hashes de provenance comme données.
```

Il n'écrit aucun `axiom` et ne transforme aucun booléen JSON déclaré en
théorème sans recalcul.

### 15.3 Prédicat de validité

Définir un prédicat décidable :

```text
ValidTrace trace
```

qui vérifie :

```text
projection commune ;
séparation ;
mismatch ;
provenance de l'usage ;
admissibilité de la requête ;
exactitude de la réponse ;
applicabilité du patch ;
égalité de l'état suivant ;
fermeture du gap courant ;
persistance ;
composition ;
partition IID/OOD ;
obligations informationnelles finies.
```

### 15.4 Preuve calculée

Le module généré contient un théorème obtenu par calcul constructif sur les
données réifiées. La technique exacte peut être `by decide` ou une preuve
récursive spécialisée, selon les performances d'élaboration. Elle ne peut pas
être un axiome, un `sorry` ou un résultat importé depuis le JSON.

### 15.5 Audit final

Le module généré se termine par un unique bloc :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms empiricalTrace_valid
/- AXIOM_AUDIT_END -/
```

La campagne échoue si Lean n'est pas disponible, si le fichier ne compile pas,
si l'audit contient une dépendance interdite ou si le certificat diffère après
rejeu déterministe.

### 15.6 Liaison checkpoint → inférence → trace

Un hash de checkpoint prouve l'identité d'un fichier, pas que ce fichier a
produit les sorties inscrites dans la trace. Sans étape supplémentaire, Lean
certifie seulement :

```text
si cette trace est la trace du modèle,
alors elle satisfait ValidTrace.
```

La validation intégrale exige donc un petit agent certifiable dont l'inférence
est calculable exactement :

```text
poids quantifiés entiers ;
opérateurs déterministes spécifiés ;
arrondis explicites ;
architecture réifiée ;
entrées réifiées ;
fonction d'inférence exécutable dans Lean ;
égalité entre sorties recalculées et trace certifiée.
```

Le théorème cible est de la forme :

```text
runModel certifiedWeights certifiedInputs = certifiedTrace
∧
ValidTrace certifiedTrace.
```

Nommer le paquet final :

```text
ValidCertifiedRun weights inputs trace :=
  runModel weights inputs = trace
  ∧ ValidTrace trace.
```

La porte de certification porte sur `ValidCertifiedRun`, pas seulement sur
`ValidTrace`.

Il n'est pas nécessaire de formaliser l'entraînement. Il est nécessaire de
lier exactement le modèle final aux décisions finies revendiquées.

### 15.7 Deux niveaux de modèles appris

Le protocole peut conserver un grand modèle flottant pour l'étude de scaling,
mais il doit distinguer :

```text
agent certifiable :
  petit, quantifié, inférence Lean exacte, revendication de bout en bout ;

agent de scaling :
  plus grand, inférence GPU, rejeu Python indépendant,
  revendication statistique seulement.
```

Pour l'agent de scaling, exiger au minimum deux implémentations d'inférence ou
un export vers un runtime indépendant, avec accord des décisions discrètes.
Une tolérance flottante doit être préenregistrée et les marges aux frontières
de décision publiées.

Le succès du grand modèle ne remplace pas l'agent certifiable. Le succès du
petit agent ne démontre pas à lui seul le scaling.

### 15.8 Encodage canonique et preuves par morceaux

Définir un encodage canonique indépendant de Python :

```text
ordre des champs ;
endianness ;
largeur des entiers ;
représentation des listes ;
version du schéma ;
absence de NaN et d'infini ;
normalisation des chaînes.
```

Les grandes traces peuvent être divisées en blocs. Chaque bloc porte un
théorème Lean de validité, puis un théorème constructif compose les blocs dans
l'ordre. Un arbre de hashes peut aider la provenance, mais ne remplace jamais
la preuve de `ValidTrace` sur les données réifiées.

### 15.9 Rejeu bit-exact

Le rejeu du modèle certifiable doit être bit-exact sur deux exécutions et, si
possible, sur deux plateformes. Toute opération non déterministe est interdite
dans l'inférence certifiée. La campagne échoue si :

```text
une décision change ;
une sortie discrète change ;
un poids exporté change ;
le module Lean régénéré diffère hors métadonnées autorisées.
```

## 16. Protocole statistique

### 16.1 Préenregistrement

Avant le run principal, figer :

```text
hypothèses ;
partitions ;
seeds ;
budgets ;
architectures ;
métriques ;
interventions ;
critères de succès ;
règles d'exclusion ;
analyse statistique.
```

### 16.2 Répétitions

Utiliser au minimum dix seeds d'entraînement indépendantes, sauf si une analyse
de puissance préenregistrée impose un nombre supérieur. Chaque checkpoint est
évalué sur plusieurs seeds d'environnement et sur la totalité du petit domaine
exhaustif. Publier tous les runs, y compris les échecs. Une unique seed ne peut
soutenir la revendication empirique générale.

### 16.3 Incertitude

Rapporter :

```text
distribution par seed ;
intervalle de confiance ;
taille d'effet ;
variance inter-environnements ;
meilleur et pire cas ;
nombre exact de décisions testées.
```

### 16.4 Obligations exactes et statistiques

Les obligations structurelles finies exigent zéro violation sur le domaine
certifié. Les performances apprises et OOD sont rapportées statistiquement.
Une moyenne élevée ne compense jamais une violation d'un théorème exact.

### 16.5 Règles de décision préenregistrées

Définir avant entraînement des marges pratiques strictement positives :

```text
δ_task       avantage minimal de tâche ;
δ_causal     effet minimal d'une intervention ;
δ_ood        performance minimale hors distribution ;
ε_forgetting oubli cumulatif maximal ;
ε_violation  fixé à zéro pour les obligations exactes.
```

Pour la comparaison au meilleur baseline apparié :

```text
Δ_task = score(full) - score(bestBaseline).
```

La porte empirique exige que la borne inférieure de l'intervalle de confiance
préenregistré sur `Δ_task` soit supérieure à `δ_task`.

Pour chaque intervention causale, définir un contraste signé. Par exemple :

```text
C_gap =
  P(query suit le gap permuté | do(gap := autreGap))
  -
  P(query suit l'ancien gap | do(gap := autreGap)).
```

La borne inférieure de l'intervalle de confiance sur le contraste doit dépasser
`δ_causal`. Des contrastes analogues sont fixés pour réponse→patch et
patch→état suivant.

La généralisation OOD exige simultanément :

```text
scoreOOD ≥ δ_ood ;
avantage sur le meilleur baseline OOD ≥ δ_task ;
oubli cumulatif ≤ ε_forgetting ;
zéro violation des invariants exacts vérifiables.
```

Les valeurs de ces marges doivent être justifiées par l'échelle de la tâche et
figées avant ouverture du test scellé. Elles ne peuvent pas être choisies après
observation des résultats.

### 16.6 Réplication indépendante

La réplication doit repartir des sources figées et du protocole, pas d'un
répertoire de sorties prérempli. Elle doit reproduire :

```text
les obligations exactes ;
le signe des effets causaux ;
les conclusions des comparaisons ;
la compilation du certificat Lean ;
la sensibilité du falsificateur.
```

Une réplication sur les mêmes poids vérifie la reproductibilité d'évaluation.
Une réplication avec nouvel entraînement vérifie la robustesse du mécanisme.
Les deux sont nécessaires.

### 16.7 Unité statistique et pseudo-réplication

L'unité indépendante principale est la seed d'entraînement, pas chaque frame ou
chaque décision d'un même checkpoint. Les analyses doivent respecter la
hiérarchie :

```text
seed d'entraînement
  → monde ou épisode
    → étape
      → décision.
```

Les intervalles peuvent utiliser un modèle hiérarchique ou un bootstrap par
blocs, mais ne doivent pas traiter des milliers de décisions corrélées comme des
runs indépendants. Les interventions naturelles et contrefactuelles sont
comparées de manière appariée sur les mêmes mondes et seeds de bruit.

### 16.8 Multiplicité et résultat principal

Déclarer une métrique principale, une intervention causale principale et une
famille OOD principale. Les autres analyses sont secondaires ou exploratoires.
Si plusieurs hypothèses confirmatoires sont testées, préenregistrer la méthode
de contrôle de multiplicité.

Les conclusions négatives et les résultats hors seuil sont publiés avec la même
granularité que les succès.

### 16.9 Arrêt, reprise et sélection

Figer les règles d'arrêt de l'entraînement et de reprise après incident. Il est
interdit de :

```text
prolonger seulement les seeds défavorables jusqu'à succès ;
choisir le meilleur pas sur le test ;
écarter un run sans règle préenregistrée ;
relancer une seed avec le même identifiant et remplacer sa sortie.
```

Chaque reprise reçoit un nouvel identifiant de provenance. Le rapport conserve
la tentative initiale.

## 17. Matrice de traçabilité

Chaque revendication publique doit être reliée à quatre artefacts.

| Revendication | Théorème abstrait | Instance constructive | Vérification empirique | Intervention |
|---|---|---|---|---|
| Projection non fidèle | `ProjectionObstruction` | paire explicite | collision observée | permutation des pôles |
| Détection correcte | soundness/completeness du détecteur | gap opérationnel certifié | précision/localisation/calibration | faux gap compatible |
| Usage non identitaire | `not_exactProjective_of_asymmetric_use` | usage orienté | action avant→après | tentative inverse |
| Transport cohérent | `CompositionalTransport` | composition calculée | trace composée | permutation d'ordre |
| Gap causal | `GapRepairAlgebra` | `next = execute repair` | transition rejouée | suppression/permutation du gap |
| Réponse pertinente | réduction stricte de fibre | monde éliminé et monde conservé | taille de fibre | permutation de réponse |
| Réponse utilisée | loi de réparation | patch dépendant | sensibilité du patch | neutralisation/permutation de réponse |
| Persistance | stabilité dynamique | invariant d'orbite | rétention mesurée | retrait d'une réparation passée |
| No-go passif | collision à vue identique | paire aux cibles incompatibles | baseline marginale | neutralisation de la requête |
| No-go visible factorisé | `VisibleFactoredClosureController` impossible | actions requises incompatibles | baseline factorisée | permutation de pôles visibles égaux |
| Budgets comparables | `ResourceBudget` | contrôleurs au même budget | courbe de Pareto | variation du budget |
| Fermeture finie | induction constructive | borne N | succès terminal | patch identité |
| Orbite ouverte | théorème de rang | indices distincts | horizon extrapolé | recherche de cycle |
| Certificat fidèle | `ValidTrace` | données réifiées | compilation Lean | falsification des artefacts |
| Checkpoint lié à la trace | `runModel weights inputs = trace` | agent entier quantifié | rejeu indépendant | mutation d'un poids |

Une ligne sans les quatre colonnes remplies est une revendication incomplète.

## 18. Arborescence cible

```text
Docs/
  ValidationIntegraleFermetureSemantiqueIA.md

Meta/AI/
  ActiveSemanticClosure.lean
  FiniteActiveSemanticClosure.lean
  OpenActiveSemanticClosure.lean
  VisibleFactoredClosureNoGo.lean
  CertifiedInference.lean
  EmpiricalTraceSchema.lean
  EmpiricalTraceVerifier.lean
  AIFoundationalValidation.lean

Empirical/
  v22_aslmt_perceptual_localglobal_dynamic_infinite/
    fichiers historiques inchangés

  v23_gap_driven_active_semantic_closure/
    README.md
    SCIENTIFIC_PROTOCOL.md
    trace_schema_v23.py
    environment_v23.py
    finite_reference_domain_v23.py
    perceptual_compositional_domain_v23.py
    symbolic_repair_domain_v23.py
    model_v23.py
    train_v23.py
    campaign_v23.py
    freeze_and_run_v23.py
    certify_information_v23.py
    verify_information_v23.py
    certify_causality_v23.py
    verify_causality_v23.py
    certify_dynamics_v23.py
    verify_dynamics_v23.py
    certify_visible_factored_nogo_v23.py
    verify_visible_factored_nogo_v23.py
    export_quantized_agent_v23.py
    verify_quantized_inference_v23.py
    audit_information_flow_v23.py
    compile_lean_trace_v23.py
    falsify_verifiers_v23.py
    audit_scientific_contract_v23.py
```

Les noms Python définitifs doivent rester nouveaux. Aucun fichier historique ne
sera renommé ou réécrit.

## 19. Phases d'implémentation

### Phase 0 — Geler et qualifier v22

Livrables :

```text
inventaire de hashes ;
rapport des limites connues ;
reproductibilité du run historique ;
aucune modification des scripts ou résultats.
```

Critère de sortie : v22 est utilisable comme baseline historique, jamais comme
certificat intégral.

### Phase 1 — Instance Lean fermée

Implémenter le noyau de spécialisation, la fermeture finie et l'orbite ouverte.

Critères de sortie :

```text
compilation complète ;
audits sans axiome ;
non-trivialité vérifiée ;
next dérivé du repair ;
causalité structurelle démontrée ;
non-projectivité démontrée ;
persistance et orbite démontrées.
```

### Phase 2 — Environnement v23 de référence

Implémenter l'environnement exécutable correspondant exactement à l'instance
finie, puis tester la concordance des transitions sur tout petit domaine
exhaustif.

Critère de sortie : Lean et Python calculent les mêmes gaps, réponses, patches
et états suivants sur le domaine de référence.

### Phase 3 — Agent certifiable

Construire un petit agent quantifié, exporter ses poids et définir la même
inférence dans Lean.

Critère de sortie :

```text
runModel weights inputs = trace ;
ValidTrace trace ;
rejeu bit-exact ;
audit sans axiome.
```

### Phase 4 — Modèle appris de scaling et contrôles

Implémenter les trois régimes d'apprentissage et les baselines appariées.

Critère de sortie : le contrôle supervisé ferme la tâche et les canaux de fuite
sont explicitement exclus ou quantifiés.

### Phase 5 — Causalité

Exécuter toutes les interventions des sections 9 et 11.

Critère de sortie : chaque variable intermédiaire produit l'effet prévu et les
variantes décoratives sont réfutées.

### Phase 6 — Information, no-go et composition

Corriger le certificat minimal, prouver les no-go marginaux, vérifier la
suffisance active, le no-go visible factorisé et les lois de composition
multi-étapes.

Critère de sortie : zéro violation sur les obligations finies exhaustives.

### Phase 7 — Généralisation multi-domaines

Ouvrir les jeux OOD scellés après gel des modèles et hyperparamètres.

Critère de sortie : rapport complet sur les deux domaines, sans suppression des
seeds ou familles défavorables.

### Phase 8 — Certificat Lean exécutable de campagne

Réifier les traces, compiler le module généré, vérifier l'audit et lancer le
falsificateur.

Critère de sortie : certificat sans axiome, déterministe et sensible à chaque
mutation enregistrée.

### Phase 9 — Réplication

Rejouer la campagne sur une machine ou un environnement indépendant à partir
du protocole et des sources figées.

Critère de sortie : mêmes obligations exactes et effets statistiques
compatibles dans les intervalles préenregistrés.

## 20. Portes de décision

La revendication progresse uniquement si les portes suivantes sont franchies
dans l'ordre.

### Porte G0 — Provenance

```text
sources figées ;
hashes valides ;
commande et environnement enregistrés ;
aucun artefact manquant.
```

### Porte G1 — Formalisation

```text
Lean compile ;
aucun axiome interdit ;
instance non triviale ;
aucun pont conditionnel externe.
```

### Porte G2 — Exactitude exécutable

```text
Python et Lean concordent ;
réponses recalculées ;
contextes canoniques ;
transitions rejouables.
```

### Porte G3 — Liaison modèle-trace

```text
agent certifiable quantifié ;
inférence Lean exacte ;
sorties égales à la trace ;
rejeu bit-exact ;
aucune opération d'inférence non déterministe.
```

### Porte G4 — Nécessité informationnelle

```text
no-go marginal exact ;
borne de capacité correcte ;
suffisance active ;
aucune fuite rendant la requête superflue ;
no-go de contrôleur visible factorisé ;
capacité totale du transcript comptabilisée ;
meilleur contrôleur fini sous le budget calculé.
```

### Porte G5 — Causalité

```text
gap non décoratif ;
requête utilisée ;
réponse utilisée ;
patch effectif ;
next exclusivement produit par le patch.
```

### Porte G6 — Dynamique

```text
plusieurs transitions ;
persistance ;
nouveaux gaps ;
pas de cycle artificiel ;
composition cohérente.
```

### Porte G7 — Généralisation

```text
OOD réellement tenu hors entraînement ;
horizons plus longs ;
compositions nouvelles ;
répétitions multi-seeds ;
validation dans deux domaines.
```

### Porte G8 — Certification et réplication

```text
`ValidCertifiedRun` prouvé dans Lean ;
checkpoint certifiable lié par calcul à la trace ;
audit sans axiome ;
falsificateur efficace ;
réplication d'évaluation et de nouvel entraînement.
```

Une porte échouée bloque les formulations qui en dépendent. Elle ne peut pas
être compensée par une meilleure moyenne sur une autre métrique.

## 21. Niveaux de formulation publique

### Après G1

Formulation autorisée :

> La théorie possède une instance constructive fermée de régulation par gap.

### Après G3

Formulation autorisée :

> Un agent quantifié exécute la chaîne certifiée sur le domaine fini et Lean
> recalcule ses décisions depuis ses poids et ses entrées.

### Après G4

Formulation autorisée :

> Sous les classes et budgets formellement définis, ni la politique passive ni
> le contrôleur visible factorisé ne réalisent la même fermeture.

### Après G5

Formulation autorisée :

> Une réalisation exécutable utilise causalement le gap pour produire sa
> requête, sa réparation et son état suivant.

### Après G7

Formulation autorisée :

> Le mécanisme appris se généralise à des compositions, horizons et familles
> de présentation tenus hors entraînement.

### Après G8

Formulation autorisée :

> La fermeture sémantique dynamique est reliée de bout en bout à une théorie
> constructive, une instance fermée, un agent certifiable, une réalisation
> apprise multi-domaines, des interventions causales et un certificat
> exécutable sans axiome.

Le terme « game changer » ne doit intervenir qu'après comparaison indépendante
avec les meilleures architectures actives pertinentes et réplication externe.

## 22. Critères d'échec explicites

La validation intégrale échoue si l'un des faits suivants est observé :

```text
le modèle résout la tâche sans requête ;
le détecteur de gap reçoit directement world ou target ;
le gap n'a aucune évidence accessible à l'agent ;
le gap peut être permuté sans changer l'action ;
la réponse peut être permutée sans changer le patch ;
la réponse ne réduit aucune fibre de mondes compatibles ;
le patch peut être neutralisé sans conserver le gap ;
next est appris ou fourni indépendamment du patch ;
les réparations antérieures sont oubliées ;
la projection est constante sur tout le modèle ;
Use ou Repair est trivial ;
OutRel est seulement un renommage de Use ;
la borne minimale utilise une fausse réponse environnementale ;
l'OOD a influencé l'entraînement ou la sélection ;
le vérificateur fait confiance aux booléens du certificat ;
le hash du checkpoint est présenté comme preuve de son exécution ;
la trace Lean n'est pas reliée par calcul au petit agent certifiable ;
le module Lean utilise un axiome ;
le pont empirique affirme une universalité non dérivée ;
une unique seed soutient la conclusion générale ;
les baselines disposent de moins d'information ou de calcul sans justification ;
la non-projectivité de HasUse est présentée comme impossibilité universelle
de toute architecture enrichie ;
la conclusion générale repose sur un seul domaine.
```

Un échec doit produire un diagnostic localisé dans la chaîne causale, pas une
réécriture a posteriori de la revendication.

## 23. Résultat final attendu

Le paquet final doit contenir :

```text
1. une sémantique constructive générale ;
2. une instance finie fermée ;
3. une orbite ouverte cumulative ;
4. un environnement Python concordant ;
5. un no-go passif exact ;
6. un no-go de contrôleur visible factorisé ;
7. un petit agent certifiable avec inférence Lean exacte ;
8. un agent appris multi-étapes de scaling ;
9. des baselines appariées sur une frontière de Pareto ;
10. des interventions causales ;
11. des bornes informationnelles corrigées ;
12. deux domaines de validation ;
13. des tests OOD scellés ;
14. un certificat Lean Mode B lié au modèle ;
15. un falsificateur indépendant ;
16. une réplication complète.
```

La proposition validée sera alors :

> Le gap n'est ni une perte scalaire, ni une annotation, ni un échec terminal.
> Il est une donnée sémantique typée qui conserve la séparation, autorise un
> transport local non identitaire, sélectionne une acquisition d'information,
> porte une réparation intrinsèque et cause la transition vers l'état suivant.
> Cette dynamique est constructive, composable, non représentable exactement
> par l'identité projetée sur son régime d'usage, et non réalisable par le
> contrôleur visible factorisé défini sous le même budget. Elle est
> empiriquement observable et causalement falsifiable.

## 24. Ordre de travail immédiat

L'ordre de mise en oeuvre est strict :

```text
1. figer v22 et publier son audit de limites ;
2. définir l'instance Lean ActiveSemanticClosure ;
3. prouver fermeture finie et orbite ouverte ;
4. construire l'environnement Python isomorphe au petit modèle fini ;
5. produire le vérificateur canonique avant l'entraînement ;
6. prouver les no-go passif et visible factorisé ;
7. corriger et généraliser le no-go de capacité totale du transcript ;
8. construire le petit agent quantifié et certifier son inférence ;
9. implémenter l'agent multi-étapes de scaling et les baselines ;
10. auditer les flux de données et exécuter les interventions causales ;
11. valider la seconde spécialisation de domaine ;
12. ouvrir les partitions OOD scellées ;
13. générer et compiler le certificat Lean Mode B de campagne ;
14. falsifier les vérificateurs ;
15. répliquer l'évaluation et le nouvel entraînement.
```

Il ne faut pas commencer par une nouvelle grande campagne GPU. Le premier
jalon décisif est la concordance exhaustive entre une petite instance Lean et
son exécution Python. Elle fixe la signification de chaque champ avant que
l'apprentissage statistique puisse masquer une ambiguïté architecturale.

## 25. Audit interne de couverture

Le tableau suivant vérifie que chaque fragment de l'énoncé opérationnel possède
une définition, une preuve cible, une mesure et une falsification.

| Fragment | Définition | Preuve ou certificat | Mesure | Falsification |
|---|---|---|---|---|
| détecter | `OperationalGap` depuis `AgentView` | soundness/completeness/localisation | précision et calibration | gap faux ou permuté |
| non-coïncidence locale | `TypedSemanticGap.mismatch` via `Agrees` | témoin sémantique fini | taux de vrais mismatches | accès direct au monde |
| droit d'interrogation | `GapAuthorizedUse` | provenance `Sep + Coord → Use` | admissibilité et asymétrie | usage inverse ou constant |
| information pertinente | réduction stricte de `CompatibleWorlds` | monde éliminé et monde conservé | réduction de fibre | réponse permutée/neutre |
| réparation intrinsèque | `IntrinsicRepair` sans monde | effet de correction et provenance | fermeture locale | patch identité/externe |
| conservation | `ClosedOn repairedPrefix` | invariant inductif | oubli cumulatif | retrait ou permutation d'un patch |
| poursuite dynamique | `next = executeRepair` | orbite finie et ouverte | transitions et nouveaux gaps | `next` parallèle ou cycle |
| impossibilité passive | `PassiveClosurePolicy` | paire à vue identique | plafond passif | oracle passif séparé |
| impossibilité factorisée | `VisibleFactoredClosureController` | actions incompatibles sous budget | baseline factorisée | enrichissement hors classe |
| capacité comparable | `ResourceBudget` | domaine/budget communs | frontière de Pareto | avantage de ressources caché |
| causalité | équations structurelles | provenance + sensibilité | contrastes appariés | interventions contrôlées |
| lien au modèle | `ValidCertifiedRun` | inférence Lean bit-exacte | accord de rejeu | mutation d'un poids |
| généralisation | partitions scellées | protocole gelé | OOD/horizon/composition | journal d'accès |
| généralité | API commune à deux domaines | deux spécialisations | résultats par domaine | échec de transfert de lois |

### 25.1 Vérifications de non-trivialité couvertes

Le plan bloque explicitement :

```text
projection constante comme seul visible ;
Use, Gap, Repair ou Witness égaux à Unit ;
OutRel renommant Use ;
next fourni séparément ;
world transmis au détecteur ou au patch ;
gap latent sans sémantique d'intervention ;
réponse enregistrée mais ignorée ;
history enregistrée sans correction persistante ;
OOD vu pendant l'entraînement ;
hash présenté comme preuve d'exécution ;
axiomes Lean ;
no-go projectif annoncé hors de sa classe ;
comparaison à une baseline sous-dotée ;
validation sur une seule seed ou un seul domaine.
```

### 25.2 Choix encore ouverts à fermer avant implémentation

Le plan est complet au niveau des obligations, mais les paramètres suivants
doivent être fixés dans le protocole v23 avant le premier run scientifique :

```text
le petit monde fini exact ;
le langage compositionnel du niveau B ;
les deux domaines finaux ;
la relation Agrees ;
la classe exacte de Query et Response ;
le budget du no-go visible factorisé ;
l'architecture entière de l'agent certifiable ;
la méthode Lean de calcul de l'inférence ;
les marges δ_task, δ_causal, δ_ood et ε_forgetting ;
les seeds et tailles d'échantillon ;
les règles de scellement OOD ;
les baselines et leurs budgets de réglage.
```

Ces choix sont des paramètres de réalisation, pas des hypothèses ajoutées aux
théorèmes de fermeture. Ils doivent être enregistrés avant les résultats pour
éviter toute adaptation opportuniste.

### 25.3 Verdict documentaire

Le document couvre désormais l'énoncé cible sans l'affaiblir en simple système
de transitions et sans le renforcer illégitimement en impossibilité universelle
de toute architecture projective. Il exige :

```text
une preuve générale bornée ;
une instance constructive fermée ;
un agent exact certifiable ;
un agent appris de scaling ;
une causalité interventionnelle ;
deux no-go distincts ;
une comparaison de ressources ;
une validation multi-domaines ;
et une réplication.
```

Le document reste un plan d'implémentation et de validation. Aucun tableau de
couverture ne doit être cité comme résultat avant production et vérification de
ses artefacts.
