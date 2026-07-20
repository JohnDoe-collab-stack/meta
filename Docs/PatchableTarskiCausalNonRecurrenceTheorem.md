# Non-récurrence causale d’une dynamique de Tarski patchable

## Résumé

On considère des candidats syntaxiques à la vérité. Chaque candidat produit,
par diagonalisation, une phrase sur laquelle il est nécessairement en désaccord
avec la vérité sémantique. On suppose que ce désaccord peut être réparé
syntaxiquement en un point, tout en préservant le comportement du candidat sur
toutes les autres phrases.

Les réparations successives engendrent alors une mémoire causale positive. Le
défi diagonal courant est absent de la mémoire présente, mais appartient à la
mémoire de tout état strictement futur. Deux états distincts de l’orbite ne
peuvent donc pas être causalement équivalents, même lorsqu’une observation
visible ancienne se répète exactement entre eux.

Le résultat central est :

```text
diagonalisation de Tarski
+ réparation locale syntaxique
+ préservation hors du point réparé
+ mémoire positive des réparations
──────────────────────────────────
récurrence visible contextuelle
+ non-récurrence de l’état causal complet
```

La fraîcheur des événements, l’injectivité de l’orbite et l’absence de retour
ne sont pas supposées. Elles sont dérivées du mismatch diagonal, de la
réparation et de sa préservation.

---

## 1. Cadre abstrait

### 1.1 Données syntaxiques et sémantiques

On se donne deux types :

```text
Sent    type des phrases syntaxiques
Pred    type des candidats syntaxiques à la vérité
```

La vérité sémantique est une propriété :

```text
M : Sent → Prop
```

Pour une phrase `d`, `M(d)` signifie que `d` est vraie dans le modèle visé.

Chaque candidat `p : Pred` induit une réponse syntaxique :

```text
T : Pred → Sent → Prop
```

La proposition `T(p,d)` signifie que le candidat `p` reconnaît la phrase `d`
comme vraie.

Toute la théorie est constructive. La négation est une fonction vers
l’absurde :

```text
¬A  signifie  A → ⊥
```

Aucun tiers exclu n’est requis.

### 1.2 Diagonalisation

Chaque candidat `p` possède une phrase diagonale :

```text
δ(p) : Sent
```

Elle vérifie le point fixe de Tarski :

```text
(D)    M(δ(p)) ↔ ¬T(p,δ(p))
```

La phrase `δ(p)` affirme donc, sémantiquement, que le candidat `p` ne la
reconnaît pas.

### 1.3 Réparation syntaxique

On dispose d’une opération interne :

```text
ρ : Pred × Sent → Pred
```

Le candidat `ρ(p,d)` est obtenu en réparant `p` à la phrase `d`.

Cette opération satisfait deux lois.

Réparation au point choisi :

```text
(R)    T(ρ(p,d),d) ↔ M(d)
```

Préservation hors de ce point :

```text
(P)    e ≠ d  →  (T(ρ(p,d),e) ↔ T(p,e))
```

L’opération `ρ` reste dans le type syntaxique `Pred`. Elle ne remplace pas
extérieurement `p` par la fonction sémantique `d ↦ M(d)`.

### 1.4 Hypothèse exacte

Le résultat repose exactement sur les données :

```text
(Sent, Pred, M, T, δ, ρ)
```

satisfaisant les lois `(D)`, `(R)` et `(P)`.

Une telle structure est appelée ici un **contexte de Tarski patchable**.

La diagonalisation seule ne suffit pas : la réparation syntaxique et sa loi de
préservation sont des hypothèses substantielles.

---

## 2. Mismatch local de Tarski

### Lemme 2.1 — Impossibilité de la correction au point diagonal

Pour tout candidat `p` :

```text
(M)    ¬(T(p,δ(p)) ↔ M(δ(p)))
```

### Preuve

Supposons :

```text
T(p,δ(p)) ↔ M(δ(p))
```

Si `T(p,δ(p))` est vraie, la correction supposée donne `M(δ(p))`. Le point
fixe `(D)` donne alors `¬T(p,δ(p))`. Par conséquent :

```text
¬T(p,δ(p))
```

Le sens réciproque de `(D)` donne maintenant `M(δ(p))`. La correction supposée
redonne `T(p,δ(p))`, contradiction.

La preuve n’utilise ni tiers exclu ni raisonnement par cas sur la vérité de la
phrase. ∎

---

## 3. Orbite intrinsèque des candidats

