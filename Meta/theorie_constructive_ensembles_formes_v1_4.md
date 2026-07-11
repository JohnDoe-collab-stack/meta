# Théorie constructive des ensembles formés
## Esquisse fondationnelle issue de la diagonalisation positive

**Statut :** document de travail, version 1.4 — modèle explicite du noyau diagonal et classification axiomatique stabilisée  
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

## Résultat principal de la réanalyse axiomatique

La réanalyse complète conduit à une correction importante :

```text
il ne faut pas prendre
« il existe une diagonalisation positive »
comme axiome primitif sans contenu déterminé.
```

Une telle formulation resterait arbitraire et pourrait être satisfaite par :

```text
WitnessOf _ := Unit
Positive _ _ := True
```

Le premier noyau réellement caractéristique est obtenu par le contraste entre
deux familles de principes.

### Principes de formation interne

```text
les constructeurs formés conservent
leurs paramètres, leurs occurrences et leur provenance.
```

La première loi abstraite concrète de cette famille est la rigidité de la paire formée :

```text
égalité interne de deux paires formées
→
égalité de leurs paramètres dans le même ordre.
```

### Principes d’extensionalisation visible

```text
la projection visible oublie
l’ordre des présentations, la multiplicité des occurrences
et certaines provenances de formation.
```

Pour la paire, l’extensionalité visible donne :

```text
project (pair⁺ A B).set
=
project (pair⁺ B A).set
```

alors que la rigidité interne permet de conserver :

```text
(pair⁺ A B).set
=
(pair⁺ B A).set
→
A = B.
```

Si `A` et `B` sont séparés, on obtient donc une cellule diagonale.

### Premier théorème diagonal canonique

Le vide formé et sa paire réflexive donnent constructivement deux formations
séparées :

```text
E := empty⁺.set
S := (pair⁺ E E).set

E = S → False.
```

On forme ensuite :

```text
formed := (pair⁺ E S).set
shadow := (pair⁺ S E).set
```

La projection visible les identifie par commutativité extensionnelle de la
paire. La rigidité de formation les sépare intérieurement. Les quatre occurrences de `E` et `S`, à gauche et à droite, donnent un témoin
dépendant dont la structure est imposée par la provenance de la paire, plutôt
qu’un témoin arbitrairement choisi comme `Unit`.

La première diagonalisation positive peut donc être un **théorème** issu de :

```text
formation vide
+
paire preuve-pertinente
+
rigidité interne de la paire
+
loi V1 de projection visible de la paire
+
extensionalité visible
```

La loi visible de la paire peut être portée localement ou dérivée d’une
réflexion/réalisation globale de l’appartenance.

Le principe central n’est ainsi pas une obstruction ni une existence
diagonale nue. C’est une **loi de provenance ou de rigidité de formation**.

Dans une axiomatique abstraite de `FormedSet`, cette loi est ajoutée comme
axiome. Dans un modèle où les formations sont données par une syntaxe
inductive, elle doit plutôt être dérivée du principe de non-confusion des
constructeurs. Le document ne revendique donc pas que `PairRigidity` soit un
axiome universel nécessaire à toute présentation de la théorie.

### Axiomes candidats dégagés

La théorie candidate se répartit en quatre groupes :

```text
A. axiomes de présentation à deux niveaux ;
B. axiomes positifs de formation ;
C. axiomes de rigidité ou de provenance interne ;
D. principes d’extension optionnels :
   collection, infini, puissance, réparation, vérité admissible.
```

Le transport, l’obstruction, la non-reconstruction et la première
diagonalisation positive sont destinés à être dérivés, non postulés
indépendamment.

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

Dans la signature actuelle, où `VisibleMem` vit dans `Prop`,
`MembershipRealization` est une extension opératoire forte : elle ajoute une
section qui choisit une donnée formée à partir d’une preuve visible.
`MembershipReflection` est la couche d’adéquation propositionnelle naturelle.

Une implémentation véritablement data-first peut au contraire introduire une
relation visible à valeurs dans `Type` et définir sa vue propositionnelle par
`Nonempty`. Cette alternative évite de présenter P2⁺ comme si les données
étaient déjà contenues dans `VisibleMem`.

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
### 17.1 Provenance et rigidité de la paire formée

