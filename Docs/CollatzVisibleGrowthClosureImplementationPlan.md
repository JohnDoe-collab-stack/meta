# Plan d'implementation : fermeture de croissance visible Collatz

## Objet

Ce document prepare l'implementation du raccord manquant entre :

```text
fermeture interne Collatz deja codee
```

et :

```text
controle de la croissance visible Collatz.
```

La cible n'est pas une formulation conditionnelle. La cible est un producteur
intrinseque :

```text
valeur visible Collatz
-> activation interne
-> intersection operationnelle
-> temoin positif diagonal
-> consommation countdown
-> reinsertion closing
-> contrainte visible
```

Il ne doit y avoir aucun champ du type :

```text
si un pont existe
si une fenetre existe
si une hauteur existe
si une borne existe
```

Toute donnee doit etre produite par le cadre.

## Etat actuel du code

### 1. Dynamique visible generique

Le fichier :

```text
Meta/Arithmetic/Trajectory.lean
```

definit deja :

```lean
natTrajectory (step : Nat -> Nat) (start : Nat) : Nat -> Nat
```

et le passage :

```text
collision de trajectoire
-> repeated-index collision
-> closed stability
```

Mais il ne definit pas encore la dynamique visible Collatz specialisee.

### 2. Hauteur visible generique

Le fichier :

```text
Meta/Arithmetic/HeightDiagonal.lean
```

definit :

```lean
NatTrajectoryFinitePrefixHeightCertificate step start
NatTrajectoryPositiveDiagonalHeightWitness cert
NatTrajectoryPostPeakWindow cert
```

Cette couche est generique. Elle part d'un certificat de hauteur de prefixe.
Elle ne produit pas encore une hauteur Collatz depuis la dynamique Collatz.

Donc elle ne doit pas etre utilisee comme producteur aval conditionnel.

### 3. Activation Collatz interne

Le fichier :

```text
Meta/Collatz/OperationalParity.lean
```

instancie deja la diagonale positive relaxee a une intersection Collatz :

```lean
collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
collatzRelaxedDiagonalCertificateOfIntersection
collatzRelaxedProjectionObstructionOfIntersection
collatzRelaxedPositiveDiagonalValueOfIntersection
```

Il prouve notamment :

```lean
collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence
```

Donc, pour une intersection operationnelle Collatz, le temoin positif existe
deja et il est le maximal relaxed divergence a l'index forme.

### 4. Raccord impair relaxe / pas impair visible

Le fichier :

```text
Meta/Collatz/RelaxedOddActionBridge.lean
```

prouve :

```lean
collatzRelaxedOddVisibleStep_eq_two_mul_rightPayload
collatzRelaxedOddVisibleStep_div_two_eq_rightPayload
```

et, pour une intersection :

```lean
collatzRelaxedOddRoleOfIntersection_visibleStep_eq_two_mul_rightPayload
collatzRelaxedOddRoleOfIntersection_visibleStep_div_two_eq_rightPayload
```

Ce raccord dit :

```text
le pas impair visible active un rightPayload relaxe consommable apres /2.
```

Mais ce fichier ne prouve pas encore une contrainte sur une trajectoire visible
complete.

### 5. Consommation et reinsertion internes

Le fichier :

```text
Meta/Collatz/CountdownConsumptionBridge.lean
```

prouve :

```lean
collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess
collatzFibrewiseStructuralPeak_reenters_as_closing
```

Donc le temoin positif diagonal active par Collatz est :

```text
consomme comme terminal excess
```

puis :

```text
reinscrit comme closingExcess.
```

### 6. Boucle interne

Le fichier :

```text
Meta/Collatz/DynamicClosureLoop.lean
```

package :

```lean
CollatzDynamicClosureLoop
```

avec :

```text
positiveWitness
peak
consumer
consumed_as_terminal_excess
reenters_as_closing
```

Le fichier :

```text
Meta/Collatz/InternalTerminality.lean
```

ajoute :

```lean
CollatzInternalTerminality
noCollatzBareNonTerminalActivation
```

Donc le code exclut deja :

```text
une activation nue non consommee
```

dans le regime interne enrichi.

## Diagnostic exact

Le code actuel prouve :

```text
activation Collatz interne
-> temoin positif
-> consommation countdown
-> reinsertion closing
-> prochaine intersection interne
```

