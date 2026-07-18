# Plan d'implementation maximal du pont v23 vers la reparabilite adaptative

## 0. Statut normatif

Ce document specifie le travail necessaire pour faire de l'agent latent appris
v23 une instance complete, publique, causale et non triviale de la theorie
`AdaptiveRepairability`.

Il ne remplace pas :

- `Docs/ValidationIntegraleFermetureSemantiqueIA.md` ;
- `Empirical/v23_gap_driven_active_semantic_closure/SCIENTIFIC_PROTOCOL.md` ;
- les portes experimentales G0-G8 ;
- la campagne apprise multi-domaines, multi-seeds, OOD et repliquee.

Il ajoute le contrat manquant entre ces elements :

```text
checkpoint appris v23
→ inference quantifiee bit-exacte
→ latents caches explicitement calcules
→ politique publique adaptative
→ arbre couvrant toutes les reponses realisables
→ fermeture et conservation certifiees
→ instance de CertifiedRepairableAt
→ no-go apparies
→ certificat de campagne
```

La conformite a une seule trace naturelle est insuffisante. Une instance qui
copie le monde, la reponse ou la cible dans le latent est invalide. Une instance
qui remplace la provenance, le frame, le transport ou la causalite par `True`
est invalide. Une preuve portant uniquement sur le petit modele symbolique est
un test de conformance, pas le resultat v23.

## 1. Cible scientifique exacte

### 1.1 Resultat vise

La cible finale est un paquet Lean clos de la forme conceptuelle suivante :

```lean
structure V23LearnedAdaptiveRepairabilityCertificate where
  learnedModel : QuantizedModel
  publicEnvironment : FinitePublicEnvironment
  decisionDoctrine : PublicDecisionDoctrine publicEnvironment
  publicPolicy : V23PublicPolicy learnedModel publicEnvironment
  learnedLatentSemantics : V23LearnedLatentSemantics learnedModel
  foundationalRealization : V23LearnedFoundationalRealization learnedModel
  adaptiveFoundationalAlignment :
    V23AdaptiveFoundationalAlignment publicPolicy foundationalRealization
  compositionalTransport : V23LearnedCompositionalTransport publicPolicy
  allBranchesCertified : V23AllBranchesCertified publicPolicy
  certifiedRepairability :
    CertifiedRepairableAt decisionDoctrine initialState obligation
  causalChain : V23CausalChainCertificate publicPolicy
  cumulativeConservation : V23CumulativeConservation publicPolicy
  passiveNoGo : V23PassiveNoGo publicEnvironment
  visibleFactoredNoGo : V23VisibleFactoredNoGo publicEnvironment
  nontriviality : V23BridgeNontriviality learnedModel publicEnvironment
```

Le nom exact pourra suivre les conventions du depot, mais aucun champ
substantiel de ce paquet ne pourra etre omis ou remplace par une proposition
universellement vraie.

Le theoreme public principal devra avoir la forme :

```lean
def v23LearnedAdaptiveRepairabilityCertificate :
    V23LearnedAdaptiveRepairabilityCertificate := ...
```

et non :

```text
si un pont externe existe, alors le certificat existe ;
si la trace est correcte, alors la fermeture est correcte ;
si les sorties Python sont fiables, alors Lean les accepte.
```

Les donnees necessaires doivent etre reifiees et recalculees dans Lean. Les
hashes etablissent la provenance des artefacts ; ils ne remplacent jamais une
preuve de correction.

### 1.2 Enonce mathematique autorise apres fermeture

Le resultat formel et constructif autorise sera :

> Il existe un agent fini a representation latente apprise et quantifiee dont
> la non-coincidence locale calculee depuis l'etat public engendre un usage,
> une requete, une reponse et une reparation intrinsique. Cette reparation
> produit l'etat public suivant, ferme le conflit decisionnel courant, conserve
> les certificats anterieurs et peut etre iteree. Sous la meme frontiere
> d'information, les classes passive et visible-factorisee formalisees ne
> peuvent garantir la meme fermeture.

Cet enonce ne signifie pas :

- que tout latent appris est reparable ;
- que tout environnement partiellement observable admet une strategie gagnante ;
- que tout OOD est resolu ;
- que tout systeme actif concurrent est domine ;
- que les resultats statistiques sont des theoremes Lean ;
- que la nouveaute historique est etablie sans comparaison bibliographique.

### 1.3 Relation stricte avec le v23 initial

La nouvelle cible est :

```text
v23 integral initial
+
instance formelle de AdaptiveRepairability
+
preuve des latents caches et de leurs dependances
+
certificat de toutes les branches publiques
```

Elle n'autorise jamais la reduction suivante :

```text
campagne complete v23
↦
un checkpoint de developpement et une trace certifiee
```

Le niveau fini et le checkpoint certifiable autorisent la campagne. Ils ne la
remplacent pas.

## 2. Etat de depart et lacune exacte

### 2.1 Elements deja disponibles

Le depot contient deja :

- le protocole v23 integral ;
- l'environnement fini exact ;
- le schema de trace canonique ;
- les dix-huit interventions typees ;
- les no-go passif et visible-factorise finis ;
- un agent a cinq tetes MLP ;
- un checkpoint quantifie de developpement ;
- l'inference `Int8/Int32` bit-exacte ;
- 697 obligations locales certifiees ;
- la reification des poids, entrees et sorties dans Lean ;
- la couverture semantique des cinq familles de tetes ;
- les realisations finie et ouverte de la fermeture active ;
- la theorie generale finie `AdaptiveRepairability` ;
- son no-go public adaptatif ;
- sa caracterisation operationnelle ;
- sa synthese bien fondee ;
- ses contre-modeles ;
- ses adaptateurs vers les trajectoires symboliques existantes.

### 2.2 Lacune restante

Les deux chaines suivantes existent encore separement :

```text
poids v23
→ inference quantifiee
→ decisions locales certifiees
```

et :

```text
FinitePublicEnvironment
→ PublicRepairTree
→ CertifiedRepairabilityWitness
```

Il manque une construction qui identifie effectivement :

```text
etat public de AdaptiveRepairability
  = etat accessible encode par v23 ;

politique publique
  = calcul des cinq tetes quantifiees ;

branches publiques
  = toutes les reponses realisables, pas seulement la reponse du monde courant ;

fermeture locale
  = decision correcte sur toute la fibre publique terminale ;

frame
  = conservation concrete de la memoire et des certificats anterieurs ;

transition
  = execution concrete de la reparation predite ;

latent appris
  = activations cachees calculees depuis les poids, pas etiquette semantique.
```

## 3. Source canonique et architecture du depot

### 3.1 Une seule source formelle active

Les modules `AdaptiveRepairability` sont actuellement presents dans un artefact
de publication autonome. L'implementation active ne doit pas entretenir deux
copies modifiables divergentes.

La cible architecturale est :