La spécification `PairFormation` décrit les occurrences internes, mais elle
n’interdit pas à une même valeur de `FormedSet` de servir de paire à plusieurs
listes de paramètres.

Pour que la formation conserve réellement son orientation dans une
présentation abstraite, on introduit la loi suivante :

```text
structure PairRigidity
    (pair⁺ :
      ∀ A B : FormedSet,
        PairFormation A B) : Prop where
  parameters :
    ∀ A B C D : FormedSet,
      (pair⁺ A B).set =
      (pair⁺ C D).set
      →
      (
        A = C
        ∧
        B = D
      )
```

Cette loi ne dit pas que la paire visible est ordonnée.

Le symbole `pair⁺ A B` doit être lu comme une **présentation formée orientée**
de la paire visible non ordonnée. L’ordre appartient à la provenance de
formation, pas à son extension visible.

Il dit que la **formation interne** de la paire retient l’ordre de ses
paramètres. L’ordre est ensuite oublié par la projection visible.

Dans un modèle où `FormedSet` est un type inductif de présentations, cette
rigidité peut être un théorème de non-confusion des constructeurs. Dans une
axiomatique abstraite de `FormedSet`, elle doit être portée comme loi.

### 17.2 Loi visible de permutation

Sous :

```text
PairProjectionLaw
VisibleExtensionalStructure
```

on dérive :

```text
pairSwap_sameVisible :
  ∀ A B : FormedSet,
    project (pair⁺ A B).set
    =
    project (pair⁺ B A).set
```

La preuve compare les membres visibles :

```text
U appartient visiblement à pair A B
↔ U = project A ∨ U = project B
↔ U = project B ∨ U = project A
↔ U appartient visiblement à pair B A.
```

L’extensionalité visible conclut l’égalité des projections.

La commutativité est donc visible, tandis que l’orientation reste interne.

### 17.3 Séparation canonique de deux paramètres

On pose :

```text
E :=
  empty⁺.set

S :=
  (pair⁺ E E).set
```

Le constructeur de paire fournit :

```text
Mem E S
```

par l’occurrence gauche.

Si :

```text
E = S
```

alors ce témoin se réécrit en :

```text
Mem E E
```

et contredit `empty⁺.elim`.

On obtient donc constructivement :

```text
empty_ne_reflexivePair :
  E = S → False
```

Aucun axiome de non-vacuité distincte n’est requis.

### 17.4 Cellule diagonale canonique par permutation

On définit :

```text
canonicalPairCell.formed :=
  (pair⁺ E S).set

canonicalPairCell.shadow :=
  (pair⁺ S E).set
```

La loi visible de permutation donne :

```text
project canonicalPairCell.formed
=
project canonicalPairCell.shadow.
```

Si les deux formations étaient égales, `PairRigidity.parameters` donnerait :

```text
E = S
```

en contradiction avec `empty_ne_reflexivePair`.

On obtient donc :

```text
canonicalPairCell :
  ProjectedSetCell
```

sans axiome indépendant d’existence diagonale.

### 17.5 Témoin positif de permutation

Pour que l’orientation ne soit pas seulement suggérée par les noms des champs,
on introduit un témoin qui enregistre le décodage exact d’une occurrence :

```text
structure PairOccurrenceWitness
    {A B x : FormedSet}
    (P : PairFormation A B)
    (occurrence : PairOccurrence x A B) : Type where
  member :
    Mem x P.set

  decodes_to :
    P.membership.toFun member
    =
    occurrence
```

Le témoin de permutation dépend alors de la cellule entière :

```text
structure PairSwapWitness
    (A B : FormedSet)
    (cell : ProjectedSetCell) : Type where
  formed_is_pair :
    cell.formed = (pair⁺ A B).set

  shadow_is_swapped_pair :
    cell.shadow = (pair⁺ B A).set

  parameters_separated :
    A = B → False

  a_left_in_formed :
    PairOccurrenceWitness
      (pair⁺ A B)
      (PairOccurrence.left rfl)

  b_right_in_formed :
    PairOccurrenceWitness
      (pair⁺ A B)
      (PairOccurrence.right rfl)

  b_left_in_shadow :
    PairOccurrenceWitness
      (pair⁺ B A)
      (PairOccurrence.left rfl)

  a_right_in_shadow :
    PairOccurrenceWitness
      (pair⁺ B A)
      (PairOccurrence.right rfl)
```

