# Fondations mathématiques causales

## Statut du document

Ce document expose une orientation fondationnelle et précise ses obligations
formelles. Il distingue systématiquement :

```text
les structures déjà présentes dans le dépôt ;
les théorèmes dont la construction est planifiée ;
les conjectures fondationnelles générales.
```

Il ne présente pas encore une nouvelle définition achevée de toutes les
mathématiques. Il formule le noyau à partir duquel une telle définition
pourrait être construite et évaluée rigoureusement.

Sa fonction actuelle est celle d’une :

```text
charte de recherche fondationnelle.
```

Elle fixe :

```text
le noyau formel identifiable ;
les constructions encore absentes ;
les critères de réussite ;
les conditions d’échec du programme.
```

Le projet n’est donc pas présenté comme une fondation déjà acquise, mais comme
un candidat fondationnel dont le seuil de validation est explicitement défini.

## 1. Thèse directrice

La description classique d’un système mathématique privilégie souvent :

```text
les objets ;
les axiomes ;
les propositions ;
les valeurs ;
les relations de vérité ou de démontrabilité.
```

L’approche causale ajoute comme données fondamentales :

```text
la provenance ;
la transformation ;
la certification locale ;
la mémoire ;
la persistance ;
la production de nouvelles frontières.
```

La thèse générale visée est :

> Une mathématique peut être comprise comme une réalisation locale d’un
> schème causal dans lequel une frontière syntaxique ouverte provoque une
> transformation, reçoit une certification dans l’état successeur, est
> conservée comme événement historique et donne lieu à une nouvelle
> frontière.

Cette thèse générale n’est pas encore démontrée. La formulation actuellement
justifiée est plus restreinte :

> Une progression mathématique ouverte peut être modélisée comme une
> réalisation locale d’un schème de provenance causale.

Le passage de « certaines progressions mathématiques » à « toute
mathématique » constitue la conjecture fondationnelle principale.

## 2. Cycle causal fondamental

Le cycle commun est :

```text
état syntaxique
→ construction du gap
→ frontière locale ouverte
→ advance causé par le gap
→ incorporation du gap dans l’état successeur
→ certification locale de l’ancien gap
→ inscription dans la mémoire
→ conservation des événements antérieurs
→ production d’une nouvelle frontière.
```

Le gap n’est :

```text
ni une distance numérique ;
ni une valeur de vérité ;
ni un évaluateur ;
ni une comparaison entre deux sémantiques.
```

Il est l’objet syntaxique individué qui rend possible une transformation
contrôlée de l’évaluateur local.

La médiation centrale est :

```text
gap syntaxique
→ transformation de l’état
→ extension de l’évaluation locale.
```

Le gap n’évalue rien par lui-même dans l’état source. Il devient constitutif de
l’état successeur, dans lequel il reçoit une certification locale.

## 3. Structure positive d’une progression

Une réalisation positive comprend au minimum :

```text
State
Gap
gap       : State → Gap
advance   : State → State
Position  : State → Type
label     : Position(S) → Gap
Evaluated : State → Gap → Prop.
```

Les positions évoluent selon :

```text
Position(root)
≃ Empty

Position(advance(S))
≃ Option(Position(S)).
```

La branche :

```text
none
```

représente la nouvelle occurrence produite par le pas, tandis que :

```text
some(p)
```

représente la conservation d’une occurrence antérieure.

Les lois locales visées sont :

```text
position_evaluated :
  Evaluated(S, label(p))

frontier_open :
  ¬Evaluated(S, gap(S))

newest_label :
  label(new(S)) = gap(S)

evaluation_preserved :
  Evaluated(S, d) → Evaluated(advance(S), d).
```

La mémoire propositionnelle est une projection des positions :

```text
Memory(S, d)
:⇔ il existe p : Position(S), label(p) = d.
```

L’extension exacte devient :

```text
Memory(advance(S), d)
↔ d = gap(S) ∨ Memory(S, d).
```

Ainsi, la provenance est portée par une donnée positive avant d’être oubliée
dans un prédicat propositionnel.

## 4. Événement, preuve et certification

Il faut distinguer :

