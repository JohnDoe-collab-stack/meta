# Plan d'implementation de la recurrence visible sans retour causal

## 0. Statut et decision

Ce plan ajoute une couche causale au theoreme generique deja prouve dans :

```text
Meta/Tarski/GenericPatchOrbit.lean
```

Il ne remplace ni le noyau arithmetique autonome en construction, ni le
`PatchableArithmeticTarskiContext`. Il formalise exactement le renforcement
suivant :

```text
mismatch diagonal local
+ patch syntaxique intrinseque
+ preservation hors de l'index courant
+ accumulation positive des reparations passees
-------------------------------------------------
recurrence possible d'une observation visible reparee
+ impossibilite d'un retour de l'etat causal complet
```

Le resultat vise est generique sur tout `PatchableArithmeticTarskiContext` et
ne depend pas de `Foundation`, de `FoundationBridge`, du modele d'atomes frais,
d'un rang, d'une horloge ou d'un compteur stocke dans l'etat.

La memoire n'est pas une hypothese supplementaire de fraicheur. C'est la trace
positive des vrais `AlgorithmStep` deja produits par le mecanisme de patch.
Son invariant de correction doit etre derive du mismatch, de la reparation et
de la preservation.

### 0.1 Etat d'execution au 20 juillet 2026

L'implementation decrite par ce plan est fermee :

```text
C1 fermee : memoire positive, correction derivee et raccord bilateral ;
C2 fermee : etat causal, alignement dynamique et non-retour extensionnel ;
C3 fermee : recurrence visible simultanee et temoin canonique S_1/S_2 ;
integration fermee : import public dans Meta.lean et audit agrege vide.
```

Declarations principales effectivement livrees :

```text
CausalMemory
CausalMemory.Remembers
CausalMemory.correctAt_of_remembers
CausalMemory.current_not_remembered
CausalState
causalOrbit
MemoryEquivalent
CausallyEquivalent
causalOrbit_memory_notEquivalent_of_lt
causalOrbit_not_causallyEquivalent_of_lt
VisibleRecurrenceWithCausalSeparation
genericVisibleRecurrenceWithCausalNonReturn
canonicalVisibleRecurrenceWithCausalNonReturn
GenericVisibleCausalNonRecurrenceTheorem
genericVisibleCausalNonRecurrenceTheorem
```

La construction complete `lake build Meta` passe sur 649 cibles. Tous les
`#print axioms` des trois nouveaux modules et de la declaration agregee sont
vides.

## 1. Frontiere exacte de la revendication

### 1.1 Ce qui est deja prouve

Pour tout contexte patchable et tout candidat initial, le noyau actuel prouve :

```text
les anciens defis restent corriges ;
le defi courant est distinct de tous les anciens ;
les indices diagonaux sont injectifs ;
les candidats syntaxiques sont injectifs ;
l'orbite dynamique n'a aucun retour exact de periode positive ;
chaque candidat demeure globalement incomplet.
```

La fraicheur est deja derivee. Elle n'est pas un champ du contexte.

### 1.2 Ce qui manque

L'etat actuel de l'orbite est seulement un `Predicate`. La memoire des gaps
repares existe dans `GenericOrbitInvariant`, mais seulement comme invariant de
preuve indexe par un entier externe. Il manque :

```text
un objet positif de memoire causale ;
un etat qui porte cette memoire ;
une equivalence causale extensionnelle ;
une preuve de non-retour modulo cette equivalence ;
une observation visible qui peut se repeter entre deux etats ainsi separes.
```

### 1.3 Enonce qui sera revendique

Le theoreme principal ne dira pas que « Tarski seul produit le temps ». Son
hypothese exacte reste :

```lean
patchable : PatchableArithmeticTarskiContext
```

Cette structure contient trois ingredients substantiels : point fixe
diagonal, patch syntaxique local et preservation hors de l'index patche.

Pour `d_k`, le defi diagonal produit a l'etape `k`, et pour `k < n < m`, la
cible constructive est :

```text
1. d_k est une observation causalement autorisee dans S_n et S_m ;
2. les deux observations ont exactement le meme code syntaxique visible ;
3. les candidats de S_n et S_m ont la meme reponse a d_k, au sens de ↔ ;
4. S_n et S_m ne sont pas causalement equivalents.
```

Forme mathematique :

