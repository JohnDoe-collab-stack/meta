# Concordance hauteur temporelle / hauteur fibrewise

## Objet

Ce document prepare le pont formel entre deux lectures de la hauteur attachee
a un depart Collatz `n`.

Lecture temporelle :

```text
une trajectoire visible part de n ;
une hauteur est lue depuis les valeurs parcourues dans le temps.
```

Lecture Meta :

```text
n initial nomme une fibre ;
la hauteur de cette fibre est deja portee par Nat enrichi :
H(n) = collatzInitialIndexFibreHeight n.
```

Affirmer que ces deux lectures ont la meme signification impose de viser un
theoreme de concordance.

## Point deja etabli

La hauteur fibrewise d'index est maintenant codee dans :

```text
Meta/Collatz/FibrewiseFlightHeight.lean
```

avec :

```lean
collatzInitialIndexFibreHeight n
```

et les faits :

```text
H(n) = natEnrichedParityFibrewiseStructuralPeak n
H(n) = natEnrichedParityMaximalRelaxedDivergence n
H(n) = (n + n) + 2
0 < H(n)
H(n) porte un temoin positif interne de diagonalisation
H(n) est consommee comme terminal excess du countdown canonique a n+n
```

Cette partie ne depend pas d'une trajectoire visible classique.

Elle part de :

```text
n initial = index de fibre
```

## Ce qui manque pour une concordance

Pour comparer avec une hauteur temporelle, il faut d'abord donner une lecture
Meta de la trajectoire visible.

Il ne suffit pas d'ecrire :

```text
temporalHeight = fibrewiseHeight
```

Il faut que la hauteur temporelle soit portee par une structure interne.

La couche generique existe deja dans :

```text
Meta/Arithmetic/HeightDiagonal.lean
```

Elle utilise :

```lean
NatTrajectoryFinitePrefixHeightCertificate step start
```

qui porte :

```lean
horizon : Nat
height : Nat
peakTime : Nat
peak_realizes_height :
  natTrajectory step start peakTime = height
bounds_prefix :
  forall time,
    time <= horizon ->
      natTrajectory step start time <= height
```

Cette structure est la forme temporelle interne correcte.

Elle ne doit pas etre confondue avec la hauteur fibrewise.

## Ancienne forme brute du pont

Une premiere forme possible consiste a porter les deux lectures dans un paquet
parametre par un `step` :

Tant que la representation temporelle Collatz n'est pas encore construite, le
schema doit rester parametre par un `step` donne :

```lean
structure TemporalFibrewiseHeightConcordance
    (step : Nat -> Nat)
    (n : Nat) where
  temporalCert :
    NatTrajectoryFinitePrefixHeightCertificate step n
  fibrewiseHeight : Nat
  fibrewiseHeight_eq :
    fibrewiseHeight = collatzInitialIndexFibreHeight n
  temporalHeight_eq_fibrewiseHeight :
    temporalCert.height = fibrewiseHeight
```

Pour obtenir une concordance Collatz specialisee, il faudra ensuite donner une
representation operationnelle Collatz de ce `step`.

Ce schema est utile comme forme de comparaison abstraite, mais il ne doit pas
etre pris comme cible finale de Collatz. La verification plus bas montre que
l'egalite :

```text
hauteur brute de natTrajectory = hauteur fibrewise H(n)
```

ne peut pas etre exigee pour la trajectoire visible brute.

Or la couche Collatz actuelle ne definit pas encore une trajectoire Collatz
globale par temps. Elle definit une action par regimes :

```lean
collatzParityAction n ParityRegime.left  = n / 2
collatzParityAction n ParityRegime.right = 3 * n + 1
```

Donc il faut choisir l'une des deux routes suivantes.

## Route A : concordance avec une representation temporelle explicite

Cette route introduirait une fonction temporelle operationnelle :

```lean
collatzOperationalTemporalStep : Nat -> Nat
```