Chaque terme canonique est construit en appliquant l’inverse de l’équivalence
`PairFormation.membership` au constructeur `left` ou `right`, puis en utilisant
la loi `apply_symm_apply` de l’équivalence.

Les égalités `formed_is_pair` et `shadow_is_swapped_pair` permettent ensuite de
transporter ces appartenances vers les pôles exacts de `cell` lorsque cela est
nécessaire.

Le témoin conserve donc effectivement :

```text
A comme occurrence gauche dans la formation ;
B comme occurrence droite dans la formation ;
B comme occurrence gauche dans l’ombre ;
A comme occurrence droite dans l’ombre.
```

Le prédicat `Positive` n’a pas besoin de dupliquer les données du témoin. Une
forme minimale de cohérence est :

```text
PairSwapPositive
    (A B : FormedSet)
    (cell : ProjectedSetCell)
    (witness : PairSwapWitness A B cell) :=
  A = B → False
```

avec :

```text
witness_pos := witness.parameters_separated
```

Le contenu positif substantiel est `PairSwapWitness` lui-même. Le champ
propositionnel `witness_pos` certifie sa cohérence ; il n’est pas présenté
comme une seconde source indépendante de données.

On construit alors :

```text
canonicalPositiveDiagonal :
  PositiveSetDiagonalization
    (PairSwapWitness E S)
    (PairSwapPositive E S)
```

Cette construction ne fait intervenir ni `MembershipReflection` ni
`MembershipRealization` : elle dépend seulement des formations internes, de
leur provenance rigide et de la loi visible locale de la paire.

---

### 17.6 Schéma de provenance formée

La paire suggère un schéma plus général :

```text
égalité interne des résultats d’un constructeur
→
égalité des données de formation pertinentes.
```

Exemples possibles :

```text
PairRigidity
UnionProvenance
SeparationProvenance
ImageProvenance
```

Ces lois ne doivent être ajoutées que lorsque le modèle de `FormedSet`
conserve effectivement les paramètres concernés.

Le principe général est :

```text
rigidité de la formation
+
équation extensionnelle visible
+
séparation des paramètres
→
diagonalisation positive dérivée.
```

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

Une séparation bornée au sens syntaxique exige des codes dépendant de la
base :

```text
BoundedPredicateCode :
  FormedSet → Typeᵦ

Satisfies :
  ∀ {A : FormedSet},
    BoundedPredicateCode A →
    FormedSet →
    Prop

separateBounded⁺ :
  ∀ A,
  ∀ code : BoundedPredicateCode A,
    SeparationFormation A (Satisfies code)
```

La définition de `BoundedPredicateCode A` doit garantir que seules les formules
bornées autorisées relativement à `A` sont représentées.

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

# Partie IX — Axiomatique candidate extraite

## 35. Métathéorie constructive ambiante

Les règles suivantes appartiennent à la métathéorie et non à la théorie
interne des ensembles formés :

```text
univers Type
univers Prop
fonctions dépendantes Π
sommes dépendantes Σ
types inductifs
égalité intentionnelle
type vide
type unité
équivalences de types
Nonempty comme troncation propositionnelle faible
```

Toute preuve de cohérence de la théorie des ensembles formés sera relative à
cette métathéorie.

---

## 36. Signature primitive

Le noyau de symboles est :

```text
FormedSet  : Typeᵤ
VisibleSet : Typeᵥ

project :
  FormedSet → VisibleSet

Mem :
  FormedSet → FormedSet → Typeₘ

VisibleMem :
  VisibleSet → VisibleSet → Prop
```

Ces symboles ne constituent pas encore des axiomes d’existence ou de
formation.

---

## 37. Principes structurels de présentation

### P1 — projection de l’appartenance

```text
membershipProjection :
  ∀ {x A : FormedSet},
    Mem x A
    →
    VisibleMem (project x) (project A)
```

Toute occurrence formée produit une appartenance visible.

### P2ʳ — réflexion propositionnelle de l’appartenance

```text
membershipReflection :
  ∀ {U : VisibleSet}
    {A : FormedSet},
    VisibleMem U (project A)
    →
    Nonempty (VisibleMembershipLift U A)
```

