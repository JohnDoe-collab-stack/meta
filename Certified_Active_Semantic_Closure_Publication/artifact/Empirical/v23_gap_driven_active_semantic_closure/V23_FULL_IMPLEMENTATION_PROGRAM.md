# Programme exhaustif d’implémentation de la campagne v23

Statut : plan d’exécution non normatif
Version du plan : v23-implementation-plan-1
Date : 2026-07-20
Protocole normatif : [SCIENTIFIC_PROTOCOL.md](SCIENTIFIC_PROTOCOL.md)
Version normative : v23-protocol-1
SHA-256 du protocole audité :
1fbd5b299d7e81620db1dcb2b940a02462c7098d79efc7b233f765a879b2861f

## 0. Autorité, objectif et règle de lecture

Ce document transforme le protocole scientifique v23 en programme
d’implémentation complet. Il ne modifie aucune hypothèse, aucun seuil, aucune
partition, aucune baseline, aucun budget et aucune règle de décision du
protocole normatif.

En cas de divergence :

1. le protocole v23 fait autorité ;
2. le code doit être corrigé pour satisfaire le protocole ;
3. ce plan doit être corrigé s’il décrit mal le protocole ;
4. le protocole ne doit jamais être assoupli après observation d’un résultat ;
5. toute modification scientifique du protocole crée une campagne distincte,
   par exemple v24.

L’objectif n’est pas de produire une démonstration partielle. La livraison est
terminée uniquement lorsque la même architecture causale est :

~~~text
définie constructivement
+ réalisée sans externalité
+ concordante entre Lean et Python
+ liée à un checkpoint quantifié certifié
+ apprise dans deux domaines
+ comparée à toutes les baselines obligatoires
+ testée par interventions causales
+ évaluée hors distribution
+ falsifiée
+ répliquée indépendamment
+ publiée avec tous les succès et échecs
~~~

## 1. Résultat final attendu

La campagne doit produire trois niveaux complémentaires.

| Niveau | Rôle | Condition de réussite |
|---|---|---|
| A | Référence finie exhaustive | Concordance Lean/Python et interventions sans divergence |
| B | Campagne apprise complète | Deux domaines, multi-seeds, baselines, causalité, OOD et statistiques |
| C | Agent entier certifiable | Checkpoint Int8/Int32 sans erreur, inférence entièrement recalculée par Lean |

Le résultat scientifique final combine :

~~~text
théorèmes Lean
+ calculs exhaustifs Python
+ apprentissage multi-seeds
+ comparaison à budget apparié
+ interventions appariées
+ généralisation OOD scellée
+ certification bit-exacte
+ réplication d’évaluation
+ réplication d’entraînement
~~~

Aucun niveau ne remplace un autre :

- A ne constitue pas une validation empirique ;
- B ne remplace pas la preuve et la certification ;
- C ne prouve pas la généralisation ;
- un score élevé ne compense jamais une violation exacte ;
- une seed réussie ne remplace jamais les dix seeds finales ;
- un checkpoint hashé ne remplace jamais le recalcul de son inférence.

### 1.1 Carte complète des hypothèses

| Hypothèse | Travail d’implémentation | Décision |
|---|---|---|
| H1 | concordance exhaustive du niveau A entre Lean et Python | zéro divergence |
| H2 | réification des poids, entrées, décisions et traces du niveau C | Lean recalcule tout, sans confiance dans un hash |
| H3 | comparaison appariée B13 contre le meilleur baseline admissible | borne inférieure 95 % de Delta_task strictement supérieure à 0,05 |
| H4 | interventions typées sur le gap | borne inférieure 95 % de C_gap strictement supérieure à 0,20 |
| H5 | interventions sur chaque arête causale | bon signe et borne inférieure supérieure à 0,20 pour chaque contraste |
| H5b | identité, associativité et composition des transports | zéro violation |
| H6 | épisodes multi-étapes et audit de l’historique | oubli au plus 0,01 appris, exactement zéro aux niveaux A/C |
| H7 | évaluation OOD après scellement et gel | score au moins 0,80, avantage inférieur borné au-dessus de 0,05, oubli au plus 0,01 |
| H8 | preuves Lean, calculs exhaustifs et optimum des classes bornées | aucune substitution statistique |

H3, H4 et H7 forment le triplet confirmatoire. Une hypothèse absente, non
calculée ou calculée hors protocole reçoit le statut missing, jamais passed.

## 2. État réel au 2026-07-20

### 2.1 Composants déjà présents

Les composants suivants existent et ont déjà servi au développement du niveau
A ou C. Ils sont historiques et ne doivent plus être modifiés après citation
d’un résultat. Toute variante devient un nouveau fichier.

| Composant | Statut actuel | Usage futur |
|---|---|---|
| SCIENTIFIC_PROTOCOL.md | présent, gelé | contrat normatif |
| trace_schema_v23.py | présent | schéma causal canonique |
| verify_trace_schema_v23.py | présent | vérification structurelle |
| test_trace_schema_v23.py | présent | tests négatifs et positifs du schéma |
| environment_v23.py | présent | erreurs, hashes, valeurs typées, provenance |
| finite_reference_domain_v23.py | présent | niveau A exact |
| finite_interventions_v23.py | présent | interventions finies |
| verify_finite_reference_v23.py | présent | vérificateur sémantique indépendant |
| verify_finite_interventions_v23.py | présent | vérification des interventions finies |
| certify_information_v23.py | présent | certificat informationnel |
| verify_information_v23.py | présent | recalcul indépendant |
| certify_visible_factored_nogo_v23.py | présent | no-go factorisé |
| verify_visible_factored_nogo_v23.py | présent | vérification indépendante |
| certifiable_agent_v23.py | présent | architecture entière quantifiée |
| train_certifiable_agent_v23.py | présent | entraînement du niveau C |
| verify_quantized_inference_v23.py | présent | rejeu exact du checkpoint |
| export_quantized_agent_v23.py | présent | export Lean des poids et décisions |
| certify_quantized_semantic_alignment_v23.py | présent | fermeture sémantique des lots |
| compile_lean_trace_v23.py | présent | concordance Lean/Python |
| tests Python existants | présents | non-régression A/C |
| checkpoint de développement | présent | preuve d’habitabilité, pas run B |

Le checkpoint actuel couvre 697 obligations réifiées avec zéro erreur et une
marge entière minimale de 1. Il constitue le niveau C de développement. Il ne
doit pas être présenté comme la campagne apprise complète.

### 2.2 Composants obligatoires absents

Les éléments suivants doivent être créés :

| Fichier ou dossier | Responsabilité |
|---|---|
| README.md | guide d’exécution local du dossier v23 |
| perceptual_compositional_domain_v23.py | domaine perceptuel de niveau B |
| symbolic_repair_domain_v23.py | domaine symbolique de niveau B |
| model_v23.py | agent complet, variantes et baselines |
| train_v23.py | entraînement déterministe unitaire |
| campaign_v23.py | génération des matrices de runs et agrégation |
| freeze_and_run_v23.py | unique lanceur scientifique normatif |
| certify_causality_v23.py | calcul des certificats H4/H5/H5b |
| verify_causality_v23.py | recalcul causal indépendant |
| certify_dynamics_v23.py | certificats H6, fermeture et persistance |
| verify_dynamics_v23.py | recalcul dynamique indépendant |
| audit_information_flow_v23.py | audit anti-fuite et budgets |
| falsify_verifiers_v23.py | mutations systématiques des certificats |
| audit_scientific_contract_v23.py | décision G0–G8 |
| protocol.lock.json | verrou de provenance |
| manifests/ | manifestes publics et privés |
| snapshots/ | copies figées des scripts exécutés |
| runs/ | sorties scientifiques immuables |
| reports/ | rapports agrégés et verdict final |

Des fichiers de tests nouveaux sont obligatoires pour chaque module créé. Ils
peuvent être ajoutés sans changer le protocole, avec un nom explicite se
terminant par _v23.py.

Modules auxiliaires nouveaux autorisés et propriétaires de responsabilités :

| Fichier | Responsabilité exclusive |
|---|---|
| level_b_contract_v23.py | Protocols Python, EpisodeBundle et types communs B |
| deterministic_seeds_v23.py | dérivation SHA-256 et vecteurs de test |
| perceptual_renderer_v23.py | renderer producteur entier |
| verify_perceptual_domain_v23.py | sémantique perceptuelle indépendante |
| verify_symbolic_domain_v23.py | sémantique SSA indépendante |
| baselines_v23.py | registre et classes B1–B13 |
| statistics_v23.py | bootstrap, permutations et Holm |
| verify_statistics_v23.py | golden tests et recalcul indépendant |
| seal_ood_v23.py | chiffrement, Merkle et journal d’ouverture |
| resource_accounting_v23.py | paramètres, FLOPs, mémoire et latence |
| test_level_b_contract_v23.py | contrats, sérialisation et anti-fuite |
| test_perceptual_domain_v23.py | domaine perceptuel |
| test_symbolic_domain_v23.py | domaine symbolique |
| test_model_v23.py | chaîne causale et masques |
| test_campaign_v23.py | matrice, reprise et immutabilité |
| test_statistics_v23.py | statistiques exactes |
| requirements-v23.lock | dépendances Python et hashes |
| Containerfile.v23 | image OCI reproductible |

Ces modules importent les scripts historiques lorsque nécessaire mais ne les
réécrivent pas. Le bundle source et le lock couvrent aussi les fichiers
auxiliaires.

### 2.3 Intégration exacte du niveau A et des no-go

Même si le code existe, les profils finite-conformance et certify doivent
recalculer les obligations suivantes ; ils ne doivent pas seulement constater
la présence des fichiers.

#### Référence finie

~~~text
Value = red | green | blue
Index = first | second | third
World = Value × Value × Value
Candidate = Option Value × Option Value × Option Value
Knowledge = unknown | excludes Value | exact Value
CandidatePatch = set Index Value | keep
Agrees(prediction, target) iff prediction = Some target
~~~

Le profil énumère :

- les 27 mondes dans l’ordre lexicographique ;
- tous les états atteignables ;
- toutes les requêtes bien typées ;
- toutes les interventions finies énumérables ;
- l’orbite canonique de trois réparations ;
- les quatre candidats distincts ;
- la fermeture et la stabilité de state3.

Observation initiale :

~~~text
first = exact red si world.first = red, sinon excludes red
second = unknown
third = unknown
~~~

Candidate initiale :

~~~text
first = Some red
second = None
third = None
~~~

Le détecteur inspecte first, puis second, puis third et produit exactement
witnessedMismatch ou unresolvedFiber.

Directions d’usage :

~~~text
correctWitnessedMismatch
inspectWitnessedMismatch
resolveFiber
inspectFiber
~~~

Le transport enregistre séparément lecture, focus candidate ou evidence,
index, caractère informatif et raccord au gap et à l’usage.

Requêtes dépendantes :

~~~text
reveal index -> revealed Value
confirm index -> confirmed Value
noInformation index -> noInformation
~~~

reveal et confirm sont naturels ; noInformation est interventionnel seulement.
Le monde canonique est green, green, green. L’orbite ferme first, second puis
third en exactement trois transitions.

La concordance couvre exactement :

~~~text
observe
detectGap
authorize
executeTransport
selectQuery
respond
buildRepair
executeRepair
CompatibleWorlds
GapClosedBy
KnownCorrectAt
KnownClosedOn
ClosedOn
~~~

#### Politique passive

La classe auditée est PassiveClosurePolicy. Elle reçoit AgentClosureState et sa
mémoire, peut appliquer des patches, mais ne peut ni appeler respond ni
rafraîchir l’observation depuis le monde.

Budget primaire :

~~~text
steps = 3
memoryCells = 256
interactionQueries = 0
~~~

Courbes exactes :

~~~text
steps = 0, 1, 2, 3, 4, 8
memoryCells = 0, 16, 64, 256, 1024
interactionQueries = 0
~~~

#### Contrôleur visible factorisé

Les classes sont VisibleFactoredClosureController et
FiniteVisibleFactoredClosureController. Le budget primaire est :

~~~text
steps = 1
interactionQueries = 1
responseBits <= 2
candidatePatches <= 1
~~~

