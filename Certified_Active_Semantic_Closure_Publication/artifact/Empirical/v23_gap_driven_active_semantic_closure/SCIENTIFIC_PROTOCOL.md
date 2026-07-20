# Protocole scientifique préenregistré v23

## Fermeture sémantique active guidée par gap

## 0. Statut normatif

Ce fichier est le contrat d'implémentation et de décision de la campagne v23.
Il transforme les obligations de
[`Docs/ValidationIntegraleFermetureSemantiqueIA.md`](../../Docs/ValidationIntegraleFermetureSemantiqueIA.md)
en choix expérimentaux fermés.

Version normative : `v23-protocol-1`.

Date de gel logique : 2026-07-16.

Le protocole est écrit avant tout run scientifique v23. Un smoke test peut
révéler une erreur d'implémentation, mais ne peut pas modifier silencieusement
une hypothèse, une marge, une partition, une baseline ou une métrique. Toute
modification postérieure à un résultat produit une nouvelle version de ce
protocole et une nouvelle campagne. Les résultats des versions différentes ne
sont jamais fusionnés sous un même identifiant.

Ce document ne revendique aucun résultat. Il définit ce qui devra être calculé,
comparé, certifié, falsifié et publié, y compris en cas d'échec.

## 1. Cible scientifique exacte

La proposition finale soumise à validation est :

> Un agent peut détecter une non-coïncidence locale depuis sa seule vue, en
> dériver un droit d'usage, exécuter le transport autorisé par ce droit,
> sélectionner une interrogation, utiliser la réponse pour construire une
> réparation intrinsèque, exécuter cette réparation comme unique cause de
> l'état suivant, conserver les réparations antérieures et poursuivre cette
> dynamique. Sous les classes et budgets explicitement définis, ni une
> politique passive recevant la même vue, ni un contrôleur dont les décisions
> factorisent par le visible déclaré ne réalisent la même fermeture.

La chaîne causale testée est exactement :

```text
AgentClosureState_n
  -> OperationalGap_n
  -> GapAuthorizedUse_n
  -> GapAuthorizedTransport_n
  -> Query_n
  -> Response_n
  -> IntrinsicRepair_n
  -> AgentClosureState_(n+1)
  -> OperationalGap_(n+1).
```

La campagne ne valide pas une simple relation dirigée, un système de
transitions arbitraire, une requête active ordinaire ou un patch extérieur. Le
successeur doit être calculé exclusivement par l'exécution de la réparation
produite dans la chaîne.

## 2. Limites de la revendication

La campagne ne cherchera pas à démontrer :

```text
une impossibilité de toute architecture passive concevable ;
une impossibilité de toute architecture projective enrichie ;
une théorie universelle de l'intelligence ;
une supériorité sur tout benchmark d'apprentissage actif ;
une sémantique complète de tous les agents ;
une équivalence entre performance empirique et théorème fondationnel.
```

Les no-go sont bornés par les classes formelles et les ressources déclarées.
Les conclusions empiriques portent sur les deux domaines, architectures,
distributions et budgets de ce protocole.

## 3. Hypothèses confirmatoires

### H1 - Concordance exécutable

Sur le domaine fini de référence, Lean et Python calculent exactement les mêmes
mondes, observations, gaps, usages, transports, requêtes, réponses, réparations,
états suivants et jugements de fermeture. Le seuil est zéro divergence.

### H2 - Liaison modèle-trace

Pour l'agent certifiable, Lean recalcule depuis les poids quantifiés et les
entrées sérialisées chaque décision discrète de la chaîne, puis prouve la
validité de la trace résultante. Un hash de checkpoint seul ne satisfait pas
cette hypothèse.

### H3 - Avantage de fermeture

Sous budgets appariés, l'agent complet dépasse le meilleur baseline admissible
sur le score principal de fermeture :

```text
Delta_task = score(full) - score(bestBaseline).
```

La borne inférieure de l'intervalle de confiance à 95 % doit être strictement
supérieure à `delta_task = 0.05`.

### H4 - Causalité du gap

Une intervention typée qui remplace le gap courant par un autre gap licite doit
déplacer l'usage, le transport, la requête et la réparation vers ce gap. Le
contraste principal est :

```text
C_gap =
  P(la requête suit le gap intervenu)
  - P(la requête continue de suivre le gap naturel).
```

La borne inférieure à 95 % doit dépasser `delta_causal = 0.20`.

### H5 - Causalité complète de la chaîne

Les contrastes appariés suivants doivent chacun avoir le signe préenregistré et
une borne inférieure à 95 % supérieure à `0.20` :

```text
gap -> usage ;
usage -> transport ;
transport -> requête ;
requête -> réponse ;
réponse -> réparation ;
réparation -> état suivant.
```

Les interventions mal typées doivent être rejetées dans 100 % des cas.

### H5b - Cohérence compositionnelle

Pour toute paire de transports composables produite dans les tests, l'exécution
séquentielle et l'exécution de leur composé doivent donner la même relation de
sortie. L'identité à gauche, l'identité à droite et l'associativité sont
vérifiées exhaustivement au niveau A et sur toutes les traces publiées aux
niveaux B et C. Une permutation non commutative doit soit changer la sortie,
soit être rejetée par le type. Le seuil est zéro violation.

### H6 - Persistance

Après réparation du préfixe `0..k`, toute transition ultérieure conserve la
correction sur ce préfixe. Le taux d'oubli cumulatif autorisé est
`epsilon_forgetting = 0.01` pour les modèles appris et `0` pour le domaine fini
et l'agent certifiable.

### H7 - Généralisation structurelle

Sur la famille OOD principale, le score de fermeture de l'agent complet doit
satisfaire simultanément :

```text
scoreOOD >= delta_ood = 0.80 ;
borne inférieure à 95 % de l'avantage OOD > 0.05 ;
oubli cumulatif <= 0.01 ;
zéro violation structurelle exacte.
```

### H8 - No-go bornés

Les no-go passif et visible factorisé doivent être reproduits par preuve Lean,
énumération exhaustive Python et calcul du meilleur contrôleur fini de leur
classe. Aucune estimation statistique ne remplace ces calculs exacts.

## 4. Niveaux de validation

La campagne comporte trois niveaux qui ne peuvent pas se substituer l'un à
l'autre.

### Niveau A - Référence finie exhaustive

Le niveau A matérialise exactement
`Meta/AI/FiniteActiveSemanticClosure.lean` et
`Meta/AI/VisibleFactoredClosureNoGo.lean`. Il fixe la signification des types et
des transitions.

### Niveau C - Agent entier certifiable

Le niveau C est un petit agent quantifié dont l'inférence complète est
réexécutée dans Lean. Il relie un checkpoint aux décisions de la chaîne et aux
preuves de trace.

### Niveau B - Campagne apprise complète

