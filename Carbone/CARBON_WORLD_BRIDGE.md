# CARBON_WORLD_BRIDGE — Ce qui manque pour produire une évolution carbonée

## 0. Réponse stricte

Le cadre peut décrire l'évolution d'organisations carbonées, mais il ne peut
pas produire une évolution à partir du seul élément chimique carbone.

Le carbone défini par son numéro atomique ne détermine ni une organisation, ni
un environnement, ni une dynamique unique. Des systèmes très différents
peuvent contenir le même élément sans partager les mêmes états, interactions
ou possibilités de reproduction.

La cible correcte n'est donc pas :

```text
Carbon → Evolution
```

mais :

```text
CarbonWorld
  = configurations carbonées
  + environnement
  + dynamique physique
  + fermeture organisationnelle
  + hérédité
  + variation
  + sélection.
```

Ce document fixe le contrat nécessaire pour raccorder un tel monde au Core.
Il ne prétend pas que ce raccord est déjà réalisé.

### 0.1 Verdict sur la simulation

Une simulation Python issue du cadre peut être comparée à la réalité, mais
seulement lorsque quatre conditions sont simultanément satisfaites :

```text
1. Lean est la source normative de la transition ;
2. Python est exhaustivement conforme au noyau Lean exporté ;
3. simulation et mesure sont traduites vers le même observable calibré ;
4. la prédiction est gelée avant l'ouverture des données de test.
```

Avant ces quatre portes, Python illustre ou explore le modèle. Après elles, il
produit un test réfutable de son adéquation dans un domaine déclaré.

## 1. Ce que le Core possède déjà

Le cadre porte la forme causale générale :

```text
organisation courante
→ projection observable
→ gap
→ usage autorisé
→ transport ou interrogation
→ réponse du milieu
→ réparation
→ exécution de la réparation
→ organisation suivante.
```

Ses objets permettent notamment de distinguer :

```text
l'état interne et sa projection ;
la coordination visible et l'identité stricte ;
le gap et l'usage qu'il autorise ;
la réponse reçue et la réparation produite ;
la transition extérieure et la transition intrinsèque ;
la trajectoire courante et son histoire.
```

Le Core fournit donc la grammaire d'une dynamique de fermeture. Il ne fournit
pas, par lui-même, les réalisateurs carbonés de cette grammaire.

### 1.1 Ancrages existants dans le projet

Le raccord ne part pas d'une architecture imaginée pour ce document. Il doit
s'appuyer sur les structures déjà présentes :

| Module | Objet existant | Rôle dans `CarbonWorld` |
|---|---|---|
| `Meta/Core/ProjectiveCore.lean` | `ProjectionObstruction` | deux interfaces séparées ayant la même projection |
| `Meta/Core/DynamicCore.lean` | `LocallyRecoveredDynamicReturn` et lectures du gap | retour formé, ombre, visible et récupération locale |
| `Meta/Core/DynamicRelaxedUsage.lean` | `IntrinsicDynamicReturnFamily` | famille de retours indexée par la source, sans transition fournie |
| `Meta/Core/DynamicRelaxedUsage.lean` | `DynamicGapCausalState` | mémoire bilatérale et transports issus du même usage non contractif |
| `Meta/Semantics/DynamicFoundationalStability.lean` | `GapRepairAlgebra` | exécution intrinsèque de la réparation et successeur dérivé |
| `Meta/AI/ActiveSemanticClosure.lean` | `ActiveSemanticClosureSystem` | détection, requête, réponse et réparation du modèle observateur |

Le théorème `GapRepairAlgebra.systemNext_eq_repairNext` établit déjà que le
successeur du système générique est définitionnellement l'exécution de la
réparation. `CarbonWorld` doit instancier ce résultat, pas recréer un second
successeur.

### 1.2 Deux dynamiques à ne pas confondre

Le projet contient deux dynamiques complémentaires.

La dynamique physique recherchée utilise :

```text
Source := WorldState
family : IntrinsicDynamicReturnFamily ...
algebra : GapRepairAlgebra family
physicalNext := algebra.next.
```

Elle peut modifier `WorldState`.

La fermeture sémantique active utilise :

```text
ActiveSemanticClosureState
  world : SemanticWorld
  agent : AgentClosureState.
```

Dans ce système, `executeRepair_world` et `nextState_world` établissent que le
monde sémantique reste inchangé : la réparation modifie le candidat,
l'observation et l'histoire de l'agent. Cette dynamique ne doit donc pas être
présentée comme l'évolution physique du carbone.

La répartition correcte est :

```text
GapRepairAlgebra
  → fait évoluer le monde carboné modélisé ;

ActiveSemanticClosureSystem
  → interroge un monde tenu hors de la vue de l'agent,
    reçoit ses réponses et répare le prédicteur.
```

Le raccord simulation–réalité devra comparer ces deux trajectoires sans les
identifier : trajectoire carbonée prédite d'un côté, histoire de correction du
modèle de l'autre.

## 2. Le manque central : un réalisateur génératif

Le raccord manquant doit construire les objets du Core depuis un état carboné
et son environnement. Il ne suffit pas d'attribuer des noms chimiques à des
types abstraits.

Le réalisateur recherché doit avoir la forme conceptuelle suivante :

```text
CarbonRealization
  CarbonState           := CarbonConfiguration
  WorldState            := CarbonState × Environment
  Interface             := CarbonOrganization
  Visible               := CarbonObservation
  project               := mesure et encodage autorisés
  GapEvidence           := sous-détermination interne positive
  Use                   := interaction rendue admissible par le gap
  Response              := réponse effectivement calculée du milieu
  RepairOf organization := modification indexée par son origine
  executeRepair         := construction de l'état carboné suivant
  history               := structure matériellement persistante.
```

