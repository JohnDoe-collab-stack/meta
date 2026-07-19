# Carbone — Fermeture évolutive carbonée constructive

## 0. Statut du document

Ce dossier porte un programme de recherche visant une percée scientifique. Il
ne contient, à ce stade, ni résultat de chimie expérimentale, ni preuve que le
carbone est universellement calculable, ni démonstration de l'origine de la
vie.

Le présent document fixe la cible avant de choisir une chimie particulière ou
de produire des résultats. Toute revendication future devra distinguer :

```text
la structure formelle démontrée ;
le modèle chimique calculé ;
la réalisation physique observée ;
la portée exacte de la généralisation ;
et ce qui demeure ouvert.
```

Le socle formel existant se trouve principalement dans :

```text
Meta/Core/BilateralCore.lean
Meta/Core/ProjectiveCore.lean
Meta/Core/DynamicCore.lean
Meta/Core/DynamicRelaxedUsage.lean
Meta/Semantics/DynamicFoundationalStability.lean
Meta/AI/ActiveSemanticClosure.lean
```

Le programme `Carbone` doit instancier ce socle sans introduire une transition
chimique extérieure déguisée en réparation intrinsèque.

Documents opérationnels :

- [contrat de raccord CarbonWorld au Core](./CARBON_WORLD_BRIDGE.md) ;
- [implémentation constructive CW0-alpha](./CW0/README.md) ;
- [maintenance, débit et complétion de valence CW1-gamma](./CW1/README.md) ;
- [audit des systèmes carbonés candidats](./CANDIDATE_SYSTEMS.md) ;
- [contrat expérimental et formel CARBON_REFERENCE_0](./CARBON_REFERENCE_0.md) ;
- [plan du premier test prédictif tenu à l'écart CARBON_PREDICTION_0](./CARBON_PREDICTION_0.md) ;
- [audit de métadonnées et paquet reproductible CP0-DATA-M0](./CP0/DATASET_AUDIT.md) ;
- [audit des entrées et split bilatéral CP0-DATA-I0](./CP0/INPUT_AUDIT.md) ;
- [protocole de rendement tenu à l'écart CP0-TARGET-0](./CP0/TARGET_PROTOCOL.md) ;
- [écart ontologique à fermer CP0-ONTOLOGY-0](./CP0/ONTOLOGY_GAP.md) ;
- [import canonique et certificat 194/194 CP0-ONTOLOGY-1](./CP0/CANONICAL_IMPORT.md) ;
- [organisation sans cible et certificat 94/94 CP0-ONTOLOGY-2](./CP0/ENVIRONMENT_IMPORT.md) ;
- [contrat du producteur et lecteur de cible gelé CP0-PRODUCER-C0/T2](./CP0/PRODUCER_CONTRACT.md) ;
- [première réfutation numérique CP0-EMPIRICAL-0](./CP0/EMPIRICAL_RESULT_0.md) ;
- [paquet de provenance et verdict CR0-G0](./CR0_G0/README.md) ;
- [passation du premier pilote miroir](./CR0_G0/LAB_HANDOFF.md).

## 1. Cible scientifique

La cible est de construire un système carboné non trivial dont la dynamique
adaptative soit simultanément :

```text
physiquement réalisée ;
causalement calculée ;
constructivement formalisée ;
expérimentalement falsifiable ;
prédictive sur des cas non utilisés pour sa construction ;
et indépendamment reproductible.
```

La revendication centrale recherchée est :

> Une classe explicitement délimitée de systèmes carbonés possède une
> dynamique de fermeture dans laquelle une inadéquation locale détectable
> produit un droit d'interaction, la réponse du milieu produit une réparation
> moléculaire intrinsèque, cette réparation détermine l'état suivant et une
> partie de l'organisation obtenue modifie causalement les possibilités des
> générations suivantes.

La chaîne complète visée est :

```text
organisation carbonée_n
→ projection observable_n
→ gap physico-chimique_n
→ transformation autorisée_n
→ transport ou interrogation_n
→ réponse du milieu_n
→ réparation moléculaire_n
→ organisation carbonée_(n+1)
→ conservation ou reproduction
→ variation héritable
→ sélection.
```

## 2. Sens précis de « rendre le carbone computable »

Le programme distingue deux formes de computation.

### 2.1 Computation externe

Un modèle exécutable calcule, avec un domaine de validité et des erreurs
déclarés :

```text
configuration carbonée + environnement
→ distribution ou ensemble certifié de configurations suivantes.
```

Cette computation décrit le système depuis l'extérieur.

### 2.2 Computation intrinsèque

Le système matériel réalise lui-même une chaîne fonctionnelle :

```text
détection
→ activation sélective
→ interaction
→ transformation
→ mémoire chimique.
```

La computation est alors incarnée par les réactions, les transferts, les
catalyseurs, la compartimentation et la persistance matérielle.

### 2.3 Critère de raccord

La percée exige que les deux descriptions commutent :

```text
système réel_n ───── transformation physique ────→ système réel_(n+1)
     │                                                    │
     │ mesure et encodage                                 │ mesure et encodage
     ▼                                                    ▼
état formel_n ───── exécution de la réparation ───→ état formel_(n+1)
```

Le calcul formel ne doit pas seulement expliquer a posteriori la trajectoire.
Il doit déterminer avant l'observation un résultat, un ensemble de résultats
ou une borne susceptible d'être réfutée.

## 3. Hypothèse structurante

Le carbone est pertinent pour le Core lorsque plusieurs organisations internes
partagent une même projection observable sans partager les mêmes possibilités
futures.

La forme minimale est :

```text
formed ≠ shadow
project formed = project shadow
future formed ≠ future shadow.
```

Les pôles peuvent correspondre, selon l'instance, à :

```text
des isomères ;
des stéréoisomères ;
des états de protonation ;
des organisations supramoléculaires ;
des compositions compartimentales ;
des réseaux catalytiques ayant les mêmes observables grossières ;
ou des histoires chimiques distinctes devenues momentanément indiscernables.
```

L'égalité visible n'est alors ni inutile ni fausse. Elle fournit une
coordination expérimentale réelle, mais ne reconstruit pas toute
l'organisation interne ni son potentiel réactionnel.

## 4. Instanciation formelle recherchée

Une première instance devra définir explicitement les correspondances
suivantes.

| Structure formelle | Réalisation carbonée attendue |
|---|---|
| `Source` | Configuration chimique, environnement local et provenance |
| `Interface` | Organisation moléculaire enrichie |
| `Visible` | Mesures accessibles selon un protocole fixé |
| `project` | Encodage de la mesure expérimentale |
| `Intersection` | Donnée commune typée produite par les lectures bilatérales |
| `formed` | Organisation retenue par la fermeture locale |
| `shadow` | Organisation coordonnée mais intérieurement distincte |
| `GapEvidence` | Désaccord mesuré ou fibre chimiquement sous-déterminée |
| `Use` | Transformation ou interaction autorisée |
| `Transport` | Transfert de matière, d'énergie ou d'information chimique |
| `Query` | Mesure, exposition ou apport sélectif |
| `Response` | Réponse du milieu effectivement obtenue |
| `RepairOf` | Transformation moléculaire indexée par son origine |
| `executeRepair` | Cinétique ou mécanisme produisant l'état suivant |
| `history` | Produits, catalyseurs ou compositions persistantes |
| `CompatibleWithViewHistory` | États chimiques compatibles avec toutes les mesures |

Les types exacts dépendront du premier domaine expérimental. Cette table fixe
la fonction des objets, pas leur implémentation prématurée.

## 5. Endogénéité obligatoire de la transition

Le successeur ne doit jamais être fourni sous la forme d'une trajectoire de
référence ou d'une table extérieure :

```text
next : State → State.
```

Il doit être dérivé de la chaîne causale complète :

```text
next state =
  executeRepair
    state
    (causalStateOfCurrentGap state)
    (repairProducedFromEnvironmentalResponse state).
```

La transition n'est acceptée comme intrinsèque que si :

1. le gap est construit depuis les observations autorisées ;
2. l'usage conserve le gap qui l'a autorisé ;
3. le transport conserve l'usage dont il est issu ;
4. la requête est dérivée du transport ;
5. la réponse vient du milieu et non d'une cible cachée donnée à l'agent ;
6. la réparation est calculée depuis cette réponse ;
7. l'état suivant est exactement l'exécution de cette réparation ;
8. toute donnée historique annoncée est matériellement conservée.

## 6. Invariants physiques minimaux

Chaque transition carbonée certifiée devra porter, selon son niveau de modèle,
des preuves ou des vérifications indépendantes de :

```text
conservation des atomes ;
conservation de la charge ;
respect de la stœchiométrie ;
conditions de température, pression, pH et solvant ;
admissibilité énergétique déclarée ;
admissibilité cinétique déclarée ;
localité des informations utilisées ;
non-vacuité de la fibre compatible ;
traçabilité de la provenance expérimentale ;
et bornes d'erreur des mesures et approximations.
```

Une simulation numérique ne doit jamais être transformée silencieusement en
vérité physique. Les résultats exacts, les calculs approchés, les intervalles
certifiés et les observations empiriques doivent avoir des types ou des
statuts distincts.

## 7. Passage de l'adaptation à l'évolution

Le système AI actuel formalise principalement une adaptation cumulative d'un
agent. Une théorie carbonée de l'évolution exige une couche supplémentaire de
population et de filiation.

Les objets positifs à construire comprennent au minimum :

```text
PopulationState
Compartment
Lineage
DivisionEvent
HeritableComponent
VariationEvent
ReproductionMeasure
DifferentialReproduction
SelectionEnvironment.
```

Quatre propriétés doivent être réalisées ensemble.

### 7.1 Variation

Des organisations ou descendants distincts doivent être effectivement
produits. Une simple incertitude de mesure ne constitue pas une variation.

### 7.2 Hérédité

Une partie identifiable de l'organisation doit être conservée à travers une
division, une réplication ou une propagation matérielle.

### 7.3 Reproduction différentielle

Dans un environnement fixé, les variantes doivent différer par une mesure
positive de persistance, de croissance, de division ou de production de
descendants.

### 7.4 Dépendance causale

Une intervention sur le composant réputé héritable doit modifier la dynamique
des descendants de la manière prédite. Une corrélation entre composition et
croissance ne suffit pas.

## 8. Certificat final visé

Le résultat formel phare pourrait être porté par une structure du type :

```text
CarbonEvolutionCertificate
```

Elle devrait réunir, sans hypothèse terminale extérieure :

```text
un système carboné exécutable ;
une projection expérimentale non constante ;
un gap physiquement réalisé ;
une séparation interne sous projection commune ;
une chaîne causale complète ;
une algèbre de réparations intrinsèques ;
des invariants physiques ;
une mémoire persistante ;
une reproduction matérielle ;
une variation héritable ;
une reproduction différentielle ;
des interventions causales ;
des prédictions préenregistrées ;
et un raccord exact aux traces expérimentales.
```

Un théorème conditionnel disant « si tous ces ponts existent, alors le système
évolue » ne constitue pas la cible. La cible est la construction d'un témoin
concret qui les porte.

## 9. Niveaux de résultat

### Niveau A — Référence carbonée finie

Un domaine borné de molécules ou de compositions est entièrement énuméré et
calculé. Toutes les transitions sont équilibrées, exécutables et raccordées à
Lean.

Ce niveau constitue une preuve de concept formelle, pas encore une percée sur
l'évolution chimique.

### Niveau B — Réseau réactionnel réel certifié

Une expérience chimique réalise la chaîne causale et les traces expérimentales
commutent avec les transitions formelles.

Ce niveau constituerait déjà un résultat interdisciplinaire important.

### Niveau C — Organisation adaptative prédictive

Le système ferme des gaps locaux, conserve ses réparations et réussit des
prédictions préenregistrées sur des conditions ou organisations non utilisées
pour le construire.

Ce niveau pourrait constituer une percée significative.

### Niveau D — Évolution carbonée constructive

La réparation devient un caractère matériellement héritable, produit une
reproduction différentielle et engendre une dynamique de sélection dont les
relations causales sont formellement et expérimentalement établies.

Ce niveau est la cible de percée fondamentale.

## 10. Programme de travail

### Phase 0 — Contrat scientifique

Avant toute expérience de référence :

```text
définir la revendication exacte ;
choisir les observables ;
fixer le domaine chimique ;
définir les interventions ;
définir les baselines ;
fixer les critères de décision ;
et préenregistrer les prédictions.
```

### Phase 1 — Domaine carboné fini

Choisir un réseau suffisamment petit pour permettre :

```text
énumération indépendante ;
équilibrage atomique exact ;
codage constructif ;
projection non constante ;
au moins une fibre visible non triviale ;
plusieurs voies réactionnelles causalement séparées ;
et vérification exhaustive des interventions.
```

### Phase 2 — Jumeau exécutable et vérificateur indépendant

Construire séparément :

```text
un producteur de trajectoires ;
un schéma de traces strict ;
un vérificateur ne réutilisant pas les décisions du producteur ;
une réification Lean des données finies ;
et des tests adversariaux de falsification.
```

### Phase 3 — Boucle chimique active

Réaliser expérimentalement :

```text
mesure
→ détection du gap
→ choix d'interaction
→ réponse chimique
→ réparation
→ nouvelle mesure.
```

Chaque maillon doit être soumis à une intervention qui conserve l'amont et
recalcule l'aval.

### Phase 4 — Compartimentation et transmission

Introduire une organisation permettant croissance, division ou propagation.
Identifier un support matériel de mémoire et mesurer sa transmission aux
descendants.

### Phase 5 — Sélection et prédictions nouvelles

Comparer plusieurs variantes dans des environnements préenregistrés. Prédire
avant l'expérience :

```text
la variante favorisée ;
la condition qui inverse l'avantage ;
la réparation nécessaire ;
la persistance attendue ;
et les cas où le visible échoue à prédire le devenir.
```

### Phase 6 — Réplication indépendante

Publier les protocoles, données brutes, scripts figés, hashes, certificats et
contre-tests nécessaires à une reconstruction externe de la chaîne complète.

## 11. Critères de choix du premier système chimique

Le premier système ne doit pas être choisi pour sa seule proximité narrative
avec l'origine de la vie. Il doit satisfaire des contraintes expérimentales et
formelles :

```text
espèces mesurables ;
cinétiques accessibles ;
interventions locales possibles ;
réactions carbonées clairement identifiées ;
plusieurs organisations sous un visible commun ;
mémoire chimique plausible ;
compartimentation possible à terme ;
et domaine assez petit pour une première certification.
```

Les familles candidates ont fait l'objet d'un
[premier audit](./CANDIDATE_SYSTEMS.md), notamment les réseaux
autocatalytiques carbonés, la chimie combinatoire dynamique et les réseaux
compartimentés. L'autocatalyse asymétrique de Soai est retenue provisoirement
pour la Référence 0 ; les gouttelettes de formose restent la cible évolutive
forte. Cette décision est réversible aux portes GO/NO-GO documentées et ne
déclare encore aucun candidat adéquat pour la percée complète.

## 12. Baselines nécessaires

Le système complet doit être comparé à des classes appariées :

```text
simulateur passif sans interrogation ;
contrôleur dépendant seulement du visible ;
contrôleur actif sans gap typé ;
système avec réparation fournie extérieurement ;
système sans mémoire persistante ;
réseau sans compartimentation ;
et modèle statistique disposant du même budget de mesure.
```

La supériorité empirique ne remplace pas les no-go formels. Inversement, un
no-go sur une classe bornée ne doit pas être présenté comme une impossibilité
de toute architecture concurrente.

## 13. Conditions de falsification

Le programme échoue à atteindre sa cible forte si l'une des situations
suivantes demeure essentielle au résultat :

```text
le gap dépend d'une vérité cachée inaccessible au système ;
la réparation correcte est encodée dans la cible ;
la trajectoire est mémorisée dans une table ;
le successeur est fourni par un ordonnanceur extérieur ;
la fibre compatible est vide ;
les transitions violent ou ignorent les invariants physiques ;
la mémoire disparaît lors de la reproduction ;
les variantes ne présentent aucune reproduction différentielle ;
les interventions ne déplacent pas causalement l'aval ;
les prédictions préenregistrées échouent ;
une baseline appariée explique intégralement le résultat ;
ou la réplication indépendante ne retrouve pas les conclusions.
```

Un échec doit être conservé et publié comme résultat du protocole, sans
modification silencieuse de la cible.

## 14. Discipline des revendications

Même en cas de succès, le programme ne revendiquera pas automatiquement :

```text
la calculabilité universelle de toute chimie carbonée ;
une solution complète au problème de l'origine de la vie ;
une dérivation de toute l'évolution biologique ;
la réduction de la chimie à la logique ;
ni l'absence de stochasticité ou de chaos physique.
```

La revendication devra rester indexée par :

```text
le domaine chimique ;
les observables ;
les conditions expérimentales ;
les approximations ;
les budgets d'interaction ;
les invariants démontrés ;
et la population effectivement étudiée.
```

## 15. Définition opérationnelle de la percée

La cible est atteinte lorsqu'un système carboné réel permet d'établir ensemble :

```text
même visible actuel
≠ même organisation interne
≠ même possibilité future,
```

et que cette différence de possibilité future est :

```text
prédite avant l'expérience ;
produite par une réparation intrinsèque ;
conservée matériellement ;
transmise à des descendants ;
soumise à reproduction différentielle ;
déplacée par intervention causale ;
certifiée constructivement ;
et reproduite indépendamment.
```

À ce niveau, le projet ne serait plus seulement une application de la théorie
à la chimie. Il fournirait un témoin constructif du passage de la matière
carbonée à une histoire évolutive.