Le niveau B contient deux domaines compositionnels, des entraînements
multi-seeds, les baselines, les interventions, le scaling, les OOD scellés et
la réplication. Il porte la revendication empirique générale limitée par ce
protocole.

La réussite du niveau A n'est pas une réussite empirique du niveau B. La
réussite d'un grand modèle du niveau B ne remplace pas la certification du
niveau C.

## 5. Référence finie exacte

### 5.1 Types

L'implémentation Python reprend sans extension les types suivants :

```text
Value     = red | green | blue
Index     = first | second | third
World     = Value x Value x Value
Candidate = Option Value x Option Value x Option Value

Knowledge =
  unknown
  | excludes Value
  | exact Value

CandidatePatch =
  set Index Value
  | keep
```

Il existe exactement `3^3 = 27` mondes. L'ordre canonique d'énumération est
lexicographique avec `red < green < blue` et
`first < second < third`.

La relation d'accord est :

```text
Agrees(prediction, target) iff prediction = Some(target).
```

Elle n'est ni constamment vraie, ni constamment fausse.

### 5.2 Observation initiale

Pour un monde `world` :

```text
observation.first =
  exact red      si world.first = red
  excludes red   sinon

observation.second = unknown
observation.third = unknown.
```

Le candidat initial est :

```text
first  = Some(red)
second = None
third  = None.
```

### 5.3 Gaps et ordre de détection

Le détecteur inspecte `first`, puis `second`, puis `third`. Il retourne le
premier gap ouvert. Les genres sont exactement :

```text
witnessedMismatch ;
unresolvedFiber.
```

Chaque gap sérialise son index, son genre et son évidence observable. Il ne
sérialise ni la valeur réelle cachée, ni la requête future, ni le patch correct.

### 5.4 Usage et transport

Les directions d'usage sont :

```text
correctWitnessedMismatch ;
inspectWitnessedMismatch ;
resolveFiber ;
inspectFiber.
```

Le chemin canonique choisit `correctWitnessedMismatch` ou `resolveFiber` selon
le genre du gap. Les variantes d'inspection restent implémentées pour les tests
d'intervention et de non-trivialité.

Le transport sérialise séparément :

```text
la lecture autorisée ;
le focus candidate ou evidence ;
l'index demandé ;
le caractère informatif ;
la preuve de raccord au gap et à l'usage.
```

Il est interdit de reconstruire ce transport dans le vérificateur lorsque
l'agent en a produit un autre.

### 5.5 Requêtes et réponses dépendantes

```text
Query(index) =
  reveal index
  | confirm index
  | noInformation index

Response(reveal index)       = revealed Value
Response(confirm index)      = confirmed Value
Response(noInformation index)= noInformation.
```

`reveal` et `confirm` sont admissibles. `noInformation` est une intervention
licite pour falsification mais n'est pas admissible dans une trace naturelle.

Le footprint maximal est :

```text
reveal  : 2 bits ;
confirm : 2 bits ;
noInformation : 0 bit.
```

### 5.6 Orbite canonique

Le monde canonique est `(green, green, green)`. L'orbite canonique contient
quatre candidats et trois réparations :

```text
state0 : mismatch sur first ;
state1 : fibre non résolue sur second ;
state2 : fibre non résolue sur third ;
state3 : closed.
```

La borne de fermeture est exactement trois transitions. Les tests exhaustifs
ne se limitent pas à cette orbite : ils couvrent les 27 mondes, tous les états
atteignables, toutes les requêtes bien typées et toutes les interventions
énumérables.

### 5.7 Concordance exhaustive

Pour chaque monde et chaque état atteignable, Python et Lean doivent concorder
sur :

```text
observe ;
detectGap ;
authorize ;
executeTransport ;
selectQuery ;
respond ;
buildRepair ;
executeRepair ;
CompatibleWorlds ;
GapClosedBy ;
KnownCorrectAt ;
KnownClosedOn ;
ClosedOn.
```

Les traces interventionnelles couvrent en plus chaque remplacement typé d'un
gap, usage, transport, requête, réponse et patch par une autre valeur de son
type fini. Le critère est zéro différence de valeur et zéro différence de
statut d'acceptation.

## 6. No-go exacts et budgets formels

### 6.1 Politique passive

La classe passive est exactement `PassiveClosurePolicy`. Elle reçoit
`AgentClosureState` et sa mémoire, applique des patches, mais ne peut ni appeler
`respond`, ni rafraîchir l'observation depuis le monde.

Le budget passif primaire est :

```text
steps = 3 ;
memoryCells = 256 ;
interactionQueries = 0.
```

Le théorème étant indépendant du nombre de pas et de la mémoire tant que les
deux vues initiales coïncident, les courbes exactes supplémentaires couvrent :

```text
steps in {0, 1, 2, 3, 4, 8} ;
memoryCells in {0, 16, 64, 256, 1024} ;
interactionQueries = 0.
```

### 6.2 Contrôleur visible factorisé

La classe abstraite est exactement `VisibleFactoredClosureController` et sa
spécialisation est `FiniteVisibleFactoredClosureController`. Le no-go primaire
porte sur une seule action. Deux états complets ont le même visible, mais
exigent respectivement `askLeft` et `askRight`. Une décision qui factorise par
ce visible sélectionne la même requête et ne peut fermer les deux en un pas.

La version exacte de la tâche de fermeture utilise les stages `first` et
`second`, le même `FiniteVisibleState`, et deux `FiniteFactoredAction`
incompatibles. Le budget est :

```text
steps = 1 ;
interactionQueries = 1 ;
responseBits <= 2 ;
candidatePatches <= 1.
```

La conclusion ne sera jamais étendue aux contrôleurs qui reçoivent une variable
absente du visible déclaré.

### 6.3 Calcul du meilleur contrôleur fini

Python énumère toutes les fonctions déterministes de la classe finie. Pour les
contrôleurs randomisés, il calcule l'optimum du simplexe fini par programme
linéaire rationnel. Le rapport publie :

```text
la classe exacte ;
le nombre de contrôleurs ;
le meilleur taux moyen ;
le pire cas ;
la paire témoin ;
les actions requises incompatibles.
```

### 6.4 Capacité totale du transcript

Le certificat informationnel compte toute variable qui peut distinguer deux
mondes :

```text
observation initiale ;
choix et ordre des requêtes ;
longueur et arrêt du transcript ;
réponses ;
mémoire initiale et mémoire mise à jour ;
randomisation publique ou privée ;
patches et refus typés.
```

Pour un budget fini, la capacité maximale est calculée sur l'arbre adaptatif
complet, pas par la seule somme des bits de réponse. Le script énumère les
histoires atteignables et publie le nombre exact de feuilles, la profondeur,
le nombre de choix par noeud et `ceil(log2(nombreDeFeuilles))`.

La nécessité est démontrée par une paire de feuilles indistinguables aux cibles
incompatibles. La suffisance active est démontrée séparément par une politique
typée qui ferme toutes les feuilles sous le budget supérieur annoncé. Une borne
qui ignore le choix de requête, le timing ou la mémoire invalide G4.

