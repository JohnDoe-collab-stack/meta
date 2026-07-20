# CARBON_REFERENCE_0 — Autocatalyse chirale sous projection achirale

## 0. Statut et verdict

**Contrat expérimental et formel provisoire — 18 juillet 2026.**

`CARBON_REFERENCE_0`, abrégé `CR0`, désigne une abstraction finie et
traçable d'une réaction d'autocatalyse asymétrique de type Soai. Il s'agit du
premier objet à tenter, pas d'un résultat acquis.

Verdict actuel :

```text
ACQUIS  : trois suppléments primaires sont figés, hashés et audités ;

NO-GO   : les données publiques examinées ne contiennent pas encore un couple
          satisfaisant à la fois l'appariement miroir strict et des futurs
          empiriques disjoints ;

GO      : voie publiée vers les deux énantiomères TMSPyr-OH et passation d'un
          pilote miroir à un laboratoire qualifié ;

NO-GO   : déclaration d'une instance chimique du Core tant que les témoins
          numériques, la transition et les bilans ne sont pas reconstruits ;

NO-GO   : revendication d'évolution, d'autonomie ou de calculabilité générale
          du carbone.
```

Le paquet [CR0-G0](./CR0_G0/README.md) porte les sources, hashes, données
extraites et le [verdict détaillé sur la paire R/S](./CR0_G0/PAIR_SEARCH.md).
Le NO-GO concerne le témoin strict disponible publiquement, pas la réalité de
l'autocatalyse asymétrique.

L'expérience manquante est maintenant cadrée dans la
[préspécification miroir CR0-P](./CR0_G0/CR0_PAIRED_EXPERIMENT_0.md). Une voie
publiée vers les deux énantiomères TMSPyr-OH a été vérifiée, l'horizon et la
marge du pilote ont été figés, et une [passation au
laboratoire](./CR0_G0/LAB_HANDOFF.md) définit la prochaine acquisition. La
confirmation reste bloquée jusqu'à la qualification des lots, la calibration
de l'ee et le calcul de sa taille depuis le pilote.

La réussite minimale de CR0 établirait un niveau A : une référence carbonée
finie reliant projection, indétermination et futurs chimiques distincts. Elle
ne suffirait pas à atteindre la percée de niveau D.

## 1. Objet physique choisi

La famille expérimentale retenue est l'alkylation asymétrique de
pyrimidine- ou pyridine-carbaldéhydes par le diisopropylzinc, facilitée par
l'alcool chiral produit. La littérature primaire établit une amplification de
l'excès énantiomérique et fournit des profils temporels, des mesures par HPLC
chirale et une analyse mécanistique récente.

CR0 ne suppose pas que tout mécanisme proposé soit définitivement établi. Il
emploie seulement des espèces, conditions et réponses qui pourront être
rattachées à une trace ou à une valeur publiée.

Le système expérimental complet comporte trois couches :

```text
P — couche physique : mélange, alimentation, réaction, prélèvement ;
M — couche de mesure : lecture achirale et lecture chirale ;
C — couche de contrôle : calcul du gap, autorisation et registre de trace.
```

La frontière de CR0 inclut `P + M + C`. La réaction carbonée `P` réalise la
transformation ; elle ne réalise pas encore à elle seule toute la détection du
gap. Cette frontière doit accompagner chaque future revendication.

## 2. Revendication minimale visée

La première proposition empirique à rendre calculable est :

> Sous des conditions communes documentées, deux états réactionnels contenant
> la même quantité totale de produit chiral, mais des compositions R/S
> opposées, peuvent produire la même observation achirale et des réponses
> chirales futures séparées après une même alimentation autocatalytique.

Forme logique :

```text
il existe sR et sS tels que

sR ≠ sS
project sR = project sS
intervention sR = intervention sS
responseClass sR ≠ responseClass sS.
```

L'égalité de projection est toujours relative au protocole fixé. CR0 ne dit
pas que `sR` et `sS` sont indiscernables par toute mesure possible : une HPLC
chirale est précisément destinée à les distinguer.