```text
Meta/AdaptiveRepairability/
  FiniteMeasure.lean
  PublicTree.lean
  OperationalCharacterization.lean
  Synthesis.lean
  ExactPosterior.lean
  Countermodels.lean
  Validation.lean
  PositiveInstance.lean
  LegacyInstanceAdapters.lean
```

Ces fichiers deviennent la source canonique du depot actif. L'artefact de
publication est regenere ou synchronise depuis une revision gelee ; il ne sert
pas de seconde branche de developpement.

La migration doit etre purement mecanique avant toute extension. Elle doit
conserver les contenus, les namespaces, les audits et la compilation de
l'artefact existant.

### 3.2 Nouveaux modules du pont

Le pont v23 doit etre separe de la theorie generale :

```text
Meta/AI/V23AdaptiveRepairability/
  LearnedLatent.lean
  PublicState.lean
  PublicEnvironment.lean
  ModelPolicy.lean
  PublicTreeCompiler.lean
  DecisionDoctrine.lean
  FoundationalAlignment.lean
  CausalChain.lean
  CumulativeConservation.lean
  Interventions.lean
  MatchedNoGo.lean
  CertifiedInstance.lean
  CampaignCertificate.lean
  Validation.lean
```

Les donnees generees restent dans les modules quantifies existants. Aucun poids
ni catalogue massif ne doit etre duplique dans le pont.

L'ordre d'import cible est :

```text
AdaptiveRepairability
QuantizedInference
QuantizedCertifiedAgent
QuantizedCertifiedAgentSemanticClosure
        ↓
LearnedLatent
        ↓
PublicState
        ↓
PublicEnvironment
        ↓
ModelPolicy
        ↓
PublicTreeCompiler
        ↓
DecisionDoctrine
        ↓
FoundationalAlignment
        ↓
CausalChain + CumulativeConservation + Interventions + MatchedNoGo
        ↓
CertifiedInstance
        ↓
CampaignCertificate
        ↓
Validation
```

Le Core ne doit pas importer cette specialisation.

### 3.3 Nouveaux scripts Python additifs

Les scripts v23 existants ont deja produit des artefacts de developpement. Ils
ne doivent pas etre modifies pour ajouter le pont. Les variantes sont de
nouveaux fichiers, par exemple :

```text
Empirical/v23_gap_driven_active_semantic_closure/
  export_hidden_activations_v23.py
  verify_hidden_alignment_v23.py
  compile_public_policy_tree_v23.py
  verify_public_policy_tree_v23.py
  certify_adaptive_repairability_bridge_v23.py
  verify_adaptive_repairability_bridge_v23.py
  falsify_adaptive_repairability_bridge_v23.py
  audit_adaptive_information_flow_v23.py
  test_hidden_alignment_v23.py
  test_public_policy_tree_v23.py
  test_adaptive_repairability_bridge_v23.py
```

Les noms finaux peuvent etre precises avant le premier run, mais chaque
responsabilite doit rester separee entre producteur, verificateur independant,
falsificateur et test. Aucun de ces fichiers ne peut reecrire un resultat
historique.

## 4. Representation latente apprise

### 4.1 Ce qui compte comme latent reel

Le latent v23 peut etre discret et quantifie. Il n'a pas besoin d'etre continu.
Il doit cependant etre une activation interne calculee par les poids appris.

Pour chaque tete, l'inference doit exposer :

```text
entree publique
→ preactivation cachee Int32
→ arrondi ties-to-even
→ saturation Int8
→ ReLU
→ latent cache Int8
→ logits Int32
→ classe canonique
```

L'API Lean doit separer ces etages. Une cible possible est :

```lean
structure QuantizedHiddenEvaluation
    (head : QuantizedHead)
    (input : List Int) where
  preactivation : List Int
  hidden : List Int
  logits : List Int
  decision : Nat
  preactivation_eq :
    preactivation = affine head.hiddenWeights head.hiddenBias input
  hidden_eq :
    hidden = quantizedRelu head.hiddenShift preactivation
  logits_eq :
    logits = affine head.outputWeights head.outputBias hidden
  decision_eq :
    decision = canonicalArgmax head.validClasses logits
```

Les longueurs, bornes `Int8`, dimensions et classes valides doivent etre portees
par les types ou prouvees explicitement.

### 4.2 Latents de la chaine a cinq tetes

Le modele v23 n'utilise pas necessairement un unique vecteur partage. Il utilise
une chaine de mediateurs appris. Le pont doit donc porter au minimum :

```text
zGap
zUse
zTransport
zQuery
zRepair
```

avec les dependances exactes :

```text
etat public encode
→ zGap → gap

etat public encode + gap
→ zUse → use

etat public encode + gap + use
→ zTransport → transport

etat public encode + gap + use + transport
→ zQuery → query

etat public encode + gap + use + transport + query + response
→ zRepair → repair
```

Si l'implementation effective differe, le graphe est extrait du code et du
checkpoint, puis documente exactement. Il est interdit de presenter comme
dependance causale un champ qui n'est pas consomme par l'entree de la tete
suivante.

### 4.3 Preuves minimales de non-trivialite latente

Le certificat doit contenir des temoins calcules de chacun des faits suivants :

```text
deux etats publics produisent des latents differents ;
deux etats semantiquement differents peuvent partager la meme vue initiale ;
au moins deux classes de gap sont produites ;
au moins deux usages sont produits ;
au moins deux transports sont produits ;
au moins deux requetes sont produites ;
un meme prefixe causal avec deux reponses admissibles produit deux repairs differents ;
les repairs differents produisent deux successeurs differents ;
le latent n'est ni le monde, ni la cible, ni la reponse finale recopies ;
la projection publique n'est pas constante ;
le modele ne peut pas reconstruire le monde prive depuis un champ explicitement fourni.
```

Une simple inegalite de dimension ne prouve pas la derniere propriete. La preuve
doit venir de l'interface d'entree, de l'existence de mondes publiquement
indiscernables et de la non-interference de la politique.

### 4.4 Provenance apprise et exclusion d'une table rebaptisee

Le certificat doit distinguer trois objets :

```text
modele semantique de reference
  calcule les bonnes decisions pour verifier ;

modele quantifie appris
  calcule les latents et decisions effectivement executes ;

catalogue de certification
  enumere les obligations sans fournir leur reponse a l'inference.
```

Le modele principal doit provenir d'une procedure d'entrainement gelee. Le
bundle doit contenir le checkpoint avant quantification, le checkpoint apres
quantification, la regle de conversion et les journaux permettant de retrouver
la mise a jour retenue sans selection silencieuse.

Sont insuffisants pour la revendication de latent appris :

- une table ecrite manuellement de l'etat vers la classe correcte ;
- des poids construits directement depuis le catalogue de test ;
- un encodeur contenant la cible ou la classe attendue ;
- une selection du premier checkpoint reussi sans publication des essais
  precedents ;
- une certification limitee aux exemples ayant servi a choisir les poids.

Le niveau fini peut utiliser une enumeration exhaustive pour certifier le
checkpoint apres entrainement. Cette enumeration ne doit pas etre une entree du
modele et ne transforme pas une recherche exhaustive de poids en apprentissage.