La difficulté essentielle est de construire `Response`, `RepairOf` et
`executeRepair` sans introduire une trajectoire cible ou une fonction `next`
extérieure.

### 2.1 Pont intrinsèque réponse–réparation

`GapRepairAlgebra` consomme la réparation déjà portée par le pôle formé. Pour
affirmer que cette réparation provient d'une réponse du milieu, `CarbonWorld`
doit porter positivement, dans sa structure et non comme hypothèse terminale :

```text
CarbonResponseRepairBridge
  ResponseAt          : Source → Type
  responseAt          : (source : Source) → ResponseAt source
  repairFromResponse  : (source : Source) →
                        ResponseAt source →
                        RepairOf (family.formedAt source)
  repairAt_eq         : (source : Source) →
                        repairFromResponse source (responseAt source)
                          = family.repairAt source.
```

La chaîne physique complète devient alors :

```text
source
→ dynamicGapCausalState family source
→ responseAt source
→ repairFromResponse source (responseAt source)
→ algebra.executeRepair source causalState repair
→ algebra.next source.
```

`repairAt_eq` ne doit pas relier deux calculs indépendants ajustés après coup.
La construction normale doit rendre cette égalité définitionnelle ou la
prouver depuis les mêmes données positives de réponse.

## 3. Ontologie positive de `CarbonWorld`

Une première version finie doit représenter explicitement au minimum :

```text
CarbonAtom
Bond
CarbonComponent
CarbonConfiguration
Compartment
Resource
EnergyToken
Environment
Interaction
Transformation
CarbonOrganization
HistoryRecord.
```

Chaque objet doit être fini ou accompagné d'un encodage fini effectif. Une
étiquette telle que `molecule`, `cellule` ou `organisme` ne vaut pas
réalisation : ses constituants et ses opérations nécessaires doivent être
constructibles.

### 3.1 État

Un état doit contenir plus que le carbone :

```text
configuration des composants carbonés ;
ressources accessibles ;
frontières ou compartiments ;
état énergétique pertinent ;
conditions environnementales ;
histoire matériellement conservée.
```

Sans environnement et sans ressources, aucune transition ouverte ne peut être
déduite du seul inventaire atomique.

### 3.2 Projection

La projection doit correspondre à une observation déclarée et non à un oubli
arbitraire choisi pour fabriquer un gap.

Elle doit satisfaire simultanément :

```text
être calculable ;
être non constante ;
oublier une information interne réelle ;
admettre au moins deux états distincts dans une même fibre ;
et conserver les informations effectivement accessibles au système étudié.
```

### 3.3 Réponse et réparation

La chaîne intrinsèque exigée est :

```text
gap(state)
→ admissibleInteraction(state, gap)
→ environmentalResponse(state, interaction)
→ repairOf(state, response)
→ executeRepair(state, repair).
```

L'état suivant est exactement le dernier terme. Il ne peut pas provenir d'une
table de succession indépendante de la réponse.

### 3.4 Critère minimal de réalisation carbonée

Pour empêcher que `CarbonConfiguration` soit un simple renommage, chaque état
doit porter une représentation vérifiable :

```text
AtomId                 : identifiants finis sans collision ;
ElementOf atom         : élément déclaré, dont Carbon ;
BondRecord             : extrémités, ordre ou classe de liaison ;
ComponentMembership    : appartenance aux composants ;
CompartmentMembership  : localisation déclarée ;
AtomInventory          : comptage par élément ;
carbonPresent          : AtomInventory(Carbon) > 0.
```

Une transformation porte un bilan :

```text
atomsBefore
atomsImported
atomsExported
atomsAfter
```

avec l'égalité constructive :

```text
atomsBefore + atomsImported = atomsAfter + atomsExported.
```

Dans un système ouvert, l'inventaire interne peut donc changer ; c'est le
bilan système–environnement qui doit fermer. Les identités atomiques sont
conservées lorsqu'elles sont suivies. Une agrégation qui ne suit que les
comptages doit déclarer qu'elle ne prouve pas la continuité individuelle des
atomes.

La charge, l'énergie et les liaisons ne sont conservées ou contraintes que si
le niveau de modèle les représente. Toute omission figure dans le domaine de
validité ; aucune conservation non encodée ne peut être revendiquée.

## 4. Fermeture organisationnelle

Une succession de transformations carbonées n'est pas encore une organisation
évolutive. Il faut établir une fermeture locale dans laquelle certaines
transformations contribuent à maintenir les conditions qui les rendent
possibles.

Le témoin minimal doit montrer que l'organisation :

```text
consomme des ressources déclarées ;
produit ou régénère des composants internes ;
maintient au moins une contrainte ou frontière ;
conserve une mémoire matérielle pertinente ;
et modifie causalement ses interactions futures.
```

La maintenance doit être une propriété vérifiée de la dynamique, pas un champ
booléen fourni sans preuve.

## 5. Passage de la dynamique à l'évolution

Le mot « évolution » n'est autorisé que lorsque quatre mécanismes positifs sont
présents.

### 5.1 Reproduction

Une organisation produit une nouvelle unité organisationnelle identifiable.
Une simple augmentation de masse ou une réaction répétée ne suffit pas.

### 5.2 Hérédité

Une partie de l'organisation parentale qui influence la dynamique future est
transmise au descendant. Cette transmission doit être traçable dans l'état et
dans l'histoire.

### 5.3 Variation

Au moins deux organisations descendantes héritables et distinctes sont
constructibles. La variation ne peut pas être un bruit extérieur sans effet
sur la suite.

### 5.4 Sélection

Dans un même environnement déclaré, les variations héritables entraînent des
différences de persistance ou de production de descendants.

La chaîne complète recherchée est alors :

```text
organisation_n
→ reproduction
→ descendants avec hérédité
→ variation
→ interaction différentielle avec le milieu
→ succès reproductif différentiel
→ composition de la population_(n+1).
```

