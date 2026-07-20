# Des gaps réparés à l’additivité naturelle causale

## 1. Résultat démontré

Le cadre construit davantage qu’une suite d’états indexée par les nombres
naturels : il construit une représentation additive fidèle de l’objet naturel
dans la dynamique causale engendrée par un gap patchable.

La chaîne fondamentale est :

```text
mismatch diagonal
+ réparation locale
+ préservation des réparations antérieures
───────────────────────────────────────────
fraîcheur intrinsèque des gaps
→ mémoire causale strictement enrichie
→ absence de contraction d’un chemin non vide
→ addition par composition des chemins
→ action additive fidèle du pas causal
→ réalisation causale de (Nat, 0, succ, +)
```

Le point fort est l’additivité réalisée. `Nat` n’est pas introduit comme une
horloge externe servant à numéroter les états. Les mots causaux sont d’abord
construits avec un mot vide et l’ajout d’un pas. Leur composition fournit
l’addition. Le mécanisme tarskien prouve ensuite que cette addition agit sur
les états sans contraction.

Autrement dit :

```text
0       = aucun événement causal
succ n  = un événement causal ajouté après n
n + m   = composition de deux histoires causales
```

La distinction fondamentale est :

```text
la syntaxe inductive des mots
→ fournit l’objet naturel abstrait et son addition

le mécanisme tarskien
→ réalise cette addition dans les états
  et empêche la contraction de deux sommes distinctes
```

La non-récurrence n’est donc pas la conclusion finale. Elle est le théorème de
séparation qui rend fidèle la représentation additive.

---

## 2. Cadre syntaxique et sémantique

On se donne deux types :

```text
Sent  : type des phrases
Pred  : type des candidats syntaxiques à la vérité
```

La vérité sémantique est donnée par :

```text
M : Sent → Prop
```

Un candidat `p : Pred` produit une réponse sur chaque phrase :

```text
T : Pred → Sent → Prop
```

La proposition `T(p,d)` signifie que le candidat `p` reconnaît la phrase `d`.

On définit :

```text
Correct(p,d)  :⇔  T(p,d) ↔ M(d)
```

Le cadre porte ensuite deux opérations syntaxiques :

```text
δ : Pred → Sent
ρ : Pred × Sent → Pred
```

`δ(p)` est le défi diagonal produit par `p`.

`ρ(p,d)` est le nouveau candidat obtenu en réparant `p` au point `d`.

Tout reste dans la syntaxe : `ρ(p,d)` appartient encore à `Pred`. La
réparation n’est pas le remplacement extérieur de `p` par l’oracle sémantique
`M`.

---

## 3. Les trois lois génératrices

### 3.1 Diagonalisation

Pour tout candidat `p` :

```text
(D)  M(δ(p)) ↔ ¬T(p,δ(p))
```

Le défi diagonal affirme que le candidat courant ne le reconnaît pas.

### 3.2 Réparation locale

Pour tout candidat `p` et toute phrase `d` :

```text
(R)  Correct(ρ(p,d),d)
```

Le patch corrige effectivement le point qu’il reçoit.

### 3.3 Préservation hors du point réparé

Pour toutes phrases `d` et `e` :

```text
(P)  e ≠ d  →  (T(ρ(p,d),e) ↔ T(p,e))
```

Le patch ne détruit donc pas les réponses acquises aux autres points.

Ces trois lois sont les seules lois sémantiques nécessaires au mécanisme.

---

## 4. Le mismatch comme moteur positif

La diagonalisation entraîne :

```text
(M)  ¬Correct(p,δ(p))
```

En effet, si `p` était correct sur `δ(p)`, alors :

```text
T(p,δ(p)) ↔ M(δ(p)) ↔ ¬T(p,δ(p))
```

ce qui produit constructivement une contradiction.

Le mismatch n’est pas seulement une impossibilité globale de définir la
vérité. Il désigne un point syntaxique précis :

```text
gap(p) := δ(p)
```

Ce point peut être consommé par la réparation :

```text
next(p) := ρ(p,δ(p))
```

Le passage fondamental est donc :

```text
gap courant
→ patch syntaxique
→ candidat suivant
```

---

## 5. Construction de la mémoire causale

Fixons un candidat initial `p₀`.

Un état causal contient :

```text
S = (current(S), memory(S))
```

où :

```text
current(S) : Pred
memory(S)  : histoire positive des réparations ayant produit current(S)
```

La racine est :

```text
S₀ = (p₀, mémoire vide)
```

L’avance canonique est :

```text
advance(S) =
  ( next(current(S)),
    memory(S) étendue par le patch de δ(current(S)) )
```

Pour une phrase `d`, l’expression :

```text
d ∈ memory(S)
```

signifie qu’un événement antérieur de l’histoire de `S` a réparé `d`.

Cette appartenance n’est pas un compteur, une date ou une position dans une
liste. C’est un témoin positif d’un événement syntaxique effectivement
survenu.

---

## 6. Solidité de la mémoire

La propriété centrale est :

```text
d ∈ memory(S)  →  Correct(current(S),d)
```

Elle se démontre par induction sur la construction de la mémoire.

### Cas du dernier événement

Si `d` est précisément le gap que le dernier patch vient de réparer, la loi
`(R)` donne directement :

```text
Correct(current(S),d)
```

### Cas d’un événement plus ancien

Supposons que `d` était déjà mémorisé avant le dernier patch.

La solidité antérieure donne que le candidat précédent était correct sur `d`.
Le gap courant du candidat précédent ne peut pas être égal à `d`, sinon ce
candidat aurait été correct sur son propre point diagonal, contre `(M)`.

On obtient donc :

```text
d ≠ gap courant
```

