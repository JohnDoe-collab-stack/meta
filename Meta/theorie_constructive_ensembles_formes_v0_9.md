# Théorie constructive des ensembles formés
## Esquisse fondationnelle issue de la diagonalisation positive

**Statut :** document de travail, version 0.9 — audit fermé du Markdown, scènes de vérité explicites et modèles jouets  
**Objet :** commencer la formalisation d’une théorie des ensembles dans laquelle l’existence fondamentale est portée comme donnée, la projection visible n’épuise pas la formation interne, et la diagonalisation constructive est une formation positive dépendamment témoignée.

Les formules sont écrites en Unicode ordinaire. Les signatures sont volontairement proches de Lean, sans prétendre constituer encore un fichier compilable.


### Convention de force

Le document distingue désormais trois niveaux qui ne doivent pas être confondus :

```text
signature primitive :
  types, projections et familles de témoins

structure de formation :
  donnée formée accompagnée de ses règles internes

loi de projection :
  compatibilité supplémentaire entre la formation interne
  et l’univers visible
```

Une loi visible n’est jamais considérée comme dérivée de la seule règle interne
sans champ ou théorème supplémentaire. De même, un constructeur global tel que
`pair⁺` est une donnée primitive de formation ; il ne doit pas être obtenu par
choix à partir d’une simple existence propositionnelle.

### Statut formel exact

Le présent document ne définit pas encore une théorie matérielle du premier
ordre comparable terme à terme à ZF ou CZF. Il spécifie une théorie
dépendamment typée à deux sortes :

```text
FormedSet
VisibleSet
```

dans une métathéorie munie de `Type`, `Prop`, fonctions dépendantes et sommes
dépendantes. Une future « théorie des ensembles » pourra être obtenue de deux
manières distinctes :

```text
1. comme théorie type-théorique primitive de ces deux sortes ;

2. comme modèle interne d’une théorie ensembliste formulée séparément.
```

Ces deux programmes ne doivent pas être confondus. En particulier, les
quantifications sur `FormedSet → Prop` sont actuellement métathéoriques ; elles
ne constituent pas encore un schéma syntaxique du premier ordre.

### Convention sur le mot « positif »

Dans ce document, « positif » signifie d’abord :

```text
présenté par un type ou une structure habitée
qui expose ses pôles, son témoin et ses opérations
```

Il ne signifie pas que la définition appartient au fragment positif de la
logique au sens proof-théorique. Une cellule diagonale contient notamment :

```text
separated :
  formed = shadow → False
```

qui est une donnée négative constructive. L’affirmativité vient de
l’existence d’un paquet explicite contenant ce réfutateur, et non de l’absence
de toute négation dans ses champs.

De même, le mot « obstruction » désigne une donnée affirmative d’obstruction,
pas une formule purement positive au sens de la logique géométrique.

Le niveau formé est volontairement preuve-pertinent. Il se comporte donc
davantage comme un univers de présentations, de contenants ou de formations que
comme un univers extensionnel de sets au sens ordinaire. Le niveau visible est
le candidat set-like sur lequel l’extensionalité agit.

---

## 0. Thèse fondatrice

La théorie part du déplacement suivant :

```text
un ensemble n’est pas seulement sa lecture visible ;
il est une formation positive
munie d’une projection.

Cette projection mérite le nom d’« extension visible » seulement lorsqu’une
loi d’adéquation de l’appartenance est ajoutée.
```

La forme centrale n’est pas :

```text
une contradiction
une impossibilité
un point fixe
une négation d’injectivité
```

mais :

```text
une donnée formée
+
son indice dépendant
+
son témoin
+
la positivité de ce témoin
```

Une diagonalisation constructive est donc comprise comme :

```text
deux formations internes séparées
+
une même projection visible
+
un témoin positif dépendant de cette cellule exacte
```

L’obstruction à la contraction ou à la reconstruction globale est une conséquence dérivée de cette donnée affirmative.

---

# Partie I — Deux niveaux de théorie

## 1. Univers formé et univers visible

La stratification logique doit être reflétée dans les signatures. On distingue
d’abord les seules sortes et relations :

```text
structure RawPositiveSetSignature where
  FormedSet  : Typeᵤ
  VisibleSet : Typeᵥ

  project :
    FormedSet → VisibleSet

  Mem :
    FormedSet → FormedSet → Typeₘ

  VisibleMem :
    VisibleSet → VisibleSet → Prop
```

Deux paquets de lois indépendants peuvent ensuite être ajoutés.

Projection des appartenances :

```text
structure MembershipProjection
    (S : RawPositiveSetSignature) where
  visibleMemOfMem :
    ∀ {x A : S.FormedSet},
      S.Mem x A →
      S.VisibleMem (S.project x) (S.project A)
```

Extensionalité visible :

```text
structure VisibleExtensionalStructure
    (S : RawPositiveSetSignature) where
  visibleExtensionality :
    ∀ V W : S.VisibleSet,
      (
        ∀ U : S.VisibleSet,
          S.VisibleMem U V ↔ S.VisibleMem U W
      )
      →
      V = W
```

Un paquet pratique peut réunir ces trois niveaux :

```text
structure PositiveSetContext where
  raw :
    RawPositiveSetSignature

  membershipProjection :
    MembershipProjection raw

  visibleExtensionality :
    VisibleExtensionalStructure raw
```

Mais ce paquetage ne doit pas masquer la différence entre :

```text
les symboles primitifs
la projection de l’appartenance
la loi d’extensionalité visible
```

Dans la suite, on fixe un tel contexte et on omet ses projections dans les
notations.

`FormedSet` porte les ensembles comme formations internes. `VisibleSet` porte
leur lecture observable. Cette lecture devient une extension exacte seulement
après ajout d’une adéquation de l’appartenance :

```text
FormedSet
   |
   | project
   v
VisibleSet
```

La projection peut oublier :

```text
la provenance de formation
les témoins d’appartenance
les réparations locales
les issues dépendantes
la différence entre plusieurs formations
```

Aucune injectivité de `project` n’est postulée.

Aucune surjectivité n’est postulée non plus. La question de la couverture de
`VisibleSet` est traitée séparément à la section 6.

---
## 2. Trois notions d’identité

Pour :

```text
A B : FormedSet
```

on distingue trois relations.

### 2.1 Identité interne

```text
InternalIdentity A B :=
  A = B
```

Elle identifie les formations elles-mêmes.

### 2.2 Identité projetée

```text
ProjectedIdentity A B :=
  project A = project B
```

Elle identifie seulement leurs lectures visibles.

### 2.3 Identité d’usage

```text
IdentityOfUse A B :=
  ProjectedIdentity A B
```

L’identité d’usage est l’égalité projetée lorsqu’elle est mobilisée comme
principe d’action.

Le noyau **ne postule pas** :

```text
project A = project B
→
A = B
```

Il ne prouve pas non plus la négation globale de ce principe à partir de la
signature seule. Une telle réfutation exige une cellule diagonale effectivement
habitée. Le statut exact est donc :

```text
pas d’injectivité primitive ;

incompatibilité locale avec l’injectivité
lorsqu’une cellule séparée est fournie.
```

---
## 3. Extensionalité visible

L’extensionalité est conservée au niveau visible.

On introduit une appartenance visible :

```text
VisibleMem :
  VisibleSet → VisibleSet → Prop
```

et une extensionalité visible :

```text
VisibleExtensionality :=
  ∀ V W : VisibleSet,
    (
      ∀ U : VisibleSet,
        VisibleMem U V ↔ VisibleMem U W
    )
    →
    V = W
```

La théorie peut donc affirmer :

```text
mêmes membres visibles
→
même ensemble visible
```

sans affirmer :

```text
mêmes membres visibles
→
même formation interne
```

L’extensionalité n’est pas supprimée ; elle est située au niveau où elle est légitime.

---

# Partie II — Appartenance formée

## 4. Appartenance comme donnée

L’appartenance interne est preuve-pertinente :

```text
Mem :
  FormedSet → FormedSet → Typeₘ
```

Un terme :

```text
m : Mem x A
```

peut porter :