## 7. API commune des domaines appris

Chaque domaine du niveau B implémente la même interface, sans alias de types :

```text
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
Response(query)
IntrinsicRepair
AgentClosureState
```

Les fonctions obligatoires sont :

```text
observe(world)
interpret(candidate, index)
evaluate(world, index)
agrees(prediction, target)
detect_gap(agent_view)
authorize(agent_view, gap)
execute_transport(agent_view, gap, use)
select_query(transport)
respond(world, query)
build_repair(agent_view, gap, use, transport, query, response)
execute_repair(agent_view, repair)
compatible_worlds(agent_view)
known_correct_at(agent_view, index)
gap_closed_by(before, gap, after)
```

`detect_gap`, `authorize`, `execute_transport`, `select_query` et
`build_repair` ne reçoivent jamais `SemanticWorld`, `Target`, une réponse future
ou la candidate finale.

Chaque épisode contient au minimum trois gaps réellement distincts, trois
réparations effectives et quatre candidats distincts.

### 7.1 Univers sémantique fermé de chaque épisode

Chaque épisode du niveau B est construit avec une famille fermée de exactement
32 mondes sémantiques distincts. Le monde réel est un élément de cette famille.
La quantification de `CompatibleWorlds`, `KnownCorrectAt`, `KnownClosedOn` et
`GapClosedBy` porte sur les 32 mondes, pas sur un échantillon postérieur.

La famille est générée et figée avant le choix du monde réel. Elle satisfait :

```text
au moins deux observations initiales différentes dans la famille ;
au moins quatre mondes partageant l'observation du monde réel ;
au moins deux cibles distinctes au premier gap non résolu ;
une requête informative qui conserve le monde réel ;
au moins un monde compatible éliminé par chaque réponse informative ;
accord de tous les mondes restants sur le gap déclaré fermé ;
fermeture de tous les gaps dans le budget annoncé.
```

Le générateur rejette l'épisode tant qu'une obligation manque. Le manifeste
privé contient les 32 mondes et permet leur énumération exhaustive par le
vérificateur. L'entrée de l'agent ne contient ni cette famille, ni son cardinal,
ni l'identifiant du monde réel. Cette fermeture finie rend les jugements
épistémiques exacts sans utiliser un solveur externe ou une approximation de
fibre.

## 8. Domaine perceptuel compositionnel

### 8.1 Monde latent

Un monde perceptuel contient :

```text
une scène 8 x 8 ;
de 3 à 6 objets ;
Shape = square | circle | triangle | cross ;
Color = red | green | blue ;
position x,y dans {0,...,7} ;
un ordre d'occlusion ;
un programme latent typé.
```

Deux objets ne partagent pas la même position avant transformation. Les
positions après mouvement sont calculées modulo 8. L'occlusion est résolue par
l'ordre latent, puis le monde est rendu en image RGB `64 x 64`.

Les mondes qui partagent l'observation du monde réel ont la même scène d'entrée
et la même image finale publique, mais diffèrent par au moins un préfixe de
programme, un état intermédiaire ou un ordre d'occlusion. Cette collision est
vérifiée pixel par pixel. La projection n'est pas constante dans le domaine :
chaque bloc de 32 épisodes contient au moins deux observations publiques
distinctes.

### 8.2 Langage de programmes

Un programme est une liste de commandes parmi :

```text
selectShape(shape)
selectColor(color)
selectAll
move(dx, dy)       avec dx,dy dans {-1,0,1}, non tous deux nuls
recolor(color)
rotateQuarter(k)   avec k dans {1,2,3}
reflect(axis)      avec axis = horizontal | vertical
release
```

Les commandes géométriques agissent sur la sélection courante. `release`
réinitialise la sélection à tous les objets. La sémantique d'une commande et de
la composition des commandes est déterministe.

En entraînement, la longueur est dans `{3,4,5}`. La famille OOD de composition
primaire utilise les longueurs `{6,7,8}` et des ordres d'opérateurs absents des
ensembles train et validation.

### 8.3 Candidate et observation

La candidate est un programme du même langage contenant des tokens corrects,
des tokens corrompus et des trous typés. Un patch ne peut modifier qu'un token
ou remplir un trou à un chemin AST déclaré.

L'observation initiale contient :

```text
l'image d'entrée ;
l'image de sortie finale ;
le programme candidat sérialisé ;
le masque explicite des trous ;
l'historique des requêtes et réponses antérieures.
```

Elle ne contient ni le programme latent, ni la liste des corruptions, ni le
prochain patch.

### 8.4 Indices, accord, requêtes et réponses

Un index perceptuel est une somme disjointe :

```text
cropIndex(stage, cropX, cropY)
objectFieldIndex(stage, slot, field)

stage dans {0,...,programLength}
cropX,cropY dans {0,1,2,3}.
slot dans {0,...,5}
field = present | shape | color | x | y.
```

Un `cropIndex` désigne une fenêtre `16 x 16` de l'image `64 x 64` après le
préfixe de longueur `stage`. Un `objectFieldIndex` désigne un champ de l'objet
au slot canonique après ce même préfixe.

```text
FieldValue = bool | Shape | Color | Fin 8
Target = cropTarget(RGB16x16) | fieldTarget(field, FieldValue)
Prediction = Option[Target]
Agrees(p,t) iff p = Some(t), avec le même tag et la même valeur.
```

Les requêtes sont :

```text
renderCrop(cropIndex)
inspectObject(objectFieldIndex)
noInformation(anyIndex).
```

`field` vaut `present`, `shape`, `color`, `x` ou `y`. Une réponse
`renderCrop` contient exactement 768 octets. Une réponse `inspectObject`
contient au plus 3 bits de valeur plus son tag de type. Elle ne contient jamais
le programme latent ou un patch. `noInformation` est réservé aux interventions.

Le budget primaire appris autorise une requête informative par transition.

### 8.5 Gap et réparation

Un gap perceptuel contient :

```text
l'index en défaut ;
le genre witnessedMismatch ou unresolvedFiber ;
une empreinte de différence accessible à l'agent ;
le chemin candidat le plus ancien compatible avec cette empreinte ;
la provenance dans l'observation ou l'historique.
```

Il ne contient pas l'opérateur latent attendu. Le patch appartient à :

```text
replaceOpcode(path, opcode)
replaceArgument(path, argument)
fillHole(path, token)
keep.
```

`keep` n'est admissible que pour une intervention négative. La trace naturelle
doit prouver que le patch modifie la candidate et ferme le gap courant sur la
fibre compatible restante.

## 9. Domaine symbolique de réparation de programmes

### 9.1 Langage

Les valeurs sont les entiers modulo 8. Une expression est :

```text
input0
input1
const(c)              c dans {0,...,7}
add(left,right)       modulo 8
xor(left,right)
ifZero(test,yes,no)
```