```text
forall k < n < m,
  project(view(S_n, d_k)) = project(view(S_m, d_k))
  and (truthAt(S_n, d_k) <-> truthAt(S_m, d_k))
  and not (S_n ~=causal S_m).
```

L'egalite visible porte sur un vrai index syntaxique observe, pas sur `Unit`.
L'equivalence des reponses est exprimee par `Iff`, et non par une egalite de
`Prop`; cela evite `propext`.

Ce theoreme montre une recurrence visible contextuelle et exacte a un ancien
defi repare. Il ne pretend pas que l'integralite des predicats visibles aux
etapes `n` et `m` est identique.

## 2. Principes anti-trivialisation

L'implementation sera rejetee si l'une des techniques suivantes apparait dans
le chemin du theoreme principal :

```text
un champ stage, rank, timestamp, age ou generation ;
la longueur de la memoire utilisee pour separer deux etats ;
un Nat.succ fabrique comme certificat de fraicheur ;
l'egalite brute des listes ou des etats comme notion causale finale ;
une projection constante vers Unit, Bool.true ou un index fixe arbitraire ;
une hypothese fresh, injective, acyclic ou noReturn ajoutee a l'interface ;
une equivalence qui mentionne les indices d'iteration n et m ;
genericOrbitIndex_injective utilise pour prouver le nouveau non-retour ;
genericOrbitCandidate_injective utilise pour prouver le nouveau non-retour ;
une egalite de propositions obtenue par propext ;
un quotient de propositions obtenu par Quot.sound ;
un pont terminal, une fenetre ou une projection finale conditionnelle.
```

Les entiers naturels restent permis pour definir et interroger l'orbite. Ils
ne doivent jamais etre stockes dans `CausalState` ni servir de separateur
causal.

La preuve de separation devra exhiber une donnee semantiquement pertinente :
le defi courant de l'etat ancien est absent de sa memoire par mismatch, puis
present dans la memoire de tout etat strictement ulterieur par reparation.

## 3. Architecture retenue

Trois nouveaux modules sont suffisants :

```text
Meta/Tarski/CausalMemory.lean
Meta/Tarski/CausalOrbit.lean
Meta/Tarski/VisibleCausalRecurrence.lean
```

Graphe d'import :

```text
TruthGap
   |
DynamicRelaxedUsage
   |
GenericPatchOrbit
   |
CausalMemory
   |
CausalOrbit
   |
VisibleCausalRecurrence
```

Aucun de ces modules ne doit importer :

```text
Foundation.*
Meta.Tarski.FoundationBridge
Meta.Tarski.ConstructivePatchModel
Meta.Tarski.IntrinsicArithmeticSyntax
Meta.Tarski.IntrinsicArithmeticPatch
```

L'ajout a `Meta.lean` ne se fera qu'apres fermeture de toutes les portes de ce
plan.

## 4. Module 1 - Memoire causale positive

### 4.1 Memoire indexee par son candidat courant

La memoire doit etre une chaine inductive dont chaque extension conserve le
vrai pas algorithmique :

```lean
inductive CausalMemory
    (patchable : PatchableArithmeticTarskiContext)
    (initial : patchable.context.Predicate) :
    patchable.context.Predicate -> Type where
  | root :
      CausalMemory patchable initial initial
  | extend
      {current : patchable.context.Predicate}
      (previous : CausalMemory patchable initial current)
      (event : patchable.AlgorithmStep current) :
      CausalMemory patchable initial event.nextPredicate
```

Le type dependamment indexe impose la coherence source-cible. Aucun champ
externe `next` n'est admis. Dans l'orbite canonique, `event` sera toujours
`patchable.step current`.

Un noeud conserve donc deja :

```text
le candidat source ;
la phrase diagonale ;
le point fixe ;
le mismatch local ;
le candidat patche ;
la correction a l'index courant ;
la preservation hors de cet index ;
le mismatch suivant.
```

Ces donnees sont celles d'`AlgorithmStep`; elles ne doivent pas etre dupliquees
dans une nouvelle liste de champs.

### 4.2 Appartenance sans egalite decidable

L'implementation finale utilise une definition structurellement recursive :

```lean
def CausalMemory.Remembers :
    CausalMemory patchable initial current ->
    patchable.context.Sentence -> Prop
  | .root, _ => False
  | .extend previous event, sentence =>
      sentence = event.diagonalSentence ∨
        previous.Remembers sentence
```