```text
événement causal ;
preuve ;
certification locale.
```

Dans une progression de théories :

```text
incorporation du gap dans l’histoire
→ événement causal ;

construction d’une dérivation
→ certification locale de cet événement ;

conservation de la dérivation sous extension
→ persistance de la certification.
```

La preuve n’est donc pas nécessairement l’événement lui-même. Elle est la
certification locale d’un événement syntaxiquement inscrit.

Cette distinction évite deux réductions :

```text
réduire la causalité à une relation de démontrabilité ;
réduire la démontrabilité à une simple présence historique.
```

## 5. Objectivité causale

La conservation :

```text
Evaluated(S, d)
→ Evaluated(advance(S), d)
```

constitue une dimension essentielle de l’objectivité, mais ne suffit pas à
elle seule. Une occurrence doit également recevoir une certification propre à
sa réalisation.

La formulation exacte est :

```text
objectivité causale
= certification locale
  + préservation sous advance.
```

La mémoire seule ne rend pas une phrase vraie ou démontrable. Elle désigne le
domaine causal dont la certification a été construite et conservée.

## 6. Temps de provenance

La construction ne suppose :

```text
ni compteur temporel externe ;
ni rang numérique ajouté ;
ni recherche d’un indice global ;
ni pont terminal extérieur.
```

Le temps apparaît d’abord comme un ordre intrinsèque de génération :

```text
root
step(root)
step(step(root))
...
```

Plus précisément, il est la généalogie des occurrences produites et
conservées. Le terme approprié est :

```text
temps de provenance.
```

Ce temps peut être isomorphe à une structure numérique discrète sans être
défini par elle. La structure causale est première dans la construction ; la
représentation numérique éventuelle est dérivée.

Le passage à un temps physique exigerait des structures supplémentaires :

```text
durée ;
mesure ;
concurrence ;
ordre partiel ;
localité ;
composition de processus indépendants.
```

## 7. Incomplétude et totalisation locale

La progression réalise simultanément :

```text
une incomplétude globale constante par sa forme ;
des totalisations locales non constantes par leur contenu.
```

À chaque état :

```text
un gap actuel reste ouvert ;
l’ancien gap est effectivement traité ;
sa certification est conservée ;
l’état est transformé ;
un nouveau gap frais apparaît.
```

Le progrès n’est donc pas défini par l’approche d’un état terminal. Il est :

```text
progrès
= clôture locale
  + certification
  + préservation
  + fraîcheur de la prochaine frontière.
```

Il n’existe pas une lacune unique qu’une complétion finale éliminerait. Il
existe une succession intrinsèque de clôtures locales conservées.

## 8. Le squelette universel de provenance

Le candidat universel `K` ne contient :

```text
ni Sentence ;
ni Predicate ;
ni gap syntaxique ;
ni vérité ;
ni prouvabilité ;
ni Evaluated.
```

Il contient seulement :

```text
KState :
  root
  step(previous)

KPosition(root)
  = Empty

KPosition(step(previous))
  ≃ Option(KPosition(previous)).
```

`K` porte la provenance avant toute décoration locale.

Les réalisations tarskienne et de prouvabilité doivent fournir :

```text
r_T : K → K_T⁺
r_P : K → K_P⁺.
```

Le diagramme fondamental est :

```text
          K
        /   \
     r_T     r_P
      /       \
     T         P
```

Sur les orbites engendrées, si les deux réalisations sont des équivalences, le
morphisme direct est dérivé :

```text
F = r_P ∘ r_T⁻¹.
```

Cette formule ne s’applique pas automatiquement aux états bruts inaccessibles
depuis les racines.

## 9. La provenance précède le contenu

Une occurrence universelle reçoit des décorations syntaxiques locales :

```text
k ↦ label_T(r_T(k))

k ↦ label_P(r_P(k)).
```

Les deux phrases ne sont pas identifiées. Elles sont deux représentations
locales d’une même position de provenance.

La proposition conceptuelle centrale est :

> La provenance de l’événement peut être plus fondamentale que le contenu par
> lequel une théorie locale le représente.

« Plus fondamentale » possède ici un sens structurel précis, et non encore un
sens métaphysique :