Cette loi exprime l’adéquation extensionnelle sans sélectionner un représentant
calculable hors de la troncation propositionnelle.

### P2⁺ — réalisation en données, principe fort optionnel

```text
membershipRealization :
  ∀ {U : VisibleSet}
    {A : FormedSet},
    VisibleMem U (project A)
    →
    VisibleMembershipLift U A
```

`P2⁺` implique `P2ʳ`, mais sa réciproque n’est pas constructive en général.

Il faut corriger son statut : `P2⁺` ne révèle pas simplement une donnée déjà
contenue dans `VisibleMem`, puisque `VisibleMem` vit dans `Prop`. Il ajoute une
**section globale de réalisation** depuis une preuve visible vers un
représentant formé. Il est donc proche d’un principe de choix de représentants
et ne fait pas partie du noyau diagonal minimal.

Comme les preuves de `VisibleMem U (project A)` sont preuve-irrélevantes, deux
applications de `membershipRealization` à deux preuves de la même appartenance
visible donnent des relèvements égaux par congruence. P2⁺ sélectionne donc, à
égalité près, un relèvement canonique pour chaque couple `(U,A)` habité. Cette
conséquence confirme sa force.

Une architecture réellement data-first peut éviter ce principe en prenant une
relation visible à valeurs dans `Type`, puis en définissant sa vue
propositionnelle par `Nonempty`. Ce choix de signature devra être étudié dans
l’implémentation Lean.

### P3 — extensionalité visible

```text
visibleExtensionality :
  ∀ V W : VisibleSet,
    (
      ∀ U : VisibleSet,
        VisibleMem U V
        ↔
        VisibleMem U W
    )
    →
    V = W
```

Cette loi agit seulement sur `VisibleSet`.

La théorie n’ajoute pas :

```text
project A = project B
→
A = B.
```

### Trois architectures possibles

#### Route diagonale locale

```text
P3
+
lois de projection propres aux constructeurs utilisés
```

Cette route suffit à la diagonale canonique de la paire. Elle ne suppose aucun
relèvement global des appartenances visibles.

#### Route adéquate propositionnelle

```text
P1 + P2ʳ + P3
```

Les lois visibles du vide, de la paire et de l’union se dérivent
propositionnellement de leurs règles internes.

#### Route réalisée en données

```text
P1 + P2⁺ + P3
```

Elle fournit des représentants calculables et implique la route précédente.
Elle est plus forte et doit être modélisée séparément.

### Limite pour la séparation

Même sous `P2ʳ` ou `P2⁺`, la loi visible d’une séparation ne se déduit pas tant
que le prédicat formé n’est pas muni d’une sémantique visible et d’une loi de
factorisation. L’adéquation de l’appartenance ne suffit pas à faire descendre
un prédicat qui distingue deux formations de même projection.

---

## 38. Axiomes positifs de formation élémentaire

### Axiome F0 — vide formé

```text
empty⁺ :
  EmptyFormation
```

Il fournit une formation et son éliminateur interne.

### Axiome F1 — paire preuve-pertinente

```text
pair⁺ :
  ∀ A B : FormedSet,
    PairFormation A B
```

La paire conserve les occurrences gauche et droite.

### Axiome F2 — rigidité de la paire

```text
pairRigidity :
  PairRigidity pair⁺
```

Dans une présentation abstraite, c’est la première loi non extensionnelle de
provenance ajoutée à la théorie. Dans un modèle syntaxique inductif, elle doit
être un théorème de non-confusion plutôt qu’un axiome supplémentaire.

Il garantit que l’égalité interne d’une paire formée conserve l’ordre des
paramètres.

### Loi V1 — projection visible de la paire

Dans la route locale, on ajoute :

```text
pairProjection :
  ∀ A B : FormedSet,
    PairProjectionLaw (pair⁺ A B)
```

Dans la route adéquate, cette loi est un théorème dérivé de P1, P2ʳ et des
règles internes de `PairFormation`. Elle est donc aussi dérivable dans la route
plus forte P2⁺.

### Axiome F3 — union avec provenance

```text
union⁺ :
  ∀ A : FormedSet,
    UnionFormation A
```

