# Écart syntaxique et morphisme causal

## Principe

L'écart n'est ni une distance numérique ni une comparaison de deux valeurs de
vérité. Il est une phrase arithmétique distinguée, construite syntaxiquement à
partir de l'état courant.

À chaque état, la fonction `gap` désigne un gap courant. Cette individuation ne
signifie pas que le système ne possède aucun autre désaccord ou aucune autre
phrase indépendante. Elle signifie qu'un événement syntaxique canonique est
choisi pour causer le pas suivant.

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
nouvel événement est ajouté par pas.

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

Un simple `Predicate` ne suffit pas comme état causal : deux états ayant le
même comportement visible peuvent conserver des histoires différentes. La
mémoire fait partie de l'identité causale de l'état.

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
```

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

Il ne faut pas demander que l'ensemble des théorèmes gagne exactement une
phrase : l'ajout d'un axiome ajoute aussi toutes ses conséquences.

## Réparation locale et ouverture globale

Chaque pas traite effectivement son gap courant :

```text
dans le système T, l'ancien indice est réparé ;
dans le système P, l'ancienne phrase devient un axiome et donc un théorème.
```

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
sépare causalement l'état source de ses successeurs ;
fait apparaître un nouveau gap après son traitement.
```

« Positif » signifie que le gap, le pas et la mémoire sont portés par des
données et des témoins internes. Cela ne signifie ni que la phrase du gap est
positive au sens logique, ni qu'une valeur de vérité lui est attribuée par le
morphisme.

Le changement de référentiel ne transforme donc pas une phrase fausse en une
phrase vraie et ne compare pas vérité et prouvabilité. Il transforme la lecture
du même phénomène : d'une obstruction constatée à un événement conservé qui
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
l'état courant a changé ;
un nouveau gap frais est produit ;
la progression reste ouverte.
```

La rupture peut ainsi être formulée sans mesure numérique :

```text
incomplétude globale constante
= présence, à chaque état, d'une obstruction de même forme ;

totalisation locale non constante
= inscription effective de l'obstruction courante par une transformation
  qui engendre un nouvel état et une nouvelle obstruction.
```

Il n'y a donc aucune totalisation globale d'un manque unique. Il existe une
suite intrinsèque de clôtures locales, chacune conservée comme événement et
chacune suivie d'un gap nouveau.

## Morphisme causal visé

Le premier morphisme à construire porte sur les états causaux complets et sur
leurs histoires, sans comparer `models` et `TheoryProvable` :

```text
φ : State_T → CertifiedTheoryState

φ(advance_T(S))
= advance_P(φ(S)).
```

Comme `State_T` contient une mémoire inductive depuis sa racine, `φ` peut être
défini par récursion sur cette mémoire :

```text
la racine tarskienne est envoyée sur initialPAState ;
chaque extension tarskienne provoque une extension du système P.
```

Cette construction utilise le chemin causal lui-même. Elle n'introduit ni rang
numérique, ni compteur temporel, ni recherche d'un indice extérieur.

La correspondance minimale entre gaps est d'abord une relation portée par les
états appariés :

```text
CurrentGapCorrespondence(S)
: gap_T(S) correspond à gap_P(φ(S)).
```

Elle doit se prolonger aux mémoires : chaque événement tarskien mémorisé doit
être accompagné de l'événement du système P produit au même pas causal, et
réciproquement.

Une fonction syntaxique globale

```text
χ : Sentence → Sentence
```

constitue une cible supplémentaire. Elle ne peut être déclarée qu'après la
construction d'une transformation explicite satisfaisant :

```text
gap_P(φ(S)) = χ(gap_T(S)).
```

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

Il transporte seulement :

```text
la succession des états ;
l'individuation du gap courant ;
l'inscription exacte des événements ;
la conservation des mémoires ;
les lois causales `(A)(I)(C)` ;
la structure additive induite par les chemins causaux.
```

La sémantique tarskienne et la prouvabilité restent des certificats locaux aux
deux réalisations.

## Ordre de construction

Le morphisme vient après la fermeture du système de prouvabilité :

```text
P3  vérificateur numérique primitif récursif ;
P4  formule uniforme Prov_h et spécification ;
P5  représentabilité interne ;
P6  diagonalisation interne ;
P7  cohérence fermée de PA ;
P8  indépendance de Rosser et conservation de la cohérence ;
P9  progression certifiée et mémoires exactes ;
P10 instance causale additive fermée ;
puis morphisme des histoires causales ;
puis, si elle existe, transformation syntaxique globale χ.
```

Avant ces constructions, `φ`, `CurrentGapCorrespondence` et `χ` restent des
cibles formelles précisément spécifiées, et non des propriétés acquises.