Cette relation ne demande ni `DecidableEq Sentence`, ni recherche booleenne,
ni liste quotientee. Elle conserve exactement les deux constructeurs positifs
attendus : `Or.inl rfl` joue le role de la tete et `Or.inr remembered` celui du
transport depuis la memoire precedente.

Une premiere formulation comme famille inductive indexee directement par
`CausalMemory` a ete rejetee : son elimination demandait d'identifier des
champs fonctionnels de deux `AlgorithmStep`. La definition recursive evite ce
transport impropre sans affaiblir la notion d'appartenance.

### 4.3 Correction intrinseque de toute phrase rememoree

Theoreme central du module :

```lean
theorem CausalMemory.correctAt_of_remembers
    (memory : CausalMemory patchable initial current)
    (remembered : memory.Remembers sentence) :
    CorrectAt patchable current sentence
```

Preuve par induction sur `memory` :

1. `root` ne peut contenir aucune phrase ;
2. le cas `head` est `event.repaired_index_agreement` ;
3. dans le cas `tail`, l'hypothese d'induction corrige deja la phrase dans le
   candidat precedent ;
4. si cette phrase etait le diagonal courant, cette correction contredirait
   `tarski_local_mismatch (patchable.context.fixedPoint current)`, apres
   reecriture par `event.diagonalSentence_eq` ;
5. `event.preserves_off_index` transporte alors la correction vers le nouveau
   candidat.

Le point 4 ne doit pas utiliser directement `event.fixedPoint` : le type
actuel d'`AlgorithmStep` ne contient pas une equation explicite entre le champ
`liar` de ce point fixe et `event.diagonalSentence`. Le point fixe canonique du
contexte a, lui, `patchable.diagonalSentence current` pour phrase, et
`event.diagonalSentence_eq` fournit exactement le raccord requis.

C'est le coeur non trivial de l'implementation. La memoire ne recoit pas un
champ `sound`; sa correction est derivee de sa structure.

### 4.4 Le gap courant n'est pas deja en memoire

Corollaire obligatoire :

```lean
theorem CausalMemory.current_not_remembered
    (memory : CausalMemory patchable initial current) :
    memory.Remembers (patchable.diagonalSentence current) -> False
```

La preuve compose `correctAt_of_remembers` avec le point fixe du candidat
courant. Elle ne compare aucune longueur et n'utilise aucune injectivite
d'orbite.

### 4.5 Raccord bilateral existant

Chaque evenement doit pouvoir etre expose comme :

```lean
TarskiDynamicRelaxedUsage.TarskiPatchComplete
  patchable
  TarskiPatchBranch.causal
```

puis projete vers les vues `Forward`, `Backward` et `Intersection` avec
`tarskiPatchCompleteness`. Ce raccord est un adaptateur derive de l'evenement,
pas une seconde representation stockee.

Il certifie que la memoire retient bien les deux orientations du pas : gap
diagonal et reparation syntaxique.

### Porte C1

```text
CausalMemory est strictement positive et indexee par le candidat obtenu ;
chaque extension contient un AlgorithmStep reel ;
correctAt_of_remembers est prouve par mismatch + repair + preservation ;
current_not_remembered est derive, jamais stocke ;
les vues bilaterales existantes sont recuperables ;
aucun compteur causal n'existe dans l'API ;
les audits sont vides.
```

## 5. Module 2 - Etat et orbite causale

### 5.1 Etat complet

Definir :

```lean
structure CausalState
    (patchable : PatchableArithmeticTarskiContext)
    (initial : patchable.context.Predicate) where
  current : patchable.context.Predicate
  memory : CausalMemory patchable initial current
```

Le gap courant, son point fixe et le prochain patch restent calculables par
`patchable.step current`. Les dupliquer dans l'etat creerait des obligations de
coherence inutiles.

### 5.2 Transition canonique

```lean
def CausalState.advance (state : CausalState patchable initial) :
    CausalState patchable initial :=
  let event := patchable.step state.current
  { current := event.nextPredicate
    memory := .extend state.memory event }
```

Deux equations sont obligatoires :

```text
advance.current = patchable.nextPredicate state.current ;
advance.current =
  (tarskiPatchGapDrivenDynamicSystem patchable initial).next state.current.
```

