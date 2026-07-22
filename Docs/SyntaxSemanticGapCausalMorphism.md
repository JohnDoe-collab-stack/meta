# Écart syntaxique et morphisme causal

## Principe

L'écart n'est ni une distance numérique ni une comparaison de deux valeurs de
vérité. Il est une phrase arithmétique distinguée, construite syntaxiquement à
partir de l'état courant. Cette phrase fournit la prise syntaxique par laquelle
l'évaluation locale peut être étendue sans être confondue avec la syntaxe.

À chaque état, la fonction `gap` désigne un gap courant. Cette individuation ne
signifie pas que le système ne possède aucun autre désaccord ou aucune autre
phrase indépendante. Elle signifie qu'un événement syntaxique canonique est
choisi pour marquer la frontière actuelle de l'évaluation, causer le pas
suivant, puis entrer dans le domaine causal déjà évalué.

La propriété d'extension exacte porte sur la mémoire événementielle : un pas
inscrit exactement le gap courant et conserve tous les événements antérieurs.

```text
Memory(advance(S), d)
↔ d = gap(S) ∨ Memory(S, d)
```

Cette loi est plus précise que les trois lois minimales du système causal :

```text
(A) le gap courant est absent de la mémoire courante ;
(I) le pas suivant inscrit le gap courant ;
(C) le pas suivant conserve toute la mémoire antérieure.
```

Les lois `(A)(I)(C)` suffisent à la fraîcheur, à la non-récurrence causale et à
la fidélité additive. La loi d'extension exacte exprime en plus qu'un seul
nouvel événement est ajouté par pas. Des lois locales supplémentaires relient
ensuite cette mémoire syntaxique à l'évaluation propre à chaque système.

## Deux couches distinctes

### Couche syntaxique commune

```text
Sentence
Predicate
diagonal : Predicate → Sentence
```

`Sentence` et `Predicate` sont des formules arithmétiques scopées.
`diagonal` est une transformation de syntaxe. Sa définition ne décide aucune
vérité et n'interroge aucune relation de prouvabilité.

Pour un prédicat `τ : Predicate`, son code est un nombre distinct de la formule
elle-même :

```text
τ : Predicate
τ.raw.code : Nat
diagonal(τ) : Sentence
```

Le diagonaliseur consomme `τ`, pas seulement son code numérique.

### Interfaces d'évaluation locales

Le système tarskien possède son interprétation locale :

```text
models : Sentence → Prop

truthAt(p, s)
:⇔ models(p appliqué au code de s).
```

Le système de théories possède sa relation locale de démontrabilité :

```text
Theorems(S, s)
:⇔ TheoryProvable(S.history, s).
```

À la racine seulement, `Theorems(initialPAState, s)` coïncide avec
`PAProvable(s)`. Après une extension, la relation pertinente est la
prouvabilité dans l'histoire courante, et non la prouvabilité dans PA seule.

Les deux interfaces ne sont ni identifiées ni comparées par le morphisme
causal. Chaque système conserve néanmoins ses propres théorèmes locaux
d'adéquation. En particulier, la formule arithmétique de prouvabilité doit être
reliée à la relation méta-théorique qu'elle représente :

```text
models(provabilityPredicate(h) appliqué au code de s)
↔ TheoryProvable(h, s).
```

Ce théorème appartient au système de prouvabilité. Il ne compare pas la vérité
du gap tarskien à la démontrabilité d'un gap du système de théories.

## Factorisation de l'évaluation par le gap

La séparation entre syntaxe et sémantique n'isole pas la syntaxe de toute
évaluation. Elle impose que le passage de l'une à l'autre soit explicite et
local à chaque système.

Les deux réalisations possèdent ainsi des relations d'évaluation distinctes :

```text
Evaluated_T(S, d)
:⇔ le candidat courant de S est correct à la phrase d

Evaluated_P(S, d)
:⇔ la théorie portée par S démontre la phrase d.
```

Dans le système T, `Evaluated_T` est défini à partir de `CorrectAt`, donc de
`truthAt` et de `models`. Dans le système P, `Evaluated_P` est défini par
`TheoryProvable`. Aucune équivalence n'est demandée entre ces deux relations.

La mémoire fournit, dans chaque système, un domaine causal certifié
d'évaluation :

```text
Memory_T(S, d)
→ Evaluated_T(S, d)

EventMemory_P(S, d)
→ Evaluated_P(S, d).
```

La réciproque n'est pas exigée. Un candidat peut être correct sur une phrase
qui n'est pas mémorisée, et une théorie démontre en général beaucoup plus de
phrases que les seuls événements inscrits dans son histoire. La mémoire ne
représente donc pas toute l'extension de l'évaluateur ; elle représente le
sous-domaine construit causalement et conservé positivement.

Le gap courant est la frontière syntaxique de ce domaine :

```text
¬Evaluated_T(S, gap_T(S))

¬Evaluated_P(S, gap_P(S)).
```

Le pas causé par ce gap construit l'évaluateur suivant en incorporant le gap,
puis certifie que cette incorporation étend effectivement l'évaluation locale :

