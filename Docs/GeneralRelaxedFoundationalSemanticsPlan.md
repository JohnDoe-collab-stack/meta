# Sémantique fondationnelle générale du transport relaxé

## Statut d'implémentation

Le plan est maintenant réalisé par la couche `Meta/Semantics`, séparée du
Core et importée en aval par `Meta.lean`.

```text
contextes et substitutions                  ContextCategory.lean
régime contextuel et naturalité             ContextualRelaxedRegime.lean
prédicats admissibles                       AdmissiblePredicateDoctrine.lean
syntaxe libre des substitutions et usages   RelaxedSyntax.lean
interprétation récursive et initialité       Interpretation.lean
correction et consistance                    Soundness.lean
conservativité de l'identité stricte         IdentityConservativity.lean
non-réduction au graphe d'usage              UseGraphNonReduction.lean
exécution interne des réparations            DynamicFoundationalStability.lean
modèle contextuel non trivial                Specialization/FiniteContextualModel.lean
raccord au gap dynamique du Core             Specialization/FiniteDynamicModel.lean
réparation cumulative non périodique         Specialization/FiniteCumulativeDynamicModel.lean
certificat fermé final                       FoundationalStability.lean
```

Le certificat final est :

```text
generalRelaxedFoundationalSemantics
```

Il contient des habitants fermés pour la syntaxe indépendante, la
conservativité, la consistance, la non-projectivité, les deux non-réductions
sémantiques et la stabilité dynamique cumulative. Les théorèmes de
consistance et de non-réduction sont dérivés des modèles ; ils ne sont pas
postulés comme champs de leurs données brutes.

## 0. Objet du plan

Le résultat actuel établit constructivement :

```text
transport par identité
⊆
transport par identité projetée
⊊
transport par usage relaxé
```

Il établit aussi une dynamique interne :

```text
gapₙ
→ usageₙ
→ transportₙ
→ réparationₙ
→ étatₙ₊₁
→ gapₙ₊₁
```

Ces résultats sont réels, mais ils ne constituent pas encore une sémantique
fondationnelle générale. Le noyau actuel permet encore de lire `Use` comme une
relation dirigée abstraite et `GapDrivenDynamicSystem` comme un système de
transition enrichi.

L’objectif de ce plan est de formaliser une couche sémantique dans laquelle :

```text
identité stricte
séparation
coordination
usage
substitution admissible
changement de contexte
transport logique
réparation causale
```

forment des jugements distincts, reliés par des théorèmes de stabilité.

Le résultat final devra démontrer simultanément :

1. la correction sémantique d’un calcul syntaxique indépendant ;
2. la stabilité du transport sous identité, composition et substitution de
   contexte ;
3. la conservation stricte de l’individuation ;
4. la conservativité du fragment classique fondé sur l’identité ;
5. l’existence d’un transport non identitaire dans un modèle fermé ;
6. la cohérence de la transition dynamique causée par une réparation ;
7. l’impossibilité de reconstruire toute la sémantique depuis le seul graphe
   dirigé des usages.

Le théorème visé n’est donc pas :

```text
une relation dirigée peut être composée
```

mais :

```text
un calcul de substitution contextuel et preuve-pertinent
peut transporter des jugements admissibles sans identifier ses termes,
possède une interprétation correcte,
conserve le fragment identitaire,
et reste stable sous une dynamique causale interne.
```

### 0.1 Portée exacte

Cette première sémantique ne prétendra pas remplacer Lean, la théorie des
types dépendants ou une théorie des ensembles complète. Elle doit établir un
résultat fondationnel précis : une extension conservative et non contractive
du calcul typé de substitution.

Le niveau atteint sera :

```text
calcul multi-sorté contextuel
+
jugement d’identité stricte
+
jugements admissibles
+
substitution relaxée
+
sémantique générale
+
soundness et consistance relative à un modèle fermé
```

Une extension ultérieure pourra traiter des types dépendants réindexés. Elle
ne doit pas être simulée dans cette phase par des égalités de types ou des
transports externes.

## 1. Frontière exacte du code actuel

### 1.1 Ce qui est déjà fermé

Les modules actuels fournissent déjà :

```text
RelaxedInterfaceRegime
HasUse
NonContractiveUse
LocalTransportChain
CompositionalUse
LawfulCompositionalUse
CompositionalTransport
ExactProjectiveRepresentation
not_exactProjective_of_asymmetric_use
IntrinsicDynamicReturnFamily
DynamicUsageMemory
DynamicGapCausalState
GapDrivenDynamicSystem
GenuinelyVaryingDynamicUsageSystem
```

La chaîne primitive est effectivement :

```text
Sep γ x y
+
Coord γ x y
→
Use γ x y
→
OutRel γ ρ (read γ ρ x) (read γ ρ y)
```

La composition des usages et celle des transports sont preuve-pertinentes.
Le transport préserve les identités et la composition.

### 1.2 Ce qui manque encore

#### Séparation non normalisée