### 4.5 Necessite causale du latent

Exposer une activation cachee ne suffit pas. Pour chaque tete, il faut etablir :

```text
sortie = decodeur(latent) ;
aucun chemin calculatoire entree → sortie ne contourne latent ;
il existe une intervention admissible sur latent qui change la sortie ;
la permutation des latents entre exemples apparies degrade la decision selon
le critere preregistre ;
les variables non ciblees restent invariantes jusqu'au premier descendant
causal attendu.
```

Au niveau empirique appris, l'analyse de mediation doit estimer l'effet du
latent naturel, du latent neutralise et du latent croise. Au niveau fini Lean,
le calcul quantifie doit verifier les interventions discretes exactes sur le
catalogue preregistre. Une correlation entre latent et classe ne suffit pas.

## 5. Frontiere publique et monde prive

### 5.1 Etat public v23

L'etat public doit contenir exactement les donnees accessibles a l'agent :

```lean
structure V23PublicState where
  observation : Observation
  candidate : Candidate
  repairMemory : RepairMemory
  stage : Stage
  encoding : EncodedAgentState
  encoding_eq : encoding = encodeAgentState observation candidate repairMemory stage
```

Le monde, la cible correcte, la fibre semantique calculee par l'evaluateur et
les labels d'apprentissage n'en font pas partie.

### 5.2 Etat prive d'execution

Le monde intervient seulement pour :

- produire l'observation initiale selon l'environnement ;
- produire la reponse a une requete autorisee ;
- calculer la semantique de correction ;
- verifier la compatibilite et la fermeture ;
- etablir les metriques et certificats apres l'action.

Il ne peut intervenir dans :

- `detectGap` ;
- `authorizeUse` ;
- `executeTransport` ;
- `selectQuery` ;
- `buildRepair` ;
- `executeRepair` ;
- la decision d'arret ;
- le choix d'une branche publique avant reception de la reponse.

### 5.3 Theoreme de non-interference publique

Le pont doit prouver une forme extensionnelle calculable :

```lean
theorem v23PublicPolicy_worldIndependent
    (e1 e2 : V23ExecutionState)
    (samePublic : e1.public = e2.public) :
    publicDecision e1.public = publicDecision e2.public := rfl
```

La preuve exacte peut ne pas etre `rfl`, mais son type ne doit pas mentionner
une hypothese d'egalite des mondes. Deux executions ayant le meme etat public
doivent calculer les memes latents et les memes decisions jusqu'a la reponse
environnementale.

## 6. Instanciation de `FinitePublicEnvironment`

### 6.1 Modele d'action

L'instance doit definir :

```text
World       := monde semantique ferme de l'episode ;
State       := V23PublicState ;
Obligation  := obligation decisionnelle courante ;
Action      := action finale du domaine ;
worlds      := enumeration canonique complete ;
compatible := semantique de la vue et de la memoire publiques ;
required   := action semantiquement exigee.
```

Les preuves suivantes sont obligatoires :

```text
worlds sans doublon ;
worlds complete ;
egalites decidables constructivement ;
fibre initiale non vide ;
existence d'au moins un conflit d'action initial ;
existence d'au moins une fibre terminale suffisante ;
non-constance de required ;
non-constance de compatible.
```

### 6.2 Requetes et reponses

`Query` et `Response` peuvent rester des porteurs uniformes avec autorisation
indexee par l'etat. Ils ne peuvent pas contenir :

- le monde complet ;
- l'action finale correcte ;
- le candidat final ;
- un patch deja calcule ;
- l'identifiant prive d'une branche autrement inaccessible.

La relation de reponse doit etre semantique :

```text
respond : World → Query → Response
```

et chaque reponse realisable doit etre representee par le sous-type utilise par
`PublicRepairTree`.

### 6.3 Etape publique

La transition publique apres reponse doit etre la vraie transition v23 :

```text
response
→ entree de la tete repair
→ zRepair
→ repair predit
→ executeRepair
→ observation et memoire mises a jour
→ candidat suivant
→ V23PublicState suivant.
```

Elle ne peut pas etre definie par une table copiant l'etat terminal attendu,
sauf pour le niveau A de conformance. Le certificat final du modele appris doit
executer les poids appris.

## 7. Politique publique issue du modele

### 7.1 Politique, pas trajectoire

Le pont doit compiler le modele en une politique :

```lean
structure V23PublicPolicy where
  detect : V23PublicState → GapDecision
  authorize : (s : V23PublicState) → OpenGap s → AuthorizedUse
  transport : ... → AuthorizedTransport
  query : ... → Query
  repair : ... → Response → IntrinsicRepair
```

Chaque champ doit etre defini par l'inference quantifiee correspondante.

Une liste de decisions lues dans une trace n'est pas une politique. Les traces
servent a verifier et a rejouer la politique ; elles ne la definissent pas.

### 7.2 Compilation en arbre public

La construction de `PublicRepairTree` doit :

1. executer la politique sur l'etat public courant ;
2. s'arreter seulement si la fermeture est certifiee ;
3. sinon produire la requete autorisee ;
4. enumerer toutes les reponses publiquement realisables ;
5. executer la reparation predite pour chaque reponse ;
6. construire recursivement chaque sous-arbre ;
7. utiliser une mesure interne explicite pour la terminaison finie.

La mesure du domaine fini peut etre le nombre de conflits d'action, a condition
que chaque branche prouve sa diminution stricte. Une borne d'horizon externe ne
peut pas remplacer cette preuve dans le certificat de reparabilite.

Pour l'orbite ouverte, aucune terminaison globale ne doit etre revendiquee. Il
faut prouver une famille de pas localement fermants et conservateurs indexee par
`n : Nat`.

### 7.3 Couverture de toutes les branches

Le theoreme requis est conceptuellement :

```lean
theorem v23CompiledTree_allRealizableBranchesWinning :
  CertifiedWinningTree
    v23DecisionDoctrine
    initialPublicState
    targetObligation
    (compileV23PublicTree initialPublicState targetObligation)
```

Il doit quantifier sur chaque feuille de l'arbre et non seulement sur le monde
utilise pour produire une trace de reference.

### 7.4 Posterior exact de chaque branche

L'instance doit construire :

```lean
def v23ExactPosteriorRepairComplete :
    ExactPosteriorRepairComplete v23FinitePublicEnvironment := ...
```

Pour chaque etape publique et chaque monde enumere, Lean doit prouver :

```text
monde compatible avec l'etat apres
↔
monde compatible avec l'etat avant
∧ reponse du monde a la requete = reponse de la branche.
```

Puis, pour chaque feuille :

```text
monde compatible avec l'etat de feuille
↔
le monde produit exactement le transcript conduisant a cette feuille.
```

Cette equivalence interdit deux affaiblissements : une mise a jour qui elimine
un monde coherent, et une mise a jour qui conserve un monde contredisant la
reponse publique. Elle doit etre obtenue depuis la semantique de l'environnement
et l'execution du repair, pas posee comme champ opaque.