Le certificat publie deux états complets ayant le même FiniteVisibleState,
leurs deux FiniteFactoredAction requises askLeft et askRight incompatibles, et
la preuve qu’une fonction du visible choisit la même action.

#### Meilleur contrôleur fini

Le producteur :

1. énumère toutes les fonctions déterministes de la classe ;
2. calcule l’optimum randomisé par programme linéaire rationnel ;
3. publie le nombre de contrôleurs, le meilleur taux moyen, le pire cas, la
   paire témoin et les actions incompatibles.

Le vérificateur reconstruit la classe et l’optimum sans réutiliser le verdict
du producteur.

#### Capacité complète du transcript

Le calcul inclut :

~~~text
observation initiale
choix et ordre des requêtes
longueur et arrêt
réponses
mémoire initiale et mise à jour
randomisation publique ou privée
patches
refus typés
~~~

Pour chaque budget fini, le script énumère l’arbre adaptatif complet et publie
le nombre de feuilles, la profondeur, les choix par nœud et le plafond du
logarithme binaire du nombre de feuilles. Il fournit séparément :

- une paire de feuilles indistinguables aux cibles incompatibles ;
- une politique active typée suffisante sous le budget supérieur annoncé.

Un calcul limité aux seuls bits des réponses échoue G4.

## 3. Principes d’ingénierie non négociables

### 3.1 Immutabilité

- Ne jamais modifier un script historique après qu’il a produit un résultat
  cité.
- Toute correction ou variante reçoit un nouveau nom.
- Toute exécution scientifique utilise une copie figée du script principal.
- Une sortie existante n’est jamais écrasée.
- Une reprise après incident reçoit un nouveau run_id.
- Tous les échecs restent publiables et traçables.

### 3.2 Nommage des snapshots

Chaque script exécuté scientifiquement est copié sous :

~~~text
stem_YYYYMMDD_HHMMSS_sha256-12.py
~~~

Les sorties reprennent exactement le même suffixe :

~~~text
profile_YYYYMMDD_HHMMSS_sha256-12.jsonl
profile_YYYYMMDD_HHMMSS_sha256-12.txt
profile_YYYYMMDD_HHMMSS_sha256-12.manifest.json
~~~

Le fichier texte commence par :

~~~text
commande complète
chemin du snapshot
SHA-256 complet du snapshot
SHA-256 du protocole
SHA-256 du bundle source
versions Python et dépendances
image OCI et digest
plateforme, CPU, GPU, pilote, CUDA et cuDNN
seeds
variables d’environnement pertinentes
heure UTC de début
~~~

### 3.3 Séparation des données

Trois espaces physiques sont nécessaires :

| Espace | Contenu | Accès |
|---|---|---|
| public | observations, candidats, historiques, réponses obtenues, traces publiables | agent et vérificateurs |
| privé | 32 mondes, monde réel, sels de commitment, clés OOD | générateur et vérificateur sémantique seulement |
| scellé | blobs OOD chiffrés et clés enveloppées | processus de scellement puis processus d’ouverture |

Le processus d’entraînement ne reçoit jamais :

- SemanticWorld ;
- Target futur ;
- liste des 32 mondes ;
- identifiant du monde réel ;
- patch correct ;
- programme latent ;
- clé de déchiffrement OOD ;
- données de test ou OOD non ouvertes.

### 3.4 Déterminisme

- Aucun générateur aléatoire global.
- Toute sous-seed est dérivée par SHA-256 selon le protocole.
- PyTorch utilise les algorithmes déterministes.
- Le test de déterminisme précède la première mise à jour.
- Deux passes identiques doivent produire les mêmes tenseurs et décisions.
- L’échec de déterminisme arrête le run avant entraînement.

### 3.4.1 Environnement de référence

Le développement et les contrôles de compatibilité ciblent :

~~~text
Python 3.10.12
PyTorch 2.10.0
NumPy 2.1.1
Lean 4.29.0
~~~

Le run final utilise une image OCI identifiée par digest, un lockfile exact et
un rapport matériel. Une autre version est un run de réplication explicitement
nommé, pas un remplacement silencieux du primaire.

### 3.5 Indépendance des vérificateurs

Un producteur et son vérificateur ne doivent pas partager la fonction qui
calcule le jugement contrôlé. Ils peuvent partager :

- les types de sérialisation ;
- les constantes normatives ;
- le parseur canonique ;
- les primitives cryptographiques.

Ils ne peuvent pas partager :

- detect_gap lorsqu’il est vérifié ;
- compatible_worlds lorsqu’il est vérifié ;
- gap_closed_by lorsqu’il est vérifié ;
- la fonction de score lorsqu’elle est auditée ;
- un validity_flag produit par le modèle.

## 4. Architecture logicielle cible

La dépendance autorisée est :

~~~text
protocole et constantes
        |
        v
schéma canonique et provenance
        |
        +------------------+
        |                  |
        v                  v
domaines producteurs   vérificateurs indépendants
        |
        v
modèles et baselines
        |
        v
entraînement unitaire
        |
        v
orchestrateur de campagne
        |
        v
snapshots et runs immuables
        |
        +------------------+
        |                  |
        v                  v
certificats           analyses statistiques
        |                  |
        +--------+---------+
                 v
          audit G0–G8
                 |
                 v
         rapport de publication
~~~

Le monde privé ne doit jamais posséder une arête vers les modèles. Il ne peut
alimenter que respond, les générateurs et les vérificateurs sémantiques.

## 5. Contrat Python commun aux domaines

### 5.1 Types obligatoires

Chaque domaine définit des types distincts pour :

~~~text
SemanticWorld
Candidate
Observation
RepairRecord
VisibleIndex
Prediction
Target
CandidatePatch
OperationalGap
GapAuthorizedUse
GapAuthorizedTransport
Query
Response dépendante de Query
IntrinsicRepair
AgentClosureState
~~~

L’implémentation doit utiliser des dataclasses gelées, enums et unions
discriminées. Aucun dictionnaire générique n’est utilisé dans le cœur
sémantique. Les dictionnaires sont réservés à la frontière de sérialisation.

### 5.2 Interface fonctionnelle

Chaque domaine expose :

~~~text
observe(world) -> Observation
interpret(candidate, index) -> Prediction
evaluate(world, index) -> Target
agrees(prediction, target) -> bool
detect_gap(agent_view) -> OperationalGap ou Closed
authorize(agent_view, gap) -> GapAuthorizedUse
execute_transport(agent_view, gap, use) -> GapAuthorizedTransport
select_query(transport) -> Query
respond(world, query) -> Response
build_repair(agent_view, gap, use, transport, query, response)
  -> IntrinsicRepair
execute_repair(agent_view, repair) -> AgentClosureState
compatible_worlds(agent_view, private_family) -> tuple de mondes
known_correct_at(agent_view, private_family, index) -> bool
gap_closed_by(before, gap, after, private_family) -> bool
~~~

Les cinq fonctions agentiques suivantes ne reçoivent aucune donnée privée :

~~~text
detect_gap
authorize
execute_transport
select_query
build_repair
~~~

### 5.3 Épisode fermé

Un EpisodeBundle contient :

~~~text
episode_id
domain
split
environment_seed
private_family de 32 mondes distincts
real_world_index privé
observation publique
candidate initiale
historique initial
budget
fingerprint structurel
world_commitments
~~~

Le constructeur rejette tout épisode ne satisfaisant pas simultanément :

- exactement 32 mondes distincts ;
- monde réel dans la famille ;
- au moins deux observations initiales distinctes ;
- au moins quatre mondes partageant l’observation réelle ;
- au moins deux cibles au premier gap ;
- au moins une requête informative ;
- conservation du monde réel après réponse ;
- élimination d’au moins un monde par réponse informative ;
- détermination du gap après réparation ;
- fermeture de tous les gaps dans le budget ;
- au moins trois gaps distincts ;
- trois réparations effectives ;
- quatre candidats distincts.

### 5.4 Sérialisation

Chaque type fournit :

~~~text
to_canonical_dict
from_canonical_dict_strict
type_tag
schema_version
~~~

Le décodeur :

- refuse les champs inconnus ;
- refuse les champs manquants ;
- refuse NaN et infini ;
- refuse les doublons de clés ;
- contrôle les tags dépendants ;
- contrôle les bornes des entiers ;
- exige NFC pour les chaînes ;
- exige l’ordre canonique des listes ordonnées ;
- ne corrige jamais silencieusement une valeur invalide.

L’encodage JSON exact utilise UTF-8, des clés triées, les séparateurs virgule
et deux-points sans espaces, des entiers décimaux, des booléens JSON, des
chaînes NFC et aucun NaN ou infini. Les blobs binaires sont en hexadécimal
minuscule avec longueur explicite.

### 5.5 Schéma causal complet de trace

Chaque ligne JSONL correspond à une transition et possède exactement les
champs normatifs suivants :

~~~text
schema_version
protocol_version
run_id
training_seed
environment_seed
domain
split
episode_id
step
checkpoint_sha256
source_bundle_sha256
executed_script_sha256
command_sha256
producer_kind

world_commitment
agent_input_manifest
state_before
compatible_fiber_before
gap_status
execution_status
refusal_stage
refusal_reason
gap
gap_evidence
authorized_use
authorized_transport
query
query_footprint
response
response_footprint
intrinsic_repair
state_after
compatible_fiber_after
gap_closed_by
known_closed_prefix
persistence_obligations
state_after_hash

intervention_kind
intervention_payload
fixed_variables
recomputed_variables
natural_trace_hash
validity_flags
~~~

producer_kind appartient exactement à :

~~~text
reference
certifiable_agent
scaling_agent
baseline
~~~

checkpoint_sha256 est nul uniquement pour reference. Aucun hash sentinelle
n’est admis.

execution_status appartient exactement à :

~~~text
advanced
closed_stasis
typed_refusal
~~~

Règles de statut :

- advanced matérialise toute la chaîne jusqu’à state_after ;
- closed_stasis ne contient aucun gap, usage, transport, requête, réponse ou
  réparation et conserve l’état par identité ;
- typed_refusal indique le premier stade invalide, conserve l’état et ne
  fabrique aucune valeur causale postérieure ;
- une trace naturelle n’est jamais typed_refusal ;
- I_next_bypass n’est valide que comme typed_refusal au stade next ;
- aucune sentinelle causale ne représente une branche fermée.

agent_input_manifest contient uniquement les informations publiques réellement
présentées au modèle. Le parseur recherche récursivement les clés privées ou
interdites.

world_commitment est le SHA-256 du monde complet salé par épisode. Le monde et
le sel sont ouverts au vérificateur seulement après production des décisions.

query_footprint et response_footprint sont recalculés depuis le constructeur
dépendant :

- niveau A : reveal ou confirm, au plus 2 bits ; noInformation, 0 bit ;
- perceptuel : crop, exactement 768 octets, ou champ typé borné ;
- symbolique : Z8, 3 bits, plus tags fixes.

validity_flags restent de simples déclarations. Aucun vérificateur ne conclut
depuis ces drapeaux.

### 5.6 Réalisation fondationnelle commune

#### Contextes

Un contexte est un historique canonique fini :

~~~text
gamma = observationInitiale, interaction_0, ..., interaction_n
~~~

Un morphisme gamma vers delta est une preuve que gamma est préfixe de delta.
L’identité est la réflexivité du préfixe et la composition sa transitivité.
Python stocke longueur et hash de préfixe ; Lean porte la preuve.

Tests :

- identité gauche et droite ;
- associativité ;
- refus d’un faux préfixe ;
- hash cohérent avec la longueur ;
- réindexation inchangée le long de l’identité.

#### Langage indexé

Les termes disponibles à un contexte sont :

~~~text
indices visibles
candidats atteignables
lectures de prédiction
gaps issus du contexte
usages autorisés
transports autorisés
réparations dérivées d’une réponse du contexte
~~~

La réindexation conserve seulement les objets dont la provenance reste valide.
Elle ne crée ni réponse ni réparation.

#### Doctrine

Implémenter et tracer :

~~~text
CompatibleWithHistory
KnownCorrectAt
KnownClosedOn
GapClosedBy
Persists
FiberDeterminate
~~~