Dans `RelaxedInterfaceRegime`, le champ :

```lean
Sep : Ctx → X → X → Type
```

est une famille arbitraire. Le noyau ne demande pas encore :

```lean
Sep γ x y → x = y → False
```

Une instance pourrait donc prendre `Sep := Unit`. Le nom « séparation » ne
suffit pas à garantir l’individuation.

#### Relation de sortie sans sémantique logique

Le champ :

```lean
OutRel γ ρ outputX outputY
```

est également arbitraire. Il peut représenter une égalité, une implication,
une transformation, ou `Unit`. Le noyau établit un transport relationnel, mais
pas encore une règle de substitution dans un langage de jugements.

#### Absence de substitutions de contexte

Les contextes sont des objets de `Ctx`, mais il n’existe pas encore :

```text
substitution Δ → Γ
reindexation des termes
reindexation des lectures
reindexation des usages
naturality du transport
```

La composition actuelle est interne à un contexte fixé.

#### Absence de syntaxe indépendante

Les structures actuelles sont directement sémantiques. Il n’existe pas encore
de calcul inductif de dérivations dont l’interprétation serait prouvée correcte
dans tout modèle.

Sans cette séparation, un champ appelé `transport` peut être lu comme la
donnée même que le théorème devrait expliquer.

#### Causalité dynamique encore trop permissive au niveau générique

Le champ :

```lean
advance :
  (Σ source, DynamicGapCausalState family source) → Source
```

reçoit bien l’état causal complet, mais une fonction particulière peut encore
l’ignorer. Les instances Tarski et `switch` exploitent réellement cet état ;
le type générique ne caractérise pas encore l’effet observable de la cause.

## 2. Définition de la stabilité fondationnelle

Une sémantique relaxée sera dite fondationnellement stable si elle satisfait
les six groupes de propriétés suivants.

### 2.1 Stabilité de l’individuation

```text
Sep Γ A x y
→
x = y
→
False
```

L’usage ne doit fournir aucun éliminateur permettant d’obtenir `x = y`.

### 2.2 Stabilité du calcul de transport

```text
use id
→ transport id

use₁ ; use₂
→ transport use₁ ; transport use₂

(use₁ ; use₂) ; use₃
=
use₁ ; (use₂ ; use₃)
```

Ces lois doivent porter sur les témoins, pas seulement sur `HasUse`.

### 2.3 Stabilité contextuelle

Pour toute substitution `σ : Δ ⇒ Γ` :

```text
Use Γ A x y
→
Use Δ A (x[σ]) (y[σ])
```

et :

```text
transport (use[σ]) (ρ[σ])
=
(transport use ρ)[σ]
```

La même naturalité est exigée pour `Sep`, `Coord` et les jugements logiques
admissibles.

### 2.4 Stabilité logique

Pour tout prédicat admissible `P` :

```text
Use Γ A x y
+
P x
→
P y
```

Cette règle est directionnelle. Elle ne doit pas s’appliquer automatiquement
à tous les prédicats `Term Γ A → Prop`, car le prédicat :

```text
z ↦ z = x
```

contracterait tout usage `x → y` en une égalité `x = y`.

La théorie doit donc distinguer formellement :

```text
prédicats d’identité stricte
≠
prédicats admissibles au transport relaxé.
```

### 2.5 Stabilité interprétative

Les règles syntaxiques doivent être définies indépendamment du modèle.
L’interprétation doit être une fonction récursive et la correction doit être
prouvée par induction sur les dérivations.

Il est interdit de mettre :

```lean
soundness : ...
consistency : ...
```

comme champs primitifs d’une structure finale.

### 2.6 Stabilité dynamique

La transition doit être obtenue depuis la réparation portée par le gap
courant :

```text
state
→ causalState state
→ repairAt state
→ applyRepair
→ next state
```

Elle doit produire un effet démontré :

```text
mismatch(state, challenge state)

correct(next state, challenge state)

stable(state, oldJudgment)
→
stable(next state, oldJudgment)
```

Une fonction `next` arbitraire ou un champ affirmant directement ces trois
propriétés ne constitue pas la fermeture recherchée.

## 3. Contraintes anti-trivialité

La réalisation finale est refusée si elle emploie l’un des raccourcis
suivants.

### 3.1 Interdictions structurelles

```text
Sep := Unit
Coord := Unit
Use := Unit
OutRel := Unit
Pred := Unit
Holds := True
Visible := Unit
project := constante
Sub := seulement l’identité
next := fonction arbitraire sans loi d’effet
syntax := semantics
```

### 3.2 Interdictions logiques

```text
axiom
sorry
admit
Classical
propext
Quot.sound
funext
noncomputable
unsafe
```

### 3.3 Interdictions architecturales

Le résultat final ne doit pas être remplacé par :

```text
si une interprétation correcte existe, alors le calcul est correct ;

si une réparation préserve les invariants, alors les invariants sont
préservés ;

si un pont terminal existe, alors la dynamique se ferme ;

si un modèle non trivial existe, alors la théorie est consistante.
```