## 8. Doctrine decisionnelle non triviale

### 8.1 Interdiction des champs `True`

Les champs de `PublicDecisionDoctrine` doivent recevoir des relations
structurelles. Cibles minimales :

```text
DecisionDerivedFromPublicFiber
  := le candidat repare est calcule depuis le transcript public et realise
     l'action unique determinee par la fibre terminale ;

DecisionClosureProvenance
  := chaque certificat du candidat terminal provient d'une reponse presente
     dans le transcript et d'une etape autorisee de l'arbre ;

DecisionFramePreserved
  := les entrees de memoire et certificats anterieurs restent presents et
     semantiquement valides ;

CurrentCertificateAdded
  := le certificat correspondant au gap courant est ajoute ;

StrictIdentityConservative
  := aucune egalite interne nouvelle entre objets distincts n'est postulee ;

TransportCoherent
  := le transport execute est celui autorise par l'usage courant et sa
     composition respecte les lois deja formalisees ;

ConsistentUpdate
  := le nouvel etat porte simultanement le candidat repare, la memoire et la
     vue publique produites par la meme reparation.
```

Chaque relation doit avoir :

- au moins un temoin positif dans la campagne ;
- au moins un contre-exemple ou une mutation rejetee ;
- une preuve de preservation par l'etape v23 ;
- une liaison a un champ effectivement calcule du modele ou de l'environnement.

### 8.2 Realisation de la decision

`DecisionRealizationComplete` ne doit pas masquer un oracle. La construction
doit extraire l'action depuis le candidat public terminal. La preuve de
correction peut consulter la semantique, mais la fonction qui choisit l'action
ne le peut pas.

Le cas impossible d'une fibre declaree homogene alors qu'elle contient deux
actions distinctes doit etre elimine par `ActionSufficientAt`, pas par une
decision privee.

## 9. Raccord fondationnel intrinsèque

### 9.1 Une seule dynamique sous plusieurs vues

Le pont ne doit pas construire d'un cote une instance adaptative et de l'autre
une instance fondationnelle sans relation entre elles. Le meme pas calcule doit
etre vu simultanement comme :

```text
un gap operationnel du systeme actif ;
un certificat contextuel de separation et coordination ;
un usage non contractif ;
un transport compositionnel ;
une reparation intrinseque ;
une transition dynamique ;
une etape publique d'un arbre adaptatif.
```

Les raccords doivent etre des egalites ou equivalences explicites portant sur
les objets calcules. Une ressemblance de noms ou une paire de constructions
paralleles ne constitue pas un raccord.

### 9.2 Regime relaxe appris

L'instance doit construire, directement ou par transport des realisations
actives deja prouvees :

```text
un ContextCategory et ses lois ;
un langage de termes indexe ;
un certificat de gap contextuel ;
une separation des poles ;
une coordination des poles ;
un RelaxedInterfaceRegime ;
un LawfulCompositionalUse ;
un CompositionalTransport ;
une doctrine de predicats admissibles ;
une interpretation et sa conservativite identitaire ;
un GapRepairAlgebra dont next est executeRepair ;
une realisation dynamique et ses lois de stabilite.
```

Les champs `Sep`, `Coord`, `Use`, `Read` et `OutRel` doivent avoir un contenu
propre. `OutRel` ne peut pas etre identique a `Use` sur tous les etats
atteignables. Le transport appris doit etre aligne sur le transport
operationnel execute par v23.

### 9.3 Usage non identitaire et non-projectivite

Pour au moins un gap appris atteint par la politique, Lean doit construire :

```text
HasUse regime context formed shadow ;
¬ HasUse regime context shadow formed ;
formed ≠ shadow ;
coordination commune ;
transport effectif vers la lecture autorisee ;
¬ ProjectivelyRepresentable regime.
```

La non-projectivite doit etre derivee de l'asymetrie de l'usage ou d'un critere
plus fort deja prouve, pas ajoutee comme champ independant.

### 9.4 Composition et coherence

L'instance doit exhiber au moins deux usages non reflexifs successifs et prouver
que :

```text
leur composition est un usage licite ;
le transport de l'usage compose
=
la composition des transports ;
les identites gauche et droite sont conservees ;
l'associativite est conservee ;
la composition preserve le frame cumulatif pertinent.
```

Une succession de deux transitions sans theoreme reliant les transports ne
satisfait pas cette obligation.

### 9.5 Alignement adaptatif-fondationnel

Le type central doit etre de la forme :

```lean
structure V23AdaptiveFoundationalAlignment
    (policy : V23PublicPolicy)
    (foundation : V23LearnedFoundationalRealization policy.model) where
  gap_eq : ...
  use_eq : ...
  transport_eq : ...
  query_eq : ...
  repair_eq : ...
  next_eq : ...
  publicStep_eq : ...
  closurePredicate_iff_leafSufficient : ...
```

Les ellipses indiquent ici des types a preciser pendant l'implementation ; elles
ne sont pas autorisees dans le code Lean livre.

Ce paquet garantit que la reparabilite adaptative n'est pas une theorie externe
posee au-dessus de v23. Elle devient une consequence operationnelle de la meme
relaxation dynamique de l'identite, du meme gap et du meme transport.

### 9.6 Stabilite et non-reduction semantique

Le pont doit reutiliser ou specialiser les resultats de stabilite existants :

```text
identite stricte conservee pour l'individuation ;
usage directionnel sans contraction ;
transport coherent des predicats admissibles ;
recomposition dynamique issue de la reparation ;
conservation des certificats anterieurs ;
non-reduction au seul graphe d'usage ;
non-reduction au seul graphe de transition ;
non-representabilite par une egalite projetee exacte.
```

Pour la non-reduction, il faut produire deux interpretations ou modes ayant le
meme graphe d'usage pertinent mais des transports ou lectures semantiques
distincts. Une simple asymetrie de relation ne suffit pas a elle seule.

## 10. Causalite complete

### 10.1 Chaine obligatoire

Le certificat causal doit couvrir :

```text
etat public
→ latent gap
→ gap
→ latent usage
→ usage
→ latent transport
→ transport
→ latent requete
→ requete
→ reponse environnementale
→ latent repair
→ repair
→ etat suivant
→ nouveau gap ou fermeture.
```

Pour chaque fleche, il faut distinguer :

- dependence calculatoire dans le programme ;
- sensibilite sur au moins une paire d'entrees ;
- intervention qui modifie ou bloque l'effet attendu ;
- absence de chemin alternatif contournant la variable.

### 10.2 Causalite structurelle Lean

Lean doit prouver au minimum :

```text
la requete executee est la sortie de la tete query sur le transport courant ;
la reparation executee est la sortie de la tete repair sur la reponse courante ;
l'etat suivant est exactement executeRepair de cette reparation ;
une reparation alternative valide produit l'etat alternatif calcule ;
une reponse croisee produit un repair ou un successeur distinct quand le
protocole l'exige ;
aucune fonction next independante du repair n'existe dans l'instance.
```

