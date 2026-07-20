# Architecture Lean, solveur et certificats

## 1. Principes d’architecture

L’implémentation suit six séparations obligatoires :

1. sémantique propositionnelle vs calcul booléen ;
2. arbre public abstrait vs certificat sérialisé ;
3. correction vs complétude ;
4. solveur non pondéré vs optimisation de coût ;
5. noyau exact vs abstraction apprise ;
6. preuve Lean vs vérificateur indépendant.

Le code ne doit pas commencer par l’API neuronale. L’ordre obligatoire est : modèle fini, prédécesseur, point fixe, certificats, caractérisation, coût, transfert appris.

## 2. Dépendances autorisées

- Lean 4 et une version gelée de Mathlib ;
- structures finies constructives déjà présentes si leur audit est propre ;
- bibliothèque de sérialisation hors noyau, sans l’utiliser pour les théorèmes ;
- Python ou Rust pour l’énumérateur et le vérificateur croisé ;
- PyTorch pour la campagne apprise, après le noyau.

Interdits dans le noyau :

- solveur SMT admis comme oracle de preuve ;
- `native_decide` sans audit de sa chaîne de confiance dans les déclarations centrales ;
- axiomes, `Classical`, `propext`, `Quot.sound` ;
- extraction d’un témoin à partir d’une négation non constructive ;
- résultat supposé de terminaison fourni par l’utilisateur.

## 3. Graphe de modules Lean

```text
FiniteCarrier
     |
     v
PublicGame -----> KnowledgeState -----> ExactPosterior
     |                  |                    |
     v                  v                    |
Target -----------> Predecessor <------------+
                         |
                         v
                    FixedPoint
                    /        \
                   v          v
              Strategy    Obstruction
                   \          /
                    v        v
                 Characterization
                         |
                  +------+-------+
                  v              v
             CostOptimal    LearnedTransfer
                  |              |
                  +------+-------+
                         v
                    Validation
```

Aucun cycle d’import n’est permis.

## 4. Modules et obligations

### 4.1 `FiniteCarrier.lean`

Déclarations principales :

- `FiniteCarrier` ;
- `allB`, `anyB`, `find?` et leurs spécifications ;
- ensemble fini canonique représenté par vecteur booléen ou liste normalisée ;
- inclusion, union, différence, appartenance ;
- cardinalité calculée ;
- lemme : inclusion stricte implique cardinalité strictement croissante ;
- lemme de stabilisation d’une chaîne croissante sur un carrier fini.

Décision : utiliser un vecteur booléen indexé par `elements` pour le point fixe. Une liste normalisée peut être exposée à la sérialisation, mais ne doit pas porter la preuve principale d’égalité extensionnelle.

Tests : carriers vides, singleton, éléments permutés, égalité booléenne défectueuse rejetée au typage.

Audit final minimal : stabilisation et spécification de `find?`.

### 4.2 `PublicGame.lean`

Déclarations :

- `EffectivePublicRepairGame` ;
- prédicats sémantiques `Compatible`, `Authorized`, `Realizable` ;
- calculs booléens associés ;
- `advance`, `patch`, provenance et invariants ;
- lois de monde réel et de posterior sûr ;
- représentation du langage de décision.

Le module ne définit ni gagnant ni stratégie.

Condition de fermeture des états :

```lean
advance_closed :
  s ∈ stateFinite.elements →
  Realizable s q r →
  advance s g q r ∈ stateFinite.elements
```

Même si `complete` rend l’appartenance triviale pour le type complet, ce lemme reste nécessaire si l’énumération représente seulement les états bien formés d’un supertype syntaxique.

### 4.3 `KnowledgeState.lean`

Fournit une instance canonique lorsque l’état public est une fibre finie plus mémoire :

```lean
structure CanonicalKnowledgeState where
  worldMask : BoolVector worldCount
  memory : FiniteMemory
  context : FiniteContext
  wellFormed : WorldMaskWellFormed worldCount worldMask
```

Le masque évite les quotients d’ensembles. Le générateur énumère toutes les valeurs bien formées et prouve la complétude.

Deux constructeurs séparés :

- `exactKnowledgeGame` : le masque après réponse est exactement l’intersection ;
- `safeAbstractGame` : le masque peut être une sur-approximation prouvée.

### 4.4 `Target.lean`

Définit :

- `FiberNonempty` ;
- `ActionSufficient` ;
- `DecisionRealizable` ;
- `SafetyInvariants` ;
- `CertifiedTarget` ;
- `targetB`.