Il faut construire :

```text
une interprétation effective ;
un modèle fermé non trivial ;
une réparation exécutable ;
les preuves de préservation ;
un témoin explicite de non-réduction au graphe d’usage.
```

## 4. Architecture cible

La couche sémantique ne doit pas être enfouie dans `Meta/Core`. Le Core reste
le langage structurel générique. La nouvelle couche l’interprète.

```text
Meta/Semantics/
  ContextCategory.lean
  ContextualRelaxedRegime.lean
  AdmissiblePredicateDoctrine.lean
  RelaxedSyntax.lean
  Interpretation.lean
  Soundness.lean
  IdentityConservativity.lean
  UseGraphNonReduction.lean
  DynamicFoundationalStability.lean

Meta/Semantics/Specialization/
  FiniteContextualModel.lean
  FiniteDynamicModel.lean
```

Graphe d’import imposé :

```text
Meta/Core
  ↓
Meta/Semantics structures génériques
  ↓
Meta/Semantics/Specialization modèles fermés
```

Aucun module de `Meta/Core` ne doit importer `Meta/Semantics`.

## 5. Catégorie constructive de contextes

### 5.1 Structure brute

Dans `ContextCategory.lean` :

```lean
structure ContextCategory where
  Ctx : Type u

  Sub : Ctx → Ctx → Type v

  identity :
    (Γ : Ctx) → Sub Γ Γ

  compose :
    {Θ Δ Γ : Ctx} →
    Sub Θ Δ →
    Sub Δ Γ →
    Sub Θ Γ
```

La convention sera :

```text
σ : Sub Δ Γ
```

signifie que les données de `Γ` peuvent être réindexées dans `Δ`.

### 5.2 Lois

Ajouter séparément :

```lean
structure LawfulContextCategory
    (C : ContextCategory) where
  leftIdentity : ...
  rightIdentity : ...
  associativity : ...
```

Les lois portent sur les témoins de substitution eux-mêmes.

### 5.3 Non-trivialité requise dans le modèle fermé

Le modèle final doit exhiber :

```text
Γ ≠ Δ

σ : Sub Δ Γ

σ n’est pas l’identité par typage
```

et une lecture dont la réindexation n’est pas définitionnellement `rfl`.

## 6. Termes indexés et régime relaxé contextuel

### 6.1 Langage multi-sorté

Dans `ContextualRelaxedRegime.lean` :

```lean
structure IndexedTermLanguage
    (C : ContextCategory) where
  Sort : Type s

  Term :
    C.Ctx → Sort → Type t

  reindexTerm :
    {Δ Γ : C.Ctx} →
    C.Sub Δ Γ →
    {A : Sort} →
    Term Γ A →
    Term Δ A
```

Les sortes restent fixes sous substitution. Cette première version évite de
cacher le travail dans des transports dépendants de preuves d’égalité entre
types réindexés.

### 6.2 Données du régime

```lean
structure ContextualRelaxedRegime
    (C : ContextCategory)
    (L : IndexedTermLanguage C) where
  Read :
    (Γ : C.Ctx) →
    (A : L.Sort) →
    Type r

  Out :
    (Γ : C.Ctx) →
    (A : L.Sort) →
    Read Γ A →
    Type o

  read :
    {Γ : C.Ctx} →
    {A : L.Sort} →
    (ρ : Read Γ A) →
    L.Term Γ A →
    Out Γ A ρ

  Sep :
    {Γ : C.Ctx} →
    {A : L.Sort} →
    L.Term Γ A →
    L.Term Γ A →
    Type sep

  Coord : ...
  Use : ...
  OutRel : ...

  useOfNoncontractive :
    Sep x y → Coord x y → Use x y

  transport :
    Use x y →
    (ρ : Read Γ A) →
    OutRel ρ (read ρ x) (read ρ y)
```

### 6.3 Réindexations

La structure doit également porter des opérations :

```text
reindexRead
reindexOut
reindexSep
reindexCoord
reindexUse
reindexOutRel
```

mais les lois seront placées dans une structure distincte :

```lean
structure LawfulContextualRelaxedRegime ... where
  termIdentity : ...
  termComposition : ...

  readIdentity : ...
  readComposition : ...

  useIdentity : ...
  useComposition : ...

  separationRefutesIdentity :
    Sep x y → x = y → False

  transportIdentity : ...
  transportComposition : ...
  transportReindexing : ...
```

### 6.4 Raccord exact au Core existant

Pour chaque fibre `(Γ, A)`, définir :

```lean
def ContextualRelaxedRegime.fiberRegime
    (M : ContextualRelaxedRegime C L)
    (Γ : C.Ctx)
    (A : L.Sort) :
    RelaxedInterfaceRegime (L.Term Γ A)
```

Le raccord doit conserver exactement :

```text
Read
Out
read
Sep
Coord
Use
OutRel
transport
```