### 10.3 Causalite interventionnelle v23

La campagne conserve les dix-huit interventions preenregistrees. Le pont doit
associer chaque intervention a :

- une transformation typee de l'etat ou de la decision ;
- un verdict attendu preenregistre ;
- une trace brute ;
- une verification independante ;
- lorsque le domaine fini le permet, un certificat Lean de succes ou de refus.

Les interventions obligatoires couvrent au moins :

```text
suppression et permutation du gap ;
suppression et permutation de l'usage ;
suppression et permutation du transport ;
neutralisation ou permutation de la requete ;
permutation de la reponse ;
neutralisation ou permutation du repair ;
tentative de contournement direct ;
invariance des variables non ciblees.
```

Un modele qui garde sa performance apres suppression d'une tete declaree
causale echoue, sauf si le protocole classe explicitement cette intervention
comme non executable et en prouve la raison.

### 10.4 Mediation latente et mediation de la chaine

Deux niveaux de mediation doivent etre testes separement :

```text
intra-tete :
  entree → hidden → logits → classe ;

inter-tetes :
  gap → use → transport → query → response → repair → next.
```

Le certificat fini doit recalculer les descendants apres une intervention ; il
ne doit pas reutiliser des sorties naturelles incoherentes avec le latent
intervenu. La campagne apprise doit mesurer les effets directs et indirects
selon le plan preregistre, avec controles croises apparies.

Une mediation est rejetee si :

- le descendant reste calcule depuis sa valeur naturelle mise en cache ;
- l'intervention modifie simultanement une variable non descendante ;
- l'etiquette correcte est injectee apres l'intervention ;
- seul le score final est compare sans verifier les variables intermediaires ;
- une intervention hors support est interpretee comme preuve causale.

## 11. Fermeture et conservation

### 11.1 Fermeture locale

Une etape ferme le gap courant seulement si elle prouve :

```text
monde reel encore compatible ;
fibre publique terminale non vide ;
absence du conflit d'action vise dans cette fibre ;
candidat terminal correct sur toute la fibre ;
candidat terminal correct dans le monde reel ;
gap courant absent ou marque ferme par un detecteur recalculable.
```

Le bool `closed` produit par le modele n'est jamais une preuve.

### 11.2 Conservation cumulative

Apres le rang `n`, l'etat doit conserver tous les certificats acquis avant
`n`. La structure cible doit porter :

```lean
structure V23CumulativeInvariant (state : V23PublicState) where
  memoryWellFormed : ...
  certificatesSound : ...
  candidateAgreesOnRepairedPrefix : ...
  transcriptExplainsMemory : ...
  noDuplicateOrContradictoryRepair : ...
```

Le theoreme d'etape doit etre :

```lean
theorem v23Step_preservesCumulativeInvariant
    (before : V23PublicState)
    (hinvariant : V23CumulativeInvariant before)
    (response : RealizableResponse ...) :
    V23CumulativeInvariant (v23Step before response)
```

Le frame ne peut pas etre deduit de la seule inclusion des fibres. Il doit
porter explicitement la conservation de la memoire, du candidat et des
certificats.

### 11.3 Dynamique finie et ouverte

Deux certificats distincts sont requis :

```text
instance finie :
  mesure strictement decroissante
  + terminaison
  + arbre public gagnant
  + fermeture globale ;

instance ouverte :
  pas suivant pour tout n
  + fermeture locale
  + conservation du prefixe
  + nouvel indice
  + absence de fermeture globale a tout stade fini.
```

La famille ouverte ne doit pas etre tronquee par un `rank`, une `windowFor` ou
une borne terminale externe.

## 12. No-go et comparateurs apparies

### 12.1 No-go formels

Le pont doit reutiliser et specialiser :

```text
adaptivePublicNoGo ;
no-go passif fini ;
no-go visible-factorise fini ;
borne exacte du meilleur controleur fini ;
capacite totale du transcript actif.
```

Il faut prouver que les deux mondes du temoin :

- appartiennent a la meme fibre publique initiale ;
- exigent des actions incompatibles ;
- restent indiscernables pour la classe de politique visee ;
- deviennent distinguables par la strategie active v23 apres la requete.

### 12.2 Capacite comparable

La comparaison empirique doit apparier :

```text
observations initiales ;
budget de parametres ;
profondeur et largeur ;
budget de calcul ;
nombre maximal de requetes ;
alphabet des reponses ;
donnees d'entrainement ;
procedure de selection ;
critere final de fermeture.
```

Le no-go informationnel exact porte sur une classe definie par son information,
pas sur une baseline volontairement sous-dimensionnee. Les comparaisons de
performance portent separement sur les architectures apprises appariees.

### 12.3 Controle oracle

Un oracle peut etre inclus uniquement comme plafond. Il doit etre marque comme
recevant une information privee supplementaire et ne peut pas servir a prouver
la superiorite a capacite comparable.

## 13. Liaison checkpoint, inference, latents et traces

### 13.1 Chaine de provenance

Chaque run scientifique doit figer :

```text
sources Python ;
protocole ;
configuration ;
seed ;
checkpoint flottant ;
regle de quantification ;
checkpoint quantifie ;
poids Lean ;
entrees certifiees ;
latents caches ;
logits ;
decisions ;
traces ;
arbre public ;
certificat final.
```

Chaque artefact possede un hash et une relation de derivation vers son
predecesseur. Aucun fichier de sortie existant n'est ecrase.

### 13.2 Alignement bit-exact etendu

L'alignement actuel des decisions doit etre etendu aux activations cachees :

```text
Python preactivation = Lean preactivation ;
Python hidden Int8 = Lean hidden Int8 ;
Python logits = Lean logits ;
Python argmax = Lean argmax ;
Python classe decodee = semantique Lean attendue.
```

Cette egalite est verifiee pour toutes les entrees du catalogue certifiable,
pas seulement pour les etapes naturelles.

Le certificat doit egalement prouver que le calcul expose des activations
internes du meme modele que celui qui produit les classes. Il est interdit
d'exporter un second reseau d'explication ou un latent reconstruit a posteriori
depuis la classe predite.

### 13.3 Reification sans confiance

Le generateur Lean n'ecrit que des donnees. Lean recalcule :

- l'inference ;
- la validite des dimensions ;
- les latents ;
- les logits ;
- les decisions ;
- le decodage semantique ;
- les transitions ;
- la fermeture ;
- la conservation ;
- les obligations de l'arbre public.

Un champ JSON `valid`, `closed`, `causal` ou `certified` n'est jamais importe
comme proposition.

## 14. Suite de declarations Lean requises

Les noms pourront etre ajustes, mais la couverture ne pourra pas etre reduite.

### 14.1 Latents appris

