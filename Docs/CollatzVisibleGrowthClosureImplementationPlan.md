# Plan d'implementation : cible stricte de croissance visible Collatz

## Objet

Ce document fixe la cible stricte pour la partie "croissance visible Collatz".

La cible n'est pas :

```text
pas de chaine mediating infinie
```

La cible n'est pas :

```text
pas de deux croissances strictes consecutives
```

La cible n'est pas :

```text
une activation interne est consommee
```

La cible stricte est :

```text
pour chaque valeur initiale visible,
la trajectoire visible Collatz produite par le cadre ne peut pas croitre
sans borne.
```

Forme mathematique visee :

```text
pour tout start : Nat,
il existe une borne B : Nat telle que
pour tout temps t : Nat,
visibleTrajectory start t <= B.
```

Forme Lean cible :

```lean
theorem noCollatzVisibleUnboundedGrowth
    (start : Nat) :
    Not (forall B : Nat,
      Exists (fun t : Nat =>
        B < collatzVisibleTrajectory start t))
```

ou, mieux si le cadre fournit directement la borne :

```lean
theorem collatzVisibleTrajectory_bounded
    (start : Nat) :
    Exists (fun B : Nat =>
      forall t : Nat,
        collatzVisibleTrajectory start t <= B)
```

Ces deux formulations sont equivalentes classiquement dans beaucoup de
contextes, mais dans ce projet il faut privilegier la forme constructive avec
producteur de borne :

```text
start -> B(start) -> preuve que B(start) borne toute la trajectoire visible.
```

## Regle de validation

Tout autre resultat vaut echec de la tache.

En particulier, les resultats suivants ne valident pas la cible :

```text
1. pas de croissance strictement monotone a chaque pas ;
2. pas de deux croissances strictes consecutives ;
3. pas de role mediating infini ;
4. pas d'activation nue non consommee ;
5. l'activation mediating produit un rightPayload ;
6. le rightPayload est consommable ;
7. la boucle interne reinscrit un closingExcess ;
8. le prochain role interne est closing ;
9. une trajectoire interne produite par le cadre ne reste pas mediating.
```

Ces enonces peuvent etre utiles comme lemmes intermediaires.
Ils ne doivent jamais etre presentes comme la cible.

Si l'implementation livre seulement l'un de ces resultats, la tache est
echouee.

## Distinction critique

La propriete :

```text
Not (forall t, a_t < a_{t+1})
```

ne prouve pas :

```text
Exists B, forall t, a_t <= B.
```

Une suite peut ne pas croitre strictement a chaque pas et rester non bornee.
Donc la cible "pas de croissance visible infinie" doit etre formalisee comme
absence de fuite non bornee, pas comme absence de croissance stricte pas-a-pas.

La propriete :

```text
pas de role mediating infini
```

ne prouve pas non plus :

```text
pas de croissance visible non bornee.
```

Il faut un theoreme de raccord explicite entre la dynamique des roles internes
et la valeur visible numerique.

## Definition stricte de croissance visible non bornee

Il faut definir la trajectoire visible produite par le cadre :

```lean
def collatzVisibleTrajectory
    (start : Nat) :
    Nat -> Nat
```

Cette trajectoire ne doit pas etre une suite externe arbitraire.
Elle doit etre produite par les definitions internes du cadre.

Ensuite, la fuite visible non bornee doit etre definie par :

```lean
structure CollatzVisibleUnboundedGrowth
    (start : Nat) where
  escapes :
    forall B : Nat,
      Exists (fun t : Nat =>
        B < collatzVisibleTrajectory start t)
```

La cible negative stricte est :

```lean
theorem noCollatzVisibleUnboundedGrowth
    (start : Nat) :
    CollatzVisibleUnboundedGrowth start -> False
```

La cible positive constructive est :

```lean
structure CollatzVisibleBound
    (start : Nat) where
  bound : Nat
  bounds_all :
    forall t : Nat,
      collatzVisibleTrajectory start t <= bound
```

