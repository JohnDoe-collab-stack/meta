# Plan exhaustif de réalisation de `v23_final`

## 0. Objet et statut

Ce document définit le plan normatif d’un nouveau dossier `v23_final`.

Son objectif n’est pas de renommer le dossier de campagne existant ni de
reproduire une seconde fois le noyau Lean. Il doit réunir, sans les affaiblir :

- la séparation stricte entre syntaxe publique et sémantique privée ;
- la dynamique causale déjà définie dans `Meta/AI` ;
- la réalisation finie exacte du v23 historique ;
- une politique apprise, persistante et quantifiée ;
- la certification de toutes les branches publiques réalisables ;
- les interventions causales, les no-go et la campagne empirique ;
- un certificat formel constructif pour les obligations mathématiques ;
- un bundle final traçable reliant ce certificat aux artefacts empiriques.

Le mot « final » désigne ici un critère de fermeture explicite. Le dossier ne
sera considéré comme terminé que lorsque toutes les portes définies dans ce
document seront satisfaites. Il ne signifie pas qu’un logiciel ou un programme
scientifique ne pourra plus évoluer.

Ce plan est un document de conception. Il ne revendique pas que les résultats
encore marqués « à construire » sont déjà établis.

État de l’audit de ce plan :

```text
date : 2026-07-24
méthode : inspection statique des sources et des documents
compilation Lean pendant cet audit : non exécutée
```

Les affirmations d’état présentes ci-dessous décrivent donc ce qui est visible
dans les sources inspectées. Les affirmations de compilation restent celles
des rapports existants jusqu’à une campagne de validation explicitement
autorisée.

## 1. Principe fondateur

### 1.1 Séparation stricte

La syntaxe et la sémantique restent de types distincts, portés par des
composants distincts et accessibles par des interfaces distinctes.

```text
Couche publique de l’agent :
  état public
  observation publique
  mémoire publique
  gap opérationnel
  usage autorisé
  transport autorisé
  requête
  réparation intrinsèque

Couche privée de l’environnement :
  monde réel
  fonction de réponse
  critère local de compatibilité
  certification sémantique
```

Le monde privé ne peut pas être lu par le détecteur de gap, la politique,
l’encodeur public, les têtes apprises, le constructeur de réparation ou
l’exécuteur de réparation.

Deux opérations de frontière doivent être distinguées :

```text
exposition publique initiale :
  publishObservation : PrivateWorld → PublicObservation

interaction sémantique active :
  respond : PrivateWorld → Query → Response
```

Dans le noyau Lean actuel, la première opération s’appelle
`ActiveClosureData.observe`. Elle construit l’observation publique initiale.
La seconde est le seul canal sémantique actif après qu’un gap a produit une
requête.

Une nouvelle observation exogène ultérieure doit être représentée comme un
nouvel événement public explicitement typé, ou comme le début d’un nouvel
épisode. Elle ne peut pas entrer silencieusement dans l’état de l’agent.

L’observation et la réponse deviennent des données publiques typées. Elles ne
donnent pas à l’agent un accès au monde qui les a produites ni à son
identifiant privé.

### 1.2 Rôle exact du gap

Le gap :

- n’est pas une valeur sémantique ;
- n’est pas un évaluateur ;
- n’est pas une distance entre syntaxe et sémantique ;
- ne contient ni le monde réel, ni la réponse future, ni la réparation correcte ;
- individue une frontière syntaxique actuellement ouverte dans l’état public.

Il constitue la médiation causale par laquelle cette frontière :

```text
est détectée
→ autorise un usage
→ détermine un transport
→ forme une requête
→ reçoit une réponse locale
→ engendre une réparation
→ transforme l’état public
→ reçoit une certification locale dans l’état successeur
→ est inscrite dans une mémoire persistante
```

Le gap ne réalise donc pas lui-même l’évaluation. Il rend possible et organise
le processus causal au terme duquel une certification locale est obtenue.

Dire que « le gap permet d’évaluer » a ici un sens précis :

```text
le gap individue ce qui reste ouvert
→ son type autorise un usage déterminé
→ le transport fixe la lecture pertinente
→ la requête demande l’information correspondante
→ la réponse fournit l’apport sémantique local
→ la réparation l’intègre à l’état public
→ GapClosedBy certifie la fermeture obtenue
```

Sans gap ouvert, la transition naturelle ne produit aucune requête active.
Avec un gap ouvert, la requête et la réparation restent indexées par ce gap.

Le noyau Lean distingue en outre :

```text
OperationalGap
  preuve observable calculable depuis la vue publique

SemanticGapEvidence
  justification, côté certificat, que ce gap correspond réellement
  à un désaccord constaté ou à une fibre sémantiquement indéterminée
```

`v23_final` doit conserver cette distinction. La preuve sémantique du gap ne
doit jamais être placée dans l’entrée publique de la politique.

### 1.3 Articulation sans confusion

La syntaxe et la sémantique ne sont ni confondues ni indépendantes.

Elles sont articulées par une séquence construite :

```text
PublicState
→ OperationalGap
→ AuthorizedUse
→ AuthorizedTransport
→ Query
→ Response
→ IntrinsicRepair
→ executeRepair
→ PublicState'
```

avec, séparément :

```text
PrivateWorld
→ publishObservation
→ PublicObservation initiale

PrivateWorld
→ respond(Query)
→ Response
```

et enfin :

```text
GapClosedBy(system, beforeClosedState, OperationalGap, afterClosedState)
```

`GapClosedBy` certifie une propriété du passage complet. Il ne doit jamais être
réduit à un champ booléen fourni par le producteur de trace.

Dans le noyau Lean actuel, un état fermé assemble le monde privé et la vue
publique de l’agent uniquement pour définir et prouver les propriétés
sémantiques. `GapClosedBy` exige :

```text
préservation du monde privé
compatibilité du monde réel avec la vue publique successeure
KnownCorrectAt sur l’indice du gap
```

`KnownCorrectAt` porte sur tous les mondes encore compatibles avec la vue
successeure. La certification locale est donc plus forte que la seule
correction sur le monde réel.

Dans l’exécutable Python, `PrivateWorld` et `PublicState` restent séparés.
Seul le vérificateur ou le certificat recompose leur couple pour établir la
propriété sémantique.

### 1.4 Thèse générale

La thèse générale visée est que cette forme causale peut recevoir plusieurs
réalisations, indépendamment de leur ontologie particulière, dès lors qu’elles
admettent :