Un programme est une liste SSA de 3 à 8 instructions. Chaque instruction peut
lire `input0`, `input1` ou un registre strictement antérieur. La sortie est le
dernier registre.

En entraînement, les programmes ont de 3 à 5 instructions. La famille OOD
primaire utilise 6 à 8 instructions et des patrons de dépendance absents de
l'entraînement.

### 9.2 Candidate et observation

La candidate est une liste SSA bien typée avec des opcodes, arguments ou
constantes corrompus et des trous typés. L'observation initiale contient huit
triplets `(input0,input1,output)` choisis par le générateur, la candidate et
l'historique. Ces huit exemples ne déterminent pas toujours le programme.

Les programmes latents qui partagent l'observation du monde réel donnent
exactement les mêmes huit sorties initiales, mais au moins deux diffèrent sur
une entrée de requête admissible. Ils restent syntaxiquement distincts après
normalisation SSA. La projection n'est pas constante entre épisodes : chaque
bloc de 32 épisodes contient au moins deux tables initiales différentes.

### 9.3 Indices, accord, requêtes et réponses

```text
RegisterIndex = instruction(Fin 8) | output
VisibleIndex = (probeInput0, probeInput1, RegisterIndex)
Prediction   = Option[Z8]
Target       = Z8
Agrees(p,t) iff p = Some(t).
```

Les requêtes sont :

```text
executeRegister(input0, input1, instructionIndex)
executeOutput(input0, input1, output)
noInformation(index).
```

Une réponse informative contient une valeur `Z8`, soit 3 bits, et son tag de
provenance. Elle ne contient ni la liste des instructions latentes, ni le token
à écrire, ni la candidate réparée.

### 9.4 Patches

```text
replaceOpcode(instruction, opcode)
replaceOperand(instruction, side, source)
replaceConstant(instruction, value)
fillHole(instruction, token)
keep.
```

Un patch modifie exactement un emplacement. La correction est évaluée sur tous
les programmes latents encore compatibles avec l'observation et l'historique,
pas uniquement sur le programme réel.

## 10. Réalisation fondationnelle commune

### 10.1 Catégorie des contextes

Les contextes sont les historiques finis canoniques :

```text
gamma = [observationInitiale, interaction_0, ..., interaction_n].
```

Un morphisme `gamma -> delta` est une preuve que `gamma` est un préfixe de
`delta`. L'identité est la preuve de préfixe réflexive. La composition est la
transitivité des préfixes. L'encodage Python stocke explicitement les longueurs
et le hash du préfixe ; Lean porte la preuve.

### 10.2 Langage indexé

Les termes à un contexte sont :

```text
les indices visibles disponibles ;
les candidats atteignables ;
les lectures de prédiction ;
les gaps dont l'évidence provient du contexte ;
les usages autorisés par ces gaps ;
les transports autorisés par ces usages ;
les réparations dérivées d'une réponse du contexte.
```

La réindexation le long d'un préfixe conserve les objets dont la provenance
reste valide. Elle ne fabrique pas de réponse ou de réparation.

### 10.3 Doctrine

Les prédicats interprétés sont :

```text
CompatibleWithHistory(gamma, world)
KnownCorrectAt(gamma, candidate, index)
KnownClosedOn(gamma, candidate, prefix)
GapClosedBy(gamma, gap, repair)
Persists(gamma, delta, repairedPrefix)
FiberDeterminate(gamma, index).
```

Les lois de substitution utilisent l'identité interne. Les transports relaxés
utilisent seulement un `GapAuthorizedUse` et un `GapAuthorizedTransport`
valides au contexte. Cette séparation doit être visible dans les types et dans
les traces.

## 11. Schéma causal de trace

Chaque ligne JSONL correspond à une transition et contient obligatoirement :

```text
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
```

`producer_kind` vaut `reference`, `certifiable_agent`, `scaling_agent` ou
`baseline`. `checkpoint_sha256` est nul uniquement pour `reference` ; aucun
hash sentinelle n'est autorisé.

`execution_status` vaut exactement :

```text
advanced : la chaîne causale a été exécutée jusqu'à l'état suivant ;
closed_stasis : le détecteur est fermé et l'état est conservé par identité ;
typed_refusal : une intervention a été refusée au premier stade invalide.
```

Une trace naturelle ne peut pas être `typed_refusal`. Une trace
`closed_stasis` ne contient aucun objet causal aval. Une trace
`typed_refusal` indique `refusal_stage`, conserve l'état courant et ne fabrique
aucune valeur après le stade refusé ; toutes les valeurs antérieures à ce stade
doivent être présentes. `I_next_bypass` n'est valide comme trace
interventionnelle que si son statut est `typed_refusal` au stade `next`.

Le monde complet est disponible dans un flux privé du vérificateur, jamais
dans `agent_input_manifest`. `world_commitment` est son SHA-256 salé par
épisode. Le sel n'est ouvert qu'au vérificateur après production des décisions.

L'encodage canonique est UTF-8, JSON sans NaN ni infini, clés triées,
séparateurs `(',', ':')`, entiers décimaux, booléens JSON, chaînes normalisées
NFC et listes ordonnées. Tous les blobs binaires sont encodés en hexadécimal
minuscule avec longueur explicite.

Une branche `closed` ne contient aucun gap, usage, transport, requête, réponse
ou réparation sentinelle. Elle prouve le statut fermé et conserve l'état par
identité.

Le vérificateur structurel réutilise le parseur normatif et contrôle seulement
l'enveloppe, l'encodage et les invariants causaux visibles dans la ligne. Les
`validity_flags` restent des déclarations du producteur. Les vérificateurs
sémantiques des sections 25 et 26 doivent recalculer chaque jugement depuis le
monde privé ouvert, l'entrée agent, les poids, les réponses et les fonctions de
domaine ; ils ne peuvent jamais conclure depuis ces drapeaux.

## 12. Interventions obligatoires

Chaque intervention est exécutée par paire sur le même monde, le même
checkpoint et les mêmes seeds de bruit que la trace naturelle.

```text
I_projection : remplacer l'observation par une autre observation compatible ;
I_gap_suppress : supprimer un gap ouvert ;
I_gap_permute : utiliser un autre gap typé de la même vue ;
I_use_suppress : retirer l'usage ;
I_use_permute : substituer une autre direction licite ;
I_transport_suppress : retirer le transport ;
I_transport_permute : substituer un transport licite différent ;
I_query_neutral : imposer noInformation ;
I_query_alternate : choisir une autre requête informative admissible
  sur le même index dépendant ;
I_response_cross : croiser deux réponses de même type ;
I_response_neutral : utiliser la réponse non informative ;
I_repair_neutral : imposer keep ;
I_repair_permute : appliquer un autre patch bien typé ;
I_next_bypass : proposer un état suivant sans exécuter le patch ;
I_history_drop : retirer une réparation antérieure ;
I_order_swap : permuter deux transports composables ;
I_random_gap : fournir un gap aléatoire typé ;
I_unused_gap : calculer le gap naturel mais interdire son accès aux têtes aval.
```