Il ne prouve pas encore sous une forme visible-role :

```text
impossibilite d'une croissance mediating nue infinie
dans une trajectoire interne produite par le cadre.
```

La raison est precise :

```text
il manque la donnee interne qui lit une valeur visible `Nat`
comme role enrichi, puis fabrique l'activation mediating quand cette lecture
est mediating.
```

Sans cette facade, la boucle interne reste correcte, mais elle n'est pas encore
exprimee comme impossibilite d'une croissance visible mediating nue.

## Producteur essentiel : visible Nat -> role enrichi

La tache essentielle est ici.

Il faut partir de :

```lean
visible : Nat
```

et produire une lecture interne de role :

```lean
role : NatEnrichedParityRole
```

avec une preuve que le code du role reconstruit exactement la valeur visible :

```lean
natEnrichedParityRoleCode role = visible
```

Ce producteur doit etre total, constructif, et defini par recursion sur `Nat`.
Il ne doit pas utiliser `if`, `Classical`, ni une decision externe de parite.

Forme cible :

```lean
def natEnrichedParityRoleOfVisible :
    Nat -> NatEnrichedParityRole
  | 0 => NatEnrichedParityRole.closingExcess 0
  | 1 => NatEnrichedParityRole.mediatingValue 0
  | Nat.succ (Nat.succ n) =>
      match natEnrichedParityRoleOfVisible n with
      | NatEnrichedParityRole.closingExcess k =>
          NatEnrichedParityRole.closingExcess (k + 1)
      | NatEnrichedParityRole.mediatingValue k =>
          NatEnrichedParityRole.mediatingValue (k + 1)
```

Theoreme cible :

```lean
theorem natEnrichedParityRoleOfVisible_code
    (visible : Nat) :
    natEnrichedParityRoleCode
      (natEnrichedParityRoleOfVisible visible) = visible
```

Ce theoreme donne le producteur manquant :

```text
valeur visible
-> role enrichi interne
-> code du role = valeur visible
```

Il est different de :

```text
IsMediatingCode visible
```

car `IsMediatingCode` est une propriete existentielle. Ici on veut une donnee
calculee par le cadre.

Remarque de forme Lean : le motif recursif doit etre ecrit comme
`Nat.succ (Nat.succ n)`. La notation de papier `n + 2` ne doit pas etre
utilisee comme motif dans le fichier final.

## Branche mediating produite depuis le visible

Une fois le role visible produit, il faut isoler la branche mediating sans
faire de l'impair classique le moteur.

Forme cible :

```lean
structure CollatzVisibleMediatingSource
    (visible : Nat) where
  index : Nat
  role_eq :
    natEnrichedParityRoleOfVisible visible =
      NatEnrichedParityRole.mediatingValue index
  code_eq_visible :
    natEnrichedParityRoleCode
      (NatEnrichedParityRole.mediatingValue index) = visible
```

Constructeur cible depuis une lecture mediating deja produite par
`natEnrichedParityRoleOfVisible` :

```lean
def collatzVisibleMediatingSourceOfRoleEq
    {visible index : Nat}
    (role_eq :
      natEnrichedParityRoleOfVisible visible =
        NatEnrichedParityRole.mediatingValue index) :
    CollatzVisibleMediatingSource visible
```

Ce n'est pas un pont externe. La seule donnee est :

```text
la branche effective du producteur interne `natEnrichedParityRoleOfVisible`.
```

Ensuite, l'activation visible doit partir de cette source :

```lean
structure CollatzVisibleMediatingActivation
    (visible : Nat) where
  source :
    CollatzVisibleMediatingSource visible
  relaxedOdd :
    NatEnrichedRelaxedOddRole source.index
  visibleStep :
    Nat
  visibleStep_eq :
    visibleStep = 3 * visible + 1
  rightPayload :
    Nat
  rightPayload_eq :
    rightPayload = relaxedOdd.rightPayload
  visibleStep_eq_two_mul_rightPayload :
    visibleStep = 2 * rightPayload
  visibleStep_div_two_eq_rightPayload :
    visibleStep / 2 = rightPayload
```

Constructeur cible :

```lean
def collatzVisibleMediatingActivation
    {visible : Nat}
    (source : CollatzVisibleMediatingSource visible) :
    CollatzVisibleMediatingActivation visible
```

Ce constructeur doit utiliser :