L’appartenance à l’union restitue le membre intermédiaire et les deux témoins
d’appartenance.

### Axiome F4 — séparation bornée codée

La famille de codes doit être dépendante de la base :

```text
BoundedPredicateCode :
  FormedSet → Typeᵦ

Satisfies :
  ∀ {A : FormedSet},
    BoundedPredicateCode A
    → FormedSet
    → Prop
```

La formation est :

```text
separateBounded⁺ :
  ∀ A : FormedSet,
  ∀ code : BoundedPredicateCode A,
    SeparationFormation
      A
      (Satisfies code)
```

Le langage des codes et sa condition de petitesse doivent être définis avant
compilation.

Pour obtenir une loi visible, il faut une donnée supplémentaire :

```text
VisibleSatisfies :
  ∀ {A : FormedSet},
    BoundedPredicateCode A
    → VisibleSet
    → Prop

boundedPredicateFactors :
  ∀ {A : FormedSet}
    (code : BoundedPredicateCode A)
    (x : FormedSet),
    Mem x A →
      (
        Satisfies code x
        ↔
        VisibleSatisfies code (project x)
      )
```

Cette factorisation relative aux membres de `A` n’est pas automatique. Elle
est impossible dès que, parmi les membres pertinents de `A`, le prédicat formé
distingue deux formations de même projection.

---

## 39. Principe caractéristique : provenance formée

`PairRigidity` est la première instance abstraite d’un principe plus général.

### Schéma PR — rigidité des constructeurs formés

Pour un constructeur :

```text
form :
  Parameters → FormedSet
```

une loi de provenance a la forme :

```text
form p = form q
→
SameFormationParameters p q.
```

Ce schéma ne doit pas être imposé uniformément à tous les constructeurs.

Il est admissible seulement lorsque le modèle conserve effectivement les
paramètres concernés.

### Rôle fondationnel

La théorie visible peut vérifier des équations telles que :

```text
pair A B = pair B A
```

au niveau de la projection, tandis que la provenance formée conserve l’ordre.

Le contraste :

```text
équation visible
+
rigidité interne
```

est le moteur de la diagonalisation positive.

Ce schéma est absent d’une théorie purement extensionnelle, où l’objet est
déjà contracté par ses membres.

---

## 40. Théorème axial central : diagonale positive canonique

Sous :

```text
P3  visibleExtensionality
F0  empty⁺
F1  pair⁺
F2  pairRigidity
V1  pairProjection
```

La loi V1 peut être primitive, ou dérivée de :

```text
P1 + P2ʳ
```

et donc, dans le système plus fort, de :

```text
P1 + P2⁺.
```

La diagonalisation canonique elle-même n’utilise toutefois aucun relèvement
global lorsque V1 est fourni localement.

On construit alors :

```text
canonicalPairCell :
  ProjectedSetCell
```

et :

```text
canonicalPairSwapWitness :
  PairSwapWitness E S canonicalPairCell
```

puis une instance :

```text
canonicalPositiveDiagonal :
  PositiveSetDiagonalization
    (PairSwapWitness E S)
    (PairSwapPositive E S).
```

Cette construction est un théorème.

Il ne faut donc pas ajouter au noyau un axiome indépendant :

```text
Σ cell,
Σ witness,
  Positive cell witness.
```

Une telle existence nue masquerait précisément la provenance positive que la
théorie cherche à conserver.

---

## 41. Axiomes d’un noyau constructif plus fort

Pour approcher une théorie de force comparable à un fragment de CZF, on peut
ajouter séparément :

### Axiome C1 — infini formé

```text
infinity⁺ :
  InfinityFormation
```

La structure exacte doit fournir zéro, successeur, clôture et un principe
d’induction approprié.

### Axiome C2 — collection forte preuve-pertinente

```text
strongCollection⁺ :
  StrongCollectionFormation
```

La totalité et la couverture doivent être indexées par les occurrences
`m : Mem x A`.

### Axiome C3 — induction sur l’appartenance formée

```text
formedSetInduction
```

La version la plus informative quantifie sur chaque occurrence
`m : Mem x A`.

Ces principes ne sont pas dérivés des axiomes élémentaires.

---

## 42. Principes optionnels de puissance supérieure

Les extensions suivantes doivent rester dans des modules séparés :

