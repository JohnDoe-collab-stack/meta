# Contrat mathématique normatif

## 1. Question décidée

Étant donnés un jeu public fini de réparation, un état initial `s₀` et une obligation `g`, décider constructivement :

```text
existe-t-il une stratégie publique finie qui,
pour tout monde concret initialement compatible
et pour toute réponse réalisable,
atteint un état où l’action exigée est déterminée,
réalisable dans le langage de décision,
et obtenue sans violer les invariants de réparation ?
```

Le solveur doit retourner une donnée positive dans les deux cas :

- `WinCertificate s₀ g` : stratégie et preuves de fermeture ;
- `LoseCertificate s₀ g` : région fermée et contre-stratégie de réponses.

Une simple négation de l’existence d’une stratégie n’est pas un certificat négatif suffisant.

## 2. Carriers finis effectifs

Chaque sorte finie doit être portée par une liste canonique sans doublon, une égalité booléenne et les preuves reliant cette égalité à l’égalité propositionnelle.

```lean
structure FiniteCarrier (α : Type u) where
  elements : List α
  nodup : elements.Nodup
  complete : ∀ x : α, x ∈ elements
  eqb : α → α → Bool
  eqb_spec : ∀ x y, eqb x y = true ↔ x = y
```

Le projet peut employer une structure équivalente de la bibliothèque standard si elle conserve :

- une énumération calculable ;
- une preuve de complétude ;
- aucune dépendance à `Classical` ;
- une sérialisation canonique pour les certificats.

Sortes minimales :

- `World` : états concrets possibles ;
- `State` : états publics complets ;
- `Goal` : obligations de décision ;
- `Action` : continuations exigées ;
- `Query` : expériences publiques ;
- `Response` : observations publiques ;
- `Patch` : réparations enregistrées ;
- `Decision` : objets exécutables du langage de décision.

`State` doit inclure toute composante qui influence ultérieurement l’autorisation, la réponse publique, la mémoire, la provenance, la décision ou les invariants. Deux historiques qui autorisent des continuations différentes ne peuvent pas être écrasés dans le même état public.

## 3. Jeu public effectif

L’interface conceptuelle minimale est :

```lean
structure EffectivePublicRepairGame where
  World State Goal Action Query Response Patch Decision : Type

  worldFinite : FiniteCarrier World
  stateFinite : FiniteCarrier State
  goalFinite : FiniteCarrier Goal
  actionFinite : FiniteCarrier Action
  queryFinite : FiniteCarrier Query
  responseFinite : FiniteCarrier Response

  compatibleB : State → World → Bool
  Compatible : State → World → Prop
  compatible_spec : compatibleB s w = true ↔ Compatible s w

  required : Goal → World → Action
  authorizedB : State → Goal → Query → Bool
  Authorized : State → Goal → Query → Prop
  authorized_spec : authorizedB s g q = true ↔ Authorized s g q

  respond : World → Query → Response
  responseRealizableB : State → Query → Response → Bool

  patch : State → Goal → Query → Response → Patch
  advance : State → Goal → Query → Response → State
  decision? : State → Goal → Option Decision
  denoteDecision : Decision → Action

  StateSafe : State → Goal → Prop
  stateSafeB : State → Goal → Bool
  stateSafe_spec : stateSafeB s g = true ↔ StateSafe s g

  PatchValid : State → Goal → Query → Response → Patch → Prop
  ProvenanceValid : State → Goal → Query → Response → Patch → Prop
  IdentityConservative : State → State → Prop
  TransportCoherent : State → State → Prop
  FramePreserved : State → State → Prop
  PriorClosuresRetained : State → State → Prop

  responseRealizable_spec :
    ∀ s q r, responseRealizableB s q r = true ↔
      ∃ w, Compatible s w ∧ respond w q = r
  posteriorContains :
    ∀ s g q r w, Authorized s g q →
      Compatible s w → respond w q = r →
      Compatible (advance s g q r) w
  fiberMonotone :
    ∀ s g q r w, Authorized s g q →
      responseRealizableB s q r = true →
      Compatible (advance s g q r) w → Compatible s w
  patchValid :
    ∀ s g q r, Authorized s g q →
      responseRealizableB s q r = true →
      PatchValid s g q r (patch s g q r)
  patchProvenance :
    ∀ s g q r, Authorized s g q →
      responseRealizableB s q r = true →
      ProvenanceValid s g q r (patch s g q r)
  identityConservative :
    ∀ s g q r, Authorized s g q →
      responseRealizableB s q r = true →
      IdentityConservative s (advance s g q r)
  transportCoherent :
    ∀ s g q r, Authorized s g q →
      responseRealizableB s q r = true →
      TransportCoherent s (advance s g q r)
  framePreservation :
    ∀ s g q r, Authorized s g q →
      responseRealizableB s q r = true →
      FramePreserved s (advance s g q r)
  retainedClosures :
    ∀ s g q r, Authorized s g q →
      responseRealizableB s q r = true →
      PriorClosuresRetained s (advance s g q r)
```