```text
la provenance de x dans A
la branche de construction utilisée
un certificat de formation
un indice de transport
une réparation ou une justification locale
```

Deux termes de :

```text
Mem x A
```

ne sont pas nécessairement identiques.

L’appartenance formée n’est donc pas réduite à une proposition nue.

---

## 5. Projection, réflexion et adéquation de l’appartenance

La direction minimale de compatibilité est la projection des témoins internes :

```text
visibleMemOfMem :
  ∀ {x A : FormedSet},
    Mem x A →
    VisibleMem (project x) (project A)
```

Elle exprime :

```text
une appartenance formée
donne une appartenance visible.
```

Cette seule direction ne suffit pas à faire de `project A` l’extension exacte
de `A`. Elle autorise des membres visibles qui ne proviennent d’aucune
appartenance formée.

Pour formuler la direction inverse, on définit :

```text
structure VisibleMembershipLift
    (U : VisibleSet)
    (A : FormedSet) where
  formed :
    FormedSet

  projected :
    project formed = U

  membership :
    Mem formed A
```

Trois niveaux doivent être distingués.

### 5.1 Réflexion propositionnelle

```text
structure MembershipReflection where
  reflected :
    ∀ {U : VisibleSet} {A : FormedSet},
      VisibleMem U (project A) →
      Nonempty (VisibleMembershipLift U A)
```

Cette loi affirme qu’un membre visible de `project A` possède au moins un
représentant formé, sans exposer ce représentant hors de la troncation
`Nonempty`.

Avec `visibleMemOfMem`, elle donne l’adéquation propositionnelle :

```text
VisibleMem U (project A)
↔
Nonempty (VisibleMembershipLift U A)
```

La direction retour élimine `Nonempty` uniquement vers la proposition
`VisibleMem U (project A)`.

### 5.2 Réalisation en données

La forme plus forte est :

```text
structure MembershipRealization where
  realize :
    ∀ {U : VisibleSet} {A : FormedSet},
      VisibleMem U (project A) →
      VisibleMembershipLift U A
```

Elle choisit effectivement, pour chaque preuve d’appartenance visible, un
représentant formé et son témoin d’appartenance.

Elle implique `MembershipReflection` par `Nonempty.intro`, mais la réciproque
est une élimination de troncation vers des données et n’appartient pas au
noyau constructif général.

Dans une implémentation fidèle au principe « l’existence fondamentale est une
donnée », `MembershipRealization` est la couche opératoire privilégiée.
`MembershipReflection` reste utile comme couche sémantique propositionnelle,
notamment pour démontrer des lois visibles sans choisir de représentant
calculable.

### 5.3 Statut du mot « extension »

Le vocabulaire exact est :

```text
sans MembershipReflection :
  project A est une projection ou lecture visible ;

avec MembershipReflection :
  project A est extensionnellement adéquat à A
  au niveau propositionnel ;

avec MembershipRealization :
  chaque appartenance visible est réalisée
  par une donnée formée explicite.
```

Cette distinction est indispensable. L’extensionalité visible seule n’assure
aucune adéquation entre `VisibleMem` et `Mem`.

---

## 6. Couverture des visibles

La représentation d’un visible isolé est une autre question :

```text
structure RepresentedVisible
    (V : VisibleSet) where
  formed :
    FormedSet

  projected :
    project formed = V
```

Une couverture en données serait :

```text
visibleCoverage :
  ∀ V : VisibleSet,
    RepresentedVisible V
```

Une couverture seulement propositionnelle serait :

```text
visibleCovered :
  ∀ V : VisibleSet,
    Nonempty (RepresentedVisible V)
```

Passer de `visibleCovered` à `visibleCoverage` exige une élimination uniforme
de la troncation et constitue un principe de choix de représentants.

La couverture de tous les visibles est indépendante de la réflexion des
membres d’un ensemble projeté :

```text
MembershipReflection
```

ne concerne que les `U` vérifiant :

```text
VisibleMem U (project A)
```

pour un `A` formé donné.

---

# Partie III — Diagonalisation positive

## 7. Cellule diagonale d’ensembles formés

Une cellule diagonale est une donnée paramétrée par le contexte projectif :

```text
structure ProjectedSetCell where
  formed :
    FormedSet

  shadow :
    FormedSet

  sameVisible :
    project formed = project shadow

  separated :
    formed = shadow → False
```

Elle porte affirmativement :

```text
un pôle formé
un pôle ombre
leur identité visible
leur séparation interne
```

Ce n’est pas la négation abstraite d’une propriété.

C’est une donnée. Le type `ProjectedSetCell` peut néanmoins être vide dans un
contexte donné ; la signature seule ne construit pas une cellule.

---
## 8. Obstruction affirmative

L’obstruction projective ne contient pas plus de données qu’une cellule
diagonale. Elle en est une lecture orientée vers les conséquences de
non-contraction :

```text
abbrev ProjectionObstruction :=
  ProjectedSetCell
```

Si l’implémentation conserve deux structures nominales, comme dans
`Meta/Core`, leur conversion est champ par champ et n’ajoute aucun contenu.

La fidélité de fibre est le test global :

```text
ProjectionFiberFaithful :=
  ∀ left right : FormedSet,
    project left = project right →
    left = right
```

Une obstruction habitée donne constructivement :

```text
ProjectionObstruction
→
ProjectionFiberFaithful
→
False
```

L’obstruction n’est donc pas définie par :

```text
¬ ProjectionFiberFaithful
```

La priorité logique est :

```text
donnée positive
→
conséquence négative
```

Constructivement, la réciproque n’est pas disponible en général :

```text
(ProjectionFiberFaithful → False)
```

ne fournit pas nécessairement les pôles, leur égalité visible et leur
séparation. C’est la différence entre une négation et une obstruction
affirmative habitée.

---
## 9. Témoin dépendant de la cellule

On fixe une famille :

```text
WitnessOf :
  ProjectedSetCell → Type𝓌
```

Le témoin dépend de la cellule complète :

```text
witness :
  WitnessOf cell
```

Son indice contient notamment :

```text
cell.formed
cell.shadow
cell.sameVisible
cell.separated
```

Dans une implémentation Lean ordinaire, les preuves situées dans `Prop` sont
preuve-irrélevantes. La dépendance substantielle porte donc surtout sur les
pôles et sur la configuration propositionnelle qu’ils satisfont, non sur un
choix calculatoire entre plusieurs preuves d’égalité ou de séparation.

---
## 10. Positivité du témoin

La positivité est paramétrée :

```text
Positive :
  ∀ cell : ProjectedSetCell,
    WitnessOf cell →
    Prop
```

La forme positive complète est :

```text
structure PositiveSetDiagonalization
    (WitnessOf :
      ProjectedSetCell → Type𝓌)
    (Positive :
      ∀ cell,
        WitnessOf cell → Prop) where
  cell :
    ProjectedSetCell

  witness :
    WitnessOf cell

  witness_pos :
    Positive cell witness
```

Elle contient :

```text
pôles internes séparés
+
même visible
+
témoin dépendant
+
preuve positive du témoin
```

Cette structure est le schéma central **lorsqu’elle est habitée**. Elle ne
constitue pas un axiome affirmant que toute cellule, ni même qu’au moins une
cellule, possède automatiquement un témoin positif. Une théorie concrète doit
construire les habitants pertinents ou ajouter un principe précisément
délimité.

La structure générique n’assure pas à elle seule un contenu substantiel. Les
choix :

```text
WitnessOf cell := Unit
Positive cell witness := True
```

produisent une diagonalisation formellement habitée mais informationnellement
triviale dès qu’une cellule existe.

L’apport métamathématique dépend donc d’une famille concrète `WitnessOf`, d’une
notion concrète `Positive` et de théorèmes montrant ce que le témoin permet de
former, transporter, conserver ou réparer. Le noyau fournit la discipline
d’indexation ; il ne remplace pas cette sémantique.

---
## 11. Deux voies issues de la même diagonale

Une diagonalisation positive possède deux directions d’exploitation.

### 11.1 Voie positive

