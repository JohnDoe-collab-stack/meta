# Caractérisation constructive de la réparabilité adaptative

## Statut du document

Ce document spécifie le prochain résultat général visé par le programme de
réparation certifiée des représentations latentes.

Il distingue strictement :

- les résultats déjà démontrés dans l’artefact ;
- les définitions nouvelles à formaliser ;
- les hypothèses locales admises sur une classe d’environnements ;
- les stratégies, épisodes et preuves qui devront être construits ;
- les contre-modèles qui interdisent toute formulation plus forte.

Les théorèmes nouveaux décrits ici sont des **objectifs formels**. Ils ne doivent
pas être cités comme résultats obtenus tant que les modules Lean, les instances,
les tests négatifs et l’audit d’axiomes ne sont pas achevés.

Cette version remplace explicitement la formule insuffisante

```text
réparabilité
↔
séparabilité de chaque paire au seul état initial.
```

La caractérisation exacte portera sur l’existence d’une stratégie publique
globale gagnante. La séparabilité paire par paire interviendra dans un théorème
de synthèse séparé, sous une loi explicite de composabilité séquentielle.

## 1. Point de départ démontré

### 1.1 Résultats génériques

L’artefact établit constructivement :

- un no-go pour une règle recevant le même code visible dans deux situations
  exigeant des continuations incompatibles ;
- un no-go pour une politique passive appliquée à deux états ayant la même vue
  d’agent ;
- l’obstruction sémantique produite par deux mondes compatibles dont les cibles
  diffèrent ;
- le pont générique suivant, local à l’index porté par le gap :

```text
GapClosedBy(system,before,gap,after)
→
RestoredLocalSufficiency(system,after,gap.index).
```

`RestoredLocalSufficiency` contient la compatibilité du monde réel, la correction
connue sur la fibre, la détermination de la cible sur cette fibre et la
correction dans le monde réel.

Ce pont ne synthétise pas la prémisse `GapClosedBy`. Il ne fournit pas encore une
politique générale pour une classe d’environnements.

### 1.2 Réalisations exactes

Le système fini certifie trois réparations complètes. Il atteint ensuite une
clôture connue et réelle, un détecteur fermé et un état stable.

Le système ouvert certifie, pour tout `n : Nat` :

- un gap courant typé ;
- une requête sélectionnée informative ;
- une réparation intrinsèque ;
- une réduction stricte de la fibre courante ;
- la fermeture locale du gap ;
- la conservation du préfixe réparé ;
- une transition effective ;
- l’absence de clôture globale à tout stade fini.

### 1.3 Validation d’implémentation

Le modèle quantifié recalcule en Lean 697 obligations réifiées. L’artefact prouve
l’erreur nulle et les marges strictes sur ce catalogue fini. Cela ne constitue
ni une généralisation statistique ni une robustesse sur un voisinage continu.

### 1.4 Portée acquise

Les résultats existants établissent :

```text
cohérence constructive
+ habitabilité
+ non-vacuité
+ exécution finie exacte
+ réalisations fermée et ouverte.
```

Ils ne constituent pas encore la caractérisation générale définie ci-dessous.

## 2. Correction logique indispensable

### 2.1 La séparabilité paire par paire n’est pas suffisante en général

Considérons trois mondes compatibles `a`, `b`, `c` exigeant trois actions
distinctes. Supposons disponibles des requêtes ponctuelles telles que :

```text
q₁ : a ↦ 0, b ↦ 1, c ↦ 0
q₂ : a ↦ 0, b ↦ 0, c ↦ 1.
```

Chaque paire conflictuelle est distinguée par au moins une requête :

```text
(a,b) par q₁
(a,c) par q₂
(b,c) par q₂.
```

Supposons cependant que toute première requête consomme l’autorisation de poser
une requête ultérieure. Après `q₁`, la branche de réponse `0` conserve `a` et
`c`. Après `q₂`, la branche de réponse `0` conserve `a` et `b`. Une ambiguïté
d’action subsiste donc dans au moins une branche, quelle que soit la première
requête.

Ainsi :

```text
toute paire est séparable depuis s
mais
aucune stratégie unique ne résout toutes les branches depuis s.
```

La condition paire par paire devient suffisante uniquement si les expériences
séparatrices peuvent être séquentiellement composées, ou si leur disponibilité
est préservée sur les états postérieurs admissibles.

### 2.2 La fermeture informationnelle n’est pas la fermeture décisionnelle

Même une fibre singleton peut rester irréparable si le langage des candidats ne
peut pas représenter l’action requise.

Il faut donc distinguer :

```text
réalisation de l’information postérieure
≠
réalisation d’un candidat correct sur une fibre homogène.
```

### 2.3 Une politique privée invaliderait le no-go

Si un constructeur de réparation reçoit le monde réel, il peut choisir la bonne
continuation sans utiliser la transcription publique. Exiger seulement que le
gap n’expose pas le monde privé ne suffit pas.

Les requêtes, réparations, décisions d’arrêt et états publics suivants doivent
être des fonctions de données publiques. Le monde réel ne doit intervenir que
dans la sémantique d’exécution et les preuves de correction.

### 2.4 La restriction de fibre ne suffit pas à la non-régression

Une fibre plus petite préserve une proposition universelle seulement lorsque les
objets lus par cette proposition sont conservés. Une réparation peut modifier le
candidat ou la mémoire et détruire un certificat antérieur malgré l’inclusion
des fibres.

Une doctrine de frame structurelle est donc nécessaire.

## 3. Architecture des résultats visés

La formalisation doit produire quatre résultats distincts.

### Théorème A — no-go adaptatif

```text
conflit d’action
+ indiscernabilité par toute stratégie publique autorisée
→
absence de stratégie certifiée garantissant la correction.
```

### Théorème B — caractérisation opérationnelle globale

```text
CertifiedRepairableAt(s,g)
↔
existence d’une stratégie publique globale gagnante depuis (s,g),
```

sous les interfaces explicites de réalisation du posterior, de réalisation de la
décision, de provenance et de frame.

Le membre droit porte un arbre unique correct sur toutes ses branches
réalisables. Il ne se réduit pas à une famille de séparateurs choisis
indépendamment pour chaque paire.

### Théorème C — synthèse par séparateurs locaux