Mais elle risque de reintroduire une lecture classique si elle est definie par :

```text
si pair alors n / 2 sinon 3*n+1
```

Cette route est donc dangereuse pour le cadre.

Elle n'est acceptable que si `collatzOperationalTemporalStep` est derive depuis
les roles operationnels deja presents, sans refaire de la parite classique le
point de depart.

Forme attendue :

```text
role operationnel
-> action Collatz
-> trajectoire visible representee
-> certificat temporel
-> concordance avec H(n)
```

## Route B : concordance interne par representation de fibre

Cette route evite de commencer par une fonction temporelle classique.

Elle definit d'abord ce qu'est une fibre Collatz representee dans Meta :

```lean
structure CollatzIndexedFibre (n : Nat) where
  index : Nat
  index_eq_initial : index = n
  height : Nat
  height_eq_fibrewise :
    height = collatzInitialIndexFibreHeight index
  witness :
    NatEnrichedParityPositiveInternalDiagonalWitness index
  witness_eq_height :
    witness.witness = height
```

Puis, seulement si une lecture temporelle interne est disponible, on ajoute :

```lean
structure CollatzIndexedFibreWithTemporalReading
    (step : Nat -> Nat)
    (n : Nat) where
  fibre : CollatzIndexedFibre n
  temporalCert :
    NatTrajectoryFinitePrefixHeightCertificate step n
  temporalHeight_eq_fibreHeight :
    temporalCert.height = fibre.height
```

Cette route respecte mieux le cadre :

```text
index/fibre d'abord ;
lecture temporelle ensuite.
```

## Paquet minimal a viser d'abord

Avant toute trajectoire visible, on peut deja formaliser le paquet fibre :

```lean
structure CollatzInitialIndexedFibreHeightPackage (n : Nat) where
  index : Nat
  index_eq_initial : index = n
  height : Nat
  height_eq :
    height = collatzInitialIndexFibreHeight index
  height_eq_double_add_two :
    height = (index + index) + 2
  witness :
    NatEnrichedParityPositiveInternalDiagonalWitness index
  witness_value_eq_height :
    witness.witness = height
  consumed_as_countdown_terminal_excess :
    height =
      formedPositiveExcessOfIntersection
        (countdownTerminalIntersection (index + index))
```

Ce paquet demontrerait :

```text
la fibre ouverte par n porte deja sa hauteur,
son temoin positif,
et son consommateur countdown canonique.
```

Il ne pretendrait pas encore :

```text
la trajectoire temporelle visible atteint exactement cette hauteur.
```

Mais il donnerait l'objet stable auquel une future lecture temporelle doit se
raccorder.

### Emplacement immediat

Ce paquet doit etre implemente dans :

```text
Meta/Collatz/InitialIndexedFibre.lean
```

Import unique attendu :

```lean
import Meta.Collatz.FibrewiseFlightHeight
```

Il ne doit pas importer :

```text
Meta.Arithmetic.HeightDiagonal
```

car il ne traite pas encore la lecture temporelle.

Il ne doit pas introduire :

```text
collatzStep
collatzOperationalTemporalStep
NatTrajectoryFinitePrefixHeightCertificate
```

car ces objets appartiennent au futur niveau de concordance temporelle.

### Constructeur canonique attendu

Le paquet doit etre construit sans hypothese :

```lean
def collatzInitialIndexedFibreHeightPackage
    (n : Nat) :
    CollatzInitialIndexedFibreHeightPackage n where
  index := n
  index_eq_initial := rfl
  height := collatzInitialIndexFibreHeight n
  height_eq := rfl
  height_eq_double_add_two :=
    collatzInitialIndexFibreHeight_eq_double_add_two n
  witness := collatzInitialIndexFibreHeightWitness n
  witness_value_eq_height :=
    collatzInitialIndexFibreHeightWitness_witness_eq_height n
  consumed_as_countdown_terminal_excess :=
    collatzInitialIndexFibreHeight_eq_countdownTerminalExcess n
```