La seconde doit etre obtenue via `tarskiPatchNext_eq_nextPredicate`. Elle
garantit que la nouvelle couche causale n'invente pas une dynamique parallele.

### 5.3 Orbite canonique et alignement

```lean
def causalOrbit : Nat -> CausalState patchable initial
  | 0 => { current := initial, memory := .root }
  | n + 1 => (causalOrbit n).advance
```

Prouver :

```lean
theorem causalOrbit_current_eq_genericOrbitCandidate :
  (causalOrbit patchable initial n).current =
    genericOrbitCandidate patchable initial n

theorem causalOrbit_current_eq_dynamicOrbitCandidate :
  (causalOrbit patchable initial n).current =
    genericDynamicOrbitCandidate patchable initial n
```

Ces lemmes servent au raccord public. Ils ne doivent pas etre utilises pour
separer causalement les etats.

### 5.4 Accumulation effective

Prouver par induction sur l'orbite :

```lean
theorem causalOrbit_remembers_of_lt
    (earlier : k < n) :
    (causalOrbit patchable initial n).memory.Remembers
      (genericOrbitIndex patchable initial k)
```

Le cas `k = n` au successeur utilise `Or.inl rfl`; le cas `k < n` utilise
`Or.inr`. La preuve construit une appartenance effective a la chaine, et pas
une simple propriete d'ensemble.

Ajouter la version sans indices d'iteration pour une transition quelconque :

```lean
theorem advance_remembers_current_gap :
  state.advance.memory.Remembers
    (patchable.diagonalSentence state.current)
```

### 5.5 Equivalence causale extensionnelle

Definir d'abord l'equivalence de memoire :

```lean
structure MemoryEquivalent (left right : CausalState patchable initial) : Prop
    where
  forward : forall sentence,
    left.memory.Remembers sentence -> right.memory.Remembers sentence
  backward : forall sentence,
    right.memory.Remembers sentence -> left.memory.Remembers sentence
```

Puis l'equivalence de l'etat causal complet :

```lean
structure CausallyEquivalent
    (left right : CausalState patchable initial) : Prop where
  sameVisibleBehavior : forall sentence,
    patchable.truthAt left.current sentence <->
      patchable.truthAt right.current sentence
  sameMemory : MemoryEquivalent left right
```

Cette notion oublie les preuves internes, l'ordre de representation et toute
egalite syntaxique brute, mais elle preserve :

```text
le comportement visible point par point ;
toutes les obligations causales accumulees dans les deux directions.
```

Prouver reflexivite, symetrie et transitivite directement par `Iff.rfl`,
`Iff.symm`, `Iff.trans` et composition des fonctions d'appartenance. Ne pas
former un quotient Lean.

### 5.6 Non-retour causal

Theoreme separateur principal du module :

```lean
theorem causalOrbit_memory_notEquivalent_of_lt
    (later : n < m) :
    MemoryEquivalent
      (causalOrbit patchable initial n)
      (causalOrbit patchable initial m) -> False
```

Preuve imposee :

1. le gap `d_n` n'est pas rememore dans `S_n`, par
   `CausalMemory.current_not_remembered` ;
2. `d_n` est rememore dans `S_m`, par
   `causalOrbit_remembers_of_lt later` ;
3. la direction `backward` de `MemoryEquivalent` le transporterait dans
   `S_n` ;
4. contradiction.

Le non-retour de l'etat complet est ensuite un corollaire strict :

```lean
theorem causalOrbit_not_causallyEquivalent_of_lt
    (later : n < m) :
    CausallyEquivalent
      (causalOrbit patchable initial n)
      (causalOrbit patchable initial m) -> False
```

Il projette `sameMemory` et appelle
`causalOrbit_memory_notEquivalent_of_lt`. Ainsi la separation est imposee par
la memoire meme si un comportement visible plus grossier se repete.

La preuve est rejetee si elle appelle l'injectivite des indices, l'injectivite
des candidats, l'egalite brute des etats ou une longueur de memoire.

Corollaire :

```lean
theorem causalOrbit_noPositivePeriod
    (positive : 0 < period) :
    CausallyEquivalent
      (causalOrbit patchable initial n)
      (causalOrbit patchable initial (n + period)) -> False
```