```text
séparateurs positifs de paires
+ composabilité séquentielle
+ réparation fidèle aux transcriptions
+ réalisation des décisions homogènes
+ non-régression
→
construction d’une stratégie publique globale gagnante.
```

La preuve utilise une mesure interne du nombre de conflits d’action.

### Théorème D — corollaire à posterior exact

La représentation exacte de chaque posterior implique les lois de fidélité
informationnelle utilisées par le théorème C. Elle fournit une première instance
générale plus simple à formaliser.

## 4. Séparation stricte entre état public et monde réel

### 4.1 Données publiques

La première classe d’environnements doit exposer :

```text
World                 type des mondes sémantiques
PublicState           type des états accessibles
Obligation            type des gaps décisionnels locaux
Action                type des continuations requises
Candidate             type des candidats réparables
CertificateKey        type des clôtures antérieures

Query(s,g)            requêtes disponibles depuis l’état public s
Response(q)           réponses dépendant de la requête q

Fiber(s,w)            compatibilité publique de w avec s
Required(g,w)         continuation requise dans w pour g
respond(w,q)          réponse déterministe du monde w
authorized(s,g,q)     preuve publique d’autorisation
candidate(s)          candidat actuellement porté par s
interpret(c,g)        action portée par le candidat c pour g.
```

`Required(g,w)` est stable pendant l’épisode relatif à `g`. Une version future
pourra utiliser `Required(s,g,w)`, mais elle devra alors transporter une preuve
explicite d’invariance le long des transitions préparatoires.

### 4.2 État sémantique d’exécution

L’exécution associe un monde fixe à un état public :

```text
RunState := World × PublicState.
```

Le monde détermine seulement les réponses environnementales :

```text
r := respond(world,q).
```

La stratégie ne reçoit jamais `world`. Elle reçoit `s`, `g`, puis les réponses
publiquement observées.

### 4.3 Non-interférence publique

Les constructeurs opérationnels doivent avoir des signatures ne contenant aucun
argument de type `World` :

```text
chooseQuery :
  (s : PublicState) → (g : Obligation)
  → Σ q : Query(s,g), authorized(s,g,q)

compileResponse :
  (s : PublicState) → (g : Obligation)
  → (q : Query(s,g))
  → authorized(s,g,q)
  → (r : Response(q))
  → r ∈ realizableResponses(s,q)
  → PublicRepairStep(s,g,q,r)

chooseStop :
  (s : PublicState) → (g : Obligation) → Bool

realizeDecision :
  (s : PublicState) → (g : Obligation)
  → PublicFiberNonempty(s)
  → ActionSufficientAt(s,g)
  → CertifiedLocalClosure(s,g)
```

Deux exécutions partant du même état public et produisant la même transcription
doivent donc produire :

- les mêmes requêtes ;
- les mêmes mises à jour publiques ;
- le même candidat public ;
- le même historique ;
- la même décision d’arrêt.

Cette propriété doit découler des types et des définitions, non d’une promesse
informelle sur l’implémentation.

## 5. Finitude constructive de la première classe

La première caractérisation vise une classe finie à réponses déterministes.

Elle fournit explicitement :

```text
allWorlds : List World
allWorlds_nodup : allWorlds.Nodup
allWorlds_complete : ∀ w, w ∈ allWorlds
```

ainsi que des procédures de décision pour :

- l’égalité des mondes ;
- l’égalité des actions ;
- l’égalité des réponses pour chaque requête ;
- `Fiber(s,w)` ;
- l’appartenance aux clés de certificats protégées.

La fibre publique est obtenue par filtrage de `allWorlds`. Les réponses
réalisables d’une requête sont obtenues en évaluant cette fibre, puis en retirant
constructivement les doublons.

La finitude est une donnée intrinsèque de la classe. Aucun `rank`, aucune
`windowFor`, aucune liste externe de réductions réelles et aucun oracle terminal
ne sont admissibles.

Dans les énoncés suivants, `FinitePublicEnvironment` désigne la structure
regroupant exactement ces types, fonctions, énumérations complètes, procédures de
décision et lois publiques déterministes.

## 6. Conflits, suffisance et réalisation de la décision

### 6.1 Conflit d’action

```text
ActionConflict(s,g,w₁,w₂) :=
  Fiber(s,w₁)
  ∧ Fiber(s,w₂)
  ∧ Required(g,w₁) ≠ Required(g,w₂).
```

### 6.2 Suffisance informationnelle locale

```text
ActionSufficientAt(s,g) :=
  ∀ w₁ w₂,
    Fiber(s,w₁)
    → Fiber(s,w₂)
    → Required(g,w₁) = Required(g,w₂).
```

Cette propriété affirme l’homogénéité de la fibre. Elle ne contient pas encore
un candidat correct.

### 6.3 Non-vacuité publique

Définir d’abord une liste calculée uniquement depuis l’état public :

```text
fiberWorlds(s) := allWorlds.filter (fun w => Fiber(s,w))

PublicFiberNonempty(s) : Prop :=
  fiberWorlds(s) ≠ [].
```

Prouver ensuite constructivement :

```text
PublicFiberNonempty(s)
↔ ∃ w, Fiber(s,w).
```

Dans une exécution réelle, cette proposition est dérivée de la conservation du
monde réel. Le représentant utilisé pour construire la décision est toujours la
tête canonique de `fiberWorlds(s)`. Il est calculé depuis `s` et `allWorlds`, pas
extrait d’un témoin sémantique fourni par l’exécution.

### 6.4 Réalisation décisionnelle

Une interface distincte doit construire la fermeture du gap à partir d’une
fibre publique non vide et homogène :

```text
realizeHomogeneousDecision :
  (s : PublicState)
  → (g : Obligation)
  → PublicFiberNonempty(s)
  → ActionSufficientAt(s,g)
  → CertifiedLocalClosure(s,g).
```

`CertifiedLocalClosure(s,g)` contient au minimum :

- un état public terminal `after` ;
- une action choisie publiquement ;
- un patch public et le candidat réparé porté par `after` ;
- l’égalité des fibres avant et après cette fermeture décisionnelle ;
- la correction du candidat terminal pour tout monde de `Fiber(after)` ;
- la provenance de sa construction ;
- la conservation des certificats antérieurs ;
- l’ajout du certificat de l’obligation courante ;
- la conservativité de l’identité stricte et la cohérence des transports ;
- le pont vers `GapClosedBy(before,after)` dans les instances du cadre existant.