La loi `(P)` transporte alors la correction de `d` à travers le nouveau patch.

La mémoire est ainsi cumulativement solide sans décision de l’égalité des
phrases et sans générateur externe de fraîcheur.

---

## 7. Les trois lois causales dérivées

Pour tout état causal `S`, les lois `(D)`, `(R)` et `(P)` produisent :

### 7.1 Absence du gap courant

```text
(A)  δ(current(S)) ∉ memory(S)
```

S’il était mémorisé, la solidité de la mémoire rendrait le candidat courant
correct sur son propre point diagonal, contre `(M)`.

### 7.2 Inscription par l’avance

```text
(I)  δ(current(S)) ∈ memory(advance(S))
```

Le patch courant devient un événement positif du nouvel état.

### 7.3 Préservation de la mémoire

```text
(C)  d ∈ memory(S)
     → d ∈ memory(advance(S))
```

Toute obligation causale acquise reste présente après l’avance.

La dynamique essentielle est donc :

```text
δ(current(S)) ∉ memory(S)

mais

δ(current(S)) ∈ memory(advance(S))
```

Le même objet syntaxique change de statut : il passe de gap actuel à
obligation persistante.

---

## 8. Fraîcheur intrinsèque

Considérons un état futur `U` obtenu depuis `S` par au moins une avance.

La première avance inscrit le gap de `S` :

```text
δ(current(S)) ∈ memory(advance(S))
```

Toutes les avances suivantes le préservent. Donc :

```text
δ(current(S)) ∈ memory(U)
```

Mais le gap courant de `U` est absent de sa mémoire :

```text
δ(current(U)) ∉ memory(U)
```

Par conséquent :

```text
δ(current(S)) ≠ δ(current(U))
```

Le nouveau gap est frais parce qu’il ne peut coïncider avec aucune obligation
déjà mémorisée.

La fraîcheur n’est donc pas fournie par :

```text
un nom nouveau
un rang croissant
une date
un index naturel injectif
```

Elle est forcée par l’incompatibilité suivante :

```text
ancien gap  = présent dans la mémoire future
gap actuel  = absent de cette même mémoire
```

---

## 9. Mots causaux et addition sans Nat

Pour ne pas présupposer les nombres naturels, on ne définit pas d’abord une
suite `Sₙ`. On construit un type inductif de mots causaux :

```text
ε     : CausalWord
w · g : CausalWord  si w : CausalWord
```

Il n’existe qu’un seul symbole générateur `g`. Les gaps successifs seront des
événements distincts produits par les applications contextuelles successives
de ce même générateur.

On pose :

```text
0ᶜ       := ε
1ᶜ       := ε · g
succᶜ(w) := w · g
```

### 9.1 Addition des mots

L’addition est la composition chronologique des histoires. Elle est définie
par récursion sur le second mot :

```text
u +ᶜ ε       := u
u +ᶜ (v · g) := (u +ᶜ v) · g
```

La lecture est : exécuter d’abord l’histoire `u`, puis l’histoire `v`.

Les deux équations fondamentales sont donc définitionnelles :

```text
u +ᶜ 0ᶜ       = u
u +ᶜ succᶜ(v) = succᶜ(u +ᶜ v)
```

### 9.2 Lois additives internes

La syntaxe unaire donne constructivement :

```text
0ᶜ +ᶜ u = u

(u +ᶜ v) +ᶜ w = u +ᶜ (v +ᶜ w)

succᶜ(u) +ᶜ v = succᶜ(u +ᶜ v)

u +ᶜ v = v +ᶜ u

u +ᶜ w = v +ᶜ w → u = v

w +ᶜ u = w +ᶜ v → u = v
```

La commutativité ne vient pas de la composition générale des fonctions. Elle
vient du fait que tous les mots sont formés par répétition d’un seul
générateur. Elle se démontre par induction à partir des deux lois de
successeur.

La cancellation droite se démontre par induction sur le suffixe commun. La
cancellation gauche en découle par commutativité.

Ainsi :

```text
(CausalWord, 0ᶜ, +ᶜ)
```

est le monoïde additif libre à un générateur, construit sans faire intervenir
le type `Nat`.

---

## 10. Évaluation et loi d’action additive

Soit un système muni d’un état et d’une transition :

```text
State
advance : State → State
```

L’évaluation d’un mot depuis un état `S` est définie par :

```text
eval(S,ε)     := S
eval(S,w · g) := advance(eval(S,w))
```

Le théorème additif fondamental est :

```text
eval(S,u +ᶜ v) = eval(eval(S,u),v)
```

Sa preuve est une induction sur `v` :

```text
v = ε
→ les deux côtés valent eval(S,u)

v = v′ · g
→ les deux côtés sont obtenus en appliquant advance
  aux deux côtés du cas inductif
```

Définissons la transformation portée par un mot :

```text
Φ(u)(S) := eval(S,u)
```

Alors, point par point :

```text
Φ(0ᶜ)(S) = S

Φ(u +ᶜ v)(S) = Φ(v)(Φ(u)(S))
```

Si la composition chronologique des transformations est notée :

```text
F ⋄ G := G ∘ F
```

la loi pointwise devient exactement :

```text
∀S, Φ(u +ᶜ v)(S) = (Φ(u) ⋄ Φ(v))(S)
```

Cette égalité est prouvée point par point en Lean ; aucune extensionnalité
fonctionnelle n’est nécessaire.

L’addition causale n’est donc pas une analogie numérique plaquée sur une
orbite. Elle est la loi de composition effective des applications successives
de `advance`.

---

## 11. Pourquoi le générateur est la transition complète

Le gap local du Core autorise un usage orienté entre deux pôles dans un même
contexte :

```text
formed(S) → shadow(S)
```