```text
Evaluated_T(advance_T(S), gap_T(S))

Evaluated_P(advance_P(S), gap_P(S)).
```

Cette fermeture n'est pas une découverte indépendante effectuée par
l'évaluateur après le pas. Elle est visée par la définition même de `advance` :
le gap devient constitutif de l'état qui définit l'évaluateur suivant. La loi
`frontier_closed` certifie que la construction syntaxique produit bien l'effet
d'évaluation annoncé. Elle ne décide pas la vérité du gap et ne transporte
aucune valeur sémantique entre les systèmes.

Les évaluations déjà acquises sont conservées :

```text
Evaluated_T(S, d)
→ Evaluated_T(advance_T(S), d)

Evaluated_P(S, d)
→ Evaluated_P(advance_P(S), d).
```

Dans T, la première conservation dérive du mismatch au gap courant et de la
préservation du patch hors de cet indice. Dans P, la seconde dérive du
transport des dérivations vers l'extension de théorie.

L'interface commune à formaliser peut être présentée ainsi :

```text
GapMediatedEvaluation(State, Gap) :
  gap       : State → Gap
  Memory    : State → Gap → Prop
  Evaluated : State → Gap → Prop
  advance   : State → State

  memory_sound :
    Memory(S, d) → Evaluated(S, d)

  frontier_open :
    ¬Evaluated(S, gap(S))

  frontier_closed :
    Evaluated(advance(S), gap(S))

  evaluation_preserved :
    Evaluated(S, d) → Evaluated(advance(S), d)

  memory_exact :
    Memory(advance(S), d)
    ↔ d = gap(S) ∨ Memory(S, d).
```

Cette interface est la projection propositionnelle du mécanisme. Elle suffit
pour appliquer le Core causal, mais elle ne doit pas être l'objet primaire du
transport : un témoin de `Memory(S, d) : Prop` ne peut pas, en général, être
éliminé constructivement pour fabriquer une donnée dans `Type`.

### Réalisation positive par positions

L'objet primaire est le type des occurrences causales déjà inscrites. Chaque
position porte sa phrase et son certificat local d'évaluation :

```text
PositiveGapMediatedEvaluation(State, Gap) :
  gap       : State → Gap
  Position  : State → Type
  label     : Position(S) → Gap
  Evaluated : State → Gap → Prop
  advance   : State → State

  position_evaluated :
    Evaluated(S, label(p))

  advancePositions :
    ConstructiveEquivalence(
      Position(advance(S)),
      Option(Position(S)))

  newest_label :
    label(advancePositions⁻¹(none)) = gap(S)

  inherited_label :
    label(advancePositions⁻¹(some(p))) = label(p)

  frontier_open :
    ¬Evaluated(S, gap(S))

  evaluation_preserved :
    Evaluated(S, d) → Evaluated(advance(S), d).
```

`none` désigne la position nouvellement créée et `some(p)` la conservation
d'une position antérieure. `ConstructiveEquivalence` est une donnée positive
avec deux fonctions inverses ; elle n'utilise ni choix ni quotient.

La mémoire propositionnelle est ensuite définie en oubliant la position, mais
pas avant le transport :

```text
Memory⁺(S, d)
:⇔ il existe p : Position(S), label(p) = d.
```

Les lois constitutives ne sont plus des champs indépendants :

```text
frontier_closed
  dérive de la position none, de newest_label
  et de position_evaluated dans advance(S) ;

memory_exact
  dérive par analyse de advancePositions(p) : Option(Position(S)) ;

memory_sound
  dérive directement de position_evaluated ;

gap_absent
  dérive de memory_sound et frontier_open ;

gap_inscribed et memory_preserved
  dérivent respectivement des branches none et some.
```

Cette formulation rend exact le rôle du gap. Le gap courant n'évalue rien par
lui-même dans l'état source. `advance` le transforme en nouvelle occurrence
positive ; cette occurrence appartient alors au domaine causal certifié de
l'évaluateur successeur. La fermeture de l'ancien gap est donc construite à
partir de sa position nouvelle, tandis que l'ouverture de la frontière et la
préservation de toute l'évaluation restent des théorèmes propres au système.

Il ne faut pas définir une fonction de la forme :

```text
positionOfMemory : Memory⁺(S, d) → Position(S).
```

Elle demanderait précisément d'extraire une donnée de `Type` depuis une preuve
existentielle dans `Prop`. Le morphisme transportera directement les
`Position`; les prédicats `Memory_T` et `EventMemory_P` n'en seront que les
projections extensionnelles.

Les deux systèmes doivent fournir des réalisations fermées de cette interface
positive. Ils partagent sa forme causale, mais chacun construit
`position_evaluated`, `frontier_open` et `evaluation_preserved` avec son propre
évaluateur.

### Statut des lois de l'interface

Les cinq lois ne sont pas indépendantes au même sens et ne portent pas le même
contenu démonstratif.

Les lois constitutives expriment ce que la construction de `advance` est
destinée à produire :