`I_next_bypass` doit être rejetée. Une trace interventionnelle valide remplace
exactement l'équation désignée, fixe toutes les variables non descendantes et
recalcule tous les descendants. `fixed_variables` et `recomputed_variables`
forment une partition totale, disjointe et sans variable inconnue des neuf
variables causales enregistrées. La première contient exactement les ancêtres
stricts de la cible ; la seconde contient la cible et tous ses descendants dans
l'ordre causal déclaré. Dans un refus typé, « recomputed » désigne la partie
invalidée et planifiée pour recalcul : seules les valeurs antérieures au refus
sont matérialisées. Elle n'est jamais acceptée comme trace
naturelle.

La cible causale normative est :

```text
projection : I_projection
gap        : I_gap_suppress, I_gap_permute, I_random_gap
use        : I_use_suppress, I_use_permute, I_unused_gap
transport  : I_transport_suppress, I_transport_permute, I_order_swap
query      : I_query_neutral, I_query_alternate
response   : I_response_cross, I_response_neutral
repair     : I_repair_neutral, I_repair_permute
next       : I_next_bypass
history    : I_history_drop
```

## 13. Agent certifiable

### 13.1 Domaine

L'agent certifiable opère sur le niveau A complet, y compris les états
atteignables et interventionnels. Son entrée canonique possède 96 coordonnées
`Int8` :

```text
21 coordonnées pour Observation ;
12 coordonnées pour Candidate ;
21 coordonnées pour les trois RepairRecord maximaux ;
4 coordonnées pour la longueur d'historique ;
38 zéros de padding réservés et vérifiés.
```

Tout padding non nul invalide l'entrée.

### 13.2 Architecture entière

L'agent est une chaîne de têtes MLP distinctes :

```text
GapHead       : 96  -> 64 -> 64 gap logits
UseHead       : 160 -> 64 -> 8 use logits
TransportHead : 168 -> 64 -> 64 transport logits
QueryHead     : 232 -> 64 -> 9 query logits
RepairHead    : 257 -> 64 -> 10 patch logits.
```

Les dimensions additionnelles sont les catalogues one-hot suivants :

```text
GapCatalog       : 64 cases ;
UseCatalog       : 8 cases ;
TransportCatalog : 64 cases ;
QueryCatalog     : 9 cases ;
ResponseCatalog  : 16 cases ;
PatchCatalog     : 10 cases.
```

Les catalogues sont ordonnés lexicographiquement depuis les constructeurs Lean.
Ils couvrent toutes les valeurs atteignables ; les cases non utilisées sont
réservées, leur logit est forcé à `-128` et leur décodage est un refus. Le
catalogue des patches contient `keep` puis les neuf combinaisons
`set(index,value)`. Le catalogue des requêtes contient les trois constructeurs
pour chacun des trois indices.

Une tête aval reçoit la sortie discrète décodée et son one-hot, pas les logits
cachés ni un bypass depuis le monde. L'entrée de chaque tête est donc :

```text
UseHead       = state96 + gap64 ;
TransportHead = state96 + gap64 + use8 ;
QueryHead     = state96 + gap64 + use8 + transport64 ;
RepairHead    = state96 + gap64 + use8 + transport64 + query9 + response16.
```

La réponse vient uniquement de `respond(world, query)`. La taille 16 encode le
constructeur dépendant, l'index et la valeur ; toute combinaison impossible est
rejetée.

L'état suivant est produit par l'exécuteur symbolique
`execute_repair(state, repair)`. Il n'existe aucune `NextHead`.

### 13.3 Arithmétique d'inférence

```text
poids et biais : Int8 ;
entrées et activations : Int8 ;
accumulateurs : Int32 ;
activation cachée : ReLU ;
échelle par couche : division par 2^shift, shift dans {0,...,15} ;
arrondi : plus proche, égalités vers l'entier pair ;
saturation : intervalle [-128,127] ;
décision : argmax ;
égalité d'argmax : plus petit index canonique.
```

Les shifts, ordres de classes et tables de décodage font partie des poids
réifiés. Lean recalcule chaque affine, arrondi, saturation, argmax et objet
typé.

### 13.4 Entraînement et critère

L'entraînement utilise toutes les entrées finies de la table de référence et
les variantes interventionnelles licites, avec `AdamW`, taux `0.001`,
`betas=(0.9,0.95)`, poids de décroissance `0`, batch complet, 2000 mises à jour
maximum. Les seeds sont `0..9`.

Après quantification, un checkpoint n'est admissible que s'il obtient zéro
erreur sur l'ensemble exhaustif. Le premier checkpoint admissible selon
l'ordre `(seed, update)` est l'agent certifiable primaire. L'absence de
checkpoint admissible est un échec de G3 et ne déclenche aucun assouplissement
de l'architecture.

## 14. Agent appris de scaling

### 14.1 Architecture causale commune

Le modèle complet comporte :

```text
un encodeur d'observation propre au domaine ;
un encodeur de candidate ;
un encodeur d'historique ;
un agrégateur de contexte ;
GapHead ;
UseHead ;
TransportHead ;
QueryHead ;
RepairHead ;
un exécuteur symbolique non appris du patch.
```

Les sorties intermédiaires sont des objets discrets validés par le schéma de
types. Une sortie invalide produit un refus, pas une projection vers l'action
valide la plus proche. Il n'existe aucun chemin direct contexte -> patch ni
contexte -> état suivant dans le modèle complet.

### 14.2 Encodeur perceptuel

Le stem contient quatre convolutions `3 x 3`, strides `(2,2,2,1)`, padding 1,
canaux `(32,64,128,d_model)`, chacune suivie de ReLU sauf la dernière. Les
tokens spatiaux, les tokens du programme candidat et les tokens d'historique
sont concaténés avec des tags de type appris.

### 14.3 Encodeur symbolique

Chaque token du programme, exemple, requête et réponse reçoit un embedding de
type, de position et de valeur. La séquence est tronquée uniquement au-delà de
512 tokens ; le générateur rejette tout épisode qui dépasserait cette borne,
avant partition.

### 14.4 Agrégateur et tailles

L'agrégateur est un Transformer pré-norm à attention causale sur l'historique.

```text
small : d_model=64,  layers=2, heads=4, d_ff=256
base  : d_model=128, layers=4, heads=8, d_ff=512
large : d_model=256, layers=8, heads=8, d_ff=1024
```

Le modèle `base` est primaire. `small` et `large` servent à la courbe de
scaling. Les têtes sont des MLP `d_model -> d_model -> logits` avec ReLU.