```text
même projection
→
identité d’usage
→
transport des lectures visibles
```

### 11.2 Voie limitative

```text
même projection
+
séparation interne
→
pas de fidélité globale
→
pas de reconstruction uniforme
```

La seconde voie ne définit pas la première.

Les deux proviennent de la même donnée positive.

---

# Partie IV — Transport d’usage

## 12. Lectures visibles

Pour :

```text
Label : Typeₗ
read  : VisibleSet → Label
```

le transport associé doit mentionner la lecture dans sa signature :

```text
ReadTransport
    (read : VisibleSet → Label)
    (A B : FormedSet) :=
  read (project A) = read (project B)
```

Une identité projetée fournit :

```text
ProjectedIdentity A B
→
ReadTransport read A B
```

par congruence.

---
## 13. Transport polymorphe

La forme directement compatible avec `Meta/Core` fixe le niveau d’univers des
lectures :

```text
InterfaceTransport.{v}
    (A B : FormedSet) :=
  ∀ Label : Typeᵥ,
  ∀ read : VisibleSet → Label,
    read (project A) = read (project B)
```

On obtient :

```text
InterfaceTransport A B
↔
ProjectedIdentity A B
```

La direction retour choisit :

```text
Label := VisibleSet
read  := identité
```

Une quantification simultanée sur tous les univers demanderait une famille
univers-polymorphe de définitions ; elle ne doit pas être simulée par un simple
`∀ Label : Type` ambigu.

---
## 14. Transport sans contraction

La théorie conserve simultanément :

```text
A = B → False
```

et :

```text
∀ read,
  read (project A) = read (project B)
```

Le transport ne fusionne pas les pôles.

Il coordonne leur usage visible.

Cette distinction est constitutive de la théorie des ensembles formés.

---

# Partie V — Formation des ensembles

## 15. Principe général

Les constructions ensemblistes sont des données de formation, non des
existences nues.

Le niveau `FormedSet` étant preuve-pertinent, ses objets ne sont pas encore des
sets extensionnels au sens ordinaire. Ils peuvent conserver :

```text
plusieurs occurrences du même membre
plusieurs chemins d’appartenance
plusieurs présentations d’une même extension
```

Le mot « ensemble » désigne donc ici une formation ou présentation set-like.
La contraction en ensemble extensionnel est le rôle du niveau visible.

Pour chaque opération, il faut distinguer :

```text
FormationSpec paramètres
```

qui décrit une formation accompagnée de ses règles internes, et éventuellement :

```text
constructor⁺ paramètres :
  FormationSpec paramètres
```

qui fournit constructivement une telle formation comme opération primitive.
Ce second terme contient la donnée ; il n’est pas extrait d’un énoncé
propositionnel `∃ formation, ...`.

Les lois reliant cette formation au visible sont des champs ou théorèmes
supplémentaires :

```text
ProjectionLaw formation
```

Elles ne suivent pas de `visibleMemOfMem` seul.

En revanche, `MembershipReflection` suffit souvent à les dériver
propositionnellement des équivalences internes de membership. Le schéma est :

```text
membre visible
→ existence tronquée d’un représentant formé
→ élimination de la formation interne
→ caractérisation visible
```

La forme plus forte `MembershipRealization` fournit en plus les représentants
comme données calculables.

---
## 16. Ensemble vide formé


La spécification interne est :

```text
structure EmptyFormation where
  set : FormedSet

  elim :
    ∀ x : FormedSet,
      Mem x set → False
```

Un constructeur vide positif est une donnée :

```text
empty⁺ : EmptyFormation
```

La vacuité visible n’est pas dérivable de `empty⁺.elim` avec la seule
projection `visibleMemOfMem`.

Elle peut soit être portée séparément :

```text
EmptyProjectionLaw (E : EmptyFormation) :=
  ∀ U : VisibleSet,
    VisibleMem U (project E.set) → False
```

soit être dérivée sous `MembershipReflection` : une appartenance visible
fournit alors `Nonempty (VisibleMembershipLift U E.set)`, que l’on élimine vers
`False` en appliquant `E.elim` au témoin d’appartenance formée.

Ainsi :

```text
formation vide interne
```

et :

```text
projection visiblement vide
```

restent deux niveaux distincts, mais une loi générale d’adéquation peut les
raccorder.

---

## 17. Paire formée

Pour conserver le côté d’introduction sans mélanger directement `Prop` et
`Type`, on introduit un type de provenance :

```text
inductive PairOccurrence
    (x A B : FormedSet) : Type where
  | left :
      x = A →
      PairOccurrence x A B

  | right :
      x = B →
      PairOccurrence x A B
```

Une paire formée est alors :

```text
structure PairFormation
    (A B : FormedSet) where
  set :
    FormedSet

  membership :
    ∀ x : FormedSet,
      Mem x set ≃
        PairOccurrence x A B
```

Le symbole `≃` désigne une équivalence de types avec fonctions dans les deux
directions et lois d’aller-retour.

Un constructeur positif est :

```text
pair⁺ :
  ∀ A B : FormedSet,
    PairFormation A B
```

La loi visible est :

```text
PairProjectionLaw
    (P : PairFormation A B) :=
  ∀ U : VisibleSet,
    VisibleMem U (project P.set)
    ↔
    (
      U = project A
      ∨
      U = project B
    )
```

Elle peut être donnée séparément. Elle est aussi dérivable de
`P.membership`, `visibleMemOfMem` et `MembershipReflection` :

```text
membre visible
→ représentant formé de la paire
→ occurrence left ou right
→ égalité visible correspondante.
```

La réciproque utilise les deux introductions internes puis
`visibleMemOfMem`.

Le niveau visible est propositionnel ; l’usage de `∨` y est donc cohérent.

Si `A = B`, les constructeurs `left` et `right` restent deux provenances
distinctes. La projection visible peut contracter ces occurrences en un seul
membre. Une paire idempotente au niveau interne demanderait une troncation ou
une loi d’identification supplémentaire.

---
## 18. Union formée


Pour `A : FormedSet` :

```text
structure UnionFormation (A : FormedSet) where
  set : FormedSet

  membership :
    ∀ x : FormedSet,
      Mem x set ≃
        Σ B : FormedSet,
          Mem B A × Mem x B
```

L’équivalence restitue la provenance complète :

```text
le membre intermédiaire B
le témoin B ∈ A
le témoin x ∈ B
```

Deux chemins distincts vers le même `x` restent donc deux témoins internes de
`Mem x set`. L’union visible pourra oublier cette multiplicité, mais l’union
formée ne la contracte pas par définition.

Un constructeur positif est :

```text
union⁺ :
  ∀ A : FormedSet,
    UnionFormation A
```

Une loi visible d’union n’est pas obtenue de la seule projection des témoins
internes.

Elle peut être donnée séparément, ou dérivée propositionnellement sous
`MembershipReflection`. La direction visible vers formé relève successivement
le membre de `project U.set`, puis le membre visible de l’intermédiaire ; la
direction inverse projette les deux témoins internes.

---

## 19. Séparation propositionnelle relative et séparation bornée codée

Pour éviter une expression ambiguë mêlant une donnée d’appartenance et une
proposition avec un produit ordinaire, on définit :

```text
structure SeparatedMembership
    (A : FormedSet)
    (P : FormedSet → Prop)
    (x : FormedSet) where
  base :
    Mem x A

  property :
    P x
```

Une formation de séparation relative est :

```text
structure SeparationFormation
    (A : FormedSet)
    (P : FormedSet → Prop) where
  set :
    FormedSet

  membership :
    ∀ x : FormedSet,
      Mem x set ≃
        SeparatedMembership A P x
```

Comme `P` est un prédicat arbitraire de la métathéorie, le principe global :

```text
separate⁺ :
  ∀ A,
  ∀ P : FormedSet → Prop,
    SeparationFormation A P
```

est un schéma externe potentiellement fort. Il est relatif à `A`, mais il n’est
pas « borné » au sens technique de CZF.

Une séparation bornée au sens syntaxique exige des codes d’admissibilité :