```text
séparation métathéorique complète
remplacement relationnel
collection extensionnelle ou tronquée
puissance positive
subset collection
fondation bien fondée
normalisation
couverture globale de VisibleSet
choix global de représentants
```

Leur ajout modifie la force de la théorie et demande un modèle.

---

## 43. Principes diagonaux optionnels non fondamentaux

### Vérité formée admissible

Une famille :

```text
TruthData :
  FormedSet → Type
```

peut devenir un principe supplémentaire si elle est munie d’une notion
d’admissibilité indépendante de l’identité interne triviale.

Un simple choix :

```text
TruthData X := X = cell.formed
```

sépare toute cellule, mais n’apporte pas encore une sémantique de vérité
substantielle.

### Réparation locale

Une famille :

```text
RepairOf :
  FormedSet → Type
```

et un habitant de :

```text
LocalProjectiveRecovery RepairOf
```

constituent une extension opérationnelle.

La version causale doit ajouter une opération ou une relation reliant
`repair` à `recovered`.

### Principe de persistance

Une extension peut demander que certains témoins diagonaux soient conservés
sous changement de projection ou de régime visible.

Ce principe généralise `ConstrainedProjectionRelaxation`, mais n’appartient
pas au noyau ensembliste élémentaire.

---

## 44. Ce qui est dérivé et ne doit pas être axiomatisé

Les constructions suivantes sont des théorèmes :

```text
identité projetée comme identité d’usage
transport de toute lecture visible
obstruction à la fidélité de la projection
impossibilité d’une reconstruction globale exacte
lois visibles du vide, de la paire et de l’union
  sous réalisation et extensionalité
commutativité visible de la paire
cellule diagonale canonique
témoin positif de permutation
gap local de vérité formel pour un prédicat artificiel construit depuis une cellule
```

Les postuler séparément introduirait des redondances et masquerait les
dépendances constructives. Le gap de vérité ainsi dérivé n’est pas encore une
sémantique substantielle de vérité ; celle-ci exige une famille admissible
`TruthData`.

---

## 45. Hiérarchie recommandée des théories

### `PFS_D` — noyau diagonal minimal

```text
P3
F0, F1, F2
V1
```

Cette théorie possède la diagonale positive canonique de permutation. Elle ne
requiert ni P1, ni P2ʳ, ni P2⁺.

### `PFS₀ʳ` — présentation formée adéquate propositionnellement

```text
P1, P2ʳ, P3
F0, F1, F2, F3, F4
```

Elle dérive propositionnellement les lois visibles du vide, de la paire et de
l’union. La loi visible de la séparation exige en plus la sémantique visible
des codes et `boundedPredicateFactors`.

`PFS₀ʳ` étend `PFS_D` lorsque V1 est dérivé de P1 et P2ʳ.

### `PFS₀⁺` — extension réalisée en données

```text
PFS₀ʳ
+
P2⁺
```

Comme P2⁺ implique P2ʳ, une présentation formelle évitera de stocker les deux
preuves indépendamment. Cette extension choisit un représentant formé pour
chaque appartenance visible et doit être considérée comme un principe fort de
réalisation, non comme le noyau de la théorie.

### `PFS_C` — noyau constructif de collection

```text
PFS₀ʳ
+
C1 infini
+
C2 collection forte
+
C3 induction formée
```

Une variante `PFS_C⁺` peut ajouter P2⁺. La comparaison future avec CZF devrait
d’abord être étudiée sur la version réfléchie, moins forte et plus naturellement
modélisable par troncation.

### `PFS_P` — extension de puissance

```text
PFS_C
+
puissance positive ou subset collection
```

Sa cohérence et ses univers doivent être étudiés séparément.

### `PFS_R` — extension opérationnelle

```text
PFS₀ʳ
+
familles de réparation
+
récupérations locales
+
lois causales optionnelles
```

### `PFS_T` — extension de vérité formée

```text
PFS₀ʳ
+
TruthData admissible
+
gaps de vérité non factorisables par project
```

Ces extensions peuvent être combinées seulement après contrôle de leurs
interactions.

---

# Partie X — Fondation et récursion

## 46. Fondation formée

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
## 47. Induction et récursion preuve-pertinentes

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

## 48. Modèle par arbres bien fondés

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