```text
frontier_closed
memory_exact.
```

Elles doivent néanmoins être prouvées. La définition de l'état suivant ne
suffit pas à elle seule : il faut montrer que l'incorporation syntaxique du gap
est correctement reconnue par l'évaluateur local et que la représentation de
la mémoire possède exactement la forme annoncée.

La loi d'obstruction porte le contenu négatif qui rend le pas nécessaire :

```text
frontier_open.
```

Elle ne provient pas de l'ajout du gap. Dans T, elle dérive du mismatch
diagonal. Dans P, elle doit dériver de l'indépendance de Rosser et de la
cohérence de l'état courant.

Les lois de cohérence relient l'histoire causale à l'évaluateur local et
garantissent que l'avance ne détruit pas ce qui était déjà acquis :

```text
memory_sound
evaluation_preserved.
```

La force du système ne réside donc pas dans `frontier_closed` prise isolément,
mais dans la conjonction suivante :

```text
frontière réellement ouverte avant le pas
+ fermeture construite et certifiée par advance
+ mémoire exacte de l'événement
+ préservation des évaluations antérieures
+ nouvelle frontière fraîche après le pas.
```

Toute instance de `GapMediatedEvaluation` fournit ensuite les trois lois du
Core causal en oubliant le contenu particulier de `Evaluated` :

```text
gap_absent
  dérive de memory_sound et frontier_open ;

gap_inscribed
  dérive de memory_exact avec d = gap(S) ;

memory_preserved
  dérive de memory_exact par conservation de l'ancienne branche.
```

Le Core causal reçoit ainsi une structure commune parce que le gap a déjà
médiatisé, dans chaque réalisation, le passage de la syntaxe vers son
évaluation locale. L'oubli vers `(A)(I)(C)` supprime la nature de l'évaluateur,
mais conserve les conséquences causales de cette médiation.

Le rôle du gap peut alors être résumé sans mélange des couches :

```text
syntaxe de l'état
→ construction du gap
→ frontière actuelle de l'évaluation locale
→ advance causé par le gap
→ évaluation locale de l'ancien gap
→ inscription dans le domaine causal certifié
→ production d'une nouvelle frontière.
```

Le gap n'est pas lui-même un évaluateur et ne porte pas une valeur sémantique
universelle. Il est l'objet syntaxique qui rend possible l'extension contrôlée
de chaque évaluateur local.

## Prédicats de prouvabilité et phrases diagonales

Une fois le vérificateur numérique construit et représenté dans
l'arithmétique, chaque histoire finie `h` fournit une vraie formule unaire :

```text
provabilityPredicate(h) : Predicate
```

Le diagonal négatif de ce prédicat fournit la phrase gödelienne simple :

```text
godelSentence(h)
:= diagonal(provabilityPredicate(h)).
```

Cette phrase reste utile pour les théorèmes internes de diagonalisation et de
prouvabilité. Elle n'est pas le gap choisi pour la progression fermée fondée
sur la seule cohérence.

Pour construire une suite de théories dont la cohérence est conservée à chaque
pas, le gap est la phrase de Rosser :

```text
rosserBadPredicate(h) : Predicate

rosserSentence(h)
:= diagonal(rosserBadPredicate(h)).
```

La construction de Rosser fournit, à partir de la cohérence de l'histoire :

```text
¬TheoryProvable(h, rosserSentence(h))

¬TheoryProvable(h, négation de rosserSentence(h)).
```

La seconde non-prouvabilité permet de transformer toute contradiction dans
l'extension en une contradiction dans la théorie source. Elle fournit ainsi
la cohérence de l'état suivant sans ajouter une hypothèse de solidité, de
1-cohérence ou d'ω-cohérence.

## Système causal tarskien

L'état tarskien complet contient le candidat courant et la mémoire positive du
chemin qui l'a produit :

```text
State_T := CausalState

current_T : State_T → Predicate
Memory_T  : State_T → Sentence → Prop

Evaluated_T(S, d)
:⇔ CorrectAt(current_T(S), d).
```

Le gap et l'avance sont :

```text
gap_T(S)
:= diagonal(current_T(S))

advance_T(S)
:= état obtenu en remplaçant current_T(S) par
   patch(current_T(S), gap_T(S))
   et en étendant sa mémoire causale.
```

Le patch est purement syntaxique. Il insère la phrase sélectionnée dans une
formule locale sans décider si cette phrase est vraie. Son certificat prouve
ensuite :

```text
le nouveau candidat est correct à l'ancien gap ;
le comportement précédent est préservé hors de cet indice ;
l'ancien gap est mémorisé ;
le nouveau gap est absent de la nouvelle mémoire.
```

Le statut des lois est précis :

```text
frontier_open_T
  dérive du fixed point diagonal et du mismatch local ;

frontier_closed_T
  dérive de patch_agrees_at ;

memory_exact_T
  dérive de la forme inductive de l'extension de mémoire ;

memory_sound_T
  dérive par induction sur la mémoire de la réparation de chaque ancien gap
  et de sa préservation par les patches suivants ;

evaluation_preserved_T
  dérive du mismatch au gap courant et de
  patch_preserves_off_index.
```