Deux usages substantiels de cette forme ne se composent pas dans le même
contexte. Le second gap appartient au contexte produit après la réparation du
premier.

Le générateur `g` n’est donc pas la flèche locale :

```text
formed(S) → shadow(S)
```

Le générateur global est la transition causale complète :

```text
S → advance(S)
```

Chaque application de `advance` contient :

```text
le mismatch local de l’état courant
la réparation de ce mismatch
le transport des corrections antérieures
l’inscription du nouvel événement dans la mémoire
la formation du contexte suivant
```

Le mismatch ne crée donc pas un nouveau générateur. Il détermine le nouvel
événement qui instancie l’application suivante du générateur global
`advance`.

### 11.1 Composition transcontextuelle

La composition locale déjà présente dans le Core reste indexée par un contexte
fixe. L’addition causale demande une composition de pas complets dont les
contextes changent :

```text
S
→ advance(S)
→ advance(advance(S))
→ ...
```

Le mot causal porte précisément cette succession dépendante. Son `k`-ième pas
est toujours formé dans le contexte produit par les pas précédents.

Pour les transports de sortie, la construction transcontextuelle obtenue est :

```text
composedTransport(S,u,v)
:
Transport(S,eval(S,u +ᶜ v))

composedTransport(S,u,v)
:=
réindexer le but de
composeAcross(
  pathTransport(S,u),
  pathTransport(eval(S,u),v))
par eval(S,u +ᶜ v) = eval(eval(S,u),v)
```

`composeAcross` n’est pas fourni comme pont terminal externe. Il est construit
à partir des événements complets conservés dans le chemin causal. Cette couche
transcontextuelle transporte l’additivité jusqu’aux lectures du Core ; elle
est distincte de la seule loi d’action sur les états, qui découle déjà de
`advance`.

---

## 12. Système abstrait à mémoire cumulative

La liberté causale ne dépend plus directement de la syntaxe tarskienne une
fois les trois lois causales extraites. La structure positive minimale est :

```text
State
Gap

gap     : State → Gap
Memory  : State → Gap → Prop
advance : State → State
```

avec, pour tout état `S` et tout gap `d` :

```text
(A)  ¬Memory(S,gap(S))

(I)  Memory(advance(S),gap(S))

(C)  Memory(S,d) → Memory(advance(S),d)
```

### 12.1 Équivalence de mémoire

On définit :

```text
S ≃ₘ T
:⇔
∀d, Memory(S,d) ↔ Memory(T,d)
```

Une équivalence causale complète `S ≃c T` peut également préserver les
réponses visibles. Le théorème de liberté utilise seulement la conséquence :

```text
S ≃c T → S ≃ₘ T
```

Il n’est donc nécessaire de former aucun quotient d’états.

### 12.2 Accumulation le long d’un mot non nul

Pour tout mot `w` :

```text
w ≠ 0ᶜ
→ Memory(eval(S,w),gap(S))
```

La preuve est une induction sur `w`.

Au premier pas, `(I)` inscrit `gap(S)`. À chaque pas supplémentaire, `(C)` le
préserve.

Or `(A)` donne :

```text
¬Memory(S,gap(S))
```

Par conséquent :

```text
w ≠ 0ᶜ
→ ¬(eval(S,w) ≃ₘ S)

w ≠ 0ᶜ
→ ¬(S ≃ₘ eval(S,w))
```

et donc :

```text
w ≠ 0ᶜ
→ ¬(eval(S,w) ≃c S)

w ≠ 0ᶜ
→ ¬(S ≃c eval(S,w))
```

Le gap de l’état de départ est le témoin interne qui sépare cet état de toute
extension causale positive.

---

## 13. Fidélité de la représentation additive

### 13.1 Comparabilité constructive des mots unaires

Pour tous mots `u` et `v`, une induction simultanée donne exactement l’une des
possibilités utilisables suivantes :

```text
u = v

ou

∃w, w ≠ 0ᶜ et v = u +ᶜ w

ou

∃w, w ≠ 0ᶜ et u = v +ᶜ w
```

Aucune longueur naturelle n’est utilisée. On retire simultanément un
constructeur `· g` aux deux mots jusqu’à rencontrer soit deux mots vides, soit
un mot vide et un mot non vide.

### 13.2 Fidélité au point initial

Fixons un état initial `S₀`. Supposons :

```text
eval(S₀,u) ≃c eval(S₀,v)
```

Si `v = u +ᶜ w` avec `w ≠ 0ᶜ`, la loi additive de l’évaluation donne :

```text
eval(S₀,v) = eval(eval(S₀,u),w)
```

Le théorème de séparation d’un mot non nul interdit alors l’équivalence
causale des deux côtés. Le cas symétrique est identique.

Il ne reste que :

```text
u = v
```

On obtient le théorème central :

```text
eval(S₀,u) ≃c eval(S₀,v)
→ u = v
```

### 13.3 Fidélité de l’action

La loi précédente implique également la fidélité de l’action additive. Si :

```text
∀S, Φ(u)(S) = Φ(v)(S)
```

alors l’égalité vaut en particulier en `S₀`. L’égalité d’états implique leur
équivalence causale, donc :

```text
u = v
```

La représentation :

```text
Φ : (CausalWord,0ᶜ,+ᶜ)
    → (transformations causales,id,⋄)
```

est ainsi additive et fidèle. Le théorème au point `S₀` est même plus précis :
un seul état initial suffit à séparer toutes les transformations engendrées.

---

## 14. Objet naturel abstrait porté par les mots

La structure récursive des mots vient de leur définition inductive, et non de
Tarski.

Les constructeurs donnent :

```text
0ᶜ ≠ succᶜ(w)

succᶜ(u) = succᶜ(v)
→ u = v
```