- une frontière ouverte individuable ;
- une transformation intrinsèque de l’état ;
- une certification locale dans l’état successeur ;
- une mémoire persistante des réparations et de leurs certifications.

Les contenus ontologiques, les types de réponses et les critères d’évaluation
restent propres à chaque réalisation. La forme causale de leur articulation est
la structure commune.

Cette universalité reste une cible mathématique. Elle doit être démontrée par
des interfaces, des morphismes ou plusieurs réalisations indépendantes ; elle
ne peut pas être conclue de la seule similitude du vocabulaire.

## 2. Sources d’autorité et état initial

### 2.1 Noyau causal canonique

Les fichiers suivants restent la source d’autorité :

```text
Meta/AI/ActiveSemanticClosure.lean
Meta/AI/CertifiedInference.lean
Meta/AI/FiniteActiveSemanticClosure.lean
Meta/AI/OpenActiveSemanticClosure.lean
Meta/AI/ActiveClosureInterventions.lean
Meta/AI/VisibleFactoredClosureNoGo.lean
Meta/AI/AIFoundationalValidation.lean
```

Ils fournissent déjà :

- la séparation entre monde sémantique et état de l’agent ;
- un gap calculé depuis la vue de l’agent ;
- une observation initiale calculée par `observe` puis exposée à l’agent ;
- la chaîne gap, usage, transport, requête, réponse et réparation ;
- `executeRepair` comme mise à jour du candidat, de l’observation et de
  l’historique ;
- `GapClosedBy` comme certification locale ;
- une réalisation finie non triviale ;
- une orbite ouverte avec fraîcheur, mémoire cumulative et non-récurrence ;
- des interventions causales typées ;
- des no-go et des réalisations fondationnelles.

Deux limites actuelles doivent rester visibles :

- `LawfulActiveSemanticClosureSystem` valide le gap ouvert et préserve la
  compatibilité du monde réel, mais n’exige pas génériquement que chaque
  `nextState` fournisse un `GapClosedBy` ;
- `CertifiedInferenceStep` contient cette fermeture pour la réalisation finie,
  mais n’est pas encore une histoire certifiée générique indexée par une
  trajectoire arbitraire.

`v23_final` ne doit pas redéfinir un noyau concurrent. Il doit instancier ce
noyau et renforcer les points nécessaires à la mémoire certifiée et au pont
appris.

La chaîne quantifiée finie existante doit également être réutilisée :

```text
Meta/AI/QuantizedInference.lean
Meta/AI/FiniteQuantizedAgentSemantics.lean
Meta/AI/QuantizedCertifiedAgent.lean
Meta/AI/QuantizedCertifiedAgentSemanticClosure.lean
Meta/AI/FiniteActiveSemanticClosureConformance.lean
```

Elle recalcule déjà l’inférence entière quantifiée, les bornes, l’arrondi
ties-to-even, la saturation, les masques, l’argmax et 697 décisions réparties
entre les cinq têtes. Elle établit aussi leur alignement avec les références
sémantiques finies.

Ce résultat existant est une réalisation certifiable finie. Il ne constitue
pas encore :

- un état appris récurrent transporté sur une campagne multistep ;
- une politique couvrant récursivement toutes les réponses réalisables ;
- le certificat empirique des domaines perceptuel et symbolique ;
- la réplication scientifique finale.

### 2.2 Réalisation finie historique

Le dossier suivant contient la référence Python finie à préserver :

```text
Empirical/v23_gap_driven_active_semantic_closure
```

Il apporte notamment :

- un domaine fini exact ;
- une séparation explicite de `World` et `AgentState` ;
- un `OperationalGap` non constant ;
- une réparation intrinsèque ;
- `execute_repair` ;
- la vérification de fermeture, de rétention et des interventions ;
- un agent quantifié certifiable et ses données réifiées dans Lean.

Les scripts historiques ayant produit un résultat cité restent immuables.
Toute adaptation destinée à `v23_final` doit être créée sous un nouveau nom.

### 2.3 Dossier de campagne récent

Le dossier suivant est une source de composants réutilisables, mais pas une
source d’autorité pour la dynamique causale :

```text
v23_full_campaign_implementation
```

Peuvent être repris après audit :

- l’infrastructure de configuration ;
- la sérialisation canonique ;
- les identifiants de contenu ;
- la séparation des seeds ;
- les outils de scellement OOD ;
- les statistiques ;
- l’export ONNX ;
- le préflight matériel ;
- le gel timestamp et SHA-256 ;
- les portes `PASS`, `FAIL`, `NOT_RUN` ;
- les mécanismes de campagne et de falsification.

Ne doivent pas être repris comme preuves suffisantes :

- un gap cible constant ;
- un état suivant indépendant de la réparation sélectionnée ;
- un posterior utilisé comme successeur au lieu de vérificateur ;
- un drapeau déclaratif `transition_derived_from_repair` ;
- une mémoire publique contenant l’identifiant du monde privé ;
- une récurrence qui ne transporte pas réellement l’état réparé ;
- un audit d’information limité à l’inspection des signatures et des modules
  exécutés, sans suivi de provenance des valeurs ;
- un noyau Lean qui recalcule la monotonie d’une fibre mais accepte
  `transitionDerivedFromRepair` comme booléen brut au lieu de recalculer
  l’exécution de la réparation.

### 2.4 Théorie `AdaptiveRepairability`

Les modules de la théorie finie `AdaptiveRepairability` ne se trouvent pas
encore dans la source Lean active. Ils sont présents dans :

```text
Certified_Active_Semantic_Closure_Publication/
  artifact/Meta/AdaptiveRepairability/
```

Ils comprennent notamment :

```text
FiniteMeasure.lean
PublicTree.lean
OperationalCharacterization.lean
Synthesis.lean
ExactPosterior.lean
Countermodels.lean
PositiveInstance.lean
LegacyInstanceAdapters.lean
Validation.lean
```

Le pont final ne doit pas importer directement une branche de publication
comme dépendance cachée. Une promotion mécanique et auditée vers :

```text
Meta/AdaptiveRepairability/
```

est un livrable préalable. Après cette promotion, la copie active devient la
source canonique et l’artefact de publication devient une sortie gelée ou
régénérée, jamais une seconde branche modifiable.

### 2.5 Règle de migration

Le nouveau dossier sera construit par sélection explicite :

```text
réutiliser après audit
adapter dans un nouveau fichier
remplacer
exclure
```