`frontier_closed_T` est proche du design du patch, mais n'est pas une simple
égalité définitionnelle. Le patch contient syntaxiquement la phrase `d` dans
la branche sélectionnée au code de `d`. Il faut encore prouver, dans la
sémantique des formules, que cette branche est effectivement sélectionnée et
que son interprétation coïncide avec `models(d)`. Cette preuve certifie
l'incorporation du gap ; elle ne calcule pas si `d` est vraie ou fausse.

La mémoire tarskienne est sémantiquement certifiée, mais demeure une donnée
syntaxique et causale :

```text
Memory_T(S, d)
→ Evaluated_T(S, d).
```

Cette implication est prouvée localement dans T. Elle n'introduit aucune
relation avec la prouvabilité du système P.

Un simple `Predicate` ne suffit pas comme état causal : deux états ayant le
même comportement visible peuvent conserver des histoires différentes. La
mémoire fait partie de l'identité causale de l'état.

La réalisation positive nécessaire au transport est déjà présente dans le
code tarskien :

```text
Position_T(S)
:= CausalState.MemoryPosition(S)

label_T(p)
:= CausalMemory.sentenceAt(S.memory, p).
```

La définition de `CausalMemory.Position` suit exactement la forme attendue :

```text
Position_T(racine) = type vide

Position_T(advance_T(S))
= Option(Position_T(S)).
```

La position `none` porte le gap qui vient d'être réparé et `some(p)` conserve
l'ancienne position. Les théorèmes déjà compilés établissent :

```text
CausalMemory.position_remembered
  : toute position fournit un témoin de mémoire ;

CausalMemory.remembers_iff_position
  : Memory_T(S, d) équivaut, dans Prop, à l'existence d'une position étiquetée d ;

CausalMemory.sentenceAt_injective
  : deux positions de même étiquette sont égales ;

CausalMemory.positionEquivalence
  : les positions sont constructivement équivalentes au temps causal fini
    intrinsèque de la mémoire.
```

Le certificat `position_evaluated_T` s'obtient en composant
`position_remembered` avec `CausalMemory.correctAt_of_remembers`. La partie
positive de l'interface n'exige donc pas de reconstruire la mémoire
tarskienne ; il reste seulement à l'empaqueter sous l'interface commune.

## Système causal de théories

Une histoire est une suite finie, construite positivement, de phrases ajoutées
à PA :

```text
TheoryHistory.root
TheoryHistory.extend(previous, event)
```

Un état porte cette histoire et sa cohérence construite :

```text
CertifiedTheoryState :=
  histoire finie
  + certificat de cohérence de la théorie correspondante.
```

Le gap et l'avance sont :

```text
gap_P(S)
:= rosserSentence(S.history)

advance_P(S)
:= état dont l'histoire est
   S.history.extend(gap_P(S)),
   avec le certificat de cohérence produit par le théorème de Rosser
   et le théorème de déduction pour les extensions finies.
```

La transition ajoute une phrase sans exécuter une procédure qui chercherait à
décider sa prouvabilité. La certification du nouvel état utilise les théorèmes
d'indépendance déjà construits.

Deux observables restent séparés :

```text
EventMemory_P(S, d)
:⇔ d apparaît dans S.history

Theorems_P(S, φ)
:⇔ TheoryProvable(S.history, φ).

Evaluated_P(S, φ)
:⇔ Theorems_P(S, φ).
```

Le code arithmétique possède déjà une occurrence positive indexée par la
phrase :

```text
TheoryHistory.Contains : Sentence → TheoryHistory → Type.
```

`newest` désigne la dernière phrase ajoutée et `earlier` transporte une
occurrence antérieure. La mémoire propositionnelle actuelle est exactement
l'oubli de ce témoin :

```text
EventMemory_P(S, d)
:= Nonempty(S.history.Contains(d)).
```

La position non indexée à ajouter à l'interface commune peut donc être définie
sans choix :

```text
Position_P(S)
:= Σ d : Sentence, S.history.Contains(d)

label_P(p)
:= p.1.
```

L'extension possède une équivalence constructive explicite :

```text
Position_P(advance_P(S))
≃ Option(Position_P(S))

⟨gap_P(S), newest⟩  ↦ none
⟨d, earlier(old)⟩   ↦ some(⟨d, old⟩).
```

L'inverse envoie `none` sur la nouvelle occurrence et `some(p)` sur
`earlier(p)`. Les deux identités se prouvent par analyse des constructeurs de
`Contains`; aucune recherche et aucune élimination de `Nonempty` vers `Type`
ne sont nécessaires.

`position_evaluated_P` s'obtient en enveloppant l'occurrence dans `Nonempty`,
puis en appliquant `historyMember_provable`. L'équivalence entre
`EventMemory_P(S, d)` et l'existence, dans `Prop`, d'une position portant `d`
est également constructive.