La syntaxe exacte peut être factorisée, mais aucune loi ne peut être remplacée par un commentaire ou un test. `posteriorContains` et `fiberMonotone` définissent une sur-approximation sûre de l’intersection exacte : tous les mondes compatibles avec l’observation sont conservés, et aucun monde extérieur à l’ancienne fibre n’est ajouté.

## 4. Fibres et réponses réalisables

La fibre publique est :

```text
Fiber(s) = { w | compatibleB(s,w) = true }.
```

Une réponse est réalisable si elle provient d’au moins un monde de la fibre :

```text
Realizable(s,q,r)
↔ ∃ w ∈ Fiber(s), respond(w,q) = r.
```

Le calcul booléen `responseRealizableB` doit être prouvé correct et complet vis-à-vis de cette définition.

Les deux postconditions minimales d’une transition sont :

```text
Compatible(s,w) ∧ respond(w,q)=r
→ Compatible(advance(s,g,q,r),w)

et

Compatible(advance(s,g,q,r),w)
→ Compatible(s,w).
```

La première interdit d’éliminer un monde compatible avec la réponse, notamment le monde réel. La seconde impose la monotonie épistémique. Ensemble, elles autorisent une fibre postérieure abstraite située entre le posterior exact et l’ancienne fibre.

Le mode exact exige l’équivalence :

```text
Compatible(advance(s,g,q,r), w)
↔ Compatible(s,w) ∧ respond(w,q)=r.
```

Le mode sur-approximatif peut conserver des mondes dont la réponse aurait différé, mais jamais éliminer un monde compatible avec la réponse ni ajouter un monde extérieur à l’ancienne fibre. Les théorèmes nécessitant l’exactitude doivent porter explicitement l’hypothèse `ExactPosteriorCompiler`.

## 5. Cible d’action certifiée

L’action-suffisance seule est :

```text
ActionSufficient(s,g)
↔ ∀ w₁ w₂,
    Compatible(s,w₁) → Compatible(s,w₂) →
    required(g,w₁) = required(g,w₂).
```

Elle ne suffit pas si le langage de décision ne peut pas exprimer l’action déterminée. La cible finale est :

```text
CertifiedTarget(s,g)
↔ Nonempty(Fiber(s))
 ∧ ActionSufficient(s,g)
 ∧ ∃ d, decision?(s,g)=some d
      ∧ ∀ w∈Fiber(s), denoteDecision(d)=required(g,w)
 ∧ StateSafe(s,g).
```

Le booléen `targetB` doit être accompagné de :

```lean
targetB_spec : targetB s g = true ↔ CertifiedTarget s g
```

La non-vacuité interdit de déclarer suffisante une fibre vide.

## 6. Requête jouable et prédécesseur public contrôlable

Une requête jouable est autorisée et possède au moins une réponse réalisable :

```text
Playable(s,g,q)
↔ Authorized(s,g,q) ∧ ∃ r, Realizable(s,q,r).
```