## 6. Ce qui est interdit

Une instance `CarbonWorld` n'est pas acceptable si elle repose sur l'un des
raccourcis suivants :

- appeler `carbone` un type fini sans sémantique matérielle ;
- fournir directement `next : State → State` ;
- cacher une trajectoire de référence dans la réponse du milieu ;
- appeler évolution toute modification au cours du temps ;
- appeler reproduction une simple conservation ou une croissance ;
- déclarer une propriété chimique parce qu'elle est vraie dans une simulation ;
- confondre preuve de cohérence Lean et validation physique ;
- ajouter après coup une variable externe qui ferme la branche terminale ;
- choisir une projection uniquement parce qu'elle produit le témoin souhaité.

## 7. Échelle de réalisation

Le programme doit progresser par niveaux qui ne sont pas interchangeables.

| Niveau | Objet construit | Revendication permise |
|---|---|---|
| `CW0` | état carboné fini, projection et dynamique intrinsèque | dynamique carbonée formelle |
| `CW1` | maintenance et mémoire matérielle | fermeture organisationnelle formelle |
| `CW2` | reproduction et hérédité | lignée carbonée formelle |
| `CW3` | variation et sélection | évolution carbonée formelle |
| `CW4` | raccord à des mesures ou données réelles | modèle carboné empiriquement testé |
| `CW5` | prédictions tenues à l'écart et réplication indépendante | revendication scientifique forte |

Atteindre `CW0` ne doit jamais être présenté comme `CW3` ou `CW5`.

## 8. Réfutabilité par couche

### 8.1 Couche formelle

Une construction échoue si elle ne type pas, dépend d'un axiome interdit, ne
ferme pas sa transition intrinsèquement ou viole ses invariants finis.

### 8.2 Couche de modèle

Le modèle est réfuté dans son domaine déclaré si :

```text
une réponse admissible observée sort de l'ensemble calculé ;
un bilan matériel annoncé est violé ;
la projection ne correspond pas à l'observation déclarée ;
la réparation dépend d'une information que le système ne reçoit pas ;
ou une baseline plus pauvre possède la même capacité prédictive.
```

### 8.3 Couche évolutive

La revendication d'évolution est réfutée si la variation n'est pas héritable,
si les descendants ne sont pas des unités reproductrices, ou si les
différences de reproduction ne dépendent pas causalement des variations dans
l'environnement déclaré.

## 9. Programme sans coût expérimental initial

L'absence de budget n'interdit pas de construire le raccord formel. Elle limite
la portée empirique autorisée.

Le travail réalisable localement est :

```text
1. définir `CarbonWorld` comme interface positive ;
2. prouver que toute transition vient de la chaîne gap-réponse-réparation ;
3. construire un témoin fini explicitement déclaré comme modèle ;
4. établir maintenance, reproduction, hérédité, variation et sélection ;
5. tester ensuite une instanciation sur des données publiques sans les appeler
   expérience nouvelle ;
6. conserver le raccord physique complet comme étape ultérieure.
```

Ce programme peut atteindre `CW3` sans frais de laboratoire. Il ne peut pas
atteindre honnêtement `CW4` ou `CW5` sans données appropriées.

## 10. Critère d'acceptation final

Le cadre décrira effectivement l'évolution d'organisations carbonées lorsque
le paquet contiendra simultanément :

```text
un état carboné positif et fini ;
un environnement explicite ;
une projection non triviale ;
un gap construit depuis cette projection ;
une réponse du milieu calculée ;
une réparation intrinsèque ;
une transition exactement produite par cette réparation ;
une maintenance organisationnelle ;
une reproduction ;
une hérédité ;
une variation ;
une sélection ;
et une séparation claire entre modèle et réalisation physique.
```

Avant cela, le projet décrit les conditions de possibilité d'une évolution
carbonée. Après cela, il en possède une instance formelle. Seules des données
réelles peuvent ensuite établir que cette instance réalise un système physique.

## 11. État de la construction

La première tranche `CW0-alpha` est désormais implémentée dans
[`CW0/Lean/CarbonWorld.lean`](./CW0/Lean/CarbonWorld.lean). Elle définit
l'interface positive `CarbonWorld`, une obstruction projective carbonée, le
bilan système–environnement et un successeur entièrement dérivé d'un pas
causal et de sa réparation.

La suite de `CW0-alpha` construit maintenant l'adaptateur vers
`IntrinsicDynamicReturnFamily`, le pont positif réponse–réparation et
`GapRepairAlgebra`, sans ajouter de second successeur. L'égalité entre le pas
du Core et celui du monde porte sur le point dépendant complet.

`CW1-alpha`, dans
[`CW1/Lean/MaintenanceMemory.lean`](./CW1/Lean/MaintenanceMemory.lean), ajoute
un contrat positif de maintenance et une mémoire topologique binaire. La
porte nécessaire vers `CW1-beta` et sa première instance sont formalisées dans
[`CW1/Lean/ActiveMaintenanceBoundary.lean`](./CW1/Lean/ActiveMaintenanceBoundary.lean).
Le témoin porte désormais une demande, une entrée et une dissipation d'énergie
strictement positives avec bilan ouvert exact. Ces jetons restent sans unité
physique et la demande atomique demeure nulle. La prochaine construction doit
donc ajouter un flux matériel explicite et équilibré. Elle doit précéder toute
revendication de reproduction `CW2`.

## 12. Séparation des responsabilités

Le raccord complet comporte cinq couches. Chacune possède une responsabilité
propre et ne doit pas usurper celle d'une autre.