```text
source.code_eq_visible
natEnrichedRelaxedOddRole source.index
natEnrichedParityMediatingCode_three_mul_add_one_eq_two_mul_rightPayload
natEnrichedParityMediatingCode_three_mul_add_one_div_two_eq_rightPayload
```

Le point technique exact est :

```text
source.code_eq_visible :
  natEnrichedParityRoleCode (mediatingValue source.index) = visible
```

Les theoremes existants portent d'abord sur :

```text
3 * natEnrichedParityRoleCode (mediatingValue source.index) + 1
```

Il faut donc obtenir les egalites visibles par reecriture avec
`source.code_eq_visible`, puis appliquer les theoremes de `RelaxedOdd`.

Comme `source` depend de `visible`, la reecriture ne doit pas remplacer
`visible` dans tout le but. La preuve Lean doit reecrire seulement le membre
gauche :

```lean
conv_lhs => rw [← source.code_eq_visible]
```

puis appliquer le theoreme relaxe correspondant. Une reecriture globale par
`rw [← source.code_eq_visible]` n'est pas robuste dans ce contexte dependant.

Ainsi, l'activation est bien fabriquee depuis la valeur visible elle-meme :

```text
visible
-> roleOfVisible visible
-> branche mediating
-> index interne
-> relaxedOdd
-> rightPayload
-> Collatz visible step
```

## Producteur total depuis la valeur visible

La cible stricte demande plus que :

```text
visible -> role enrichi
```

et plus que :

```text
si la branche produite est mediating, alors activation mediating.
```

Elle demande aussi plus que :

```text
visible -> role enrichi -> activation relaxee
```

car la fermeture interne deja prouvee dans `Meta/Collatz` depend d'une
intersection :

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

Le vrai producteur doit donc construire, depuis la valeur visible, l'objet
interne suffisant pour entrer dans :

```lean
CollatzDynamicClosureLoop intersection
```

### Verrou de positivite du formed index

Toute intersection porte :

```lean
formedPositiveExcessOfIntersection intersection = intersection.excess + 1
```

Donc son index forme est toujours strictement positif.

Par consequence, la lecture :

```lean
NatEnrichedParityRole.mediatingValue 0
```

qui code la valeur visible :

```text
1
```

ne peut pas produire une intersection dont l'index forme serait `0`.

Ce cas doit etre traite comme terminal visible interne, pas comme activation
de croissance.

La cible correcte est donc :

```text
visible
-> roleOfVisible visible
-> closing branch
   ou terminal mediating zero
   ou nonterminal mediating succ
```

Seule la branche :

```lean
mediatingValue (Nat.succ k)
```

produit une intersection formee et donc une boucle de fermeture.

### Intersection formee produite depuis le visible

Pour une branche mediating non terminale :

```lean
roleOfVisible visible = NatEnrichedParityRole.mediatingValue (Nat.succ k)
```

il faut produire une intersection dont :

```lean
formedPositiveExcessOfIntersection intersection = Nat.succ k
```

Construction cible :

```lean
def collatzVisibleFormedBranch
    (visible : Nat)
    (terminalTime : Nat) :
    MemoryBranch :=
  canonicalBranch visible

def collatzVisibleFormedIntersection
    (visible : Nat)
    (terminalTime : Nat) :
    PrimitiveMemoryReadingIntersection
      (collatzVisibleFormedBranch visible terminalTime) :=
  primitiveMemoryReadingIntersection_of_sharedTrace
    (branch := collatzVisibleFormedBranch visible terminalTime)
    (globalTrace visible)
    rfl
    rfl
    terminalTime
```

Theoreme cible :

```lean
theorem collatzVisibleFormedIntersection_formedPositiveExcess
    (visible terminalTime : Nat) :
    formedPositiveExcessOfIntersection
      (collatzVisibleFormedIntersection visible terminalTime) =
        Nat.succ terminalTime :=
  rfl
```

Ainsi, pour `mediatingValue (Nat.succ k)`, on prend :

```lean
terminalTime := k
```

et l'index forme produit vaut bien :

```text
Nat.succ k
```

### Producteur total corrige

Forme cible :