```text
BoundedPredicateCode :
  Typeᵦ

holds :
  BoundedPredicateCode →
  FormedSet →
  Prop

separateBounded⁺ :
  ∀ A,
  ∀ code : BoundedPredicateCode,
    SeparationFormation A (holds code)
```

La définition de `BoundedPredicateCode` doit garantir que seules les formules
autorisées sont représentées.

Une séparation pleinement preuve-pertinente :

```text
P : FormedSet → Typeₚ
```

demande un type analogue à `SeparatedMembership` dont le champ `property`
habite `P x`, ainsi qu’un principe de petitesse, de redimensionnement ou de
représentabilité.

Enfin, aucune loi visible n’est automatique. Elle exige :

```text
Pᵥ : VisibleSet → Prop
```

et une factorisation :

```text
∀ x,
  P x ↔ Pᵥ (project x)
```

Avec cette factorisation et `MembershipReflection`, la loi visible de
séparation peut être dérivée propositionnellement de la formation interne.
Sans réflexion, elle reste une loi supplémentaire.

Un prédicat formé qui distingue une cellule diagonale ne possède précisément
pas une telle factorisation.

---
## 20. Image formée

Pour ne pas mélanger une égalité propositionnelle avec une donnée
d’appartenance dans un produit, on introduit :

```text
structure ImagePreimage
    (f : FormedSet → FormedSet)
    (A y : FormedSet) where
  source :
    FormedSet

  source_mem :
    Mem source A

  image_eq :
    y = f source
```

L’image par une fonction interne explicite est :

```text
structure ImageFormation
    (f : FormedSet → FormedSet)
    (A : FormedSet) where
  set :
    FormedSet

  membership :
    ∀ y : FormedSet,
      Mem y set ≃
        ImagePreimage f A y
```

Un principe global :

```text
image⁺ :
  ∀ f A,
    ImageFormation f A
```

est déjà une forme forte de remplacement fonctionnel. Il ne doit pas être
classé dans la signature structurelle minimale tant qu’un modèle et ses
conditions de petitesse ne sont pas fournis.

Il ne demande aucun choix lorsque `f` est une donnée explicite ; il demande en
revanche que l’image de la famille des occurrences de `A` soit représentable
par une formation.

---
## 21. Image relationnelle et remplacement

Pour une relation preuve-pertinente :

```text
R : FormedSet → FormedSet → Typeᵣ
```

l’image relationnelle interne est d’abord une notion indépendante de la
fonctionnalité :

```text
structure RelationalImageFormation
    (A : FormedSet)
    (R : FormedSet → FormedSet → Typeᵣ) where
  set :
    FormedSet

  membership :
    ∀ y : FormedSet,
      Mem y set ≃
        Σ x : FormedSet,
          Mem x A × R x y
```

Cette structure conserve :

```text
l’occurrence de x dans A
le témoin relationnel R x y
```

La fonctionnalité interne nécessaire au remplacement est relative au
domaine :

```text
StrictFunctionalOn A R :=
  ∀ x : FormedSet,
  ∀ m : Mem x A,
  ∀ y z : FormedSet,
    R x y →
    R x z →
    y = z
```

Le témoin `m` limite la loi aux éléments effectivement présents dans `A`.
Une fonctionnalité globale de `R` serait plus forte que nécessaire.

Pour représenter le remplacement usuel, il faut aussi une totalité sur le
domaine. Dans la lecture preuve-pertinente, la forme la plus forte est indexée
par les occurrences :

```text
TotalOnOccurrences A R :=
  ∀ x : FormedSet,
  ∀ m : Mem x A,
    Σ y : FormedSet,
      R x y
```

Un paquet de remplacement est alors :

```text
structure ReplacementFormation
    (A : FormedSet)
    (R : FormedSet → FormedSet → Typeᵣ) where
  image :
    RelationalImageFormation A R

  total :
    TotalOnOccurrences A R

  functional :
    StrictFunctionalOn A R
```

La totalité par occurrences peut fournir des témoins différents pour deux
occurrences du même `x`. Pour comparer les sorties issues de deux occurrences
`m₁` et `m₂`, on applique `StrictFunctionalOn A R` avec l’une de ces occurrences
et les deux témoins relationnels `R x y` et `R x z`. Les sorties formées sont
alors égales.

La fonctionnalité seulement projetée, elle aussi relative au domaine, est :

```text
ProjectedFunctionalOn A R :=
  ∀ x : FormedSet,
  ∀ m : Mem x A,
  ∀ y z : FormedSet,
    R x y →
    R x z →
    project y = project z
```

ne suffit pas à produire une sortie intérieurement déterminée. Elle ne
détermine que l’identité d’usage des sorties. Pour obtenir une formation, il
faut ajouter l’une des données suivantes :

```text
un représentant formé choisi pour chaque fibre
une normalisation
une récupération locale cohérente
ou une sortie seulement visible
```

---

## 22. Collection positive


La collection conserve les données locales. Pour :

```text
R : FormedSet → FormedSet → Typeᵣ
```

une totalité dépendante est :

```text
totalOn :
  ∀ x : FormedSet,
  ∀ m : Mem x A,
    Σ y : FormedSet,
      R x y
```

Un principe de collection doit produire une formation `C` avec au moins :

```text
coverage :
  ∀ x,
  ∀ m : Mem x A,
    Σ y : FormedSet,
      Mem y C × R x y
```

et, pour une collection exacte :

```text
soundness :
  ∀ y,
    Mem y C →
    Σ x : FormedSet,
    Σ m : Mem x A,
      R x y
```

La construction de `C` n’est pas dérivée de `totalOn` par simple projection :
elle constitue précisément un principe de collection, avec ses conditions de
petitesse. Elle reste donc optionnelle jusqu’à la construction d’un modèle.

La totalité ci-dessus est indexée par `m : Mem x A`. Elle collecte donc des
réponses pour les occurrences internes, pas seulement pour les valeurs `x`.
Une version tronquée ou extensionnelle de la collection devrait être formulée
séparément.

---

## 23. Infini formé

Une première version peut introduire :

```text
zero⁺ :
  FormedSet

succ⁺ :
  FormedSet → FormedSet

omega⁺ :
  FormedSet
```

avec :

```text
omega_zero :
  Mem zero⁺ omega⁺

omega_succ :
  ∀ n,
    Mem n omega⁺
    →
    Mem (succ⁺ n) omega⁺
```

et un principe minimal d’induction ou de clôture.

La forme exacte de `succ⁺` doit être choisie :

```text
succ⁺ n
:=
union de n avec le singleton de n
```

au niveau formé, avec conservation de la provenance.

Cette partie reste à formaliser précisément.

---

## 24. Ensemble des sous-formations

L’analogue de l’ensemble des parties ne doit pas être introduit comme une compréhension non contrôlée.

On commence par un type de sous-formations :

```text
structure Subformation (A : FormedSet) where
  carrier :
    FormedSet

  inclusion :
    ∀ {x : FormedSet},
      Mem x carrier
      →
      Mem x A
```

Une puissance positive viserait :

```text
power⁺ A :
  FormedSet
```

avec une représentation des sous-formations de `A`.

Des problèmes de taille d’univers apparaissent immédiatement :

```text
Subformation A
```

peut vivre dans un univers supérieur à `FormedSet`.

La puissance positive doit donc être traitée avec :

```text
des univers explicites
ou
un principe de petite représentation
ou
des codes de sous-formations
```

Elle n’appartient pas encore au noyau minimal.

---

# Partie VI — Vérité formée

## 25. Vérité formée comme donnée

La forme primaire doit être preuve-pertinente :

```text
TruthData :
  FormedSet → Typeₜ
```

Un terme :

```text
truth :
  TruthData A
```

est une donnée de vérité attachée à la formation exacte `A`.

La vue propositionnelle correspondante est :

```text
TruthProp A :=
  Nonempty (TruthData A)
```

On peut aussi partir directement d’un prédicat :

```text
Truth :
  FormedSet → Prop
```

lorsqu’aucun contenu calculatoire de la vérité n’est requis. Mais cette version
est une vue plus faible. Elle ne doit pas remplacer silencieusement la donnée
primaire dans une théorie dont le principe fondateur est la formation
témoignée.