Fixons un candidat initial `p₀ : Pred`. Définissons récursivement :

```text
dₙ     := δ(pₙ)
pₙ₊₁   := ρ(pₙ,dₙ)
```

La phrase `dₙ` est le défi produit par `pₙ`. Le candidat `pₙ₊₁` est la
réparation syntaxique intrinsèque de ce défi.

Définissons la correction locale :

```text
Correct(p,d)  :⇔  T(p,d) ↔ M(d)
```

### Théorème 3.1 — Correction cumulative

Pour tous `k,n ∈ ℕ` :

```text
k < n  →  Correct(pₙ,dₖ)
```

Autrement dit, tout candidat ultérieur demeure correct sur tous les défis déjà
réparés.

### Théorème 3.2 — Fraîcheur dérivée

Pour tous `k,n ∈ ℕ` :

```text
k < n  →  dₖ ≠ dₙ
```

### Preuve simultanée

Supposons que `pₙ` soit correct sur tous les défis antérieurs.

La loi `(R)` donne immédiatement :

```text
Correct(pₙ₊₁,dₙ)
```

Soit `k < n`. Si `dₖ = dₙ`, la correction déjà acquise de `dₖ` par `pₙ`
deviendrait une correction de `pₙ` sur son propre point diagonal :

```text
Correct(pₙ,δ(pₙ))
```

Cela contredit le mismatch `(M)`. Donc `dₖ ≠ dₙ`.

La loi `(P)` transporte alors la correction de `dₖ` depuis `pₙ` vers `pₙ₊₁`.

La correction cumulative et la fraîcheur sont ainsi construites ensemble. ∎

### Corollaire 3.3 — Injectivité des défis

```text
dₖ = dₙ  →  k = n
```

### Corollaire 3.4 — Injectivité des candidats

Si `pₖ = pₙ`, alors :

```text
dₖ = δ(pₖ) = δ(pₙ) = dₙ
```

L’injectivité des défis donne donc :

```text
pₖ = pₙ  →  k = n
```

### Corollaire 3.5 — Absence de période syntaxique positive

Pour tous `n,r ∈ ℕ` :

```text
r > 0  →  pₙ₊ᵣ ≠ pₙ
```

Aucun générateur extérieur d’objets frais n’intervient.

---

## 4. Mémoire causale positive

### 4.1 Événement de réparation

Le passage de `pₙ` à `pₙ₊₁` produit un événement complet :

```text
Eₙ = (
  candidat source pₙ,
  défi diagonal dₙ,
  certificat du mismatch,
  candidat réparé pₙ₊₁,
  certificat de réparation,
  certificat de préservation
)
```

L’événement ne contient pas seulement la phrase `dₙ`. Il conserve les deux
orientations du pas causal :

```text
gap diagonal constaté
        ↓
réparation syntaxique autorisée
```

### 4.2 Chaîne de mémoire

La mémoire est définie positivement :

```text
H₀     := ε
Hₙ₊₁   := Eₙ :: Hₙ
```

Une phrase `d` est remémorée par `Hₙ₊₁` lorsque :

```text
d ∈ Hₙ₊₁  :⇔  (d = dₙ) ∨ (d ∈ Hₙ)
```

Cette définition n’exige aucune égalité décidable sur `Sent`.

Dans la formalisation, la mémoire est indexée par le candidat qu’elle a
effectivement atteint :

```text
Hₙ : Memory(p₀,pₙ)
```

Une histoire arbitraire ne peut donc pas être attachée à un candidat qui n’en
serait pas la cible.

### Théorème 4.1 — Solidité de la mémoire

Pour tous `n ∈ ℕ` et `d : Sent` :

```text
d ∈ Hₙ  →  Correct(pₙ,d)
```

### Preuve

La preuve suit la structure positive de `Hₙ`.

1. La mémoire vide ne remémore aucune phrase.
2. Le nouvel élément `dₙ` est corrigé par `(R)`.
3. Pour un ancien élément `d ∈ Hₙ`, l’hypothèse d’induction donne
   `Correct(pₙ,d)`.
4. Si `d = dₙ`, cette correction contredit le mismatch courant `(M)`.
5. Donc `d ≠ dₙ`, et `(P)` transporte la correction vers `pₙ₊₁`.

La solidité n’est pas stockée comme un champ supplémentaire de la mémoire. Elle
est dérivée de la diagonalisation, de la réparation et de la préservation. ∎

### Corollaire 4.2 — Absence du gap courant