```text
la provenance est définie dans le squelette commun ;
le contenu apparaît comme décoration locale ;
l’évaluation apparaît dans une fibre locale supplémentaire.
```

L’initialité de `K`, lorsqu’elle sera démontrée, donnera un sens mathématique
plus fort à cette priorité.

## 10. Universalité constructive

La propriété universelle candidate est :

> Pour toute orbite positive pointée `R`, il existe un morphisme
> `realize_R : K → R` préservant `root`, `advance`, `new` et `old`, et tout
> autre morphisme satisfait les mêmes valeurs point par point.

L’unicité ne doit pas être encodée naïvement comme égalité de fonctions. Elle
est formulée relativement à une équivalence explicite entre morphismes :

```text
pour tout état k,
  f.stateMap(k) = g.stateMap(k) ;

pour toute position p,
  f.positionMap(p) = g.positionMap(p),
après les transports dépendants nécessaires.
```

Cette formulation évite :

```text
funext ;
les quotients ;
Quot.sound ;
le choix ;
les axiomes classiques.
```

`GapOrbit⁺` doit donc être construit d’abord comme une structure de morphismes
munie d’une équivalence pointwise explicite. Les lois d’identité, de
composition et d’universalité sont établies relativement à cette équivalence.

## 11. Séparation stricte des sémantiques

Le morphisme de provenance ne contient aucune flèche :

```text
Evaluated_T → Evaluated_P
```

ni :

```text
models → TheoryProvable.
```

Les systèmes partagent :

```text
la forme de la progression ;
la provenance des occurrences ;
la loi new / old ;
le cycle ouverture / transformation / fermeture.
```

Ils ne partagent pas nécessairement :

```text
leurs phrases ;
leurs valeurs ;
leurs preuves ;
leurs évaluateurs ;
leurs critères locaux de certification.
```

L’unification est causale et structurelle, non sémantique.

## 12. Invariance sous les présentations équivalentes

L’invariance n’est pas une propriété de robustesse secondaire. Elle est le
critère d’objectivité de la provenance.

La provenance ne peut devenir fondationnelle si elle dépend arbitrairement :

```text
du codage de Gödel ;
du choix du calcul de preuve ;
de la notation ;
de la granularité accidentelle des dérivations ;
de l’organisation d’une implémentation.
```

Il faut définir une notion admissible d’équivalence de présentations.

Une équivalence doit au minimum transporter :

```text
EState(root) = root

EState(advance(S))
= advance′(EState(S))

EPosition(new(S))
= new′(EState(S))

EPosition(old(p))
= old′(EPosition(p)).
```

Pour les décorations syntaxiques, l’égalité brute des phrases est généralement
trop forte. Il faut une traduction explicite :

```text
χS : Gap → Gap′

χS(gap(S))
≈ gap′(EState(S)).
```

Pour deux présentations équivalentes d’une même réalisation, l’évaluation doit
être naturelle sous cette traduction :

```text
Evaluated(S, d)
↔ Evaluated′(EState(S), χS(d)).
```

Cette équivalence interne à deux présentations d’un même système ne crée pas
de flèche sémantique entre deux réalisations distinctes telles que `T` et `P`.

### Choix du bon niveau événementiel

L’invariance ne peut pas être exigée aveuglément pour chaque règle
d’inférence. Deux calculs équivalents peuvent décomposer une preuve en des
nombres différents de pas.

L’événement invariant doit être choisi au niveau approprié :

```text
clôture d’un gap ;
inscription d’un événement frontière ;
transformation certifiée de l’état.
```

La théorie doit distinguer :

```text
les différences réelles de provenance ;
les différences artificielles de présentation ;
les raffinements ou regroupements admissibles d’événements.
```

Sans ce théorème d’invariance, le temps de provenance pourrait rester un
artefact syntaxique. Avec lui, il acquiert une forme d’objectivité comparable à
une invariance de jauge ou de coordonnées.

### 12.1 Normalisation événementielle

Deux présentations équivalentes peuvent posséder :

```text
des codages de Gödel différents ;
des calculs de preuve différents ;
plusieurs microétapes pour une transformation conceptuelle unique ;
des syntaxes brutes non isomorphes.
```