L’identité interne sert aux substitutions. GapAuthorizedUse et
GapAuthorizedTransport servent aux transports relaxés. Les types et traces
doivent rendre impossible la confusion entre ces deux mécanismes.

## 6. Domaine perceptuel compositionnel

Fichier : perceptual_compositional_domain_v23.py.

### 6.1 Monde et rendu

Implémenter :

~~~text
Shape = square | circle | triangle | cross
Color = red | green | blue
Position = Fin 8 × Fin 8
Object = present, shape, color, x, y, slot
Scene = 3 à 6 objets
OcclusionOrder
PerceptualProgram
PerceptualWorld
~~~

Le renderer doit :

- produire exactement 64 × 64 pixels RGB ;
- utiliser uniquement une arithmétique entière ;
- être déterministe bit à bit ;
- résoudre les déplacements modulo 8 ;
- appliquer les commandes dans l’ordre ;
- résoudre l’occlusion par l’ordre latent ;
- fournir les états intermédiaires pour chaque préfixe ;
- produire un hash pour chaque image et chaque état intermédiaire.

Deux implémentations sont nécessaires :

1. le renderer producteur ;
2. un renderer de vérification indépendant ou une implémentation de référence
   suffisamment séparée pour détecter une erreur commune.

### 6.2 Langage de programmes

Implémenter les commandes exactement :

~~~text
selectShape(square | circle | triangle | cross)
selectColor(red | green | blue)
selectAll
move(dx, dy), dx et dy dans {-1, 0, 1}, non tous deux nuls
recolor(red | green | blue)
rotateQuarter(k), k dans {1, 2, 3}
reflect(horizontal | vertical)
release
~~~

Les opérations géométriques agissent sur la sélection courante. release
réinitialise la sélection à tous les objets.

Les longueurs d’entraînement sont 3, 4 et 5. OOD-composition utilise 6, 7 et 8
ainsi que des ordres d’opérateurs absents de train et validation.

Chaque commande possède :

- validateur de type ;
- exécuteur déterministe ;
- sérialiseur canonique ;
- générateur exhaustif de paramètres licites ;
- tests d’identité lorsque pertinent ;
- tests de composition ;
- tests de non-commutation.

### 6.3 Candidate, trous et patches

La candidate est un AST du même langage avec :

- tokens corrects ;
- tokens corrompus ;
- trous typés ;
- chemins AST canoniques ;
- masque public des trous.

L’observation publique initiale contient exactement :

~~~text
image d’entrée
image de sortie finale
programme candidat sérialisé
masque des trous
historique des requêtes et réponses
~~~

Elle ne contient ni programme latent, ni liste des corruptions, ni prochain
patch. Les mondes compatibles avec le réel partagent la même scène d’entrée et
la même image finale, mais diffèrent sur un préfixe, un état intermédiaire ou
un ordre d’occlusion. Cette collision est contrôlée pixel par pixel.

Un patch modifie exactement un emplacement :

~~~text
replaceOpcode
replaceArgument
fillHole
keep
~~~

Le validateur refuse :

- un chemin absent ;
- un opcode mal typé ;
- un argument hors domaine ;
- un remplissage incompatible avec le trou ;
- plusieurs modifications ;
- keep dans une trace naturelle ;
- un patch qui ne modifie pas la candidate ;
- un patch non dérivé de la réponse.

### 6.4 Indices et requêtes

Implémenter :

~~~text
cropIndex(stage, cropX, cropY)
objectFieldIndex(stage, slot, field)
renderCrop
inspectObject
noInformation
~~~

Les valeurs sémantiques sont :

~~~text
FieldValue = bool | Shape | Color | Fin 8
Target = cropTarget RGB16x16 | fieldTarget(field, FieldValue)
Prediction = Option Target
Agrees(p, t) iff p = Some t avec mêmes tag et valeur
~~~

Contrôles :

- stage dans la longueur du programme ;
- cropX et cropY dans Fin 4 ;
- slot dans Fin 6 ;
- field correctement tagué ;
- crop de 16 × 16, soit 768 octets ;
- champ objet limité à sa valeur et son tag ;
- aucune réponse ne contient un programme ou un patch ;
- une requête informative au plus par transition.

Le gap perceptuel contient seulement :

~~~text
index en défaut
witnessedMismatch ou unresolvedFiber
empreinte de différence accessible
plus ancien chemin candidat compatible
provenance observation ou historique
~~~

Il ne contient jamais l’opérateur latent attendu.

### 6.5 Générateur de familles

Le générateur :

1. choisit une structure de programme selon le split ;
2. génère une scène et un ordre d’occlusion ;
3. construit 32 mondes avant de choisir le monde réel ;
4. vérifie les collisions pixel par pixel ;
5. crée h corruptions réparables ;
6. calcule tous les postérieurs exacts ;
7. rejette jusqu’à satisfaction des obligations ;
8. calcule le fingerprint structurel ;
9. sérialise séparément partie publique et manifeste privé.

### 6.6 Tests obligatoires

- round-trip de chaque type ;
- rendu déterministe ;
- collision publique réelle mais mondes distincts ;
- projection non constante par blocs de 32 épisodes ;
- exactitude des crops ;
- exactitude des champs objets ;
- requête informative ;
- fibre strictement réduite ;
- monde réel conservé ;
- fermeture du gap ;
- conservation des préfixes ;
- trois réparations ;
- composition des commandes ;
- permutations non commutatives ;
- séparation train/OOD par fingerprint ;
- refus de toute fuite du programme latent.

## 7. Domaine symbolique de réparation

Fichier : symbolic_repair_domain_v23.py.

### 7.1 Langage SSA

Implémenter :

~~~text
Z8
input0
input1
const
add modulo 8
xor
ifZero
SSAInstruction
SSAProgram
~~~

Le typeur vérifie :

- 3 à 8 instructions ;
- chaque registre lu est strictement antérieur ;
- le dernier registre est la sortie ;
- chaque constante appartient à Z8 ;
- les deux branches de ifZero sont valides ;
- la normalisation SSA est déterministe.

Les programmes train ont 3 à 5 instructions. OOD-composition utilise 6 à 8
instructions et des graphes de dépendance absents de l’entraînement.

### 7.2 Interpréteur indépendant

Deux évaluateurs sont exigés :

1. exécuteur utilisé par le producteur ;
2. évaluateur du vérificateur, sans appel à l’exécuteur producteur.

Ils doivent concorder exhaustivement sur les programmes de test courts et sur
toutes les entrées Z8 × Z8 des épisodes publiés.

### 7.3 Observation et ambiguïté

L’observation publique contient :

- huit triplets input0, input1, output ;
- candidate SSA ;
- trous et corruptions visibles ;
- historique.

Le générateur vérifie que :

- au moins quatre programmes distincts partagent l’observation réelle ;
- les huit exemples initiaux sont identiques pour ces programmes ;
- au moins deux programmes diffèrent sur une requête admissible ;
- les programmes restent distincts après normalisation ;
- la projection n’est pas constante entre épisodes.

### 7.4 Requêtes et patches

Implémenter :

~~~text
RegisterIndex = instruction(Fin 8) | output
VisibleIndex = probeInput0, probeInput1, RegisterIndex
Prediction = Option Z8
Target = Z8
Agrees(p, t) iff p = Some t
executeRegister
executeOutput
noInformation
replaceOpcode
replaceOperand
replaceConstant
fillHole
keep
~~~

Une réponse contient une valeur Z8 et son tag de provenance. Elle ne contient
ni le programme latent ni le token correct.

noInformation et keep sont réservés aux interventions négatives. Une trace
naturelle qui les utilise est refusée.

### 7.5 Tests obligatoires

- typage SSA positif et négatif ;
- normalisation déterministe ;
- exécution modulo 8 ;
- exactitude des registres intermédiaires ;
- ambiguïté des huit exemples ;
- existence d’une probe séparatrice ;
- fibre exacte de 32 programmes ;
- réduction stricte ;
- action-suffisance après réparation ;
- un seul emplacement modifié ;
- fermeture de chaque gap ;
- persistance des réparations ;
- séparation structurelle des splits ;
- absence de fuite du programme latent.

## 8. Agent certifiable et modèle appris complet

Fichier : model_v23.py.

### 8.1 Intégration exacte de l’agent certifiable

L’intégration du niveau C réutilise les scripts historiques sans les modifier.
Son entrée canonique possède exactement 96 coordonnées Int8 :

~~~text
21 pour Observation
12 pour Candidate
21 pour au plus trois RepairRecord
4 pour la longueur d’historique
38 zéros de padding
~~~

Tout padding non nul invalide l’entrée.

Architecture :

~~~text
GapHead       : 96  -> 64 -> 64 logits
UseHead       : 160 -> 64 -> 8 logits
TransportHead : 168 -> 64 -> 64 logits
QueryHead     : 232 -> 64 -> 9 logits
RepairHead    : 257 -> 64 -> 10 logits
~~~

Catalogues one-hot :

~~~text
GapCatalog       : 64
UseCatalog       : 8
TransportCatalog : 64
QueryCatalog     : 9
ResponseCatalog  : 16
PatchCatalog     : 10
~~~

Les catalogues suivent l’ordre lexicographique des constructeurs Lean. Les
classes réservées ont un logit forcé à -128 et se décodent en refus.

Entrées aval :

~~~text
UseHead       = state96 + gap64
TransportHead = state96 + gap64 + use8
QueryHead     = state96 + gap64 + use8 + transport64
RepairHead    = state96 + gap64 + use8 + transport64 + query9 + response16
~~~

Une tête aval reçoit l’objet discret décodé et son one-hot, jamais les logits
cachés. La réponse provient uniquement de respond. L’état suivant provient
uniquement de execute_repair ; aucune NextHead.

Arithmétique exacte :

~~~text
poids et biais Int8
entrées et activations Int8
accumulateurs Int32
ReLU
division par puissance de deux
shift entre 0 et 15
arrondi au plus proche, égalité vers l’entier pair
saturation dans [-128, 127]
argmax
égalité d’argmax vers le plus petit index
~~~

Les primitives sont nommées round_ties_to_even, saturate_int8 et
canonical_argmax et possèdent des tests de bord exhaustifs sur leurs domaines
finis pertinents.

L’entraînement du niveau C utilise :

~~~text
toutes les entrées finies et interventions licites
AdamW
learning_rate = 0.001
betas = 0.9, 0.95
weight_decay = 0
batch complet
maximum 2000 updates
seeds 0 à 9
~~~

Le premier checkpoint admissible selon l’ordre seed, update est primaire. Il
doit obtenir zéro erreur après quantification. Son absence échoue G3 sans
assouplissement.

Le profil certifiable-agent doit :

1. rejouer l’entraînement ou vérifier son replay gelé ;
2. recharger le JSON canonique ;
3. recalculer les 697 inférences ;
4. contrôler dimensions, bornes, catalogues, arrondi, saturation et argmax ;
5. exporter les modules Lean ;
6. reconstruire les 697 références sémantiques ;
7. compiler le point d’entrée ;
8. publier l’audit d’axiomes.

### 8.2 Structure du modèle appris

Le modèle contient :

~~~text
ObservationEncoder
CandidateEncoder
HistoryEncoder
ContextAggregator
GapHead
UseHead
TransportHead
QueryHead
RepairHead
SymbolicRepairExecutor
~~~

La méthode forward naturelle calcule strictement :

~~~text
contexte
-> gap discret validé
-> usage discret validé
-> transport discret validé
-> requête discrète validée
-> réponse produite par le domaine
-> réparation discrète validée
-> execute_repair
-> état suivant
~~~

Il n’existe :

- aucune NextHead ;
- aucun chemin contexte vers patch ;
- aucun chemin monde vers tête ;
- aucun passage des logits cachés entre têtes ;
- aucune normalisation silencieuse d’une sortie invalide.

### 8.3 Encodeur perceptuel

Implémenter quatre convolutions 3 × 3 :

| Couche | Canaux | Stride | Padding | Activation |
|---|---:|---:|---:|---|
| 1 | 32 | 2 | 1 | ReLU |
| 2 | 64 | 2 | 1 | ReLU |
| 3 | 128 | 2 | 1 | ReLU |
| 4 | d_model | 1 | 1 | aucune |

Concaténer :