Théorèmes :

- `actionConflictMeasure_eq_zero_iff` ;
- `targetB_correct` ;
- `target_implies_actionSufficient` ;
- `target_decision_correct`.

Le compilateur de décision doit retourner l’objet `Decision`, pas seulement prouver son existence.

### 4.5 `Predecessor.lean`

Types calculés :

```lean
structure ControllableChoice where
  query : Query
  authorized : authorizedB s g query = true
  hasRealizableBranch :
    ∃ r, responseRealizableB s query r = true
  successorsInside :
    ∀ r, responseRealizableB s query r = true →
      targetMask.contains (advance s g query r) = true
```

Fonctions :

- `realizableResponses` ;
- `safeQueryFor?` ;
- `cpreWitness?` ;
- `cpreB`.

La fonction `cpreWitness?` parcourt les requêtes dans un ordre canonique. Son succès fournit directement la requête employée dans le certificat ; son échec montre qu’une requête est non jouable ou fournit une réponse réalisable sortant du masque cible.

Théorèmes : correction et complétude de chaque fonction, puis monotonie de `CPre`.

### 4.6 `FixedPoint.lean`

Représentation :

```lean
structure WinningLayer where
  members : StateMask
  witness : State → Option LayerWitness

inductive LayerWitness (game) (g) (firstLayer : State → Nat) (s : State)
  | target (decision : Decision)
  | predecessor
      (query : Query)
      (playable : Playable s g query)
      (childLayerEarlier :
        ∀ r, Realizable s query r →
          firstLayer (advance s g query r) < firstLayer s)
```

Algorithme :

1. construire la couche cible ;
2. calculer `CPre` du masque courant ;
3. ajouter simultanément les nouveaux états ;
4. enregistrer le premier témoin de chaque nouvel état ;
5. arrêter à stabilité ou après le nombre intrinsèque d’états ;
6. recalculer la stabilité comme condition de validité interne.

La fonction publique :

```lean
computeWinningRegion : Game → Goal → WinningComputation
```

`WinningComputation` contient le masque final, les témoins de couche et la preuve calculable de stabilité.

Théorèmes :

- croissance des couches ;
- correction d’une couche ;
- tout état ajouté possède un témoin ;
- stabilisation ;
- pré-point-fixe et point fixe ;
- minimalité : tout ensemble contenant les cibles et fermé par `CPre` contient la région gagnante.

### 4.7 `Strategy.lean`

Définition indépendante :

```lean
inductive PublicRepairTree (game) (g) (s)
  | leaf : CertifiedTarget s g → PublicRepairTree game g s
  | query :
      (q : Query) → Playable s g q →
      (∀ r, Realizable s q r →
        PublicRepairTree game g (advance s g q r)) →
      PublicRepairTree game g s
```

Si l’indexation dépendante gêne la sérialisation, conserver cette version pour la sémantique et définir séparément un arbre brut vérifié.

Fonctions :

- extraction depuis les témoins de couche ;
- exécution dans un monde concret ;
- transcription publique ;
- coût, profondeur et feuilles ;
- sérialisation canonique sans preuve.

Théorèmes : finitude, correction de toutes les feuilles, rétention du monde réel, conservation des clôtures le long de tous les chemins.

### 4.8 `Obstruction.lean`

Déclarations :

```lean
structure LosingObstruction where
  region : StateMask
  rootInside : region.contains root = true
  noTarget :
    ∀ s, region.contains s = true → targetB s goal = false
  responseChoice : State → Query → Option Response
  responseChoice_spec :
    ∀ s q, region.contains s = true → Playable s goal q →
      ∃ r, responseChoice s q = some r
        ∧ Realizable s q r
        ∧ region.contains (advance s goal q r) = true
```

Le `responseChoice` est construit en recherchant une réponse réalisable qui reste dans le complément. Son existence découle de l’échec du prédécesseur au point fixe, par calcul fini explicite. Les requêtes autorisées mais dépourvues de réponse réalisable ne sont pas jouables et ne figurent pas dans la contre-stratégie.

Théorèmes :

- région sans cible ;
- fermeture adversariale ;
- toute stratégie finie possède une branche restant dans la région ;
- aucune stratégie publique certifiée ne gagne depuis la racine.

La dernière preuve procède par induction sur l’arbre public, pas par contradiction classique.

### 4.9 `Characterization.lean`