## 3. Ce que CR0 ne revendique pas

Même entièrement réussi, CR0 ne démontrera pas à lui seul :

- le mécanisme complet de toute réaction de Soai ;
- que la matière détecte spontanément notre ignorance expérimentale ;
- qu'un excès énantiomérique est un organisme ou une population ;
- une filiation entre compartiments ou une hérédité reproductrice ;
- une évolution darwinienne ;
- la calculabilité de toute molécule carbonée ;
- une origine expérimentale de l'homochiralité biologique.

## 4. Unité de référence

Une unité CR0 est une condition expérimentale bornée :

```text
un substrat identifié ;
un produit alcool R/S identifié ;
un intervalle de concentrations ;
un protocole d'alimentation ;
une température, un solvant et une atmosphère déclarés ;
un temps initial et un horizon Δt ;
une lecture achirale initiale ;
une lecture chirale finale ;
et une provenance documentaire pour chaque valeur.
```

L'étude mécanistique de 2025 fournit notamment des expériences en toluène
anhydre à température ambiante, ainsi que des séries variant les
concentrations initiales. Ces plages servent de points d'extraction ; elles ne
deviennent des constantes de CR0 qu'après vérification dans les données
sources et transcription avec unités et incertitudes.

## 5. État physique et état fini

### 5.1 État physique conceptuel

L'état utilisé pour interpréter une expérience comprend au minimum :

```text
concentration du substrat carbonylé ;
concentration du réactif organozincique ;
concentration de l'alcool R ;
concentration de l'alcool S ;
intermédiaires explicitement retenus par le modèle ;
température, solvant, atmosphère et volume ;
temps depuis l'alimentation ;
identifiant d'expérience et provenance ;
historique des alimentations et prélèvements.
```

Omettre une variable est permis seulement si une expérience de contrôle ou
une borne démontre qu'elle n'affecte pas la revendication dans le domaine CR0.

### 5.2 Encodage fini visé

Les valeurs physiques réelles ne seront pas transformées silencieusement en
valeurs exactes. L'instance constructive utilisera des intervalles rationnels
ou des classes finies issues du protocole :

```text
CarbonState
  substrate       : ConcentrationInterval
  reagent         : ConcentrationInterval
  productR        : ConcentrationInterval
  productS        : ConcentrationInterval
  intermediates   : finite vector ConcentrationInterval
  condition       : ConditionId
  timeBin         : TimeInterval
  inventory       : AtomInventory
  history         : List InterventionRecord
  provenance      : SourceRecord
```

Chaque intervalle doit conserver : unité, méthode de mesure, erreur, source et
règle d'arrondi. Deux intervalles qui se recouvrent ne sont pas déclarés égaux.
Le schéma devra distinguer :

```text
égalité exacte de l'encodage ;
compatibilité des intervalles ;
et indistinguabilité selon le protocole.
```

## 6. Projection expérimentale

### 6.1 Visible initial proposé

Le visible achiral minimal conserve :

```text
quantité totale de produit = productR + productS ;
quantité de substrat selon une mesure achirale ;
condition expérimentale ;
temps ou fenêtre temporelle ;
identité du protocole de mesure.
```

Il oublie volontairement :

```text
le signe et la magnitude de l'excès énantiomérique ;
la répartition R/S ;
et les intermédiaires non résolus par la mesure choisie.
```

Cette projection est non constante : des quantités totales, substrats,
conditions ou temps distincts doivent donner des visibles distincts.

### 6.2 Collision requise

Le témoin idéal est un couple miroir apparié :

```text
sR.productR = high       sS.productR = low
sR.productS = low        sS.productS = high
sR.total    = T          sS.total    = T
sR.condition = c         sS.condition = c
project sR = v           project sS = v.
```

`high`, `low`, `T`, `c` et `v` devront être remplacés par des valeurs ou
intervalles documentés. Le couple est actuellement **conceptuel** : aucun
témoin numérique n'est déclaré avant extraction ou expérience appariée.