- tokens spatiaux ;
- tokens de candidate ;
- tokens d’historique ;
- tags de type appris ;
- positions canoniques.

### 8.4 Encodeur symbolique

Chaque token possède :

- embedding de type ;
- embedding de position ;
- embedding de valeur ;
- tag de provenance ;
- masque causal.

La longueur maximale est 512. Le générateur rejette avant partition tout
épisode dépassant cette limite. L’évaluation ne tronque jamais un épisode
accepté.

### 8.5 Agrégateur

Transformer pré-norm à attention causale :

| Taille | d_model | Couches | Têtes | d_ff |
|---|---:|---:|---:|---:|
| small | 64 | 2 | 4 | 256 |
| base | 128 | 4 | 8 | 512 |
| large | 256 | 8 | 8 | 1024 |

Chaque tête est un MLP d_model vers d_model vers logits avec ReLU.

Le modèle base est primaire. Small et large servent aux courbes de scaling.

### 8.6 Masques typés

Pour chaque décision :

1. produire les logits ;
2. calculer indépendamment l’ensemble des valeurs typées disponibles ;
3. masquer les autres classes ;
4. appliquer argmax ;
5. départager par index canonique ;
6. décoder strictement ;
7. produire typed_refusal si le décodage échoue.

Le masque ne reçoit pas le monde privé et ne doit pas encoder indirectement la
réponse correcte.

### 8.7 ONNX

Exporter chaque checkpoint retenu vers ONNX Runtime CPU. Sur toutes les traces
publiées :

- mêmes décisions discrètes à 100 % ;
- erreur absolue des logits au plus 1e-5 ;
- publication des décisions à marge inférieure à 1e-4 ;
- aucune substitution ONNX pendant la sélection du checkpoint.

## 9. Baselines B1–B13

Toutes les baselines sont enregistrées dans un registre unique avec :

~~~text
system_id
classe scientifique
entrées autorisées
actions autorisées
budget
nombre de paramètres
FLOPs
motif d’inclusion ou d’exclusion du contraste principal
~~~

### 9.1 Spécification

| ID | Implémentation obligatoire | Contraste principal |
|---|---|---|
| B1 | observation seule, sans candidate structurée | admissible |
| B2 | candidate seule, sans observation sémantique | admissible |
| B3 | toutes les observations initiales, sans interaction | admissible |
| B4 | mémoire récurrente, aucune requête | admissible |
| B5 | requêtes actives sans gap/use/transport typés | admissible |
| B6 | modèle latent et planificateur | admissible |
| B7 | décisions factorisées par le visible déclaré | admissible |
| B8 | requête puis patch monolithique | admissible |
| B9 | oracle externe de patch après réponse | diagnostic seulement |
| B10 | même architecture, gap aléatoire | admissible |
| B11 | gap calculé mais inaccessible aux têtes aval | admissible |
| B12 | état suivant directement prédit | diagnostic seulement |
| B13 | système gap-driven complet | système testé |

### 9.2 Équité

Pour chaque domaine et taille :

- observations publiques identiques ;
- réponses aux requêtes choisies identiques ;
- même nombre maximal de pas ;
- même budget de réponses ;
- paramètres à plus ou moins 5 % ;
- FLOPs par épisode à plus ou moins 10 % ;
- même protocole de réglage ;
- mêmes épisodes d’évaluation ;
- aucune baseline artificiellement privée d’une ressource non définitoire.

Si une baseline ne peut respecter les paramètres sans changer de classe :

1. l’écart est documenté avant entraînement ;
2. elle est placée sur la courbe de ressources ;
3. elle est exclue du contraste principal apparié ;
4. son résultat reste publié.

### 9.3 Tests anti-contournement

- B10 reçoit réellement des gaps aléatoires ;
- B11 calcule le gap mais le gradient et l’activation ne l’atteignent pas ;
- B12 ne peut être cité comme réparation intrinsèque ;
- B9 est marqué oracle ;
- B13 ne possède aucun bypass ;
- chaque baseline reçoit exactement ses entrées déclarées ;
- les paramètres morts ne sont pas comptés ;
- les FLOPs sont mesurés sur les branches exécutées.

### 9.4 Budgets empiriques exacts

Pour une cible de longueur h, tous les systèmes interactifs reçoivent :

~~~text
steps <= h
queries <= h
candidatePatches <= h
au plus une réponse informative par step
mémoire sérialisée <= 64 KiB pour base
réponse perceptuelle <= 768 octets ou un champ objet
réponse symbolique <= 3 bits plus tags fixes
~~~

Les courbes de Pareto couvrent :

~~~text
h = 1, 3, 5, 8, 12, 16
size = small, base, large
~~~

Le score principal utilise base et un budget égal au nombre de corruptions
générées. Les rapports enregistrent les coûts réellement consommés en
requêtes, octets, patches, paramètres et FLOPs, pas seulement les plafonds.

## 10. Entraînement

Fichier : train_v23.py.

### 10.1 Une commande, un run

train_v23.py exécute exactement un tuple :

~~~text
domain
system
size
regime
hyperparameters
training_seed
data_manifest
maximum_updates
output_directory inexistant
~~~

Il ne décide ni de la matrice globale ni de l’ouverture OOD.

### 10.2 Régimes

| Régime | Supervision |
|---|---|
| R_supervised | labels de tous les objets intermédiaires |
| R_intermediate | labels gap/use/transport, récompense query/repair |
| R_causal | observation, réponses, fermeture et coûts seulement |

Les poids ne sont jamais transférés entre régimes.

### 10.3 Configuration finale

~~~text
AdamW
betas = 0.9, 0.95
weight_decay = 0.01
gradient_clip_norm = 1.0
batch_size = 64 épisodes
updates = 120000
warmup = 5000
cosine vers 10 % du taux initial
FP32
checkpoint tous les 5000 updates
~~~

Objectif R_causal :

~~~text
1.0 fermeture terminale
+ 0.5 coût de requête normalisé
+ 1.0 violation typée
+ 1.0 oubli
+ 0.5 cohérence compositionnelle
~~~

Une action invalide termine l’épisode avec score nul.

### 10.4 Réglage

Grille :

~~~text
learning_rate = 0.0001, 0.0003, 0.001
weight_decay = 0, 0.01
dropout = 0, 0.1
~~~

Soit 12 configurations par système et seeds 100, 101, 102, pendant 30000
updates. L’ordre de sélection est :

1. score structurel ;
2. fermeture ;
3. moins de requêtes ;
4. ordre lexicographique.

### 10.5 Runs finaux

- seeds 0 à 9 ;
- entraînement depuis zéro ;
- exactement 120000 updates ;
- aucune seed remplacée ;
- checkpoints tous les 5000 updates ;
- sélection par score structurel, fermeture, puis plus petit update ;
- NaN, faible score ou divergence numérique après démarrage restent des
  résultats ;
- seul un incident admissible crée un nouveau run_id.

Les seuls incidents admissibles sont :

~~~text
erreur matérielle enregistrée
fichier corrompu confirmé par hash
violation documentée du protocole de données
échec du déterminisme avant la première mise à jour
~~~

Un score faible, une divergence numérique ou une perte NaN après le démarrage
scientifique ne permettent ni exclusion ni remplacement.

### 10.6 Sorties

Chaque run contient :

~~~text
run_manifest.json
command.txt
environment.json
metrics_train.jsonl
metrics_validation.jsonl
checkpoints/
selected_checkpoint.json
selected_checkpoint.sha256
onnx/
determinism_report.json
resource_report.json
incident_report.json ou null
completion.marker créé en dernier
~~~

## 11. Génération des partitions

### 11.1 Volumes

Par domaine :

| Partition | Nombre |
|---|---:|
| IID validation | 4096 |
| validation structurelle | 4096 par famille |
| IID test | 8192 |
| OOD scellé | 8192 par famille |
| interventions | 4096 par type et seed finale |

L’entraînement génère les batches en ligne pour h dans 3, 4, 5.

### 11.2 OOD

Familles :

~~~text
OOD-composition
OOD-horizon
OOD-presentation
OOD-action-response
OOD-cross-family
~~~

La famille principale est OOD-composition.

Définitions exactes :

- OOD-composition : programmes de longueur 6, 7, 8 et ordres inédits ;
- OOD-horizon : h égal à 8, 12 ou 16 ;
- OOD-presentation : palettes, formes, occlusions ou noms de tokens inédits ;
- OOD-action-response : combinaisons requête/réponse absentes de train ;
- OOD-cross-family : composition et présentation simultanées.

Les fingerprints incluent :

- suite d’opcodes ;
- graphe de dépendance ;
- profondeur ;
- patrons d’arguments ;
- forme normale AST.

Avant entraînement, un auditeur indépendant prouve la disjonction entre
OOD-composition et tous les splits non OOD.

### 11.3 Seeds

| Usage | Seeds |
|---|---|
| réglage | 100, 101, 102 |
| entraînement final | 0 à 9 |
| référence finie | 230000 |
| IID validation | 231000 |
| validation structurelle | 232000 |
| IID test | 233000 |
| OOD scellé | 234000 |
| interventions | 235000 |
| réplication évaluation | 236000 |
| réplication entraînement | 10 à 19 |

La fonction de dérivation de sous-seed possède des vecteurs de test fixes et
une implémentation indépendante dans l’auditeur.

## 12. Scellement OOD

Profil responsable : sealed-ood.

### 12.1 Création

1. Générer les épisodes avec seed 234000.
2. Valider la disjonction structurelle.
3. Sérialiser chaque épisode canoniquement.
4. Tirer une clé AES-256 et un nonce de 96 bits uniques par blob.
5. Chiffrer avec AES-256-GCM.
6. Utiliser le hash du manifeste public comme données associées.
7. Construire le Merkle root des blobs.
8. Publier nombres, tailles, familles et Merkle root.
9. Envelopper les clés avec la clé de campagne.
10. Déplacer la clé de campagne hors de la machine d’entraînement.

### 12.2 Contrôles

- aucune réutilisation de nonce ;
- authentification de chaque blob ;
- clés absentes du dépôt et des conteneurs de train ;
- permissions et accès enregistrés ;
- journal append-only ;
- checkpoints et évaluateur hashés avant ouverture ;
- ouverture irréversible enregistrée avec heure UTC ;
- toute ouverture prématurée invalide la partition.

### 12.3 Gestion d’incident

Une partition compromise :

- n’est jamais réparée en place ;
- conserve son journal ;
- reçoit le statut invalidated ;
- impose une nouvelle version de protocole et une nouvelle seed ;
- ne peut contribuer à H7.

## 13. Orchestration

### 13.1 campaign_v23.py

Responsabilités :

- construire la matrice exhaustive des runs ;
- produire un identifiant stable pour chaque cellule ;
- détecter doublons et omissions ;
- estimer paramètres, FLOPs, stockage et temps ;
- matérialiser le DAG de dépendances ;
- lancer uniquement des snapshots figés ;
- ne jamais écraser une sortie ;
- agréger les statuts sans interpréter les résultats scientifiques.

La matrice explicite :

~~~text
domain × system × size × regime × configuration × seed × split × profile
~~~

Les exclusions sont déclarées dans un manifeste avant run, avec justification
directement dérivée du protocole. Aucune exclusion implicite.

### 13.2 freeze_and_run_v23.py

Unique entrée scientifique. Il :

1. vérifie le hash du protocole ;
2. vérifie protocol.lock.json ;
3. vérifie que le workspace source est autorisé ;
4. calcule le hash du bundle ;
5. copie le script dans snapshots ;
6. vérifie le nom timestamp/hash ;
7. crée un dossier de sortie inexistant ;
8. écrit la provenance avant calcul ;
9. lance le profil demandé ;
10. capture stdout, stderr et code retour ;
11. calcule les hashes de sortie ;
12. écrit le manifeste final ;
13. crée completion.marker en dernier.

Profils autorisés :

~~~text
finite-conformance
certifiable-agent
tune
final-train
interventions
sealed-ood
certify
falsify
replicate-eval
replicate-train
~~~

Tout autre profil est refusé.

### 13.3 Reprise

Un run incomplet :

- reste immuable ;
- reçoit un incident_report ;
- ne reçoit jamais completion.marker ;
- peut être relancé sous un nouveau run_id ;
- garde un lien replaces_attempt uniquement informatif ;
- n’est jamais effacé.