Pour un ensemble `X` d’états publics, un état est prédécesseur contrôlable si une requête jouable conduit dans `X` pour toute réponse réalisable :

```text
CPre_g(X)(s)
↔ ∃ q,
    Playable(s,g,q)
  ∧ ∀ r, Realizable(s,q,r)
           → advance(s,g,q,r) ∈ X.
```

La clause d’existence d’une réponse réalisable est obligatoire. Elle empêche de gagner par une requête sans branche concrète.

Le témoin de requête doit être extrait par parcours de `queryFinite.elements`. Le `∀ r` doit être décidé par parcours de `responseFinite.elements`.

## 7. Point fixe gagnant

Définir :

```text
W₀(g)     = { s | CertifiedTarget(s,g) }
Wₙ₊₁(g)  = Wₙ(g) ∪ CPre_g(Wₙ(g)).
```

Le calcul utilise un vecteur booléen indexé par l’énumération complète des états. Il itère au plus `|State|` ajouts stricts, puis vérifie explicitement la stabilité.

Le nombre d’itérations n’est pas une hypothèse fournie par l’utilisateur. Il est dérivé de l’énumération intrinsèque du jeu. Il ne doit apparaître ni comme `rank`, ni comme fenêtre externe, ni comme pont terminal ajouté au théorème.

Notations :

```text
Winning_g = μX. (Target_g ∪ CPre_g(X))
Losing_g  = State \\ Winning_g.
```

## 8. Certificat gagnant

Un certificat gagnant contient :

- l’état et l’obligation racines ;
- pour chaque nœud non terminal, une requête jouable ;
- exactement une branche pour chaque réponse réalisable ;
- la transition publique calculée ;
- le patch, la provenance et les preuves de sécurité ;
- une feuille portant une décision correcte ;
- une preuve que tout chemin est fini.

Le terme de finitude est extrait de la première couche gagnante du nœud : chaque enfant appartient à une couche strictement antérieure. Cette couche est un artefact calculé par le solveur, pas une donnée logique exigée de l’environnement.

Le certificat sérialisé ne contient pas nécessairement les preuves Lean. Un vérificateur exécutable recalcule les prédicats ; le théorème Lean relie l’acceptation du vérificateur à `CertifiedRepairableAt`.

## 9. Certificat perdant

Le complément du point fixe fournit une obstruction positive :

```text
LoseCertificate(s,g) :=
  s ∈ Losing_g
  ∧ (∀ t∈Losing_g, ¬CertifiedTarget(t,g))
  ∧ (∀ t∈Losing_g, ∀ q,
       Playable(t,g,q)
       → ∃ r, Realizable(t,q,r)
             ∧ advance(t,g,q,r) ∈ Losing_g).
```

Il représente une contre-stratégie : quelle que soit la requête publique choisie, une réponse réalisable maintient le processus dans une région sans décision certifiée.

Le certificat négatif ne dit pas que le problème est impossible avec de nouveaux capteurs, un autre langage de réparation ou une autre abstraction. Il prouve l’impossibilité relative au jeu public déclaré.

## 10. Théorèmes obligatoires du cœur

### T1 — calcul du prédécesseur

```lean
cpreB_correct : cpreB game g X s = true ↔ ControllablePre game g X s
```

### T2 — monotonie

```lean
cpre_mono : X ⊆ Y → CPre game g X ⊆ CPre game g Y
```

### T3 — stabilisation finie

```lean
winningIteration_stabilizes :
  pointwiseEqual
    (iterateWinning game g game.stateFinite.elements.length)
    (iterateWinning game g (game.stateFinite.elements.length + 1))
```

Une égalité point par point des vecteurs booléens ou des listes canoniques est requise afin de ne dépendre ni de `propext` ni d’extensionalité classique.

### T4 — correction gagnante

```lean
solver_win_sound :
  solve game s g = .win cert → CertifiedRepairableAt game s g
```

### T5 — complétude gagnante