## 7. Gap, usage et intervention

Le gap initial est une fibre visible non résolue :

```text
Compatible(v) = { s | project s = v et s satisfait les contraintes CR0 }
```

Un `GapEvidence(v)` doit porter positivement deux membres distincts et
admissibles de cette fibre. Il ne peut pas reposer sur l'affirmation abstraite
que « la chimie pourrait être différente ».

L'usage autorisé par ce gap est :

```text
appliquer la même alimentation documentée aux deux états compatibles,
puis acquérir une réponse chirale à l'horizon fixé.
```

La même intervention signifie mêmes quantités, ordre d'ajout, durée,
température, solvant, agitation et procédure de prélèvement, dans les tolérances
préenregistrées. Un écart post hoc annule l'appariement.

## 8. Chaîne causale CR0

La chaîne proposée est :

```text
CarbonState
→ project
→ fibre compatible non singleton
→ autorisation d'une alimentation commune
→ transfert physique des réactifs
→ réaction avec l'organisation chirale présente
→ événements ou flux stéréosélectifs
→ nouvelle composition R/S
→ lecture chirale et trace vérifiable.
```

Correspondance avec le Core :

| Core | CR0 |
|---|---|
| `Source` | état réactionnel, conditions et provenance |
| `Visible` | mesure achirale bornée |
| `project` | protocole de lecture achirale |
| `formed` | état enrichi R |
| `shadow` | état enrichi S apparié |
| `GapEvidence` | deux états admissibles dans une même fibre |
| `Use` | droit d'appliquer l'alimentation discriminante |
| `Transport` | ajout physique du substrat et du réactif |
| `Query` | rencontre avec l'alimentation pendant Δt |
| `Response` | classe finie d'événements ou de flux réactionnels |
| `RepairOf` | mise à jour stœchiométrique indexée par la réponse |
| `executeRepair` | calcul de la nouvelle composition |
| `history` | produits persistants, ajouts et prélèvements |

La lecture chirale vérifie la réponse ; elle ne doit pas être utilisée comme
une cible cachée pour choisir la transition.

## 9. Transition constructive

CR0 ne postulera pas une fonction extérieure `next : State → State`. La
forme visée est une réponse typée qui porte les consommations et productions :

```text
ReactionResponse(state, intervention)
  consumed     : finite stoichiometric vector
  produced     : finite stoichiometric vector
  responseBin  : finite kinetic class
  atomProof    : inventory is conserved
  chargeProof  : charge is conserved
  source       : trace or bounded model record
```

puis :

```text
executeRepair(state, response) =
  state - response.consumed + response.produced,
  avec ajout de l'intervention et de la réponse à history.
```

Si plusieurs réponses sont physiquement compatibles avec les incertitudes,
la transition retourne un ensemble fini non vide de successeurs admissibles.
Elle ne choisit pas arbitrairement celui observé. Une prédiction est alors une
classe ou une borne préenregistrée.

Le producteur de réponses et le vérificateur de traces doivent être séparés :

```text
producteur    : état + intervention → réponses prédites ;
expérience    : état + intervention → trace mesurée ;
vérificateur  : trace + réponses prédites → acceptation ou réfutation.
```

Le vérificateur ne reçoit ni le signe attendu, ni l'étiquette `sR/sS`, ni le
successeur choisi par le producteur.

## 10. Hypothèses falsifiables

### CR0-H1 — Collision projective

Deux états R/S appariés distincts satisfont exactement le même encodage
achiral initial.

**Réfutation :** aucun couple ne reste apparié lorsque les erreurs, les
conditions et la provenance sont incluses.

### CR0-H2 — Futur différentiel

Sous une alimentation commune, les classes de réponse chirale après `Δt` sont
disjointes ou séparées par une marge préenregistrée.

**Réfutation :** les intervalles prédits ou mesurés se recouvrent au-delà du
seuil fixé, ou le signe initial n'améliore pas la prédiction du futur.