Une précision est nécessaire : `TheoryHistory` autorise syntaxiquement deux
ajouts égaux, donc `label_P` n'est pas injective sur un état certifié arbitraire.
Le morphisme des occurrences n'a pas besoin de cette injectivité. Sur l'orbite
engendrée depuis `initialPAState`, `provabilityGap_not_mem` permet en revanche
de prouver par induction que chaque nouvelle étiquette est fraîche ; cette
propriété sera requise seulement si l'on veut ensuite oublier les occurrences
et obtenir une fonction sur les phrases historiques elles-mêmes.

La mémoire événementielle satisfait une extension exacte :

```text
EventMemory_P(advance_P(S), d)
↔ d = gap_P(S) ∨ EventMemory_P(S, d).
```

La collection des théorèmes satisfait seulement les lois appropriées :

```text
¬Theorems_P(S, gap_P(S))

Theorems_P(advance_P(S), gap_P(S))

Theorems_P(S, φ)
→ Theorems_P(advance_P(S), φ).
```

Les déclarations destinées à porter ces lois sont présentes dans
`ProvabilityProgression.lean` :

```text
frontier_open_P
  = provabilityGap_not_provable,
    dérivé de l'indépendance de Rosser pour l'histoire courante ;

frontier_closed_P
  = provabilityGap_provable_after_advance,
    construit par la règle du nouvel axiome ;

memory_exact_P
  = provabilityAdvance_memory_iff,
    dérivé par analyse de newest et earlier ;

memory_sound_P
  = historyMember_provable,
    qui convertit une occurrence en dérivation par la règle d'axiome ;

evaluation_preserved_P
  = provabilityTheorems_preserved,
    transformation explicite des anciennes dérivations.
```

Cette correspondance a été vérifiée dans le texte source, mais elle ne doit pas
encore être qualifiée de théorème fermé du dépôt courant : la chaîne d'imports
arithmétique ne compile pas intégralement à l'état vérifié plus bas.

La preuve de `frontier_closed_P` est directe une fois la phrase ajoutée : tout
axiome de l'histoire courante possède immédiatement une dérivation. Cela ne
rend pas `advance_P` trivial. Pour que son résultat soit encore un
`CertifiedTheoryState`, il faut construire la cohérence de la théorie étendue.
Cette construction consomme la seconde non-prouvabilité de Rosser et le
théorème de déduction pour les extensions finies.

Il faut donc distinguer :

```text
incorporer le gap comme nouvel axiome
→ fermeture locale immédiate du gap ;

certifier l'état suivant
→ preuve substantielle que cette incorporation préserve la cohérence.
```

L'histoire fournit donc elle aussi un domaine causal certifié :

```text
EventMemory_P(S, d)
→ Evaluated_P(S, d).
```

Cette implication est réalisée par une transformation explicite qui convertit
une occurrence dans l'histoire en dérivation par la règle d'axiome.

Il ne faut pas demander que l'ensemble des théorèmes gagne exactement une
phrase : l'ajout d'un axiome ajoute aussi toutes ses conséquences.

## Réparation locale et ouverture globale

Chaque pas traite effectivement son gap courant :

```text
dans le système T, l'ancien indice est réparé ;
dans le système P, l'ancienne phrase devient un axiome et donc un théorème.
```

Dans les deux cas, la clôture locale est construite. `advance` ne consulte pas
un évaluateur indépendant qui découvrirait après coup que le gap est résolu. Il
incorpore le gap à la structure qui définit l'évaluateur suivant, puis fournit
le certificat local correspondant. Le gap est ainsi la cause structurelle de
sa propre clôture dans l'état successeur, sans s'évaluer lui-même dans l'état
source.

Ce qui demeure ouvert n'est pas l'ancien gap, mais la progression entière. Le
successeur possède un nouveau gap, distinct de tous les événements déjà
mémorisés. Il n'existe donc aucun état terminal qui épuise l'histoire des gaps.

## Changement de référentiel

Les mêmes données admettent deux lectures qui ne modifient ni la syntaxe ni les
théorèmes locaux.

### Référentiel classique

Le référentiel classique considère d'abord l'obstruction produite à un état
donné :

```text
le candidat tarskien courant échoue sur sa phrase diagonale ;
la théorie certifiée courante ne prouve pas sa phrase de Rosser.
```

Dans cette lecture, chaque état est marqué par une limite actuelle. La
répétition de cette forme à tous les états exprime l'incomplétude globale de la
progression.

Le mot « classique » désigne ici ce mode de lecture centré sur l'obstruction.
Il ne désigne pas `LogicMode.classical` et n'introduit aucun raisonnement
classique dans Lean.

### Référentiel positif

Le référentiel positif conserve l'obstruction comme donnée causale au lieu de
la réduire à une conclusion négative. Le gap courant devient un événement
individué qui :

```text
cause le pas suivant ;
est inscrit dans la mémoire ;
reste identifiable dans toute l'histoire future ;
étend le domaine causal certifié d'évaluation ;
sépare causalement l'état source de ses successeurs ;
fait apparaître un nouveau gap après son traitement.
```