Pour chaque taille et domaine, le nombre de paramètres de référence est le
compte exact dérivé de cette architecture, encodeurs et têtes compris, puis
inscrit dans le manifeste avant entraînement des baselines. Chaque baseline est
dans l'intervalle `+/- 5 %` de ce compte. Aucun paramètre mort, padding de poids
ou branche jamais exécutée n'est compté. Si une baseline ne peut entrer dans
l'intervalle sans modifier sa classe, elle est rapportée sur une courbe de
ressources et exclue de la comparaison principale à budget apparié.

### 14.5 Décision et rejeu

L'évaluation utilise `argmax` déterministe avec départage par index canonique.
Les modèles de scaling sont évalués en FP32. Une seconde implémentation
d'inférence, exportée vers ONNX Runtime CPU, doit produire les mêmes décisions
discrètes sur 100 % des traces publiées. Les logits peuvent différer d'au plus
`1e-5` en erreur absolue. Toute décision située à moins de `1e-4` de la seconde
classe est publiée comme décision à faible marge.

## 15. Régimes d'apprentissage

Trois régimes sont entraînés séparément :

```text
R_supervised : labels pour chaque objet intermédiaire ;
R_intermediate : labels gap/use/transport, récompense pour query/repair ;
R_causal : observation, réponses aux requêtes, fermeture et coûts uniquement.
```

`R_causal` est le régime confirmatoire. `R_supervised` est un contrôle de
réalisabilité. `R_intermediate` mesure l'effet d'une supervision structurée.
Les poids ne sont pas transférés entre ces régimes.

Configuration finale :

```text
optimizer = AdamW
betas = (0.9, 0.95)
weight_decay = 0.01
gradient_clip_norm = 1.0
batch_size = 64 episodes
updates = 120000
warmup = 5000 updates
schedule = cosine vers 10 % du taux initial
precision = FP32
checkpoint_interval = 5000 updates
```

La fonction objectif de `R_causal` est :

```text
1.0 * perte de fermeture terminale
+ 0.5 * coût de requête normalisé
+ 1.0 * pénalité de violation typée
+ 1.0 * pénalité d'oubli
+ 0.5 * perte de cohérence compositionnelle.
```

La pénalité de violation typée est infinie opérationnellement : une action
invalide termine l'épisode avec score nul. Son terme différentiable ne remplace
pas ce refus.

## 16. Réglage des hyperparamètres

Le réglage utilise uniquement les seeds d'entraînement `100,101,102` et les
partitions de validation non scellées. Chaque système dispose des 12
configurations :

```text
learning_rate in {0.0001, 0.0003, 0.001}
weight_decay in {0, 0.01}
dropout in {0, 0.1}.
```

Chaque configuration reçoit 30000 mises à jour sur les trois seeds. La
configuration choisie maximise, dans cet ordre :

```text
1. score structurel de validation ;
2. score de fermeture ;
3. moins de requêtes ;
4. ordre lexicographique des hyperparamètres.
```

Les seeds finales `0..9` sont réentraînées depuis zéro pendant 120000 mises à
jour avec la configuration choisie. Aucune seed finale n'est remplacée.

## 17. Baselines obligatoires

Toutes les baselines reçoivent les mêmes observations publiques, les mêmes
réponses aux requêtes qu'elles choisissent, le même nombre maximal de pas, le
même budget de réponses, la même bande de paramètres et des FLOPs par épisode
à `+/- 10 %` du modèle complet de même taille.

```text
B1  image-only / observation-only, sans candidate structurée ;
B2  candidate-only, sans observation sémantique ;
B3  all-initial-observations, aucune interaction ultérieure ;
B4  recurrent-no-action, mémoire mais aucune requête ;
B5  classical-active, requêtes actives sans gap/use/transport typés ;
B6  world-model-planner, modèle latent et planification sous même budget ;
B7  visible-factored, décisions contraintes à factoriser par le visible déclaré ;
B8  query-without-structured-repair, requête active puis patch monolithique ;
B9  external-repair, oracle de patch recevant la réponse, hors comparaison principale ;
B10 random-gap, même architecture avec gaps aléatoires ;
B11 unused-gap, gap calculé mais non transmis aux têtes aval ;
B12 direct-next, état suivant prédit directement, diagnostic interdit de revendication ;
B13 full-gap-driven, système complet.
```

`B9` et `B12` sont des plafonds diagnostiques, pas des concurrents admissibles
pour l'avantage principal, car ils violent respectivement l'intrinsécité du
repair et la causalité repair -> next.

Le meilleur baseline primaire est choisi parmi `B1..B8`, `B10` et `B11` après
réglage égal. Les résultats de tous les systèmes sont publiés.

## 18. Budgets empiriques

Pour un épisode de longueur cible `h`, tous les systèmes interactifs reçoivent :

```text
steps <= h ;
queries <= h ;
candidatePatches <= h ;
une réponse informative au plus par step ;
mémoire sérialisée <= 64 KiB pour base ;
réponse perceptuelle <= 768 octets ou un champ objet ;
réponse symbolique <= 3 bits plus tags fixes.
```

Les courbes de Pareto utilisent `h in {1,3,5,8,12,16}` et les tailles
`small/base/large`. Le score principal utilise `base` et le budget correspondant
exactement au nombre de corruptions générées. Les coûts réels en requêtes,
octets, patches, paramètres et FLOPs sont rapportés, pas seulement les maxima.

## 19. Génération des épisodes

### 19.1 Entraînement

Chaque batch est généré en ligne depuis une seed déterministe. Les épisodes
d'entraînement ont `h in {3,4,5}`, exactement `h` corruptions réparables et
donc au moins quatre candidats distincts.

### 19.2 Validation et test

Par domaine :

```text
IID validation : 4096 épisodes ;
structural validation : 4096 épisodes par famille ;
IID test figé : 8192 épisodes ;
OOD scellé : 8192 épisodes par famille ;
interventions : 4096 épisodes appariés par type et par seed finale.
```

Les mêmes épisodes d'évaluation sont partagés entre modèles pour permettre les
contrastes appariés. L'unité statistique principale reste la seed
d'entraînement.

### 19.3 Familles OOD

```text
OOD-composition : programmes de longueur 6,7,8 et ordres d'opérateurs inédits ;
OOD-horizon : h dans {8,12,16} ;
OOD-presentation : palettes, formes, occlusions ou noms de tokens inédits ;
OOD-action-response : combinaisons requête/réponse absentes de train ;
OOD-cross-family : composition + présentation simultanées.
```

La famille confirmatoire principale est `OOD-composition`. Les autres sont
secondaires préenregistrées.

Les partitions structurelles sont définies sur la forme normale des AST, pas
uniquement par des seeds. Le générateur calcule pour chaque programme un
fingerprint de la suite d'opcodes, du graphe de dépendance, de la profondeur et
des patrons d'arguments. Aucun fingerprint OOD-composition ne peut apparaître
dans train, IID validation, structural validation ou IID test. L'auditeur
recalcule cette disjonction avant ouverture des résultats.