Ici l'arithmetique ne sert qu'a etablir `n < n + period`; le temoin causal de
separation reste `d_n`.

### Porte C2

```text
advance est exactement le pas gap-driven existant ;
l'orbite causale est alignee aux deux orbites existantes ;
tout ancien gap est effectivement rememore ;
l'equivalence est extensionnelle et ne contient aucun indice temporel ;
la memoire seule est deja non equivalente entre deux etapes distinctes ;
le non-retour causal utilise uniquement absence presente + presence future ;
les audits sont vides.
```

## 6. Module 3 - Recurrence visible et separation causale

### 6.1 Observation autorisee

Une observation visible doit etre rattachee a une reparation effectivement
memoree :

```lean
structure AuthorizedVisibleObservation
    (state : CausalState patchable initial) where
  sentence : patchable.context.Sentence
  remembered : state.memory.Remembers sentence

def AuthorizedVisibleObservation.project
    (observation : AuthorizedVisibleObservation state) :
    patchable.context.Sentence :=
  observation.sentence
```

La correction visible associee est derivee :

```lean
theorem AuthorizedVisibleObservation.correctAt :
  CorrectAt patchable state.current observation.sentence
```

Ainsi `project` ne projette ni un singleton arbitraire, ni un probe non
autorise. Il oublie une vraie preuve de memoire et retourne la phrase vraiment
observee.

### 6.2 Egalite comportementale constructive

Definir :

```lean
def VisibleSameAt
    (sentence : patchable.context.Sentence)
    (left right : CausalState patchable initial) : Prop :=
  patchable.truthAt left.current sentence <->
    patchable.truthAt right.current sentence
```

Si une phrase est rememoree dans les deux etats, les deux corrections vers
`models sentence` donnent `VisibleSameAt` par transitivite des `Iff`.

```lean
theorem visibleSameAt_of_remembered
    (leftRemembers : left.memory.Remembers sentence)
    (rightRemembers : right.memory.Remembers sentence) :
    VisibleSameAt sentence left right
```

### 6.3 Vue recurrente d'un ancien gap

Pour `k < n`, construire :

```lean
def causalOrbitPastObservation
    (earlier : k < n) :
    AuthorizedVisibleObservation (causalOrbit patchable initial n)
```

avec :

```text
causalOrbitPastObservation(...).project = genericOrbitIndex ... k.
```

Pour `k < n < m`, les observations obtenues dans `S_n` et `S_m` doivent avoir
exactement la meme projection par egalite ordinaire de `Sentence`, et leurs
reponses doivent satisfaire `VisibleSameAt`.

### 6.4 Theoreme simultane final

Creer une structure de resultat lisible :

```lean
structure VisibleRecurrenceWithCausalSeparation
    (left right : CausalState patchable initial) : Prop where
  sentence : patchable.context.Sentence
  leftObservation : AuthorizedVisibleObservation left
  rightObservation : AuthorizedVisibleObservation right
  sameSentence :
    leftObservation.project = rightObservation.project
  sameVisibleResponse :
    VisibleSameAt sentence left right
  leftProjectsToSentence : leftObservation.project = sentence
  rightProjectsToSentence : rightObservation.project = sentence
  memorySeparated : MemoryEquivalent left right -> False
  causallySeparated : CausallyEquivalent left right -> False
```

Theoreme parametrique :

```lean
theorem generic_visibleRecurrence_with_causalNonReturn
    (first : k < n)
    (second : n < m) :
    VisibleRecurrenceWithCausalSeparation
      (causalOrbit patchable initial n)
      (causalOrbit patchable initial m)
```

Le temoin `sentence` doit etre `genericOrbitIndex patchable initial k`.

Ajouter un temoin ferme relatif a n'importe quel contexte patchable :

```lean
def canonical_visibleRecurrence_with_causalNonReturn :
    VisibleRecurrenceWithCausalSeparation
      (causalOrbit patchable initial 1)
      (causalOrbit patchable initial 2)
```

Il utilise le gap de l'etape `0`. Cela montre que la compatibilite entre
repetition visible et non-retour causal n'est pas une simple possibilite
conditionnelle : elle est produite dans toute orbite patchable possedant un
candidat initial.

### 6.5 Package public

Rassembler les declarations principales dans :