Ils donnent aussi l’induction. Pour toute propriété `P` :

```text
P(0ᶜ)

et

∀w, P(w) → P(succᶜ(w))

impliquent

∀w, P(w)
```

Enfin, pour tout type `X`, tout élément `x₀ : X` et toute opération
`s : X → X`, on définit récursivement :

```text
fold : CausalWord → X

fold(0ᶜ)       = x₀
fold(succᶜ(w)) = s(fold(w))
```

L’unicité est énoncée constructivement, point par point :

```text
si h : CausalWord → X vérifie les deux mêmes équations,
alors ∀w, h(w) = fold(w)
```

Aucune égalité globale de fonctions et aucune extensionnalité fonctionnelle
ne sont requises.

Ainsi :

```text
(CausalWord,0ᶜ,succᶜ)
```

est l’objet naturel abstrait. Son addition est la composition `+ᶜ` définie à
la section 9.

Le rôle spécifique de Tarski n’est pas de fournir ces constructeurs. Il est de
garantir que leur réalisation additive dans les états causaux ne les
contracte pas.

### 14.1 Identification finale à Nat

Le type `Nat` n’intervient qu’après la construction causale, comme objet de
comparaison. On définit alors :

```text
toNat(0ᶜ)       := 0
toNat(succᶜ(w)) := succ(toNat(w))

ofNat(0)        := 0ᶜ
ofNat(succ(n))  := succᶜ(ofNat(n))
```

Deux inductions donnent :

```text
ofNat(toNat(w)) = w

toNat(ofNat(n)) = n
```

L’additivité est également préservée :

```text
toNat(u +ᶜ v) = toNat(u) + toNat(v)

ofNat(n + m) = ofNat(n) +ᶜ ofNat(m)
```

On obtient seulement à ce stade l’identification additive :

```text
(CausalWord,0ᶜ,succᶜ,+ᶜ)
≅
(Nat,0,succ,+)
```

`Nat` est ici la forme normale externe de la structure déjà construite ; il
n’a joué aucun rôle dans la production ou la séparation des états causaux.

---

## 15. Objet naturel causal réalisé

Pour lier positivement un mot à l’état qu’il produit, sans quotient ni choix,
on définit relativement à `S₀` :

```text
RealizedCausalNat(S₀) :=
  (word, state, realized)
```

avec :

```text
word     : CausalWord
state    : State
realized : state = eval(S₀,word)
```

Le mot et son état ne sont pas juxtaposés arbitrairement : le champ `realized`
les lie par l’évaluation causale.

### 15.1 Zéro et successeur réalisés

```text
0ʳ := (0ᶜ,S₀,preuve que S₀ = eval(S₀,0ᶜ))
```

Pour `x = (u,S,realized)`, on pose :

```text
succʳ(x) :=
  (succᶜ(u),
   advance(S),
   preuve que advance(S) = eval(S₀,succᶜ(u)))
```

La dernière preuve utilise `realized` et la définition de `eval`.

### 15.2 Addition réalisée

Pour :

```text
x = (u,Sᵤ,realizedᵤ)
y = (v,Sᵥ,realizedᵥ)
```

on définit :

```text
x +ʳ y :=
  (u +ᶜ v,
   eval(S₀,u +ᶜ v),
   identité)
```

Cette addition est relative à la même origine causale `S₀`. Sa lecture
opérationnelle est fournie par la loi d’action :

```text
state(x +ʳ y) = eval(state(x),word(y))
```

Le côté droit signifie : partir de l’état réalisé par `x`, puis exécuter
l’histoire portée par `y`.

Cette phrase se comprend au niveau des formes de chemins. L’addition ne
réutilise pas les événements concrets déjà contenus dans `state(y)`. Elle
réexécute le mot `word(y)` depuis `state(x)` :

```text
forme de y = word(y)

événements de x +ʳ y
=
événements produits en évaluant word(y) dans le contexte state(x)
```

Les gaps concrets de cette nouvelle exécution peuvent donc différer des gaps
qui ont produit `state(y)` depuis `S₀`.

La formulation exacte est :

```text
L’addition concatène les formes de chemins.
L’évaluation instancie contextuellement leurs événements.
```

### 15.3 Plongement additif

Le plongement canonique est :

```text
embed₀(w) := (w,eval(S₀,w),identité)
```

Il satisfait :

```text
embed₀(0ᶜ) = 0ʳ

embed₀(succᶜ(w)) = succʳ(embed₀(w))

embed₀(u +ᶜ v) = embed₀(u) +ʳ embed₀(v)
```

La troisième égalité est le théorème d’additivité réalisée.

La projection vers le mot satisfait également :

```text
word(embed₀(w)) = w

embed₀(word(x)) = x
```

La seconde égalité utilise le témoin `realized` porté par `x`. Ainsi
`CausalWord` et `RealizedCausalNat(S₀)` sont constructivement isomorphes, sans
quotient :

```text
CausalWord ≅ RealizedCausalNat(S₀)
```

### 15.4 L’état complet détermine le mot

Pour deux objets réalisés `x` et `y`, la fidélité tarskienne donne :

```text
state(x) ≃c state(y)
→ word(x) = word(y)
```

En particulier :

```text
state(x) = state(y)
→ word(x) = word(y)
```

Comme tout objet réalisé est égal à l’image canonique de son mot :

```text
embed₀(word(x)) = x
```

l’égalité des mots redonne l’égalité complète des objets. On obtient donc la
fidélité forte de la projection d’état :

```text
state(x) ≃c state(y)
→ x = y
```

et, en particulier :

```text
state(x) = state(y)
→ x = y
```