Forme minimale :

```text
structure CertifiedLocalClosure(before,g) where
  after : PublicState
  chosenAction : Action
  repairedCandidate : Candidate
  afterCarriesCandidate : candidate(after) = repairedCandidate
  fiberPreserved : ∀ w, Fiber(after,w) ↔ Fiber(before,w)
  knownCorrect :
    ∀ w, Fiber(after,w)
      → interpret(repairedCandidate,g) = Required(g,w)
  publicDerivation :
    DecisionDerivedFromPublicFiber(before,g,after,repairedCandidate)
  provenanceComplete : DecisionClosureProvenance(before,g,after)
  framePreserved : DecisionFramePreserved(before,g,after)
  currentCertificateAdded : CurrentCertificateAdded(before,g,after)
  strictIdentityConservative : StrictIdentityConservative(before,after)
  transportCoherent : TransportCoherent(before,after)
  consistentUpdate : ConsistentUpdate(before,after)
```

`DecisionDerivedFromPublicFiber` est défini par l’exécution du compilateur sur la
tête canonique de `fiberWorlds(before)`. Sa définition et le constructeur de
`CertifiedLocalClosure` ne possèdent aucun argument de type `World` représentant
le monde réel.

La correction dans le monde réel est ensuite dérivée de sa compatibilité.

Cette interface exprime l’adéquation du langage des candidats. Elle ne doit pas
être confondue avec la capacité de représenter une observation postérieure.

`DecisionRealizationComplete` abrège l’existence constructive de
`realizeHomogeneousDecision` pour tout état public `s` et toute obligation `g`
satisfaisant seulement `PublicFiberNonempty(s)` et
`ActionSufficientAt(s,g)`. Cette portée totale correspond exactement à la
direction droite-gauche du théorème B ; elle ne suppose pas
`RepairDomainInvariant` sur les feuilles d’un arbre arbitraire.

## 7. Étape publique de réparation

Pour un état public `s`, une obligation `g`, une requête autorisée `q` et une
réponse réalisable `r`, une étape expose :

```text
PublicRepairStep(s,g,q,r)
```

avec les données publiques suivantes :

- l’état public `after` ;
- le patch du candidat ;
- la mise à jour de l’observation ;
- l’entrée de mémoire ;
- les usages et transports autorisés ;
- la provenance reliant gap, requête, réponse et mises à jour.

Le constructeur de l’étape reçoit seulement `(s,g,q,r)` et les preuves publiques
d’autorisation. Il ne reçoit pas de monde réel.

### 7.1 Lois sémantiques locales

Chaque étape doit prouver :

```text
posteriorSound :
  Fiber(after,w) → Fiber(s,w)

observedWorldRetained :
  Fiber(s,w) → respond(w,q) = r → Fiber(after,w)

responseDerived :
  patch, observation, mémoire et provenance dérivent de r

requiredStable :
  la signification de Required(g,·) est conservée

framePreserved :
  les anciennes clés restent inscrites et leurs lectures protégées
  restent égales ou sont transportées explicitement

strictIdentityConservative :
  aucune identité stricte nouvelle n’est fabriquée

transportCoherent :
  les transports produits respectent leurs lois de composition

consistentUpdate :
  la réparation ne produit aucune contradiction interdite.
```

`observedWorldRetained` est quantifié sur tout monde compatible donnant la
réponse, pas seulement sur un monde choisi pendant la preuve.

Les interfaces globales utilisées dans les théorèmes abrègent les lois locales :

```text
LogicalConservativity :=
  tous les PublicRepairStep et CertifiedLocalClosure satisfont
  strictIdentityConservative et consistentUpdate

TransportCoherence :=
  tous leurs transports satisfont les lois d’identité et de composition.

LawfulFiberRepair :=
  tous les PublicRepairStep sont publics et satisfont
  posteriorSound et observedWorldRetained.
```

Ces interfaces sont des doctrines de sécurité. Elles ne contiennent ni
séparateur, ni stratégie gagnante, ni preuve de terminaison.

### 7.2 Étapes préparatoires

Une étape n’est pas obligée de réduire immédiatement le nombre de conflits. Elle
peut uniquement rendre une requête ultérieure autorisée. La diminution stricte
sera exigée à la fin d’un épisode séparateur fini.

## 8. Stratégies publiques finies

### 8.1 Arbre de stratégie

Une stratégie est un arbre dépendant des réponses réalisables :

```text
PublicRepairTree(s,g) ::=
  stop
  | ask q authorization
      (step : ∀ r ∈ realizableResponses(s,q),
        PublicRepairStep(s,g,q,r))
      (next : ∀ r membership,
        PublicRepairTree((step r membership).after,g)).
```

Les ensembles de mondes et de réponses réalisables étant explicitement finis,
l’arbre pertinent est finiment branchant. Sa construction Lean doit fournir une
taille ou une preuve de bonne fondation calculable.

Les branches impossibles ne font pas partie des obligations sémantiques. Pour
tout monde compatible, `respond(world,q)` appartient constructivement à la liste
des réponses réalisables.

Les feuilles sont des adresses finies dans l’arbre, et non de simples états :

```text
Leaf : PublicRepairTree(s,g) → Type
leafState : (tree : PublicRepairTree(s,g)) → Leaf(tree) → PublicState
leafTranscript : (tree : PublicRepairTree(s,g)) → Leaf(tree) → Transcript

IsRealizableLeaf(s,tree,leaf) : Prop :=
  ∃ w,
    ∃ compatible : Fiber(s,w),
      terminalLeaf(tree,w,compatible) = leaf.
```

`Leaf(tree)` doit posséder une énumération finie sans doublon et une égalité
décidable. `IsRealizableLeaf` est décidable par évaluation de tous les mondes de
`fiberWorlds(s)`. Son témoin reste dans `Prop`.

La composition des arbres utilise une opération publique de greffe :

```text
bindLeaves :
  (tree : PublicRepairTree(s,g))
  → ((leaf : Leaf(tree))
      → PublicRepairTree(leafState(tree,leaf),g))
  → PublicRepairTree(s,g).
```

Le constructeur de synthèse possède une continuation récursive seulement pour
les feuilles réalisables. Il la totalise avant d’appeler `bindLeaves` :