Pour tout `n ∈ ℕ` :

```text
dₙ ∉ Hₙ
```

En effet, `dₙ ∈ Hₙ` impliquerait par solidité :

```text
Correct(pₙ,dₙ)
```

Mais `dₙ = δ(pₙ)`, ce qui contredit `(M)`.

### Corollaire 4.3 — Présence future du gap

Pour tous `n,m ∈ ℕ` :

```text
n < m  →  dₙ ∈ Hₘ
```

Le constructeur de tête inscrit `dₙ` dans `Hₙ₊₁`. Chaque extension ultérieure
conserve positivement cette appartenance.

---

## 5. État causal complet

Définissons l’état causal :

```text
Sₙ := (pₙ,Hₙ)
```

La mémoire de `Sₙ` ne contient aucun numéro d’étape. Elle contient les
événements qui ont effectivement produit `pₙ`.

### 5.1 Équivalence extensionnelle des mémoires

Deux mémoires sont extensionnellement équivalentes lorsque chacune transporte
toutes les obligations de l’autre :

```text
H ≃mem K  :⇔
  ∀d,
    (d ∈ H → d ∈ K)
    ∧
    (d ∈ K → d ∈ H)
```

Cette relation oublie :

- la représentation Lean de la chaîne ;
- les preuves internes ;
- la longueur de la chaîne ;
- l’ordre concret de stockage.

Elle ne conserve que le contenu causal extensionnel.

### 5.2 Équivalence causale des états

Pour `S = (p,H)` et `S′ = (q,K)`, définissons :

```text
S ≃causal S′  :⇔
  [∀d, T(p,d) ↔ T(q,d)]
  ∧
  [H ≃mem K]
```

Cette relation préserve :

1. tout le comportement visible point par point ;
2. toutes les obligations causales dans les deux directions.

Elle est constructivement réflexive, symétrique et transitive. Aucun quotient
de propositions n’est formé.

### Théorème 5.1 — Non-équivalence des mémoires

Pour tous `n,m ∈ ℕ` :

```text
n < m  →  Hₙ ≄mem Hₘ
```

### Preuve

Le témoin séparateur est le défi `dₙ`.

Le corollaire 4.2 donne :

```text
dₙ ∉ Hₙ
```

Le corollaire 4.3 donne, puisque `n < m` :

```text
dₙ ∈ Hₘ
```

Une équivalence extensionnelle transporterait cette appartenance de `Hₘ` vers
`Hₙ`, contradiction. ∎

### Théorème 5.2 — Non-récurrence de l’état causal complet

Pour tous `n,m ∈ ℕ` :

```text
n < m  →  Sₙ ≄causal Sₘ
```

Ce résultat est un corollaire strict de la non-équivalence des mémoires. Il
reste donc vrai indépendamment du comportement visible sur les autres phrases.

### Corollaire 5.3 — Absence de période causale positive

Pour tous `n,r ∈ ℕ` :

```text
r > 0  →  Sₙ ≄causal Sₙ₊ᵣ
```

L’arithmétique sert uniquement à établir `n < n+r`. Le témoin causal reste
`dₙ`, et non l’entier `n`.

---

## 6. Récurrence visible

### 6.1 Observation autorisée

Une observation de `d` dans `S = (p,H)` est autorisée lorsque `d` est une
obligation effectivement remémorée :

```text
View(S,d) := (d, preuve que d ∈ H)
```

Sa projection visible oublie la preuve causale et conserve la phrase :

```text
π(View(S,d)) = d
```

Sa réponse visible est :

```text
Resp(S,d) := T(p,d)
```

La projection n’est pas constante. Elle retourne la phrase réellement
remémorée et observée.

### 6.2 Répétition d’une observation ancienne

Soient :

```text
k < n < m
```

L’accumulation donne :

```text
dₖ ∈ Hₙ
dₖ ∈ Hₘ
```

On peut donc construire deux observations autorisées :

```text
Vₙ := View(Sₙ,dₖ)
Vₘ := View(Sₘ,dₖ)
```

Leurs projections syntaxiques sont exactement égales :

```text
π(Vₙ) = dₖ = π(Vₘ)
```

La solidité de la mémoire donne aussi :

```text
T(pₙ,dₖ) ↔ M(dₖ)
T(pₘ,dₖ) ↔ M(dₖ)
```

Par transitivité :

```text
T(pₙ,dₖ) ↔ T(pₘ,dₖ)
```