Le mot reste porté positivement dans la structure, mais il n’est pas une
annotation ambiguë : l’état causal complet suffit à le déterminer sur
l’orbite réalisée.

Cette construction package davantage de structure qu’une simple fonction
injective vers les états et reste entièrement positive, sans quotient de
l’espace des états.

---

## 16. Lois de l’addition réalisée

Les lois de `+ᶜ` se transportent à `+ʳ` par les composantes `word` et
`realized` :

```text
x +ʳ 0ʳ = x

0ʳ +ʳ x = x

(x +ʳ y) +ʳ z = x +ʳ (y +ʳ z)

x +ʳ y = y +ʳ x

x +ʳ z = y +ʳ z → x = y

z +ʳ x = z +ʳ y → x = y

succʳ(x) = x +ʳ embed₀(1ᶜ)
```

Dans la formalisation constructive, ces égalités sont prouvées sur la
structure réalisée complète en ramenant son égalité à celle des mots. Aucune
extensionnalité fonctionnelle n’intervient.

La cancellation et la séparation du zéro impliquent qu’aucun incrément non
nul ne peut être absorbé :

```text
w ≠ 0ᶜ
→ ¬(x +ʳ embed₀(w) = x)
```

La non-récurrence devient ainsi une conséquence additive : aucune translation
positive de l’objet réalisé ne revient à son point de départ.

Le résultat n’est donc pas seulement :

```text
il existe une infinité d’états
```

mais :

```text
les états accessibles portent une réalisation fidèle,
cancellative et non périodique de l’addition naturelle
```

---

## 17. Multiplication : frontière de la formalisation

La multiplication n’est pas le moteur du résultat principal. Elle est dérivée
du récurseur naturel et de l’addition déjà construite :

```text
u ×ᶜ 0ᶜ       := 0ᶜ
u ×ᶜ succᶜ(v) := (u ×ᶜ v) +ᶜ u
```

L’ordre logique formalisé est :

```text
composition causale
→ addition des mots
→ action additive sur les états
→ fidélité tarskienne
→ addition sur l’objet réalisé
→ définition de la multiplication des mots par récursion
```

Le fichier générique définit `×ᶜ`, mais le théorème principal audité porte sur
la structure additive qui précède la multiplication. `×ʳ` et les lois
multiplicatives complètes ne font pas partie du paquet tarskien fermé. Elles ne
sont donc ni utilisées ni cachées dans la preuve de l’additivité.

---

## 18. Répétition visible et non-retour causal

Une théorie concrète peut porter une observation visible :

```text
observe : State → Visible
```

Sa non-injectivité est la propriété négative :

```text
¬Injective(observe)

:⇔

¬(∀S T, observe(S) = observe(T) → S = T)
```

Elle n’est pas une conséquence générique de `(A)`, `(I)`, `(C)` ou de la
patchabilité tarskienne. Elle appartient à la théorie mathématique ou au
modèle qui définit `Visible` et `observe`.

Constructivement, cette négation ne produit pas automatiquement une
collision. Une théorie peut fournir le certificat positif plus fort :

```text
∃u v,
  u ≠ v
  ∧ observe(eval(S₀,u)) = observe(eval(S₀,v))
```

Lorsqu’un tel certificat est construit, la fidélité causale impose
simultanément :

```text
u ≠ v
→ ¬(eval(S₀,u) ≃c eval(S₀,v))
```

La valeur naturelle réalisée est donc déterminée par l’état causal complet,
pas nécessairement par sa projection visible.

Le visible peut donc boucler dans les théories qui démontrent cette
non-injectivité, tandis que l’action additive causale ne se contracte pas. Les
deux affirmations ont des statuts distincts : la fidélité causale est
générique ; la non-injectivité visible est spécifique.

---

## 19. Socle antérieur et résultat ajouté

Le dépôt contient déjà :

```text
le contexte de Tarski patchable
le pas syntaxique canonique
le mismatch diagonal local
la réparation au point courant
la préservation hors du point courant
la correction cumulative
la fraîcheur intrinsèque des défis
l’injectivité des candidats et des défis
la mémoire causale positive
l’absence du gap courant dans la mémoire
l’inscription du gap après l’avance
la préservation des souvenirs antérieurs
la non-équivalence des états causalement distincts
l’absence de période causale positive
la répétition visible compatible avec la séparation causale
```

Le Core contient également :

```text
l’identité des usages
la composition des usages dans un contexte fixé
les lois d’identité et d’associativité
le transport cohérent de l’identité et de la composition
le gap non contractif
l’état causal dynamique
la transition consommant un état causal complet
```

Ces résultats formaient le socle tarskien de séparation. La présente
formalisation ajoute maintenant :

```text
les mots causaux construits sans Nat
leur addition associative, commutative et cancellative
l’action additive dans les endotransformations chronologiques
la fidélité abstraite dérivée de la mémoire cumulative
l’objet RealizedCausalNat
ses lois additives complètes
la fidélité causale de sa projection d’état
le transport transcontextuel issu des payloads complets du Core
l’identification constructive à Nat seulement dans la couche finale
```

### 19.1 Traçabilité dans le dépôt

Le raccord exact est :