Ni `TruthData A` ni `TruthProp A` ne sont supposés déterminés par `project A`.

---
## 26. Gap local de vérité

On spécialise le motif positif avec une vérité type-valuée :

```text
structure LocalSetTruthGap
    (TruthData :
      FormedSet → Typeₜ)
    (RepairOf :
      FormedSet → Typeᵣ) where
  recovery :
    LocalProjectiveRecovery RepairOf

  formed_truth :
    TruthData recovery.formed

  shadow_not_truth :
    TruthData recovery.shadow →
    False
```

Le paquet contient :

```text
project recovery.formed
=
project recovery.shadow
```

mais aussi :

```text
TruthData recovery.formed
```

et :

```text
TruthData recovery.shadow → False
```

On en déduit une impossibilité de classification propositionnelle exacte :

```text
noVisibleTruthClassifier :
  ∀ visibleTruth : VisibleSet → Prop,
    (
      ∀ A : FormedSet,
        visibleTruth (project A)
        ↔
        Nonempty (TruthData A)
    )
    →
    False
```

La preuve utilise la donnée `formed_truth`, transporte sa vue `Nonempty` par
l’égalité visible, puis contredit `shadow_not_truth`.

Ce théorème ne dit pas qu’aucune information visible sur la vérité n’est
possible. Il exclut seulement une classification qui factorise exactement
toute la vérité formée à travers `project`.

---
## 27. Formation et vérité projetée

Pour une scène :

```text
Scene :=
  FormedSet → Prop
```

la formation positive primaire doit être une structure de données :

```text
structure GeometricFormationData
    (TruthData :
      FormedSet → Typeₜ)
    (scene : Scene) where
  formed :
    FormedSet

  in_scene :
    scene formed

  truth :
    TruthData formed
```

Sa vue propositionnelle est :

```text
GeometricFormationProp TruthData scene :=
  Nonempty
    (GeometricFormationData TruthData scene)
```

La stabilité projetée porte sur la vue propositionnelle de la vérité :

```text
ProjectedLocalTruth
    (TruthData :
      FormedSet → Typeₜ)
    (scene : Scene) :=
  ∀ A B : FormedSet,
    scene A →
    scene B →
    project A = project B →
    (
      Nonempty (TruthData A)
      ↔
      Nonempty (TruthData B)
    )
```

Pour :

```text
gap :
  LocalSetTruthGap TruthData RepairOf
```

les deux scènes sont définies par :

```text
fullScene gap A :=
  A = gap.recovery.formed
  ∨
  A = gap.recovery.shadow

shadowScene gap A :=
  A = gap.recovery.shadow
```

Le premier terme positif est :

```text
fullSceneFormation :
  GeometricFormationData
    TruthData
    (fullScene gap)
```

avec :

```text
formed  := gap.recovery.formed
in_scene := Or.inl rfl
truth   := gap.formed_truth
```

La scène complète n’est pas stable par vérité projetée :

```text
fullScene_not_projectedTruth :
  ProjectedLocalTruth
    TruthData
    (fullScene gap)
  →
  False
```

La preuve applique la stabilité supposée aux pôles formé et ombre, utilise
`gap.recovery.sameProjection`, transporte `Nonempty gap.formed_truth`, puis
élimine l’habitant obtenu de `TruthData gap.recovery.shadow` avec
`gap.shadow_not_truth`.

La scène réduite à l’ombre est stable :

```text
shadowScene_projectedTruth :
  ProjectedLocalTruth
    TruthData
    (shadowScene gap)
```

car deux objets de cette scène sont tous deux égaux à l’ombre ; leurs vues
propositionnelles de vérité se réécrivent donc en la même proposition.

Enfin :

```text
shadowScene_no_formation :
  GeometricFormationData
    TruthData
    (shadowScene gap)
  →
  False
```

car le témoin `in_scene` identifie la formation portée à l’ombre, ce qui
transforme son champ `truth` en un habitant interdit de
`TruthData gap.recovery.shadow`.

Le résultat fournit donc quatre termes explicites :

```text
fullSceneFormation
fullScene_not_projectedTruth
shadowScene_projectedTruth
shadowScene_no_formation
```

Il constitue une séparation constructive des deux implications, ou des
contre-exemples internes aux deux implications. Il ne constitue pas encore une
preuve d’indépendance relative entre deux théories axiomatiques.

---

# Partie VII — Réparation locale

## 28. Famille de réparations

Une famille de réparations est :

```text
RepairOf :
  FormedSet → Typeᵣ
```

Une réparation est toujours indexée par le pôle formé exact :

```text
repair :
  RepairOf formed
```

Elle ne doit pas être aplatie en une donnée globale.

---

## 29. Récupération projective locale

La structure est paramétrée par la famille de réparations :

```text
structure LocalProjectiveRecovery
    (RepairOf :
      FormedSet → Typeᵣ) where
  formed :
    FormedSet

  shadow :
    FormedSet

  sameProjection :
    project formed = project shadow

  separated :
    formed = shadow → False

  repair :
    RepairOf formed

  recovered :
    FormedSet

  recovered_eq_formed :
    recovered = formed
```

Elle affirme positivement :

```text
la formation exacte est connue
son ombre visible est connue
leur différence interne est conservée
une réparation indexée est disponible
la formation récupérée est fournie
```

Elle ne postule pas un inverse global de `project`.

---

## 30. Sémantique causale optionnelle de la réparation

Le noyau minimal ne dit pas encore que `repair` calcule `recovered`.

Une version plus forte peut ajouter :

```text
applyRepair :
  ∀ A : FormedSet,
    RepairOf A →
    FormedSet
```

et, pour un paquet local donné :

```text
repair_produces_recovered :
  applyRepair localRecovery.formed localRecovery.repair
  =
  localRecovery.recovered
```

La correction au pôle formé suit alors de :

```text
localRecovery.recovered_eq_formed
```

On peut aussi utiliser une relation :

```text
Repairs :
  ∀ A : FormedSet,
    RepairOf A →
    FormedSet →
    Type
```

avec :

```text
repair_realizes :
  Repairs
    localRecovery.formed
    localRecovery.repair
    localRecovery.recovered
```

Cette couche causale doit rester distincte de la simple présence positive
d’une réparation. Elle doit relier explicitement le champ `repair` au champ
`recovered`, et non seulement prouver séparément qu’une application abstraite
retourne le pôle formé.

---

# Partie VIII — Reconstruction globale et choix

## 31. Reconstruction globale

Une conservation globale de l’information serait :

```text
structure InformationConservingProjection where
  recover :
    VisibleSet → FormedSet

  reconstructs :
    ∀ A : FormedSet,
      recover (project A) = A
```

Une cellule diagonale séparée réfute cette structure.

La preuve utilise la donnée positive :

```text
formed
shadow
sameVisible
separated
```

et non une négation primitive.

---

## 32. Statut de l’axiome du choix classique

Dans une formulation ensembliste classique, l’axiome du choix affirme
l’existence d’une fonction ou d’un ensemble de choix. Il affirme donc bien un
objet dans chaque modèle de la théorie.

Le contraste pertinent n’est pas :

```text
le choix ne contient absolument aucun objet
```

mais :

```text
la preuve classique d’existence
n’expose pas en général une règle canonique,
calculatoire et dépendamment indexée
qui détermine chaque choix.
```

Dans une lecture preuve-pertinente, le témoin existentiel peut être opaque ou
non calculatoire, alors que les constructeurs de la théorie formée retournent
directement leurs données et certificats.

La comparaison doit rester limitée à ce cadre. Elle ne vaut pas pour le choix
constructif extrait de sommes dépendantes déjà habitées.

---
## 33. Choix dépendant depuis des données

Pour :

```text
A : Typeᵤ
B : A → Typeᵥ
R : ∀ x : A, B x → Typeᵣ
```

la forme constructive est :

```text
choiceFromData :
  (
    ∀ x : A,
      Σ y : B x,
        R x y
  )
  →
  Σ f : (∀ x : A, B x),
    ∀ x : A,
      R x (f x)
```