Theoreme public prefere :

```lean
def collatzVisibleBound
    (start : Nat) :
    CollatzVisibleBound start
```

Puis :

```lean
theorem noCollatzVisibleUnboundedGrowth_of_bound
    (start : Nat) :
    CollatzVisibleUnboundedGrowth start -> False
```

## Producteur obligatoire

La preuve doit fournir un producteur interne, pas une hypothese.

Interdit :

```text
si une borne existe alors...
si une hauteur existe alors...
si une fenetre existe alors...
si un pont existe alors...
si une trajectoire est deja fermee alors...
```

Obligatoire :

```text
start
-> trajectoire visible produite par le cadre
-> borne visible produite par le cadre
-> preuve que tous les temps sont sous cette borne.
```

Le point dur est donc :

```text
trouver dans Meta la donnee interne qui fabrique une borne visible numerique
depuis la valeur initiale visible elle-meme.
```

Tant que ce producteur n'est pas trouve, la cible n'est pas atteinte.

## Audit du document

Le document, dans sa forme actuelle, fixe correctement la cible mais ne garantit
pas encore son obtention.

Raison :

```text
il ne fournit pas encore le producteur de borne B(start).
```

Donc ce document ne doit pas etre lu comme une solution. Il doit etre lu comme
un cahier de verification strict.

Pour qu'il devienne un plan d'implementation complet, il faut ajouter un verrou
positif qui transforme la structure interne deja codee en borne visible.

Sans ce verrou, toute implementation restera inferieure a la cible.

Verdict d'audit :

```text
le document n'est pas encore un plan de preuve complet.
```

Il devient utilisable seulement comme plan de preuve lorsque l'une des deux
declarations suivantes est accompagnee d'une route constructive complete :

```lean
def collatzVisibleTrajectoryBound
    (start : Nat) :
    CollatzVisibleTrajectoryBound start
```

ou :

```lean
theorem noCollatzVisibleUnboundedGrowth
    (start : Nat) :
    CollatzVisibleUnboundedGrowth start -> False
```

Toute tentative consistant a nommer une grandeur interne :

```text
peak(start)
height(start)
bound(start)
```

sans prouver :

```lean
forall t : Nat,
  collatzVisibleTrajectory start t <= peak start
```

est une triche conceptuelle et doit etre rejetee.

La prochaine tache mathematique n'est donc pas de coder une facade. Elle est de
trouver ou construire dans le cadre le producteur :

```text
start -> borne visible trajectorielle complete.
```

## Correction : l'enveloppe globale par pas est trop forte

La route suivante est invalide si elle est lue comme une enveloppe stable pour
tous les naturels sous une borne :

```lean
structure CollatzVisibleEnvelope
    (start : Nat) where
  bound : Nat
  start_le_bound :
    start <= bound
  step_closed :
    forall visible : Nat,
      visible <= bound ->
        collatzVisibleStep visible <= bound
```

Raison :

```text
visible <= bound
```

ne signifie pas :

```text
visible est un etat admissible de la trajectoire issue de start.
```

Une borne stable sur tous les naturels sous `bound` demanderait trop :

```text
pour tout visible <= bound,
collatzVisibleStep visible <= bound.
```

Ce n'est pas la cible. La cible porte seulement sur :

```text
les valeurs effectivement produites par la trajectoire visible issue de start.
```

Donc cette enveloppe globale ne doit pas etre implementee. Elle serait une
fausse route.

## Verrou positif requis : enveloppe trajectorielle intrinsèque

La route constructive correcte est une enveloppe trajectorielle, pas une
enveloppe globale sur tous les visibles sous la borne.

Forme Lean cible minimale :

```lean
structure CollatzVisibleTrajectoryBound
    (start : Nat) where
  bound : Nat
  start_le_bound :
    start <= bound
  bounds_all :
    forall t : Nat,
      collatzVisibleTrajectory start t <= bound
```