Les théorèmes suivants sont requis :

```text
fiberUse_eq
fiberTransport_eq
fiberNonContractiveUse_eq
fiberCompositionalTransport
```

La couche sémantique ne doit pas réimplémenter une seconde théorie du Core.

## 7. Doctrine des prédicats admissibles

### 7.1 Pourquoi une doctrine séparée est nécessaire

Une relation dirigée sait seulement dire :

```text
x → y
```

Une théorie de substitution doit préciser :

```text
quels jugements peuvent être transportés ;
comment ils sont interprétés ;
comment ils changent de contexte ;
quelles opérations logiques ils supportent.
```

### 7.2 Structure

Dans `AdmissiblePredicateDoctrine.lean` :

```lean
structure AdmissiblePredicateDoctrine
    (M : ContextualRelaxedRegime C L) where
  Pred :
    (Γ : C.Ctx) →
    (A : L.Sort) →
    Type p

  Holds :
    {Γ : C.Ctx} →
    {A : L.Sort} →
    Pred Γ A →
    L.Term Γ A →
    Prop

  top : Pred Γ A
  bottom : Pred Γ A
  and : Pred Γ A → Pred Γ A → Pred Γ A

  reindexPred :
    C.Sub Δ Γ →
    Pred Γ A →
    Pred Δ A

  substituteUse :
    M.Use x y →
    Holds P x →
    Holds P y
```

### 7.3 Lois logiques

```text
Holds top x

Holds bottom x → False

Holds (and P Q) x
↔
Holds P x × Holds Q x

Holds (reindexPred σ P) (reindexTerm σ x)
↔
Holds P x
```

La dernière loi peut être orientée par deux fonctions plutôt que par une
équivalence propositionnelle si cela évite toute dépendance à `propext`.

### 7.4 Frontière avec l’identité

Définir explicitement :

```lean
def StrictIdentity
    (x y : L.Term Γ A) : Prop :=
  x = y
```

Ne pas ajouter automatiquement :

```lean
identityPredicate x : Pred Γ A
```

Si une instance souhaite rendre certains prédicats d’identité admissibles,
elle devra fournir une structure positive locale et prouver qu’elle ne
contracte pas le gap concerné.

## 8. Syntaxe indépendante

### 8.1 Signature

Dans `RelaxedSyntax.lean`, définir une signature qui ne contient aucun modèle :

```lean
structure RelaxedTransportSignature where
  ContextAtom : Type u
  Sort : Type s

  SubAtom :
    ContextAtom → ContextAtom → Type v

  TermAtom :
    ContextAtom → Sort → Type t

  SeparationAtom : ...
  CoordinationAtom : ...
  PredicateAtom : ...
```

### 8.2 Substitutions libres

```lean
inductive Substitution : Context → Context → Type
  | identity
  | atom
  | compose
```

### 8.3 Termes et réindexation

```lean
inductive Term : Context → Sort → Type
  | atom
  | reindex
```

Les lois de réindexation seront imposées par une relation de normalisation
inductive ou par des théorèmes de congruence, pas par un quotient.

### 8.4 Dérivations de séparation et coordination

```lean
inductive SeparationDerivation :
    Term Γ A → Term Γ A → Type
  | atom
  | reindex

inductive CoordinationDerivation :
    Term Γ A → Term Γ A → Type
  | atom
  | reindex
```

### 8.5 Dérivations d’usage

```lean
inductive UseDerivation :
    Term Γ A → Term Γ A → Type
  | identity
  | noncontractive
      (sep : SeparationDerivation x y)
      (coord : CoordinationDerivation x y)
  | compose
      (first : UseDerivation x y)
      (second : UseDerivation y z)
  | reindex
      (σ : Substitution Δ Γ)
      (use : UseDerivation x y)
```

Cette définition est essentielle : les usages syntaxiques sont générés par les
règles annoncées. Ils ne sont pas une relation arbitraire fournie par le
modèle.

### 8.6 Formules et preuves

Construire un fragment logique minimal :

```lean
inductive Formula
  | atom
  | top
  | bottom
  | and
  | at

inductive Judgment
  | holds
      (formula : Formula)
  | strictIdentity
      (left right : Term Γ A)

inductive Proof
  | assumption
  | topIntro
  | andIntro
  | andLeft
  | andRight
  | identityRefl
  | identitySymm
  | identityTrans
  | identityReindex
  | transport
      (use : UseDerivation x y)
      (proof : Proof assumptions (Judgment.holds (Formula.at P x)))
```

La conclusion de `transport` est :

```text
Proof assumptions (Judgment.holds (Formula.at P y))
```

Il n’existe aucun constructeur :

```text
UseDerivation x y
→
Proof assumptions (Judgment.strictIdentity x y)
```

Cette absence rend possible le théorème de conservativité précis. Le transport
relaxé peut produire de nouveaux jugements admissibles ; il ne produit pas de
nouvelles identités strictes.