```lean
inductive CollatzVisibleInternalActivation
    (visible : Nat) where
  | closing
      (index : Nat)
      (role_eq :
        natEnrichedParityRoleOfVisible visible =
          NatEnrichedParityRole.closingExcess index)
      (code_eq_visible :
        natEnrichedParityRoleCode
          (NatEnrichedParityRole.closingExcess index) = visible)
  | terminalOne
      (role_eq :
        natEnrichedParityRoleOfVisible visible =
          NatEnrichedParityRole.mediatingValue 0)
      (code_eq_visible :
        natEnrichedParityRoleCode
          (NatEnrichedParityRole.mediatingValue 0) = visible)
  | mediating
      (terminalTime : Nat)
      (source :
        CollatzVisibleMediatingSource visible)
      (source_index_eq :
        source.index = Nat.succ terminalTime)
      (intersection :
        PrimitiveMemoryReadingIntersection
          (collatzVisibleFormedBranch visible terminalTime))
      (formedIndex_eq :
        formedPositiveExcessOfIntersection intersection =
          source.index)
      (activation :
        CollatzVisibleMediatingActivation visible)
      (closureLoop :
        CollatzDynamicClosureLoop intersection)
```

Constructeur total attendu :

```lean
def collatzVisibleInternalActivation
    (visible : Nat) :
    CollatzVisibleInternalActivation visible :=
  match role_eq :
      natEnrichedParityRoleOfVisible visible with
  | NatEnrichedParityRole.closingExcess index =>
      CollatzVisibleInternalActivation.closing
        index
        role_eq
        (...)
  | NatEnrichedParityRole.mediatingValue 0 =>
      CollatzVisibleInternalActivation.terminalOne
        role_eq
        (...)
  | NatEnrichedParityRole.mediatingValue (Nat.succ terminalTime) =>
      let source :=
        collatzVisibleMediatingSourceOfRoleEq role_eq
      let intersection :=
        collatzVisibleFormedIntersection visible terminalTime
      CollatzVisibleInternalActivation.mediating
        terminalTime
        source
        (...)
        intersection
        (...)
        (collatzVisibleMediatingActivation source)
        (collatzDynamicClosureLoop intersection)
```

Les preuves `code_eq_visible` doivent toutes provenir de :

```lean
natEnrichedParityRoleOfVisible_code visible
```

et de la preuve de branche `role_eq`.

Ce producteur total est le vrai raccord :

```text
visible : Nat
-> roleOfVisible visible
-> closing branch ou mediating branch
-> terminalOne ou formed mediating intersection
-> activation interne correspondante
-> closureLoop quand la branche est mediating non terminale
```

Il n'ajoute pas une hypothese. Il effectue l'elimination constructive du role
calcule par le cadre.

### Theoreme public pour la branche mediating

Une fois le producteur total pose, ajouter une facade qui extrait le cas
mediating non terminal quand le producteur tombe effectivement sur
`mediatingValue (Nat.succ terminalTime)` :

```lean
def collatzVisibleInternalActivation_mediatingSuccOfRoleEq
    {visible terminalTime : Nat}
    (role_eq :
      natEnrichedParityRoleOfVisible visible =
        NatEnrichedParityRole.mediatingValue (Nat.succ terminalTime)) :
    CollatzVisibleMediatingActivation visible :=
  match collatzVisibleInternalActivation visible with
  | CollatzVisibleInternalActivation.mediating _ _ _ _ _ activation _ =>
      activation
  | CollatzVisibleInternalActivation.closing closingIndex closingRoleEq _ =>
      False.elim (...)
  | CollatzVisibleInternalActivation.terminalOne terminalRoleEq _ =>
      False.elim (...)
```

Le cas impossible doit etre ferme par contradiction entre :

```lean
closingExcess closingIndex = mediatingValue index
```

obtenue depuis `closingRoleEq` et `role_eq`, puis par l'injectivite des
constructeurs de `NatEnrichedParityRole`.

Cette facade n'est pas le producteur principal. Le producteur principal reste :

```lean
collatzVisibleInternalActivation visible
```

qui est total.

## Critere strict de cible atteinte

La cible essentielle sera atteinte seulement quand le code prouvera :

```text
pour toute valeur visible,
le cadre calcule un role interne ;
si ce role est mediating zero, la valeur est le terminal visible `1` ;
si ce role est mediating succ, le cadre produit directement :
  - l'index interne,
  - l'intersection formee,
  - l'activation relaxee,
  - le rightPayload,
  - la boucle de fermeture interne.
```