## 49. Modèle par présentations

Le fragment `PFS_D` possède un modèle explicite dans les mathématiques
ordinaires.

### 49.1 Modèle exact du fragment vide–paire

On prend les présentations syntaxiques orientées :

```text
inductive FormedSet where
  | empty
  | pair : FormedSet → FormedSet → FormedSet
```

L’appartenance formée est :

```text
Mem x empty := Empty

Mem x (pair A B) :=
  PairOccurrence x A B
```

On prend pour `VisibleSet` les ensembles héréditairement finis, avec leur
égalité et leur appartenance extensionnelles, puis :

```text
project empty := ∅

project (pair A B) :=
  { project A, project B }
```

Alors :

```text
F0 : le constructeur empty fournit EmptyFormation ;

F1 : le constructeur pair fournit PairFormation ;

F2 : PairRigidity est le théorème d’injectivité
     du constructeur syntaxique pair ;

V1 : PairProjectionLaw suit de la définition
     de la paire visible non ordonnée ;

P3 : l’extensionalité est celle des ensembles
     héréditairement finis.
```

Pour les termes :

```text
E := empty
S := pair E E
P := pair E S
Q := pair S E
```

on vérifie :

```text
E ≠ S
P ≠ Q
project P = project Q
```

Ce modèle établit la satisfaisabilité relative du noyau `PFS_D` dans une
métathéorie où les ensembles héréditairement finis sont disponibles. Il ne
valide pas encore les axiomes d’union, de séparation, de collection ou de
puissance de la théorie complète.

### 49.2 Extension du modèle de présentations

Plus généralement, on peut prendre :

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

Si la syntaxe possède un constructeur orienté :

```text
pairForm A B
```

son principe de non-confusion fournit directement `PairRigidity`.

L’interprétation visible peut néanmoins envoyer :

```text
pairForm A B
pairForm B A
```

sur la même paire extensionnelle. Le modèle par présentations réalise donc
exactement le contraste :

```text
rigidité interne
+
commutativité visible.
```

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

Dans un tel modèle, `MembershipReflection` peut être obtenue lorsque
l’appartenance visible est définie comme troncation existentielle d’une
appartenance formée. `MembershipRealization` demanderait en revanche une
section choisissant un représentant dans chaque classe visible ; elle ne doit
pas être supposée automatique.

---

## 50. Modèle par graphes ou codes

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

## 51. Théorème de projection

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

La séparation n’appartient pas à cette liste sans sémantique visible du code
et loi de factorisation.

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
### 51.1 Théorème de rigidité–contraction

Le premier théorème propre à la nouvelle axiomatique est :

```text
PairRigidity
+
PairProjectionLaw
+
VisibleExtensionalStructure
+
A = B → False
→
ProjectedSetCell
```

avec :

```text
formed := (pair⁺ A B).set
shadow := (pair⁺ B A).set.
```

La donnée de séparation des paramètres est transformée en séparation des
formations par rigidité.

La loi visible de paire est transformée en identité projetée par
extensionalité.

### 51.2 Théorème de diagonalisation positive canonique

En choisissant :

```text
A := empty⁺.set
B := (pair⁺ A A).set
```

la séparation `A = B → False` est dérivée des règles de membership.

On obtient sans hypothèse externe :

```text
canonicalPositiveDiagonal.
```

Ce théorème doit précéder les théorèmes d’obstruction et de
non-reconstruction, car ceux-ci en sont des vues par oubli.

---

## 52. Théorème de non-contraction

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

## 53. Théorème de transport

Objectif :

```text
ProjectedIdentity A B
↔
transport de toutes les lectures visibles.
```

Ce théorème établit l’identité d’usage sans contraction interne.

---

## 54. Théorème de séparation formation/vérité projetée

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

## 55. Théorème de conservativité visible

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
## 56. Théorème de cohérence relative

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

### 56.1 Premier modèle jouet dégénéré du noyau adéquat

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

### 56.2 Modèle jouet des constructeurs internes

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

et, lorsque les constructeurs du type inductif sont orientés et injectifs :

```text
PairRigidity.
```

Le théorème de non-confusion du type inductif fournit alors la loi de
provenance sans axiome supplémentaire dans le modèle.

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

