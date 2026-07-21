# Plan d’implémentation — horloge intrinsèque et mémoire exactement finie

## 1. Objectif fermé

Le résultat visé n’est pas une nouvelle indexation extérieure de l’orbite.
Il faut extraire depuis la mémoire causale positive elle-même :

```text
mémoire cohérente
→ mot causal exact
→ positions mémorielles positives
→ cardinalité causale exacte
→ ordre par accessibilité
→ coordonnée Fin/Nat seulement à la fin
```

Le théorème central doit fournir une rétraction, et pas seulement une
injection :

```text
intrinsicTime : CausalState → CausalWord

intrinsicTime(eval(S₀,w)) = w
```

Ainsi, l’état complet reconstruit effectivement son heure causale depuis la
forme inductive de sa mémoire. Aucun compteur n’est ajouté au type des états.

## 2. Contraintes de fermeture

Toute la couche intrinsèque doit être construite sans :

```text
Nat
Fin
Classical
propext
Quot.sound
axiome de choix
égalité décidable sur les phrases
rang ou fenêtre externes
état terminal
```

`Nat` et `Fin` ne peuvent intervenir que dans un fichier de comparaison
final, après la construction causale complète.

## 3. Couche générique : finitude causale et ordre

Créer :

```text
Meta/Core/CausalFinite.lean
```

### 3.1 Type fini relatif à un mot

Définir récursivement :

```text
CausalFin(0ᶜ)       := vide
CausalFin(succᶜ(w)) := option(CausalFin(w))
```

`CausalFin(w)` représente les positions strictement antérieures à l’extrémité
du mot `w`, sans mesurer `w` par un nombre extérieur.

### 3.2 Extension et précédence

Définir d’abord les témoins positifs dans `Type` :

```text
Extension(u,v)
= un suffixe r avec v = u +ᶜ r

PositiveExtension(u,v)
= un suffixe r non vide avec v = u +ᶜ r
```

Puis leurs lectures propositionnelles :

```text
Precedes(u,v)
:⇔
∃r, v = u +ᶜ r

StrictlyPrecedes(u,v)
:⇔
∃r, r ≠ 0ᶜ ∧ v = u +ᶜ r
```

Prouver constructivement :

```text
réflexivité de Precedes
transitivité de Precedes
antisymétrie de Precedes
irréflexivité de StrictlyPrecedes
comparabilité des mots unaires
```

### 3.3 Accessibilité d’une dynamique cumulative

Définir :

```text
Reachable(S,T)
:⇔
∃w, T = eval(S,w)
```

Sur une orbite fidèle, prouver :

```text
Reachable(eval(S₀,u),eval(S₀,v))
↔
Precedes(u,v)
```

Pour toute extension positive, construire la donnée positive :

```text
StrictPredicateInclusion
  (Memory(eval(S₀,u)))
  (Memory(eval(S₀,v)))
```

Le témoin est `gap(eval(S₀,u))`.

La donnée `PositiveExtension` est indispensable ici : Lean interdit à juste
titre d’éliminer une simple existence dans `Prop` pour fabriquer une structure
dans `Type`. Le théorème de croissance stricte consomme donc le témoin positif
porté par `PositiveExtension`; il ne cache ni choix ni oracle.

## 4. Couche tarskienne : horloge portée par la mémoire

Créer :

```text
Meta/Tarski/CausalClock.lean
```

### 4.1 Lecture structurelle de la mémoire

Définir par récursion sur `CausalMemory` :

```text
CausalMemory.causalTime(root) = 0ᶜ

CausalMemory.causalTime(extend(previous,event))
= succᶜ(CausalMemory.causalTime(previous))
```

Puis :

```text
CausalState.intrinsicTime(S) := causalTime(S.memory)
```

Prouver :

```text
intrinsicTime(initialCausalState) = 0ᶜ

intrinsicTime(advance(S))
= succᶜ(intrinsicTime(S))

intrinsicTime(eval(S₀,w)) = w
```

La dernière égalité rend `eval(S₀)` section de `intrinsicTime` et fournit une
horloge intrinsèque effectivement décodable.

## 5. Positions positives et exactitude extensionnelle

### 5.1 Positions

Définir depuis la forme de la mémoire :

```text
Position(root) = vide

Position(extend(previous,event))
= option(Position(previous))
```

La valeur `none` désigne le nouvel événement et `some(position)` une position
antérieure conservée.

Définir :

```text
sentenceAt : Position(memory) → Sentence
```