```text
extendRealizableLeaves(tree,nextRealizable)(leaf) :=
  if h : IsRealizableLeaf(s,tree,leaf)
  then nextRealizable(leaf,h)
  else stop.
```

Ses lois relient les transcriptions concaténées, les états terminaux et la
composition des preuves de frame et de conservation.

La première caractérisation porte sur des stratégies déterministes. Une graine
aléatoire publique fixée peut être ajoutée comme paramètre initial de l’arbre ;
les garanties probabilistes ou presque sûres constituent une extension séparée.

### 8.2 Exécution

Définir un type commun de transcription publique, par exemple une liste
d’événements encodant état, requête et réponse sans champs de preuve. L’exécution
d’un arbre reçoit explicitement la preuve de compatibilité initiale :

```text
run :
  (tree : PublicRepairTree(s,g))
  → (w : World)
  → Fiber(s,w)
  → PublicRunResult(tree,w)

transcript(tree,w,compatible)
terminalPublicState(tree,w,compatible)
terminalLeaf(tree,w,compatible).
```

La transcription contient seulement les requêtes, réponses et identifiants
publics nécessaires. Les preuves d’autorisation ne doivent pas participer à son
égalité. Les résultats d’exécution ne doivent pas dépendre du choix de la preuve
`compatible` ; ce lemme suit de l’irrélevance des preuves.

L’encodage doit être suffisamment discriminant pour prouver par induction sur
l’arbre :

```text
sameTranscript_sameLeaf :
  transcript(tree,w₁,compatible₁)
    = transcript(tree,w₂,compatible₂)
  → terminalLeaf(tree,w₁,compatible₁)
    = terminalLeaf(tree,w₂,compatible₂)

sameTranscript_samePublicState :
  transcript(tree,w₁,compatible₁)
    = transcript(tree,w₂,compatible₂)
  → terminalPublicState(tree,w₁,compatible₁)
    = terminalPublicState(tree,w₂,compatible₂).
```

Le second lemme se déduit du premier par application de `leafState`. Ces lemmes
sont des obligations de la sémantique des transcriptions, pas des hypothèses
ajoutées au no-go.

### 8.3 Arbre global résolvant l’action

```text
UniformActionResolvingTree(s,g,tree) :=
  ∀ w (compatible : Fiber(s,w)),
    ActionSufficientAt(
      terminalPublicState(tree,w,compatible),g).
```

L’arbre est unique avant de connaître le monde réel. Des mondes donnant des
réponses différentes peuvent atteindre des feuilles différentes.

### 8.4 Arbre certifié gagnant

Un arbre gagnant ajoute :

- la compatibilité de chaque monde avec l’état terminal de sa branche ;
- une fonction
  `∀ leaf, IsRealizableLeaf(s,tree,leaf) →
  CertifiedLocalClosure(leafState(tree,leaf),g)` ;
- la correction connue et réelle ;
- la provenance cumulative ;
- la non-régression cumulative.

L’état final d’une branche gagnante est le champ `after` de sa
`CertifiedLocalClosure`, pas nécessairement l’état brut de la feuille avant la
fermeture décisionnelle.

### 8.5 Définition de la réparabilité

```text
CertifiedRepairableAt(s,g) :=
  PublicFiberNonempty(s)
  × Σ tree : PublicRepairTree(s,g),
      CertifiedWinningTree(s,g,tree).
```

Cette définition fixe la conclusion : la réparabilité n’est ni la seule
homogénéité de la fibre, ni la seule existence d’une transcription séparatrice.
Elle inclut la fermeture correcte et les obligations de certification.

## 9. Indiscernabilité publique adaptative

Deux mondes compatibles sont indiscernables lorsque toute stratégie publique
autorisée leur donne la même transcription :

```text
PubliclyIndistinguishable(s,g,w₁,w₂) :=
  ∀ tree : PublicRepairTree(s,g),
    ∀ compatible₁ : Fiber(s,w₁),
    ∀ compatible₂ : Fiber(s,w₂),
      transcript(tree,w₁,compatible₁)
      = transcript(tree,w₂,compatible₂).
```

Puisque les mises à jour sont publiques et déterministes relativement aux
réponses, l’égalité des transcriptions force l’égalité des chemins, des états
publics terminaux et des décisions publiques par
`sameTranscript_sameLeaf` et `sameTranscript_samePublicState`.

La relation doit quantifier les mêmes arbres que ceux admis dans
`CertifiedRepairableAt`. Utiliser une classe d’expériences plus pauvre rendrait
le no-go inapplicable aux politiques réelles.

## 10. Théorème A — no-go adaptatif

### 10.1 Énoncé visé

```text
ActionConflict(s,g,w₁,w₂)
∧ PubliclyIndistinguishable(s,g,w₁,w₂)
→ ¬ CertifiedRepairableAt(s,g).
```

### 10.2 Preuve attendue

Supposons un arbre certifié gagnant. Les deux mondes suivent le même chemin
public, car leurs transcriptions sont égales. Ils atteignent donc le même état
public terminal.

La loi `observedWorldRetained`, composée le long du chemin, montre que les deux
mondes restent compatibles avec cet état. La feuille étant action-suffisante,
leurs continuations requises doivent être égales, en contradiction avec le
conflit initial et la stabilité de `Required`.

La preuve ne doit utiliser ni tiers exclu ni extraction classique d’un témoin.
Le conflit et l’indiscernabilité sont fournis positivement.

## 11. Théorème B — caractérisation opérationnelle globale

Définir d’abord :

```text
UniformlyActionResolvableAt(s,g) :=
  PublicFiberNonempty(s)
  × Σ tree : PublicRepairTree(s,g),
      UniformActionResolvingTree(s,g,tree)
      ∧ conservation cumulative du monde compatible
      ∧ frame cumulative
      ∧ provenance cumulative.
```

Sous une interface de réalisation décisionnelle totale sur les fibres publiques
non vides et homogènes, et pour des steps satisfaisant les lois de
conservativité, de cohérence, de provenance et de frame :

```text
CertifiedRepairableAt(s,g)
↔
UniformlyActionResolvableAt(s,g).
```

### 11.1 Direction gauche-droite

Oublier, dans un arbre gagnant, les certificats de fermeture des feuilles. La
structure restante est un arbre public global résolvant l’action.