Assemble :

```lean
inductive SolveResult (game) (s) (g)
  | win  : SerializableWinCertificate game s g → SolveResult game s g
  | lose : SerializableLoseCertificate game s g → SolveResult game s g
```

Fonctions :

- `solve` ;
- `checkWin` ;
- `checkLose`.

Théorèmes centraux :

- `checkWin_sound` ;
- `checkLose_sound` ;
- `solve_total` ;
- `solve_sound` ;
- `solve_complete` ;
- `certifiedRepairable_iff_winningFixedPoint` ;
- exclusivité de `WIN` et `LOSE` ;
- déterminisme du verdict pour un jeu sérialisé canonique.

La complétude doit partir d’un arbre public fini arbitraire et montrer que sa racine entre dans une couche. Preuve recommandée : induction sur l’arbre ; feuille dans `W₀`, nœud dans `Wₙ₊₁` après majoration constructive des couches finies de ses enfants.

### 4.10 `ExactPosterior.lean`

Établit, pour l’instance canonique :

- exactitude de chaque mise à jour ;
- égalité entre masque final et fibre de transcription ;
- conservation du monde réel ;
- aucune réduction non justifiée ;
- action-suffisance potentiellement avant identification complète.

Ce module fournit le corollaire vers l’indiscernabilité adaptative sous les hypothèses complètes déclarées dans le contrat mathématique.

### 4.11 `CostOptimal.lean`

Deux phases :

1. restriction au sous-graphe gagnant et aux actions propres ;
2. calcul des valeurs et choix canonique du coût minimal.

L’algorithme retenu doit être fini et démontré. Option recommandée : programmation dynamique par couches de budget calculées sur le graphe fini, avec relaxation jusqu’à stabilité et détection des coûts strictement positifs. Si des requêtes de coût nul sont admises, traiter explicitement les cycles nuls avant de revendiquer l’optimalité.

API :

```lean
solveOptimal : Game → State → Goal → SolveResultWithCost
```

Le verdict gagnant/non gagnant doit rester identique à `solve`.

### 4.12 `LearnedTransfer.lean`

Définit uniquement le contrat symbolique entre concret et abstrait :

- `ConcreteTrace` ;
- `LearnedPacket` ;
- `AbstractionCertificate` ;
- `checkLearnedPacket` ;
- `AcceptedLearnedDecision`.

Le fichier n’importe aucune bibliothèque de machine learning. Les tenseurs sont hors noyau ; seul leur résultat sérialisé est vérifié.

Théorèmes : correction d’acceptation, abstention sûre, composition d’épisodes, non-régression et complétude relative sous abstraction adéquate.

### 4.13 `Comparisons/*.lean`

Trois traductions minimales :

1. séquence adaptative distinguante : cible singleton et décision = identité de l’état ;
2. belief state fini exact : état public = sous-ensemble de mondes ;
3. diagnostic actif : `required` = classe de diagnostic ou action corrective.

Pour chaque traduction :

- construction explicite du jeu ;
- préservation des transcriptions ;
- correspondance des stratégies ;
- énoncé exact de ce qui est conservé ;
- exemple de stricte économie quand l’action-suffisance n’exige pas l’identification du monde.

Ne pas formaliser une « irréductibilité » globale sans définition de traduction fidèle et contre-théorème associé.

### 4.14 `Countermodels.lean`

Un namespace par contre-modèle, instances minimales et théorèmes calculés. Chaque exemple doit rendre visible l’hypothèse supprimée.

### 4.15 `Validation.lean`

Imports de tous les modules et agrégation de :

- théorèmes centraux ;
- exemples positifs et négatifs ;
- checks calculés sur petites instances ;
- version de format des certificats.

L’agrégation ne doit jamais être présentée comme augmentant les quantificateurs des théorèmes importés.

## 5. Vérificateurs de certificats

### 5.1 Vérificateur Lean

Les fonctions `checkWin` et `checkLose` sont la référence sémantique. Elles prennent un jeu canonique et un certificat brut. Aucun champ de preuve fourni dans le JSON n’est cru.

### 5.2 Vérificateur indépendant

Implémentation recommandée : Rust sans dépendance lourde, ou Python standard si le temps de développement prime. Il doit :

- parser un schéma versionné ;
- recalculer les réponses réalisables ;
- recalculer toutes les transitions ;
- vérifier l’exhaustivité des branches ;
- vérifier les feuilles et invariants ;
- vérifier la fermeture de la région perdante ;
- refuser champs inconnus en mode strict ;
- refuser doublons, indices hors plage, cycles dans un certificat fini et hachages divergents.

