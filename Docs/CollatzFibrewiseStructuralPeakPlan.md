# Pic structurel fibrewise porte par chaque index

## Objet

Ce document fixe la notion de pic structurel fibrewise.

Le point fondamental est que le pic n'est pas cree par Collatz.

Il est deja porte par chaque index de Nat enrichi.

La divergence maximale relaxee ne donne donc pas seulement une valeur positive
locale. Elle equipe chaque index d'un pic structurel propre a sa fibre.

Formule centrale :

```text
pour tout index k :
k
-> divergence maximale relaxee a k
-> pic structurel fibrewise Peak(k)
-> consommateur countdown canonique
-> reinsertion closing/forming
```

Ce pic n'est pas un maximum global de trajectoire. Il est interne a la fibre
portee par l'index `k`.

Ainsi, `fibrewise` ne signifie pas partiel.

Il signifie :

```text
total sur les index,
mais attache fibre par fibre.
```

Le resultat attendu est donc universel au niveau des index :

```text
pour tout k, Peak(k) existe comme structure enrichie consommable.
```

## Pourquoi parler de pic

Dans Nat enrichi, la divergence relaxee maximale est :

```lean
natEnrichedParityMaximalRelaxedDivergence k
```

Elle est :

```text
positive ;
diagonalement certifiee ;
non contractee dans une lecture visible courte ;
consommable par un countdown canonique.
```

Elle represente donc le point de production maximale de la mediation relaxee a
l'index `k`, au sens deja fixe dans `Meta/Arithmetic/Parity.lean` :

```text
maximal = non-contraction maximale interne de la mediation,
pas maximum externe sur une famille ordonnee.
```

On peut l'appeler :

```text
pic structurel fibrewise
```

car :

```text
il est attache a tout index k ;
il est produit par la structure relaxee a k ;
il ne pretend pas borner toutes les trajectoires ;
il donne le sommet local de divergence avant consommation.
```

La donnee fondamentale n'est donc pas :

```text
Collatz produit un pic isole.
```

Elle est :

```text
Nat enrichi porte une structure totale de pics fibrewise :
k |-> Peak(k).
```

Collatz rencontre cette structure lorsqu'il active l'index porte par une
intersection.

## Phase ascendante et exclusion de la contraction

Dans Collatz, la phase ascendante doit etre lue comme l'activation du cote :

```text
mediating/shadow
```

Ce cote ne doit pas etre contracte immediatement en lecture visible courte.

La raison est structurelle :

```text
la phase ascendante est precisement le moment ou la mediation doit rester
relaxee pour que le pic fibrewise de l'index apparaisse.
```

Donc la montee n'est pas d'abord une croissance brute a borner. Elle est :

```text
activation du shadow
-> suspension de la contraction immediate
-> divergence maximale relaxee
-> pic fibrewise Peak(k)
```

La contraction visible courte n'est pas refutee partout. Elle n'est simplement
pas la bonne lecture de la phase ascendante. Si on contracte trop tot, on perd
le pic structurel que la phase ascendante revele.

La reprise se fait ensuite par :

```text
Peak(k)
-> consommateur countdown canonique
-> reinsertion comme closingExcess
-> cote closing/forming
```

Donc le schema complet devient :

```text
phase ascendante :
mediating/shadow
-> non-contraction
-> divergence maximale
-> pic fibrewise

phase de reprise :
pic fibrewise
-> consommation countdown
-> reinsertion closing/forming
```

Phrase cle :

```text
La phase ascendante n'est pas une anomalie a borner ;
elle est le moment ou la contraction visible courte est suspendue afin que
le pic fibrewise de l'index apparaisse.
```

## Difference avec un pic global de trajectoire

Il ne faut pas confondre :

```text
pic structurel fibrewise
```

avec :

```text
hauteur maximale globale d'une trajectoire Collatz.
```

Le pic structurel fibrewise dit :

```text
pour cet index k, la mediation relaxee produit une divergence maximale propre
a cette fibre.
```

Il ne dit pas :