Cette structure atteint directement la cible si elle est produite par le cadre :

```lean
def collatzVisibleTrajectoryBound
    (start : Nat) :
    CollatzVisibleTrajectoryBound start
```

Elle n'est pas acceptable comme hypothese :

```lean
(bound : CollatzVisibleTrajectoryBound start) -> ...
```

car cela serait exactement :

```text
si une borne existe alors...
```

Une fois `collatzVisibleTrajectoryBound start` construit, la cible suit
immediatement :

```lean
def collatzVisibleBound
    (start : Nat) :
    CollatzVisibleBound start where
  bound := (collatzVisibleTrajectoryBound start).bound
  bounds_all :=
    (collatzVisibleTrajectoryBound start).bounds_all
```

Cette route est valide parce qu'elle prouve directement :

```text
borne produite depuis start
+ preuve directe que tous les temps visibles sont sous cette borne.
```

Elle atteint la cible.

Le verrou dur devient donc :

```text
produire `CollatzVisibleTrajectoryBound start` sans supposer une hauteur,
une fenetre, une borne ou une terminaison externe.
```

Ce verrou n'est pas actuellement resolu par les fichiers Collatz existants.

## Pourquoi les lemmes actuels ne suffisent pas

Les lemmes actuels du dossier `Meta/Collatz` donnent :

```text
activation relaxee
-> rightPayload
-> consommation countdown
-> reinsertion closing
```

Ils ne donnent pas encore :

```text
forall t,
collatzVisibleTrajectory start t <= B(start).
```

Donc ils ne peuvent pas encore produire `CollatzVisibleTrajectoryBound`.

Le verrou exact est :

```text
trouver la grandeur interne qui est :
1. calculee depuis start ;
2. assez grande pour contenir start ;
3. prouvee superieure a toutes les valeurs visibles effectivement produites.
```

Toute grandeur qui ne satisfait pas ces trois points ne ferme pas la cible.

Point important :

```text
une grandeur `peak(start)` definie par formule interne ne suffit pas.
```

Il faut aussi prouver :

```lean
forall t : Nat,
  collatzVisibleTrajectory start t <= peak start
```

Sinon le nom `peak` ou `height` serait seulement decoratif.

## Route alternative : contradiction d'echappement

Une seconde route est possible si l'enveloppe directe est trop forte.

Elle consiste a convertir une fuite visible non bornee en objet interne
impossible.

Forme stricte :

```lean
structure CollatzVisibleEscapeObstruction
    (start : Nat) where
  escape :
    CollatzVisibleUnboundedGrowth start
  internalContradictionCarrier :
    Type
  contradiction :
    internalContradictionCarrier -> False
```

Cette forme est encore trop abstraite si `internalContradictionCarrier` est
choisi librement. La version acceptable doit nommer un objet deja porte par le
cadre, par exemple :

```text
une repetition impossible ;
une collision incompatible ;
une violation d'un ordre diagonal strictement decroissant ;
une impossibilite de reinsertion ;
une incompatibilite entre deux roles produits par le meme index.
```

Forme acceptable :

```lean
def obstructionOfVisibleUnboundedGrowth
    {start : Nat}
    (escape : CollatzVisibleUnboundedGrowth start) :
    KnownInternalImpossibleObject start
```

avec :

```lean
theorem noKnownInternalImpossibleObject
    (start : Nat) :
    KnownInternalImpossibleObject start -> False
```

Cette route atteint la cible seulement si :

```text
escape -> KnownInternalImpossibleObject
```

est construit sans hypothese supplementaire.

## Choix d'implementation impose

L'implementation doit choisir une de ces deux routes :

```text
Route A :
  produire CollatzVisibleTrajectoryBound start
  puis produire CollatzVisibleBound start.

Route B :
  produire une contradiction interne depuis CollatzVisibleUnboundedGrowth start
  puis prouver noCollatzVisibleUnboundedGrowth.
```