Le fragment est volontairement minimal. Ajouter implication, quantification ou
égalité interne avant la preuve de stabilité augmenterait inutilement le
risque de contraction.

## 9. Interprétation et correction

### 9.1 Interprétation des symboles

Dans `Interpretation.lean` :

```lean
structure RelaxedInterpretation
    (Σ : RelaxedTransportSignature)
    (M : LawfulContextualRelaxedRegime ...) where
  contextAtom : ...
  substitutionAtom : ...
  termAtom : ...
  separationAtom : ...
  coordinationAtom : ...
  predicateAtom : ...
```

La structure ne contient ni interprétation des dérivations, ni correction.

### 9.2 Fonctions récursives

Définir par récursion :

```text
interpretSubstitution
interpretTerm
interpretSeparation
interpretCoordination
interpretUse
interpretFormula
```

### 9.3 Théorème de transport sémantique

```lean
theorem interpretUse_transport
    (use : UseDerivation x y)
    (holds : Holds (interpretPredicate P) (interpretTerm x)) :
    Holds (interpretPredicate P) (interpretTerm y)
```

La preuve doit être une induction sur `use`.

Cas obligatoires :

```text
identity
noncontractive
compose
reindex
```

### 9.4 Théorème de correction global

Dans `Soundness.lean` :

```lean
theorem relaxedProof_sound
    (derivation : Proof assumptions conclusion)
    (environment : SemanticallySatisfies assumptions) :
    SemanticallyHolds conclusion
```

La preuve est une induction sur la dérivation syntaxique.

### 9.5 Initialité opérationnelle

Ajouter un principe d’unicité : toute fonction des dérivations d’usage vers un
modèle qui préserve :

```text
identity
noncontractive
composition
reindexation
```

coïncide avec `interpretUse`.

La conclusion doit être formulée point par point :

```lean
theorem interpretUse_unique
    (other : ...)
    (preservesIdentity : ...)
    (preservesNoncontractive : ...)
    (preservesComposition : ...)
    (preservesReindexing : ...) :
    ∀ use, other use = interpretUse use
```

Il ne faut pas transformer cette conclusion en égalité de fonctions par
`funext`.

Ce théorème montre que le calcul est la fermeture libre des règles primitives,
et non une relation ajoutée après coup.

## 10. Consistance, non-contraction et conservativité

### 10.1 Consistance du fragment logique

Définir :

```lean
def ClosedContradiction : Prop :=
  Nonempty (Proof [] (Judgment.holds Formula.bottom))
```

Depuis un modèle fermé où `bottom` n’est jamais satisfait et depuis le théorème
de correction :

```lean
theorem noClosedContradiction :
    ClosedContradiction → False
```

Ce théorème doit être dérivé. Il ne doit pas être un champ du modèle.

### 10.2 Non-contraction

```lean
theorem separatedUse_doesNotIdentify
    (sep : SeparationDerivation x y)
    (use : UseDerivation x y) :
    interpretTerm x = interpretTerm y → False
```

Le témoin d’usage reste disponible. Seule l’égalité interne est réfutée.

### 10.3 Fragment d’identité stricte

Définir le sous-calcul :

```text
StrictIdentityDerivation x y
```

généré uniquement par :

```text
réflexivité
symétrie
transitivité
réindexation
congruence des constructeurs syntaxiques
```

Puis définir son inclusion dans les jugements du calcul complet :

```lean
def strictIdentityEmbedding :
  StrictIdentityDerivation x y →
  Proof assumptions (Judgment.strictIdentity x y)
```

L’identité peut également produire un usage réflexif par
`UseDerivation.identity`, mais ce raccord ne doit jamais être inversé pour un
usage non identitaire.

### 10.4 Conservativité

Le théorème exact porte sur les conclusions d’identité stricte :

```lean
theorem strictIdentity_conservative
    (derivation :
      Proof identityAssumptions
        (Judgment.strictIdentity x y)) :
    StrictIdentityDerivation x y
```

La preuve doit procéder par induction et inversion de `derivation`. Le cas
`transport` est impossible par l’indice de sa conclusion.

Avec `strictIdentityEmbedding`, on obtient :

```text
identité stricte dérivable dans le sous-calcul
↔
identité stricte dérivable dans le calcul complet.
```

Il serait faux de demander la conservativité pour tous les jugements
admissibles : le but même de la relaxation est d’autoriser de nouveaux
transports de ces jugements.

### 10.5 Stricte extension

Construire dans le modèle fermé :

```text
Use x y
x ≠ y
¬ Use y x
```

Puis dériver :

```text
aucune interprétation exacte de cet usage par égalité projetée.
```

Le théorème actuel `not_exactProjective_of_asymmetric_use` doit être réutilisé,
pas redémontré.

## 11. Non-réduction au graphe dirigé

Cette section est indispensable à la revendication fondationnelle.

### 11.1 Foncteur d’oubli

Définir la vue :

```lean
def underlyingUseGraph
    (M : LawfulContextualRelaxedRegime ...) :
    ContextIndexedDirectedGraph
```