Cette équivalence est constructive. Elle ne transforme pas deux propositions
logiquement équivalentes en une égalité de `Prop`.

---

## 7. Théorème principal

### Théorème 7.1 — Récurrence visible avec non-retour causal

Dans tout contexte de Tarski patchable, pour tout candidat initial `p₀` et
tous `k,n,m ∈ ℕ` tels que `k < n < m`, il existe deux observations autorisées
`Vₙ` de `Sₙ` et `Vₘ` de `Sₘ` vérifiant simultanément :

```text
π(Vₙ) = π(Vₘ) = dₖ

T(pₙ,dₖ) ↔ T(pₘ,dₖ)

Hₙ ≄mem Hₘ

Sₙ ≄causal Sₘ
```

Sous forme condensée :

```text
∀k,n,m ∈ ℕ,

  k < n < m
  →
  ∃Vₙ,Vₘ,

    [π(Vₙ) = π(Vₘ) = dₖ]
    ∧
    [T(pₙ,dₖ) ↔ T(pₘ,dₖ)]
    ∧
    [Hₙ ≄mem Hₘ]
    ∧
    [Sₙ ≄causal Sₘ]
```

Les quatre conclusions portent sur le même couple d’états et la même histoire
de réparations.

### 7.2 Témoin canonique

Le résultat n’est pas seulement conditionnel. Dans toute orbite patchable, on
peut prendre :

```text
k = 0
n = 1
m = 2
```

On obtient :

```text
π(View(S₁,d₀)) = d₀ = π(View(S₂,d₀))

T(p₁,d₀) ↔ T(p₂,d₀)

S₁ ≄causal S₂
```

---

## 8. Incomplétude persistante

La réparation d’un gap ne produit jamais un candidat globalement correct.

Pour tout `n ∈ ℕ` :

```text
¬[∀d : Sent, T(pₙ,d) ↔ M(d)]
```

En effet, `pₙ` produit son nouveau point diagonal `dₙ`, sur lequel le mismatch
local s’applique encore.

La dynamique ne converge donc jamais vers un prédicat global de vérité. Elle
accumule des corrections locales tout en produisant un nouveau défaut
diagonal.

---

## 9. Pourquoi le résultat est non trivial

### 9.1 La non-récurrence n’est pas postulée

Le contexte initial ne contient aucune hypothèse :

```text
fresh
injective
acyclic
noReturn
```

Ces propriétés sont dérivées.

### 9.2 La séparation n’utilise pas une horloge cachée

L’état causal ne contient aucun champ numérique indiquant son étape.

La preuve n’utilise ni la longueur de la mémoire, ni l’égalité brute des
chaînes. Elle reste valide après passage à l’équivalence extensionnelle
`≃mem`.

Le séparateur est une donnée syntaxique sémantiquement justifiée :

```text
dₙ ∉ Hₙ
dₙ ∈ Hₘ    lorsque n < m
```

### 9.3 La fraîcheur provient du mismatch

Le défi `dₙ` ne peut coïncider avec un ancien défi réparé. Une telle
coïncidence transformerait une correction passée en correction du mismatch
courant.

Le système produit donc ses propres séparateurs causaux, sans identifiant frais
fourni de l’extérieur.

### 9.4 Le visible et le causal concernent les mêmes états

La répétition visible et la séparation causale ne proviennent pas de deux
modèles juxtaposés.

Pour le même couple `Sₙ,Sₘ` :

```text
même phrase visible dₖ
même réponse visible sur dₖ
mémoire causale différente
état causal non équivalent
```

### 9.5 Pourquoi la mémoire ne rend pas la preuve tautologique

Une fois décidé qu’un état conserve ses événements, une forme de non-retour
est attendue dans de nombreux systèmes à journal cumulatif.

La part spécifiquement tarskienne et non triviale est plus précise :

1. chaque événement est une vraie réparation syntaxique ;
2. toute obligation mémorisée reste correcte par un théorème, pas par un
   champ supposé ;
3. le défi courant est prouvé absent de la mémoire présente ;
4. il devient un nouveau séparateur sans générateur externe de fraîcheur ;
5. la séparation subsiste lorsque la forme, l’ordre et la longueur de la
   mémoire sont oubliés.

C’est cette combinaison qui distingue le théorème d’un état muni artificiellement
d’un compteur croissant.

---

## 10. Portée exacte et limites

### 10.1 Ce que le théorème établit

```text
patchabilité de Tarski
→ non-récurrence causale extensionnelle
```

