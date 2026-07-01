# Collatz internal terminality closure plan

## Objet

Ce document fixe la prochaine couche a exposer autour de Collatz dans le cadre
Meta.

La cible n'est pas une reformulation classique de la conjecture de Collatz.
La cible est la fermeture interne suivante :

```text
reinsertion closing
-> prochain etat interne
-> iteration typable de la boucle
-> aucune activation relaxee nue
-> terminalite interne de la divergence produite
```

Le point central est que le code porte deja la majeure partie de cette chaine.
Il manque surtout une facade finale qui la rende explicite, auditable, et
impossible a confondre avec une affirmation externe sur une trajectoire
visible.

## Interdits de lecture

Le fichier a implementer ne doit pas introduire :

```text
borne globale visible
hauteur de vol classique
preuve orbitale classique
nouvelle donnee aval
pont conditionnel externe
```

Il ne doit pas dire :

```text
si un prochain etat existe, alors...
si une consommation terminale existe, alors...
si une fermeture existe, alors...
```

Le prochain etat interne doit etre produit par le cadre lui-meme.

## Etat actuel du code

### 1. Le consumer est deja le prochain etat interne

Dans :

```text
Meta/Collatz/CountdownConsumptionBridge.lean
```

on a :

```lean
def collatzRelaxedCountdownConsumerIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision
              (collatzRelaxedCountdownConsumerIndex intersection))))) :=
  countdownTerminalIntersection
    (collatzRelaxedCountdownConsumerIndex intersection)
```

Ce point est decisive.

Le consumer n'est pas une valeur numerique aval. C'est deja une nouvelle
`PrimitiveMemoryReadingIntersection`.

Donc il peut servir de prochain etat interne de la boucle.

### 2. La divergence est consommee comme terminal excess

Dans :

```text
Meta/Collatz/CountdownConsumptionBridge.lean
```

on a :

```lean
theorem collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
```

et :

```lean
theorem collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess
```

Lecture interne :

```text
la valeur diagonale positive activee par l'intersection
=
l'exces terminal du consumer countdown canonique
```

Il n'y a donc pas de divergence relaxee nue au niveau de cette activation.

### 3. La divergence revient comme closing/forming

Dans :

```text
Meta/Collatz/CountdownConsumptionBridge.lean
```

on a :

```lean
theorem collatzFibrewiseStructuralPeak_reenters_as_closing
```

Lecture interne :

```text
le pic consomme par countdown
revient comme closingExcess du consumer
```

Donc l'exces n'est pas seulement absorbe. Il est reinscrit dans le role
forming/closing du cadre.

### 4. La boucle est deja packagee

Dans :

```text
Meta/Collatz/DynamicClosureLoop.lean
```

on a :

```lean
structure CollatzDynamicClosureLoop
```

avec les champs essentiels :

```lean
consumer :
  PrimitiveMemoryReadingIntersection
    (repeatedIndexBranch
      (repeatedIndexCollision_of_trajectoryCollision
        (trajectoryCollision_of_windowCollision
          (countdownTerminalWindowCollision
            (collatzRelaxedCountdownConsumerIndex intersection)))))

consumed_as_terminal_excess :
  peak = formedPositiveExcessOfIntersection consumer

reenters_as_closing :
  arithmeticClosingRoleOfIntersection consumer =
    NatEnrichedParityRole.closingExcess peak
```

Lecture interne :

```text
intersection
-> peak positif
-> consumer interne
-> consommation terminale
-> reinsertion closing
```

## Ce qui manque

Il manque une couche de facade qui nomme explicitement ce que le code porte
deja.

Nom propose :

```text
Meta/Collatz/InternalTerminality.lean
```

ou :

```text
Meta/Collatz/InternalClosureTerminality.lean
```

Objectif du fichier :

```text
1. nommer le prochain etat interne ;
2. montrer que ce prochain etat est reactivable dans le meme cadre ;
3. exposer la terminalite interne de l'activation courante ;
4. formuler l'impossibilite d'une activation relaxee nue non consommee.
```

## Definitions attendues

### 1. Prochain etat interne

Pour eviter tout type implicite flou, on nomme d'abord la branche du prochain
etat interne :

```lean
abbrev collatzNextInternalBranch
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    MemoryBranch :=
  repeatedIndexBranch
    (repeatedIndexCollision_of_trajectoryCollision
      (trajectoryCollision_of_windowCollision
        (countdownTerminalWindowCollision
          (collatzRelaxedCountdownConsumerIndex intersection))))
```

Puis on extrait l'intersection suivante :

```lean
def collatzNextInternalIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    PrimitiveMemoryReadingIntersection
      (collatzNextInternalBranch intersection) :=
  (collatzDynamicClosureLoop intersection).consumer
```

Lecture :

```text
le prochain etat interne est le consumer canonique produit par la boucle
```

Ce n'est pas une hypothese. C'est une extraction directe du paquet deja
construit.

### 2. Boucle suivante typable

```lean
def collatzNextDynamicClosureLoop
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :=
  collatzDynamicClosureLoop
    (collatzNextInternalIntersection intersection)
```

Lecture :

```text
le consumer est du bon type pour relancer la meme construction
```

Cela expose l'iteration typable.

La boucle n'est pas encore une recursion globale. Elle est une stabilite de
type :

```text
sortie interne de la boucle
:
entree valide de la meme boucle
```

### 3. Certificat de terminalite interne de l'activation

Structure attendue :