### 13.4 Commandes normatives finales

Après implémentation et avant publication, les seules entrées de campagne sont :

~~~bash
python freeze_and_run_v23.py --profile finite-conformance
python freeze_and_run_v23.py --profile certifiable-agent
python freeze_and_run_v23.py --profile tune
python freeze_and_run_v23.py --profile final-train
python freeze_and_run_v23.py --profile interventions
python freeze_and_run_v23.py --profile sealed-ood
python freeze_and_run_v23.py --profile certify
python freeze_and_run_v23.py --profile falsify
python freeze_and_run_v23.py --profile replicate-eval
python freeze_and_run_v23.py --profile replicate-train
python audit_scientific_contract_v23.py --require-all-gates
~~~

Le lanceur refuse toute dépendance, source, configuration ou partition qui
n’est pas couverte par le lock et le manifeste du run.

## 14. Interventions causales

Fichiers :

- certify_causality_v23.py ;
- verify_causality_v23.py.

### 14.1 Matrice

Implémenter les 18 interventions :

~~~text
I_projection
I_gap_suppress
I_gap_permute
I_use_suppress
I_use_permute
I_transport_suppress
I_transport_permute
I_query_neutral
I_query_alternate
I_response_cross
I_response_neutral
I_repair_neutral
I_repair_permute
I_next_bypass
I_history_drop
I_order_swap
I_random_gap
I_unused_gap
~~~

Correspondance normative :

| Cible | Interventions |
|---|---|
| projection | I_projection |
| gap | I_gap_suppress, I_gap_permute, I_random_gap |
| use | I_use_suppress, I_use_permute, I_unused_gap |
| transport | I_transport_suppress, I_transport_permute, I_order_swap |
| query | I_query_neutral, I_query_alternate |
| response | I_response_cross, I_response_neutral |
| repair | I_repair_neutral, I_repair_permute |
| next | I_next_bypass |
| history | I_history_drop |

### 14.2 Appariement

Chaque intervention réutilise :

- monde ;
- checkpoint ;
- seed de bruit ;
- état initial ;
- budget ;
- épisode ;
- ordre des opérations non ciblées.

Les ancêtres stricts sont fixes. La cible et tous ses descendants sont
recalculés.

### 14.3 Partition causale

fixed_variables et recomputed_variables doivent être :

- disjoints ;
- complets ;
- ordonnés ;
- sans variable inconnue ;
- conformes au DAG des neuf variables.

I_next_bypass produit obligatoirement typed_refusal au stade next.

### 14.4 Certificat H4/H5

Le certificat contient :

- taux de suivi du gap naturel ;
- taux de suivi du gap intervenu ;
- contraste apparié ;
- résultats par domaine et seed ;
- intervalles hiérarchiques ;
- inversions de signe exactes ;
- refus mal typés ;
- violations de partition causale ;
- exemples minimaux ;
- hashes des traces.

Le vérificateur recalcule les descendants et les statistiques depuis les
traces, sans lire le verdict du certificat.

## 15. Dynamique et persistance

Fichiers :

- certify_dynamics_v23.py ;
- verify_dynamics_v23.py.

Le certificat contrôle pour chaque transition :

- monde réel dans la fibre avant et après ;
- inclusion de la fibre ;
- réduction stricte lorsqu’un gap est ouvert ;
- gap courant fermé ;
- candidate effectivement modifiée ;
- réparation dérivée de la réponse ;
- état suivant égal à execute_repair ;
- chaque réparation antérieure conservée ;
- KnownClosedOn monotone ;
- closed_stasis par identité ;
- progression jusqu’à fermeture ou budget.

Agrégats :

- oubli cumulatif par épisode ;
- oubli par horizon ;
- succès par nombre de corruptions ;
- requêtes et patches ;
- taille de fibre ;
- composition des transports ;
- violations exactes.

H6 passe seulement si :

- niveau A et C : oubli exactement nul ;
- modèles appris : oubli au plus 0,01 ;
- zéro violation structurelle ;
- persistance vérifiée sur plusieurs transitions et horizons.

## 16. Audit des flux d’information

Fichier : audit_information_flow_v23.py.

### 16.1 Audit statique

Construire la liste des arguments, attributs et tenseurs accessibles à chaque
module. Refuser toute route :

~~~text
world -> détecteur
target -> détecteur
world -> tête
future response -> tête amont
correct patch -> modèle
private family -> modèle
OOD key -> entraînement
logits amont -> tête aval
context -> repair sans chaîne causale
context -> next
~~~

### 16.2 Audit dynamique

Utiliser des marqueurs de provenance et hooks pour vérifier :

- tensors effectivement consommés ;
- gradients ;
- masques ;
- branches exécutées ;
- variables fixes sous intervention ;
- absence de mémoire cachée hors AgentClosureState ;
- absence d’accès fichier ou variable d’environnement privée.

### 16.3 Budgets

Recalculer :

- paramètres actifs ;
- FLOPs exécutés ;
- mémoire sérialisée ;
- octets de réponse ;
- nombre de requêtes ;
- nombre de patches ;
- nombre de pas ;
- capacité totale du transcript.

Produire une table d’équité par baseline avant l’évaluation finale.

## 17. Métriques et statistiques

### 17.1 Score principal

Un épisode vaut 1 si et seulement si :

- closed dans le budget ;
- KnownClosedOn certifié ;
- ClosedOn vrai dans le monde réel ;
- persistance de toutes les réparations ;
- aucune violation de type ;
- aucune violation de provenance ;
- aucune violation de causalité.

Le score multi-domaine est le minimum des scores perceptuel et symbolique.

### 17.2 Mesures secondaires

Calculer et publier :

- gap correct par genre ;
- calibration ;
- réduction de fibre ;
- requêtes par fermeture ;
- bits par fermeture ;
- patches effectifs ;
- préfixe fermé ;
- oubli ;
- violations ;
- FLOPs ;
- latence ;
- mémoire ;
- marges ;
- succès par horizon et profondeur.

### 17.3 Analyse confirmatoire

Pour H3, H4 et H7 :

1. unité indépendante : seed ;
2. épisodes emboîtés ;
3. bootstrap hiérarchique apparié ;
4. 10000 réplications ;
5. intervalle percentile 95 % ;
6. test exact des 1024 inversions de signe ;
7. test unilatéral préenregistré ;
8. Holm sur six tests domaine × hypothèse ;
9. seuils pratiques obligatoires même si p significative.

### 17.4 Seuils

| Hypothèse | Seuil |
|---|---|
| H3 | borne inférieure de Delta_task strictement supérieure à 0,05 |
| H4 | borne inférieure de C_gap strictement supérieure à 0,20 |
| H5 | chaque contraste causal supérieur à 0,20 et bon signe |
| H6 | oubli au plus 0,01 appris, zéro A/C |
| H7 | score OOD au moins 0,80, avantage OOD inférieur borné au-dessus de 0,05, oubli au plus 0,01 |
| obligations exactes | zéro violation |

Le script statistique doit être testé sur :

- cas synthétique nul ;
- effet positif connu ;
- effet négatif ;
- seeds identiques ;
- épisodes déséquilibrés ;
- correction Holm ;
- énumération exacte des signes.

## 18. Certification Lean

### 18.1 Sorties

Produire :

~~~text
RawTrace
ValidTrace
ValidInterventionTrace
runModel weights inputs = rawTrace
ValidCertifiedRun
~~~

Les JSON ne sont jamais admis comme axiomes. Les données sont réifiées et les
preuves calculées.

### 18.2 Découpage

- blocs de 256 transitions ;
- module Lean par bloc ;
- composition ordonnée ;
- manifeste des modules ;
- hash de chaque source générée ;
- point d’entrée de campagne ;
- build Lake complet.

### 18.3 Contraintes constructives

Chaque nouveau fichier Lean :

- aucun axiom ;
- aucun sorry ;
- aucun admit ;
- aucun Classical ;
- aucun propext ;
- aucun Quot.sound ;
- aucun pont terminal externe ;
- exactement un bloc AXIOM_AUDIT ;
- bloc placé à la toute fin ;
- noms concrets ;
- sortie sans axiome.

### 18.4 Concordance

Pour les données certifiables, Lean et Python doivent concorder sur :

~~~text
observe
detectGap
authorize
executeTransport
selectQuery
respond
buildRepair
executeRepair
CompatibleWorlds
GapClosedBy
KnownCorrectAt
KnownClosedOn
ClosedOn
inférence entière
argmax
trace finale
~~~

## 19. Falsification

Fichier : falsify_verifiers_v23.py.

### 19.1 Mutations obligatoires

Au moins une mutation invalide par champ :

~~~text
gap index
gap genre
gap évidence
usage
transport focus
transport index
requête
réponse
patch
état suivant
historique
fibre
fermeture
poids
logit
départage
hash de provenance
~~~

### 19.2 Attendus

- 100 % des mutations invalides rejetées ;
- code d’erreur stable ;
- chemin précis du champ ;
- aucune exception non classée ;
- une mutation valide différente produit une nouvelle trace ;
- aucune normalisation silencieuse ;
- aucune confiance dans validity_flags.

### 19.3 Falsification croisée

Chaque vérificateur reçoit :

- certificats d’un autre domaine ;
- mauvaise version de protocole ;
- mauvais checkpoint ;
- mauvais bundle ;
- ordre de lignes modifié ;
- ligne dupliquée ;
- ligne retirée ;
- fermeture anticipée ;
- réponse croisée de mauvais type ;
- clé OOD incorrecte ;
- manifeste privé incompatible.

## 20. Audit scientifique global

Fichier : audit_scientific_contract_v23.py.

L’auditeur ne lance pas d’entraînement. Il lit les manifestes achevés, recalcule
leurs hashes et produit un verdict par porte.

### 20.1 G0 — Provenance

Exiger :

- protocole exact ;
- protocol.lock ;
- source bundle ;
- environnement ;
- image OCI ;
- commandes ;
- seeds ;
- partitions ;
- snapshots ;
- absence d’écrasement.

### 20.2 G1 — Formalisation

Exiger :

- builds Lean ;
- audits constructifs ;
- non-trivialité ;
- agrégat final.

### 20.3 G2 — Concordance

Exiger :

- niveau A complet ;
- interventions exhaustives ;
- zéro divergence Lean/Python.

### 20.4 G3 — Agent certifiable

Exiger :

- zéro erreur exhaustive ;
- poids Int8 ;
- accumulateurs Int32 ;
- recalcul Lean ;
- trace sémantiquement fermée.

### 20.5 G4 — Information

Exiger :

- no-go passif ;
- no-go visible factorisé ;
- meilleur contrôleur fini ;
- capacité du transcript ;
- politique active suffisante.

### 20.6 G5 — Causalité

Exiger :

- H4 ;
- H5 ;
- refus des bypass ;
- audit des flux ;
- zéro violation structurelle.

### 20.7 G6 — Dynamique

Exiger :

- H6 ;
- persistance ;
- cohérence compositionnelle ;
- fermeture multi-étapes.

### 20.8 G7 — Généralisation

Exiger :

- H3 et H7 ;
- deux domaines ;
- dix seeds ;
- OOD ouvert seulement après gel ;
- comparaisons appariées.

### 20.9 G8 — Certification et réplication

Exiger :

- certificats ;
- falsifications ;
- réplication d’évaluation ;
- réplication des entraînements ;
- rapports complets.

Le mode --require-all-gates retourne un code non nul dès qu’une porte manque ou
échoue. Il ne transforme jamais missing en passed.

## 21. Réplication indépendante

### 21.1 Réplication d’évaluation

- machine ou image fraîche ;
- seed racine 236000 ;
- checkpoints finaux gelés ;
- évaluateur reconstruit depuis source ;
- aucun cache original ;
- recalcul des traces, métriques et certificats ;
- comparaison hash par hash lorsque déterministe ;
- explication de toute différence tolérée.

### 21.2 Réplication d’entraînement

- seeds 10 à 19 ;
- nouvel entraînement depuis zéro ;
- mêmes hyperparamètres gelés ;
- mêmes budgets ;
- même procédure de sélection ;
- nouvelle série de checkpoints ;
- analyse distincte des seeds primaires ;
- aucune fusion opportuniste.