```text
pour une trajectoire complete, aucune valeur ne depasse ce nombre.
```

Donc le pic est total sur les index de Nat enrichi, mais il n'est pas une
hauteur globale de trajectoire ni une borne unique d'orbite numerique.

## Forme Nat enrichi

La definition actuelle donne :

```lean
natEnrichedParityMaximalRelaxedDivergence k
```

et le lemme structurel :

```lean
natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two
```

expose :

```text
pic(k) = k + k + 2
```

Cette forme est importante :

```text
k + k
=
double mediation

+ 2
=
deux poles terminaux consommables par countdown
```

Donc le pic fibrewise est deja dans une forme de consommation :

```text
pic(k) = consumerIndex(k) + 2
```

avec :

```text
consumerIndex(k) = k + k
```

## Forme Collatz

Dans la couche Collatz, pour une intersection :

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

l'index est :

```lean
k = formedPositiveExcessOfIntersection intersection
```

Le pic structurel fibrewise active par Collatz est :

```lean
collatzRelaxedPositiveDiagonalValueOfIntersection intersection
```

et il est egal a :

```lean
natEnrichedParityMaximalRelaxedDivergence k
```

Donc :

```text
Peak(intersection)
=
Peak(k)
=
natEnrichedParityMaximalRelaxedDivergence k.
```

Collatz ne fabrique donc pas le pic. Il instancie le pic deja porte par
l'index `k`.

Le pont countdown montre ensuite :

```text
Peak(intersection)
=
terminal excess du countdown consommateur canonique.
```

La reinsertion montre enfin :

```text
Peak(intersection)
-> closingExcess Peak(intersection)
```

dans le consommateur countdown.

## Theoremes d'exposition du pic structurel

Ces declarations ne sont pas decoratives.

Elles exposent comme objet public une structure deja forcee par les couches
precedentes :

```text
index enrichi
-> divergence maximale relaxee
-> temoin positif de diagonalisation interne
-> forme consommable
-> consommation countdown
-> reinsertion closing/forming
```

Elles ne doivent pas ajouter d'hypothese nouvelle, de producteur externe, ni
reintroduire une lecture classique. Mais elles rendent explicite le resultat
structurel profond : chaque index est deja equipe d'un pic fibrewise
consommable et reinscriptible.

### Emplacement

Les theoremes Nat doivent aller dans :

```text
Meta/Arithmetic/Parity.lean
```

car ils ne parlent que de :

```lean
natEnrichedParityMaximalRelaxedDivergence
```

Les theoremes Collatz doivent aller dans :

```text
Meta/Collatz/CountdownConsumptionBridge.lean
```

car ils utilisent deja :

```lean
collatzRelaxedPositiveDiagonalValueOfIntersection
collatzRelaxedCountdownConsumerIntersection
collatzRelaxedCountdownConsumer_closingRole_eq_positiveDiagonal
```

### Definition lisible du pic Nat

```lean
def natEnrichedParityFibrewiseStructuralPeak
    (k : Nat) :
    Nat :=
  natEnrichedParityMaximalRelaxedDivergence k
```

### Forme de consommation du pic Nat

```lean
theorem natEnrichedParityFibrewiseStructuralPeak_eq_double_add_two
    (k : Nat) :
    natEnrichedParityFibrewiseStructuralPeak k = (k + k) + 2 :=
  natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two k
```

### Definition lisible du pic Collatz

```lean
def collatzFibrewiseStructuralPeak
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  collatzRelaxedPositiveDiagonalValueOfIntersection intersection
```

### Raccord Collatz-Nat

```lean
theorem collatzFibrewiseStructuralPeak_eq_natPeak
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzFibrewiseStructuralPeak intersection =
      natEnrichedParityFibrewiseStructuralPeak
        (formedPositiveExcessOfIntersection intersection) :=
  collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence intersection
```

Lecture :

```text
le pic Collatz n'est pas une nouvelle construction ;
c'est le pic Nat enrichi de l'index forme de l'intersection.
```