Donc le producteur final attendu n'est pas seulement :

```lean
CollatzVisibleMediatingActivation visible
```

mais :

```lean
CollatzVisibleInternalActivation visible
```

avec une branche mediating non terminale portant :

```lean
CollatzDynamicClosureLoop intersection
```

## Definition cible de la lecture visible

Il faut introduire un fichier :

```text
Meta/Collatz/VisibleRoleDynamics.lean
```

Ce fichier doit definir la lecture visible par roles, sans selection classique
externe. Il ne doit pas definir une fonction totale par :

```text
if even then ... else ...
```

La selection vient du role operationnel deja porte par le cadre. Les deux
lectures visibles sont :

```lean
def collatzVisibleClosingStep (n : Nat) : Nat := n / 2

def collatzVisibleMediatingStep (n : Nat) : Nat := 3 * n + 1
```

Puis la selection ne doit pas etre le moteur du cadre. Elle doit etre une
lecture visible tardive, produite par un role :

```lean
def collatzVisibleStepOfRole
    (role : NatEnrichedParityRole) : Nat :=
  match role with
  | NatEnrichedParityRole.closingExcess k =>
      collatzVisibleClosingStep
        (natEnrichedParityRoleCode (NatEnrichedParityRole.closingExcess k))
  | NatEnrichedParityRole.mediatingValue k =>
      collatzVisibleMediatingStep
        (natEnrichedParityRoleCode (NatEnrichedParityRole.mediatingValue k))
```

Cette definition evite de faire de la parite classique le point d'entree.

## Producteur intrinseque attendu

La structure `CollatzVisibleActivation (k : Nat)` reste utile, mais elle ne
doit plus etre le point de depart principal. Elle devient la forme indexee
interne obtenue apres extraction de l'index depuis la valeur visible.

Il faut produire :

```lean
structure CollatzVisibleActivation (k : Nat) where
  closingRole :
    NatEnrichedParityRole
  closingRole_eq :
    closingRole = NatEnrichedParityRole.closingExcess k
  mediatingRole :
    NatEnrichedParityRole
  mediatingRole_eq :
    mediatingRole = NatEnrichedParityRole.mediatingValue k
  relaxedOdd :
    NatEnrichedRelaxedOddRole k
  visibleSource :
    Nat
  visibleSource_eq :
    visibleSource = natEnrichedParityRoleCode mediatingRole
  visibleStep :
    Nat
  visibleStep_eq :
    visibleStep = collatzVisibleStepOfRole mediatingRole
  rightPayload :
    Nat
  rightPayload_eq :
    rightPayload = relaxedOdd.rightPayload
  visibleStep_eq_two_mul_rightPayload :
    visibleStep = 2 * rightPayload
  visibleStep_div_two_eq_rightPayload :
    visibleStep / 2 = rightPayload
```

Cette structure ne doit contenir aucune hypothese.

Constructeur attendu :

```lean
def collatzVisibleActivation (k : Nat) :
  CollatzVisibleActivation k
```

Il doit etre construit depuis :

```text
NatEnrichedParityRole.mediatingValue k
natEnrichedRelaxedOddRole k
collatzRelaxedOddVisibleStep_eq_two_mul_rightPayload
collatzRelaxedOddVisibleStep_div_two_eq_rightPayload
```

Puis le vrai producteur public doit etre :

```lean
def collatzVisibleActivationOfMediatingSource
    {visible : Nat}
    (source : CollatzVisibleMediatingSource visible) :
    CollatzVisibleActivation source.index
```

et la facade :

```lean
def collatzVisibleMediatingActivationOfSource
    {visible : Nat}
    (source : CollatzVisibleMediatingSource visible) :
    CollatzVisibleMediatingActivation visible
```

## Raccord secondaire : activation depuis une intersection

Cette section ne doit pas etre lue comme le producteur principal de la cible.

Le producteur principal part de :

```lean
visible : Nat
```

et construit lui-meme le cas interne :

```text
closing
ou terminalOne
ou mediating non terminal + intersection + fermeture
```

Le raccord depuis une intersection reste utile seulement comme facade interne
pour reutiliser les theoremes deja codes. Il ne suffit pas a atteindre la cible
stricte, car il suppose deja l'objet operationnel que la cible visible doit
fabriquer.

Le bon index interne est :