Chaque composant migré devra apparaître dans un registre de provenance avec :

- son chemin source ;
- son hash ;
- sa catégorie de migration ;
- la justification ;
- les tests de conformance associés ;
- son statut scientifique.

## 3. Résultat final visé

### 3.1 Résultat formel

Le résultat formel doit être une donnée Lean construite, et non un théorème
conditionnel reposant sur un pont externe.

Sa forme conceptuelle est :

```lean
structure V23FinalFormalCertificate where
  publicPrivateSeparation
  publicPolicy
  quantizedInference
  allRealizableBranches
  gapIndividuation
  repairOnlySuccessor
  localGapClosure
  certifiedPersistentHistory
  cumulativeClosure
  openOrbitNonRecurrence
  typedInterventions
  causalMediation
  passiveNoGo
  visibleFactoredNoGo
  finiteReferenceConformance
  foundationalRealization
  reifiedArtifactIntegrity
```

Le nom et le typage final pourront être affinés pendant l’implémentation. Aucun
champ substantiel ne pourra être remplacé par `True`, un drapeau importé, un
verdict JSON, une hypothèse externe ou une proposition vide.

Ce certificat peut vérifier par calcul des artefacts finis réifiés et conserver
leurs digests comme données. Il ne transforme pas, à lui seul, l’exécution
d’une campagne empirique, l’indépendance d’une réplication ou une conclusion
statistique en théorème mathématique.

Le livrable global est donc un second objet de niveau dépôt :

```text
V23FinalReleaseBundle
  certificat formel Lean
  manifeste des artefacts réifiés
  manifeste de campagne
  rapports des vérificateurs indépendants
  résultats statistiques
  rapport de réplication
  matrice affirmation-preuve
```

`V23FinalReleaseBundle` est un contrat de publication vérifiable. Il ne doit pas
être présenté comme une unique proposition Lean englobant des événements
empiriques externes.

### 3.2 Résultat opérationnel

Le système final doit démontrer, pour chaque transition active certifiée :

```text
1. le gap est calculé uniquement depuis l’état public ;
2. le gap est actuellement ouvert ;
3. l’usage et le transport sont autorisés par ce gap ;
4. la requête est déterminée par les données publiques autorisées ;
5. après l’observation publique initiale, la réponse active provient uniquement
   de respond(world, query) ;
6. la réparation est construite depuis la chaîne causale typée ;
7. l’état suivant est exactement executeRepair(state, repair) ;
8. l’ancien gap est localement fermé dans l’état suivant ;
9. le nouveau record est ajouté à la mémoire publique ;
10. une histoire certifiée relie le record à sa preuve de fermeture ;
11. toutes les certifications antérieures restent valides ;
12. aucune tête directe ne calcule l’état suivant.
```

### 3.3 Résultat appris

La composante apprise doit établir :

- des représentations cachées effectivement calculées depuis les poids ;
- une politique publique calculant gap, usage, transport, requête et réparation ;
- une mémoire ou un état latent réellement transporté entre plusieurs étapes ;
- une quantification dont les opérations, arrondis, bornes et argmax sont
  reproduits exactement ;
- une preuve de toutes les décisions sur le domaine fini certifiable ;
- une évaluation empirique séparée sur les domaines de campagne ;
- des interventions qui testent la médiation plutôt qu’une simple corrélation.

### 3.4 Portée autorisée

Une fois toutes les portes fermées, le résultat autorisé sera :

> Il existe une réalisation finie et apprise d’une dynamique dans laquelle une
> frontière syntaxique publique ouverte produit causalement une requête, reçoit
> une réponse par l’unique canal sémantique actif après requête, engendre une réparation
> intrinsèque qui est l’unique source de l’état suivant, ferme localement la
> frontière courante et conserve une histoire certifiée cumulative.

La portée empirique dépendra séparément des campagnes réellement exécutées.

Le résultat ne signifiera pas :

- que toute mathématique admet déjà une telle réalisation ;
- que toute architecture latente est réparable ;
- que toute frontière ouverte peut être fermée ;
- que la sémantique est réductible à la syntaxe ;
- que le gap possède lui-même un contenu de vérité ;
- qu’une réussite finie implique une généralisation universelle ;
- que la nouveauté historique est établie sans étude bibliographique.

## 4. Architecture de référence

### 4.1 Frontière de types

La couche publique doit définir ou spécialiser des types distincts :

```text
PublicObservation
PublicCandidate
RuntimeMemory
PublicState
GapKind
GapIndex
OperationalGap
AuthorizedUse
AuthorizedTransport
Query
Response
IntrinsicRepair
```

La couche privée doit contenir :

```text
PrivateWorld
publishObservation : PrivateWorld → PublicObservation
respond : PrivateWorld → Query → Response
evaluate : PrivateWorld → VisibleIndex → Target
Compatible : PublicState → PrivateWorld → Prop
```

`publishObservation` est exécutée par l’environnement avant l’entrée dans la
boucle active. `respond` est exécutée par l’environnement après une requête.
Leurs sorties sont publiques, mais leur argument privé n’est jamais transmis à
l’agent.

`evaluate` et `Compatible` appartiennent au vérificateur sémantique. Ils peuvent
lire le monde privé pour établir un certificat, mais leurs résultats ne sont
jamais des entrées de la politique.

Les fonctions de l’agent ne prennent jamais `PrivateWorld` en argument :

```text
detectGap
authorizeUse
transport
buildQuery
buildRepair
executeRepair
publicPolicy
publicEncoder
historyEncoder
```

### 4.2 Transition autorisée

L’initialisation canonique est :

```text
observation := publishObservation(privateWorld)
publicState := initialPublicState(observation)
```

La transition active canonique qui suit est :

```text
gap       := detectGap(publicState)
use       := authorizeUse(publicState, gap)
transport := transportUse(publicState, gap, use)
query     := buildQuery(publicState, gap, use, transport)
response  := respond(privateWorld, query)
repair    := buildRepair(publicState, gap, use, transport, query, response)
next      := executeRepair(publicState, repair)
```

Une éventuelle stase terminale doit être un constructeur distinct et prouvé
admissible. Elle ne peut pas masquer une branche active non consommée.

La décision terminale doit être séparée de la transition :

```text
detectGap(publicState) = closed
→ stase causale
→ lecture ou action terminale depuis l’état public fermé
```