Il serait donc trop fort d’exiger une correspondance stricte entre tous les pas
primitifs.

La construction visée associe à toute présentation brute `P` une
normalisation :

```text
N(P)
= orbite des événements distingués de fermeture de gap.
```

Deux présentations sont admissiblement équivalentes lorsque :

```text
N(P) ≃ N(P′).
```

Les lois strictes de préservation de `root`, `advance`, `new` et `old` portent
sur ces orbites normalisées. Au niveau des calculs bruts, une transformation
événementielle peut correspondre à un chemin fini de microétapes :

```text
un pas dans N(P)
↔ un chemin fini cohérent dans P.
```

Cette normalisation doit être intrinsèque. Elle ne peut pas sélectionner les
événements pertinents à l’aide d’un rang ou d’une projection terminale
extérieure.

### 12.2 Quatre couches d’une équivalence admissible

Une équivalence complète de présentations possède au moins quatre composantes :

```text
E =
  EState
  + EPosition
  + χ
  + ηEval.
```

#### Provenance

```text
EState :
  State → State′

EPosition_S :
  Position(S) ≃ Position′(EState(S)).
```

Cette couche préserve :

```text
root ;
advance ;
new ;
old.
```

#### Décoration syntaxique

```text
χ_S :
  Gap_P(S) → Gap_P′(EState(S)).
```

Pour une position historique `p`, la naturalité des labels demande :

```text
χ_S(label_S(p))
≈ label′_(EState(S))(EPosition_S(p)).
```

La relation `≈` doit être définie explicitement. Elle peut être une égalité
après recodage, une équivalence syntaxique certifiée ou une relation de
traduction propre aux présentations considérées.

#### Évaluation locale

Pour deux présentations du même système :

```text
ηEval :
  Evaluated(S, d)
  ↔ Evaluated′(EState(S), χ_S(d)).
```

Cette composante est légitime parce qu’elle compare deux présentations
supposées représenter la même évaluation. Elle demeure interdite entre deux
réalisations différentes telles que `T` et `P`.

#### Cohérence supérieure

Les transports doivent :

```text
posséder des identités ;
se composer ;
respecter les traductions syntaxiques ;
respecter les certificats locaux ;
donner des résultats équivalents le long de chemins équivalents.
```

Les commutations peuvent n’être valides qu’à équivalence constructive cohérente
près. La structure finale pourrait donc être :

```text
une structure enrichie en équivalences pointwise ;
une bicatégorie constructive ;
ou une structure analogue sans quotient.
```

Le choix exact doit être déterminé par les preuves nécessaires, et non imposé
prématurément.

## 13. Mathématiques classiques comme projection

La structure causale peut être oubliée par étapes :

```text
positions positives
→ mémoire propositionnelle
→ lois causales (A)(I)(C)
→ relation extensionnelle d’évaluation.
```

Le diagramme fondationnel visé est :

```text
mathématique causale
→ oubli de la provenance, de la mémoire et de advance
→ mathématique extensionnelle classique.
```

Ce foncteur d’oubli général n’est pas encore défini. Pour que la nouvelle
fondation contienne réellement les mathématiques classiques, il faudra
construire :

```text
un plongement des théories ordinaires ;
une preuve de fidélité ou de conservation ;
une caractérisation de ce que l’oubli conserve ;
une caractérisation de ce que l’oubli détruit.
```

La mathématique classique apparaîtrait alors comme la projection statique
d’une structure causale plus riche, et non comme une théorie rejetée.

### 13.1 Théorème d’enrichissement strict

L’oubli doit perdre une information démontrablement non reconstructible.

Soit :

```text
U :
  CausalMath → ExtMath
```

le transport qui oublie :

```text
gap ;
advance ;
Position ;
Memory ;
la provenance des certifications.
```

Il faut construire un invariant causal `I` qui ne se factorise pas par `U` :

```text
il n’existe pas Ī tel que
I = Ī ∘ U.
```

Une formulation concrète consiste à construire deux systèmes `X` et `Y` tels
que :

```text
U(X) ≃ U(Y)
```

mais :