### CR0-H3 — Dépendance causale

Inverser le signe de l'excès initial, toutes choses appariées, inverse la
classe de réponse ; réduire sa magnitude modifie l'amplification selon une
relation prédéclarée.

**Réfutation :** une variable non contrôlée explique l'effet, ou
l'intervention sur la chiralité ne déplace pas l'aval.

### CR0-H4 — Gain autocatalytique

Dans le domaine fixé, l'état contenant le produit catalytique produit une
réponse distincte du contrôle apparié sans ce produit.

**Réfutation :** une baseline non autocatalytique disposant des mêmes
conditions explique entièrement les traces.

### CR0-H5 — Concordance exécutable

Le producteur fini prédit sur des conditions tenues à l'écart une classe
contenant la trace future, avec le taux de couverture préenregistré.

**Réfutation :** la couverture ou la calibration échoue, ou ne dépasse pas une
baseline visible-seulement de même budget.

## 11. Invariants et contrôles

Chaque transition devra vérifier :

- inventaire des atomes de carbone et des autres éléments retenus ;
- charge formelle et stœchiométrie ;
- ajout, prélèvement et dilution explicitement comptabilisés ;
- domaine de température, solvant et atmosphère ;
- absence de concentration négative ;
- non-vacuité des classes de réponses ;
- séparation entre données d'ajustement et données de test ;
- provenance jusqu'à la figure, table ou fichier source.

Contrôles minimaux :

```text
produit chiral présent / absent ;
excès initial R / S / voisin de zéro ;
alimentation active / contrôle sans alimentation ;
lecture achirale / lecture chirale ;
producteur cinétique / baseline visible-seulement ;
paramètres ajustés / condition tenue à l'écart.
```

## 12. Audit anti-triche actuel

| Exigence | État | Motif |
|---|---|---|
| Domaine carboné réel | GO | famille expérimentale primaire identifiée |
| Projection non constante | PROVISOIRE | définition prête, protocole instrumental à figer |
| Deux états de même visible | OUVERT | construction conceptuelle, témoin numérique absent |
| Futurs séparés sous intervention commune | OUVERT | effet publié, paire appariée CR0 non extraite |
| Gap calculé sans vérité cachée | PARTIEL | fibre calculable par C, pas encore détectée par P seul |
| Réponse issue du milieu | PROVISOIRE | chaîne physique plausible, schéma de trace absent |
| Réparation dérivée de la réponse | OUVERT | type défini, données stœchiométriques à encoder |
| Successeur sans table-cible | OUVERT | producteur fini non construit |
| Conservation auditée | OUVERT | inventaire réactionnel non encodé |
| Prédiction tenue à l'écart | NO-GO | aucune exécution CR0 à ce jour |
| Reproduction et hérédité | NO-GO | hors capacité de ce système isolé |
| Sélection | NO-GO | aucune population de descendants |

Le tableau interdit de transformer la plausibilité en résultat. Le premier
changement de statut doit pointer vers un artefact vérifiable.

## 13. Données à extraire avant tout théorème chimique

Pour chaque trace retenue :

```text
référence bibliographique et identifiant de fichier ;
numéro de figure, panneau, table ou feuille ;
substrat et produit exacts ;
concentrations et unités ;
excès énantiomérique initial avec méthode ;
ordre et temps des ajouts ;
température, solvant, atmosphère et agitation ;
temps d'échantillonnage ;
concentration ou conversion finale ;
excès énantiomérique final ;
réplicat, erreur et règle d'exclusion ;
transformation effectuée lors de la numérisation ;
hash du fichier source local.
```

Une valeur lue sur une figure doit être marquée `digitized`, avec une erreur
de lecture distincte de l'erreur expérimentale. Les données supplémentaires
originales sont préférées aux courbes numérisées.