Si une tête `ContinueHead` ou `TerminalActionHead` est conservée, elle peut
choisir une action publique après fermeture ou signaler qu’une nouvelle
réparation est nécessaire. Elle ne peut jamais construire le successeur à la
place de `executeRepair`.

Les constructions suivantes sont interdites :

```text
next := model.nextHead(...)
next := posterior(privateWorld, ...)
next := expectedNextState exporté
next := currentState + embedding non relié à repair
next fourni parallèlement à repair
```

### 4.3 Rôle du posterior

Le posterior ou la fibre compatible peut servir à :

- vérifier la réduction d’incertitude ;
- établir la compatibilité du monde réel ;
- prouver la fermeture locale ;
- calculer une métrique d’évaluation ;
- produire un certificat indépendant.

Il ne doit pas être l’état public suivant, sauf si une réalisation formelle
définit explicitement l’état public comme cette fibre et démontre que
`executeRepair` produit exactement cette fibre. Une égalité déclarative ne
suffit pas.

### 4.4 Deux niveaux de mémoire

Le plan distingue deux objets.

#### Mémoire d’exécution

```text
RuntimeMemory := List PublicRepairRecord
```

Elle est :

- publique ;
- lisible par l’agent ;
- transportée dans l’état suivant ;
- exempte de données privées ;
- étendue exactement par le record courant ;
- utilisée par la politique récurrente si le protocole l’autorise.

#### Histoire certifiée

```text
CertifiedHistory
```

Elle est une structure positive qui conserve, pour chaque étape :

```text
before
gap
use
transport
query
response
repair
after
after = executeRepair(before, repair)
GapClosedBy(before, world, gap, after)
effectivité éventuelle
lien avec le préfixe certifié précédent
```

La mémoire d’exécution ne contient pas nécessairement les termes de preuve.
L’histoire certifiée établit que chaque record public correspond à une
transition effectivement certifiée.

Le vérificateur peut les réunir dans un état certifié :

```text
CertifiedPublicState
  publicState : PublicState
  certifiedHistory : CertifiedHistory publicState
```

La politique ne reçoit que `publicState`. Le certificat final reçoit
`CertifiedPublicState`. Ainsi la certification est persistante au niveau du
système prouvé sans devenir un canal privé vers l’agent.

Cette distinction évite deux confusions :

- prétendre que `List RepairRecord` contient déjà les preuves ;
- exposer le monde privé à l’agent sous prétexte de conserver un certificat.

### 4.5 Conservation cumulative

Pour un préfixe certifié de longueur `n`, l’ajout d’une transition doit prouver :

```text
runtimeHistory(after) = runtimeHistory(before) ++ [publicRecord(repair)]
```

et :

```text
les n anciennes entrées restent présentes dans le même ordre
la nouvelle entrée correspond à la réparation exécutée
la nouvelle entrée ferme le gap courant
les n anciennes fermetures restent valides ou sont revalidées
```

La simple croissance de la longueur de la liste ne suffit pas.

### 4.6 Gap non trivial

Le gap doit avoir au moins :

- plusieurs indices réalisables ;
- plusieurs espèces réalisables lorsque le domaine en exige plusieurs ;
- un lien calculé avec l’état public courant ;
- une preuve d’ouverture avant la réparation ;
- une preuve de fermeture après la réparation ;
- une propriété de fraîcheur ou de non-récurrence sur l’orbite ouverte.

Une cible constante, par exemple « conflit d’action » à chaque étape, ne
constitue pas l’individuation exigée.

### 4.7 Politique apprise persistante

Le modèle appris doit transporter un état réellement causal :

```text
hiddenStateₙ₊₁ = recurrentUpdate(hiddenStateₙ, publicInputₙ, repairₙ)
```

ou une formulation équivalente explicitement justifiée.

Les tests doivent comporter des épisodes d’au moins deux transitions actives
afin de vérifier :

- que la réparation du pas `n` influence réellement le pas `n + 1` ;
- que la mémoire publique est effectivement relue ;
- qu’aucune donnée privée n’est introduite lors de cette relecture ;
- qu’une intervention sur la réparation modifie les descendants attendus.

## 5. Arborescence cible

Le dossier proposé est :

```text
v23_final/
  README.md
  CLAIM_REGISTRY.md
  PROTOCOL.md
  IMPLEMENTATION_STATUS.md
  DECISIONS_AND_RISKS.md
  MIGRATION_MANIFEST.json
  protocol.lock.json
  pyproject.toml
  schemas/
    public_state.schema.json
    public_repair_record.schema.json
    certified_step.schema.json
    trace.schema.json
    run_manifest.schema.json
    campaign_result.schema.json
  configs/
    development.json
    finite_certification.json
    tuning.json
    final.json
    preflight.json
  src/v23_final/
    __init__.py
    contracts.py
    public_state.py
    certified_history.py
    execution.py
    encoding.py
    traces.py
    policy.py
    models.py
    training.py
    quantized.py
    verification.py
    certification.py
    interventions.py
    causality.py
    information_flow.py
    no_go.py
    statistics.py
    provenance.py
    preflight.py
    campaign.py
    domains/
      __init__.py
      base.py
      finite_reference.py
      symbolic.py
      perceptual.py
  tests/
    test_public_private_boundary.py
    test_gap_individuation.py
    test_execute_repair.py
    test_certified_history.py
    test_multistep_recurrence.py
    test_finite_conformance.py
    test_quantized_inference.py
    test_all_branches.py
    test_information_flow.py
    test_interventions.py
    test_no_go.py
    test_falsification.py
    test_provenance.py
  scripts/
    build_finite_reference.py
    train_certifiable_agent.py
    export_quantized_agent.py
    certify_finite_domain.py
    run_interventions.py
    run_campaign.py
    freeze_and_run.py
    verify_bundle.py
    generate_lean_data.py
  artifacts/
    development/
    frozen/
```

L’arborescence Lean cible est :

```text
Meta/AdaptiveRepairability/
  FiniteMeasure.lean
  PublicTree.lean
  OperationalCharacterization.lean
  Synthesis.lean
  ExactPosterior.lean
  Countermodels.lean
  PositiveInstance.lean
  LegacyInstanceAdapters.lean
  Validation.lean

Meta/AI/V23Final/
  PublicState.lean
  CertifiedHistory.lean
  ExecuteRepair.lean
  FiniteConformance.lean
  PublicPolicy.lean
  QuantizedInference.lean
  AllBranches.lean
  InformationFlow.lean
  CausalNecessity.lean
  CumulativeMemory.lean
  FoundationalBridge.lean
  FinalCertificate.lean
```