```lean
solver_win_complete :
  CertifiedRepairableAt game s g →
  ∃ cert, solve game s g = .win cert
```

La définition indépendante de `CertifiedRepairableAt` doit quantifier les arbres publics finis ; elle ne peut pas être définie par `solve = win`.

### T6 — correction perdante

```lean
solver_lose_sound :
  solve game s g = .lose cert → ¬ CertifiedRepairableAt game s g
```

### T7 — complétude perdante

```lean
solver_lose_complete :
  (¬ CertifiedRepairableAt game s g) →
  ∃ cert, solve game s g = .lose cert
```

Dans le noyau constructif, préférer la forme positive totale :

```lean
solve_total : WinCertificate game s g ⊕ LoseCertificate game s g
```

puis dériver les corollaires propositionnels décidables.

### T8 — caractérisation décidable

```lean
certifiedRepairable_iff_winningFixedPoint :
  CertifiedRepairableAt game s g ↔ WinningMember game s g
```

### T9 — validité de l’obstruction

```lean
losing_region_closed :
  LosingMember game s g →
  ∀ q, Playable s g q →
  ∃ r, Realizable s q r ∧ LosingMember game (advance s g q r) g
```

### T10 — conservation le long de toute stratégie gagnante

```lean
winningStrategy_preserves :
  AcceptedWinCertificate game s g cert →
  EveryExecutedPathPreservesDeclaredClosures game cert
```

## 11. Indiscernabilité adaptative : place exacte

L’indiscernabilité est définie par égalité de toutes les transcriptions publiques produites par toutes les stratégies autorisées. Elle sert au no-go et aux comparaisons, mais elle ne doit pas être présentée comme l’unique caractérisation sans conditions supplémentaires.

En contexte dynamique, l’homogénéité des classes d’observation peut ne pas suffire si :

- les requêtes discriminantes ne sont jamais autorisées depuis certains états ;
- une transition sûre ne peut pas représenter le posterior ;
- le langage de décision ne réalise pas l’action déterminée ;
- un verrou de contexte crée une région perdante malgré une séparation abstraite possible.

Le théorème principal est donc le point fixe de jeu. Le corollaire :

```text
réparabilité
↔ homogénéité d’action des classes adaptatives
```

n’est autorisé que sous des hypothèses explicites de disponibilité persistante, fermeture des états, exactitude postérieure et complétude de décision. Un contre-modèle doit montrer que la suppression de chacune de ces hypothèses invalide le corollaire.

## 12. Mesures d’action et diagnostic

La mesure de conflit :

```text
μAction(s,g)
= nombre de paires de mondes compatibles
  exigeant des actions différentes.
```

Elle doit satisfaire :

```text
μAction(s,g)=0 ↔ ActionSufficient(s,g)
```

Elle reste utile pour les diagnostics, les séparateurs et les comparaisons avec l’identification complète. Elle ne remplace pas le point fixe : une requête préparatoire peut conserver temporairement `μAction` tout en changeant le contexte d’autorisation et en étant indispensable à une stratégie gagnante.

## 13. Optimalité de coût

Après T1–T10, ajouter un coût naturel non négatif :

```text
queryCost : State → Goal → Query → Nat
```

Pour une stratégie, distinguer :

- coût pire cas : maximum sur les branches réalisables ;
- profondeur pire cas ;
- nombre de requêtes ;
- coût attendu, uniquement si une distribution certifiée est fournie.

Objectif primaire : minimiser le coût pire cas parmi les stratégies certifiées gagnantes.

Équation de Bellman finie :

```text
V(s)=0                                      si Target(s)
V(s)=min_q [cost(s,q)+max_r V(advance(s,q,r))]
                                             si gagnant non terminal.
```

Le minimum porte seulement sur les requêtes dont toutes les branches réalisables restent gagnantes et progressent dans une solution finie. Utiliser `Option Nat` ou un type constructif explicite pour l’infini ; ne pas importer une complétion classique.

Théorèmes :