### Theoremes publics attendus

Le fichier doit exposer au moins :

```lean
theorem collatzInitialIndexedFibre_height_eq
    (n : Nat) :
    (collatzInitialIndexedFibreHeightPackage n).height =
      collatzInitialIndexFibreHeight n
```

```lean
theorem collatzInitialIndexedFibre_height_eq_double_add_two
    (n : Nat) :
    (collatzInitialIndexedFibreHeightPackage n).height =
      (n + n) + 2
```

```lean
theorem collatzInitialIndexedFibre_witness_value_eq_height
    (n : Nat) :
    (collatzInitialIndexedFibreHeightPackage n).witness.witness =
      (collatzInitialIndexedFibreHeightPackage n).height
```

```lean
theorem collatzInitialIndexedFibre_consumed_as_countdown_terminal_excess
    (n : Nat) :
    (collatzInitialIndexedFibreHeightPackage n).height =
      formedPositiveExcessOfIntersection
        (countdownTerminalIntersection (n + n))
```

Ces theoremes ne doivent rien prouver de nouveau mathematiquement.
Ils doivent rendre auditable le fait que la fibre initiale possede deja :

```text
index ;
hauteur ;
temoin positif ;
consommateur countdown.
```

### Audit attendu du paquet fibre

Le fichier doit finir par :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzInitialIndexedFibreHeightPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexedFibreHeightPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexedFibre_height_eq_double_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexedFibre_consumed_as_countdown_terminal_excess
/- AXIOM_AUDIT_END -/
```

Validation :

```text
lake env lean Meta/Collatz/InitialIndexedFibre.lean
lake env lean Meta.lean
```

## Schema brut non final

Une fois une lecture temporelle brute disponible, on peut former le paquet
parametre suivant :

```lean
structure CollatzTemporalFibrewiseHeightConcordance
    (step : Nat -> Nat)
    (n : Nat) where
  fibre :
    CollatzInitialIndexedFibreHeightPackage n
  temporal :
    NatTrajectoryFinitePrefixHeightCertificate step n
  temporal_realizes_fibre_height :
    temporal.height = fibre.height
  temporal_peak_is_fibre_peak :
    natTrajectory step n temporal.peakTime = fibre.height
  temporal_bounds_by_fibre_height :
    forall time,
      time <= temporal.horizon ->
        natTrajectory step n time <= fibre.height
```

Pour specialiser ce schema a Collatz comme simple projection visible, il faudra
ajouter separement une preuve que `step` est la representation operationnelle
visible de Collatz dans le cadre. Cette preuve ne doit pas etre remplacee par
une definition classique naive d'une fonction de transition.

Lecture :

```text
ce paquet compare une hauteur brute et une hauteur fibrewise,
mais il ne constitue pas encore la concordance finale.
```

## Representation temporelle operationnelle

Le point dur n'est pas de poser :

```lean
step : Nat -> Nat
```

Le point dur est de prouver que ce `step` est la representation temporelle
operationnelle de Collatz dans le cadre.

Cette representation doit etre derivee depuis les roles deja presents :

```text
OperationalParityRoles
collatzParityAction
closing/forming
mediating/shadow
```

et non depuis une classification classique primitive :

```text
pair / impair
```

### Fait disponible dans le code

Le code actuel donne deja une action par regime :

```lean
collatzParityAction n ParityRegime.left  = n / 2
collatzParityAction n ParityRegime.right = 3 * n + 1
```

et une lecture de ces regimes depuis une intersection operationnelle :

```lean
arithmeticOperationalParityRolesOfIntersection intersection
```

avec :

```lean
operationalParityRoles_closingRegime
operationalParityRoles_mediatingRegime
```

La couche Collatz expose deja :

```lean
collatzClosingRegime_eq_formedRegime
collatzMediatingRegime_eq_shadowRegime
collatzOperationalParity_sameProjection
collatzOperationalParity_separated
```

Donc le cadre sait deja dire :

```text
le cote closing/forming porte le regime gauche ;
le cote mediating/shadow porte le regime droit ;
les deux regimes ont meme projection visible ;
les deux regimes restent separes dans l'interface enrichie.
```

Ce qui n'existe pas encore est une donnee temporelle canonique qui choisit,
pour chaque etat temporel, quel cote operationnel est actif.

### Predicat manquant exact

Il ne faut pas introduire un paquet faible qui se contente de dire que le step
peut ressembler a l'une des actions. Une telle forme ne choisirait pas
operationnellement le regime actif.

Le predicat manquant doit d'abord etre local a une intersection, parce que les
roles operationnels existants sont produits par une intersection.

Forme locale attendue :

```lean
inductive CollatzIntersectionRegimeEvidence
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ParityRegime -> Type where
  | closing :
      CollatzIntersectionRegimeEvidence intersection
        (operationalParityRoles_closingRegime
          (arithmeticOperationalParityRolesOfIntersection intersection))
  | mediating :
      CollatzIntersectionRegimeEvidence intersection
        (operationalParityRoles_mediatingRegime
          (arithmeticOperationalParityRolesOfIntersection intersection))