### 5.2 Correspondance exacte avec Remembers

Prouver :

```text
Remembers(memory,d)
↔
∃p : Position(memory), sentenceAt(p) = d
```

La direction existentielle reste dans `Prop`; aucune extraction par choix
n’est utilisée.

### 5.3 Absence de doublons

Prouver :

```text
sentenceAt(p) = sentenceAt(q)
→ p = q
```

Le cas nouveau/ancien est réfuté par :

```text
current_not_remembered
```

L’absence de doublons est donc une conséquence du mismatch tarskien, et non
une propriété supposée d’une liste.

## 6. Cardinalité causale exacte

Construire une équivalence à deux inverses :

```text
Position(memory)
≅
CausalFin(causalTime(memory))
```

Puis spécialiser à l’orbite :

```text
Position((eval(S₀,w)).memory)
≅
CausalFin(w)
```

Ce résultat doit être le théorème principal antérieur à `Nat` : la mémoire
porte exactement autant de positions qu’il existe d’antécédents causaux dans
le mot qui l’a produite.

## 7. Comparaison finale avec Fin et Nat

Créer :

```text
Meta/Tarski/CausalClockNat.lean
```

Définir constructivement :

```text
CausalFin(w) ≅ Fin(toNat(w))
```

et en déduire :

```text
Position((eval(S₀,w)).memory)
≅
Fin(toNat(w))
```

Pour l’orbite classique :

```text
Position((causalOrbit(n)).memory) ≅ Fin(n)
```

`Fin(n)` apparaît donc comme comparaison finale de la cardinalité causale,
jamais comme moteur de la construction.

## 8. Paquets principaux

Construire deux paquets fermés.

Avant `Nat` :

```text
TarskiIntrinsicClockTheorem
```

contenant :

```text
rétraction intrinsicTime ∘ eval = id
exactitude Remembers/Position
injectivité de sentenceAt
équivalence Position/CausalFin
ordre causal par accessibilité
```

Après `Nat` :

```text
TarskiExactFiniteMemoryTheorem
```

contenant :

```text
Position(eval(w).memory) ≅ Fin(toNat(w))
Position(causalOrbit(n).memory) ≅ Fin(n)
```

## 9. Frontière de cette implémentation

La multiplication existe déjà comme récursion sur l’addition causale. Sa
fermeture algébrique et l’interprétation de la factorisation doivent venir
après cette étape.

Cette implémentation ne transportera pas prématurément `prime`, `gcd` ou
`totient` depuis `Nat`. Elle ferme d’abord la revendication plus fondamentale :

```text
le temps et la cardinalité finie d’un état
sont reconstructibles depuis sa mémoire causale positive
```

## 10. Validation

Chaque nouveau fichier Lean doit terminer par un unique bloc
`AXIOM_AUDIT`. Les cibles principales doivent compiler avec :

```text
lake build Meta.Core.CausalFinite
lake build Meta.Tarski.CausalClock
lake build Meta.Tarski.CausalClockNat
lake build Meta.Tarski.CausalAdditiveRealization
```

Tous les audits doivent annoncer qu’aucune déclaration principale ne dépend
d’un axiome.

## 11. Statut d’exécution

Le plan est entièrement implémenté.

```text
Meta/Core/CausalFinite.lean
  CausalFin
  Extension et PositiveExtension
  Precedes et StrictlyPrecedes
  ordre causal constructif
  Reachable ↔ Precedes
  croissance stricte le long d’une extension positive

Meta/Tarski/CausalClock.lean
  causalTime
  Position et sentenceAt
  Remembers ↔ existence d’une Position
  injectivité de sentenceAt
  intrinsicTime(eval(S₀,w)) = w
  Position ≅ CausalFin
  TarskiIntrinsicClockTheorem

Meta/Tarski/CausalClockNat.lean
  CausalFin(w) ≅ Fin(toNat(w))
  Position(eval(S₀,w)) ≅ Fin(toNat(w))
  Position(causalOrbit(n)) ≅ Fin(n)
  intrinsicNaturalTime(causalOrbit(n)) = n
  TarskiExactFiniteMemoryTheorem

Meta/Tarski/CausalAdditiveRealization.lean
  intégration des deux nouveaux paquets
  intrinsicTime(state(x)) = word(x)
```

Les quatre cibles de validation compilent et chaque bloc `AXIOM_AUDIT`
annonce l’absence d’axiomes. La couche antérieure à la comparaison finale ne
mentionne ni `Nat` ni `Fin` dans ses déclarations.