« Positif » signifie que le gap, le pas et la mémoire sont portés par des
données et des témoins internes. Cela ne signifie ni que la phrase du gap est
positive au sens logique, ni qu'une valeur de vérité lui est attribuée par le
morphisme.

Le changement de référentiel ne transforme donc pas une phrase fausse en une
phrase vraie et ne compare pas vérité et prouvabilité. Il transforme la lecture
du même phénomène : d'une obstruction constatée à une frontière syntaxique qui
permet d'étendre l'évaluation locale, reste conservée comme événement et
engendre une progression.

## Incomplétude globale constante et totalisation locale non constante

L'incomplétude globale est constante par sa forme, non par son contenu. À tout
état certifié, le système construit un gap courant absent de l'évaluation
locale pertinente :

```text
système T : le candidat courant n'est pas correct à son gap diagonal ;
système P : la théorie courante ne prouve pas sa phrase de Rosser.
```

Le mot « constante » signifie que cette forme d'obstruction est reproduite à
chaque état. Il ne signifie pas que la même phrase revient. Au contraire, la
fraîcheur causale impose que le nouveau gap soit distinct de tous les gaps déjà
mémorisés.

La totalisation locale désigne le traitement exact du gap courant :

```text
système T : advance_T répare l'ancien indice diagonal ;
système P : advance_P inscrit l'ancienne phrase de Rosser comme axiome,
            donc la rend prouvable dans la théorie suivante.
```

Cette totalisation est non constante parce qu'elle transforme l'état auquel
elle s'applique. Elle ne produit ni un prédicat final globalement correct, ni
une théorie complète, ni un point fixe terminal. Après chaque traitement :

```text
l'ancien gap appartient à la mémoire ;
l'ancien gap appartient au domaine causal certifié d'évaluation ;
l'état courant a changé ;
un nouveau gap frais est produit ;
la progression reste ouverte.
```

La rupture peut ainsi être formulée sans mesure numérique :

```text
incomplétude globale constante
= présence, à chaque état, d'une obstruction de même forme ;

totalisation locale non constante
= évaluation et inscription effectives de l'obstruction courante par une
  transformation qui engendre un nouvel état et une nouvelle obstruction.
```

Il n'y a donc aucune totalisation globale d'un manque unique. Il existe une
suite intrinsèque de clôtures locales, chacune conservée comme événement et
chacune suivie d'un gap nouveau.

## Morphisme causal visé

Le morphisme central porte sur les états causaux complets, leurs frontières
syntaxiques et leurs domaines causaux certifiés d'évaluation. Il ne compare ni
les valeurs produites par `models` et `TheoryProvable`, ni les relations
`Evaluated_T` et `Evaluated_P`.

La première composante transporte les états et commute avec l'avance :

```text
φ : State_T → CertifiedTheoryState

φ(advance_T(S))
= advance_P(φ(S)).
```

Comme `State_T` contient une mémoire inductive depuis sa racine, `φ` peut être
défini par récursion sur cette mémoire :

```text
φMemory(CausalMemory.root)
:= initialPAState

φMemory(CausalMemory.extend(previous, event))
:= advance_P(φMemory(previous))

φ(S)
:= φMemory(S.memory).
```

Le contenu syntaxique de `event` n'est pas envoyé sur une phrase identique :
il détermine la position causale du pas. Le gap de Rosser correspondant est
reconstruit localement depuis l'état P obtenu au pas précédent. Par réduction
sur le constructeur `extend`, cette définition vise une commutation
définitionnelle avec `advance`, plutôt qu'un pont ajouté après la récursion.

Cette récursion fournit la composante d'état, mais ne suffit pas à elle seule au
morphisme recherché. Il faut aussi transporter les événements qui constituent
les domaines certifiés. Chaque extension doit conserver la correspondance entre
le gap qui a causé le pas tarskien et le gap qui a causé le pas de théorie.

La construction complète utilise le chemin causal lui-même. Elle n'introduit
ni rang numérique, ni compteur temporel, ni recherche d'un indice extérieur.

La seconde composante primaire transporte les occurrences positives :

```text
positionMap_S :
  ConstructiveEquivalence(
    Position_T(S),
    Position_P(φ(S))).
```

Elle est construite par la même récursion que `φ`. À la racine, elle relie les
deux types vides. À chaque extension, elle applique le foncteur `Option` à
l'équivalence déjà obtenue. Elle doit donc satisfaire les égalités de
cohérence suivantes :

```text
positionMap_root(p)
:= élimination du type vide

positionMap_extend(none)
:= new_P

positionMap_extend(some(p))
:= old_P(positionMap_previous(p))

positionMap_advance(new_T(S))
= new_P(φ(S))

positionMap_advance(old_T(p))
= old_P(positionMap_S(p)).
```

Ici `new` est l'inverse de la branche `none` de `advancePositions` et `old`
celui de la branche `some`. Ces égalités empêchent une simple bijection
arbitraire entre deux mémoires de même taille : elles préservent l'origine
causale de chaque occurrence et sa conservation à travers les pas.