| Couche | Responsabilité | Ce qu'elle ne prouve pas |
|---|---|---|
| `Core` | forme causale gap–usage–réponse–réparation | existence d'un réalisateur carboné |
| `CarbonWorld Lean` | définition finie, transition intrinsèque et invariants | adéquation au monde physique |
| noyau exporté | représentation canonique exécutable du modèle Lean | exactitude des données réelles |
| simulateur Python | calcul à l'échelle, échantillonnage et statistiques | vérité du modèle source |
| adaptateur empirique | traduction des mesures dans les observables déclarés | validité hors du domaine testé |

Le sens de dépendance autorisé est :

```text
Core
→ CarbonWorld Lean
→ noyau exporté
→ simulation Python
→ prédictions observables
→ comparaison aux données.
```

Les données réelles peuvent réfuter ou recalibrer une version ultérieure du
modèle. Elles ne peuvent pas modifier silencieusement une version déjà gelée
pendant son test.

## 13. Contrat formel de simulation

### 13.1 Domaine fini déclaré

Chaque version de `CarbonWorld` doit déclarer un domaine fermé :

```text
CarbonStateId
EnvironmentId
WorldStateId
InteractionId
ResponseId
RepairId
VisibleId
ObservationId
ParameterId.
```

Les identifiants ne sont pas la sémantique. Chacun renvoie à une donnée
positive décrivant son contenu carboné, son unité, son domaine et sa
provenance.

Le domaine contient au minimum :

```text
carbonStates       : ensemble fini de configurations admissibles ;
environments       : ensemble fini d'environnements admissibles ;
worldStates        : sous-ensemble fini des couples admissibles ;
initialWorldStates : sous-ensemble non vide ;
Source             := WorldState ;
Interface          := CarbonOrganization ;
Visible            := CarbonObservation ;
project            : Interface → Visible ;
family             : IntrinsicDynamicReturnFamily ... ;
responseBridge     : CarbonResponseRepairBridge family ;
algebra            : GapRepairAlgebra family ;
observe            : WorldState → ObservationSet.
```

À une source donnée, les objets effectivement consommés sont :

```text
causalState(worldState) := dynamicGapCausalState family worldState
response(worldState)    := responseBridge.responseAt worldState
repair(worldState)      :=
  responseBridge.repairFromResponse worldState (response worldState)
step(worldState)        :=
  algebra.executeRepair worldState (causalState worldState) (repair worldState).
```

La loi `responseBridge.repairAt_eq`, suivie de
`GapRepairAlgebra.systemNext_eq_repairNext`, doit établir :

```text
step(worldState) = algebra.next worldState.
```

Cette égalité doit être dérivée. Elle ne doit pas être une hypothèse de
concordance fournie par l'instance.

### 13.2 Paramètres

Les paramètres sont séparés en trois classes :

```text
structuralParameters   : déterminent la forme du réseau ;
calibrationParameters  : estimés sur les données autorisées ;
protocolParameters     : observation, horizon, discrétisation et seuils.
```

Chaque paramètre porte :

```text
nom ;
type et unité ;
domaine fini ou intervalle rationnel ;
source ;
méthode d'estimation ;
version ;
statut gelé ou ouvert.
```

Un paramètre absent n'est jamais remplacé par une valeur implicite. Il bloque
la transition concernée ou rend sa réponse ensembliste.

### 13.3 Invariants obligatoires

Selon le niveau revendiqué, le noyau Lean doit établir :

```text
fermeture de la transition dans le domaine ;
conservation de l'inventaire déclaré ;
non-négativité des ressources ;
respect des capacités de compartiment ;
traçabilité de chaque réparation jusqu'à sa réponse ;
traçabilité de chaque réponse jusqu'à son interaction ;
persistance explicite des données appelées mémoire ;
absence de lecture d'une cible future ;
finitude des ensembles de réponses ;
et calculabilité de la projection.
```

## 14. Sémantique déterministe, ensembliste et stochastique

Ces trois régimes doivent rester distincts. Le noyau intrinsèque du Core reste
déterministe une fois la source, son état causal et sa réparation fixés. Le
caractère ensembliste ou stochastique vient d'une information partielle sur la
source ou sur une réponse positive encore non résolue ; il ne remplace pas
`algebra.next` par une transition extérieure.

### 14.1 Régime déterministe

```text
step := algebra.next : WorldState → WorldState
```

Il n'est admissible que si `WorldState` encode toutes les
variables nécessaires dans le domaine. Une incertitude non représentée ne
peut pas être éliminée par choix arbitraire d'un successeur.

### 14.2 Régime ensembliste

```text
compatibleStates : Visible → FiniteNonemptySet WorldState
stepSetAtVisible visible :=
  image algebra.next (compatibleStates visible).
```

Il représente une information partielle sans attribuer de probabilités non
justifiées. C'est le régime par défaut lorsque plusieurs réparations restent
compatibles avec les données disponibles.

Si plusieurs réponses physiques sont possibles depuis la même configuration
apparente, le domaine doit porter un `OutcomeToken` ou une donnée positive
équivalente dans la réponse ou la source enrichie. Une fois cette donnée fixée,
l'exécution reste celle de `GapRepairAlgebra`.

### 14.3 Régime stochastique exact

```text
beliefAtVisible : Visible → FiniteRationalDistribution WorldState
kernelAtVisible visible :=
  pushForward algebra.next (beliefAtVisible visible).
```

Les poids sont des rationnels non négatifs dont la somme vaut exactement un.
Le support de `kernelAtVisible visible` doit coïncider avec l'image des sources
compatibles de poids non nul. Une probabilité réelle approchée peut être
utilisée par Python, mais la version formelle de référence conserve les poids
rationnels avant conversion numérique.

Le régime stochastique ne doit pas masquer une ignorance structurelle. Si les
poids ne sont pas identifiables, le modèle reste ensembliste ou porte une
famille finie de distributions admissibles.

## 15. Noyau exporté canonique