```lean
structure CollatzInternalTerminality
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  currentLoop :
    CollatzDynamicClosureLoop intersection
  nextIntersection :
    PrimitiveMemoryReadingIntersection
      (collatzNextInternalBranch intersection)
  next_eq_consumer :
    nextIntersection =
      (collatzDynamicClosureLoop intersection).consumer
  consumed :
    (collatzDynamicClosureLoop intersection).peak =
      formedPositiveExcessOfIntersection nextIntersection
  reinserted :
    arithmeticClosingRoleOfIntersection nextIntersection =
      NatEnrichedParityRole.closingExcess
        (collatzDynamicClosureLoop intersection).peak
  nextLoop :
    CollatzDynamicClosureLoop nextIntersection
```

Le champ `nextLoop` est important : il montre que la reinsertion ne sort pas du
cadre. Elle produit un nouvel objet sur lequel la meme boucle est definie.

### 4. Formulation positive de l'absence de divergence nue

La forme principale doit rester positive :

```lean
def collatzInternalTerminality
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzInternalTerminality intersection
```

Lecture :

```text
toute activation portee par une intersection Collatz possede deja
sa consommation terminale et sa reinsertion closing
```

On peut ensuite ajouter une facade negative seulement comme corollaire, si elle
reste definie a partir de la structure positive. Cette formulation derivee est
precisee plus bas.

La formulation principale est :

```text
terminalite interne positive
```

pas :

```text
negation brute
```

## Theoremes publics attendus

### Prochain etat = consumer

```lean
theorem collatzNextInternalIntersection_eq_consumer
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzNextInternalIntersection intersection =
      (collatzDynamicClosureLoop intersection).consumer :=
  rfl
```

### Le peak courant est consomme par le prochain etat

```lean
theorem collatzCurrentPeak_consumed_by_nextInternalIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzDynamicClosureLoop intersection).peak =
      formedPositiveExcessOfIntersection
        (collatzNextInternalIntersection intersection)
```

### Le prochain etat porte la reinsertion closing

```lean
theorem collatzCurrentPeak_reinserted_in_nextInternalIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzNextInternalIntersection intersection) =
      NatEnrichedParityRole.closingExcess
        (collatzDynamicClosureLoop intersection).peak
```

### Le prochain etat est reactivable

```lean
def collatzNextInternalTerminality
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzDynamicClosureLoop
      (collatzNextInternalIntersection intersection) :=
  collatzDynamicClosureLoop
    (collatzNextInternalIntersection intersection)
```

### Impossibilite derivee d'une activation nue

Si on expose le predicat secondaire negatif, il doit employer `≠`, pas un
operateur non-Lean.

```lean
structure CollatzBareNonTerminalActivation
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  gap : Nat
  gap_eq_peak :
    gap = (collatzDynamicClosureLoop intersection).peak
  not_consumed :
    gap ≠ formedPositiveExcessOfIntersection
      (collatzNextInternalIntersection intersection)
```

Le theoreme se prouve uniquement a partir de la consommation positive :

```lean
theorem noCollatzBareNonTerminalActivation
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzBareNonTerminalActivation intersection -> False
```

### Certificat public complet

```lean
def collatzInternalTerminality
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzInternalTerminality intersection
```

## Ce que le fichier demontrera

Le fichier demontrera :

```text
pour toute intersection interne portee par le cadre Collatz,
la divergence relaxee activee par cette intersection
est deja prise dans une boucle positive :

production
-> consommation terminale countdown
-> reinsertion closing
-> prochain objet interne reactivable
```

Donc :

```text
il n'existe pas, dans ce cadre, d'activation relaxee nue qui resterait
hors consommation et hors reinsertion.
```

## Ce que le fichier ne demontrera pas

Le fichier ne demontrera pas :

```text
toute orbite visible atteint 1
```

Il ne demontrera pas non plus :

```text
une hauteur de vol visible classique
```

Il demontrera la terminalite interne de l'activation structurelle dans le
cadre Meta.

## Critere de reussite

L'objectif est atteint si le code final permet d'ecrire, sans hypothese
ajoutee :

```text
intersection
-> collatzInternalTerminality intersection
```

et si ce certificat contient explicitement :

```text
1. le loop courant ;
2. le prochain etat interne ;
3. la consommation terminale du peak par ce prochain etat ;
4. la reinsertion closing ;
5. la possibilite de relancer la boucle sur ce prochain etat.
```

Si l'un de ces cinq points manque, la facade n'est pas complete.

## Verrou conceptuel

La phrase exacte a viser est :

```text
La divergence positive activee par Collatz ne reste pas nue :
elle produit canoniquement son consumer terminal,
elle revient comme closingExcess,
et ce retour est deja un nouvel objet interne de la meme forme.
```

Cela donne la lecture :

```text
reinsertion closing
-> prochain etat interne
-> iteration typable de la boucle
-> impossibilite d'une activation relaxee nue
-> terminalite interne
```

## Verification avant implementation

Avant d'implementer, verifier :

```text
Meta/Collatz/DynamicClosureLoop.lean
Meta/Collatz/CountdownConsumptionBridge.lean
Meta/Arithmetic/Countdown.lean
Meta/Collatz/DiagonalOrder.lean
```

Les declarations deja disponibles doivent suffire :

```lean
collatzDynamicClosureLoop
collatzDynamicClosureLoop_consumed_as_terminal_excess
collatzDynamicClosureLoop_reenters_as_closing
collatzRelaxedCountdownConsumerIntersection
countdownTerminalWindowCollision
```

Aucun producteur externe ne doit etre ajoute.

## Audit Lean attendu

Le futur fichier Lean devra finir par :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzNextInternalIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInternalTerminality
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzCurrentPeak_consumed_by_nextInternalIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzCurrentPeak_reinserted_in_nextInternalIntersection
/- AXIOM_AUDIT_END -/
```

Le build doit rester sans :

```text
axiom
sorry
Classical
propext
Quot.sound
```