```text
QuantizedHiddenEvaluation
evaluateHidden
evaluateHidden_dimensions
evaluateHidden_int8Bounds
evaluateHidden_logits_eq_existingInference
v23GapHiddenAlignment
v23UseHiddenAlignment
v23TransportHiddenAlignment
v23QueryHiddenAlignment
v23RepairHiddenAlignment
v23AllHiddenAlignments
```

### 14.2 Politique publique

```text
V23PublicState
V23PublicPolicy
v23PublicPolicy
v23PublicPolicy_worldIndependent
v23PublicPolicy_usesOnlyPublicInputs
v23PolicyDecisions_eq_quantizedModel
```

### 14.3 Environnement et arbre

```text
v23FiniteActionModel
v23FinitePublicEnvironment
v23InitialFiberNonempty
v23InitialActionConflict
compileV23PublicTree
compileV23PublicTree_retainsActualWorld
compileV23PublicTree_coversRealizableResponses
compileV23PublicTree_strictlyDecreasesConflictMeasure
v23CompiledTree_uniformlyActionResolving
v23PublicStep_exactPosterior
v23ExactPosteriorRepairComplete
v23CompiledTree_generatedByExactCompiler
v23CompiledTree_leafPosterior
```

### 14.4 Doctrine et fermeture

```text
V23DecisionProvenance
V23DecisionFrame
V23TransportCoherence
V23ConsistentUpdate
v23DecisionDoctrine
v23DecisionRealizationComplete
v23Repair_closesCurrentGap
v23Step_preservesCumulativeInvariant
v23CompiledTree_winning
v23CertifiedRepairabilityWitness
v23CertifiedRepairableAt
```

### 14.5 Raccord fondationnel

```text
V23LearnedFoundationalRealization
v23LearnedFoundationalRealization
V23LearnedCompositionalTransport
v23LearnedCompositionalTransport
v23LearnedForwardHasUse
v23LearnedBackwardHasUse_refuted
v23LearnedRegime_notProjectivelyRepresentable
V23AdaptiveFoundationalAlignment
v23AdaptiveFoundationalAlignment
v23LearnedUseGraphSemanticNonReduction
v23LearnedTransitionGraphSemanticNonReduction
```

### 14.6 Causalite, interventions et no-go

```text
V23CausalChainCertificate
v23CausalChainCertificate
v23InterventionCertificate
v23AllFiniteInterventionsCertified
v23PassiveNoGo
v23VisibleFactoredNoGo
v23ActiveStrategy_breaksInitialIndistinguishability
v23MatchedInformationSeparation
```

### 14.7 Paquet final

```text
V23LearnedAdaptiveRepairabilityCertificate
v23LearnedAdaptiveRepairabilityCertificate
V23CampaignFormalCertificate
v23CampaignFormalCertificate
```

Le premier paquet certifie l'agent fini appris. Le second rattache les artefacts
formels aux identifiants figes de la campagne sans transformer les resultats
statistiques en theoremes.

## 15. Anti-trivialite obligatoire

### 15.1 Types interdits pour le resultat principal

Dans l'instance finale, les objets suivants ne peuvent etre `Unit`, `PUnit`,
`True`, `False` par construction, ni des alias mutuels :

```text
World
PublicState
LearnedLatent
Gap
Use
Transport
Query
Response
Repair
Candidate
DecisionProvenance
DecisionFrame
TransportCoherence
CumulativeInvariant
```

### 15.2 Aliases semantiques interdits

Sont interdits :

```text
Candidate := World ;
Response := World ;
Gap := Query ;
Use := Query ;
Transport := Use ;
Repair := Candidate ;
next := valeur terminale attendue ;
latent := etiquette semantique ;
latent := one-hot du monde prive ;
policy := lecture d'une trace de reference ;
winningTree := branche du seul monde actuel.
```

### 15.3 Proprietes interdites par vacuite

Une propriete structurelle ne peut pas etre instanciee par `True` dans le paquet
principal. Si une propriete est reellement automatique, elle doit etre definie
par une egalite, une inclusion, une provenance ou une relation concrete, puis
prouvee.

Une branche impossible doit etre eliminee par une incompatibilite semantique
prouvee. Elle ne doit pas etre ignoree en choisissant un type de reponse trop
petit.

### 15.4 Tests positifs et negatifs

Chaque composant doit avoir :

- un cas positif ;
- un cas negatif ;
- une mutation rejetee ;
- une preuve ou verification que le rejet vient de la bonne obligation.

Le catalogue de falsification doit couvrir au minimum les latents, logits,
classes, gaps, usages, transports, requetes, reponses, repairs, etats suivants,
fibres, frames, transcriptions et hashes de provenance.

## 16. Campagne empirique preservee integralement

### 16.1 Deux niveaux appris

Le pont formel fini ne dispense pas de construire et executer :

- le domaine perceptuel compositionnel ;
- le domaine symbolique de reparation de programmes ;
- l'agent causal complet ;
- les baselines appariees ;
- les ablations internes ;
- les interventions ;
- les partitions IID et OOD scellees ;
- les dix seeds finales ;
- la replication d'evaluation ;
- la replication d'entrainement.

### 16.2 Separation exact/statistique

```text
Lean prouve :
  correction de l'inference quantifiee finie ;
  correction de l'instance finie ;
  fermeture de toutes les branches du domaine reifie ;
  no-go exacts dans les classes formalisees ;

la campagne mesure :
  apprentissage ;
  robustesse multi-seed ;
  generalisation IID/OOD ;
  effet des interventions ;
  comparaison aux baselines ;
  replication.
```

Aucun passage de la seconde liste a la premiere n'est autorise sans nouvelle
formalisation.

### 16.3 Runs scientifiques immuables

Les regles de tracabilite Python du depot restent obligatoires : nouveau script
pour chaque variante, copie gelee `timestamp+sha256`, sorties portant le meme
suffixe, commande et hash dans le rapport, smoke tests dans `/tmp`, aucun
ecrasement d'un resultat cite.

## 17. Portes d'acceptation du pont

Ces portes completent G0-G8 ; elles ne les remplacent pas.

### L0 - Source canonique

- `AdaptiveRepairability` compile depuis le `Meta/` actif ;
- aucune divergence avec la revision de publication source ;
- l'artefact autonome reste reproductible.

### L1 - Latents explicites

- les cinq activations cachees sont exposees dans Python et Lean ;
- dimensions, arrondis, saturations et ReLU concordent bit a bit ;
- aucune activation n'est importee comme verdict fiable ;
- les activations appartiennent au modele appris qui produit les decisions ;
- une intervention latente exacte modifie au moins une sortie et son descendant
  attendu.

### L2 - Politique publique

- toutes les decisions viennent des poids quantifies ;
- le monde prive n'est pas dans les entrees ;
- la non-interference publique est prouvee ;
- la politique n'est pas une trace memorisee.

### L3 - Environnement adaptatif

- `FinitePublicEnvironment` est habite et non trivial ;
- toutes les reponses realisables sont enumerees ;
- les transitions executent le vrai repair v23 ;
- l'arbre ne consulte pas le monde pour choisir une branche ;
- chaque etape realise le posterior public exact ;
- chaque feuille correspond exactement aux mondes produisant son transcript.