Python ne doit pas réimplémenter les lois causales. Lean produit un paquet
canonique contenant :

```text
schema_version.json
domain.json
states.json
environments.json
projections.json
transitions.json
beliefs.json
observations.json
parameters.json
invariants.json
test_vectors.json
provenance.json
MANIFEST.sha256.
```

### 15.1 Contenu minimal d'une transition

```text
source_carbon_state_id
source_environment_id
gap_id
interaction_id
response_id
repair_id
target_carbon_state_id
target_environment_id
inventory_before
inventory_after
provenance_id.
```

`transitions.json` contient la transition déterministe intrinsèque de chaque
`WorldState`. Les distributions épistémiques sont séparées dans
`beliefs.json` :

```text
visible_id
source_carbon_state_id
source_environment_id
weight_numerator
weight_denominator
provenance_id.
```

Tous les identifiants référencés doivent exister. Les poids nuls sont omis et
les poids associés à un visible somment exactement à un. L'ordre des lignes est
canonique afin que deux exports sémantiquement identiques aient le même hash.

### 15.2 Règle d'autorité

La source d'autorité est :

```text
définitions Lean
→ évaluation Lean
→ export canonique hashé.
```

Une table modifiée manuellement n'est plus un export du modèle. Elle reçoit un
nouvel identifiant de modèle et doit être réimportée puis vérifiée si elle doit
devenir normative.

## 16. Conformité entre Lean et Python

### 16.1 Deux modes Python

Le simulateur possède deux moteurs séparés :

```text
exact    : énumère les supports et calcule avec les poids rationnels ;
sampling : échantillonne le même noyau pour les études à grande échelle.
```

Le moteur exact sert de référence de conformité. Le moteur d'échantillonnage
sert aux estimations numériques, jamais à redéfinir le support possible.

### 16.2 Obligation d'exhaustivité

Pour un domaine fini, la conformité ne repose pas sur quelques tests unitaires.
Le validateur doit parcourir tous les `WorldState`, c'est-à-dire tous les
couples admissibles :

```text
(carbonState, environment)
```

et vérifier :

```text
même projection ;
même successeur intrinsèque de chaque `WorldState` ;
mêmes supports et poids rationnels des croyances en mode exact ;
même noyau projeté obtenu par image de `algebra.next` ;
mêmes identifiants de gap, interaction, réponse et réparation ;
mêmes inventaires avant et après ;
mêmes observations projetées.
```

Le rapport de conformité contient le nombre total de cas, le nombre de cas
comparés et la liste complète des divergences. Un seul cas non vérifié empêche
le statut `PYTHON_CONFORMANT`.

### 16.3 Limite de la preuve

Lean peut prouver les propriétés de son noyau. Il ne prouve pas directement
que l'interpréteur Python, le système d'exploitation ou le matériel sont
corrects. La confiance dans Python repose sur :

```text
un export canonique ;
un moteur exact minimal ;
des tests exhaustifs du domaine fini ;
des hashes ;
et la reproductibilité indépendante des sorties.
```

Si une garantie plus forte devient nécessaire, les résultats critiques sont
réimportés dans Lean sous forme de certificats finis et revérifiés.

## 17. Simulation des trajectoires

### 17.1 État initial

Une simulation n'accepte que des états initiaux appartenant au domaine et
portant une provenance :

```text
constructed_witness
public_training_data
public_validation_data
external_measurement
counterfactual_scenario.
```

Un scénario contrefactuel ne doit pas être présenté comme mesure.

### 17.2 Temps et générations

Trois indices sont distingués :

```text
transition_index : nombre d'exécutions de réparation ;
physical_time    : durée associée lorsque le modèle la définit ;
generation_index: incrément uniquement lors d'une reproduction validée.
```

Une transition ne vaut pas automatiquement une génération. Le simulateur ne
peut pas fabriquer une vitesse physique si la correspondance temporelle n'est
pas spécifiée.

### 17.3 Arrêts

Les conditions d'arrêt sont positives et versionnées :

```text
horizon fini atteint ;
état terminal intrinsèque atteint ;
ressource déclarée épuisée ;
population vide ;
cycle détecté si le protocole l'autorise ;
ou violation qui invalide le run.
```

Une limite de calcul ne devient pas un état terminal du modèle.

## 18. Adaptateur vers la réalité

La comparaison n'est pas faite entre un état Lean et un fichier brut. Un
adaptateur empirique explicite traduit les deux côtés vers le même type
`Observation`.

```text
simulatedState
  → simulatedObservation

physicalMeasurement
  → calibratedObservation
```

Seules ces observations sont comparées.

### 18.1 Enregistrement de mesure

```text
MeasurementRecord
  measurement_id
  system_id
  observable_id
  value
  unit
  uncertainty
  detection_limit
  calibration_id
  protocol_id
  physical_time
  generation_index_if_known
  raw_artifact_id
  source_id
  exclusion_status.
```

Une unité, une incertitude ou une calibration manquante ne reçoit pas la
valeur zéro. Le champ reste manquant et les tests qui en dépendent deviennent
inapplicables.

### 18.2 Domaine d'applicabilité

Avant toute prédiction, le système réel est classé :

```text
IN_DOMAIN
BOUNDARY_CASE
OUT_OF_DOMAIN
UNDETERMINED.
```

Seul `IN_DOMAIN` contribue au test primaire. Les autres statuts sont conservés
et rapportés. Ils ne doivent pas être supprimés pour améliorer une métrique.

### 18.3 Incertitude de mesure

Le modèle produit une observation ponctuelle, un ensemble fini ou une
distribution. La mesure produit un intervalle ou une loi d'erreur. Le test
compare donc des objets avec incertitude, pas uniquement des valeurs centrales.

Une convention d'arrondi commune est fixée avant le test. Élargir les
intervalles après observation invalide le test primaire.