```text
Meta/Tarski/TruthGap.lean
  PatchableArithmeticTarskiContext
  AlgorithmStep
  step

Meta/Tarski/GenericPatchOrbit.lean
  GenericOrbitInvariant
  genericOrbit_cumulativeAgreement
  genericOrbitIndex_ne_of_lt
  genericOrbitIndex_injective
  genericOrbitCandidate_injective

Meta/Tarski/CausalMemory.lean
  CausalMemory
  CausalMemory.Remembers
  CausalMemory.correctAt_of_remembers
  CausalMemory.current_not_remembered

Meta/Tarski/CausalOrbit.lean
  CausalState
  CausalState.advance
  CausalState.advance_remembers_current_gap
  CausalState.advance_remembers_previous
  MemoryEquivalent
  CausallyEquivalent
  causalOrbit_memory_notEquivalent_of_lt
  causalOrbit_not_causallyEquivalent_of_lt

Meta/Core/RelaxedUsageRegime.lean
  CompositionalUse

Meta/Core/TransportCoherence.lean
  LawfulCompositionalUse
  CompositionalTransport

Meta/Core/DynamicRelaxedUsage.lean
  DynamicGapUse.compose
  dynamicCompositionalTransportOfReturnFamily
  dynamicTransport_preservesComposition
  DynamicGapCausalState
  GapDrivenDynamicSystem
```

Le modèle de commutation à deux états du Core prouve par ailleurs que la
transition dynamique générique peut revenir après deux pas. La fidélité
additive ne vient donc pas de `GapDrivenDynamicSystem` seul ; elle vient de
l’instance à mémoire cumulative construite par Tarski.

---

## 20. Construction formelle réalisée

La formalisation antérieure définissait l’orbite par une fonction :

```text
Nat → CausalState
```

puis prouvait son injectivité. La nouvelle formalisation est construite dans
l’ordre inverse :

```text
1. CausalWord, 0ᶜ et succᶜ définis sans Nat ;
2. +ᶜ défini et ses lois additives prouvées ;
3. eval défini et sa loi d’action additive prouvée ;
4. système abstrait à mémoire cumulative extrait ;
5. tout chemin non nul séparé de sa source ;
6. fidélité additive prouvée au point initial ;
7. RealizedCausalNat(S₀) construit ;
8. 0ʳ, succʳ et +ʳ définis ;
9. lois additives transportées à l’objet réalisé ;
10. instance tarskienne construite depuis (D), (R) et (P) ;
11. transport transcontextuel construit depuis les événements complets ;
12. CausalWord identifié à Nat seulement dans la couche finale.
```

Cette architecture est implémentée dans trois couches :

```text
Meta/Core/CausalAdditive.lean
  CausalWord, addition, multiplication, récursion
  Endchrono et action Φ pointwise
  système abstrait (A), (I), (C)
  séparation, fraîcheur et fidélité
  chemins et transports transcontextuels positifs
  RealizedCausalNat et ses lois additives

Meta/Core/CausalAdditiveNat.lean
  comparaison constructive CausalWord ↔ Nat
  compatibilité de zéro, successeur et addition

Meta/Tarski/CausalAdditiveRealization.lean
  instance fermée du système cumulatif
  action tarskienne dans Endchrono
  transport construit depuis les payloads complets du Core
  fidélité de l’orbite et de l’objet réalisé complet
```

Le premier fichier ne mentionne pas `Nat` dans ses déclarations. Le second est
la seule couche où `Nat` intervient. Le troisième ne suppose aucune loi
causale générique non instanciée : il les construit depuis le contexte de
Tarski patchable et la mémoire causale existante.

Aucun rang, aucune fenêtre, aucun générateur externe de fraîcheur, aucun pont
terminal et aucun quotient n’interviennent.

---

## 21. Architecture des théorèmes

### 21.1 Théorème algébrique des mots

Le premier théorème est indépendant de Tarski :

```text
(CausalWord,0ᶜ,succᶜ,+ᶜ)
```

vérifie :

```text
zéro
successeur
induction
récursion pointwise unique
associativité
commutativité
cancellation
```

### 21.2 Théorème abstrait d’additivité causale

Toute structure :

```text
(State,Gap,Memory,advance)
```

satisfaisant `(A)`, `(I)` et `(C)` vérifie :

```text
eval(S,u +ᶜ v) = eval(eval(S,u),v)

w ≠ 0ᶜ
→ ¬(eval(S,w) ≃ₘ S)

eval(S₀,u) ≃ₘ eval(S₀,v)
→ u = v
```

Il produit donc une représentation additive fidèle des mots causaux dans les
transformations d’états.

### 21.3 Théorème tarskien fermé

Tout contexte de Tarski patchable et tout candidat initial construisent
intrinsèquement :

```text
State   := états munis de leur mémoire causale
Gap     := phrases syntaxiques
gap(S)  := phrase diagonale du candidat courant
Memory  := appartenance positive à la mémoire causale
advance := patch diagonal canonique avec extension de mémoire
```

Les lois abstraites sont dérivées ainsi :

```text
(D) → mismatch diagonal

(R) + (P) + mismatch
→ solidité cumulative de la mémoire

solidité cumulative + mismatch
→ absence du gap courant → (A)

extension par l’événement canonique
→ inscription du gap réparé → (I)

rétention inductive des événements antérieurs
→ préservation de l’appartenance → (C)
```

La fraîcheur des gaps est ensuite redérivée de `(A)`, `(I)` et `(C)` : un gap
ancien est présent dans la mémoire future tandis que le gap courant en est
absent.

Le théorème principal n’est donc pas conditionné par un pont causal supposé.
L’instance complète du théorème abstrait est construite depuis `(D)`, `(R)` et
`(P)`.

### 21.4 Théorème de réalisation additive

Pour l’instance tarskienne :

```text
embed₀ : CausalWord → RealizedCausalNat(S₀)
```

est un plongement additif fidèle :

```text
embed₀(0ᶜ) = 0ʳ

embed₀(u +ᶜ v) = embed₀(u) +ʳ embed₀(v)

state(embed₀(u)) ≃c state(embed₀(v))
→ u = v
```

La fidélité se relève à l’objet réalisé complet :

```text
state(x) ≃c state(y)
→ x = y
```