Cette organisation évite de créer un second projet Lean autonome avec une
sémantique divergente. `Meta/AI` reste la source causale active ;
`Meta/AdaptiveRepairability` devient la source adaptative active seulement
après la promotion mécanique du lot V6.

## 6. Registre des affirmations

`CLAIM_REGISTRY.md` doit être créé avant l’implémentation. Pour chaque
affirmation, il contiendra :

```text
identifiant
énoncé exact
niveau : définition, test exhaustif, théorème, résultat empirique
portée
artefacts requis
preuve ou vérificateur d’autorité
contre-tests requis
statut : NOT_STARTED, PARTIAL, PASS, FAIL, NOT_RUN
```

Registre minimal :

```text
C01 séparation publique/privée
C02 exposition initiale uniquement par publishObservation
C03 réponse active uniquement par respond
C04 gap public, individué et non constant
C05 typage de la chaîne causale
C06 réparation intrinsèque
C07 executeRepair unique producteur du successeur
C08 fermeture locale du gap courant
C09 extension exacte de la mémoire publique
C10 histoire certifiée positive
C11 conservation cumulative
C12 récurrence multistep effective
C13 inference quantifiée exacte
C14 couverture de toutes les branches publiques réalisables
C15 interventions causales typées
C16 absence de bypass
C17 no-go passif
C18 no-go visible factorisé
C19 conformance Python/Lean
C20 promotion canonique de AdaptiveRepairability
C21 réalisation fondationnelle
C22 provenance scientifique complète
C23 campagne apprise exécutée
C24 réplication indépendante
```

Une affirmation non enregistrée ne doit pas apparaître dans le résumé public
du dossier.

## 7. Lots d’implémentation

### V0 — Gel du contrat

Objectif : rendre les critères de réussite non ambigus avant tout nouveau run.

Livrables :

- `README.md` ;
- `CLAIM_REGISTRY.md` ;
- `PROTOCOL.md` ;
- `DECISIONS_AND_RISKS.md` ;
- schémas JSON initiaux ;
- manifeste de migration ;
- règles de versionnement ;
- définition des portes ;
- séparation explicite entre développement et science confirmatoire.

Porte V0 :

- chaque affirmation possède une preuve attendue ;
- chaque terme central possède une définition unique ;
- aucune métrique empirique ne remplace une obligation structurelle ;
- aucune réussite de smoke n’est assimilée à un résultat scientifique.

### V1 — Frontière publique et privée

Objectif : rendre impossible par construction l’accès direct au monde privé.

Travail :

- définir les types publics et privés ;
- établir une liste positive des données accessibles à chaque fonction ;
- retirer `world_id`, cible, réponse future, clé OOD et réparation correcte de
  l’état et de la mémoire publics ;
- définir `publishObservation` comme canal d’exposition initiale ;
- définir `respond` comme unique canal sémantique actif après requête ;
- séparer les données de certification hors de l’entrée de l’agent ;
- créer des contrôleurs de sérialisation qui refusent les champs privés.

Preuves et tests :

- audit statique des signatures ;
- audit dynamique de taint sur les valeurs ;
- renommage bijectif des identifiants privés, à contenu de monde constant, sans
  changement des sorties publiques ;
- mondes différents mais publiquement indistinguables donnant la même décision
  avant réponse ;
- échec volontaire si un identifiant privé entre dans l’encodeur public.

Porte V1 :

```text
aucune fonction publique ne lit PrivateWorld
et
publishObservation est l’unique exposition initiale
et
respond est le seul canal privé de la boucle active
et
RuntimeMemory est entièrement publique
```

### V2 — Gap public non trivial

Objectif : rétablir l’individuation réelle de la frontière.

Travail :

- porter les espèces et indices de gaps du domaine fini de référence ;
- définir le calcul du gap depuis l’état public ;
- distinguer absence de gap, gap courant et conflit de typage ;
- interdire une cible constante ;
- définir l’ouverture avant transition et la fermeture après transition ;
- établir la fraîcheur sur les orbites ouvertes.

Preuves et tests :

- au moins deux indices réalisables ;
- toutes les espèces prévues sont atteignables ;
- mutation de l’état public pouvant changer le gap ;
- mêmes données privées et états publics différents pouvant produire des gaps
  différents ;
- aucune dépendance directe au monde privé.

Porte V2 :

```text
le gap est public, calculé, individué, ouvert avant réparation
et non réductible à une constante de protocole
```

### V3 — Exécution intrinsèque de la réparation

Objectif : faire de la réparation la cause structurelle unique du successeur.

Travail :

- définir `PublicRepairRecord` ;
- définir `IntrinsicRepair` ;
- porter ou spécialiser `executeRepair` ;
- supprimer toute valeur `next` calculée parallèlement ;
- conserver le posterior comme outil de vérification ;
- rendre la stase explicite et séparée ;
- prouver l’égalité entre transition opérationnelle et `executeRepair`.

Preuves et tests :

- deux réparations qui diffèrent sur un champ effectivement
  exécuté doivent produire la différence publique prescrite par ce champ ;
- même réparation donne le même successeur ;
- toute transition active possède un témoin de réparation ;
- aucune transition active ne peut contourner `executeRepair` ;
- mutation du champ `next` exporté sans mutation de la réparation est refusée ;
- mutation de la réparation recalcule les descendants.

Porte V3 :

```text
nextState = executeRepair(currentState, repair)
```

doit être une égalité calculée ou prouvée, jamais un booléen fourni.

### V4 — Mémoire publique et histoire certifiée

Objectif : conserver l’événement causal sans exposer le monde privé.

Travail :

- définir `RuntimeMemory` comme liste de records publics ;
- définir `CertifiedStep` ;
- définir `CertifiedHistory` inductivement ;
- relier chaque entrée publique à une étape certifiée ;
- prouver l’extension exacte ;
- prouver la conservation du préfixe ;
- prouver la fermeture du gap courant ;
- définir la conservation ou la revalidation des fermetures antérieures.

Forme conceptuelle :

```text
CertifiedHistory.nil

CertifiedHistory.step :
  history before
  → certified transition before after
  → runtimeHistory(after) =
      runtimeHistory(before) ++ [publicRecord(repair)]
  → CertifiedHistory after
```

Porte V4 :