```lean
structure GenericVisibleCausalNonRecurrenceTheorem
    (patchable : PatchableArithmeticTarskiContext)
    (initial : patchable.context.Predicate) where
  memorySound : ...
  currentGapAbsent : ...
  oldGapsAccumulated : ...
  memorySeparated : ...
  noCausalReturn : ...
  visibleRecurrence : ...
  everyCandidateIncomplete : ...
```

Le champ `everyCandidateIncomplete` reutilise le theoreme existant. Le package
ne doit contenir aucune hypothese nouvelle.

### Porte C3

```text
l'observation contient une preuve d'autorisation causale ;
la projection retourne un vrai index syntaxique ;
la repetition comportementale est derivee des reparations cumulees ;
le meme couple d'etats est visiblement recurrent et causalement separe ;
un temoin canonique S_1/S_2 est construit pour tout contexte patchable ;
aucune egalite de Prop ni projection constante n'apparait ;
les audits sont vides.
```

## 7. Relation avec la reorientation des usages

Le role logique des composants doit rester explicite :

```text
le mismatch courant
  -> interdit que le gap courant soit deja une obligation reparee ;

la reparation locale
  -> inscrit ce gap dans l'etat suivant ;

la preservation hors index
  -> maintient toutes les obligations anciennes ;

la memoire positive
  -> rend ces obligations comparables entre etats ;

la dynamique relaxed usage existante
  -> certifie que l'extension est bien le pas causal autorise par le gap.
```

La reorientation contextuelle ne doit donc pas etre ajoutee comme axiome du
nouveau theoreme. Elle est deja realisee par :

```text
tarskiPatchAdvance ;
tarskiPatchGapDrivenDynamicSystem ;
tarskiPatchNext_eq_nextPredicate ;
TarskiIntrinsicGapDrivenStateChange.
```

Le nouveau module prouve que `CausalState.advance` est cette meme transition,
puis conserve son `AlgorithmStep` dans la memoire.

## 8. Ordre d'implementation

Les quatre lots ci-dessous sont termines.

### Lot A - Memoire minimale

1. creer `CausalMemory.lean` ;
2. definir la chaine indexee et `Remembers` ;
3. prouver `correctAt_of_remembers` ;
4. prouver `current_not_remembered` ;
5. ajouter l'adaptateur vers les vues bilaterales ;
6. fermer l'audit C1.

### Lot B - Dynamique causale

1. creer `CausalOrbit.lean` ;
2. definir `CausalState`, `advance`, `causalOrbit` ;
3. prouver l'alignement avec la dynamique existante ;
4. prouver l'accumulation des gaps ;
5. definir les equivalences extensionnelles ;
6. prouver le non-retour causal sans injectivite existante ;
7. fermer l'audit C2.

### Lot C - Recurrence visible

1. creer `VisibleCausalRecurrence.lean` ;
2. definir l'observation autorisee et sa projection ;
3. prouver `visibleSameAt_of_remembered` ;
4. construire les observations temporelles ;
5. prouver le theoreme simultane ;
6. construire le temoin canonique `S_1/S_2` ;
7. fermer l'audit C3.

### Lot D - Integration

1. ajouter le dernier module a `Meta.lean` ;
2. construire `Meta` ;
3. verifier le graphe d'import ;
4. verifier tous les audits ;
5. mettre a jour le statut de ce document avec les noms effectivement livres.

## 9. Audits et commandes de validation

Chaque fichier Lean nouveau se termine par un unique bloc :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms nom.de.la.declaration.principale
/- AXIOM_AUDIT_END -/
```

Les validations minimales sont :

```bash
lake env lean Meta/Tarski/CausalMemory.lean
lake env lean Meta/Tarski/CausalOrbit.lean
lake env lean Meta/Tarski/VisibleCausalRecurrence.lean
lake build Meta
```

Audit des dependances et des raccourcis interdits :

```bash
rg -n "Foundation|FoundationBridge|ConstructivePatchModel" \
  Meta/Tarski/CausalMemory.lean \
  Meta/Tarski/CausalOrbit.lean \
  Meta/Tarski/VisibleCausalRecurrence.lean

rg -n "Classical|propext|Quot\.sound|axiom|sorry|admit|unsafe|noncomputable" \
  Meta/Tarski/CausalMemory.lean \
  Meta/Tarski/CausalOrbit.lean \
  Meta/Tarski/VisibleCausalRecurrence.lean