### 11.2 Direction droite-gauche

Pour chaque feuille réalisable :

1. composer les lois de conservation du monde le long du chemin ;
2. en déduire `PublicFiberNonempty` ;
3. utiliser l’homogénéité terminale ;
4. appliquer `realizeHomogeneousDecision` ;
5. agréger provenance et frame.

Cette équivalence est exacte relativement aux interfaces déclarées. Elle ne
prétend pas que la simple séparabilité de chaque paire initiale construit déjà
l’arbre global.

## 12. Séparateurs adaptatifs de paires

### 12.1 Épisode séparateur

Pour une paire conflictuelle, un épisode séparateur est un arbre public fini dont
toute feuille réalisable élimine la coexistence de cette paire :

```text
PairSeparatingEpisode(s,g,w₁,w₂) :=
  Σ episode : PublicRepairTree(s,g),
    ∀ leaf : Leaf(episode),
      IsRealizableLeaf(s,episode,leaf)
      → ¬ (
        Fiber(leafState(episode,leaf),w₁)
        ∧ Fiber(leafState(episode,leaf),w₂)).
```

Les étapes préparatoires de l’épisode peuvent conserver temporairement les deux
mondes. La séparation est exigée uniformément à toutes les feuilles réalisables.
La réalisabilité est une proposition séparée ; aucune valeur de type `World`
n’est stockée dans l’adresse calculable d’une feuille.

### 12.2 Séparabilité positive

```text
AdaptivePairSeparability(s,g) :=
  ∀ w₁ w₂,
    ActionConflict(s,g,w₁,w₂)
    → PairSeparatingEpisode(s,g,w₁,w₂).
```

Le séparateur est une donnée positive. La négation de l’indiscernabilité ne doit
pas être utilisée pour extraire classiquement cet épisode.

### 12.3 Nécessité

Un arbre global résolvant l’action fournit un séparateur pour toute paire
conflictuelle : l’arbre global lui-même empêche les deux mondes de coexister dans
une feuille homogène.

Ainsi :

```text
UniformlyActionResolvableAt(s,g)
→ AdaptivePairSeparability(s,g).
```

La réciproque est fausse sans composabilité, comme le montre le contre-modèle à
trois mondes.

## 13. Composabilité séquentielle

### 13.1 Invariant de domaine

Introduire un prédicat public :

```text
RepairDomainInvariant(s,g).
```

Il regroupe uniquement les propriétés locales nécessaires à la réapplication du
constructeur :

- fibre calculable dans l’univers fini déclaré ;
- fibre publiquement non vide ;
- obligation `g` stable ;
- cohérence des autorisations ;
- état et historique bien formés ;
- disponibilité du compilateur public de réponses ;
- validité de la doctrine de frame ;
- validité de la doctrine d’identité stricte ;
- cohérence compositionnelle des transports ;
- cohérence logique des mises à jour.

Il ne doit contenir ni arbre gagnant, ni fermeture finale, ni rang terminal.

### 13.2 Séparabilité persistante

```text
PersistentAdaptivePairSeparability(g) :=
  ∀ s,
    RepairDomainInvariant(s,g)
    → AdaptivePairSeparability(s,g).
```

Cette propriété affirme que tout nouvel état admissible possède les séparateurs
locaux requis. Elle interdit de déduire abusivement la séparabilité future de la
seule séparabilité initiale.

### 13.3 Séparabilité composable

La persistance existentielle seule ne garantit pas que l’épisode séparateur
choisi préserve l’invariant. L’épisode et sa preuve de fermeture doivent être
fournis dans le même objet positif :

```text
structure ComposablePairSeparatingEpisode(s,g,w₁,w₂) where
  episode : PublicRepairTree(s,g)
  separated :
    ∀ leaf : Leaf(episode),
      IsRealizableLeaf(s,episode,leaf)
      → ¬ (
        Fiber(leafState(episode,leaf),w₁)
        ∧ Fiber(leafState(episode,leaf),w₂))
  invariantPreserved :
    ∀ leaf : Leaf(episode),
      IsRealizableLeaf(s,episode,leaf)
      → RepairDomainInvariant(leafState(episode,leaf),g)

ComposableAdaptivePairSeparability(g) :=
  ∀ s,
    RepairDomainInvariant(s,g)
    → ∀ w₁ w₂,
      ActionConflict(s,g,w₁,w₂)
      → ComposablePairSeparatingEpisode(s,g,w₁,w₂).
```

Cette propriété implique `PersistentAdaptivePairSeparability`, mais sa réciproque
n’est pas utilisée. Elle constitue la composabilité séquentielle exacte requise
par le théorème de synthèse.

Une instance peut établir cette propriété parce que :

- les requêtes restent disponibles après raffinement ;
- une réponse peut ouvrir de nouvelles requêtes sans fermer les anciennes ;
- les autorisations suivent une loi de monotonie ;
- ou un protocole spécifique construit explicitement le séparateur suivant.

Le théorème général ne doit choisir aucune de ces raisons à la place de
l’instance.

## 14. Mesure constructive des conflits

### 14.1 Représentation sans quotient

La formalisation Lean ne doit pas représenter les paires non ordonnées par un
quotient. Utiliser les paires ordonnées de la liste globale :

```text
orderedConflicts(s,g) :=
  (allWorlds × allWorlds).filter
    (fun (w₁,w₂) =>
      w₁ ≠ w₂
      ∧ Fiber(s,w₁)
      ∧ Fiber(s,w₂)
      ∧ Required(g,w₁) ≠ Required(g,w₂)).
```

Puis :

```text
μAction(s,g) := orderedConflicts(s,g).length.
```

Chaque conflit non ordonné peut être compté deux fois. Cela ne change ni le
critère de nullité ni la bonne fondation de la mesure.

### 14.2 Critère de fermeture informationnelle

```text
μAction(s,g) = 0
↔ ActionSufficientAt(s,g).
```

La preuve utilise l’énumération complète, les décisions d’égalité et le filtre
calculable. Elle ne transforme pas classiquement `¬ ∀` en un témoin existentiel.

Le programme de décision doit produire directement :

```text
ActionSufficientAt(s,g)
⊎ Σ w₁ w₂, ActionConflict(s,g,w₁,w₂).
```

### 14.3 Monotonie