## 20. Seeds

```text
seeds de réglage : 100,101,102 ;
seeds finales d'entraînement : 0,1,2,3,4,5,6,7,8,9 ;
seed de référence finie : 230000 ;
seed racine IID validation : 231000 ;
seed racine structural validation : 232000 ;
seed racine IID test : 233000 ;
seed racine OOD scellé : 234000 ;
seed racine interventions : 235000 ;
seed racine réplication d'évaluation : 236000 ;
seeds de nouvel entraînement de réplication : 10,11,12,13,14,15,16,17,18,19.
```

Chaque sous-seed est `uint64(SHA256(label || root || ordinal)[0:8])` en ordre
big-endian. Aucun appel au générateur aléatoire global n'est permis.

## 21. Scellement OOD

Avant tout entraînement final :

1. `freeze_and_run_v23.py` génère les manifestes OOD avec la seed racine.
2. Chaque épisode est sérialisé canoniquement puis chiffré séparément.
3. Le rapport public pré-run contient le nombre d'épisodes, les familles, les
   tailles et le Merkle root des blobs chiffrés.
4. Les clés sont stockées hors du répertoire d'entraînement et ne sont pas
   accessibles aux processus de train ou de sélection.
5. Les checkpoints, configurations et scripts d'évaluation sont hashés avant
   ouverture.
6. L'ouverture est enregistrée dans un journal append-only.

Le chiffrement est `AES-256-GCM`. Chaque blob utilise une clé de 256 bits tirée
par le générateur cryptographique du système, un nonce unique de 96 bits et le
hash du manifeste public comme données associées. Les clés sont enveloppées par
une clé de campagne conservée hors machine d'entraînement. Une réutilisation de
nonce ou une erreur d'authentification invalide la partition.

Tout accès prématuré invalide la partition. Une nouvelle partition reçoit une
nouvelle seed racine et une nouvelle version de protocole ; elle ne remplace
pas silencieusement la partition compromise.

## 22. Métriques

### 22.1 Score principal

Un épisode vaut 1 seulement si :

```text
le système atteint closed dans le budget ;
KnownClosedOn est certifié sur le domaine annoncé ;
ClosedOn est vrai dans le monde réel ;
toutes les réparations antérieures persistent ;
aucune violation de type, provenance ou causalité n'est observée.
```

Sinon il vaut 0. Le score de domaine est la moyenne par seed. Le score
confirmatoire multi-domaine est le minimum des scores perceptuel et symbolique.

### 22.2 Métriques secondaires

```text
taux de gap correct par genre ;
calibration du détecteur ;
réduction de la taille de CompatibleWorlds ;
requêtes par fermeture ;
bits de réponse par fermeture ;
patches effectifs ;
longueur du préfixe KnownClosedOn ;
taux d'oubli ;
violations typées ;
FLOPs, latence et mémoire ;
marge d'argmax ;
succès par horizon et profondeur.
```

### 22.3 Obligations exactes

Les obligations suivantes tolèrent zéro violation :

```text
concordance Lean/Python ;
validité de type ;
provenance du gap ;
alignement gap/use/transport ;
réponse conforme à la requête ;
repair dérivé de la réponse ;
next égal à executeRepair ;
monde réel conservé dans la fibre ;
refus des interventions mal typées ;
inférence certifiable bit-exacte ;
audit Lean sans axiome interdit.
```

## 23. Analyse statistique

L'unité indépendante principale est la seed d'entraînement. Les épisodes et
étapes sont des observations emboîtées.

Les intervalles sont obtenus par bootstrap hiérarchique apparié :

```text
10000 réplications ;
rééchantillonnage des seeds d'entraînement ;
puis des épisodes à l'intérieur de chaque seed ;
intervalle percentile à 95 % ;
contrastes calculés sur les mêmes épisodes.
```

Le résultat principal est le triplet confirmatoire `H3`, `H4`, `H7`. Les trois
p-values par domaine sont contrôlées par Holm à `alpha = 0.05`. Les seuils de
marge restent obligatoires même si une p-value est significative.

Chaque p-value confirmatoire est obtenue par test de permutation apparié exact
sur les dix différences inter-seeds : les `2^10 = 1024` inversions de signe
sont énumérées. Le test est unilatéral dans le sens préenregistré. Holm est
appliqué aux six tests domaine x hypothèse ; le score minimum multi-domaine et
les marges pratiques restent les critères de décision principaux.

Le rapport publie pour chaque système : moyenne, médiane, écart-type inter-seed,
intervalle, meilleur seed, pire seed, nombre d'épisodes et nombre de décisions.

## 24. Sélection, arrêt et incidents

Chaque run final effectue exactement 120000 mises à jour. Le checkpoint est
choisi parmi les checkpoints tous les 5000 pas par le score structurel de
validation, puis le score de fermeture, puis le plus petit numéro de pas.

Un run est exclu seulement pour :

```text
erreur matérielle enregistrée ;
fichier corrompu vérifié par hash ;
violation du protocole de données ;
échec du déterminisme exigé avant la première mise à jour.
```

Une divergence numérique, un score faible ou une perte NaN après le démarrage
scientifique restent des résultats. Une reprise reçoit un nouvel identifiant et
ne remplace pas la tentative initiale.

## 25. Certification Lean

Le toolchain est `leanprover/lean4:v4.29.0`. Les modules générés respectent les
contraintes constructives du dépôt.

Le pipeline produit :

```text
RawTrace réifiée ;
ValidTrace rawTrace ;
ValidInterventionTrace intervention rawTrace ;
runModel weights inputs = rawTrace ;
ValidCertifiedRun weights inputs rawTrace.
```

Les preuves sont calculées par réduction, `by decide` ou récursion spécialisée.
Le JSON n'est jamais importé comme axiome. Chaque fichier Lean généré se termine
par un unique bloc `AXIOM_AUDIT` et la campagne échoue si la sortie mentionne
un axiome, `Classical`, `propext` ou `Quot.sound`.

Les traces volumineuses sont divisées en blocs de 256 transitions. Lean prouve
chaque bloc puis leur composition ordonnée. Les hashes servent à la provenance,
pas à la validité logique.

## 26. Falsification des vérificateurs

Pour chaque champ causal, le falsificateur crée au moins une mutation :

```text
index de gap ;
genre ou évidence ;
direction d'usage ;
focus ou index de transport ;
requête ;
réponse ;
patch ;
état suivant ;
historique ;
fibre compatible ;
flag de fermeture ;
poids quantifié ;
logit ou départage ;
hash de provenance.
```

Une mutation sémantiquement invalide doit être rejetée. Une mutation valide
mais différente doit produire une nouvelle trace et un nouveau certificat, pas
être normalisée silencieusement. Le taux de détection attendu est 100 % pour le
catalogue préenregistré.