et l’état réalisé satisfait la loi opérationnelle :

```text
state(embed₀(u +ᶜ v))
=
eval(state(embed₀(u)),v)
```

### 21.5 Théorème de transport additif transcontextuel

Cette couche est distincte du théorème abstrait de fidélité. Les lois `(A)`,
`(I)` et `(C)` suffisent pour l’action additive, la séparation et la fidélité,
mais elles ne définissent pas à elles seules les transports du Core.

On construit donc une structure positive supplémentaire :

```text
Transport : State → State → Type

identityTransport(S) : Transport(S,S)

stepTransport(S) : Transport(S,advance(S))

composeTransport :
  Transport(S,T) × Transport(T,U)
  → Transport(S,U)
```

Le chemin causal complet porte alors les transports locaux produits à chacune
de ses étapes. Pour tout état `S` et tout mot `w`, on définit récursivement :

```text
pathTransport(S,w)
```

indexé par :

```text
source = S
target = eval(S,w)
```

avec les équations de définition :

```text
pathTransport(S,0ᶜ) = transport identité en S

pathTransport(S,succᶜ(w))
=
composeTransport(
  pathTransport(S,w),
  stepTransport(eval(S,w)))
```

L’addition fournit ensuite positivement le transport composé :

```text
pathTransport(S,u +ᶜ v)
  et
composeAcross(
  pathTransport(S,u),
  pathTransport(eval(S,u),v))

ont le même type cible
Transport(S,eval(S,u +ᶜ v))
après réindexation par la loi additive de eval.
```

Dans une structure de transport arbitraire, leur égalité comme termes exige
en plus les lois d’identité, d’associativité et leur cohérence dépendante. Elle
n’est ni nécessaire à la fidélité issue de `(A)`, `(I)`, `(C)`, ni cachée dans
ces trois lois. L’implémentation construit explicitement le terme composé et
son index cible exact.

La construction repose sur les événements complets déjà mémorisés par le
chemin. Elle ne prend pas `composeAcross` comme hypothèse terminale non
instanciée dans le théorème tarskien fermé.

Dans l’instance tarskienne, `stepTransport(S)` est produit par l’état causal
dynamique complet du Core au candidat courant. La récursion sur le mot
réinstancie donc le payload de chaque pas dans le contexte effectivement
atteint, au lieu de recopier les événements d’une autre histoire.

Cette construction raccorde les deux additivités :

```text
addition des mots
→ composition des transitions d’états
→ composition cohérente des transports du Core
```

---

## 22. Théorème principal formalisé

Pour tout contexte de Tarski patchable et tout candidat initial `p₀`, il
existe un objet positif :

```text
RealizedCausalNat(p₀)
```

muni de :

```text
0ʳ      : RealizedCausalNat(p₀)
succʳ   : RealizedCausalNat(p₀) → RealizedCausalNat(p₀)
+ʳ      : RealizedCausalNat(p₀)
          → RealizedCausalNat(p₀)
          → RealizedCausalNat(p₀)

word    : RealizedCausalNat(p₀) → CausalWord
state   : RealizedCausalNat(p₀) → CausalState(p₀)
```

tel que :

```text
word(0ʳ) = 0ᶜ

word(succʳ(x)) = succᶜ(word(x))

word(x +ʳ y) = word(x) +ᶜ word(y)

state(0ʳ) = état causal initial

state(succʳ(x)) = advance(state(x))

state(x +ʳ y) = eval(state(x),word(y))

state(x) ≃c state(y)
→ x = y
```

et tel que `+ʳ` soit associative, commutative, cancellative et de neutre `0ʳ`.

Le morphisme additif porte vers les transformations causales, et non vers le
type brut des états. Posons :

```text
Φ(u)(S) := eval(S,u)
```

Les théorèmes formalisés donnent :

```text
(Nat,0,succ,+)
≅
(CausalWord,0ᶜ,succᶜ,+ᶜ)
≅
(RealizedCausalNat(p₀),0ʳ,succʳ,+ʳ)

et

(CausalWord,0ᶜ,+ᶜ)
↪
(Endchrono(CausalState(p₀)),id,⋄)

par ∀S, Φ(u +ᶜ v)(S) = (Φ(u) ⋄ Φ(v))(S)
```

Les deux premières flèches conservent et reflètent la structure naturelle et
additive. La flèche `Φ` est le morphisme additif fidèle vers les
endotransformations chronologiques.

L’orbite est séparément l’évaluation de cette action au point initial :

```text
realize₀(u) := Φ(u)(S₀)

realize₀(u) ≃c realize₀(v)
→ u = v
```

La projection :

```text
state : RealizedCausalNat(p₀) → CausalState(p₀)
```

n’est pas présentée comme un morphisme de monoïdes, car `CausalState` ne porte
pas ici d’opération binaire. Elle est équivariante pour l’action :

```text
state(x +ʳ y) = Φ(word(y))(state(x))
```

et causalement fidèle :

```text
state(x) ≃c state(y) → x = y
```

La chaîne finale est :

```text
Le mismatch détermine le prochain événement causal.
La réparation réalise l’application suivante de advance.
La préservation rend l’événement irréversible.
La mémoire sépare toutes les compositions positives.
La composition des chemins définit l’addition.
L’évaluation transforme cette addition en composition de transitions.
Tarski empêche toute contraction de cette représentation additive.
L’objet naturel causal est ainsi réalisé fidèlement dans les états complets.
```

La conclusion exacte n’est pas que Tarski crée à lui seul la syntaxe de Nat.

Elle est :

```text
La syntaxe libre des chemins porte l’objet naturel abstrait.

Le mécanisme tarskien réalise fidèlement son addition
dans une dynamique causale à mémoire cumulative.
```