Il n’est pas une nouvelle base de confiance pour la preuve Lean. Il sert à détecter les erreurs d’extraction, de sérialisation et d’intégration.

### 5.3 Format minimal `WIN`

```json
{
  "schema": "repair-win/1",
  "game_sha256": "64-hex",
  "root_state": 0,
  "goal": 0,
  "nodes": [
    {
      "id": 0,
      "state": 0,
      "kind": "query",
      "query": 1,
      "branches": [{"response": 0, "child": 1}]
    },
    {
      "id": 1,
      "state": 2,
      "kind": "leaf",
      "decision": 0
    }
  ],
  "claimed_worst_cost": 1
}
```

### 5.4 Format minimal `LOSE`

```json
{
  "schema": "repair-lose/1",
  "game_sha256": "64-hex",
  "root_state": 0,
  "goal": 0,
  "losing_states": [0, 3],
  "counter_responses": [
    {"state": 0, "query": 1, "response": 0},
    {"state": 3, "query": 1, "response": 1}
  ]
}
```

Le schéma réel est normé dans un fichier JSON Schema séparé lors de l’implémentation. Les exemples n’autorisent pas à omettre une requête jouable : le vérificateur recalcule la couverture complète.

## 6. API de ligne de commande cible

```text
repair-solve solve GAME.json --state S --goal G --out CERT.json
repair-solve verify GAME.json CERT.json
repair-solve enumerate CONFIG.json --out-jsonl CASES.jsonl
repair-solve audit GAME.json --out REPORT.json
repair-solve explain GAME.json CERT.json --out REPORT.md
```

Codes de sortie :

- `0` : commande accomplie et certificat valide ;
- `2` : entrée invalide ;
- `3` : certificat rejeté ;
- `4` : incompatibilité de schéma ;
- `5` : erreur interne ;
- jamais de code distinct pour `WIN` et `LOSE` : le verdict est dans l’objet validé.

## 7. Déterminisme et reproductibilité du solveur

À jeu identique :

- ordre des états = énumération canonique ;
- ordre des requêtes = énumération canonique ;
- ordre des réponses = énumération canonique ;
- premier témoin au coût minimal en ordre lexicographique ;
- sérialisation JSON avec clés triées et sans nombres flottants ;
- hachage SHA-256 sur les octets canoniques ;
- même certificat sur Linux et Windows pour la même version.

Un test golden compare les octets, pas seulement le verdict.

## 8. Performance attendue

Le cœur explicite a une complexité de référence :

```text
O(|State|² · |Query| · |Response|)
```

pour une implémentation naïve avec au plus `|State|` itérations. L’implémentation optimisée peut utiliser une file de nouveaux états et des prédécesseurs inverses, mais seulement après validation de la version simple.

Les certificats gagnants peuvent être des DAG plutôt que des arbres pour partager les sous-stratégies. La sémantique publique reste définie par dépliage fini ; le vérificateur contrôle l’absence de cycle ou une décroissance de couche.

## 9. Audit Lean obligatoire

Chaque fichier `.lean` se termine par exactement :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms nom_declaration_principale
/- AXIOM_AUDIT_END -/
```

ou plusieurs lignes réelles si nécessaire. Aucun texte ne suit le bloc.

Audit global automatisé :

- exactement un début et une fin par fichier ;
- bloc physiquement à la fin ;
- tous les noms existent ;
- absence de `axiom`, `Classical`, `propext`, `Quot.sound` dans le code et les sorties ;
- absence de `sorry`, `admit`, `unsafe` dans le noyau ;
- `lake build` propre depuis une copie fraîche.

## 10. Critère de fin du noyau

Le noyau est fini seulement lorsque :

1. `solve` est total et exécutable ;
2. un résultat `WIN` est converti en arbre public correct ;
3. un résultat `LOSE` interdit constructivement tout arbre public gagnant ;
4. toute stratégie publique gagnante implique `WIN` ;
5. le monde réel et les clôtures déclarées sont préservés sur tous les chemins ;
6. les deux vérificateurs acceptent les certificats valides et rejettent les mutations ;
7. les audits Lean sont vides d’axiomes.

L’optimalité, le latent appris et les expériences ne peuvent pas compenser l’absence d’un de ces sept éléments.