```text
la mémoire d’exécution conserve les records publics
et
l’histoire certifiée conserve leurs justifications
et
aucune preuve n’est simulée par un drapeau
```

### V5 — Réalisation finie exacte

Objectif : obtenir un oracle de conformance exhaustif avant l’apprentissage.

Travail :

- porter le domaine fini historique sans modifier les scripts cités ;
- produire une nouvelle implémentation `finite_reference.py` ;
- construire toutes les transitions naturelles ;
- couvrir les stases et les refus typés ;
- couvrir toutes les interventions réalisables ;
- comparer objet par objet avec la réalisation Lean canonique ;
- générer des données Lean, jamais des propositions admises.

Comparaison minimale :

```text
état initial
fibre compatible
gap
usage
transport
requête
réponse
réparation
observation suivante
mémoire suivante
état final
fermeture
préfixe historique
raison de refus éventuelle
```

Porte V5 :

- couverture exhaustive du domaine fini ;
- zéro omission ;
- zéro duplication ;
- zéro divergence Python/Lean ;
- mutations adversariales correctement refusées.

### V6 — Promotion canonique d’`AdaptiveRepairability`

Objectif : intégrer mécaniquement la théorie déjà présente dans l’artefact de
publication à la source Lean active, sans la modifier ni créer deux autorités.

Travail :

- copier les neuf modules sources vers `Meta/AdaptiveRepairability/` ;
- préserver leurs namespaces, déclarations et blocs `AXIOM_AUDIT` ;
- enregistrer les hashes avant et après promotion ;
- vérifier l’identité textuelle ou documenter chaque différence strictement
  mécanique d’import ;
- orienter les nouveaux modules vers la copie active ;
- définir la procédure de régénération de l’artefact de publication ;
- interdire toute modification indépendante de la copie publiée.

La promotion ne doit pas être mélangée au pont v23. Toute évolution théorique
ultérieure constitue un changement séparé, revu après la fermeture de
l’identité de migration.

Porte V6 :

```text
Meta/AdaptiveRepairability est la source active canonique
et
l’artefact publié n’est plus une dépendance de développement
et
la promotion n’a modifié aucun énoncé
```

### V7 — Pont Lean de conformance

Objectif : relier les données finies au noyau `Meta/AI` sans créer une seconde
sémantique.

Travail :

- définir les adaptateurs vers `ActiveSemanticClosureSystem` ;
- spécialiser `CertifiedInferenceStep` ;
- prouver l’équivalence de `executeRepair` ;
- reconstituer les branches à partir des données réifiées ;
- prouver la couverture des entrées ;
- relier la mémoire publique à `CertifiedHistory` ;
- ajouter les audits constructifs requis.

Contraintes Lean :

- aucun axiome ;
- aucune dépendance à `Classical` ;
- aucune dépendance à `propext` ;
- aucune dépendance à `Quot.sound` ;
- aucun `sorry` ;
- aucun pont terminal externe ;
- un unique bloc `AXIOM_AUDIT` final par fichier modifié.

Porte V7 :

```text
les données importées sont recalculées
et
les déclarations principales n’ont aucune dépendance axiomatique
```

### V8 — Modèle appris réellement persistant

Objectif : apprendre la politique causale sans perdre la dynamique multistep.

Travail :

- définir l’encodeur public ;
- définir l’encodeur de mémoire publique ;
- définir l’état latent persistant ;
- entraîner les têtes dans l’ordre causal ;
- faire dépendre la mise à jour récurrente de la réparation exécutée ;
- entraîner sur des épisodes comportant plusieurs transitions actives ;
- conserver des baselines de capacité comparable ;
- interdire une tête directe `NextHead`.

Têtes minimales :

```text
GapHead
UseHead
TransportHead
QueryHead
RepairHead
```

Le choix entre les deux architectures suivantes doit être gelé à V0 :

```text
A. GapHead total :
   produit closed ou un gap ouvert individué ;

B. détecteur public certifié :
   produit closed ou un domaine de gaps ouverts,
   puis GapHead sélectionne un gap dans ce domaine.
```

Dans les deux cas, l’absence de gap conduit à la stase. Une éventuelle
`TerminalActionHead` est évaluée seulement sur un état certifié fermé. Elle
n’est pas une `NextHead`.

La réponse reste produite par le domaine, jamais par une cible privée injectée
dans les entrées.

Tests décisifs :

- ablation de la mémoire ;
- permutation de l’historique ;
- intervention sur la réparation au pas précédent ;
- comparaison d’épisodes partageant le présent mais différant par leur passé ;
- vérification que l’état réparé influence les logits futurs ;
- gradient causal non nul sur la voie prescrite ;
- à l’inférence, absence de valeur, activation ou branche de contrôle provenant
  d’un champ privé interdit.

Les cibles privées éventuellement autorisées pour la supervision doivent être
isolées dans le calcul de perte. Elles ne peuvent pas être concaténées aux
entrées, recopiées dans la mémoire ou rendues disponibles à l’inférence. Le
rapport doit distinguer explicitement flux d’entraînement et flux d’inférence.

Porte V8 :

```text
la politique est publique
et
la récurrence est effective
et
la réparation modifie réellement les décisions ultérieures
```

### V9 — Quantification et inférence exacte

Objectif : réutiliser le noyau quantifié et la réalisation finie existants,
puis certifier le calcul réel du modèle retenu sans le remplacer par une table
de cibles.

Travail :

- conserver `QuantizedInference.lean` comme noyau de calcul ;
- réutiliser la chaîne existante des 697 décisions comme test de non-régression ;
- figer les poids ;
- spécifier les conversions et saturations ;
- spécifier l’arrondi ;
- spécifier les accumulateurs ;
- spécifier l’argmax et ses égalités ;
- exporter les poids et entrées ;
- recalculer activations, logits et décisions dans Lean ;
- prouver les marges nécessaires ;
- couvrir les cinq familles de décisions.

Interdictions :

```text
prediction := target
logits exportés acceptés sans recalcul
lookup de la décision attendue
verdict JSON utilisé comme preuve
```

Porte V9 :

- parité bit-exacte ;
- activations et logits recalculés ;
- argmax prouvé ;
- couverture exhaustive des entrées certifiables ;
- tests de mutation des poids, entrées, échelles et arrondis.

### V10 — Toutes les branches publiques

Objectif : passer d’une trace naturelle à une politique certifiée.

Travail :