```lean
formedPositiveExcessOfIntersection intersection
```

La structure a ajouter est :

Introduire une structure intrinsèque :

```lean
structure CollatzFormedVisibleActivation where
  branch : MemoryBranch
  intersection :
    PrimitiveMemoryReadingIntersection branch
  formedIndex : Nat
  formedIndex_eq :
    formedIndex = formedPositiveExcessOfIntersection intersection
  visibleActivation :
    CollatzVisibleActivation formedIndex
  closureLoop :
    CollatzDynamicClosureLoop intersection
```

Puis fournir un constructeur canonique depuis toute intersection :

```lean
def collatzFormedVisibleActivation
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzFormedVisibleActivation
```

Cette route respecte le code actuel.

Elle transforme toute intersection operationnelle deja portee par le cadre en
activation visible fermee. C'est un raccord interne, pas le producteur visible
total.

Le producteur visible total reste :

```lean
collatzVisibleInternalActivation visible
```

car lui seul part de la valeur visible elle-meme.

## Trajectoire interne produite par le cadre

Pour parler de chaine visible sans producteur externe, il faut d'abord produire
la suite interne d'intersections.

Ajouter :

```lean
abbrev CollatzInternalState :=
  Sigma (fun branch : MemoryBranch =>
    PrimitiveMemoryReadingIntersection branch)

def CollatzInternalState.intersection
    (state : CollatzInternalState) :
    PrimitiveMemoryReadingIntersection state.1 :=
  state.2

def collatzNextInternalState
    (state : CollatzInternalState) :
    CollatzInternalState :=
  match state with
  | Sigma.mk branch intersection =>
      Sigma.mk
        (collatzNextInternalBranch intersection)
        (collatzNextInternalIntersection intersection)

def collatzInternalStateTrajectory
    (state : CollatzInternalState) : Nat -> CollatzInternalState
  | 0 => state
  | t + 1 =>
      collatzNextInternalState
        (collatzInternalStateTrajectory state t)
```

Cette trajectoire est interne. Elle est produite par :

```text
collatzNextInternalIntersection
```

et non par une suite de roles arbitraire.

Ensuite seulement, extraire la lecture visible :

```lean
def collatzInternalStateRole
    (state : CollatzInternalState) :
    NatEnrichedParityRole

def collatzInternalStateVisibleStep
    (state : CollatzInternalState) :
    Nat
```

avec :

```text
role = arithmeticClosingRoleOfIntersection intersection
```

ou, pour l'activation courante :

```text
role = arithmeticMediatingRoleOfIntersection intersection
```

selon la facade visee.

## Verrou dur

Le verrou dur est :

```text
reinserted closingExcess peak
-> role admissible du prochain pas visible.
```

Il faut formaliser :

```lean
def nextRoleOfInternalTerminality
    (terminality : CollatzInternalTerminality intersection) :
    NatEnrichedParityRole :=
  arithmeticClosingRoleOfIntersection terminality.nextIntersection
```

et prouver :

```lean
nextRoleOfInternalTerminality terminality =
  NatEnrichedParityRole.closingExcess
    (collatzDynamicClosureLoop intersection).peak
```

Ce theoreme existe deja sous la forme :

```lean
collatzCurrentPeak_reinserted_in_nextInternalIntersection
```

Il faut maintenant en extraire une facade visible :

```lean
theorem visibleStepOfNextRole_is_closing
```

qui donne :

```text
le prochain role interne est closing,
donc sa lecture visible admissible est la lecture closing.
```

## Consequence visible exacte

La consequence visible immediate n'est pas :

```text
la trajectoire atteint 1
```

ni directement :

```text
la trajectoire est bornee
```

La consequence visible exacte est :

```text
apres activation mediating relaxee,
le prochain role interne force une lecture closing.
```

En notation :

```text
mediating activation
-> rightPayload
-> positiveWitness/peak
-> consumer
-> closingExcess peak
-> next visible reading is closing
```

Le premier theoreme cible doit donc etre :

```lean
theorem collatzInternalTerminality_nextVisibleRole_is_closing
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    nextRoleOfInternalTerminality
      (collatzInternalTerminality intersection) =
      NatEnrichedParityRole.closingExcess
        (collatzDynamicClosureLoop intersection).peak
```

Puis :

```lean
theorem collatzInternalTerminality_nextVisibleStep_eq_div_two
```