```

Lecture :

```text
un regime est admissible seulement s'il est l'un des deux poles deja produits
par l'intersection operationnelle.
```

Cette forme ne parle pas de parite classique. Elle ne dit pas :

```text
si n est pair ;
si n est impair.
```

Elle dit :

```text
le regime vient du pole closing ;
le regime vient du pole mediating.
```

Cette distinction est interne au cadre.

### Action operationnelle locale

Une fois l'evidence locale definie, l'action locale doit etre un paquet
porte par cette evidence :

```lean
structure CollatzOperationalActionAtIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) where
  regime : ParityRegime
  regimeEvidence :
    CollatzIntersectionRegimeEvidence intersection regime
  value : Nat
  value_eq_action :
    value = collatzParityAction n regime
```

Ce paquet ne produit pas encore une trajectoire. Il produit seulement l'action
Collatz lue depuis une activation operationnelle deja portee par le cadre.

Il doit exposer deux constructeurs canoniques :

```lean
def collatzClosingOperationalActionAtIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    CollatzOperationalActionAtIntersection intersection n
```

```lean
def collatzMediatingOperationalActionAtIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    CollatzOperationalActionAtIntersection intersection n
```

avec les lectures publiques :

```lean
theorem collatzClosingOperationalAction_value_eq_div_two
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    (collatzClosingOperationalActionAtIntersection intersection n).value =
      n / 2
```

```lean
theorem collatzMediatingOperationalAction_value_eq_three_mul_add_one
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    (collatzMediatingOperationalActionAtIntersection intersection n).value =
      3 * n + 1
```

Ces deux theoremes sont acceptables parce qu'ils ne definissent pas les regimes
par les formules. Les formules ne sont que les actions attachees a des poles
operationnels deja produits.

### Producteur temporel admissible

La representation temporelle complete doit ensuite porter une selection de
regime issue du cadre :

```lean
structure CollatzOperationalTemporalRepresentation
    (step : Nat -> Nat) where
  branchOf : Nat -> MemoryBranch
  intersectionOf :
    forall n,
      PrimitiveMemoryReadingIntersection (branchOf n)
  regimeOf : forall n, ParityRegime
  regime_is_operational :
    forall n,
      CollatzIntersectionRegimeEvidence
        (intersectionOf n)
        (regimeOf n)
  step_eq_action :
    forall n,
      step n = collatzParityAction n (regimeOf n)