- énumérer les réponses réalisables à chaque requête ;
- construire l’arbre public complet ;
- appliquer la politique quantifiée sur chaque branche ;
- prouver la fermeture sur chaque feuille terminale ;
- prouver la conservation cumulative le long de chaque chemin ;
- justifier la finitude de l’arbre par la mesure interne de conflit déjà portée
  par `AdaptiveRepairability`, ou par une autre donnée positive intrinsèque ;
- relier l’arbre au cadre d’`AdaptiveRepairability` ;
- distinguer branches impossibles, refus typés et branches certifiées.

La terminaison ne peut pas être obtenue en ajoutant après coup un rang externe,
une fenêtre arbitraire ou une borne sans lien avec la dynamique.

Porte V10 :

```text
la preuve porte sur toutes les réponses réalisables
et non uniquement sur la réponse du monde courant
```

### V11 — Information, causalité et absence de bypass

Objectif : établir que la chaîne n’est pas seulement présente mais nécessaire
dans la classe testée.

Travail :

- audit positif des dépendances de données ;
- audit dynamique de taint ;
- interventions appariées sur observation, gap, usage, transport, requête,
  réponse et réparation ;
- recalcul de tous les descendants ;
- maintien fixe de l’amont ;
- refus des injections mal typées ;
- test direct d’un bypass du successeur ;
- médiation et ablations preregistrées ;
- no-go passif et visible factorisé appariés.

Une intervention valide doit :

```text
conserver l’amont
modifier le nœud ciblé
recalculer l’aval
respecter les types dépendants
produire ou réfuter la propriété causale attendue
```

Porte V11 :

- zéro fuite privée ;
- zéro bypass accepté ;
- effets descendants conformes ;
- no-go établis dans les classes précisément définies ;
- falsificateurs capables de faire échouer chaque vérificateur pertinent.

### V12 — Réalisation fondationnelle

Objectif : raccorder le système appris à la théorie générale sans extrapolation
verbale.

Travail :

- construire l’instance fondationnelle depuis les objets effectifs ;
- identifier l’état, le gap, la mémoire et l’avance ;
- prouver les égalités de transport nécessaires ;
- relier les étapes apprises à `CertifiedInferenceStep` ;
- relier les chemins à la mémoire cumulative ;
- établir la fraîcheur ou la non-récurrence requise ;
- expliciter exactement la portée de l’universalisation.

La réalisation ne peut pas avoir la forme :

```text
si un morphisme externe existe, alors le résultat suit
```

Le morphisme ou l’adaptateur doit être une donnée intrinsèque construite et ses
lois doivent être prouvées.

Porte V12 :

```text
les objets appris instancient effectivement la structure fondationnelle
et
les égalités de commutation sont démontrées
```

### V13 — Campagne scientifique

Objectif : évaluer la portée empirique après la fermeture structurelle.

Travail :

- geler le protocole ;
- geler les partitions et l’OOD avant entraînement ;
- séparer tuning, runs finaux et réplication ;
- exécuter les domaines prévus ;
- utiliser les seeds preregistrées sans remplacement ;
- entraîner les baselines appariées ;
- exécuter les interventions ;
- calculer les statistiques preregistrées ;
- produire les checkpoints et traces ;
- vérifier les bundles ;
- répéter sur l’infrastructure indépendante prévue.

Chaque exécution scientifique doit :

- utiliser une copie du script contenant timestamp et SHA-256 ;
- produire des sorties portant le même suffixe ;
- enregistrer la commande complète ;
- enregistrer le hash du script ;
- enregistrer environnement, seeds, partitions et plateforme ;
- écrire le marqueur de fin uniquement après succès de tous les contrôles.

Porte V13 :

- toutes les cellules prévues ont un statut ;
- aucune cellule absente n’est comptée comme succès ;
- les résultats statistiques et structurels sont séparés ;
- les bundles sont rejouables ;
- la réplication est identifiée distinctement.

### V14 — Certificat final et publication

Objectif : produire un point d’entrée unique dont chaque champ renvoie à une
preuve ou un artefact vérifiable.

Livrables :

- `Meta/AI/V23Final/FinalCertificate.lean` ;
- manifeste final des déclarations ;
- rapport complet des audits d’axiomes ;
- manifeste de provenance ;
- matrice affirmation-preuve ;
- rapport de falsification ;
- rapport de campagne ;
- limites et non-affirmations ;
- bundle reproductible.

Porte V14 :

```text
toutes les affirmations publiques sont couvertes
et
toutes les dépendances sont traçables
et
aucune porte manquante n’est transformée en succès
```

## 8. Ordre de dépendance

L’ordre recommandé est :

```text
V0  contrat
 ↓
V1  frontière publique/privée
 ↓
V2  gap non trivial
 ↓
V3  executeRepair unique
 ↓
V4  mémoire certifiée
 ↓
V5  référence finie
 ↓
V6  promotion de AdaptiveRepairability
 ↓
V7  conformance Lean
 ↓
V8  modèle persistant
 ↓
V9  quantification exacte
 ↓
V10 toutes les branches
 ↓
V11 causalité et no-go
 ↓
V12 réalisation fondationnelle
 ↓
V13 campagne
 ↓
V14 certificat final
```

Des travaux d’infrastructure de V13 peuvent être préparés plus tôt, mais aucun
run confirmatoire ne doit être lancé avant le gel des contrats structurels dont
il dépend.

## 9. Matrice de validation

| Porte | Objet | Validation d’autorité |
|---|---|---|
| V0 | contrat | revue du registre et lock |
| V1 | séparation | types, taint, tests adversariaux |
| V2 | gap | couverture et preuves d’ouverture |
| V3 | transition | égalité avec `executeRepair` |
| V4 | mémoire | structure inductive et préfixe exact |
| V5 | référence finie | énumération exhaustive |
| V6 | théorie adaptative | promotion mécanique auditée |
| V7 | pont formel | preuves Lean constructives |
| V8 | apprentissage | épisodes multistep et interventions |
| V9 | quantification | recalcul bit-exact |
| V10 | politique | arbre de toutes les branches |
| V11 | causalité | interventions, taint et no-go |
| V12 | fondation | instance et lois de commutation |
| V13 | science | campagne gelée et réplication |
| V14 | synthèse | certificat final et matrice complète |

Chaque porte utilise :

```text
NOT_STARTED
PARTIAL
PASS
FAIL
NOT_RUN
```

`PARTIAL` et `NOT_RUN` ne sont jamais assimilés à `PASS`.