## 19. Séparation des données

### 19.1 Compartiments documentaires

Les données sont réparties avant l'ajustement :

| Compartiment | Usage autorisé |
|---|---|
| `theory` | définir les types et invariants généraux |
| `training` | ajuster les paramètres annoncés |
| `selection` | choisir entre variantes préexistantes |
| `validation` | régler le protocole sans produire la revendication finale |
| `held_out_test` | tester une version gelée une seule fois |
| `external_replication` | réplication indépendante |

Une donnée ayant influencé une règle, un seuil, une projection ou une variante
n'est plus tenue à l'écart pour cette version.

### 19.2 Prévention des fuites

Sont considérés comme fuite :

- inspecter le test avant de geler le modèle ;
- choisir la projection après avoir vu les erreurs ;
- ajouter une variable parce qu'elle distingue les cas ratés ;
- supprimer une famille de réactions après un échec ;
- ajuster les poids sur les fréquences du test ;
- utiliser le nom du résultat comme entrée cachée ;
- réemployer le test pour annoncer la performance de la version corrigée.

Après une fuite, le compartiment devient `training` ou `selection`. Un nouveau
jeu tenu à l'écart est nécessaire.

### 19.3 Instanciation de la fermeture sémantique active

La couche AI peut être instanciée sans la confondre avec le monde physique :

```text
ActiveClosureData.SemanticWorld := source de données ou oracle physique figé
Candidate                       := version candidate de CarbonWorld
Observation                     := réponses déjà autorisées
RepairRecord                    := trace d'une correction du modèle
VisibleIndex                    := identifiant d'une requête mesurable
Prediction                      := observation prédite
Target                          := observation reçue du monde
CandidatePatch                  := modification versionnée du candidat.
```

La chaîne existante s'interprète alors :

```text
detectGap
→ authorize
→ executeTransport
→ selectQuery
→ respond
→ buildRepair
→ executeRepair
→ nouveau candidat et nouvelle histoire de l'agent.
```

Le monde de données reste fixe, conformément à `nextState_world`. Cette
fermeture sert à la phase `training` ou `selection` : elle construit et trace
les corrections successives du prédicteur.

Elle est désactivée pour le test tenu à l'écart. Pendant `held_out_test`, le
candidat est gelé : une erreur constitue un résultat du test. Elle ne déclenche
pas une réparation comptée dans la performance de la même version. Une
réparation ultérieure ouvre une nouvelle version dont le test précédent fait
désormais partie de l'histoire d'apprentissage.

## 20. Gel d'une prédiction

Avant l'ouverture des données de test, le paquet suivant est figé :

```text
version du Core ;
version CarbonWorld ;
export canonique et son hash ;
simulateur Python et son hash ;
paramètres ;
états initiaux ;
horizon ;
adaptateur d'observation ;
domaine d'applicabilité ;
baselines ;
métriques ;
seuils de réussite et de réfutation ;
règles d'exclusion ;
et graine aléatoire si elle intervient dans un résultat primaire.
```

Le paquet de prédiction est horodaté. Une correction, même mineure, produit
une nouvelle version et ne remplace jamais le paquet initial.

## 21. Métriques et critères de réfutation

Les métriques exactes dépendent du régime sémantique.

### 21.1 Prédiction déterministe

Un cas échoue si l'observation calibrée est incompatible avec l'observation
unique prédite selon la tolérance préenregistrée.

Le modèle déterministe est réfuté dans son domaine déclaré dès qu'un cas
admissible viole une loi annoncée comme universelle. Une revendication de taux
de succès doit être formulée séparément.

### 21.2 Prédiction ensembliste

Les mesures principales sont :

```text
coverage    : fréquence d'inclusion de l'observation réelle ;
set_size    : taille ou largeur de l'ensemble prédit ;
specificity : réduction par rapport à tous les états possibles.
```

Une couverture élevée obtenue en prédisant tout le domaine n'est pas un
succès. Le seuil doit porter conjointement sur couverture et spécificité.

Un cas primaire réfute une garantie de couverture universelle si l'intervalle
observé est disjoint de l'ensemble prédit après propagation des erreurs.

### 21.3 Prédiction stochastique

Le rapport doit inclure au minimum :

```text
score propre préenregistré ;
calibration des probabilités ;
fréquence des événements auxquels le modèle attribuait une masse nulle ;
comparaison aux baselines ;
incertitude due au Monte-Carlo ;
et sensibilité aux paramètres non identifiés.
```

Un événement admissible auquel le noyau gelé attribue une probabilité exacte
nulle réfute le support du modèle, sous réserve que l'identification et la
mesure soient valides.

### 21.4 Invariants physiques

Une violation d'inventaire, de non-négativité ou de capacité n'est pas une
simple erreur prédictive. Elle invalide le run ou le modèle selon l'origine de
la violation. Elle est toujours rapportée séparément des métriques de qualité.

## 22. Baselines et ablations

Une performance n'est informative que contre des alternatives plus pauvres.
Les baselines minimales sont :

```text
persistence          : l'observation ne change pas ;
majority              : réponse la plus fréquente du training ;
visible_only          : prédiction depuis la projection sans état interne ;
unconstrained_markov  : transition ajustée sans chaîne causale du Core ;
full_support          : tous les futurs sont possibles.
```

Les ablations retirent une composante à la fois :

```text
sans gap ;
sans histoire ;
sans réponse du milieu ;
sans réparation indexée ;
sans compartiment ;
sans hérédité ;
sans variation.
```

Le cadre apporte un gain empirique seulement si sa structure améliore une
métrique préenregistrée ou permet une garantie que les baselines ne possèdent
pas. L'échec face à une baseline n'annule pas les théorèmes, mais interdit la
revendication d'utilité prédictive correspondante.

## 23. Tests spécifiques de fermeture et d'évolution