Elle oublie :

```text
Sep
Coord
témoins de Use
Read
Out
OutRel
prédicats admissibles
réindexation logique
transport
réparations
```

et ne garde que `HasUse`.

### 11.2 Un squelette commun, deux transports

Construire d’abord un squelette commun :

```lean
structure CommonUseSkeleton where
  contextCategory : ContextCategory
  language : IndexedTermLanguage contextCategory
  Sep : ...
  Coord : ...
  Use : ...
  identity : ...
  compose : ...
  reindexUse : ...
```

Les modèles `M₁` et `M₂` doivent utiliser définitionnellement ce même
squelette. Ils ne peuvent différer que dans les lectures, sorties, relations
de sortie et interprétations du transport.

Construire ensuite deux modèles fermés tels que :

```text
SameUseGraph M₁ M₂
```

Les deux modèles doivent avoir :

```text
au moins deux lectures ;
des sorties non constantes ;
des relations de sortie habitées et réfutées selon les cas ;
un transport qui analyse réellement le témoin d’usage.
```

Produire un usage commun `use : Use x y` et une lecture commune codée `ρ` dont
les transports donnent deux résultats observables distincts :

```text
observe₁ (transport₁ use ρ) = true

observe₂ (transport₂ use ρ) = false
```

Les fonctions d’observation doivent être définies sur des types de résultats
concrets ; elles ne doivent pas être ajoutées comme champs arbitraires du
théorème de distinction.

En aval, construire également un prédicat explicite `P`, un contexte `Γ` et
un terme `x` tels que :

```text
Holds₁ P x

Holds₂ P x → False
```

Ne pas prouver `M₁ ≠ M₂` par extensionalité de fonctions. Porter un témoin
positif :

```lean
structure SemanticDistinction (M₁ M₂ : ...) where
  context : ...
  sort : ...
  term : ...
  predicateLeft : ...
  predicateRight : ...
  leftHolds : ...
  rightRefuted : ... → False
```

Ajouter séparément :

```lean
structure TransportSemanticDistinction (M₁ M₂ : ...) where
  use : ...
  reading : ...
  leftResult : ...
  rightResult : ...
  leftObserved : observeLeft leftResult = true
  rightObserved : observeRight rightResult = false
```

### 11.3 Théorème central de non-réduction

```lean
def useGraphDoesNotDetermineSemantics :
  Σ M₁ M₂,
    SameUseGraph M₁ M₂ ×
    TransportSemanticDistinction M₁ M₂ ×
    SemanticDistinction M₁ M₂
```

Ce résultat établit formellement :

```text
graphe d’usage identique
≠
sémantique de substitution identique.
```

La théorie contient donc strictement plus d’information qu’un système de
transitions dirigées.

## 12. Sémantique dynamique causale

### 12.1 Remplacer la transition arbitraire au niveau sémantique

Dans `DynamicFoundationalStability.lean`, définir :

```lean
structure RepairAlgebra
    (family : IntrinsicDynamicReturnFamily ...) where
  applyRepair :
    (source : Source) →
    RepairOf (family.formedAt source) →
    Source
```

Puis :

```lean
def repairDrivenNext
    (algebra : RepairAlgebra family)
    (source : Source) : Source :=
  algebra.applyRepair source (family.repairAt source)
```

Le système dynamique est construit depuis cette fonction. Il ne reçoit pas un
second `next` indépendant.

### 12.2 Certificat d’effet causal

```lean
structure RepairEffect
    (algebra : RepairAlgebra family)
    (source : Source) where
  challenge : Challenge source

  mismatchBefore :
    RefutesAt source challenge

  repairedAfter :
    HoldsAt (repairDrivenNext algebra source) challenge

  sourceChanges :
    source = repairDrivenNext algebra source → False

  oldStable :
    ∀ old,
      StableBefore source old →
      StableAfter (repairDrivenNext algebra source) old
```

Le défi, le mismatch et la réparation doivent être calculés depuis
`DynamicGapCausalState family source`.

### 12.3 Théorème de stabilité d’un pas

```lean
theorem repairDrivenStep_stable
    (source : Source) :
    FoundationallyStableStep
      source
      (repairDrivenNext algebra source)
```

Le résultat doit exposer :

```text
préservation du typage
préservation des séparations
préservation des usages persistants
préservation des jugements déjà réparés
correction du challenge courant
production du prochain état causal
```

### 12.4 Théorème d’orbite

```lean
def iterateRepair : Nat → Source → Source

theorem repairOrbit_stable
    (n : Nat) :
    StableState (iterateRepair n initial)
```

La preuve doit être une induction sur `n` utilisant le théorème de stabilité
d’un pas.

Ne pas ajouter de `rank`, de `windowFor`, de borne terminale ou de pont externe
à la structure générique.

## 13. Modèle contextuel fermé non trivial

### 13.1 Données minimales

`FiniteContextualModel.lean` doit contenir au moins :