### Raccord Collatz-countdown

```lean
theorem collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzFibrewiseStructuralPeak intersection =
      formedPositiveExcessOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) :=
  collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess intersection
```

### Reinsertion du pic

```lean
theorem collatzFibrewiseStructuralPeak_reenters_as_closing
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) =
      NatEnrichedParityRole.closingExcess
        (collatzFibrewiseStructuralPeak intersection) :=
  collatzRelaxedCountdownConsumer_closingRole_eq_positiveDiagonal intersection
```

Ces declarations ne doivent pas ajouter d'hypothese nouvelle si elles sont
definies comme theoremes d'exposition des resultats deja obtenus. Elles servent
a rendre le role du pic explicite, auditable et reutilisable.

## Interdits

Ces theoremes ne doivent pas utiliser :

```text
OddClassical
EvenClassical
natEnrichedParityRoleCode
countdownTerminalMediatingCode
une hauteur globale
une borne de trajectoire
une hypothese de terminaison
```

Ils doivent seulement exposer :

```text
la divergence relaxee maximale ;
le pont Collatz-countdown ;
la reinsertion closing/forming deja prouvee.
```

## Audit attendu

Si les theoremes Nat sont ajoutes a `Meta/Arithmetic/Parity.lean`, mettre a
jour l'unique bloc `AXIOM_AUDIT` final avec :

```lean
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityFibrewiseStructuralPeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityFibrewiseStructuralPeak_eq_double_add_two
```

Si les theoremes Collatz sont ajoutes a
`Meta/Collatz/CountdownConsumptionBridge.lean`, mettre a jour l'unique bloc
`AXIOM_AUDIT` final avec :

```lean
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewiseStructuralPeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewiseStructuralPeak_eq_natPeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewiseStructuralPeak_reenters_as_closing
```

Validation attendue :

```text
lake env lean Meta/Arithmetic/Parity.lean
lake env lean Meta/Collatz/CountdownConsumptionBridge.lean
lake env lean Meta.lean
```

Les audits doivent rester sans axiomes et sans dependance interdite.

## Ce que cela pretend demontrer

Le resultat pretend demontrer :

```text
Nat enrichi porte une structure totale de pics fibrewise ;
pour chaque index k, Peak(k) est donne par la divergence maximale relaxee ;
dans Collatz, chaque intersection rencontre le pic de son index forme ;
ce pic est consommable par countdown ;
ce pic est reinscrit comme role closing/forming.
```

Il ne pretend pas demontrer directement :

```text
un maximum global de trajectoire ;
une borne classique ;
la terminaison numerique de toute orbite.
```

## Importance conceptuelle

Le pic fibrewise change la lecture de la croissance.

Dans le classique, une grande valeur peut apparaitre comme une croissance
libre.

Dans le cadre, la phase ascendante apparait autrement :

```text
elle exclut la contraction immediate ;
elle laisse apparaitre le pic fibrewise porte par l'index ;
elle declenche ensuite son format de consommation.
```

Le pic associe a une activation est :

```text
produit par une divergence relaxee ;
diagonalement certifie ;
consommable par un countdown canonique ;
reinscrit dans le pole forme.
```

Donc la croissance n'est pas l'objet premier. L'objet premier est :

```text
index k deja equipe d'un pic fibrewise
-> activation ascendante sans contraction immediate
-> consommation terminale
-> reinsertion formee.
```

La consequence est forte :

```text
si une dynamique parcourt des index de Nat enrichi,
elle ne traverse jamais des index nus ;
elle traverse des fibres deja equipees d'un pic,
d'un consommateur countdown canonique,
et d'une reinsertion closing/forming.
```

## Formule courte

```text
Chaque index de Nat enrichi porte son propre pic structurel.
Ce pic est total sur les index et fibrewise dans son mode d'attachement.
Dans Collatz, la phase ascendante suspend la contraction et rencontre le pic de
son index.
Ce pic est consomme par countdown et revient comme closingExcess.
```