### 21.3 Indépendance

Idéalement, la réplication est opérée par une autre personne. À défaut :

- environnement isolé ;
- compte système distinct ;
- absence d’accès aux sorties attendues pendant le run ;
- journal complet ;
- procédure signée et horodatée ;
- mention explicite que la réplication n’est pas humaine indépendante.

## 22. Rapports et artefacts

### 22.1 Arborescence

~~~text
protocol.lock.json

manifests/
  source_bundle.json
  environment.json
  parameter_budgets.json
  flops_budgets.json
  split_fingerprints.json
  ood_public_manifest.json
  run_matrix.json

snapshots/
  scripts figés
  lockfiles
  définition OCI

runs/
  smoke/
  finite_conformance/
  certifiable_agent/
  tune/
  final_train/
  interventions/
  sealed_ood/
  certification/
  falsification/
  replicate_eval/
  replicate_train/

reports/
  gate_report.json
  gate_report.md
  model_comparison.csv
  resource_comparison.csv
  causal_effects.csv
  dynamics.csv
  ood.csv
  statistical_report.json
  failures.md
  final_scientific_report.md
  claim_evidence_matrix.md
~~~

### 22.2 Rapport final

Ordre obligatoire :

1. identité du protocole ;
2. provenance ;
3. état G0–G8 ;
4. théorèmes exacts ;
5. calculs exhaustifs ;
6. agent certifiable ;
7. campagne IID ;
8. baselines ;
9. interventions ;
10. dynamique ;
11. OOD ;
12. scaling ;
13. réplications ;
14. falsifications ;
15. incidents ;
16. résultats négatifs ;
17. limites ;
18. claims autorisés.

Chaque tableau contient :

- nombre de seeds ;
- nombre d’épisodes ;
- moyenne ;
- médiane ;
- écart-type ;
- intervalle ;
- meilleur seed ;
- pire seed ;
- hashes des sources.

## 23. protocol.lock.json

Le lock ne redéfinit aucune règle. Il identifie :

~~~text
schema
protocol_version
protocol_sha256
source_bundle_sha256
python_lock_sha256
oci_digest
lean_toolchain
lean_toolchain_sha256
script_hashes
domain_schema_hashes
trace_schema_sha256
seed_roots
created_at_utc
created_by
~~~

Le fichier est généré une fois G0 préparé. Toute divergence ultérieure :

- bloque un run primaire ;
- peut lancer une réplication explicitement nommée ;
- ne met jamais à jour le lock en place.

## 24. Ordre de réalisation en lots

### Lot 0 — Préservation et préflight

Livrables :

- copie externe du checkpoint de développement ;
- inventaire des scripts historiques ;
- hashes ;
- README ;
- lock Python ;
- définition OCI ;
- estimation CPU/GPU, stockage et durée ;
- plan de secrets OOD.

Acceptation :

- aucune modification historique ;
- smoke tests uniquement dans /tmp ou sous _smoke_ ;
- environnement déterministe disponible.

### Lot 1 — Intégration A/C

Livrables :

- profils finite-conformance et certifiable-agent ;
- intégration de tous les tests actuels ;
- rapports G1–G4 préliminaires ;
- concordance exhaustive.

Acceptation :

- zéro divergence ;
- checkpoint rejoué ;
- Lean sans axiome ;
- no-go recalculés.

### Lot 2 — API et familles fermées

Livrables :

- interface commune ;
- EpisodeBundle ;
- familles exactes de 32 mondes ;
- sérialisation public/privé ;
- tests anti-fuite.

Acceptation :

- obligations de génération vérifiées exhaustivement ;
- monde privé inaccessible au modèle.

### Lot 3 — Domaine perceptuel

Livrables :

- langage ;
- renderer ;
- candidate ;
- requêtes ;
- réparations ;
- générateur ;
- vérificateur indépendant ;
- tests.

Acceptation :

- collisions pixel exactes ;
- fibres exactes ;
- trois réparations ;
- fingerprints.

### Lot 4 — Domaine symbolique

Livrables analogues au lot 3.

Acceptation :

- typage SSA ;
- ambiguïté des observations ;
- probes séparatrices ;
- fermeture exacte.

### Lot 5 — Agent complet

Livrables :

- encodeurs ;
- Transformer ;
- cinq têtes ;
- masques ;
- exécuteur ;
- tailles ;
- ONNX ;
- tests anti-bypass.

Acceptation :

- chaîne causale unique ;
- sorties typées ;
- parité ONNX.

### Lot 6 — Baselines et équité

Livrables :

- B1 à B13 ;
- registre ;
- paramètres ;
- FLOPs ;
- mémoire ;
- audit d’entrées.

Acceptation :

- budgets conformes ;
- exclusions documentées avant scores.

### Lot 7 — Orchestration et scellement

Livrables :

- train_v23 ;
- campaign_v23 ;
- freeze_and_run_v23 ;
- protocol.lock ;
- manifests ;
- AES-GCM ;
- Merkle ;
- journal append-only.

Acceptation :

- aucune sortie écrasable ;
- OOD inaccessible au train ;
- matrice exhaustive.

### Lot 8 — Smoke tests

Exécuter des runs très courts uniquement pour :

- erreurs de type ;
- mémoire ;
- débit ;
- déterminisme ;
- intégrité des traces ;
- estimation des ressources.

Les résultats portent _smoke_ et ne sont jamais cités.

### Lot 9 — Réglage

Exécuter les 12 configurations et seeds 100–102 selon la matrice gelée.

Acceptation :

- toutes les cellules terminées ou incidentées ;
- configuration choisie par règle préenregistrée ;
- aucun OOD ouvert.

### Lot 10 — Entraînement final

Exécuter seeds 0–9, 120000 updates.

Acceptation :

- aucune seed remplacée ;
- checkpoints gelés ;
- code d’évaluation gelé ;
- rapports de ressources.

### Lot 11 — Interventions et dynamique

Exécuter 4096 épisodes appariés par type, domaine et seed.

Acceptation :

- H4/H5 calculés ;
- H6 calculé ;
- refus exacts ;
- aucune fuite.

### Lot 12 — Ouverture OOD

Seulement après gel des checkpoints et évaluateurs.

Acceptation :

- journal d’ouverture ;
- authentification des blobs ;
- H7 calculé sans nouvelle sélection.

### Lot 13 — Certification et falsification

Livrables :

- modules Lean ;
- certificats ;
- mutations ;
- audit de build ;
- rapport G0–G7.

Acceptation :

- zéro axiome ;
- 100 % mutations invalides rejetées ;
- aucune violation exacte.

### Lot 14 — Réplication

Exécuter replicate-eval puis replicate-train.

Acceptation :

- seeds 10–19 distinctes ;
- environnement indépendant ;
- résultats publiés séparément.

### Lot 15 — Publication

Livrables :

- rapport complet ;
- matrices claim–evidence ;
- données et modèles ;
- échecs ;
- limites ;
- archive immuable ;
- DOI lorsque approprié.

## 25. Définition de terminé

La campagne est terminée seulement si toutes les cases suivantes sont
objectivement décidées :

### Infrastructure

- [ ] Tous les fichiers obligatoires existent.
- [ ] Les scripts historiques sont inchangés.
- [ ] Les scripts scientifiques sont snapshotés.
- [ ] Le protocole et le bundle sont hashés.
- [ ] L’environnement OCI est figé.
- [ ] Aucune sortie n’a été écrasée.

### Niveau A

- [ ] Concordance Lean/Python complète.
- [ ] Interventions finies complètes.
- [ ] No-go exacts complets.
- [ ] Capacité du transcript calculée.

### Niveau C

- [ ] Checkpoint admissible.
- [ ] Zéro erreur.
- [ ] Recalcul Lean exact.
- [ ] Fermeture sémantique des 697 obligations.

### Niveau B

- [ ] Deux domaines implémentés.
- [ ] Familles exactes de 32 mondes.
- [ ] Agent complet sans bypass.
- [ ] B1–B13 implémentées.
- [ ] Budgets appariés.
- [ ] Réglage complet.
- [ ] Dix seeds finales.
- [ ] Interventions complètes.
- [ ] Persistance complète.
- [ ] OOD scellé puis ouvert correctement.
- [ ] Parité ONNX.

### Statistiques

- [ ] Bootstrap hiérarchique.
- [ ] Tests de permutation exacts.
- [ ] Correction Holm.
- [ ] H3 décidé.
- [ ] H4 décidé.
- [ ] H5 décidé.
- [ ] H6 décidé.
- [ ] H7 décidé.

### Certification

- [ ] Certificats générés.
- [ ] Vérificateurs indépendants.
- [ ] Falsification à 100 %.
- [ ] Modules Lean constructifs.
- [ ] Audit sans axiome.

### Réplication

- [ ] Évaluation répliquée.
- [ ] Entraînements seeds 10–19 répliqués.
- [ ] Différences documentées.

### Publication

- [ ] Tous les runs publiés.
- [ ] Tous les incidents publiés.
- [ ] Résultats négatifs publiés.
- [ ] Claims limités aux portes franchies.
- [ ] G0–G8 décidées.
- [ ] Archive immuable.

## 26. Règle de décision finale

Le rapport final utilise exactement l’un des verdicts :

### Validation complète

Toutes les portes G0–G8 passent. Les formulations complètes bornées par le
protocole sont autorisées.

### Validation partielle

Certaines portes passent et d’autres échouent. Seules les formulations
dépendant exclusivement des portes passées sont autorisées.

### Campagne invalide

Une violation de provenance, une ouverture OOD prématurée, une fuite
d’information, une sortie écrasée ou une falsification non détectée invalide
les claims correspondants, même avec de bons scores.

### Résultat négatif valide

La provenance est correcte, mais une hypothèse scientifique échoue. L’échec est
un résultat et doit être publié sans ajuster rétroactivement le protocole.

## 27. Première séquence d’implémentation

Le travail commence dans cet ordre précis :

1. créer README.md ;
2. créer les répertoires vides via fichiers manifestes, sans résultats fictifs ;
3. écrire le générateur de protocol.lock sans geler prématurément le lock ;
4. intégrer les profils A/C existants au lanceur ;
5. obtenir G1–G4 depuis une exécution figée ;
6. définir l’interface LevelBDomain et EpisodeBundle ;
7. implémenter le domaine symbolique, plus rapide à auditer ;
8. implémenter le domaine perceptuel et son renderer indépendant ;
9. implémenter le modèle complet ;
10. implémenter les treize systèmes ;
11. implémenter l’audit des flux et des ressources ;
12. implémenter l’orchestrateur et le scellement ;
13. exécuter uniquement les smoke tests ;
14. auditer tout le code avant le premier run scientifique ;
15. geler G0 ;
16. lancer les profils normatifs dans l’ordre.

La priorité n’est pas la vitesse d’obtention d’un score. La priorité est
l’impossibilité de produire un score scientifiquement ambigu.

## 28. Non-trivialité et non-raccourcis

### 28.1 Critères normatifs de non-trivialité

L’auditeur invalide la campagne si :

- le visible est constant sur tout un domaine ;
- Agrees est constant ;
- Gap, Use, Transport, Repair ou Witness est Unit ;
- CandidatePatch remplace intégralement Candidate ;
- le gap contient la requête correcte ou le patch correct ;
- Use est seulement Query renommé ;
- Transport est seulement Use renommé ;
- OutRel est universel, vide ou identique à Use sur tous les états atteignables ;
- QueryAdmissible accepte tout ou rien ;
- le détecteur reçoit world ou target ;
- la réponse contient le monde ou la candidate finale ;
- le repair est produit par un oracle extérieur ;
- next existe indépendamment de executeRepair ;
- une réparation antérieure disparaît sans échec ;
- le modèle complet contourne une tête causale ;
- une baseline reçoit moins d’information ou de ressources sans rapport ;
- l’OOD influence l’entraînement ou la sélection ;
- un certificat fait confiance à un booléen du modèle ;
- une seed est présentée comme résultat général ;
- le niveau A est présenté comme campagne complète.

Chaque propriété possède :