### 23.1 Maintenance

Une propriété `Maintained organization interval` doit être calculée depuis la
trajectoire. Elle vérifie la persistance de constituants ou contraintes
déclarés malgré des transformations et des flux.

Le contrôle contrefactuel retire la réparation ou la ressource pertinente. Si
la même maintenance est obtenue, le mécanisme de fermeture annoncé n'est pas
causalement discriminé.

### 23.2 Reproduction

Le modèle doit fournir :

```text
isReproductiveUnit : Organization → Bool
parentOf           : OrganizationId → OrganizationId → Prop
birthEvent         : State → FiniteSet ReproductionRecord.
```

Chaque événement de naissance identifie le parent, le descendant, les
ressources consommées et les composants transmis. Le simple comptage d'une
espèce chimique n'est pas un événement de reproduction.

### 23.3 Hérédité

Un `HeritableTrait` doit :

```text
être calculable sur le parent et le descendant ;
être transmis au-dessus d'une baseline déclarée ;
modifier au moins une possibilité future ;
et ne pas être reconstruit uniquement depuis l'étiquette de lignée.
```

La transmission est rapportée avec ses échecs. Une sélection sans hérédité
n'établit pas une évolution cumulative.

### 23.4 Variation

Les opérateurs de variation sont internes à la dynamique ou à une réponse
environnementale déclarée. Chaque variante porte sa provenance causale. Une
liste de descendants écrite à l'avance n'est pas une variation produite.

### 23.5 Sélection

Le test compare des variants héritables dans un environnement commun et
mesure une différence de descendants viables ou persistants à un horizon
préenregistré.

Une différence initiale de ressources, de temps ou de traitement confondue
avec le variant invalide le test causal. La sélection simulée n'établit une
sélection physique qu'après comparaison aux données correspondantes.

## 24. Traçabilité des simulations Python

Toute expérience numérique citée doit être immuable et reconstructible.

### 24.1 Scripts

- un script ayant produit un résultat cité n'est jamais modifié ;
- toute variante reçoit un nouveau nom ;
- chaque exécution scientifique utilise une copie figée du script ;
- le nom de cette copie contient un timestamp et son hash SHA-256 ;
- le simulateur vérifie le hash de l'export Lean avant de démarrer.

### 24.2 Sorties

Les sorties reprennent exactement le suffixe timestamp et hash du script :

```text
run_<timestamp>_sha256-<hash>.jsonl
run_<timestamp>_sha256-<hash>.txt
```

Le rapport texte contient :

```text
commande complète ;
hash du script ;
hash du noyau Lean exporté ;
versions des dépendances ;
plateforme ;
graine aléatoire ;
paramètres ;
compartiment de données ;
heure de début et de fin ;
statut de conformité.
```

Les smoke-tests écrivent dans `/tmp` ou dans des fichiers marqués `smoke`. Ils
ne remplacent aucune sortie de référence.

### 24.3 Aléatoire

Une graine fixe permet la reproduction d'un run, mais ne suffit pas à valider
un résultat stochastique. Les conclusions primaires doivent être stables sur
un protocole de graines préenregistré ou calculées exactement lorsque le
domaine le permet.

## 25. Taxonomie des échecs

Tout échec reçoit une classe afin d'éviter qu'un problème soit déplacé vers une
autre couche.

| Classe | Exemple | Conséquence |
|---|---|---|
| `FORMAL` | invariant Lean non prouvé | modèle non admissible |
| `EXPORT` | table incomplète ou hash incohérent | simulation interdite |
| `CONFORMANCE` | Python diffère du noyau exact | résultats Python invalides |
| `NUMERICAL` | instabilité ou erreur Monte-Carlo | estimation à refaire, modèle non encore jugé |
| `DATA` | unité, calibration ou provenance absente | cas non testable |
| `DOMAIN` | système hors domaine déclaré | aucune conclusion sur le modèle interne |
| `MODEL` | observation admissible hors prédiction | version du modèle réfutée ou garantie rompue |
| `EVOLUTION` | absence d'hérédité ou de reproduction | revendication évolutive rejetée |
| `REPLICATION` | résultat non reproduit | revendication forte non acquise |

Une correction change la version. Le rapport de la version réfutée reste
conservé.

## 26. Niveaux de validation de la chaîne numérique

| Niveau | Condition |
|---|---|
| `SIM0` | script Python exécutable sur un exemple |
| `SIM1` | conformité exhaustive au noyau Lean sur le domaine fini |
| `SIM2` | reproduction de données utilisées pour la calibration |
| `SIM3` | prédiction tenue à l'écart supérieure aux baselines selon le contrat |
| `SIM4` | réplication indépendante sur une autre source ou équipe |

`SIM0` ne démontre que l'exécution. `SIM1` démontre que Python exécute le bon
modèle. `SIM2` est rétrospectif. La première validation prédictive commence à
`SIM3`.

Les niveaux `SIM` et `CW` sont orthogonaux. Une instance peut être `CW3/SIM1` :
évolution formelle correctement simulée mais non validée empiriquement.

## 27. Architecture documentaire et logicielle visée

```text
Carbone/
  CARBON_WORLD_BRIDGE.md
  CW0/
    README.md
    DOMAIN.md
    CLAIMS.md
    Lean/
      CarbonWorld.lean
      CarbonWorldFinite.lean
      CarbonWorldExport.lean
    schema/
      domain.schema.json
      transition.schema.json
      measurement.schema.json
    exports/
      <version>/
        *.json
        MANIFEST.sha256
    python/
      simulate_carbon_world.py
      validate_conformance.py
      compare_observations.py
    data/
      sources/
      extracted/
      splits/
    runs/
      smoke/
      reference/
    reports/
      CONFORMANCE.md
      VALIDATION.md
      LIMITS.md.
```