## 57. Modules initiaux

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
PositiveSetTheory/PairRigidity.lean
PositiveSetTheory/CanonicalDiagonal.lean
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
## 58. Discipline de formalisation

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
aucun axiome nu d’existence diagonale
  lorsqu’une diagonale peut être dérivée de la provenance
aucune existence propositionnelle éliminée comme donnée
  sans principe explicite de réalisation ou de choix
aucune causalité attribuée à une réparation sans champ formel
aucune rigidité de constructeur ajoutée
  sans modèle ou justification de provenance
```

Les audits devraient inclure :

```text
#print axioms
```

pour les constructions principales.

---

# Partie XIV — Questions ouvertes

## 59. Questions sur l’appartenance

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

## 60. Questions sur l’extensionalité interne

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

## 61. Questions sur les diagonales

Le premier témoin canonique est maintenant identifié :

```text
PairSwapWitness
```

pour la cellule issue de la permutation d’une paire rigide.

La question générale devient :

```text
quels constructeurs formés possèdent une loi de provenance
et quelles équations visibles produisent
des témoins diagonaux canoniques ?
```

La théorie ne doit toujours pas affirmer sans preuve :

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

## 62. Questions sur la puissance

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

## 63. Questions sur le choix

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

## 64. Points corrigés par le contre-audit

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

18. L’axiome d’existence diagonale nue est remplacé
    par un théorème canonique dérivé de la paire rigide.

19. `PairRigidity` est identifié comme première instance abstraite
    du schéma de provenance formée.

20. Les axiomes sont désormais classés en :
    présentation, formation, provenance,
    noyau constructif et extensions optionnelles.

21. `MembershipRealization` est reclassé comme section forte,
    proche d’un choix de représentants, et non comme noyau positif minimal.

22. `PairRigidity` est un axiome seulement dans la présentation abstraite ;
    il devient un théorème de non-confusion dans un modèle syntaxique.

23. La signature des codes bornés est rendue dépendante de la base,
    et leur descente visible exige une factorisation explicite.

24. Le témoin de permutation conserve désormais explicitement
    la séparation des paramètres et l’orientation des quatre occurrences.

25. L’orientation est certifiée dans le type
    par `PairOccurrenceWitness.decodes_to`, et non seulement par les noms.

26. P2⁺ est reconnu comme une section canonisante :
    la preuve-irrélevance de VisibleMem force l’égalité
    des relèvements produits pour une même appartenance visible.

27. La factorisation visible des prédicats bornés
    est limitée aux membres de la base, ce qui est la force nécessaire.

28. Un modèle explicite par syntaxe orientée et ensembles
    héréditairement finis valide F0, F1, F2, V1 et P3,
    donc le noyau diagonal PFS_D.
```

---
## 65. Statut après contre-audit

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

La satisfaisabilité relative du fragment diagonal `PFS_D` est désormais
étayée par le modèle vide–paire de la section 49. La cohérence relative de la
théorie enrichie par union, séparation, collection, infini ou puissance, ainsi
que la conservativité visible, restent ouvertes.

---

# Partie XVI — Première formulation synthétique

## 66. Définition proposée

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

8. certains constructeurs conservent intérieurement
   leurs paramètres par des lois de provenance,
   tandis que la projection vérifie des équations extensionnelles ;

9. l’interaction entre provenance interne
   et contraction visible produit des diagonales positives
   sans axiome d’existence séparé ;

10. une récupération locale, lorsqu’elle est fournie,
    reste distincte d’une reconstruction globale ;

11. le choix classique n’est pas utilisé implicitement
    pour extraire des représentants
    depuis de simples non-vacuités propositionnelles.
```

Les points 5, 6 et 10 sont conditionnels à l’existence des paquets
correspondants dans une théorie générique. Dans `PFS_D`, le point 9 possède
cependant une réalisation canonique dérivée de `empty⁺`, `pair⁺`,
`PairRigidity`, `PairProjectionLaw` et de l’extensionalité visible. La signature brute seule ne postule aucune cellule diagonale,
aucun témoin positif et aucune réparation locale.

---

## 67. Formule directrice

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

## 68. Conclusion provisoire

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
un résultat de la provenance formée
et de l’extensionalisation visible,
plutôt qu’un axiome nu ou un simple procédé de négation.
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