qui exprime que la lecture visible du prochain role est la lecture closing.

## Definition finale de croissance visible dans le cadre

La cible finale porte sur la trajectoire interne produite par le cadre, pas sur
une suite externe arbitraire :

```text
f : Nat -> Nat
```

La comparaison visible brute :

```text
f t < f (t + 1)
```

est seulement une lecture externe. Dans ce cadre, une croissance visible
Collatz est une lecture de role :

```text
la branche visible continue a demander le regime mediating.
```

Donc la bonne definition de croissance visible au temps `t` est :

```text
dans la trajectoire interne produite par le cadre,
le prochain role visible est encore mediating.
```

Cette definition demande positivement un role mediating au prochain pas.

### Croissance visible au temps `t`

Ajouter :

```lean
structure CollatzVisibleMediatingGrowthAt
    (state : CollatzInternalState)
    (t : Nat) where
  current :
    CollatzInternalState
  current_eq :
    current = collatzInternalStateTrajectory state t
  nextRole :
    NatEnrichedParityRole
  nextRole_eq :
    nextRole = collatzNextInternalStateRole current
  mediatingIndex :
    Nat
  nextRole_is_mediating :
    nextRole =
      NatEnrichedParityRole.mediatingValue mediatingIndex
```

Cette structure signifie :

```text
au temps interne t, la lecture visible pretend continuer en mediating.
```

Elle ne contient aucun champ conditionnel. Elle est une demande positive de
croissance visible mediating.

### Exclusion locale

Le theoreme local cible est :

```lean
theorem noCollatzVisibleMediatingGrowthAt
    (state : CollatzInternalState)
    (t : Nat) :
    CollatzVisibleMediatingGrowthAt state t -> False
```

Preuve attendue :

1. construire d'abord l'egalite mediating sur `growth.current` :

```lean
have hmedCurrent :
    collatzNextInternalStateRole growth.current =
      NatEnrichedParityRole.mediatingValue growth.mediatingIndex := by
  rw [← growth.nextRole_eq]
  exact growth.nextRole_is_mediating
```

2. ouvrir ensuite `growth.current` avec une equation :

```lean
cases hcurrent : growth.current with
| mk branch intersection => ...
```

3. `collatzNextInternalStateRole current` se deploie en :

```lean
arithmeticClosingRoleOfIntersection
  (collatzNextInternalIntersection intersection)
```

4. appliquer :

```lean
collatzCurrentPeak_reinserted_in_nextInternalIntersection intersection
```

qui donne :

```lean
collatzNextInternalStateRole current =
  NatEnrichedParityRole.closingExcess
    (collatzDynamicClosureLoop intersection).peak
```

5. reecrire `hmedCurrent` par `hcurrent`, puis par l'egalite closing ;
6. fermer par disjonction des constructeurs :

```lean
NatEnrichedParityRole.closingExcess _ ≠
  NatEnrichedParityRole.mediatingValue _
```

ou par `cases` / `noConfusion` sur l'egalite impossible.

Point Lean verifie : construire `hmedCurrent` avant d'ouvrir `current` evite le
probleme de reecriture dependante apres `cases`.

### Croissance visible infinie

Ajouter :

```lean
structure CollatzVisibleInfiniteMediatingGrowth
    (state : CollatzInternalState) where
  growthAt :
    forall t : Nat,
      CollatzVisibleMediatingGrowthAt state t
```

Theoreme final :

```lean
theorem noCollatzVisibleInfiniteMediatingGrowth
    (state : CollatzInternalState) :
    CollatzVisibleInfiniteMediatingGrowth state -> False
```

Preuve :

```lean
intro growth
exact noCollatzVisibleMediatingGrowthAt state 0 (growth.growthAt 0)
```

Ce theoreme est la cible finale de cette partie :

```text
pas de croissance visible infinie
```

au sens strict du cadre :

```text
pas de trajectoire interne produite par le cadre
dont la lecture visible reste mediating a tous les temps.
```

La raison est constructive :

```text
chaque activation mediating non terminale fabrique sa fermeture,
et la fermeture reinscrit le prochain role comme closingExcess.
```

## Implementation proposee

### Nouveau fichier 1

```text
Meta/Collatz/VisibleRoleDynamics.lean
```

Contenu :