## 27. Traçabilité des scripts et sorties

Les scripts v22 sont immuables. Tout script v23 reste nouveau après avoir
produit un résultat cité.

Avant une exécution scientifique, chaque script exécuté est copié sous :

```text
<stem>_YYYYMMDD_HHMMSS_<sha256-12>.py
```

où le hash est celui du contenu copié. Les sorties du script reprennent
exactement le suffixe `YYYYMMDD_HHMMSS_<sha256-12>`. Le fichier texte de sortie
contient au début :

```text
commande complète ;
chemin du script figé ;
SHA-256 complet ;
hash du protocole ;
hash du bundle source ;
versions Python et dépendances ;
plateforme et matériel ;
seeds ;
variables d'environnement pertinentes.
```

Les smoke tests écrivent dans `/tmp/v23_smoke_*` ou dans des fichiers contenant
explicitement `_smoke_`. Ils ne deviennent jamais des résultats de référence.

## 28. Environnement logiciel

Le développement de référence utilise :

```text
Python 3.10.12 ;
PyTorch 2.10.0 ;
NumPy 2.1.1 ;
Lean 4.29.0.
```

Le run final est exécuté dans une image OCI figée par digest. Le lockfile Python,
le digest de l'image, le pilote, CUDA/cuDNN le cas échéant et la liste complète
des paquets sont enregistrés à G0. Un changement d'environnement crée un run de
réplication, pas un remplacement du run primaire.

Les algorithmes déterministes PyTorch sont obligatoires. Le run échoue avant
l'entraînement si deux passes identiques ne donnent pas les mêmes décisions et
les mêmes tenseurs sur le test de déterminisme.

## 29. Arborescence d'implémentation obligatoire

```text
Empirical/v23_gap_driven_active_semantic_closure/
  README.md
  SCIENTIFIC_PROTOCOL.md
  trace_schema_v23.py
  verify_trace_schema_v23.py
  test_trace_schema_v23.py
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
  protocol.lock.json
  manifests/
  snapshots/
  runs/
  reports/
```

`protocol.lock.json` est généré après gel des sources et contient les hashes ;
il ne redéfinit aucune règle scientifique.

## 30. Commandes normatives

Après implémentation, les seules entrées de campagne sont :

```bash
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
```

Le lanceur refuse un protocole, un script, un modèle ou un manifeste non hashé.
Il refuse également une sortie existante au lieu de l'écraser.

## 31. Portes de décision

### G0 - Provenance

Sources, protocole, environnement, commandes, seeds et partitions sont figés et
hashés.

### G1 - Formalisation

Les modules Lean compilent sans axiome interdit ; l'instance est non triviale
et intrinsèquement alignée.

### G2 - Concordance

Lean et Python concordent exhaustivement sur le niveau A, y compris les
interventions.

### G3 - Agent certifiable

Un checkpoint quantifié obtient zéro erreur exhaustive et Lean prouve
`ValidCertifiedRun` depuis ses poids et entrées.

### G4 - Nécessité informationnelle

Les no-go passif et factorisé, la capacité de transcript et le meilleur
contrôleur fini sont calculés exactement.

### G5 - Causalité

H4 et H5 passent ; aucun bypass gap/use/transport/repair/next n'est détecté.

### G6 - Dynamique

H6 passe sur plusieurs transitions et horizons ; la composition et la
persistance sont vérifiées.

### G7 - Généralisation

H3 et H7 passent sur les deux domaines et dix seeds, après ouverture OOD.

### G8 - Certification et réplication

Les certificats, falsifications, rejeux indépendants et nouveaux entraînements
de réplication satisfont les critères préenregistrés.

Une porte échouée bloque les formulations qui en dépendent. Aucun score moyen
ne compense une violation exacte.

## 32. Critères de non-trivialité

La campagne échoue si :

```text
le visible est constant sur tout un domaine ;
Agrees est constant ;
Gap, Use, Transport, Repair ou Witness est Unit ;
CandidatePatch remplace intégralement Candidate ;
le gap contient la requête ou le patch correct ;
Use est seulement Query renommé ;
Transport est seulement Use renommé ;
OutRel est universel, vide ou identique à Use sur tous les états atteignables ;
QueryAdmissible accepte tout ou rien ;
le détecteur reçoit world ou target ;
la réponse contient le monde ou la candidate finale ;
le repair est calculé par un oracle extérieur ;
next existe indépendamment de executeRepair ;
une réparation antérieure peut disparaître sans échec ;
le modèle complet peut contourner une tête causale ;
une baseline reçoit moins d'information ou moins de ressources sans rapport ;
le test OOD influence l'entraînement ou la sélection ;
un certificat fait confiance à un booléen produit par le modèle ;
un résultat à une seed est présenté comme résultat général ;
le niveau A est présenté comme la campagne v23 complète.
```

## 33. Règle de publication

Tous les runs, y compris les échecs, sont publiés avec leurs hashes. Le rapport
sépare :

```text
théorèmes exacts ;
calculs exhaustifs ;
certification de l'agent entier ;
résultats statistiques ;
analyses secondaires ;
analyses exploratoires postérieures au gel.
```

Le terme « game changer » n'est pas une conclusion du protocole. Il ne peut
être discuté qu'après G8, comparaison indépendante avec les architectures
actives pertinentes et réplication externe.

## 34. Ordre d'implémentation

L'ordre est bloquant :

```text
1. implémenter le schéma de trace et son parseur strict ;
2. implémenter le niveau A isomorphe à Lean ;
3. exécuter la concordance exhaustive ;
4. implémenter et vérifier les deux no-go ;
5. construire l'agent quantifié et son inférence Lean ;
6. falsifier les vérificateurs ;
7. implémenter les deux domaines du niveau B ;
8. implémenter le modèle complet et toutes les baselines ;
9. auditer les flux d'information et les budgets ;
10. exécuter le réglage puis les dix seeds finales ;
11. exécuter les interventions ;
12. ouvrir les OOD scellés ;
13. compiler les certificats de campagne ;
14. répliquer l'évaluation ;
15. répliquer les entraînements.
```

Il est interdit de lancer la campagne GPU confirmatoire avant G2. Il est
interdit d'ouvrir l'OOD avant gel des checkpoints et du code d'évaluation.

## 35. Verdict du protocole

Ce protocole ne réduit pas v23 à un test minimal. Le modèle fini est la base de
concordance ; l'agent quantifié fournit la liaison calculatoire ; les deux
domaines appris, les baselines, les interventions, l'OOD et la réplication
constituent la campagne finale.

La validation n'est acquise que si la même architecture causale est :

```text
définie constructivement ;
réalisée sans externalité ;
calculée sur une instance finie ;
liée à un checkpoint certifiable ;
apprise dans deux domaines ;
nécessaire sous interventions ;
comparée sous budgets appariés ;
généralisée hors distribution ;
et reproduite indépendamment.
```