1. un test positif montrant que l’instance correcte passe ;
2. un mutant minimal qui doit échouer ;
3. un code d’erreur stable ;
4. une entrée dans le rapport de falsification.

### 28.2 Raccourcis de livraison

La livraison n’est pas complète si l’un des raccourcis suivants est utilisé :

- seulement le checkpoint v23 existant ;
- seulement un domaine ;
- seulement une seed ;
- seulement B13 ;
- absence de B6 ou des baselines actives ;
- OOD non scellé ;
- OOD utilisé pour sélectionner ;
- réparation calculée depuis le monde ;
- patch oracle non signalé ;
- next prédit directement ;
- statistiques par épisode comme unités indépendantes ;
- comparaison à budgets inégaux ;
- certificat fondé sur un booléen déclaré ;
- vérificateur partageant le calcul du producteur ;
- modification du protocole après résultat ;
- suppression d’un run échoué ;
- remplacement silencieux d’une seed ;
- conclusion générale depuis le domaine fini ;
- présentation du niveau C comme niveau B.

Le meilleur travail possible est précisément celui qui rend chacun de ces
raccourcis détectable, impossible ou explicitement disqualifiant.

## 29. Matrice de couverture du protocole

Cette table est la checklist de maintenance du présent document. Une évolution
du plan n’est acceptable que si les 36 sections normatives restent couvertes.

| Section normative | Sujet | Section d’implémentation |
|---:|---|---|
| 0 | statut normatif | 0, 3.1, 23 |
| 1 | cible scientifique | 0, 1 |
| 2 | limites | 26, 28 |
| 3 | H1–H8 | 1.1, 14–17, 20 |
| 4 | niveaux A/B/C | 1, 2 |
| 5 | référence finie | 2.3 |
| 6 | no-go et budgets formels | 2.3, 20.5 |
| 7 | API des domaines | 5 |
| 8 | domaine perceptuel | 6 |
| 9 | domaine symbolique | 7 |
| 10 | réalisation fondationnelle | 5.6 |
| 11 | schéma causal | 5.4, 5.5 |
| 12 | interventions | 14 |
| 13 | agent certifiable | 8.1 |
| 14 | agent appris | 8.2–8.7 |
| 15 | régimes | 10.2, 10.3 |
| 16 | réglage | 10.4 |
| 17 | baselines | 9.1–9.3 |
| 18 | budgets empiriques | 9.4 |
| 19 | épisodes et splits | 11.1, 11.2 |
| 20 | seeds | 11.3 |
| 21 | scellement OOD | 12 |
| 22 | métriques | 17.1, 17.2 |
| 23 | statistiques | 17.3, 17.4 |
| 24 | sélection et incidents | 10.5, 13.3 |
| 25 | certification Lean | 18 |
| 26 | falsification | 19 |
| 27 | traçabilité | 3.1, 3.2, 13 |
| 28 | environnement | 3.4.1, lot 0 |
| 29 | arborescence | 2.1, 2.2, 22.1 |
| 30 | commandes | 13.4 |
| 31 | G0–G8 | 20 |
| 32 | non-trivialité | 28.1 |
| 33 | publication | 22, 26 |
| 34 | ordre bloquant | 24, 27 |
| 35 | verdict | 1, 25, 26 |

Pour chaque ligne, l’implémentation finale doit pouvoir pointer vers :

~~~text
au moins un module producteur
au moins un test
au moins un artefact immuable
au moins un contrôle indépendant
une porte G0–G8 ou une justification de portée
~~~

L’audit_scientific_contract_v23 doit matérialiser cette correspondance dans un
fichier machine-readable. Une section normative sans preuve d’implémentation
reçoit missing.

## 30. Spécification algorithmique à geler avant G0

Cette section ferme les choix d’ingénierie nécessaires pour qu’une équipe
puisse coder sans inventer silencieusement une seconde campagne. Ces choix ne
modifient ni hypothèse ni seuil. Ils font partie du bundle source hashé à G0.

Avant le premier run scientifique, leur implémentation, leurs vecteurs de test
et le présent document sont inclus dans protocol.lock.json. Après ce gel, une
modification crée une nouvelle tentative ou une nouvelle version selon son
impact ; elle ne remplace jamais le primaire.

### 30.1 Primitives déterministes

#### Dérivation des seeds

Entrée :

~~~text
label UTF-8 NFC
root uint64
ordinal uint64
~~~

Message :

~~~text
uint32_be(len(label)) || label || uint64_be(root) || uint64_be(ordinal)
~~~

Sortie :

~~~text
uint64_be(SHA256(message)[0:8])
~~~

Chaque appel aléatoire reçoit une sous-seed dédiée à son rôle. Réutiliser une
sous-seed entre génération, modèle, dropout ou intervention est interdit.

#### Ordres canoniques

- enums : ordre de déclaration gelé ;
- chemins AST : parcours préordre, enfant gauche avant droit ;
- programmes : longueur, opcodes, opérandes, constantes ;
- mondes : hash canonique puis payload canonique pour départager ;
- indices : constructeur, stage, coordonnées, slot, field ;
- requêtes, patches et réponses : constructeur puis paramètres ;
- égalité d’argmax : plus petit index ;
- ensembles sérialisés : listes triées sans doublon.

Chaque ordre possède un golden file de dix exemples et un test de stabilité.

#### Arithmétique

- géométrie et rendu : entiers seulement ;
- Z8 : réduction modulo 8 après chaque opération ;
- coûts et statistiques enregistrés en entiers ou rationnels lorsque possible ;
- modèles de niveau B : FP32 ;
- modèle C : Int8/Int32 selon 8.1 ;
- aucun comportement ne dépend de l’ordre d’un dictionnaire non canonisé.

### 30.2 Rasterisation perceptuelle exacte

#### Grille

- scène logique : 8 × 8 cellules ;
- image : 64 × 64 pixels ;
- une cellule logique correspond à un bloc de 8 × 8 pixels ;
- coordonnées logiques x vers la droite, y vers le bas ;
- coordonnées locales u,v dans 0 à 7 ;
- arrière-plan RGB = 0,0,0 ;
- rouge = 255,0,0 ;
- vert = 0,255,0 ;
- bleu = 0,0,255.

#### Masques de forme

Un pixel local est opaque si :

~~~text
square:
  1 <= u <= 6 et 1 <= v <= 6

circle:
  (2*u - 7)^2 + (2*v - 7)^2 <= 36

triangle:
  1 <= v <= 6 et abs(2*u - 7) <= v

cross:
  ((u = 3 ou u = 4) et 1 <= v <= 6)
  ou
  ((v = 3 ou v = 4) et 1 <= u <= 6)
~~~

Les pixels hors masque sont transparents.

#### Occlusion

Chaque objet possède un slot stable et une position dans l’ordre latent
d’occlusion. Les objets sont peints du fond vers l’avant ; le dernier objet
opaque écrit le pixel. L’ordre est total, sans doublon. Un objet absent ne
peint rien.

#### Transformations

Les transformations agissent sur les positions des objets sélectionnés :

~~~text
move(dx,dy): ((x + dx) mod 8, (y + dy) mod 8)

rotateQuarter(1): (7 - y, x)
rotateQuarter(2): (7 - x, 7 - y)
rotateQuarter(3): (y, 7 - x)

reflect(horizontal): (x, 7 - y)
reflect(vertical): (7 - x, y)
~~~

recolor modifie uniquement Color. Les formes n’ont pas d’orientation cachée ;
rotation et réflexion déplacent donc les objets sans changer Shape.

La sélection est un ensemble de slots :

- selectShape remplace la sélection ;
- selectColor remplace la sélection ;
- selectAll sélectionne tous les présents ;
- release sélectionne tous les présents ;
- une commande géométrique ou recolor conserve la sélection.

#### Vecteurs de test

Le renderer fournit au minimum :

- image vide ;
- une instance de chaque forme et couleur ;
- chaque coin de grille ;
- wrap-around des huit mouvements ;
- trois rotations ;
- deux réflexions ;
- collision de deux puis trois objets ;
- transparence partielle de chaque masque ;
- invariance square/circle sous mouvement inverse ;
- non-commutation move/recolor avec sélection ;
- hashes d’images attendus.

### 30.3 Construction des familles perceptuelles

Pour chaque ordinal d’épisode :

1. dériver episode_seed ;
2. construire un pool de mondes comprenant plusieurs scènes, programmes et
   ordres d’occlusion ;
3. exécuter chaque monde et calculer sa clé d’observation publique initiale,
   formée des hashes image d’entrée et image finale ;
4. grouper les mondes par cette clé ;
5. identifier les groupes admissibles de taille au moins quatre qui possèdent
   un conflit de cible et une requête discriminante ;
6. choisir un groupe ancre avec une sous-seed dédiée ;
7. prendre canoniquement entre 4 et 16 mondes du groupe ancre ;
8. compléter jusqu’à 32 par round-robin canonique sur au moins un autre
   groupe d’observation ;
9. dédupliquer et trier la famille finale ;
10. construire une candidate commune depuis le premier monde canonique du
    groupe ancre, avant choix du monde réel ;
11. générer h corruptions sur cette candidate ;
12. choisir le monde réel dans le groupe ancre par une sous-seed distincte,
    après fixation de la famille et de la candidate ;
13. recalculer CompatibleWorlds depuis observation, candidate et historique ;
14. exiger que la fibre réelle contienne au moins quatre mondes, deux cibles au
    premier gap, une requête discriminante et toutes les réparations ;
15. vérifier que la famille complète contient au moins deux observations ;
16. vérifier les trois gaps et la fermeture ;
17. rejeter l’épisode sinon et passer à attempt + 1.

Pool déterministe :

- au plus 65536 mondes candidats par attempt ;
- variations de chaque opcode et argument dans l’ordre canonique ;
- permutations d’ordre d’occlusion en ordre lexicographique ;
- programmes de la longueur imposée seulement ;
- aucune utilisation du monde choisi comme signal de construction de famille
  ou de candidate.

Un attempt épuisé ne produit aucune sortie partielle. Après 1024 attempts pour
un ordinal, le générateur échoue avec un incident de génération ; il ne réduit
ni la taille 32 ni les contraintes.

### 30.4 Construction des familles symboliques

#### Encodage SSA exact

~~~text
Source =
  input0
  | input1
  | register(j), avec j strictement inférieur à l’instruction courante

Instruction =
  readInput0
  | readInput1
  | const(c), c dans Z8
  | add(left: Source, right: Source)
  | xor(left: Source, right: Source)
  | ifZero(test: Source, yes: Source, no: Source)
~~~

Chaque instruction produit un registre Z8. La sortie du programme est le
dernier registre. add réduit modulo 8 ; xor applique le XOR bit à bit sur les
représentants 0 à 7 ; ifZero choisit yes si test vaut 0, no sinon.

OperandSlot appartient à left/right pour add et xor, et test/yes/no pour
ifZero. replaceOperand doit respecter l’arité de l’opcode courant. Un changement
d’opcode qui change l’arité doit fournir, dans le même token de remplacement,
les opérandes canoniques bien typés définis par le catalogue ; il reste une
modification d’un unique nœud AST.

La normalisation renomme les registres par ordre de définition et sérialise les
opérandes dans l’ordre de l’opcode. Elle n’effectue aucune simplification
algébrique qui pourrait fusionner deux programmes syntaxiquement distincts.

Pour chaque ordinal :

1. générer un pool canonique de programmes SSA selon le split ;
2. choisir une liste publique de huit entrées distinctes par sous-seed ;
3. calculer pour chaque programme sa table de huit sorties ;
4. grouper les programmes par table d’observation ;
5. identifier les groupes de taille au moins quatre ayant deux cibles sur un
   gap et une probe admissible qui sépare une paire ;
6. choisir un groupe ancre avec une sous-seed dédiée ;
7. prendre canoniquement entre 4 et 16 programmes du groupe ancre ;
8. compléter la famille à 32 par round-robin sur au moins un autre groupe ;
9. normaliser SSA, dédupliquer et trier ;
10. construire une candidate commune depuis le premier programme canonique du
    groupe ancre, avant choix du réel ;
11. générer h corruptions réparables ;
12. choisir le monde réel dans le groupe ancre après fixation de la famille et
    de la candidate ;