La correspondance des frontières devient alors une conséquence du transport
de la nouvelle position. Les deux gaps courants sont les étiquettes des
positions qui apparaissent dans les états successeurs :

```text
gap_T(S)
= label_T(new_T(S))

gap_P(φ(S))
= label_P(new_P(φ(S))).
```

Comme `φ` commute avec `advance` et que `positionMap_advance` envoie la nouvelle
position sur la nouvelle position, le morphisme apparie les deux événements
frontière sans identifier leurs phrases.

Pour toute position historique `p`, la paire de phrases transportée est :

```text
d_T := label_T(p)

d_P := label_P(positionMap_S(p)).
```

Elle fournit immédiatement les deux faits de mémoire correspondants. Le
transport inverse utilise `positionMap_S⁻¹`. On obtient donc le transport
bidirectionnel des domaines causaux certifiés sans choisir une position à
partir d'une preuve de `Memory_T` ou de `EventMemory_P`.

Les théorèmes locaux d'évaluation s'appliquent ensuite séparément :

```text
Memory_T(S, d_T)
→ Evaluated_T(S, d_T)

EventMemory_P(φ(S), d_P)
→ Evaluated_P(φ(S), d_P).
```

Il n'existe aucune flèche entre les deux conclusions `Evaluated`. Le morphisme
montre que la même architecture syntaxique de frontière et d'extension reçoit
deux réalisations sémantiques locales différentes :

```text
gap_T(S)  → advance_T(S)  → new_T / Position_T → Evaluated_T
   ↓              ↓                ↓
événement apparié φ             positionMap
   ↓              ↓                ↓
gap_P(φ(S)) → advance_P(φ(S)) → new_P / Position_P → Evaluated_P
```

Les flèches horizontales décrivent la médiation du gap vers l'évaluation
locale. Les flèches verticales transportent seulement la structure syntaxique
et causale. Aucune flèche verticale ne compare les sémantiques terminales.

Le morphisme doit donc préserver le cycle complet :

```text
frontière courante non évaluée localement ;
gap syntaxique causant l'avance ;
évaluation locale de l'ancien gap après l'avance ;
inscription exacte dans la mémoire ;
conservation du domaine déjà certifié ;
apparition d'une nouvelle frontière fraîche.
```

Cette préservation distingue le morphisme d'une simple synchronisation des
nombres de pas. Deux histoires de même longueur ne suffisent pas : leurs
occurrences doivent être appariées par une équivalence compatible avec `none`
et `some`, et chaque position transportée doit continuer à fournir son
certificat local d'évaluation.

Le morphisme conserve aussi le statut des lois :

```text
les deux frontier_open restent des obstructions prouvées localement ;
les deux frontier_closed restent des fermetures construites par advance ;
les deux memory_exact décrivent l'incorporation exacte d'un événement ;
les deux memory_sound relient séparément la mémoire à l'évaluation locale ;
les deux evaluation_preserved conservent les acquis de chaque évaluateur.
```

Il ne transforme pas une fermeture construite en découverte sémantique. Il
montre que deux mécanismes d'incorporation différents réalisent la même forme
de médiation : le gap syntaxique reconfigure l'évaluateur suivant, qui certifie
alors localement l'ancien gap.

### Transformation syntaxique globale secondaire

Le morphisme positif fournit déjà une transformation syntaxique dépendante de
l'état et de l'occurrence :

```text
χ_S(p : Position_T(S))
:= label_P(positionMap_S(p)).
```

Cette définition est constructive parce que `p` est une donnée de `Type`. Elle
apparie exactement les événements historiques. Pour la frontière courante, la
même construction est appliquée aux nouvelles positions dans les états
successeurs :

```text
χ_frontier,S(gap_T(S))
:= label_P(new_P(φ(S)))
 = gap_P(φ(S)).
```

Cette écriture ne prétend pas définir `χ_frontier,S` sur toutes les phrases :
son domaine est l'événement courant individué. Elle suffit au morphisme causal
parce que celui-ci transporte des occurrences et leurs étiquettes, pas une
fonction arbitraire sur toute la syntaxe.

Une fonction syntaxique globale

```text
χ : Sentence → Sentence
```

constitue une cible supplémentaire. Elle ne peut être déclarée qu'après la
construction d'une transformation explicite satisfaisant :

```text
gap_P(φ(S)) = χ(gap_T(S)).
```

Cette fonction renforcerait la correspondance relationnelle des gaps, mais
elle n'est pas le cœur du morphisme. Le résultat central existe dès que les
frontières, les positions, leurs étiquettes et leur rôle dans l'extension
locale de l'évaluation sont transportés sans identification sémantique.

Pour faire descendre `χ_S` des occurrences vers les phrases historiques, il
faut en plus une fidélité des étiquettes. Elle existe déjà dans T par
`sentenceAt_injective`. Dans P, elle doit être prouvée sur l'orbite engendrée à
partir de la fraîcheur de chaque gap de Rosser. Même après cette descente, la
transformation reste naturellement dépendante de l'état. Une fonction globale
sur toutes les `Sentence` demanderait encore une loi de cohérence entre les
états et une définition explicite hors du domaine historique ; ces données ne
sont pas nécessaires au résultat causal.