```lean
optimal_sound : emittedCost cert = worstCaseCost cert
optimal_lower_bound : ∀ other, ValidWin other → emittedCost cert ≤ worstCaseCost other
optimal_attained : ValidWin cert
```

## 14. Contrat de transfert depuis un latent appris

Le réseau n’est jamais une source de preuve. Il propose :

- un identifiant d’état public abstrait ;
- éventuellement une fibre ou un masque de mondes ;
- des logits de requête et d’action ;
- un paquet de preuves calculables : historique, observations, transitions et hachages.

Un vérificateur indépendant accepte seulement si le paquet satisfait :

```text
ConcreteHistorySound
∧ AbstractStateRecognized
∧ ConcretePosterior ⊆ AbstractFiber
∧ PublicTransitionConsistent
∧ DeclaredClosuresPreserved
∧ SolverCertificateAccepted.
```

Le théorème de transfert obligatoire est :

```lean
acceptedLearnedCertificate_sound :
  checker.accept game concreteHistory learnedPacket = true →
  ∀ concreteWorld,
    ConsistentWithHistory concreteWorld concreteHistory →
    ExecutedDecision learnedPacket = required goal concreteWorld
    ∧ PreservedClosures concreteHistory learnedPacket
```

Le système peut s’abstenir. La garantie porte sur les cas acceptés ; la couverture est une quantité empirique rapportée séparément.

Complétude relative facultative mais fortement visée : si l’abstraction proposée est saine, fermée par transition, complète pour les décisions et dans la région gagnante, alors le vérificateur accepte le certificat canonique du solveur.

## 15. Extensions de robustesse

### 15.1 Réponses non déterministes adversariales

Remplacer `respond` par une relation finie `MayRespond`. Le prédécesseur universel quantifie toutes les réponses autorisées par la relation. Correction et complétude deviennent celles d’un jeu fini adversarial.

### 15.2 Bruit probabiliste

Introduire séparément des distributions finies rationnelles normalisées. Les résultats doivent annoncer :

- probabilité d’erreur ;
- niveau de confiance ;
- coût espéré ou risque ;
- hypothèses de calibration.

Une probabilité élevée ne doit jamais être exposée par l’API comme un `WinCertificate` certain.

### 15.3 Abstraction continue

Un environnement continu peut être traité uniquement via un morphisme vers un jeu fini avec preuve de simulation saine. La garantie concrète dépend explicitement de cette preuve.

## 16. Contre-modèles obligatoires

Au moins un modèle fini minimal pour chacun des échecs suivants :

1. deux mondes, même transcription adaptative, actions requises différentes ;
2. requête ponctuellement non discriminante qui débloque ensuite une requête discriminante ;
3. séparation informationnelle disponible mais posterior non représentable ;
4. posterior exact mais décision non exprimable ;
5. fibre réduite mais ancienne clôture invalidée par modification du candidat ;
6. requête sans réponse réalisable donnant un faux gain si la non-vacuité est omise ;
7. classe d’observation homogène mais région perdante due à l’autorisation ;
8. action déterminée avant identification complète du monde ;
9. abstraction apprise non saine rejetée par le vérificateur ;
10. certificat négatif cessant d’être valide lorsqu’une nouvelle requête est ajoutée.

Chaque contre-modèle doit compiler, exécuter le solveur et vérifier le résultat attendu.

## 17. Contraintes constructives non négociables

Tous les fichiers Lean doivent :

- ne déclarer aucun axiome ;
- ne dépendre ni de `Classical`, ni de `propext`, ni de `Quot.sound` ;
- ne pas utiliser une forme déguisée de choix classique pour extraire une requête ;
- ne pas remplacer la terminaison par un rang externe ou une fenêtre supposée ;
- calculer les témoins par les énumérations finies internes ;
- terminer par un unique bloc `AXIOM_AUDIT` portant sur les déclarations principales du fichier.

Le théorème central n’est accepté que si `#print axioms` affiche une liste vide pour le solveur total, la correction, la complétude, l’obstruction et le transfert appris.