Sous stabilité de `Required` :

```text
(∀ w, Fiber(after,w) → Fiber(before,w))
→ μAction(after,g) ≤ μAction(before,g).
```

### 14.4 Diminution uniforme d’un épisode séparateur

Pour la paire sélectionnée et toute feuille réalisable de son épisode :

```text
∀ leaf,
  IsRealizableLeaf(before,episode,leaf)
  → μAction(leafState(episode,leaf),g) < μAction(before,g).
```

La monotonie empêche la création de nouveaux conflits. La fidélité de l’épisode
retire au moins les deux orientations de la paire sélectionnée.

La diminution est exigée sur toutes les feuilles réalisables, pas uniquement sur
la branche du monde utilisé lors d’une exécution particulière.

## 15. Théorème C — synthèse constructive

### 15.1 Hypothèses

Pour l’état initial `s` et l’obligation `g` :

1. `RepairDomainInvariant(s,g)` ;
2. l’univers des mondes est explicitement fini ;
3. les conflits sont décidables et énumérables ;
4. `ComposableAdaptivePairSeparability(g)` ;
5. les étapes sont publiques et conservent tout monde compatible donnant la
   transcription observée ;
6. les fibres postérieures sont incluses dans les fibres antérieures ;
7. `Required(g,·)` reste stable ;
8. la doctrine de frame se compose ;
9. les steps et fermetures décisionnelles sont conservatifs pour l’identité
    stricte, cohérents pour les transports et logiquement consistants ;
10. les fibres homogènes non vides possèdent une réalisation décisionnelle.

### 15.2 Construction

À partir d’un état admissible :

```text
si μAction = 0 :
  construire la fermeture décisionnelle publique

sinon :
  extraire constructivement une paire conflictuelle
  obtenir son épisode séparateur positif
  pour chaque feuille réalisable :
    prouver la diminution stricte de μAction
    réappliquer la construction à l’état terminal
  greffer les sous-arbres obtenus à l’épisode séparateur.
```

La récursion bien fondée utilise seulement `μAction(s,g)`. La stratégie globale
est construite avant de connaître le monde réel et contient une continuation
pour toute branche réalisable.

### 15.3 Conclusion

```text
FinitePublicEnvironment
→ ComposableAdaptivePairSeparability(g)
→ LawfulFiberRepair
→ DecisionRealizationComplete
→ CompositionalFrameLaw
→ LogicalConservativity
→ TransportCoherence
→ RepairDomainInvariant(s,g)
→ CertifiedRepairableAt(s,g).
```

Le théorème ne conclut pas à partir de la seule
`AdaptivePairSeparability(s,g)`. L’épisode choisi et sa fermeture de l’invariant
sont réunis dans une hypothèse positive visible et auditable.

## 16. Théorème D — posterior exact

L’exactitude doit d’abord être formulée au niveau où la réparation a réellement
lieu : après chaque réponse publique.

Pour une requête `q` posée depuis `before` et une réponse `r`, définir :

```text
ExactResponsePosterior(before,q,r,w) :=
  Fiber(before,w)
  ∧ respond(w,q) = r.
```

Une étape exacte satisfait :

```text
Fiber(step.after,w)
↔ ExactResponsePosterior(before,q,r,w).
```

`ExactPosteriorRepairComplete` porte un compilateur canonique `realizeResponse`
défini pour toute requête autorisée et toute réponse figurant dans
`realizableResponses`, ainsi que la preuve de cette équivalence pour tout monde.
L’interface fixe ce compilateur ; elle ne prétend pas que tout
`PublicRepairStep` arbitraire est exact.

La réalisabilité de la réponse reste une proposition :

```text
IsRealizableResponse(before,q,r) : Prop :=
  ∃ w,
    Fiber(before,w)
    ∧ respond(w,q) = r.
```

L’énumération publique doit satisfaire :

```text
r ∈ realizableResponses(before,q)
↔ IsRealizableResponse(before,q,r).
```

Le compilateur public a alors la signature suivante :

```text
realizeResponse :
  (before : PublicState)
  → (g : Obligation)
  → (q : Query(before,g))
  → authorized(before,g,q)
  → (r : Response(q))
  → r ∈ realizableResponses(before,q)
  → PublicRepairStep(before,g,q,r).
```

Le témoin sémantique reste dans `Prop` et n’est pas transmis au constructeur de
l’état public. Celui-ci reçoit seulement une preuve d’appartenance à la liste
publique calculée. La partie calculable du step dépend de `before`, `g`, `q` et
`r`, jamais du monde réel d’exécution.

Un arbre exact doit ensuite certifier que chacun de ses steps est précisément
produit par ce compilateur canonique :

```text
GeneratedByExactCompiler(complete,tree) :=
  propriété inductive telle que

  GeneratedByExactCompiler(complete,stop)

  GeneratedByExactCompiler(complete,ask q authorization step next)
  ↔
    (∀ r membership,
      step(r,membership)
      = complete.realizeResponse(
          before,g,q,authorization,r,membership))
    ∧ (∀ r membership,
      GeneratedByExactCompiler(
        complete,next(r,membership))).

ExactPublicRepairTree(complete,tree) :=
  GeneratedByExactCompiler(complete,tree).
```

L’exactitude de tous les steps d’un `ExactPublicRepairTree` se déduit donc du
compilateur, au lieu d’être supposée pour un arbre arbitraire.

Définir constructivement la relation indiquant qu’un monde suit une adresse de
feuille :

```text
ReachesLeaf(before,e,w,leaf) : Prop :=
  ∃ compatible : Fiber(before,w),
    terminalLeaf(e,w,compatible) = leaf.
```

La composition des équivalences locales le long d’un épisode exact donne ensuite
le posterior exact de chaque feuille :

```text
ExactPublicRepairTree(complete,e)
→
Fiber(leafState(e,leaf),w)
↔ ReachesLeaf(before,e,w,leaf).
```

Cette loi composée implique constructivement :

- l’inclusion de chaque fibre terminale dans la fibre initiale ;
- la conservation de tout monde compatible ayant atteint la feuille ;
- l’élimination conjointe de deux mondes dont les transcriptions diffèrent ;
- la diminution de `μAction` pour toute paire séparée.

Pour que l’épisode séparateur choisi soit à la fois composable et exact, définir :