Tout autre choix est hors cible.

En particulier, il est interdit de remplacer ces routes par :

```text
pas de mediating infini ;
pas de croissance stricte consecutive ;
pas d'activation nue ;
reinsertion closing ;
rightPayload consommable.
```

Ces resultats peuvent etre des sous-lemmes seulement s'ils participent
explicitement a la production de :

```lean
CollatzVisibleTrajectoryBound start
```

ou de :

```lean
noCollatzVisibleUnboundedGrowth start
```

## Test de non-triche

Avant de valider une implementation, poser les questions suivantes :

```text
1. Existe-t-il dans le code une declaration publique nommee
   `collatzVisibleBound` ou `noCollatzVisibleUnboundedGrowth` ?

2. Cette declaration quantifie-t-elle sur `start : Nat` ?

3. Porte-t-elle sur la trajectoire visible numerique, et pas seulement sur les
   roles internes ?

4. Produit-elle une borne ou refute-t-elle explicitement
   `forall B, exists t, B < trajectory t` ?

5. La preuve part-elle de donnees produites par le cadre, et non d'une borne,
   hauteur, fenetre ou fermeture supposee ?

6. L'audit Lean est-il sans axiome, sans `Classical`, sans `propext`, sans
   `Quot.sound` ?
```

Si une seule reponse est negative, la cible n'est pas atteinte.

## Lien avec les couches existantes

Les couches existantes peuvent servir uniquement si elles sont raccordees a la
borne visible finale.

### Relaxed odd

Les fichiers :

```text
Meta/Arithmetic/RelaxedOdd.lean
Meta/Collatz/RelaxedOddActionBridge.lean
```

prouvent que le pas mediating visible est raccorde au `rightPayload` relaxe.

Cela ne suffit pas.

Il faut encore prouver que l'iteration visible de ces sorties reste bornee.

### Countdown consumption

Le fichier :

```text
Meta/Collatz/CountdownConsumptionBridge.lean
```

prouve que la divergence positive activee est consommee comme terminal excess.

Cela ne suffit pas.

Il faut encore montrer que cette consommation impose une borne sur les valeurs
visibles de toute la trajectoire.

### Internal terminality

Le fichier :

```text
Meta/Collatz/InternalTerminality.lean
```

prouve qu'une activation interne nue est consommee et reinseree.

Cela ne suffit pas.

Il faut encore produire le passage :

```text
consommation interne
-> contrainte numerique visible globale sur la trajectoire.
```

### Diagonal order

Le fichier :

```text
Meta/Collatz/DiagonalOrder.lean
```

calibre un ordre diagonal.

Cela ne suffit pas.

Il faut encore prouver que la trajectoire visible est controlee par une mesure
qui donne une borne effective, pas seulement un ordre ou une calibration.

## Theoreme de raccord obligatoire

Le verrou central a prouver est :

```text
si la trajectoire visible etait non bornee,
alors elle produirait une donnee interne impossible dans le cadre.
```

Mais cette implication ne doit pas etre postulee.
Elle doit etre construite.

Forme cible possible :

```lean
def internalObstructionOfVisibleEscape
    {start : Nat}
    (escape : CollatzVisibleUnboundedGrowth start) :
    InternalImpossibleObject start
```

puis :

```lean
theorem noInternalImpossibleObject
    (start : Nat) :
    InternalImpossibleObject start -> False
```

et enfin :

```lean
theorem noCollatzVisibleUnboundedGrowth
    (start : Nat) :
    CollatzVisibleUnboundedGrowth start -> False := by
  intro escape
  exact noInternalImpossibleObject start
    (internalObstructionOfVisibleEscape escape)
```

Mais cette route est acceptable seulement si `InternalImpossibleObject` est
intrinseque, deja porte par le cadre ou strictement necessaire comme nouvelle
structure positive.

Elle ne doit pas etre une hypothese aval.

## Ce qui doit etre audite avant implementation