```

Cette structure force le point important :

```text
le step ne choisit pas son regime par un test classique ;
le step choisit un regime certifie par une intersection operationnelle.
```

La donnee `intersectionOf` n'est pas une donnee aval de fermeture. Elle est le
support operationnel qui justifie le regime lu par `step`.

### Obstruction au schema temporel brut

Le schema suivant ne peut pas etre la preuve finale brute :

```lean
def collatzTemporalHeightCertificate
    (n : Nat) :
    NatTrajectoryFinitePrefixHeightCertificate
      collatzOperationalTemporalStep
      n
```

avec :

```lean
(collatzTemporalHeightCertificate n).height =
  collatzInitialIndexFibreHeight n
```

si `natTrajectory` est compris comme une trajectoire de valeurs `Nat` brutes
et si `collatzOperationalTemporalStep` applique seulement, a chaque valeur
visible, l'une des deux actions :

```lean
n / 2
3 * n + 1
```

La raison est formelle.

Pour `n = 2`, la hauteur fibrewise deja prouvee vaut :

```text
H(2) = (2 + 2) + 2 = 6
```

Un certificat temporel brut de hauteur `6` devrait fournir :

```lean
peakTime : Nat
natTrajectory collatzOperationalTemporalStep 2 peakTime = 6
```

et :

```lean
forall time,
  time <= horizon ->
    natTrajectory collatzOperationalTemporalStep 2 time <= 6
```

Or, sous les deux actions brutes disponibles, une trajectoire qui reste sous
`6` depuis `2` ne peut pas atteindre `6` :

```text
2 -> 1        par closing
2 -> 7        par mediating, deja au-dessus de 6
1 -> 0 ou 4
4 -> 2 ou 13
0 -> 0 ou 1
```

La partie bornee reste donc dans :

```text
{0, 1, 2, 4}
```

et ne realise pas `6`.

Conclusion :

```text
la concordance brute
hauteur temporelle Nat = hauteur fibrewise H(n)
n'est pas le bon enonce final.
```

Ce point ne refute pas la hauteur fibrewise. Il refute seulement
l'identification immediate de cette hauteur avec une valeur brute visitee par
`natTrajectory` sur `Nat`.

## Correction du but de concordance

Le resultat final ne doit pas etre une structure conditionnelle du type :

```text
pour tout step, si representation, si certificat, alors concordance.
```

Cette forme peut exister comme schema intermediaire, mais elle ne ferme rien.

Le producteur final attendu doit porter une trajectoire enrichie, pas seulement
une trajectoire brute sur les valeurs visibles.

Forme de l'etat enrichi attendu :

```lean
structure CollatzTemporalFibreState (n : Nat) where
  visible : Nat
  fibre :
    CollatzInitialIndexedFibreHeightPackage n
  activeHeight : Nat
  activeHeight_eq :
    activeHeight = fibre.height
  positiveWitness :
    NatEnrichedParityPositiveInternalDiagonalWitness n
  positiveWitness_eq_activeHeight :
    positiveWitness.witness = activeHeight
```

Le step temporel admissible doit agir sur cet etat enrichi :

```lean
def collatzEnrichedTemporalStep
    (n : Nat) :
    CollatzTemporalFibreState n ->
      CollatzTemporalFibreState n
```

et non comme simple fonction :

```lean
Nat -> Nat
```

L'action visible `n / 2` ou `3*n+1` reste lisible comme projection locale du
step enrichi, mais la hauteur fibrewise reste portee par le champ structurel
`activeHeight`.

Le producteur total corrige devient :

```lean
def collatzInitialTemporalFibreState
    (n : Nat) :
    CollatzTemporalFibreState n
```

```lean
def collatzEnrichedTemporalHeightConcordance
    (n time : Nat) :
    (enrichedTrajectory (collatzEnrichedTemporalStep n)
      (collatzInitialTemporalFibreState n)
      time).activeHeight =
      collatzInitialIndexFibreHeight n