```text
structure ExactComposablePairSeparatingEpisode
    (complete,s,g,w₁,w₂) where
  composable : ComposablePairSeparatingEpisode(s,g,w₁,w₂)
  generated :
    ExactPublicRepairTree(complete,composable.episode)

ExactComposableAdaptivePairSeparability(complete,g) :=
  ∀ s,
    RepairDomainInvariant(s,g)
    → ∀ w₁ w₂,
      ActionConflict(s,g,w₁,w₂)
      → ExactComposablePairSeparatingEpisode(complete,s,g,w₁,w₂).
```

Le premier corollaire Lean raisonnable est alors :

```text
FinitePublicEnvironment
∧ RepairDomainInvariant(s,g)
∧ (Σ complete : ExactPosteriorRepairComplete,
    ExactComposableAdaptivePairSeparability(complete,g))
∧ DecisionRealizationComplete
∧ CompositionalFrameLaw
∧ LogicalConservativity
∧ TransportCoherence
→ CertifiedRepairableAt(s,g).
```

La version par sur-approximation fidèle sera une généralisation ultérieure.

## 17. Doctrine structurelle de non-régression

Une propriété antérieure ne doit pas être transmise au théorème sous la forme
d’une preuve arbitraire qu’elle est préservée. Sa dépendance doit être exposée.

Pour chaque clé protégée :

```text
ProtectedSnapshot : CertificateKey → Type
protectedKeys : PublicState → List CertificateKey
readProtected : (key : CertificateKey) → PublicState → ProtectedSnapshot(key)
ClosedProperty : (key : CertificateKey) → ProtectedSnapshot(key) → Prop.
```

Le registre public satisfait :

```text
protectedKeys_nodup(s) : protectedKeys(s).Nodup

keysMonotone(before,after) :=
  ∀ key,
    key ∈ protectedKeys(before)
    → key ∈ protectedKeys(after).
```

Pour toute clé appartenant au registre avant l’étape, celle-ci fournit soit :

```text
readProtected(key,after) = readProtected(key,before),
```

soit un transport structurel explicitement associé à cette clé.

La conservation se déduit alors par réécriture ou par le transport déclaré :

```text
ClosedProperty(key,readProtected(key,before))
→ ClosedProperty(key,readProtected(key,after)).
```

La composition des égalités ou transports le long d’un arbre produit la
non-régression cumulative.

Une fermeture décisionnelle ajoute en outre la clé canonique de l’obligation
courante :

```text
obligationKey(g) ∈ protectedKeys(closure.after)
```

et porte la preuve `ClosedProperty` correspondante. Les lois `keysMonotone` et
`protectedKeys_nodup` garantissent que les épisodes suivants conservent le
registre cumulatif sans dupliquer silencieusement les certificats.

`CompositionalFrameLaw` abrège les preuves suivantes pour chaque step et chaque
fermeture décisionnelle : `keysMonotone`, préservation ou transport des lectures
anciennes, ajout de la clé courante lors d’une fermeture, et stabilité de ces
propriétés par composition et par `bindLeaves`.

Dans les réalisations actuelles, les lectures protégées peuvent être les entrées
du candidat situées dans le préfixe déjà réparé et les enregistrements de
provenance correspondants.

## 18. Hiérarchie dynamique

### 18.1 `CertifiedRepairStep`

Une interaction publique élémentaire :

```text
requête autorisée
→ réponse environnementale
→ réparation publique intrinsèque
→ transition certifiée.
```

### 18.2 `PairSeparatingEpisode`

Une suite finie de steps préparatoires ou informatifs qui élimine une paire
conflictuelle sur toutes ses feuilles réalisables.

### 18.3 `CertifiedRepairEpisode`

L’arbre fini synthétisé par récursion sur `μAction`, qui ferme une obligation
stable dans toutes les branches compatibles.

### 18.4 `CertifiedRepairOrbit`

Une suite d’épisodes :

- dans un domaine fermé fini, une mesure globale peut conduire à un état stable ;
- dans un domaine ouvert, chaque épisode ferme son obligation courante et
  préserve les précédentes sans supposer de terminal fini.

Les réalisations actuelles sont des instances particulièrement directes : chaque
gap publié y est fermé par un step certifié.

## 19. Extension ouverte

Pour une suite intrinsèque d’obligations `g₀,g₁,…`, construire :

```text
∀ n,
  CertifiedRepairEpisode(state(n),gₙ,state(n+1))
  ∧ LocalClosure(state(n+1),gₙ)
  ∧ conservation des clôtures de g₀,…,gₙ₋₁
  ∧ state(n+1) ≠ state(n).
```

Chaque épisode utilise sa propre mesure finie `μAction(·,gₙ)`. Aucune mesure
globale finie n’est requise pour l’orbite ouverte.

La branche non terminale est consommée par l’obligation suivante, portée par les
données intrinsèques de l’environnement. Aucun pont terminal conditionnel n’est
admissible.

## 20. Contre-modèles obligatoires

La formalisation ou son banc de tests doit inclure quatre modèles négatifs.

### 20.1 Séparabilité non composable

Le modèle à trois mondes de la section 2 doit satisfaire la séparabilité initiale
de chaque paire tout en réfutant l’existence d’un arbre global résolvant. Il
valide la nécessité de la composabilité.

### 20.2 Candidat non expressif

Une fibre singleton dont l’action requise n’est représentable par aucun candidat
doit réfuter la réparabilité certifiée malgré `μAction = 0`. Il valide la
nécessité de la réalisation décisionnelle.

### 20.3 Réparation consultant le monde privé

Une fonction autorisée artificiellement à lire `World` peut fermer immédiatement
tous les gaps. Elle doit être rejetée par les signatures publiques, et non
acceptée puis exclue par une convention narrative.

### 20.4 Régression par mutation hors frame

Une réparation qui réduit correctement la fibre mais modifie une entrée protégée
doit échouer à produire la preuve de frame. Elle valide l’indépendance entre
raffinement épistémique et conservation du candidat.

## 21. Garde-fous contre la tautologie

Les hypothèses du théorème de synthèse ne doivent pas contenir :

- un `CertifiedRepairEpisode` déjà complet ;
- un arbre global gagnant ;
- un `GapClosedBy` terminal fourni ;
- une politique supposée correcte ;
- un rang terminal externe ;
- la liste des branches réelles futures ;
- une consultation du monde privé ;
- un prédicat de frame défini comme la conclusion de non-régression elle-même.