```text
X n’est pas causalement équivalent à Y.
```

Ils possèdent la même projection extensionnelle — par exemple les mêmes
propositions évaluées ou la même théorie finale — mais des provenances
causalement distinctes.

Ce théorème montrerait que la couche causale n’est pas une présentation
redondante de données classiques. Elle distinguerait des structures que
l’oubli extensionnel identifie.

### 13.2 Difficulté du plongement des objets statiques

Le plongement de toutes les mathématiques ordinaires n’est pas automatique. Le
cadre actuel exige :

```text
une progression ouverte ;
une frontière fraîche ;
une transformation effective ;
l’absence d’état terminal.
```

Un objet classique statique ne porte pas nécessairement ces données. Trois
thèses sont possibles :

```text
objet classique
= projection d’une progression causale ;

objet classique
= limite ou colimite d’une progression causale ;

objet classique
= réalisation causale dégénérée sans frontière nouvelle.
```

La première thèse est la plus radicale : les objets statiques deviennent les
ombres extensionnelles de processus. Elle exige alors de montrer que deux
processus représentant le même objet classique sont reliés par les
équivalences admissibles de présentations.

La troisième thèse facilite le plongement, mais affaiblit la portée de la loi
d’ouverture permanente. Le choix entre ces options constitue une décision
fondationnelle, pas un simple détail d’implémentation.

## 14. Mathématiques et physique

Le noyau causal ne contient aucune distinction préalable entre :

```text
système mathématique ;
système logique ;
système physique.
```

Cette distinction apparaît dans les décorations et les évaluateurs locaux.

Des réalisations différentes peuvent interpréter `Evaluated` comme :

```text
correction locale relativement à models ;
existence d’une dérivation ;
résultat expérimental stabilisé ;
contrainte satisfaite dans un état physique ;
trace persistante d’une interaction.
```

La thèse commune n’est pas que ces évaluations sont identiques. Elle est
qu’elles peuvent réaliser une même grammaire causale :

```text
frontière ouverte
→ transformation
→ certification locale
→ mémoire
→ nouvelle frontière.
```

Dans cette architecture, les mathématiques ne sont donc pas nécessairement un
langage extérieur appliqué à la physique. Les systèmes mathématiques et
physiques peuvent être étudiés comme des réalisations différentes d’un même
schème de provenance, sans réduction de leurs sémantiques.

## 15. Au-delà du cas linéaire

La loi :

```text
Position(advance(S))
≃ Option(Position(S))
```

décrit un processus ajoutant exactement une occurrence par pas.

Pour des réalisations concurrentes ou physiques, la généralisation naturelle
est :

```text
Position(advance(S))
≃ NewEvents(S) ⊎ Position(S).
```

`NewEvents(S)` peut porter :

```text
plusieurs événements simultanés ;
des dépendances partielles ;
des relations de localité ;
des branches incompatibles ;
des compositions indépendantes.
```

L’objet universel correspondant ne serait plus seulement une chaîne de
provenance, mais une structure événementielle causale.

Le cas linéaire reste le secteur initial dans lequel les définitions, les lois
de transport et les preuves constructives peuvent être établies sans masquer
les difficultés.

## 16. Conditions d’une nouvelle fondation

La proposition ne devient une nouvelle définition générale des mathématiques
qu’après satisfaction de trois conditions.

### 16.1 Plongement fidèle

Les mathématiques ordinaires doivent pouvoir être représentées sans perdre
leurs résultats essentiels :

```text
théories ;
preuves ;
modèles ;
interprétations ;
équivalences.
```

### 16.2 Fécondité propre

La couche causale doit permettre d’énoncer et de démontrer des résultats qui ne
sont pas de simples reformulations d’un compteur d’étapes :

```text
invariants de provenance ;
théorèmes de non-récurrence ;
rigidité des chemins ;
lois de mémoire ;
impossibilité d’un état terminal ;
relations entre clôture, fraîcheur et additivité.
```

Le critère formel de fécondité est le théorème d’enrichissement strict :

```text
deux systèmes identifiés par l’oubli extensionnel
restent distinguables par un invariant causal.
```

### 16.3 Invariance de présentation