Cette arborescence est une cible. Aucun fichier de résultat ne doit être créé
avant que son schéma, son statut et sa provenance soient définis.

## 28. Feuille de route sans frais de laboratoire

### Phase A — Spécification

```text
A1. définir le domaine fini CW0 ;
A2. définir les états, environnements et observations ;
A3. fixer les invariants ;
A4. fixer les revendications et réfutations ;
A5. identifier des données publiques compatibles.
```

Sortie : contrat relu, aucun résultat.

### Phase B — Noyau constructif

```text
B1. instancier les objets du Core ;
B2. dériver la transition de la réponse et de la réparation ;
B3. prouver fermeture et invariants ;
B4. ajouter l'audit d'axiomes ;
B5. évaluer exhaustivement le domaine fini.
```

Sortie : `CW0`, sans revendication physique.

### Phase C — Export et Python

```text
C1. produire l'export canonique ;
C2. écrire le moteur exact minimal ;
C3. vérifier exhaustivement la conformité ;
C4. ajouter le moteur d'échantillonnage ;
C5. figer le premier run reproductible.
```

Sortie : `SIM1`.

### Phase D — Données publiques

```text
D1. figer les sources et leurs hashes ;
D2. construire l'adaptateur empirique ;
D3. séparer calibration et test ;
D4. définir les baselines ;
D5. geler la prédiction ;
D6. ouvrir le test et publier aussi les échecs.
```

Sortie possible : `CW4/SIM3`, seulement si les données sont adéquates.

### Phase E — Évolution formelle

```text
E1. ajouter maintenance et mémoire ;
E2. définir l'unité reproductrice ;
E3. construire l'hérédité ;
E4. produire la variation ;
E5. établir la sélection ;
E6. répéter export, conformité et comparaison.
```

Sortie possible : `CW3`, puis `CW4` si un raccord empirique existe.

## 29. Portes de décision

### Porte `G0` — domaine

```text
GO si les états et environnements sont finis, positifs et interprétables ;
NO-GO si « carbone » reste une étiquette sans contenu.
```

### Porte `G1` — intrinsicité

```text
GO si step se réduit à gap–interaction–réponse–réparation–exécution ;
NO-GO si un successeur extérieur subsiste.
```

### Porte `G2` — conformité

```text
GO si Python correspond exhaustivement au noyau exporté ;
NO-GO au premier cas divergent.
```

### Porte `G3` — observation

```text
GO si simulation et mesure partagent un observable calibré ;
NO-GO si la comparaison repose sur des quantités différentes.
```

### Porte `G4` — prédiction

```text
GO selon les métriques et seuils préenregistrés sur données tenues à l'écart ;
NO-GO si le modèle échoue ou n'améliore pas la baseline exigée.
```

### Porte `G5` — évolution

```text
GO si reproduction, hérédité, variation et sélection sont toutes positives ;
NO-GO si l'une est seulement supposée ou renommée.
```

## 30. Revendications autorisées

Les formulations doivent suivre l'état réel du paquet.

### Après `CW0/SIM1`

Autorisé :

> Une dynamique finie d'organisations carbonées est intrinsèquement dérivée du
> Core, constructivement certifiée et exécutée conformément en Python.

Interdit :

> Le carbone réel évolue selon notre modèle.

### Après `CW3/SIM1`

Autorisé :

> Le modèle contient une reproduction, une hérédité, une variation et une
> sélection formellement réalisées.

Interdit :

> Une évolution carbonée physique a été observée.

### Après `CW4/SIM3`

Autorisé, dans le domaine exact :

> La version gelée prédit les observations carbonées tenues à l'écart selon le
> protocole et les seuils déclarés.

Interdit :

> Toute évolution carbonée est calculable.

### Après `CW5/SIM4`

Une revendication scientifique forte devient possible, mais reste limitée au
domaine, aux observables, aux environnements et aux horizons effectivement
testés.

## 31. Questions qui doivent rester ouvertes

Avant de choisir l'instance `CW0`, il faut répondre explicitement :

```text
quelle organisation carbonée minimale est représentée ?
quelle observation produit la projection ?
quel gap possède une conséquence causale ?
quel environnement répond ?
quelle réparation est réellement produite par cette réponse ?
quel inventaire doit être conservé ?
quelle variable constitue une mémoire ?
quelle donnée publique peut tester le modèle ?
quel résultat le réfuterait ?
quelle baseline menace le plus directement la nouveauté ?
```

Une question non résolue doit rester visible dans le contrat. Elle ne doit pas
être fermée par une constante arbitraire uniquement pour permettre la
compilation.

## 32. Critère final du raccord simulation–réalité

La comparaison est directe au sens scientifique uniquement si le diagramme
suivant commute dans les tolérances préenregistrées :

```text
état physique_n ───── transformation physique ─────→ état physique_(n+1)
      │                                                       │
      │ mesure calibrée                                      │ mesure calibrée
      ▼                                                       ▼
observation_n                                      observation réelle_(n+1)
      │
      │ encodage dans le domaine
      ▼
état CarbonWorld_n ─── réponse/réparation Lean ───→ état CarbonWorld_(n+1)
      │                                                       │
      │ export canonique                                     │ projection
      ▼                                                       ▼
simulation Python ────────────────────────────────→ observation prédite_(n+1).
```

Le raccord est accepté si :

```text
Lean produit la dynamique ;
Python lui est exhaustivement conforme ;
l'adaptateur mesure le même observable ;
la prédiction est gelée avant le test ;
les observations réelles satisfont les critères annoncés ;
et les baselines ne suffisent pas à expliquer le résultat revendiqué.
```

Il est rejeté si l'une de ces conditions échoue. Cette possibilité de rejet est
ce qui transforme la simulation issue du cadre en test du modèle plutôt qu'en
illustration.
