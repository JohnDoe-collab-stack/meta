# Plan de fermeture dynamique Collatz

## Objet

Ce document fixe le verrou restant pour terminer la partie structurelle
Collatz dans le cadre Meta.

Les couches precedentes ont deja etabli :

```text
index k
-> divergence relaxee maximale
-> pic structurel fibrewise Peak(k)
-> consommation countdown canonique
-> reinsertion comme closing/forming
```

Il reste a exposer la boucle dynamique complete :

```text
activation Collatz pertinente
-> divergence relaxee
-> Peak(k)
-> consommation countdown
-> reinsertion closing/forming
-> role closing/forming reforme dans le meme format operationnel
```

Le but n'est pas d'ajouter une hypothese de terminaison. Le but est de montrer
que l'activation Collatz deja formalisee ne laisse pas une divergence nue hors
du cadre : elle est produite, consommee, puis reinscrite comme
`closingExcess peak`.

## Ce qui est deja prouve

### Nat enrichi

Dans `Meta/Arithmetic/Parity.lean`, pour tout index `k` :

```lean
natEnrichedParityFibrewiseStructuralPeak k
```

est defini par la divergence maximale relaxee :

```lean
natEnrichedParityMaximalRelaxedDivergence k
```

et porte :

```text
positivite ;
DiagonalCertificate core ;
ProjectionObstruction core ;
temoin positif interne ;
forme de consommation (k + k) + 2.
```

La couche pertinente est :

```lean
NatEnrichedParityRelaxedBilateralGap k
NatEnrichedParityPositiveInternalDiagonalWitness k
natEnrichedParityFibrewiseStructuralPeakWitness k
```

### Countdown

Dans `Meta/Arithmetic/CountdownRelaxedParity.lean`, on dispose maintenant du
raccord Nat generique :

```lean
natEnrichedParityFibrewiseStructuralPeak_eq_countdownTerminalExcess
```

Lecture :

```text
pour tout k,
Peak(k)
=
terminal excess du countdown canonique a l'index k + k.
```

Donc la consommabilite n'est pas seulement exposee cote Collatz. Elle est
deja disponible au niveau Nat/countdown.

### Collatz

Dans `Meta/Collatz/OperationalParity.lean`, une intersection :

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

instancie la diagonale relaxee Nat a l'index :

```lean
k = formedPositiveExcessOfIntersection intersection
```

Les declarations centrales sont :

```lean
collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
collatzRelaxedGapOfIntersection
collatzRelaxedDiagonalCertificateOfIntersection
collatzRelaxedProjectionObstructionOfIntersection
collatzRelaxedPositiveDiagonalValueOfIntersection
collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence
```

Dans `Meta/Collatz/CountdownConsumptionBridge.lean`, on a deja :

```lean
collatzRelaxedCountdownConsumerIndex
collatzRelaxedCountdownConsumerIntersection
collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
collatzFibrewiseStructuralPeak
collatzFibrewiseStructuralPeak_eq_natPeak
collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess
collatzFibrewiseStructuralPeak_reenters_as_closing
CollatzFibrewiseStructuralPeakPackage
collatzFibrewiseStructuralPeakPackage
CollatzRelaxedCountdownReinsertion
collatzRelaxedCountdownReinsertion
```

Donc la chaine locale est deja presente :

```text
activation sur intersection
-> temoin positif
-> Peak(k)
-> terminal excess du consommateur countdown
-> closingExcess Peak(k)
```

## Verrou restant

La partie n'est terminee que lorsque cette chaine locale est exposee comme
une fermeture dynamique structurelle.

Le verrou exact est :

```text
il ne doit pas rester une activation Collatz pertinente dont la divergence
relaxee soit produite sans etre consommee et reinscrite dans un etat forme.
```

Dans le code actuel, "activation Collatz pertinente" signifie strictement :

```text
une intersection enrichie sur laquelle la couche
Meta.Collatz.OperationalParity instancie les roles Collatz.
```

Ce n'est pas une quantification sur une orbite numerique externe. C'est une
quantification sur les intersections enrichies du cadre.