Avant de coder, verifier explicitement :

```text
1. quelle est la definition exacte de la trajectoire visible ;
2. quelle valeur visible est lue a chaque temps ;
3. quelle donnee interne correspond a cette valeur visible ;
4. quelle grandeur interne pourrait produire une borne visible ;
5. si cette grandeur est deja portee par Nat enrichi, countdown, diagonal order,
   relaxed odd, OOD ou internal terminality ;
6. si elle n'est pas portee, quelle structure positive intrinsèque est
   mathematiquement legitime ;
7. comment prouver que cette structure borne toutes les valeurs visibles ;
8. comment deduire l'impossibilite de `CollatzVisibleUnboundedGrowth`.
```

Si l'un de ces points manque, l'implementation ne doit pas etre presentee comme
la cible.

## Audit des candidats actuels

Lecture du code existant :

```text
Meta/Arithmetic/HeightDiagonal.lean
Meta/Arithmetic/Window.lean
Meta/Arithmetic/DynamicGap.lean
Meta/Arithmetic/Parity.lean
Meta/Arithmetic/RelaxedOdd.lean
Meta/Collatz/OperationalParity.lean
Meta/Collatz/RelaxedOddActionBridge.lean
Meta/Collatz/CountdownConsumptionBridge.lean
Meta/Collatz/DynamicClosureLoop.lean
Meta/Collatz/DiagonalOrder.lean
```

Verdict :

```text
aucun fichier actuel ne fournit `start -> borne visible trajectorielle`.
```

Detail :

```text
HeightDiagonal :
  part d'un certificat de hauteur deja donne.
  Donc ce n'est pas un producteur de borne Collatz.

Window / FinitePigeonhole :
  transforme une fenetre bornee en collision.
  Donc ce n'est pas un producteur de fenetre bornee.

RelaxedOdd :
  prouve la relation locale entre le code mediating et le rightPayload.
  Donc ce n'est pas une borne trajectorielle.

CountdownConsumptionBridge :
  prouve la consommation locale d'une divergence.
  Donc ce n'est pas une borne trajectorielle.

DynamicClosureLoop :
  package production, consommation et reinsertion locales.
  Donc ce n'est pas une borne trajectorielle.

DiagonalOrder :
  calibre l'ordre diagonal sur les indices.
  Sur les indices nus, cet ordre est extensionnellement l'ordre Nat.
  Donc ce n'est pas une mesure de descente ni une borne.
```

Conclusion :

```text
le code actuel porte des fermetures locales ;
il ne porte pas encore l'invariant trajectoriel global requis.
```

## Invariant trajectoriel requis

Pour que le document devienne capable de supporter la preuve cible, il faut
introduire ou identifier une structure de ce type :

```lean
structure CollatzVisibleTrajectoryInvariant
    (start : Nat) where
  value :
    Nat -> Nat
  visible_le_value :
    forall t : Nat,
      collatzVisibleTrajectory start t <= value t
  value_le_bound :
    forall t : Nat,
      value t <= value 0
```

Alors la borne est immediate :

```lean
def collatzVisibleTrajectoryBoundOfInvariant
    (start : Nat)
    (inv : CollatzVisibleTrajectoryInvariant start) :
    CollatzVisibleTrajectoryBound start where
  bound := inv.value 0
  start_le_bound := by
    -- depuis visible_le_value 0
  bounds_all := by
    intro t
    exact Nat.le_trans (inv.visible_le_value t) (inv.value_le_bound t)
```

Mais cette structure n'est acceptable que si l'on produit :

```lean
def collatzVisibleTrajectoryInvariant
    (start : Nat) :
    CollatzVisibleTrajectoryInvariant start
```

Interdit :

```lean
(inv : CollatzVisibleTrajectoryInvariant start) -> ...
```

car ce serait une hypothese aval.

## Forme plus forte : mesure de descente par blocs

Une route plus informative consiste a produire des blocs dynamiques.