Le cas `χ = id` est un théorème éventuel, pas une donnée initiale. Il exigerait
de montrer que le patch d'un candidat tarskien et la reconstruction du prédicat
de prouvabilité après extension produisent des diagonales syntaxiquement
identiques. Or ces deux opérations ont des comportements différents : le patch
est local à un code, tandis qu'une extension de théorie peut créer de nombreux
nouveaux théorèmes. La correspondance des histoires n'implique donc pas
l'identité des phrases.

## Portée du morphisme

Le morphisme ne doit établir aucune proposition de la forme :

```text
models(gap_T(S))
↔ TheoryProvable(φ(S).history, gap_P(φ(S))).
```

Il transporte la factorisation causale de l'évaluation :

```text
la succession des états ;
l'individuation de la frontière syntaxique courante ;
l'ouverture locale portée par le gap courant ;
l'évaluation locale de l'ancien gap après advance ;
l'inscription exacte des événements ;
la conservation des domaines causaux certifiés ;
les implications locales mémoire → évaluation ;
les lois causales `(A)(I)(C)` ;
la structure additive induite par les chemins causaux.
```

Le transport des implications `mémoire → évaluation` signifie que chacune
reste valide dans sa propre réalisation. Il ne transforme jamais une preuve de
`Evaluated_T` en preuve de `Evaluated_P`, ni réciproquement. La sémantique
tarskienne et la prouvabilité restent des certificats locaux aux deux systèmes.

## État vérifié et ordre de construction restant

La chaîne arithmétique qui était auparavant décrite comme préalable est
maintenant présente dans les fichiers sources :

```text
P3  PRFunction.proofCheck ;
P4  proofFormula, provabilityPredicate, Prov_PA et leurs spécifications ;
P5  représentabilité et réfutation internes des fonctions primitives récursives ;
P6  diagonalisation interne ;
P7  paConsistent ;
P8  indépendance de Rosser et extendWithRosser_consistent ;
P9  CertifiedTheoryState, advance, Theorems et mémoire événementielle exacte ;
P10 paProvabilityAccumulatingSystem et les déclarations de son orbite causale.
```

La vérification distingue cependant deux statuts.

Les modules `Meta.Tarski.CausalClock` et
`Meta.Tarski.BareArithmetic.TheoryHistoryCoding` compilent et leurs audits ne
déclarent aucun axiome. Le premier contient déjà les positions positives
exactes de T. Le second confirme constructivement le support requis pour P :
`TheoryHistory`, `TheoryHistory.Contains` et l'extension positive des axiomes.

Le fichier `Meta.Tarski.BareArithmetic.ProvabilityProgression` contient bien
les cinq déclarations locales nécessaires côté P :
`historyMember_provable`, `provabilityGap_not_provable`,
`provabilityGap_provable_after_advance`, `provabilityTheorems_preserved` et
`provabilityAdvance_memory_iff`. Mais la commande de compilation de la chaîne
complète échoue actuellement dans des dépendances antérieures, notamment
`InternalTermNormalization.lean`, avec des erreurs de typage et de syntaxe. La
récupération sur ces erreurs fait apparaître `sorryAx` dans l'audit de ce
module. Tant que ces erreurs ne sont pas résolues, P3–P10 doivent être décrits
comme présents dans le source et architecturalement assemblés, non comme une
fermeture Lean constructive vérifiée.

Le travail restant pour le morphisme est désormais circonscrit :

```text
M1  définir l'interface PositiveGapMediatedEvaluation et sa projection
    vers GapMediatedEvaluation puis vers (A)(I)(C) ;

M2  empaqueter les positions tarskiennes déjà existantes ;

M3  définir Position_P := Σ d, TheoryHistory.Contains d,
    son étiquette et son équivalence d'extension par Option ;

M4  empaqueter la progression de Rosser dans l'interface positive ;

M5  définir φ par récursion sur CausalMemory et prouver
    φ(advance_T(S)) = advance_P(φ(S)) ;

M6  définir positionMap par la même récursion et prouver sa compatibilité
    avec les constructeurs new et old ;

M7  en déduire le transport des frontières, des mémoires propositionnelles
    et des certificats locaux d'évaluation ;

M8  optionnellement, prouver l'injectivité de label_P sur l'orbite engendrée
    et étudier la descente vers une transformation syntaxique globale χ.
```

Ainsi, `Evaluated_P` et le système causal P ont désormais des définitions
sources précises, mais leur fermeture constructive doit d'abord être rétablie
par une compilation complète sans `sorryAx`. Après cette fermeture, ce qui
restera à introduire comme déclarations Lean sera l'interface positive commune,
le paquet de positions P, `φ`, `positionMap` et leurs lois de cohérence. Cette
seconde difficulté est une construction intrinsèque par récursion sur les
histoires, sans rang numérique, sans choix et sans pont terminal externe.