L'audit initial a trouvé deux cas complémentaires mais insuffisants : les
séries 2025 emploient expérimentalement des alcools initiaux `(1R)` fortement
enrichis sans jumeau `(1S)` apparié ; la série H de 2019 apparie des initiateurs
à `0,10 % R/S`, mais ses réponses finales se recouvrent. Ces cas ne doivent pas
être combinés artificiellement en un seul témoin.

## 14. Porte d'entrée vers Lean

La création d'une instance Lean présentée comme chimique est autorisée
seulement après obtention d'un paquet `CR0-G0` contenant :

1. le schéma d'état fini ;
2. le protocole exact de projection ;
3. un couple numérique apparié `sR/sS` ;
4. l'intervention commune ;
5. les classes de réponse mesurées ;
6. le bilan stœchiométrique ;
7. les fichiers sources et leur provenance ;
8. un jeu de test tenu à l'écart ;
9. les seuils de décision préenregistrés.

Avant `CR0-G0`, un code générique pourrait seulement prouver des propriétés
du schéma abstrait. Il ne devrait pas porter un nom laissant croire que la
chimie de Soai a été certifiée.

Quand cette porte sera franchie, les premiers objets à construire seront :

```text
CarbonState
CarbonVisible
project
Compatible
ChiralFeed
ReactionResponse
executeRepair
CarbonTrace
verifyTrace.
```

Le premier théorème concret devra exhiber le couple apparié et démontrer
constructivement :

```text
sR ≠ sS ∧ project sR = project sS.
```

Le second devra établir que les ensembles finis de réponses prédites sont
séparés selon le critère préenregistré. Toutes les règles constructives et
l'audit d'axiomes du projet s'appliqueront.

## 15. Séquence de travail immédiate

```text
T1 — figer les articles et données supplémentaires utilisés ;
T2 — établir le registre de provenance et le schéma d'extraction ;
T3 — chercher une paire R/S réellement appariée ;
T4 — reconstruire les profils et incertitudes sans ajustement post hoc ;
T5 — décider GO/NO-GO sur CR0-H1 et CR0-H2 ;
T6 — seulement en cas de GO, écrire le producteur fini ;
T7 — construire séparément le vérificateur ;
T8 — réserver un jeu de conditions et préenregistrer les seuils ;
T9 — seulement ensuite, instancier le Core dans Lean.
```

Si T3 échoue dans les données existantes, deux options licites restent
possibles : concevoir une expérience appariée nouvelle, ou basculer le niveau
A vers le réseau bistable de bases de Schiff. Il est interdit de fabriquer un
couple miroir synthétique et de le présenter comme un résultat expérimental.

## 16. Relation avec la cible de percée

CR0 teste le noyau :

```text
même visible actuel
≠ même organisation interne
≠ même possibilité future.
```

La gouttelette de formose devra ensuite porter ce noyau dans une population :

```text
possibilité future
→ croissance ou persistance
→ division
→ transmission d'une organisation
→ différence de fréquence entre descendants.
```

Le passage de CR0 à la formose n'est pas automatique. Il exigera une nouvelle
instance, de nouvelles interventions et une preuve de filiation. CR0 est un
instrument de réduction du risque conceptuel : s'il échoue déjà à relier une
projection commune à des futurs chimiques séparés sans tricher, la
revendication évolutive plus forte doit être suspendue.

## 17. Sources de départ

- [Audit et décision sur les systèmes candidats](./CANDIDATE_SYSTEMS.md)
- [Mechanistic analysis and kinetic profiling of Soai’s asymmetric
  autocatalysis for pyridyl and pyrimidyl substrates, *Nature Communications*
  (2025)](https://www.nature.com/articles/s41467-025-62591-3)
- [Asymmetric autocatalysis and amplification of enantiomeric excess of a
  chiral molecule, *Nature* (1995)](https://www.nature.com/articles/378767a0)
- [Energy threshold for chiral symmetry breaking in molecular
  self-replication, *Nature Chemistry*
  (2019)](https://www.nature.com/articles/s41557-019-0321-y)