Cette opération est définie par projections des sommes dépendantes. Elle ne
constitue pas un axiome supplémentaire dans une théorie des types disposant de
ces constructeurs.

La différence exacte est :

```text
existence propositionnelle classique :
  un sélecteur est affirmé sans règle calculatoire imposée

données dépendantes :
  élément local et témoin déjà fournis
  → fonction extraite par projection
```

---
## 34. Diagonalisation positive et sélection de représentants

Le choix et la diagonalisation positive sont deux opérations différentes, mais
elles ne sont pas logiquement opposées.

Une fonction de choix ou une section :

```text
select :
  ∀ V : VisibleSet,
    RepresentedVisible V
```

sélectionne une formation au-dessus de chaque visible. Cette sélection ne
supprime pas les autres formations de la fibre et ne les identifie pas
automatiquement.

Une diagonalisation positive fournit au contraire, localement :

```text
formed
shadow
sameVisible
separated
witness
```

Elle distingue deux pôles d’une même fibre et porte une donnée sur leur
coordination.

La contraction n’apparaît que si la sélection est suivie d’un principe
supplémentaire, par exemple :

```text
normalisation canonique
quotient
fidélité imposée
identification de toute formation à son représentant choisi
```

La formulation rigoureuse est donc :

```text
choix :
  ajout d’une sélection ou d’une section

diagonalisation positive :
  ajout d’une cellule non contractive témoignée
```

Les deux peuvent coexister. Ce qui est incompatible avec une cellule séparée,
c’est une reconstruction globale vérifiant :

```text
recover (project A) = A
```

pour toute formation `A`, non la simple existence d’un représentant choisi par
fibre.

---

# Partie IX — Axiomes minimaux proposés

## 35. Noyau minimal

Le noyau doit être stratifié.

### Noyau de symboles

```text
RawPositiveSetSignature
```

c’est-à-dire :

```text
FormedSet
VisibleSet
project
Mem
VisibleMem
```

### Lois structurelles séparées

```text
MembershipProjection
VisibleExtensionalStructure
```

Pour que `project A` soit une extension exacte plutôt qu’une simple lecture,
on ajoute au moins :

```text
MembershipReflection
```

La forme calculatoire plus forte est :

```text
MembershipRealization
```

Ces lois peuvent être regroupées dans des contextes pratiques, mais restent
logiquement distinctes des symboles.

### Schémas diagonaux

```text
ProjectedSetCell
ProjectionObstruction
PositiveSetDiagonalization
```

Ce sont des types de configurations. Le noyau n’affirme pas qu’ils sont
habités.

### Fragment de formation élémentaire candidat

Peuvent être ajoutées comme opérations primitives explicites, après
construction d’un modèle :

```text
empty⁺ :
  EmptyFormation

pair⁺ :
  ∀ A B,
    PairFormation A B

union⁺ :
  ∀ A,
    UnionFormation A
```

La séparation doit être distinguée :

```text
separateBounded⁺ :
  séparation sur codes de prédicats admissibles
```

peut appartenir à un fragment constructif contrôlé, tandis que :

```text
∀ P : FormedSet → Prop,
  SeparationFormation A P
```

est un schéma externe plus fort.

### Extensions fortes

```text
séparation externe complète
image
remplacement
collection
infini
puissance
fondation
couverture de VisibleSet
```

ne font pas partie du noyau minimal avant preuve de modélisabilité, contrôle
des univers et définition précise de leur syntaxe.

---
## 36. Principes positifs

La théorie définit les types de données suivants :

```text
ProjectedSetCell
PositiveSetDiagonalization
LocalProjectiveRecovery
LocalSetTruthGap
```

Leur définition n’est pas un axiome d’existence. Une théorie concrète peut
construire certains habitants, ou rester sans cellule diagonale dans un modèle
particulier. Elle ne postule pas que toute formation possède une ombre séparée.

---

## 37. Principes optionnels

Les extensions possibles sont :

```text
liftVisibleMem
replacement relationnel
collection
infini
puissance positive
fondation
réparation causale
choix global de représentants
```

Chaque extension doit faire l’objet d’un module séparé et d’une analyse de cohérence.

---

# Partie X — Fondation et récursion

## 38. Fondation formée

Une fondation extensionnelle des prédécesseurs peut utiliser la troncation
propositionnelle :

```text
MemRel x A :=
  Nonempty (Mem x A)
```

et demander :

```text
WellFounded MemRel
```

ou :

```text
∀ A : FormedSet,
  Acc MemRel A
```

Cette loi suffit pour une induction qui dépend des nœuds `x`, mais elle oublie
la multiplicité et la provenance des témoins `m : Mem x A`.

Elle porte sur la formation interne au niveau des prédécesseurs existants, pas
sur les seules projections visibles. Elle reste optionnelle pour permettre des
modèles non bien fondés.

---
## 39. Induction et récursion preuve-pertinentes

À partir de :

```text
WellFounded MemRel
```

on obtient une induction propositionnelle sur les prédécesseurs tronqués :

```text
formedSetInduction :
  ∀ P : FormedSet → Prop,
    (
      ∀ A,
        (
          ∀ x,
            MemRel x A →
            P x
        )
        →
        P A
    )
    →
    ∀ A,
      P A
```

Cette induction ne distingue pas deux témoins différents de `Mem x A`.

Pour une récursion sensible aux occurrences, on fournit une présentation :

```text
structure MembershipPresentation where
  Position :
    FormedSet → Typeₚ

  child :
    ∀ A : FormedSet,
      Position A → FormedSet

  membership :
    ∀ x A : FormedSet,
      Mem x A ≃
        { p : Position A //
          child A p = x }
```

Le sous-type de droite vit dans `Type` et conserve la position `p`.

Une hypothèse de bien-fondation ou une construction inductive sur ces positions
peut alors fournir une étape :

```text
∀ A,
  (
    ∀ p : Position A,
      P (child A p)
  )
  →
  P A
```

Pour une récursion produisant des données, on prend :

```text
P : FormedSet → Type
```

et non seulement `Prop`.

La preuve-pertinence de `Mem` ne produit pas automatiquement ce recursor ; elle
le rend formulable lorsqu’une présentation bien fondée est fournie.

---

# Partie XI — Modèles visés

## 40. Modèle par arbres bien fondés

Un premier candidat est :

```text
FormedSet :=
  arbres bien fondés étiquetés
```

L’appartenance interne correspond aux branches immédiates avec leur témoin de position.

La projection visible pourrait être :

```text
collapse extensionnel
```

ou une lecture par bisimulation.

Deux arbres distincts peuvent alors avoir la même extension visible.

Une cellule diagonale est donnée par :

```text
deux arbres distincts
+
une égalité de leurs collapses
```

Un témoin positif peut dépendre de leur différence de formation.

---

## 41. Modèle par présentations

Un autre candidat est :

```text
FormedSet :=
  présentations syntaxiques d’ensembles
```

avec :

```text
VisibleSet :=
  sémantique extensionnelle
```

La projection interprète une présentation.

Deux présentations distinctes peuvent avoir la même interprétation.

Le témoin positif peut porter :

```text
une dérivation
une provenance
un certificat de normalisation
une réparation
une propriété de formation
```

Ce modèle est particulièrement naturel pour une application métamathématique.

---

## 42. Modèle par graphes ou codes

On peut aussi prendre :

```text
FormedSet :=
  graphes pointés ou codes de formation
```

et :

```text
VisibleSet :=
  classes extensionnelles observées
```

La théorie doit alors préciser si `VisibleSet` est :

```text
un type quotient
un setoid
une relation de bisimulation
une interface abstraite
```

Le noyau de diagonalisation positive n’exige pas de quotient interne des formations.

---

# Partie XII — Théorèmes métamathématiques visés

## 43. Théorème de projection

Le théorème de projection n’est pas automatique à partir des seules règles
internes de formation et de `visibleMemOfMem`.

Sous `MembershipReflection`, les équivalences internes de membership suffisent
cependant à dériver propositionnellement les lois visibles des constructeurs
élémentaires :