```

Cette concordance est implementable parce qu'elle compare deux lectures du
meme support enrichi :

```text
hauteur portee par l'etat temporel enrichi
=
hauteur fibrewise de l'index initial.
```

Elle ne pretend plus que la valeur visible brute `H(n)` est forcement visitee
par la trajectoire `Nat`.

### Relation avec un step visible brut

Un step visible brut peut encore etre expose, mais seulement comme projection :

```lean
def collatzOperationalTemporalStep :
    Nat -> Nat
```

```lean
def collatzOperationalTemporalRepresentation :
    CollatzOperationalTemporalRepresentation collatzOperationalTemporalStep
```

Cette projection ne porte pas a elle seule la concordance de hauteur.

Un certificat temporel brut peut encore exister comme objet separe :

```lean
def collatzTemporalHeightCertificate
    (n : Nat) :
    NatTrajectoryFinitePrefixHeightCertificate
      collatzOperationalTemporalStep
      n
```

mais il ne doit pas etre exige que sa hauteur soit toujours :

```lean
collatzInitialIndexFibreHeight n
```

Cette egalite est fausse pour le schema brut, comme le cas `n = 2` le montre.

### Obligation du certificat enrichi

Le certificat enrichi doit montrer :

```lean
activeHeight =
  (collatzInitialIndexedFibreHeightPackage n).height
```

et donc :

```lean
activeHeight = collatzInitialIndexFibreHeight n
```

Il doit porter la stabilite du support :

```lean
forall time,
  (enrichedTrajectory (collatzEnrichedTemporalStep n)
      (collatzInitialTemporalFibreState n)
      time).activeHeight =
    collatzInitialIndexFibreHeight n
```

Cette obligation est la concordance forte correcte :

```text
la hauteur portee par la temporalite enrichie est la hauteur fibrewise.
```

### Verrou exact restant

Le document ne doit pas cacher le verrou.

Pour aller jusqu'a la concordance definitive, il faut produire :

```text
un etat temporel enrichi total ;
un step enrichi total ;
un producteur operationnel de regime pour chaque etat ;
une preuve que le support activeHeight est conserve ;
une egalite de hauteur entre le support temporel enrichi et la fibre initiale.
```

En Lean, le verrou se concentre dans :

```lean
def collatzEnrichedTemporalHeightConcordance
    (n time : Nat) :
    (enrichedTrajectory (collatzEnrichedTemporalStep n)
      (collatzInitialTemporalFibreState n)
      time).activeHeight =
      collatzInitialIndexFibreHeight n
```

La production de cette definition sans axiome et sans hypothese ajoutee marque
le passage de la promesse de concordance au theoreme de concordance.

### Critere strict

Une representation temporelle Collatz acceptable devra satisfaire :

```text
1. elle produit un etat temporel enrichi ;
2. elle produit un step enrichi total ;
3. la projection visible du step est lue depuis collatzParityAction ;
4. le regime utilise par step vient des roles operationnels du cadre ;
5. aucune definition de regime ne doit etre une simple recopie de pair/impair
   classique ;