```lean
natEnrichedParityRoleOfVisible
natEnrichedParityRoleOfVisible_code
collatzVisibleFormedBranch
collatzVisibleFormedIntersection
collatzVisibleFormedIntersection_formedPositiveExcess
collatzVisibleClosingStep
collatzVisibleMediatingStep
collatzVisibleStepOfRole
collatzVisibleStepOfRole_closing
collatzVisibleStepOfRole_mediating
CollatzVisibleMediatingSource
collatzVisibleMediatingSourceOfRoleEq
CollatzVisibleMediatingActivation
collatzVisibleMediatingActivation
CollatzVisibleActivation
collatzVisibleActivation
CollatzVisibleInternalActivation
collatzVisibleInternalActivation
collatzVisibleInternalActivation_mediatingSuccOfRoleEq
```

Objectif :

```text
definir la lecture visible par roles, sans selection classique externe.
produire l'analyse interne totale de toute valeur visible.
```

### Nouveau fichier 2

```text
Meta/Collatz/InternalStateTrajectory.lean
```

Contenu :

```lean
CollatzInternalState
CollatzInternalState.intersection
collatzNextInternalState
collatzInternalStateTrajectory
collatzInternalStateTrajectory_zero
collatzInternalStateTrajectory_succ
collatzNextInternalStateRole
```

Objectif :

```text
produire la suite interne depuis `collatzNextInternalIntersection`.
```

### Nouveau fichier 3

```text
Meta/Collatz/VisibleClosure.lean
```

Contenu :

```lean
nextRoleOfInternalTerminality
collatzInternalTerminality_nextRole_eq_closing
collatzInternalTerminality_nextVisibleStep_eq_closingStep
CollatzVisibleMediatingGrowthAt
noCollatzVisibleMediatingGrowthAt
CollatzVisibleInfiniteMediatingGrowth
noCollatzVisibleInfiniteMediatingGrowth
```

Objectif :

```text
transformer la reinsertion closing interne en impossibilite d'une croissance
visible mediating infinie.
```

## Ce que l'implementation demontrera

Elle demontrera :

```text
toute activation mediating non terminale produite depuis une valeur visible
fabrique une intersection operationnelle et une boucle de fermeture.
```

Elle demontrera aussi :

```text
cette boucle produit une prochaine lecture visible closing.
```

Elle demontrera aussi :

```text
toute valeur visible possede une analyse interne totale :
closing, terminalOne, ou mediating non terminal.
```

et, dans le cas mediating produit par cette analyse :

```text
la valeur visible fabrique directement l'activation relaxee correspondante
et la boucle de fermeture interne.
```

Elle demontrera enfin :

```text
une trajectoire interne produite par le cadre ne peut pas avoir une lecture
visible mediating a tous les temps.
```

Forme finale Lean :

```lean
theorem noCollatzVisibleInfiniteMediatingGrowth
    (state : CollatzInternalState) :
    CollatzVisibleInfiniteMediatingGrowth state -> False
```

Forme finale en langage du cadre :

```text
pas de croissance visible infinie.
```

Sens exact :

```text
pas de trajectoire interne Collatz dont la lecture visible reste indefiniment
dans le regime mediating.
```

Mecanisme :

```text
mediating non terminal
-> activation relaxee
-> intersection formee
-> boucle de fermeture
-> prochain role closingExcess
-> impossibilite de rester mediating au prochain pas
```

Elle ne pretend pas encore a elle seule :

```text
atteinte de 1
```

car l'atteinte de `1` demande ensuite la lecture terminale du cycle closing.

## Critere de validation

Le travail sera acceptable seulement si :

```text
1. aucun pont conditionnel n'est ajoute ;
2. aucune hauteur visible n'est supposee ;
3. aucune fenetre n'est supposee ;
4. aucune trajectoire externe arbitraire n'est utilisee comme producteur ;
5. toute valeur visible est analysee par `natEnrichedParityRoleOfVisible` ;
6. le cas mediating produit une activation sans hypothese externe ;
7. le role closing suivant est derive de InternalTerminality ;
8. la lecture visible suivante est derivee du role closing ;
9. `noCollatzVisibleMediatingGrowthAt` est prouve sans hypothese externe ;
10. `noCollatzVisibleInfiniteMediatingGrowth` est prouve depuis le cas local ;
11. l'audit Lean ne montre aucun axiome, Classical, propext, Quot.sound.
```