```text
EmptyProjectionLaw empty⁺
PairProjectionLaw (pair⁺ A B)
UnionProjectionLaw (union⁺ A)
```

Sans réflexion, ces lois doivent être ajoutées séparément.

Pour l’union, une forme purement visible possible est :

```text
UnionProjectionLaw (U : UnionFormation A) :=
  ∀ X : VisibleSet,
    VisibleMem X (project U.set)
    ↔
    ∃ V : VisibleSet,
      VisibleMem V (project A)
      ∧
      VisibleMem X V
```

L’usage de `∃` est ici volontaire : cette loi appartient au niveau visible
propositionnel. La provenance formée reste portée séparément par l’équivalence
de types de `UnionFormation.membership`.

Pour la séparation, une loi visible ne peut être demandée qu’après fourniture
d’un prédicat visible `Pᵥ` et d’une compatibilité :

```text
∀ x,
  P x ↔ Pᵥ (project x)
```

On peut alors formuler :

```text
SeparationProjectionLaw S Pᵥ :=
  ∀ X : VisibleSet,
    VisibleMem X (project S.set)
    ↔
    (
      VisibleMem X (project A)
      ∧
      Pᵥ X
    )
```

Seulement après ajout de ces lois, ou après leur dérivation à partir de
`MembershipReflection`, peut-on conclure que les projections des constructeurs
satisfont les axiomes visibles correspondants.

Un théorème global de projection devra en outre préciser si tout visible est
représenté. Sans `visibleCoverage`, il ne porte naturellement que sur les
objets visibles obtenus par `project` et sur les constructeurs explicitement
définis.

---
## 44. Théorème de non-contraction

Objectif :

```text
une diagonalisation positive
ne peut pas coexister
avec une fidélité globale de project.
```

La preuve doit consommer :

```text
cell.sameVisible
```

puis :

```text
cell.separated
```

Le théorème négatif reste dérivé de la donnée affirmative.

---

## 45. Théorème de transport

Objectif :

```text
ProjectedIdentity A B
↔
transport de toutes les lectures visibles.
```

Ce théorème établit l’identité d’usage sans contraction interne.

---

## 46. Théorème de séparation formation/vérité projetée

Objectif :

```text
LocalSetTruthGap
→
(
  donnée d’une scène formée
  non stable par vérité projetée
)
×
(
  donnée d’une scène stable par vérité projetée
  sans formation positive
)
```

Ce résultat construit des contre-exemples internes aux deux implications entre :

```text
formation positive
```

et :

```text
vérité déterminée par la seule projection
```

Il ne revendique pas encore une indépendance relative entre deux systèmes axiomatiques.

---

## 47. Théorème de conservativité visible

Objectif majeur : définir un langage visible et une traduction précise.

Une formulation possible est :

```text
si une phrase du langage visible
est dérivable dans le système formé
sans utiliser de principe supplémentaire
sur les témoins internes,
alors sa traduction est dérivable
dans une théorie extensionnelle cible.
```

Cibles possibles :

```text
CZF
IZF
un fragment de ZF
une théorie des types extensionnelle
```

Avant tout théorème, il faut fixer :

```text
la syntaxe du langage visible
la sémantique de VisibleSet et VisibleMem
la représentation ou non de tous les visibles
la traduction des constructeurs
les règles qui peuvent mentionner les témoins internes
```

La conservativité n’est donc pas encore un énoncé mathématique fermé dans la
version présente ; c’est un programme de formalisation.

---
## 48. Théorème de cohérence relative

Objectif :

```text
si la théorie des types modèle utilisée est cohérente,
alors le noyau de la théorie des ensembles formés est cohérent.
```

La première version devrait éviter :

```text
puissance forte
choix classique
compréhension non bornée
```

afin d’isoler le noyau positif.

### 48.1 Premier modèle jouet dégénéré du noyau adéquat

Un modèle minimal, volontairement dégénéré, valide déjà la compatibilité de :

```text
projection constante
adéquation propositionnelle de l’appartenance
extensionalité visible
cellule diagonale habitée
témoin positif
formation vide
```

On prend :

```text
FormedSet  := Bool
VisibleSet := Unit

project _ := ()

Mem _ _ := Empty
VisibleMem _ _ := False
```

Alors :

```text
MembershipProjection
MembershipReflection
VisibleExtensionalStructure
```

sont habités.

Les deux booléens fournissent une cellule diagonale séparée de même projection.
Avec :

```text
WitnessOf _ := Unit
Positive _ _ := True
```

on obtient une diagonalisation positive triviale. Ce modèle confirme
seulement la cohérence relative du squelette avec les types inductifs usuels ;
il ne valide aucun contenu ensembliste substantiel. Il montre également la
nécessité de choisir un témoin non trivial pour obtenir un apport
métamathématique.

Une `EmptyFormation` existe. En revanche, aucune `PairFormation false true`
n’existe dans ce modèle puisque toutes les appartenances internes sont vides.

### 48.2 Modèle jouet des constructeurs internes

Un second modèle peut prendre des termes syntaxiques :

```text
FormedSet :=
  empty
  | pair FormedSet FormedSet
  | union FormedSet
```

et une famille inductive `Mem` engendrée par :

```text
pair_left
pair_right
union_intro
```

Il valide les spécifications internes :

```text
EmptyFormation
PairFormation
UnionFormation
```

On peut lui donner une projection grossière vers `Unit` et une appartenance
visible toujours vraie afin de satisfaire seulement `MembershipProjection`.

Ce modèle ne satisfait ni `MembershipReflection` ni les lois visibles du vide.
Il montre concrètement que :

```text
constructeurs internes
+
projection des témoins
```

ne suffisent pas à obtenir une sémantique extensionnelle exacte.

Ces modèles jouets ne prouvent pas la cohérence de la théorie complète, mais
ils vérifient deux séparations structurelles centrales du document.

---

# Partie XIII — Architecture Lean proposée

## 49. Modules initiaux

Une première implémentation devrait refléter la stratification :

```text
PositiveSetTheory/RawSignature.lean
PositiveSetTheory/MembershipProjection.lean
PositiveSetTheory/MembershipReflection.lean
PositiveSetTheory/MembershipRealization.lean
PositiveSetTheory/VisibleExtensionality.lean
PositiveSetTheory/Identity.lean
PositiveSetTheory/Diagonalization.lean
PositiveSetTheory/TruthGap.lean
PositiveSetTheory/LocalRecovery.lean
```

Constructeurs élémentaires candidats :

```text
PositiveSetTheory/Empty.lean
PositiveSetTheory/Pair.lean
PositiveSetTheory/Union.lean
PositiveSetTheory/BoundedSeparation.lean
```

Extensions fortes :

```text
PositiveSetTheory/ExternalSeparation.lean
PositiveSetTheory/Image.lean
PositiveSetTheory/Replacement.lean
PositiveSetTheory/Collection.lean
PositiveSetTheory/Infinity.lean
PositiveSetTheory/Power.lean
PositiveSetTheory/Foundation.lean
PositiveSetTheory/Choice.lean
PositiveSetTheory/VisibleCoverage.lean
```

Modèles et métathéorie :

```text
PositiveSetTheory/Models/Presentation.lean
PositiveSetTheory/Models/WellFoundedTree.lean
PositiveSetTheory/ProjectionTheorem.lean
PositiveSetTheory/VisibleConservativity.lean
```

---
## 50. Discipline de formalisation

Chaque module doit distinguer :

```text
structures primitives
constructeurs
éliminateurs
théorèmes dérivés
principes optionnels
```

Les règles recommandées sont :

```text
aucune hypothèse classique implicite
aucun quotient imposé aux formations
aucune extensionalité interne globale
aucune existence propositionnelle éliminée comme donnée
  sans principe explicite de réalisation ou de choix
aucune causalité attribuée à une réparation sans champ formel
```

Les audits devraient inclure :

```text
#print axioms
```

pour les constructions principales.

---

# Partie XIV — Questions ouvertes

## 51. Questions sur l’appartenance

Il reste à décider :

```text
Mem x A : Type
```

doit-il être :