Le theoreme attendu doit donc etre total sur ces intersections :

```text
pour toute intersection,
la boucle production -> consommation -> reinsertion -> formation existe.
```

## Fichier cible

Le meilleur emplacement est un nouveau fichier :

```text
Meta/Collatz/DynamicClosureLoop.lean
```

Imports attendus :

```lean
import Meta.Collatz.CountdownConsumptionBridge
```

Ce fichier ne doit pas recreer Nat enrichi, countdown, ni la parite
operationnelle. Il doit seulement exposer la boucle deja portee par leurs
raccords.

Il faudra aussi ajouter l'import dans :

```text
Meta.lean
```

et mettre a jour l'audit final de `Meta.lean`.

## Objet principal a creer

### Structure de boucle

La structure doit regrouper les donnees deja produites, sans hypothese
supplementaire :

```lean
structure CollatzDynamicClosureLoop
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  formedIndex : Nat
  formedIndex_eq :
    formedIndex = formedPositiveExcessOfIntersection intersection
  positiveWitness : Nat
  positiveWitness_eq :
    positiveWitness =
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection
  peak : Nat
  peak_eq :
    peak = collatzFibrewiseStructuralPeak intersection
  positiveWitness_eq_peak :
    positiveWitness = peak
  peak_eq_natPeak :
    peak = natEnrichedParityFibrewiseStructuralPeak formedIndex
  consumer :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision
              (collatzRelaxedCountdownConsumerIndex intersection)))))
  consumer_eq :
    consumer = collatzRelaxedCountdownConsumerIntersection intersection
  consumed_as_terminal_excess :
    peak = formedPositiveExcessOfIntersection consumer
  reenters_as_closing :
    arithmeticClosingRoleOfIntersection consumer =
      NatEnrichedParityRole.closingExcess peak
```

Ce paquet doit etre construit canoniquement :

```lean
def collatzDynamicClosureLoop
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzDynamicClosureLoop intersection
```

### Point technique important

Le champ `consumer` doit etre aligne avec :

```lean
collatzRelaxedCountdownConsumerIntersection intersection
```

Or celui-ci utilise deja :

```lean
collatzRelaxedCountdownConsumerIndex intersection
=
formedPositiveExcessOfIntersection intersection
+
formedPositiveExcessOfIntersection intersection
```

Il faut utiliser directement le type exact deja porte par le consommateur
canonique :

```lean
consumer :
  PrimitiveMemoryReadingIntersection
    (repeatedIndexBranch
      (repeatedIndexCollision_of_trajectoryCollision
        (trajectoryCollision_of_windowCollision
          (countdownTerminalWindowCollision
            (collatzRelaxedCountdownConsumerIndex intersection)))))
consumer_eq :
  consumer = collatzRelaxedCountdownConsumerIntersection intersection
```

Puis exposer separement :

```lean
theorem collatzDynamicClosureLoop_consumerIndex_eq_formedIndex_double
```

Ce choix evite les difficultes de transport de types dependants et garde la
boucle attachee au consommateur deja construit par le cadre.

## Theoremes publics attendus

### 1. Index de boucle

```lean
theorem collatzDynamicClosureLoop_consumerIndex_eq_double_formed
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzRelaxedCountdownConsumerIndex intersection =
      formedPositiveExcessOfIntersection intersection +
        formedPositiveExcessOfIntersection intersection
```

Ce theoreme est probablement `rfl`, mais il doit etre expose pour la lecture.

### 2. Production du pic depuis l'activation

```lean
theorem collatzDynamicClosureLoop_peak_eq_positiveWitness
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzFibrewiseStructuralPeak intersection =
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection
```

Ce theoreme est probablement `rfl`.

### 3. Consommation du pic

Ce fait existe deja :

```lean
collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess
```

Le nouveau fichier peut le reexporter sous un nom de boucle :

```lean
theorem collatzDynamicClosureLoop_peak_consumed
```

### 4. Reinsertion formee

Ce fait existe deja :

```lean
collatzFibrewiseStructuralPeak_reenters_as_closing
```