Il établit simultanément une récurrence visible contextuelle sur toute ancienne
phrase diagonale réparée.

### 10.2 Ce qu’il n’établit pas

Le théorème ne montre pas :

1. que la diagonalisation de Tarski seule suffit sans opération de patch ;
2. que deux candidats `pₙ` et `pₘ` ont le même comportement sur toutes les
   phrases ;
3. qu’une projection totale et non contextuelle des états revient
   périodiquement ;
4. que la vérité arithmétique générale est décidable ;
5. que ce résultat est inédit dans toute la littérature mathématique.

Le visible qui se répète est une observation ancienne autorisée par les deux
mémoires. La réponse coïncide à ce point précis, pas nécessairement sur
l’intégralité du langage.

Une revendication de priorité scientifique demanderait une étude
bibliographique séparée sur :

- les théories itérées de la vérité ;
- les progressions de réflexion ;
- les systèmes révisionnels de vérité ;
- les sémantiques à mémoire ;
- les dynamiques event-sourced.

Le présent document établit l’autonomie et la non-trivialité interne du résultat
formalisé. Il ne revendique pas encore une priorité bibliographique.

---

## 11. Caractère constructif

La formalisation n’utilise aucun des principes suivants :

```text
Classical
propext
Quot.sound
axiome ajouté
```

En particulier :

- le mismatch est une fonction vers `⊥` ;
- l’appartenance à la mémoire est une disjonction positive ;
- la comparaison visible utilise `↔` ;
- les équivalences sont deux transports explicites ;
- aucun quotient de propositions n’est formé.

---

## 12. Correspondance avec la formalisation Lean

| Objet mathématique | Déclaration Lean |
|---|---|
| contexte `(Sent, Pred, M, T, δ)` | `ArithmeticTarskiContext` |
| patch `ρ` et lois `(R),(P)` | `PatchableArithmeticTarskiContext` |
| événement `Eₙ` | `AlgorithmStep` |
| orbite `pₙ` | `genericOrbitCandidate` |
| défi `dₙ` | `genericOrbitIndex` |
| correction cumulative | `genericOrbit_cumulativeAgreement` |
| mémoire `Hₙ` | `CausalMemory` |
| appartenance `d ∈ Hₙ` | `CausalMemory.Remembers` |
| solidité de la mémoire | `CausalMemory.correctAt_of_remembers` |
| absence du gap courant | `CausalMemory.current_not_remembered` |
| état `Sₙ` | `CausalState` et `causalOrbit` |
| équivalence `≃mem` | `MemoryEquivalent` |
| équivalence `≃causal` | `CausallyEquivalent` |
| non-équivalence des mémoires | `causalOrbit_memory_notEquivalent_of_lt` |
| non-retour causal | `causalOrbit_not_causallyEquivalent_of_lt` |
| observation autorisée | `AuthorizedVisibleObservation` |
| même réponse ponctuelle | `VisibleSameAt` |
| théorème simultané | `genericVisibleRecurrenceWithCausalNonReturn` |
| témoin `S₁/S₂` | `canonicalVisibleRecurrenceWithCausalNonReturn` |
| package public | `genericVisibleCausalNonRecurrenceTheorem` |

Modules concernés :

```text
Meta/Tarski/TruthGap.lean
Meta/Tarski/GenericPatchOrbit.lean
Meta/Tarski/CausalMemory.lean
Meta/Tarski/CausalOrbit.lean
Meta/Tarski/VisibleCausalRecurrence.lean
```

Le package public est importé par `Meta.lean`. Tous ses audits d’axiomes sont
vides.

---

## Conclusion

La découverte formalisée peut être énoncée ainsi :

> Dans un contexte de Tarski syntaxiquement patchable, chaque mismatch
> diagonal réparé devient une obligation causale persistante. Le mismatch
> suivant fournit intrinsèquement une nouvelle obligation, distincte de toutes
> celles déjà réparées. Une ancienne observation peut donc réapparaître avec
> exactement la même syntaxe et la même réponse visible, tandis que la mémoire
> causale complète interdit tout retour.

La formule centrale, en notation directe, est :

```text
∀k,n,m ∈ ℕ,

  k < n < m
  →
  ∃Vₙ,Vₘ,

    [π(Vₙ) = π(Vₘ) = dₖ]
    ∧
    [T(pₙ,dₖ) ↔ T(pₘ,dₖ)]
    ∧
    [Sₙ ≄causal Sₘ]
```