6. le support de hauteur est porte par l'etat enrichi ;
7. ce support est egal a la hauteur fibrewise initiale ;
8. la representation doit etre auditable sans axiome.
```

Tant que ces criteres ne sont pas remplis, la concordance temporelle complete
ne doit pas etre implementee.

## Ce que la concordance definitive demontrera

La concordance definitive demontrera :

```text
la hauteur fibrewise n'est pas seulement une hauteur interne parallele ;
elle concorde avec le support de hauteur porte par la temporalite enrichie
representee dans le cadre.
```

Cela transformerait la phrase :

```text
la hauteur fibrewise joue le meme role que la hauteur temporelle
```

en enonce formel :

```text
la hauteur fibrewise et le support temporel enrichi coincident dans Meta.
```

## Discipline

Ne pas faire :

```text
definir collatzStep par parite classique puis forcer la concordance ;
postuler une hauteur temporelle ;
ajouter une hypothese de terminaison ;
ajouter un producteur externe ;
introduire un si ce pont existe alors...
```

Faire :

```text
partir de l'index/fibre ;
utiliser la hauteur fibrewise deja prouvee ;
representer la lecture temporelle uniquement si elle est derivee du cadre ;
prouver l'egalite des hauteurs seulement quand les deux objets vivent dans le
meme espace formel.
```

## Ordre d'implementation complet

### Etape 1 : paquet fibre pur

Ajouter le paquet fibre pur :

```text
Meta/Collatz/InitialIndexedFibre.lean
```

Dans ce nouveau fichier, importer la facade deja construite :

```text
import Meta.Collatz.FibrewiseFlightHeight
```

Prouver sans condition :

```text
n initial
-> fibre indexee par n
-> hauteur H(n)
-> temoin positif
-> countdown consumer
```

Ajouter l'import dans :

```text
Meta.lean
```

Verifier :

```text
lake env lean Meta/Collatz/InitialIndexedFibre.lean
lake env lean Meta.lean
```

### Etape 2 : evidence de regime operationnel

Ajouter un fichier separe :

```text
Meta/Collatz/OperationalRegimeEvidence.lean
```

Import attendu :

```lean
import Meta.Collatz.OperationalParity
```

Objectif :

```text
intersection operationnelle
-> regime closing ou mediating certifie par le cadre
-> action Collatz attachee a ce regime
```

Declarations principales :

```lean
CollatzIntersectionRegimeEvidence
CollatzOperationalActionAtIntersection
collatzClosingOperationalActionAtIntersection
collatzMediatingOperationalActionAtIntersection
```

Ce fichier doit rester local aux intersections. Il ne doit pas encore produire
une trajectoire temporelle globale.

### Etape 3 : projection visible operationnelle

Ajouter :

```text
Meta/Collatz/OperationalTemporalRepresentation.lean
```

Import attendu :

```lean
import Meta.Collatz.OperationalRegimeEvidence
```

Objectif :

```text
projection visible totale
-> selection operationnelle de regime
-> preuve que step applique collatzParityAction au regime certifie
```

Declarations principales :

```lean
collatzOperationalTemporalStep
CollatzOperationalTemporalRepresentation
collatzOperationalTemporalRepresentation
```

Critere de refus :

```text
si collatzOperationalTemporalStep est defini par un test pair/impair classique,
le fichier est faux pour le cadre.
```

Point de rigueur :

```text
ce fichier ne prouve pas encore la concordance de hauteur.
Il expose seulement la projection visible admissible.
```

### Etape 4 : temporalite enrichie

Ajouter :

```text
Meta/Collatz/EnrichedTemporalState.lean
```

Imports attendus :

```lean
import Meta.Collatz.OperationalTemporalRepresentation
import Meta.Collatz.InitialIndexedFibre
```

Objectif :

```text
porter dans l'etat temporel enrichi :
visible Nat ;
fibre initiale ;
hauteur active ;
temoin positif ;
preuve que la hauteur active est la hauteur fibrewise.
```

Declarations principales :

```lean
enrichedTrajectory
CollatzTemporalFibreState
collatzInitialTemporalFibreState
collatzEnrichedTemporalStep
```

Forme attendue de l'iteration enrichie :

```lean
def enrichedTrajectory
    {State : Type}
    (step : State -> State)
    (start : State) :
    Nat -> State
  | 0 => start
  | t + 1 => step (enrichedTrajectory step start t)
```

Theoremes publics requis :

```lean
theorem collatzInitialTemporalFibreState_activeHeight_eq_fibre
    (n : Nat) :
    (collatzInitialTemporalFibreState n).activeHeight =
      collatzInitialIndexFibreHeight n
```

```lean
theorem collatzEnrichedTemporalStep_preserves_activeHeight
    (n : Nat) :
    (collatzEnrichedTemporalStep n
      (collatzInitialTemporalFibreState n)).activeHeight =
      (collatzInitialTemporalFibreState n).activeHeight