Les structures causales pertinentes doivent être conservées sous les
recodages, traductions et présentations reconnus comme équivalents.

Sans cette troisième condition, la causalité mathématique pourrait n’être
qu’un effet de notation.

## 17. Programme formel

Le programme fondationnel peut être organisé ainsi :

```text
F1  définir les progressions mathématiques ouvertes ;

F2  définir le squelette positif de provenance ;

F3  construire GapOrbit⁺ et son équivalence pointwise ;

F4  construire K et démontrer son initialité constructive ;

F5  construire les réalisations r_T et r_P ;

F6  prouver leur équivalence avec les orbites engendrées ;

F7  dériver le morphisme causal direct sur ces orbites ;

F8  formaliser les décorations syntaxiques locales ;

F9  formaliser les fibres locales d’évaluation ;

F10 définir la normalisation événementielle N(P) des présentations brutes ;

F11 définir les équivalences admissibles à quatre composantes
    EState, EPosition, χ et ηEval ;

F12 démontrer l’invariance de la provenance normalisée ;

F13 démontrer la naturalité des décorations et des évaluations
    sous les recodages admissibles ;

F14 construire les identités, compositions et cohérences supérieures
    relativement à l’équivalence pointwise ;

F15 définir l’oubli U vers les structures extensionnelles ;

F16 choisir et construire le plongement des objets mathématiques statiques ;

F17 démontrer l’enrichissement strict par un invariant non factorisable
    à travers U, ou par deux systèmes extensionnellement identiques
    mais causalement non équivalents ;

F18 généraliser des événements linéaires vers les structures concurrentes.
```

Toutes ces constructions doivent rester :

```text
constructives ;
intrinsèques ;
sans choix ;
sans quotient ;
sans extensionalité fonctionnelle ;
sans rang numérique externe ;
sans pont terminal ajouté.
```

## 18. Trois théorèmes fondationnels majeurs

Le programme se concentre en trois théorèmes.

### 18.1 Universalité

```text
La provenance pure possède un objet libre K.
```

Il faut construire `K`, démontrer son initialité constructive pointwise et
construire ses réalisations dans les orbites considérées.

### 18.2 Invariance

```text
Le squelette événementiel normalisé est préservé
sous les changements de présentation admissibles.
```

Ce théorème transforme la provenance en structure objective plutôt qu’en
artefact de codage.

### 18.3 Enrichissement strict

```text
L’oubli extensionnel perd une information causale
qui ne peut pas être reconstruite depuis sa seule image.
```

Ce théorème sépare une nouvelle fondation d’une simple représentation
alternative des mêmes données.

Le seuil fondationnel exact est :

> La provenance devient fondamentale lorsqu’elle est définie
> intrinsèquement, invariantement transportée entre présentations et porte une
> information que la projection extensionnelle ne peut reconstruire.

## 19. Formulation fondationnelle finale

La formulation prudente actuellement défendable est :

> Une progression mathématique ouverte peut être modélisée comme une
> réalisation locale d’un schème de provenance causale, dans lequel une
> frontière syntaxique non évaluée provoque une transformation, reçoit une
> certification locale dans l’état successeur, est conservée comme occurrence
> historique et donne lieu à une nouvelle frontière.

La conjecture fondationnelle générale est :

> Les mathématiques peuvent être reconstruites comme des réalisations de
> structures de provenance, de transformation et de persistance certifiée,
> dont les présentations extensionnelles classiques sont des projections.

Le critère de réussite est :

```text
provenance intrinsèque
+ certification locale
+ préservation
+ invariance de présentation
+ plongement fidèle
+ enrichissement strict.
```

La provenance n’est véritablement fondamentale que lorsqu’elle est
transportable, indépendante des choix accidentels d’encodage et capable de
produire des théorèmes qui disparaissent lorsqu’on oublie la structure causale.

## 20. Falsifiabilité du programme

Les trois théorèmes majeurs déterminent trois modes d’échec indépendants.

### 20.1 Échec de l’universalité

Le programme échoue sous sa forme actuelle si :

```text
K ne possède pas l’initialité constructive attendue ;
les réalisations r_T et r_P ne se construisent pas ;
ou leur restriction aux orbites engendrées ne fournit pas
les équivalences annoncées.
```