### L4 - Doctrine substantielle

- aucun champ principal n'est `True` ;
- provenance, frame, ajout de certificat, transport et coherence sont concrets ;
- chaque relation possede tests positifs et negatifs.

### L5 - Raccord fondationnel

- le meme gap alimente les vues adaptative et fondationnelle ;
- le regime relaxe, ses lois d'usage et son transport sont construits ;
- le transport appris respecte identites, composition et associativite ;
- la reparation fondationnelle produit exactement la transition publique ;
- un usage asymetrique appris refute la representabilite projective exacte ;
- les non-reductions aux graphes d'usage et de transition sont etablies.

### L6 - Strategie gagnante

- l'arbre public couvre toutes les branches realisables ;
- chaque feuille est action-suffisante ;
- la realisation de decision est publique ;
- `CertifiedRepairableAt` est construit.

### L7 - Causalite

- chaque fleche de la chaine est calculatoire et sensible ;
- les interventions finies sont certifiees ;
- aucun bypass n'est detecte ;
- `next` est derive exclusivement du repair execute.

### L8 - Conservation

- le frame cumulatif est defini concretement ;
- chaque pas le preserve ;
- au moins deux pas successifs non triviaux sont certifies ;
- l'instance ouverte est prouvee pour tout rang sans borne externe.

### L9 - No-go apparies

- les classes passive et visible-factorisee sont definies exactement ;
- leurs frontieres d'information sont identiques a celles revendiquees ;
- les impossibilites sont prouvees ;
- les baselines apprises sont appariees separement.

### L10 - Integration de campagne

- checkpoint, latents, traces et certificat partagent une provenance gelee ;
- le bundle Lean se reconstruit depuis les donnees figees ;
- les falsificateurs detectent toutes les mutations preenregistrees ;
- le rapport distingue developpement, preuve exacte et resultat statistique.

### L11 - Cloture maximale

- L0-L10 sont fermes ;
- G0-G8 sont fermes ;
- evaluation et entrainement sont repliques ;
- aucun incident ni run echoue n'a ete supprime ;
- l'audit externe peut reproduire chaque revendication depuis les sources.

## 18. Ordre d'implementation bloque

### Phase 1 - Promotion sans changement semantique

1. integrer `Meta/AdaptiveRepairability` comme source active ;
2. ajouter ses imports a l'entree de build appropriee ;
3. compiler tous ses modules ;
4. comparer les fichiers a l'artefact source ;
5. verifier les audits d'axiomes.

Critere de sortie : L0.

### Phase 2 - Inference latente bit-exacte

1. ajouter l'API Python qui exporte les preactivations et activations cachees ;
2. ajouter l'API Lean correspondante sans casser `runModel` ;
3. prouver l'equivalence des logits avec l'inference existante ;
4. generer les donnees d'alignement cache ;
5. verifier les cinq tetes sur toutes les entrees certifiables ;
6. falsifier chaque etage numerique.

Critere de sortie : L1.

### Phase 3 - Etat et politique publics

1. definir `V23PublicState` ;
2. formaliser son encodage canonique ;
3. definir la politique depuis les cinq tetes ;
4. prouver la non-interference ;
5. prouver l'egalite avec les decisions quantifiees existantes ;
6. ajouter les temoins de sensibilite et de non-constance.

Critere de sortie : L2.

### Phase 4 - Environnement et arbre

1. instancier le modele d'action ;
2. instancier requetes, reponses et autorisations ;
3. prouver l'exactitude des fibres publiques ;
4. definir les etapes issues du repair predit ;
5. compiler la politique en arbre de toutes branches ;
6. prouver la diminution de mesure ;
7. construire le compilateur de posterior exact ;
8. prouver l'equivalence feuille-transcript ;
9. prouver couverture et retention.

Critere de sortie : L3.

### Phase 5 - Doctrine substantielle

1. definir les relations structurelles de la doctrine ;
2. prouver la realisation decisionnelle ;
3. fournir les cas positifs, negatifs et les mutations rejetees ;
4. prouver provenance, frame et coherence sur chaque etape publique.

Critere de sortie : L4.

### Phase 6 - Raccord fondationnel

1. instancier le regime relaxe et ses lois ;
2. construire l'usage non contractif issu du gap appris ;
3. construire le transport compositionnel ;
4. raccorder le `GapRepairAlgebra` a `executeRepair` ;
5. prouver les egalites adaptatif-fondationnel ;
6. deriver la non-projectivite ;
7. prouver les non-reductions semantiques.

Critere de sortie : L5.

### Phase 7 - Strategie gagnante

1. prouver la fermeture de chaque feuille ;
2. construire `CertifiedWinningTree` ;
3. construire `CertifiedRepairabilityWitness` ;
4. specialiser la caracterisation operationnelle ;
5. rattacher la fermeture de feuille au predicat fondationnel correspondant.

Critere de sortie : L6.

### Phase 8 - Causalite et conservation

1. formaliser la chaine complete ;
2. raccorder les dix-huit interventions ;
3. prouver les sensibilites ;
4. definir le frame cumulatif ;
5. prouver sa preservation ;
6. certifier plusieurs transitions ;
7. raccorder l'orbite ouverte.

Criteres de sortie : L7 et L8.

### Phase 9 - No-go apparies

1. specialiser le no-go adaptatif public ;
2. raccorder le no-go passif ;
3. raccorder le no-go visible-factorise ;
4. verifier les budgets informationnels ;
5. separer strictement les theoremes exacts des baselines statistiques.

Critere de sortie : L9.

### Phase 10 - Certification scientifique

1. geler sources, protocole et checkpoint ;
2. reconstruire poids, latents et traces ;
3. compiler le certificat Lean final ;
4. executer tous les falsificateurs ;
5. executer la campagne apprise complete ;
6. ouvrir les OOD seulement apres scellement ;
7. repliquer evaluation et entrainement ;
8. produire la matrice preuve-revendication.

Criteres de sortie : L10, L11 et G0-G8.

## 19. Matrice minimale de tracabilite