```

Ce fichier ne doit pas importer `Meta.Arithmetic.HeightDiagonal`. Le certificat
a produire ici est enrichi, pas un certificat de maximum brut de trajectoire
sur `Nat`.

### Etape 5 : concordance definitive

Ajouter seulement ensuite :

```text
Meta/Collatz/EnrichedTemporalFibrewiseConcordance.lean
```

Import attendu :

```lean
import Meta.Collatz.EnrichedTemporalState
```

Objectif :

```text
prouver que la hauteur portee par la temporalite enrichie reste la hauteur
fibrewise de l'index initial.
```

Declaration finale attendue :

```lean
def collatzEnrichedTemporalHeightConcordance
    (n time : Nat) :
    (enrichedTrajectory (collatzEnrichedTemporalStep n)
      (collatzInitialTemporalFibreState n)
      time).activeHeight =
      collatzInitialIndexFibreHeight n
```

Cette declaration doit etre totale en `n` et en `time`.

Elle ne doit pas prendre :

```text
temporalCert
heightBound
peakData
terminalBridge
rank
window
actualReducts
```

comme arguments.

### Etape 6 : certificat brut optionnel

Le certificat brut suivant peut exister dans un fichier separe :

```text
Meta/Collatz/VisibleTemporalCertificate.lean
```

mais il ne doit pas pretendre prouver :

```text
hauteur brute = collatzInitialIndexFibreHeight n
```

Son role eventuel serait seulement de decrire une fenetre visible de la
projection `Nat`, pas la concordance de hauteur fibrewise.

### Etape 6 : validation globale

Verifier les fichiers dans cet ordre :

```text
lake env lean Meta/Collatz/InitialIndexedFibre.lean
lake env lean Meta/Collatz/OperationalRegimeEvidence.lean
lake env lean Meta/Collatz/OperationalTemporalRepresentation.lean
lake env lean Meta/Collatz/EnrichedTemporalState.lean
lake env lean Meta/Collatz/EnrichedTemporalFibrewiseConcordance.lean
lake env lean Meta.lean
```

Chaque fichier Lean modifie doit finir par un unique bloc :

```text
AXIOM_AUDIT
```

et l'audit ne doit mentionner aucun axiome, `Classical`, `propext` ou
`Quot.sound`.

## Criteres de completion

Le travail sera complet uniquement quand ces cinq producteurs seront presents
et totaux :

```lean
collatzInitialIndexedFibreHeightPackage
collatzOperationalTemporalStep
collatzOperationalTemporalRepresentation
collatzInitialTemporalFibreState
collatzEnrichedTemporalHeightConcordance
```

Le travail restera incomplet si l'on a seulement :

```text
un paquet fibre sans trajectoire ;
un step pose sans producteur de regime ;
un step sans preuve operationnelle ;
une concordance parametree par un certificat externe ;
une hauteur temporelle posee comme donnee ;
une identification de la hauteur fibrewise avec une valeur brute visitee ;
un pont terminal sous hypothese.
```

## Lecture finale de l'objectif

L'objectif n'est pas de retrouver une hauteur classique par des moyens
classiques.

L'objectif est :

```text
Core / Nat enrichi
-> hauteur fibrewise H(n)
-> etat temporel enrichi
-> step enrichi admissible dans le cadre
-> conservation du support activeHeight
-> activeHeight(n, time) = H_fibrewise(n)
```

Quand cette chaine sera codee, la phrase :

```text
la hauteur fibrewise a la meme signification que la hauteur temporelle
```

sera remplacee par :

```text
le support de hauteur porte par la temporalite enrichie produite dans Meta
concorde avec la hauteur fibrewise initiale.
```

## Formule courte

```text
La concordance n'est pas une identification verbale.
Elle doit devenir un theoreme reliant deux objets :

1. la hauteur fibrewise deja produite par l'index ;
2. le support de hauteur porte par la temporalite enrichie representee dans
   Meta.
```