```text
librement preuve-pertinent
un type propositionnel
un type tronqué dans certains fragments
```

Il faut aussi préciser la relation exacte entre :

```text
Mem
VisibleMem
project
```

sans forcer une reconstruction globale des témoins.

---

## 52. Questions sur l’extensionalité interne

Trois options sont possibles.

### Option A — aucune extensionalité interne

```text
project A = project B
```

ne produit jamais :

```text
A = B
```

sans donnée supplémentaire.

### Option B — extensionalité interne restreinte

Certaines classes de formations normalisées peuvent vérifier :

```text
project A = project B
→
A = B
```

### Option C — normalisation

Une opération :

```text
normalize :
  FormedSet → FormedSet
```

peut choisir une forme canonique avec :

```text
project (normalize A) = project A
```

et une fidélité limitée aux formes normalisées.

Cette opération serait distincte de la théorie fondamentale.

---

## 53. Questions sur les diagonales

Il faut préciser quelles cellules possèdent canoniquement :

```text
WitnessOf cell
```

La théorie ne doit pas affirmer sans preuve :

```text
∀ cell,
  WitnessOf cell
```

Plusieurs familles de témoins peuvent exister :

```text
témoin de provenance
témoin de vérité
témoin de réparation
témoin de rôle
témoin de différence de construction
témoin de stabilité
```

La diagonalisation positive est un schéma paramétré, pas un témoin unique universel.

---

## 54. Questions sur la puissance

L’ensemble des parties est le point le plus délicat.

Il faut décider si la théorie collecte :

```text
des sous-ensembles visibles
des sous-formations internes
des codes de prédicats
des familles petites de témoins
```

La réponse influencera fortement :

```text
la force de la théorie
ses univers
sa cohérence relative
son rapport à CZF ou ZF
```

---

## 55. Questions sur le choix

Il faut distinguer au moins :

```text
choix depuis des sommes dépendantes
choix de représentants dans les fibres de project
choix classique sur des existences propositionnelles
choix de normalisations
```

Ces quatre principes n’ont pas la même force.

La théorie positive doit privilégier :

```text
l’extraction depuis des données déjà présentes
```

et traiter les autres formes comme des extensions séparées.

---

# Partie XV — Résultat du contre-audit sémantique et de typabilité

## 56. Points corrigés par le contre-audit

Le triple contre-audit des versions 0.5 à 0.7 ajoute les corrections suivantes :

```text
1. Les relèvements visibles sont des structures
   contenant représentant, égalité de projection et appartenance.

2. La paire n’utilise plus une somme directement appliquée
   à des propositions ; elle possède un inductif PairOccurrence.

3. La séparation possède un type SeparatedMembership
   qui réunit proprement donnée et proposition.

4. L’image possède un type ImagePreimage
   au lieu d’un produit ambigu entre Type et Prop.

5. La formation géométrique positive est une structure en Type,
   non un produit ambigu ni un Exists propositionnel.

6. La récursion par occurrences utilise un sous-type de positions,
   explicitement situé dans Type.

7. La couverture visible distingue désormais
   la donnée de représentants de sa simple non-vacuité propositionnelle.

8. L’adéquation de l’appartenance distingue projection,
   réflexion propositionnelle et réalisation en données.

9. Le terme « positif » est distingué de la positivité logique :
   une obstruction affirmative peut contenir un réfutateur vers False.

10. Le remplacement est séparé de l’image relationnelle
    et exige totalité plus fonctionnalité.

11. La causalité de la réparation relie désormais explicitement
    repair au champ recovered.

12. Deux modèles jouets vérifient séparément
    le noyau diagonal adéquat et les constructeurs internes.

13. La définition du représentant visible n’apparaît plus deux fois.

14. La fonctionnalité du remplacement est relative
    au domaine remplacé, et non imposée globalement à R.

15. La discipline finale distingue désormais
    existence propositionnelle et donnée réalisante.

16. La fonctionnalité projetée est elle aussi
    relative au domaine remplacé.

17. Les scènes du gap de vérité et les quatre termes
    de séparation sont maintenant explicitement définis.
```

---
## 57. Statut après contre-audit

Le document est désormais mieux stratifié au niveau de ses pseudo-signatures
Lean-like et de la sémantique de l’appartenance. Il ne mélange plus
silencieusement :

```text
projection et extension exacte
réflexion propositionnelle et réalisation en données
image relationnelle et remplacement
présence d’une réparation et causalité de la réparation
affirmativité d’un paquet et positivité logique
```

Cette formulation n’est pas une preuve de cohérence logique.

Cette conclusion ne signifie pas que le document compile. Restent notamment à
fixer dans un premier fichier Lean :

```text
les paramètres d’univers exacts
les espaces de noms
les arguments implicites
les niveaux de Sort des équivalences
les structures de petitesse
les codes de prédicats bornés
```

Le prochain seuil de vérification est donc double :

```text
1. traduire RawPositiveSetSignature,
   ProjectedSetCell,
   PositiveSetDiagonalization
   et InterfaceTransport dans un fichier Lean compilable ;

2. construire un modèle de EmptyFormation,
   PairFormation et UnionFormation.
```

La cohérence relative et la conservativité visible restent entièrement
ouvertes.

---

# Partie XVI — Première formulation synthétique

## 58. Définition proposée

Une **théorie constructive des ensembles formés**, au stade présent, est une
spécification dépendamment typée à deux sortes dans laquelle :

```text
1. les objets internes sont des formations porteuses de données ;

2. leur lecture visible est obtenue par projection ;
   elle devient une extension exacte sous MembershipReflection ;

3. l’extensionalité agit au niveau visible ;

4. l’égalité visible devient une identité d’usage
   et transporte les lectures ;

5. le type des cellules à même projection visible
   et pôles séparés est explicitement définissable ;

6. lorsqu’une telle cellule porte un témoin positif,
   ce témoin dépend de la cellule entière ;

7. les constructeurs effectivement ajoutés
   retournent des formations accompagnées
   de leurs certificats internes ;

8. une récupération locale, lorsqu’elle est fournie,
   reste distincte d’une reconstruction globale ;

9. le choix classique n’est pas utilisé implicitement
   pour extraire des représentants
   depuis de simples non-vacuités propositionnelles.
```

Les points 5, 6 et 8 sont conditionnels à l’existence des paquets
correspondants. La signature brute ne postule aucune cellule diagonale, aucun
témoin positif et aucune réparation locale.

---

## 59. Formule directrice

La formule centrale est :

```text
formation interne
+
projection visible
+
séparation non contractive
+
témoin positif dépendant
+
transport d’usage
```

et non :

```text
extension visible
=
totalité de l’ensemble
```

---

## 60. Conclusion provisoire

Le programme proposé vise à réécrire le geste ensembliste fondamental.

Dans une lecture purement extensionnelle :

```text
un ensemble est déterminé par ses éléments.
```

Dans la lecture positive formée, lorsque l’adéquation de l’appartenance est
établie :

```text
une extension visible détermine un usage commun,
mais elle ne détermine pas nécessairement
la formation interne qui la porte.
```

Sans `MembershipReflection`, il faut parler seulement de projection ou de
lecture visible.

Une configuration suffisamment enrichie peut réunir :

```text
deux formations visiblement identiques
leur séparation interne
un témoin positif de leur cellule
un transport commun au niveau visible
éventuellement une réparation locale
et la non-reconstruction globale de toutes les formations
```

Ces propriétés ne sont pas toutes dérivées de la seule égalité projetée :
elles proviennent des paquets positifs effectivement fournis.

Le programme fondationnel est alors :

```text
remplacer les existences nues
par des constructions dépendamment témoignées ;

conserver l’extensionalité comme lecture visible ;

faire de la diagonalisation positive
un principe de formation
plutôt qu’un simple procédé de négation.
```

Ce document constitue seulement le premier noyau conceptuel. Les prochaines étapes sont :

```text
formaliser les signatures Lean minimales ;
choisir un premier modèle ;
prouver le théorème de transport ;
construire le gap local de vérité ;
établir un fragment visible extensionnel ;
analyser la cohérence relative.
```