Les hypothèses admissibles portent sur :

- l’énumération et la décidabilité des données ;
- la sémantique des requêtes et réponses ;
- des séparateurs locaux positifs ;
- la fermeture locale d’un invariant de domaine ;
- les compilateurs publics de transcriptions et de candidats ;
- leurs lois de fidélité, conservativité, provenance et frame.

La paire conflictuelle, la stratégie globale, la récursion, les décisions
terminales et la preuve cumulative doivent être construites.

## 22. Plan de formalisation Lean

### Étape A — données publiques finies

Définir l’univers fini explicite, les fibres calculables, les obligations
stables, les requêtes dépendantes et les réponses réalisables.

### Étape B — conflits et mesure

Définir :

```text
ActionConflict
ActionSufficientAt
orderedConflicts
actionConflictMeasure
```

Prouver la décision positive conflit/suffisance, le critère de nullité et la
monotonie.

### Étape C — étapes publiques

Définir `PublicRepairStep` et établir, par les types, que ses données
opérationnelles ne dépendent pas du monde réel.

### Étape D — arbres et exécution

Définir `PublicRepairTree`, les transcriptions, l’état terminal, la composition
des frames, `Leaf`, `IsRealizableLeaf`, la conservation du monde compatible et
l’opération totale `bindLeaves` avec ses lois de greffe.

Prouver `sameTranscript_sameLeaf` et `sameTranscript_samePublicState`.

### Étape E — no-go adaptatif

Prouver le théorème A pour exactement la même classe d’arbres publics que celle
utilisée par la définition de réparabilité.

### Étape F — réalisation décisionnelle

Définir `CertifiedLocalClosure` avec son état `after`, son registre cumulatif et
le compilateur des fibres homogènes. Relier ses instances à `GapClosedBy` puis à
`RestoredLocalSufficiency`.

### Étape G — caractérisation globale

Prouver le théorème B entre résolvabilité globale et réparabilité certifiée.

### Étape H — épisodes séparateurs

Définir la séparabilité positive, l’invariant de domaine, sa fermeture et la
composabilité séquentielle.

### Étape I — synthèse bien fondée

Construire l’arbre global par récursion sur `actionConflictMeasure`. Prouver la
diminution sur chaque feuille réalisable avant tout appel récursif.

### Étape J — posterior exact et contre-modèles

Instancier la complétude exacte, définir `GeneratedByExactCompiler`, prouver
l’exactitude des feuilles des arbres générés, puis formaliser les quatre
contre-modèles. Un énoncé naïf réintroduit ultérieurement doit échouer sur au
moins l’un d’eux.

### Étape K — instances existantes

Relier les systèmes fini et ouvert publiés aux nouvelles interfaces sans élargir
leurs quantificateurs actuels.

## 23. Critères d’acceptation formelle

Le futur développement sera acceptable seulement si :

- toutes les preuves sont constructives ;
- aucun axiome, `Classical`, `propext` ou `Quot.sound` n’est utilisé ;
- l’univers fini et les décisions d’égalité sont des données explicites ;
- aucune paire non ordonnée n’est implémentée par quotient ;
- les séparateurs sont des témoins positifs ;
- les stratégies ne reçoivent jamais le monde réel ;
- la classe d’expériences du no-go est identique à celle des politiques positives ;
- l’égalité des transcriptions implique formellement l’égalité des feuilles et
  des états publics terminaux ;
- la séparabilité paire par paire n’est jamais utilisée sans composabilité ;
- la réalisation du posterior et celle du candidat sont deux interfaces séparées ;
- toute réalisabilité de feuille est un prédicat dans `Prop`, séparé de son adresse ;
- `bindLeaves` est total sur les adresses et traite explicitement les feuilles
  irréalisables ;
- la fermeture décisionnelle expose un état public `after` et un candidat terminal ;
- le monde compatible est préservé pour toute réponse effectivement produite ;
- la diminution de mesure vaut sur toutes les feuilles réalisables ;
- tout théorème de posterior exact est limité aux arbres prouvés générés par le
  compilateur exact ;
- la frame condition est structurelle, son registre est monotone et elle se compose ;
- l’identité stricte reste conservative et les transports restent cohérents ;
- la terminaison fermée utilise uniquement une mesure interne ;
- l’extension ouverte ne suppose aucun terminal fini ;
- chaque fichier Lean possède exactement un bloc final `AXIOM_AUDIT` ;
- chaque déclaration auditée existe et n’affiche aucune dépendance axiomatique.

## 24. Revendication scientifique autorisée après preuve

Une fois les théorèmes A à D démontrés et les contre-modèles formalisés, la
revendication défendable sera :

> Pour une classe explicitement définie d’environnements partiellement
> observables finis et déterministes, la réparabilité certifiée est caractérisée
> par l’existence d’une stratégie publique globale gagnante. Une telle stratégie
> peut être synthétisée constructivement à partir de séparateurs locaux de
> conflits lorsque ceux-ci sont séquentiellement composables, que les
> transcriptions et décisions sont réalisables par le langage interne, et que
> des lois explicites de conservativité, de cohérence, de provenance et de
> non-régression sont satisfaites.

Cette revendication réunit précisément :

```text
obstruction informationnelle
+ acquisition active publique
+ réparation intrinsèque
+ synthèse d’une stratégie globale
+ fermeture décisionnelle
+ conservation cumulative.
```

Elle ne prétend pas que la séparabilité ponctuelle ou paire par paire suffit dans
tous les systèmes interactifs.

## 25. Non-revendications persistantes

Même après cette formalisation resteraient séparés :

- les réponses bruitées, adversariales ou retardées ;
- les mondes continus ou non effectivement énumérables ;
- l’apprentissage des représentations, requêtes ou réparations ;
- l’optimalité en coût ou en nombre de requêtes ;
- la généralisation statistique hors distribution ;
- la comparaison expérimentale avec les belief states, predictive states,
  méthodes de diagnostic actif et raffinement d’abstraction ;
- l’irréductibilité à toutes les théories voisines ;
- toute revendication de priorité historique.

Ces extensions ne doivent être ni supposées silencieusement ni confondues avec
la caractérisation constructive finie.