Dans ce cas, le squelette proposé ne constitue pas la provenance universelle
des réalisations étudiées.

### 20.2 Échec de l’invariance

Le programme échoue comme fondation de la provenance si :

```text
les changements admissibles de codage détruisent le squelette événementiel ;
la normalisation N(P) dépend d’un choix externe ;
ou les événements distingués ne peuvent pas être sélectionnés intrinsèquement.
```

Dans ce cas, la provenance demeure un effet de présentation.

### 20.3 Échec de l’enrichissement strict

Le programme échoue comme enrichissement fondationnel si :

```text
tout invariant causal se reconstruit depuis U(X) ;
ou toute différence causale disparaît sous les équivalences admissibles.
```

Dans ce cas, la couche causale constitue une représentation redondante de
données extensionnelles.

Un programme fondationnel devient testable lorsqu’il énonce non seulement ce
qu’il espère démontrer, mais également les résultats qui invalideraient sa
prétention centrale.

## 21. Contrôles de non-trivialité

### 21.1 Test du simple compteur

Dans le secteur linéaire :

```text
KState ::= root | step(previous)
```

peut être isomorphe à une chaîne discrète. La seule construction de `K` ne
suffit donc pas.

Il faut montrer que les réalisations, les décorations et les invariants
transportent davantage que :

```text
le nombre d’étapes ;
l’âge d’une occurrence ;
l’ordre arbitraire d’une liste.
```

La causalité devient substantielle lorsqu’elle distingue des chemins ou des
histoires qui possèdent la même projection temporelle brute.

### 21.2 Test de l’équivalence admissible

Une équivalence trop stricte conserve :

```text
les accidents de codage ;
les microétapes ;
les choix d’implémentation.
```

Une équivalence trop permissive efface :

```text
les différences réelles de provenance ;
les dépendances causales ;
les invariants recherchés.
```

La normalisation `N(P)` doit donc être définie indépendamment de l’équivalence
que l’on souhaite ensuite obtenir. Il serait circulaire de choisir après coup
les événements distingués afin de forcer deux présentations à coïncider.

### 21.3 Test de l’annotation bureaucratique

Deux systèmes `X` et `Y` ne fournissent pas un enrichissement strict
substantiel si leur différence provient seulement d’annotations ajoutées sans
effet.

Une différence causale pertinente doit :

```text
survivre aux équivalences admissibles ;
être indépendante d’un codage particulier ;
modifier un invariant ou un théorème causal ;
ne pas se réduire à l’ordre choisi pour rédiger une preuve.
```

Le théorème d’enrichissement strict doit satisfaire ces quatre exigences.

## 22. Priorité du chantier formel

La construction de `K` et des réalisations linéaires constitue le socle
initial. Le seuil fondationnel se situe cependant principalement dans :

```text
F10  normalisation événementielle ;
F11  équivalences admissibles à quatre composantes ;
F12  invariance de la provenance ;
F13  naturalité des décorations et des évaluations ;
F14  cohérences supérieures ;
F15  oubli extensionnel ;
F16  plongement des objets statiques ;
F17  enrichissement strict.
```

Ces étapes déterminent si la provenance est :

```text
une structure mathématique objective
```

ou seulement :

```text
une histoire particulière choisie pour présenter des données extensionnelles.
```

L’élargissement philosophique et le passage aux processus concurrents ne
doivent pas masquer cette priorité démonstrative.

## 23. Verdict de programme

Le statut exact du projet est :

> Un candidat fondationnel constructif dont le noyau causal est spécifié, dont
> les généralisations sont identifiées et dont les critères de validation et
> de réfutation sont explicitement formulés.

La provenance n’est pas déclarée fondamentale parce qu’elle apparaît dans un
encodage. Elle doit devenir :

```text
intrinsèque ;
invariante sous les présentations admissibles ;
localement certifiée ;
préservée ;
et irréductible à la projection extensionnelle.
```

C’est le seuil entre :

```text
une nouvelle représentation des mathématiques
```

et :

```text
une nouvelle fondation des mathématiques.
```