rg -n "rank|windowFor|actualReducts|terminal|timestamp|generation|\.length" \
  Meta/Tarski/CausalMemory.lean \
  Meta/Tarski/CausalOrbit.lean \
  Meta/Tarski/VisibleCausalRecurrence.lean
```

Audit anti-circularite de la preuve de non-retour :

```bash
rg -n "genericOrbit(Index|Candidate)_injective|genericDynamicOrbitCandidate_injective" \
  Meta/Tarski/CausalOrbit.lean \
  Meta/Tarski/VisibleCausalRecurrence.lean
```

Toute occurrence dans le corps de
`causalOrbit_not_causallyEquivalent_of_lt` ou de ses auxiliaires est
bloquante.

Verifier enfin :

```text
exactement un AXIOM_AUDIT par nouveau fichier ;
le bloc est a la fin du fichier ;
tous les noms imprimes existent ;
chaque #print axioms affiche 'depends on axioms: []' ;
aucune sortie ne mentionne propext, Quot.sound ou Classical.*.
```

## 10. Criteres de non-trivialite scientifique

L'implementation n'est acceptee comme renforcement reel que si les six tests
conceptuels suivants sont simultanement satisfaits.

### N1 - La memoire contient des causes, pas des dates

Chaque noeud retient un `AlgorithmStep` complet. Retirer le gap ou la loi de
preservation doit rendre impossible la preuve de correction cumulative.

### N2 - La nouveaute est prouvee negativement et localement

Le gap courant est absent parce que sa presence donnerait une correction que
son propre point fixe refute. Aucun oracle de fraicheur n'est disponible.

### N3 - L'accumulation est positive

Le gap devient membre par `Or.inl rfl` et reste membre par `Or.inr`. La
contradiction n'est jamais utilisee pour fabriquer la memoire.

### N4 - La separation survit a un quotient observationnel raisonnable

Le theoreme separe les etats modulo comportement visible global et equivalence
extensionnelle de leurs obligations, pas seulement par inegalite de leurs
representations Lean.

### N5 - Le visible repete effectivement quelque chose d'informatif

Les deux etats repondent de la meme facon a une phrase diagonale historique
qu'ils ont tous deux reparee. La projection exhibe cette phrase exacte.

### N6 - Le meme mecanisme produit les deux phenomenes

La recurrence visible et la separation causale portent sur le meme couple
`S_n`, `S_m` et le meme historique de patchs. Elles ne proviennent pas de deux
modeles juxtaposes.

## 11. Dependances avec le micro-noyau arithmetique

Cette couche causale peut etre fermee avant la fin du micro-noyau arithmetique,
car elle est generique sur `PatchableArithmeticTarskiContext`.

Elle ne dispense toutefois pas de la diagonalisation :

```text
elle se passe de Foundation ;
elle ne se passe pas du contexte Tarski patchable ;
elle ne construit pas a elle seule l'instance arithmetique fermee.
```

Quand `BareArithmetic/Patch.lean` et `BareArithmetic/ClosedOrbit.lean` seront
fermes, l'instance arithmetique heritera automatiquement du package causal.
Le raccord final devra etre une definition, sans nouvelle preuve de
non-recurrence specifique a l'arithmetique.

## 12. Definition du succes

Le lot est termine : le depot expose, sans import de `Foundation` dans la
nouvelle chaine, une declaration fermee relative a tout contexte patchable qui
certifie simultanement :

```text
chaque patch conserve un evenement bilateral complet ;
toute obligation rememoree reste correcte ;
le gap courant n'est pas encore rememore ;
le gap courant devient une obligation de tous les etats futurs ;
aucun etat futur n'est causalement equivalent a l'etat courant ;
une observation diagonale passee se repete exactement entre ces etats ;
les reponses visibles a cette observation sont equivalentes ;
chaque candidat reste globalement incomplet.
```

Le claim final pourra alors etre formule sans survente :

> Dans tout contexte de Tarski syntaxiquement patchable, chaque tentative de
> correction locale devient une obligation causale persistante. Une phrase
> deja reparee peut reapparaitre avec exactement le meme comportement visible,
> tandis que l'accumulation des obligations interdit tout retour de l'etat
> causal complet.