```text
deux contextes distincts ;
une substitution non identité ;
une sorte ;
trois termes distincts ;
un usage directionnel composé ;
une séparation qui réfute réellement l’égalité ;
deux lectures distinctes ;
une sortie non constante ;
une relation de sortie non triviale ;
plusieurs prédicats admissibles ;
un prédicat vrai sur certains termes et faux sur d’autres.
```

### 13.2 Modèle recommandé

Réutiliser la géométrie :

```text
before → during → after
```

mais ajouter une vraie structure contextuelle :

```text
coarse
fine

refine : Sub fine coarse
```

Les prédicats admissibles peuvent être des codes finis monotones :

```text
top
reachedDuring
reachedAfter
and P Q
```

avec une interprétation calculable. La monotonie le long des usages doit être
prouvée par analyse des constructeurs.

### 13.3 Tests obligatoires

```text
before ≠ during
during ≠ after
before ≠ after

Use before during
Use during after
Use before after

¬ Use after before

transport (before → after)
=
transport (before → during) ; transport (during → after)

reindex (use₁ ; use₂)
=
reindex use₁ ; reindex use₂

Holds reachedDuring during
Holds reachedDuring after
¬ Holds reachedDuring before
```

### 13.4 Consistance fermée

Le modèle doit produire :

```lean
def finiteFoundationalModel :
  ClosedRelaxedFoundationalModel

theorem finiteModel_noClosedContradiction :
  ClosedContradiction → False
```

`ClosedRelaxedFoundationalModel` doit contenir les données du modèle, pas le
théorème `noClosedContradiction`. Celui-ci est dérivé par soundness.

## 14. Modèle dynamique fermé

Dans `FiniteDynamicModel.lean`, prolonger le modèle contextuel par une
réparation réelle.

### 14.1 État

```text
state₀ : current = before
state₁ : current = during
state₂ : current = after
```

### 14.2 Challenge et réparation

Chaque état porte un challenge calculé. La réparation doit modifier la donnée
syntaxique qui échoue, pas seulement changer une étiquette d’état.

### 14.3 Propriétés exigées

```text
mismatch₀
repair₀
correct₁ challenge₀

mismatch₁
repair₁
correct₂ challenge₁

correct₂ challenge₀
```

La dernière propriété vérifie la stabilité cumulative.

### 14.4 Non-réduction dynamique

Construire deux lectures causales partageant définitionnellement :

```text
le type Source ;
l’état initial ;
la famille de gaps ;
la fonction repairDrivenNext ;
l’orbite des états.
```

Elles ont donc le même graphe d’états :

```text
state₀ → state₁ → state₂
```

La distinction doit porter sur deux challenges internes différents dont le
même état suivant certifie les corrections. Chaque lecture doit contenir :

```text
un challenge calculé depuis le gap courant ;
un mismatch avant transition ;
une correction après transition ;
une provenance vers la réparation consommée.
```

Produire un témoin `DynamicSemanticDistinction` identifiant explicitement le
challenge et le jugement réparé de chaque lecture, plutôt qu’une inégalité
extensionnelle entre fonctions.

Cela démontrera :

```text
graphe de transition identique
≠
causalité sémantique identique.
```

## 15. Théorèmes principaux attendus

### 15.1 Théorèmes génériques

```text
contextualUse_reindex
contextualTransport_identity
contextualTransport_composition
contextualTransport_reindex

interpretUse_transport
relaxedProof_sound
interpretUse_unique

separation_refutes_internalIdentity
separatedUse_doesNotIdentify

strictIdentityEmbedding
strictIdentity_conservative

underlyingUseGraph
useGraphDoesNotDetermineSemantics

repairDrivenStep_stable
repairOrbit_stable
```

### 15.2 Habitants fermés

```text
finiteFoundationalModel
finiteModel_noClosedContradiction
finiteModel_strictRelaxation
finiteModel_useGraphSemanticDistinction

finiteRepairAlgebra
finiteRepairEffects
finiteDynamicFoundationalSystem
finiteDynamicOrbitStable
finiteTransitionGraphSemanticDistinction
```

### 15.3 Théorème de synthèse final

```lean
structure RelaxedFoundationalStabilityTheorem where
  syntaxSound : ...
  closedConsistency : ...
  identityConservative : ...
  strictNonIdentityUse : ...
  contextualNaturality : ...
  dynamicStability : ...
  useGraphInsufficient : ...
  transitionGraphInsufficient : ...
```

Puis construire :

```lean
def relaxedFoundationalStabilityTheorem :
  RelaxedFoundationalStabilityTheorem
```

Chaque champ doit être rempli par un théorème déjà démontré. La structure ne
doit pas servir à postuler les propriétés.

## 16. Ordre d’implémentation

### Phase A — contextualisation

1. créer `ContextCategory.lean` ;
2. créer `IndexedTermLanguage` ;
3. créer `ContextualRelaxedRegime` ;
4. séparer données et lois ;
5. construire `fiberRegime` vers le Core existant ;
6. prouver les lois de naturalité.

