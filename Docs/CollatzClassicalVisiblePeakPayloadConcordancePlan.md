# Plan : correspondance payload / lecture classique visible du pic

## Cible stricte

Objectif :

```text
pic enrichi final
= excess H(k)

payload
= H(k)

lecture classique visible du pic
= H(k)
```

La cible n'est pas une nouvelle trajectoire.
La cible n'est pas une reformulation vague.
La cible est une correspondance formelle entre :

```text
1. l'atome enrichi final ;
2. sa projection payload ;
3. la lecture classique visible du pic.
```

## Point deja prouve

Dans :

```text
Meta/Collatz/FibrewisePeakObservation.lean
```

on a deja :

```lean
collatzFibrewisePeakOccursAsFinalExcess
```

qui prouve :

```text
forall k,
exists pref,
  collatzInitialIndexPeakObservationTrace k =
    pref ++ [NatTraceAtom.excess (collatzInitialIndexFibreHeight k)]
```

Donc le pic enrichi final est bien :

```text
excess H(k)
```

avec :

```text
H(k) = collatzInitialIndexFibreHeight k
```

On a aussi :

```lean
collatzInitialIndexPeakObservationTrace_terminalPayload_eq_height
```

qui prouve :

```text
terminalPayload (tracePayloads trace) = H(k)
```

Donc la projection payload du pic final est deja prouvee.

## Manque exact

Il manque un nom formel pour la lecture classique visible du pic.

Ce nom doit etre definitionnellement egal a `H(k)`.

Definition attendue :

```lean
def collatzClassicalVisiblePeakOfIndex
    (k : Nat) :
    Nat :=
  collatzInitialIndexFibreHeight k
```

Cette definition fixe :

```text
lecture classique visible du pic a l'index k
= H(k)
```

par egalite definitionnelle.

## Theoremes attendus

### 1. Egalite definitionnelle

Theoreme facade :

```lean
theorem collatzClassicalVisiblePeakOfIndex_eq_height
    (k : Nat) :
    collatzClassicalVisiblePeakOfIndex k =
      collatzInitialIndexFibreHeight k :=
  rfl
```

Ce theoreme doit etre `rfl`.

Il certifie que la lecture classique visible du pic est definitionnellement
la hauteur fibrewise `H(k)`.

### 2. Correspondance payload / classique

Theoreme :

```lean
theorem collatzInitialIndexPeakObservationTrace_terminalPayload_eq_classicalVisiblePeak
    (k : Nat) :
    terminalPayload
        (tracePayloads (collatzInitialIndexPeakObservationTrace k)) =
      collatzClassicalVisiblePeakOfIndex k :=
  collatzInitialIndexPeakObservationTrace_terminalPayload_eq_height k
```

Lecture :

```text
le payload terminal de la trace enrichie est exactement la lecture classique
visible du pic.
```

### 3. Correspondance atome final / payload / classique

Theoreme :

```lean
theorem collatzFibrewisePeakOccursAsFinalExcess_classicalVisiblePeak
    (k : Nat) :
    Exists (fun (pref : List NatTraceAtom) =>
      collatzInitialIndexPeakObservationTrace k =
        pref ++
          [NatTraceAtom.excess
            (collatzClassicalVisiblePeakOfIndex k)]) :=
  collatzFibrewisePeakOccursAsFinalExcess k
```

Si Lean ne ferme pas directement par unfolding, utiliser :

```lean
change Exists (fun (pref : List NatTraceAtom) =>
  collatzInitialIndexPeakObservationTrace k =
    pref ++
      [NatTraceAtom.excess
        (collatzInitialIndexFibreHeight k)])
exact collatzFibrewisePeakOccursAsFinalExcess k
```

Lecture :

```text
la trace enrichie finit par l'atome excess de la lecture classique visible.
```

## Paquet optionnel

On peut aussi enrichir `CollatzFibrewisePeakObservation` avec :

```lean
classicalVisiblePeak : Nat
classicalVisiblePeak_eq :
  classicalVisiblePeak = collatzClassicalVisiblePeakOfIndex n
classicalVisiblePeak_eq_peak :
  classicalVisiblePeak = peak
observedTrace_terminalPayload_eq_classicalVisiblePeak :
  terminalPayload (tracePayloads observedTrace) = classicalVisiblePeak
observedTrace_final_excess_classicalVisiblePeak :
  observedTrace =
    consumer.forward.trace ++
      [NatTraceAtom.excess classicalVisiblePeak]
```

Ce paquet n'est pas obligatoire pour la preuve minimale.
Il est utile si on veut que la structure porte explicitement les trois niveaux.

## Validation obligatoire

Fichier Lean a modifier :

```text
Meta/Collatz/FibrewisePeakObservation.lean
```

Audit a mettre a jour a la fin du fichier avec les nouveaux noms principaux.

Verifier :

```text
lake env lean Meta/Collatz/FibrewisePeakObservation.lean
lake build Meta.Collatz.FibrewisePeakObservation
lake env lean Meta.lean
```

Critere de reussite :

```text
aucun axiome ;
pas de Classical ;
pas de propext ;
pas de Quot.sound ;
egalite definitionnelle par rfl pour la lecture classique visible du pic.
```