13. recalculer la fibre compatible et exiger au moins quatre mondes, deux
    cibles et une probe séparatrice ;
14. vérifier au moins deux observations initiales dans la famille ;
15. vérifier toutes les fibres et réparations ;
16. rejeter sinon.

L’énumération est bornée à 65536 programmes candidats par attempt et 1024
attempts par ordinal. Une borne atteinte est un échec explicite, jamais un
échantillonnage silencieusement plus petit.

Dans les deux domaines, le générateur de partition vérifie aussi que chaque
bloc canonique de 32 épisodes contient au moins deux observations publiques
distinctes.

### 30.5 Génération des corruptions

Les chemins éligibles sont calculés avant choix des corruptions et triés
canoniquement. Tirer sans remise exactement h chemins.

Pour chaque chemin, dériver corruption_seed et choisir parmi les mutations
bien typées autres que l’original :

~~~text
opcode différent
argument différent
constante différente
remplacement par trou typé
~~~

La classe est choisie uniformément parmi celles disponibles, puis la valeur
uniformément parmi les alternatives canoniques. Le générateur vérifie :

- h chemins distincts ;
- h corruptions effectives ;
- chaque corruption possède une réparation mono-emplacement ;
- l’ordre de détection produit au moins trois gaps distincts ;
- chaque étape change Candidate ;
- quatre candidats distincts au minimum ;
- fermeture dans h transitions au plus.

Le manifeste privé enregistre originaux et corruptions. Le manifeste public
n’enregistre que candidate, trous et observation autorisée.

### 30.6 Catalogues appris finis

Chaque domaine construit avant entraînement des catalogues globaux finis depuis
sa grammaire, ses bornes de longueur et ses indices publics :

~~~text
GapCatalog
UseCatalog
TransportCatalog
QueryCatalog
RepairCatalog
~~~

Les catalogues sont triés, sérialisés, hashés et inscrits au manifeste. Chaque
tête est exactement un MLP d_model vers d_model vers la taille de son catalogue.
Un masque calculé depuis la vue publique rend inaccessibles les entrées
mal typées ou non disponibles à l’état courant.

Pour GapCatalog, l’entrée apprise est GapKey(index, kind). Après sélection, le
payload d’évidence et sa provenance sont construits déterministement depuis la
vue publique au même index. Cette construction ne lit ni monde, ni target, ni
réponse future.

Bornes minimales vérifiées :

~~~text
perceptuel:
  crop indices = 9 stages * 4 * 4 = 144
  object indices = 9 stages * 6 * 5 = 270
  visible indices = 414
  gap keys = 2 * 414 + closed = 829

symbolique:
  probe pairs = 8 * 8 = 64
  register indices maximaux = 8 instructions + output = 9
  visible indices = 576
  gap keys = 2 * 576 + closed = 1153
~~~

Les catalogues d’usage, transport, requête et réparation sont générés
exhaustivement depuis ces indices et les AST maximaux. Leur compte exact est
publié avant G0 et comparé à une seconde énumération indépendante.

Cette réalisation :

- ne dépend pas de SemanticWorld ;
- utilise des dimensions de sortie fixes et auditables ;
- conserve un ordre d’argmax canonique ;
- refuse un masque vide lorsque la doctrine exige une action ;
- ne crée aucune valeur hors catalogue ;
- encode noInformation et keep mais les masque dans les traces naturelles.

Closed est démasqué seulement lorsque la vue publique satisfait le prédicat
fermé. Les classes réservées ou impossibles restent masquées et leur sélection
forcée dans une intervention produit typed_refusal.

### 30.7 Tokenisation

#### Tokens communs

Chaque token possède :

~~~text
type_id
constructor_id
position_id
value_id
provenance_id
segment_id
~~~

Les vocabulaires sont construits depuis les enums et grammaires, triés
canoniquement, puis hashés. Aucun token inconnu n’est projeté vers un token
valide ; il est refusé.

#### Perceptuel

Ordre :

1. tokens image d’entrée en ordre raster ;
2. tokens image finale ;
3. tokens candidate en préordre ;
4. masque des trous ;
5. historique chronologique ;
6. token de décision courant.

Les images entrent aussi dans le stem convolutionnel. Les tokens image
symboliques ne contiennent que position, segment et lien vers le token spatial,
pas une seconde copie privée.

#### Symbolique

Ordre :

1. huit exemples triés par ordre de génération conservé ;
2. candidate SSA ;
3. trous ;
4. historique ;
5. token de décision.

Tout épisode au-delà de 512 tokens est rejeté avant partition.

### 30.8 Estimateur d’apprentissage discret

L’évaluation est toujours argmax. Pendant l’entraînement :

- R_supervised utilise teacher forcing et entropie croisée pour les cinq
  têtes ;
- R_intermediate utilise entropie croisée pour gap/use/transport et politique
  stochastique pour query/repair ;
- R_causal utilise une politique stochastique pour les cinq têtes ;
- le tirage est catégoriel sur le catalogue typé masqué ;
- chaque tirage utilise une sous-seed issue de run, update, épisode, step et
  tête ;
- aucun échantillonnage n’a lieu durant validation ou test.

Pour les décisions sans label, utiliser REINFORCE avec baseline leave-one-out
non apprise dans chaque batch de 64 épisodes :

~~~text
episode_cost =
  1.0 * (1 - terminal_closure)
  + 0.5 * (queries_used / max(1,h))
  + 1.0 * typed_violation
  + 1.0 * forgetting_fraction
  + 0.5 * composition_violation_fraction

advantage_i =
  episode_cost_i
  - mean(episode_cost_j pour j != i)

policy_loss =
  mean(stop_gradient(advantage_i) * sum(log_probability_i))
~~~

Minimiser policy_loss diminue le coût attendu. Aucun critic appris, aucune
valeur privée et aucun entropy bonus supplémentaire.

R_intermediate additionne les entropies croisées supervisées avec coefficient
1 aux termes policy query/repair. R_supervised optimise la somme moyenne des
cinq entropies croisées et rapporte séparément l’objectif causal, sans
gradient.

Les pertes sont moyennées par décision valide, puis par épisode, puis par
batch. Un épisode sans décision pour une tête contribue zéro à cette tête.

### 30.9 Fermeture, oubli et composition dans la loss

- terminal_closure vaut 1 uniquement selon le score exact de 17.1 ;
- typed_violation vaut 1 dès le premier refus naturel ;
- forgetting_fraction est le nombre d’obligations antérieures perdues divisé
  par leur nombre, zéro si aucune ;
- composition_violation_fraction compare toutes les paires composables
  observées, zéro si aucune ;
- queries_used compte uniquement les requêtes réellement exécutées ;
- h est le nombre de corruptions de l’épisode.

Les calculs de loss utilisés par le trainer sont recalculés par un auditeur sur
un échantillon figé avant G0 et sur toutes les traces publiées après run.

### 30.10 Réalisation des baselines

Toutes partagent tokenisation, taille cible, entraînement, sélection et
exécuteur lorsque leur classe le permet.

| ID | Réalisation fermée |
|---|---|
| B1 | encodeur observation et historique ; candidate remplacée par un token absent |
| B2 | encodeur candidate et historique ; observation remplacée par un token absent |
| B3 | encode toute l’observation initiale et candidate, actionne un patch sans nouvelle réponse |
| B4 | Transformer causal récurrent, actions limitées aux patches publics sans query |
| B5 | même contexte, une tête Query directe puis une tête Repair directe, sans objets gap/use/transport |
| B6 | encodeur commun, transition latente apprise, modèle de réponse appris sur train, recherche beam déterministe de largeur 16 et horizon égal au budget |
| B7 | projection visible gelée, toutes les décisions fonctions de cette projection seulement |
| B8 | Query directe, réponse réelle, Repair monolithique |
| B9 | Query admissible puis oracle privé de patch ; étiqueté diagnostic |
| B10 | gap uniforme parmi GapCandidates via seed dédiée, chaîne aval identique à B13 |
| B11 | GapHead entraînée et évaluée, mais son résultat est remplacé par un token constant indépendant avant UseHead |
| B12 | tête directe prédisant state_after ; aucune revendication intrinsèque |
| B13 | chaîne causale complète |

B6 ne reçoit jamais le vrai monde. Son modèle de réponse est entraîné seulement
sur interactions train et sa planification compte dans les FLOPs.

#### Appariement des paramètres

Pour chaque baseline, domaine et taille :

1. calculer le nombre actif de B13 ;
2. choisir d_model baseline parmi les multiples de 8 ;
3. choisir le plus proche dans la bande de 5 % ;
4. interdire poids de padding, paramètres gelés inutiles et branches mortes ;
5. mesurer FLOPs sur épisodes de calibration publics ;
6. ajuster seulement largeur et profondeur autorisées avant entraînement ;
7. exclure du contraste principal si aucune réalisation de même classe ne
   respecte paramètres et FLOPs.

Les choix de largeur/profondeur sont inscrits dans parameter_budgets.json avant
le réglage et ne changent plus après scores.

### 30.11 Mesures secondaires fermées

La calibration du gap utilise :

- confiance = maximum softmax de GapHead ;
- exactitude = égalité au gap de référence lorsqu’un label existe ;
- ECE à 15 bins de largeur égale ;
- bins fermés à gauche, ouverts à droite, dernier fermé ;
- Brier multiclasses publié en complément.

La latence :

- batch 1 ;
- 100 warmups ;
- 1000 mesures ;
- médiane, p90 et p99 ;
- synchronisation GPU avant et après ;
- matériel du manifeste.

Les FLOPs :

- additions et multiplications comptées séparément dans le détail ;
- MAC rapporté aussi comme deux FLOPs ;
- branches réellement exécutées ;
- planification B6 incluse ;
- renderer et vérificateur exclus du coût agent mais rapportés séparément.

La mémoire est le maximum de mémoire agent sérialisée et le pic de tenseurs
mesuré séparément.

### 30.12 Statistiques reproductibles

Le bootstrap et les permutations utilisent des sous-seeds SHA-256 dérivées de
protocol hash, analysis id et replicate ordinal. Les indices rééchantillonnés
sont enregistrés dans un manifeste compressé ou reproductibles bit à bit
depuis ces entrées.

Les six p-values Holm sont triées par valeur puis par identifiant
domain/hypothesis pour départage. Les valeurs brutes et ajustées sont publiées.
Les intervalles utilisent les quantiles empiriques 0,025 et 0,975 avec la règle
d’index documentée dans le code et des golden tests.

### 30.13 Dépendances d’exécution

Le lock Python contient au minimum les distributions nécessaires à :

~~~text
PyTorch
NumPy
ONNX
ONNX Runtime CPU
AES-256-GCM
lecture et écriture JSON canonique
mesure de ressources
tests
~~~

Le renderer n’utilise pas une bibliothèque graphique externe. L’algorithme
rationnel du no-go n’utilise pas un solveur flottant pour conclure.

Les versions exactes, wheels, hashes et index de provenance sont résolus une
fois dans l’image OCI, testés, puis gelés avant G0. Aucune installation réseau
ne se produit pendant un run scientifique.

### 30.14 Préflight de calcul

Avant G0, campaign_v23.py produit sans entraîner :

~~~text
nombre exact de cellules de tuning
nombre exact de runs finaux
nombre exact d’évaluations
nombre attendu de transitions
paramètres et FLOPs par système
estimation de temps par smoke benchmark
stockage checkpoints
stockage traces publiques
stockage manifests privés
stockage OOD chiffré
GPU-hours et CPU-hours estimées
~~~

Le planificateur refuse de lancer une campagne dont l’espace disponible est
inférieur à 1,5 fois l’estimation ou dont la matrice contient une cellule sans
ressource assignée.

### 30.15 Critère de gel de cette spécification

Cette section est prête pour G0 lorsque :

- toutes les fonctions décrites ont un module propriétaire ;
- tous les ordres ont des golden tests ;
- les deux générateurs produisent 100 épisodes smoke valides ;
- les vérificateurs indépendants les acceptent ;
- les mutants anti-fuite échouent ;
- la matrice complète est dénombrée ;
- l’environnement exact est verrouillé ;
- aucun choix marqué libre, automatique ou par défaut ne subsiste ;
- le hash de ce document est enregistré dans protocol.lock.json.