| Revendication | Donnee | Calcul | Preuve/verificateur | Intervention | Porte |
|---|---|---|---|---|---|
| latent appris exact | poids + entree | activation quantifiee | Lean/Python bit-exact | mutation hidden | L1 |
| latent causal | hidden naturel/intervenu | decodeur de tete | mediation exacte | clamp/permutation hidden | L1/L7 |
| politique publique | etat public | cinq tetes | non-interference Lean | fuite monde | L2 |
| raccord fondationnel | meme pas calcule | vues adaptative et relaxee | egalites d'alignement | divergence de vue | L5 |
| gap causal | latent gap | decode gap | correction locale | suppression/permutation | L7/G5 |
| usage causal | gap | tete use | autorisation typee | suppression/permutation | L7/G5 |
| transport causal | usage | tete transport | coherence | suppression/permutation | L5/L7/G5 |
| requete causale | transport | tete query | admissibilite | neutralisation | L7/G5 |
| repair causal | reponse | tete repair | fermeture locale | permutation reponse/repair | L7/G5 |
| transition intrinseque | repair | executeRepair | egalite du successeur | bypass next | L7/G6 |
| conservation | memoire | mise a jour | frame cumulatif | effacement ancien | L8/G6 |
| strategie gagnante | toutes reponses | arbre public | CertifiedWinningTree | branche adversariale | L6 |
| impossibilite passive | fibre conflictuelle | classe passive | no-go exact | controle oracle separe | L9/G4 |
| impossibilite factorisee | visible commun | classe factorisee | no-go exact | budget apparie | L9/G4 |
| generalisation | runs scelles | metriques | analyse preregistree | OOD | G7 |
| reproductibilite | bundle fige | rejeu | audit externe | mutation hash | L10/G8 |

Chaque ligne doit pointer vers des chemins, identifiants de run, noms de
theoremes et hashes effectifs dans le rapport final.

## 20. Audits obligatoires

### 20.1 Audit Lean

Chaque fichier Lean cree ou modifie doit :

- rester constructif ;
- ne contenir aucun `axiom`, `sorry`, `admit`, `Classical`, `propext`,
  `Quot.sound`, `noncomputable` ou `unsafe` ;
- se terminer par un unique bloc `AXIOM_AUDIT` ;
- auditer les declarations principales du fichier ;
- compiler sous le toolchain fige.

Commandes minimales :

```bash
lake build Meta.AdaptiveRepairability.Validation
lake build Meta.AI.V23AdaptiveRepairability.Validation
lake build Meta
rg -n '\b(axiom|sorry|admit|Classical|propext|Quot\.sound|noncomputable|unsafe)\b' \
  Meta/AdaptiveRepairability Meta/AI/V23AdaptiveRepairability
```

L'audit echoue si un nom imprime n'existe pas ou si une sortie mentionne une
dependance interdite.

### 20.2 Audit Python

Les tests doivent couvrir :

```text
encodage public ;
calcul de chaque hidden ;
arrondi et saturation ;
logits et argmax ;
decodage des cinq tetes ;
generation de toutes les branches ;
fermeture et conservation ;
absence de fuite ;
interventions ;
serialisation ;
hashes ;
rejet des mutations.
```

Les smoke tests utilisent `/tmp`. Toute execution scientifique respecte la
copie gelee `timestamp+sha256` et ne modifie aucun script historique.

### 20.3 Audit d'information

Un auditeur mecanique doit construire, pour chaque sortie du modele, la liste
de ses entrees effectives. Il echoue si :

- un identifiant de monde prive apparait ;
- une cible correcte apparait avant la reponse autorisee ;
- le patch final apparait dans le gap ;
- la requete correcte apparait dans une etiquette accessible a l'inference ;
- l'etat suivant apparait dans l'entree d'une tete precedente ;
- une branche est selectionnee par le monde plutot que par la reponse publique.

## 21. Criteres d'echec immediat

Le projet ne peut pas annoncer le pont comme realise si l'un des cas suivants
survient :

1. seul le domaine symbolique est instancie ;
2. seul le checkpoint de developpement est certifie ;
3. seules les classes finales sont alignees, sans les latents caches ;
4. le latent expose est reconstruit depuis la classe ou produit par un autre
    modele que celui qui decide ;
5. l'arbre ne contient que la trajectoire du monde reel ;
6. le monde prive intervient dans la politique ;
7. `Candidate`, `Response` ou `latent` copie le monde ;
8. une loi de doctrine est `True` ;
9. l'invariant de composition est `True` sans contenu structurel ;
10. la fermeture fait confiance au modele ;
11. le repair n'est pas la cause unique de `next` ;
12. la memoire anterieure peut regresser ;
13. une intervention causale n'affecte pas la chaine sans explication typee ;
14. la baseline comparee recoit moins d'information ou de calcul sans controle ;
15. l'OOD est consulte avant scellement ;
16. une seule seed est generalisee ;
17. les echecs sont omis du bundle ;
18. Lean importe un verdict JSON comme preuve ;
19. l'artefact publie diverge silencieusement de la source active ;
20. le certificat ne se reconstruit pas depuis un clone propre ;
21. le niveau fini est presente comme remplacement de la campagne complete ;
22. le posterior d'une branche n'est prouve que dans un sens ;
23. l'arbre certifie une branche naturelle mais pas les reponses alternatives ;
24. le checkpoint est une table construite depuis les etiquettes plutot qu'un
    resultat d'entrainement trace ;
25. les vues adaptative et fondationnelle sont construites en parallele sans
    egalites reliant leurs gaps, usages, transports, repairs et transitions ;
26. la composition des transitions est montree, mais pas la composition des
    usages et transports qui les autorisent ;
27. la non-projectivite est affirmee sans etre derivee d'un usage appris
    asymetrique ;
28. la semantique est reduite au seul graphe d'usage ou de transition.

## 22. Definition de termine

Le travail est termine uniquement lorsque l'on peut suivre sans saut :

```text
sources et protocole figes
→ entrainement identifie
→ checkpoint identifie
→ quantification identifiee
→ poids Lean
→ calcul des cinq latents caches
→ calcul des cinq decisions
→ politique publique
→ regime relaxe et transport compositionnel alignes
→ arbre de toutes les reponses realisables
→ fermeture de chaque feuille
→ conservation cumulative
→ instance CertifiedRepairableAt
→ no-go apparies
→ interventions
→ campagne multi-domaines multi-seeds
→ OOD scelles
→ replication
→ certificat et rapport reproductibles.
```

Le paquet final doit permettre trois audits independants :

1. audit logique, reconstruisant les preuves Lean ;
2. audit calculatoire, rejouant l'inference et les traces bit a bit ;
3. audit scientifique, reproduisant la campagne et ses analyses statistiques.

Aucun de ces audits ne remplace les deux autres.

## 23. Ordre de travail immediat

Le prochain lot d'implementation doit rester limite a L0-L2 :

1. promouvoir la theorie `AdaptiveRepairability` dans la source active sans
   changement semantique ;
2. introduire `QuantizedHiddenEvaluation` dans un nouveau module sans modifier
   les scripts historiques ;
3. exposer les activations cachees dans une nouvelle variante Python ;
4. verifier l'egalite des logits avec l'inference existante ;
5. produire les alignements caches des cinq tetes ;
6. definir `V23PublicState` ;
7. construire `v23PublicPolicy` depuis les poids existants ;
8. prouver la non-interference et les premieres sensibilites ;
9. compiler et auditer ;
10. seulement ensuite commencer l'instance de `FinitePublicEnvironment`.

Ce lot n'autorise encore aucune revendication nouvelle. Il etablit la base
necessaire pour que le latent appris, et non une copie symbolique du monde,
devienne le mediateur effectif de la reparabilite adaptative.