---

## 23. Coordonnée naturelle canonique

L’objet naturel classique fournit une coordonnée canonique par la composition :

```text
RealizedCausalNat(S₀)
  ──word──▶ CausalWord
  ──toNat─▶ Nat
```

On nomme cette composition :

```text
coordNat : RealizedCausalNat(S₀) → Nat

coordNat(x) := toNat(word(x))
```

Cette coordonnée préserve exactement la structure naturelle additive :

```text
coordNat(0ʳ) = 0

coordNat(succʳ(x)) = Nat.succ(coordNat(x))

coordNat(x +ʳ y) = coordNat(x) + coordNat(y)
```

Elle possède l’inverse constructif :

```text
embedNat : Nat → RealizedCausalNat(S₀)

embedNat(n) := embed₀(ofNat(n))
```

et les deux lois :

```text
coordNat(embedNat(n)) = n

embedNat(coordNat(x)) = x
```

Ainsi, `coordNat` est bijective sur le porteur réalisé :

```text
RealizedCausalNat(S₀) ≅ Nat
```

Cette bijectivité interdit de comprendre `coordNat` comme une projection
visible non injective. Elle ne fusionne aucun objet réalisé et ne perd aucune
information mathématique sur ce porteur, puisque `embedNat` reconstruit
entièrement `x` depuis `coordNat(x)`.

`Nat` ne porte certes pas comme champs explicites :

```text
state(x)
memory(state(x))
les gaps successivement réparés
les événements produits dans chaque contexte
les transports causaux complets
```

mais elles sont reconstructibles relativement au système et à l’origine `S₀`.
La différence porte donc sur la présentation et la structure exposée, pas sur
l’injectivité du porteur réalisé.

Une véritable perspective visible est une application séparée :

```text
observe : RealizedCausalNat(S₀) → Visible
```

et sa difficulté classique éventuelle est :

```text
¬Injective(observe)
```

Cette propriété négative ne vient pas de `coordNat`. Elle doit être démontrée
par la théorie ou le modèle qui définit l’observation. Un certificat explicite
de collision visible constitue une donnée constructive plus forte.

La conclusion complète est donc :

```text
Nat est la coordonnée additive canonique de RealizedCausalNat(S₀).

La non-injectivité d’une perspective visible relève d’une application
distincte et d’une théorie concrète.
```

---

## 24. Statut formel

Le résultat est réparti entre trois fichiers Lean.

### 24.1 Noyau causal sans Nat

```text
Meta/Core/CausalAdditive.lean
```

Ce fichier construit et prouve :

```text
CausalWord
0ᶜ, succᶜ, +ᶜ et ×ᶜ
les lois additives internes
la récursion pointwise unique
ChronologicalEndomorphism
Φ et sa loi additive pointwise
AccumulatingCausalSystem
la séparation de tout chemin positif
la fraîcheur intrinsèque des gaps
la fidélité de eval et de Φ
les chemins de transport transcontextuels
RealizedCausalNat
les lois additives et la fidélité de l’objet réalisé
```

Les déclarations principales auditées comprennent :

```text
CausalWord.add_commutative
AccumulatingCausalSystem.wordAction_add_at
AccumulatingCausalSystem.wordAction_pointwise_faithful
AccumulatingCausalSystem.eval_faithful
RealizedCausalNat.state_add
RealizedCausalNat.memoryEquivalent_determines
RealizedCausalNat.no_positive_absorption
```

### 24.2 Identification finale à Nat

```text
Meta/Core/CausalAdditiveNat.lean
```

Ce fichier introduit `Nat` pour la première fois et construit une équivalence
constructive à deux inverses :

```text
CausalWord.equivalence : CausalWord ≅ Nat
```

avec :

```text
toNat(u +ᶜ v) = toNat(u) + toNat(v)

ofNat(n + m) = ofNat(n) +ᶜ ofNat(m)
```

Ce fichier définit également la coordonnée de l’objet réalisé. Les identifiants
Lean conservent le nom technique `naturalProjection`, mais
`naturalEquivalence` prouve qu’il s’agit d’une coordonnée bijective :

```text
RealizedCausalNat.naturalProjection
RealizedCausalNat.naturalEmbedding
RealizedCausalNat.naturalProjection_zero
RealizedCausalNat.naturalProjection_succ
RealizedCausalNat.naturalProjection_add
RealizedCausalNat.naturalEquivalence
```

### 24.3 Instance tarskienne fermée

```text
Meta/Tarski/CausalAdditiveRealization.lean
```

Pour tout `PatchableArithmeticTarskiContext` et tout candidat initial, ce
fichier construit :

```text
tarskiAccumulatingCausalSystem
tarskiCausalTransportStructure
tarskiWordAction
TarskiRealizedCausalNat
tarskiNaturalProjection
tarskiNaturalEmbedding
tarskiNaturalEquivalence
tarskiCausalAdditiveRealizationTheorem
```

Le paquet final contient l’additivité et la fidélité de la transformation,
l’additivité de l’orbite, les lois de l’objet réalisé, sa fidélité causale
complète, la non-absorption de tout incrément positif, les trois lois de la
coordonnée naturelle et son équivalence constructive avec `Nat`.

### 24.4 Audit constructif

La cible :

```text
lake build Meta.Tarski.CausalAdditiveRealization
```

compile intégralement. Les blocs `#print axioms` des trois fichiers déclarent
que toutes les déclarations principales sont indépendantes de tout axiome.
La preuve n’utilise ni `Classical`, ni `propext`, ni `Quot.sound`, ni quotient,
ni rang, ni fenêtre, ni pont terminal externe. Aucune déclaration principale
ne dépend de `FoundationBridge`.