### Phase B — doctrine logique

1. définir les prédicats admissibles ;
2. définir `Holds` ;
3. ajouter `top`, `bottom`, `and` ;
4. prouver la substitution par usage ;
5. prouver la réindexation des jugements ;
6. maintenir l’identité stricte hors du fragment admissible automatique.

### Phase C — syntaxe et interprétation

1. définir la signature indépendante ;
2. définir substitutions, termes, séparations et coordinations ;
3. définir `UseDerivation` ;
4. définir formules et preuves ;
5. définir l’interprétation récursive ;
6. prouver soundness par induction ;
7. prouver l’unicité de l’interprétation des usages.

### Phase D — stabilité fondationnelle statique

1. dériver la consistance depuis le modèle ;
2. prouver la non-contraction ;
3. construire l’inclusion du fragment identitaire ;
4. prouver sa conservativité ;
5. réutiliser l’obstruction générique par asymétrie ;
6. construire deux doctrines sur le même graphe ;
7. prouver la non-réduction sémantique.

### Phase E — stabilité dynamique

1. définir `RepairAlgebra` ;
2. dériver `repairDrivenNext` ;
3. définir le certificat d’effet ;
4. prouver la stabilité d’un pas ;
5. prouver la stabilité de l’orbite ;
6. construire deux causalités sur le même graphe de transitions ;
7. prouver la non-réduction dynamique.

### Phase F — clôture

1. construire le modèle contextuel fermé ;
2. construire le modèle dynamique fermé ;
3. remplir `RelaxedFoundationalStabilityTheorem` ;
4. importer le théorème final dans `Meta.lean` ;
5. compiler le dépôt complet ;
6. auditer tous les axiomes.

## 17. Audits obligatoires

Chaque fichier Lean nouveau ou modifié doit finir par un unique bloc :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms <déclarations principales>
/- AXIOM_AUDIT_END -/
```

Commandes minimales :

```text
lake env lean Meta/Semantics/ContextCategory.lean
lake env lean Meta/Semantics/ContextualRelaxedRegime.lean
lake env lean Meta/Semantics/AdmissiblePredicateDoctrine.lean
lake env lean Meta/Semantics/RelaxedSyntax.lean
lake env lean Meta/Semantics/Interpretation.lean
lake env lean Meta/Semantics/Soundness.lean
lake env lean Meta/Semantics/IdentityConservativity.lean
lake env lean Meta/Semantics/UseGraphNonReduction.lean
lake env lean Meta/Semantics/DynamicFoundationalStability.lean
lake env lean Meta/Semantics/Specialization/FiniteContextualModel.lean
lake env lean Meta/Semantics/Specialization/FiniteDynamicModel.lean
lake build
```

Contrôle textuel :

```text
aucun axiom
aucun sorry
aucun admit
aucun Classical
aucun propext
aucun Quot.sound
aucun funext
aucun noncomputable
aucun unsafe
exactement un AXIOM_AUDIT par fichier Lean
```

## 18. Critères de clôture scientifique

Le chantier ne sera pas déclaré terminé tant que les affirmations suivantes
ne seront pas toutes démontrées dans Lean.

```text
1. les dérivations syntaxiques ont une interprétation calculée ;

2. la correction est prouvée par induction ;

3. la substitution relaxée commute aux changements de contexte ;

4. les usages et transports respectent identité, composition et
   associativité ;

5. une séparation réfute effectivement l’égalité interne ;

6. le fragment identitaire est conservativement inclus ;

7. un usage séparé et asymétrique est effectivement habité ;

8. le modèle fermé réfute toute contradiction syntaxique close ;

9. deux doctrines ayant le même graphe d’usage sont sémantiquement
   distinguées ;

10. la transition dynamique est calculée depuis la réparation courante ;

11. la réparation corrige le challenge courant et préserve les acquis ;

12. deux systèmes ayant le même graphe de transitions peuvent porter des
    causalités sémantiques distinctes ;

13. le théorème final est un habitant fermé ;

14. tous les audits sont constructifs et sans axiome interdit.
```

## Conclusion

La sémantique générale recherchée doit établir trois séparations irréductibles :

```text
identité stricte
≠
usage autorisé

graphe d’usage
≠
sémantique du transport

graphe de transition
≠
causalité de la réparation
```

La stabilité fondationnelle sera alors exprimée par la chaîne :

```text
syntaxe indépendante
→ interprétation contextuelle
→ soundness
→ non-contraction
→ conservativité de l’identité
→ stricte extension par usage
→ réparation causale
→ stabilité dynamique
```

Ce résultat dépasserait une théorie des relations dirigées parce que le graphe
des usages ne déterminerait ni les jugements admissibles, ni leur transport,
ni leur réindexation, ni l’effet causal des réparations. Ces données seraient
liées par un calcul syntaxique, une interprétation générale et des théorèmes de
stabilité effectivement compilés.