## 10. Stratégie de tests

### 10.1 Tests unitaires

Ils couvrent :

- sérialisation canonique ;
- types et masques ;
- calcul du gap ;
- autorisations ;
- transport ;
- construction de requête ;
- construction de réparation ;
- exécution de réparation ;
- extension de mémoire ;
- quantification ;
- déterminisme ;
- provenance.

### 10.2 Tests de propriétés

Ils vérifient :

- déterminisme des fonctions pures ;
- absence de champ privé dans les sorties publiques ;
- exactitude de l’extension historique ;
- conservation de l’ordre ;
- idempotence des vérificateurs ;
- rejet des entrées mal typées ;
- stabilité des identifiants de contenu.

### 10.3 Tests exhaustifs

Ils portent sur :

- tous les états du domaine fini ;
- toutes les réponses réalisables ;
- toutes les transitions naturelles ;
- toutes les stases ;
- tous les refus typés ;
- toutes les interventions finies ;
- toutes les entrées de l’agent certifiable.

### 10.4 Tests adversariaux

Ils mutent au minimum :

- gap ;
- indice ;
- espèce ;
- usage ;
- transport ;
- requête ;
- réponse ;
- réparation ;
- successeur ;
- record historique ;
- ordre historique ;
- poids ;
- activation ;
- logits ;
- décision ;
- hash ;
- seed ;
- partition ;
- statut de porte.

Chaque vérificateur doit être accompagné d’au moins une mutation qu’il refuse.

### 10.5 Tests multistep

Ils comprennent au minimum :

- deux transitions actives consécutives ;
- réutilisation réelle de la mémoire ;
- divergence de deux histoires ayant le même état visible courant lorsque le
  protocole affirme que l’histoire appartient à l’identité causale ;
- intervention au pas `n` et effet contrôlé au pas `n + 1` ;
- conservation des fermetures des pas antérieurs.

## 11. Risques prioritaires

### R1 — Fuite du monde privé

Risque : l’identifiant du monde, la cible ou une réponse future entre dans
l’état public ou sa mémoire.

Réponse : allowlist de types, taint dynamique, permutation des identifiants,
audit des sérialisations et des tenseurs.

### R2 — Réparation décorative

Risque : la réparation est prédite mais le successeur est calculé autrement.

Réponse : supprimer tout `next` parallèle et imposer l’égalité
`next = executeRepair(state, repair)`.

### R3 — Certification déclarative

Risque : la fermeture est attestée par un booléen produit par la trace.

Réponse : recalcul indépendant puis reconstruction d’une preuve positive.

### R4 — Mémoire seulement nominale

Risque : la liste grandit mais n’influence pas l’étape suivante, ou ne conserve
pas les certifications.

Réponse : structure `CertifiedHistory`, tests multistep et interventions sur le
passé.

### R5 — Gap constant

Risque : une tête réussit en prédisant toujours la même classe.

Réponse : domaine couvrant plusieurs gaps, métriques par espèce et
contre-exemples adversariaux.

### R6 — Quantification simulée

Risque : la décision attendue est réimportée au lieu d’être recalculée.

Réponse : réification des poids et du calcul complet jusqu’à l’argmax.

### R7 — Une trace remplace une politique

Risque : seule la branche naturelle est certifiée.

Réponse : arbre exhaustif de toutes les réponses publiques réalisables.

### R8 — Double noyau formel

Risque : le sous-projet final définit une version plus faible du système.

Réponse : import et spécialisation du noyau `Meta/AI`, avec tests de
conformance.

### R9 — Campagne lancée trop tôt

Risque : des ressources importantes sont consommées avant la fermeture des
obligations structurelles.

Réponse : préflight fail-closed et dépendance explicite de V13 envers V0–V12.

### R10 — Universalisation excessive

Risque : une réalisation particulière est présentée comme une preuve portant
sur toute mathématique.

Réponse : séparer interface générale, réalisations prouvées et conjectures de
portée.

## 12. Critère de complétude du dossier

`v23_final` est complet seulement si les conditions suivantes sont
simultanément satisfaites :

- le contrat est gelé et traçable ;
- la frontière publique/privée résiste aux audits statiques et dynamiques ;
- le gap est public, ouvert, individué et non constant ;
- l’observation initiale est exposée uniquement par `publishObservation` ;
- après cette exposition, `respond` est l’unique apport sémantique privé de la
  boucle active ;
- la réparation est intrinsèque ;
- `executeRepair` est l’unique source du successeur ;
- le gap courant est certifié fermé dans le successeur ;
- la mémoire publique est étendue exactement ;
- l’histoire certifiée conserve toutes les étapes ;
- les anciennes certifications sont préservées ou revalidées ;
- la réalisation finie est exhaustive ;
- Python et Lean calculent les mêmes objets ;
- le modèle est réellement persistant sur plusieurs étapes ;
- l’inférence quantifiée est recalculée exactement ;
- toutes les branches publiques réalisables sont certifiées ;
- les interventions établissent les dépendances causales revendiquées ;
- les bypass et fuites sont falsifiés ;
- les no-go sont établis dans leurs classes exactes ;
- l’instance fondationnelle est construite ;
- la campagne scientifique est gelée, exécutée et rejouable ;
- le certificat final Lean est constructif et sans axiome ;
- chaque affirmation publique est reliée à une preuve ou à un artefact précis ;
- les limites sont publiées avec les résultats.

Tant qu’une de ces conditions manque, le dossier doit annoncer exactement le
niveau atteint et conserver le reste sous le statut `PARTIAL` ou `NOT_RUN`.

## 13. Premier incrément recommandé

Le premier incrément ne doit contenir ni entraînement GPU ni nouvelle campagne.

Il doit livrer :

```text
1. le squelette documentaire de v23_final ;
2. le registre des affirmations ;
3. les types PublicState, RuntimeMemory et CertifiedHistory ;
4. la frontière PrivateWorld/publishObservation/respond ;
5. OperationalGap non constant ;
6. IntrinsicRepair et executeRepair ;
7. une trajectoire finie de deux transitions actives ;
8. l’extension exacte de mémoire ;
9. la certification locale des deux gaps ;
10. un test démontrant qu’aucun identifiant privé n’entre dans la mémoire.
```

Ce premier incrément ferme le risque architectural principal. Il fournit
ensuite une base stable pour la conformance exhaustive, l’apprentissage,
l’inférence quantifiée et le certificat final.