Le nouveau fichier peut le reexporter sous un nom de boucle :

```lean
theorem collatzDynamicClosureLoop_peak_reenters
```

### 5. Paquet complet

Le paquet principal :

```lean
def collatzDynamicClosureLoop
```

doit contenir ensemble :

```text
formedIndex ;
positiveWitness ;
peak ;
consumer ;
consumption ;
reinsertion.
```

Lecture :

```text
pour toute activation Collatz portee par une intersection,
la divergence positive relaxee active son pic fibrewise,
ce pic est consomme par un countdown canonique,
et ce meme pic revient comme role closing/forming.
```

## Certificat positif de non-fuite structurelle

La bonne forme n'est pas un enonce negatif ajoute apres coup. La bonne forme
est de faire de `CollatzDynamicClosureLoop` lui-meme le certificat positif de
non-fuite structurelle :

```lean
def collatzDynamicClosureLoop
```

puis de nommer explicitement les projections :

```lean
theorem collatzDynamicClosureLoop_consumed_as_terminal_excess
theorem collatzDynamicClosureLoop_reenters_as_closing
```

Ainsi, la non-fuite n'est pas une proposition negative ajoutee. Elle est le
contenu positif du paquet :

```text
il existe canoniquement une boucle de consommation/reinsertion.
```

## Ce que cela demontrera exactement

Le resultat demontrera :

```text
pour toute intersection enrichie activee par Collatz,
la divergence relaxee positive n'est pas une croissance nue ;
elle est identifiee au pic fibrewise de l'index forme ;
ce pic est consomme comme exces terminal d'un countdown canonique ;
ce pic est reinscrit comme role closing/forming.
```

Donc on aura ferme cette partie :

```text
production
-> consommation
-> reinsertion
```

au niveau structurel-operatoire du cadre.

## Ce que cela ne doit pas pretendre

Le fichier ne doit pas pretendre directement :

```text
toute orbite numerique atteint 1 ;
une hauteur globale de trajectoire existe ;
une borne classique est fournie ;
une croissance numerique est majoree par estimation externe.
```

Il doit rester dans le cadre :

```text
intersection enrichie
-> role mediating/shadow
-> divergence relaxee
-> pic fibrewise
-> consommateur countdown
-> role closing/forming.
```

## Interdits stricts

Le fichier ne doit pas utiliser :

```text
OddClassical
EvenClassical
natEnrichedParityRoleCode
countdownTerminalMediatingCode
countdownTerminalClosingCode
2*k+1
hauteur globale
borne de trajectoire
hypothese de terminaison
rank
windowFor
actualReducts
pont terminal externe
theoreme conditionnel
```

Il ne doit pas introduire :

```text
si ce pont existe alors...
si un reducteur existe alors...
si une fenetre existe alors...
```

La boucle doit etre produite directement par les donnees internes deja
presentes.

## Audit Lean attendu

Le nouveau fichier `Meta/Collatz/DynamicClosureLoop.lean` devra finir par un
unique bloc :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDynamicClosureLoop
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop_peak_consumed
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop_peak_reenters
/- AXIOM_AUDIT_END -/
```

Adapter la liste aux noms definitifs, sans placeholder.

Validation attendue :

```text
lake env lean Meta/Collatz/DynamicClosureLoop.lean
lake build Meta.Collatz.DynamicClosureLoop
lake env lean Meta.lean
```

L'audit ne doit afficher aucun axiome et ne doit pas mentionner :

```text
Classical
propext
Quot.sound
```

## Critere de fin de cette partie

Cette partie sera terminee lorsque le code exposera :

```text
pour toute intersection enrichie activee par Collatz,
il existe canoniquement une boucle :

activation
-> temoin positif
-> pic fibrewise
-> consommation countdown
-> reinsertion closing/forming.
```

La phrase finale correcte sera :

```text
Dans le cadre Meta, une activation Collatz pertinente ne produit pas un pic
non consomme : elle produit une divergence relaxee qui est deja prise dans une
boucle structurelle de consommation et de reinsertion.
```

Cette phrase est le resultat attendu de l'implementation.