La croissance visible brute peut monter localement. Donc une descente pas a pas
sur la valeur visible n'est pas la bonne forme.

La bonne forme possible est :

```lean
structure CollatzVisibleBlockMeasure
    (start : Nat) where
  blockStart :
    Nat -> Nat
  blockValue :
    Nat -> Nat
  measure :
    Nat -> Nat
  blockValue_eq :
    forall b : Nat,
      blockValue b =
        collatzVisibleTrajectory start (blockStart b)
  block_covers :
    forall t : Nat,
      Exists (fun b : Nat =>
        collatzVisibleTrajectory start t <= measure b)
  measure_le_initial :
    forall b : Nat,
      measure b <= measure 0
```

Cette forme permettrait de borner tous les temps si :

```text
chaque temps est couvert par un bloc ;
chaque bloc est majore par une mesure ;
la mesure des blocs reste sous la mesure initiale.
```

Theoreme cible depuis cette structure :

```lean
def collatzVisibleTrajectoryBoundOfBlockMeasure
    (start : Nat)
    (blocks : CollatzVisibleBlockMeasure start) :
    CollatzVisibleTrajectoryBound start
```

Mais, encore une fois, la cible exige le producteur :

```lean
def collatzVisibleBlockMeasure
    (start : Nat) :
    CollatzVisibleBlockMeasure start
```

## Forme interdite : mesure locale non couvrante

Une mesure locale du type :

```lean
current -> next -> next <= localPeak current
```

ne suffit pas.

Elle doit aussi prouver :

```text
tous les `localPeak current` restent sous une borne calculee depuis `start`.
```

Sinon on obtient seulement :

```text
chaque pas a son pic local.
```

Cela laisse possible une suite de pics locaux strictement croissante.

Donc tout plan qui produit seulement :

```text
localPeak(t)
```

sans preuve :

```text
forall t, localPeak(t) <= B(start)
```

est un echec de la cible.

## Verrou mathematique exact

Le verrou n'est pas :

```text
montrer que 3n+1 est repris par /2.
```

Le verrou est :

```text
montrer que la suite des reprises ne produit pas une suite non bornee de
nouveaux pics visibles.
```

Forme Lean directe :

```lean
theorem collatzVisibleLocalPeaks_bounded
    (start : Nat) :
    Exists (fun B : Nat =>
      forall t : Nat,
        localVisiblePeak start t <= B)
```

puis :

```lean
theorem collatzVisibleTrajectory_le_localPeak
    (start t : Nat) :
    collatzVisibleTrajectory start t <= localVisiblePeak start t
```

Ce couple suffit a produire :

```lean
CollatzVisibleTrajectoryBound start
```

Mais ni `localVisiblePeak`, ni `collatzVisibleLocalPeaks_bounded`, ni le
raccord `trajectory_le_localPeak` n'existent actuellement dans le code.

## Decision d'implementation

Le document supportera strictement l'implementation seulement quand l'une des
trois familles suivantes sera entierement detaillee :

```text
1. producteur direct de `CollatzVisibleTrajectoryBound start` ;
2. producteur de `CollatzVisibleTrajectoryInvariant start` ;
3. producteur de `CollatzVisibleBlockMeasure start`.
```

Dans les trois cas, il faut un producteur depuis `start`.

Le document ne doit pas autoriser une implementation avant d'avoir choisi une
de ces familles et rempli ses champs sans hypothese externe.

## Critere final d'acceptation

La tache est acceptee seulement si le code fournit :

```lean
def collatzVisibleBound
    (start : Nat) :
    CollatzVisibleBound start
```

ou :

```lean
theorem noCollatzVisibleUnboundedGrowth
    (start : Nat) :
    CollatzVisibleUnboundedGrowth start -> False
```

avec une preuve constructive, sans axiome, sans `Classical`, sans `propext`,
sans `Quot.sound`, et sans pont conditionnel.

Tout resultat strictement plus faible vaut echec de la tache.
