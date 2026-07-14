# Plan d'implementation du gap causal de Tarski

## Objectif

Le but n'est pas de rendre `TarskiDiagonalReturnSource` habitable comme etat
coherent autonome. Ce serait mathematiquement faux.

Le but est de formaliser explicitement la chaine causale deja presente dans la
preuve :

```text
source candidate complete
  =
  point fixe diagonal
  +
  definition exacte de verite projetee

        cause

trace causale locale
  =
  phrase menteuse
  +
  pole semantique
  +
  pole syntaxique
  +
  projection commune
  +
  passage TruthAt -> Holds
  +
  passage Holds -> non-TruthAt
  +
  non-TruthAt
  +
  Holds
  +
  gap oriente produit

        cause

refutation de la source candidate
```

La source candidate est donc bien refutable. Ce n'est pas un defaut. Le defaut
actuel est que la causalite interne de cette refutation n'est pas assez visible
dans l'API : le code expose le gap produit, mais ne nomme pas encore chaque
etape qui montre que la candidate syntaxique fabrique elle-meme son obstruction.

## Principe a respecter

Il ne faut pas remplacer le gap oriente par un simple mismatch.

Le mismatch local :

```text
not (TruthAt liar <-> Holds liar)
```

est utile, mais il est plus faible que la factorisation actuelle de la preuve de
Tarski sous hypothese de definition exacte.

La source candidate donne davantage :

```text
TruthAt liar -> Holds liar
Holds liar -> not TruthAt liar
not TruthAt liar
Holds liar
```

Donc elle produit un gap oriente :

```text
formed := semantic liar
shadow := syntactic liar

sameSyntax := rfl

truth_formed :
  Holds liar

shadow_not_truth :
  TruthAt liar -> False
```

Cette orientation ne doit pas etre perdue.

## Ce qui existe deja

Dans `Meta/Tarski/TruthGap.lean` :

```lean
TarskiDiagonalFixedPoint
TarskiTruthDefinition
ExactProjectedTruthDefinition
TarskiInterface
TarskiDiagonalObstruction
TarskiDiagonalObstruction.ofFixedPointAndExactProjectedTruthDefinition
TarskiDiagonalObstruction.exactProjectedTruthDefinition_refutedByProjectiveCorollary
```

Dans `Meta/Tarski/DynamicReturn.lean` :

```lean
TarskiDiagonalReturnSource
tarskiProducedObstruction
TarskiDiagonalIntersection
tarskiBidirectionalCompleteness
tarskiRoundTripCoherence
tarskiLocallyRecoveredDynamicReturn
tarskiDynamicReturn_operationalGap
tarskiDynamicReturn_structuralGap
```

La structure actuelle est correcte comme factorisation de la refutation :

```text
Complete  := point fixe + definition projetee candidate
Forward   := point fixe
Backward  := definition projetee candidate
Intersection := source + obstruction produite
```

Mais la causalite interne reste trop implicite.

## Ce qui ne doit pas etre fait

Ne pas remplacer :

```lean
TarskiDiagonalObstruction
```

par :

```lean
LocalTruthMismatch
```

comme couche principale. Le mismatch est une projection plus faible du processus.

Ne pas remplacer la source candidate par le point fixe seul dans le retour
dynamique existant. Le retour dynamique actuel formalise la refutation d'une
source complete candidate. Changer `Complete` en point fixe seul changerait le
theoreme.

Ne pas introduire une causalite conditionnelle du type :

```text
si un patch externe existe, alors...
```

La causalite doit etre interne :

```text
source candidate
-> trace causale
-> gap produit
-> refutation
```

Ne pas cacher le contenu dans :

```lean
Unit
```

pour les nouvelles couches causales. Les anciennes definitions minimales peuvent
rester pour compatibilite, mais la nouvelle API causale doit porter des champs
mathematiques.

## Separation anti-trivialisation

La trace causale ne doit pas contenir directement un champ :

```lean
source_refuted : False
```

sinon toute structure qui porte la trace pourrait ensuite fabriquer ses champs
par `False.elim`. Meme si le constructeur canonique est ecrit proprement, l'API
deviendrait trop permissive.

Il faut donc separer strictement :

```text
production causale
  = donnees substantielles du gap, sans champ False

consommation refutative
  = theorem separe qui consomme la production et la source candidate
```

La regle d'implementation est :

```text
les witness, repairs, local recoveries et dynamic returns portent la production,
pas la refutation.
```

La refutation existe comme consequence terminale :

```lean
theorem tarskiCausalTrace_refutesSource
    (trace : TarskiCausalTrace source) :
    False
```

mais elle ne doit pas etre un champ de la trace.

## Nouvelle structure principale

Ajouter dans `Meta/Tarski/DynamicReturn.lean` :

```lean
structure TarskiCausalTrace
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) where
  index : Sentence

  index_eq_liar :
    index = source.fixedPoint.liar

  formed : TarskiInterface Sentence
  shadow : TarskiInterface Sentence

  formed_is_semantic :
    formed = TarskiInterface.semantic index

  shadow_is_syntactic :
    shadow = TarskiInterface.syntactic index

  formed_projects :
    (@TarskiInterface.project Sentence) formed = index

  shadow_projects :
    (@TarskiInterface.project Sentence) shadow = index

  sameSyntax :
    (@TarskiInterface.project Sentence) formed =
      (@TarskiInterface.project Sentence) shadow

  candidate_correct_at_formed :
    TruthAt index <->
      TarskiInterface.truth TruthAt Holds formed

  candidate_correct_at_shadow :
    TruthAt index <->
      TarskiInterface.truth TruthAt Holds shadow

  truth_to_holds :
    TruthAt index -> Holds index

  holds_to_not_truth :
    Holds index -> TruthAt index -> False

  shadow_not_truth :
    TarskiInterface.truth TruthAt Holds shadow -> False

  truth_formed :
    TarskiInterface.truth TruthAt Holds formed

  separated :
    formed = shadow -> False

  obstruction :
    TarskiDiagonalObstruction
      Sentence
      (TarskiInterface Sentence)
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds)

  obstruction_eq_reconstructed :
    obstruction =
      { formed := formed
        shadow := shadow
        sameSyntax := sameSyntax
        truth_formed := truth_formed
        shadow_not_truth := shadow_not_truth }

  obstruction_eq :
    obstruction = tarskiProducedObstruction source
```

Lecture des champs :

```text
candidate_correct_at_formed
  vient de source.projectedDefinition.correct (semantic liar)

truth_to_holds
  vient de candidate_correct_at_formed.mp

holds_to_not_truth
  vient de source.fixedPoint.liar_spec.mp

shadow_not_truth
  est le not TruthAt obtenu par diagonalisation

truth_formed
  est Holds liar obtenu par liar_spec.mpr shadow_not_truth

obstruction
  est le gap oriente produit

obstruction_eq_reconstructed
  interdit que le gap porte par la trace soit decoratif :
  il est exactement reconstruit depuis les champs locaux de la trace
```

Cette structure est volontairement redondante. La redondance est ici une vertu :
elle rend la causalite inspectable, au lieu de la cacher dans une preuve compacte.

## Constructeur canonique

Ajouter :

```lean
def tarskiCausalTraceOfSource
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    TarskiCausalTrace source
```

Le constructeur doit suivre l'ordre causal, pas seulement remplir les champs :

```lean
have truth_to_holds :
    TruthAt source.fixedPoint.liar -> Holds source.fixedPoint.liar := ...

have shadow_not_truth :
    TruthAt source.fixedPoint.liar -> False := ...

have truth_formed :
    Holds source.fixedPoint.liar := ...

have obstruction :
    TarskiDiagonalObstruction ... :=
  tarskiProducedObstruction source
```

Critere important : ne pas utiliser `False.elim` pour fabriquer les champs
substantiels. La contradiction finale ne doit pas etre un champ de cette trace.
Le constructeur `tarskiCausalTraceOfSource` ne doit pas appeler
`tarskiDiagonalReturnSource_refuted`,
`exactProjectedTruthDefinition_refutedByProjectiveCorollary` ou
`notProjectedTruthDefinable`. Ces lemmes appartiennent a la consommation
terminale, pas a la production causale.

## Consommation refutative separee

Ajouter ensuite la consommation terminale. La forme principale doit passer par
le gap porte par la trace, sinon la trace causale devient decorative :

```lean
theorem tarskiCausalTrace_refutesSource
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    False :=
  TarskiDiagonalObstruction.notProjectedTruthDefinable
    trace.obstruction
    { truthAt := TruthAt
      correct := source.projectedDefinition.correct }
```

Une preuve directe depuis `source.fixedPoint` et `source.projectedDefinition`
peut rester comme lemme de compatibilite :

```lean
theorem tarskiDiagonalReturnSource_refuted
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    False :=
  TarskiDiagonalObstruction
    .exactProjectedTruthDefinition_refutedByProjectiveCorollary
      source.fixedPoint
      source.projectedDefinition
```

Mais ce lemme direct ne doit pas etre utilise pour remplir les champs de
`TarskiCausalTrace`, ni comme preuve principale de la causalite dynamique. La
chaine causale visee est :

```text
source
-> TarskiCausalTrace
-> trace.obstruction
-> refutation
```

et non :

```text
source
-> refutation directe
-> trace fabriquee apres coup
```

## Projection vers le gap existant

Ajouter :

```lean
def TarskiCausalTrace.toObstruction
    (trace : TarskiCausalTrace source) :
    TarskiDiagonalObstruction
      Sentence
      (TarskiInterface Sentence)
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds) :=
  trace.obstruction
```

Et :

```lean
theorem TarskiCausalTrace.toObstruction_eq_reconstructed
    (trace : TarskiCausalTrace source) :
    trace.toObstruction =
      { formed := trace.formed
        shadow := trace.shadow
        sameSyntax := trace.sameSyntax
        truth_formed := trace.truth_formed
        shadow_not_truth := trace.shadow_not_truth }
```

Et :

```lean
theorem TarskiCausalTrace.toObstruction_eq_produced
    (trace : TarskiCausalTrace source) :
    trace.toObstruction = tarskiProducedObstruction source :=
  trace.obstruction_eq
```

Cela fixe le lien :

```text
trace causale
-> meme obstruction que l'ancienne API
```

Donc les couches existantes `GapContraction`, `ReferentialOrder`, `Beth`, etc.
restent valides.

## Projection vers le mismatch positif

Si `TarskiPositiveDiagonal` et `LocalTruthMismatch` existent dans
`TruthGap.lean`, ajouter une projection depuis la trace :

```lean
def TarskiCausalTrace.toPositiveDiagonal
    (trace : TarskiCausalTrace source) :
    TarskiPositiveDiagonal Sentence TruthAt Holds
```

et :

```lean
def TarskiCausalTrace.toLocalTruthMismatch
    (trace : TarskiCausalTrace source) :
    LocalTruthMismatch Sentence TruthAt Holds :=
  trace.toPositiveDiagonal.localTruthMismatch
```

Lecture :

```text
le mismatch n'est pas le remplacement du gap ;
il est une vue oublieuse de la trace causale.
```

## Witness dynamique non trivial

L'ancienne API :

```lean
def TarskiDynamicWitness (_interface : TarskiInterface Sentence) : Type :=
  Unit
```

peut rester comme couche de compatibilite minimale.

Mais la nouvelle API causale doit ajouter :

```lean
structure TarskiCausalDynamicWitness
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds)
    (interface : TarskiInterface Sentence) where
  trace : TarskiCausalTrace source
  interface_eq_formed :
    interface = trace.formed
```

Ce witness n'est pas trivial :

```text
il porte la trace ;
il lie l'interface formee au pole semantique produit ;
il donne acces au gap, a la projection commune, au truth_formed,
et au shadow_not_truth.
```

## Reparation causale non triviale

L'ancienne API :

```lean
TarskiTruthRepair := Unit
```

peut rester pour les couches existantes, mais elle ne doit plus etre presentee
comme la causalite.

Ajouter :

```lean
structure TarskiCausalRepair
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds)
    (interface : TarskiInterface Sentence) where
  trace : TarskiCausalTrace source

  repairs_formed :
    interface = trace.formed

  recovered : TarskiInterface Sentence

  recovered_eq_formed :
    recovered = trace.formed

  carries_truth_formed :
    TarskiInterface.truth TruthAt Holds recovered
```

Cette reparation n'est pas un patch global de `TruthAt`. Elle est la reparation
locale au sens du cadre :

```text
on recupere le pole forme exact
et on conserve sa verite semantique produite causalement.
```

Elle ne doit pas etre vendue comme une correction algorithmique globale du
predicat syntaxique.

## Local recovery causal

Ajouter :

```lean
def tarskiCausalLocalRecovery
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    LocalProjectiveRecovery
      (TarskiInterface Sentence)
      Sentence
      (@TarskiInterface.project Sentence)
      (TarskiCausalRepair source)
```

Champs attendus :

```lean
formed := trace.formed
shadow := trace.shadow
sameProjection := trace.sameSyntax
separated := trace.separated
repair := { ... trace ... }
recovered := trace.formed
recovered_eq_formed := rfl
```

Critere : le champ `repair` doit contenir la trace. Il ne peut pas etre `()`.

## Retour dynamique causal

Ajouter une version principale causalement explicite :

```lean
def tarskiCausalLocallyRecoveredDynamicReturn
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    LocallyRecoveredDynamicReturn
      (tarskiBidirectionalCompleteness Sentence TruthAt Holds)
      (tarskiRoundTripCoherence Sentence TruthAt Holds)
      TarskiDynamicBranch.diagonal
      (TarskiDiagonalReturnSource Sentence TruthAt Holds)
      (TarskiInterface Sentence)
      (TarskiCausalDynamicWitness source)
      TarskiDynamicInterfaceRealization
      Sentence
      (@TarskiInterface.project Sentence)
      (TarskiCausalRepair source)
```

La version existante `tarskiLocallyRecoveredDynamicReturn` peut rester comme
compatibilite minimale. La documentation doit cependant dire clairement :

```text
tarskiLocallyRecoveredDynamicReturn
  = lecture minimale compatible avec l'ancien core

tarskiCausalLocallyRecoveredDynamicReturn
  = lecture causale principale
```

## Consequences causales a exposer

Ajouter les projections suivantes :

```lean
def tarskiCausalDynamicReturn_operationalGap ...

def tarskiCausalDynamicReturn_structuralGap ...

theorem tarskiCausalDynamicReturn_refutesShortPresentation ...

theorem tarskiCausalDynamicReturn_notOrderContractive ...
```

Ces theoremes doivent reutiliser les theoremes generiques sur
`LocallyRecoveredDynamicReturn`, mais avec le witness et la reparation causale
non triviaux.

Ajouter aussi :

```lean
theorem tarskiCausalTrace_refutesSource
    (trace : TarskiCausalTrace source) :
    False
```

La causalite devient alors visible :

```text
source
-> trace
-> localRecovery
-> dynamicReturn
-> operationalGap
-> refutations generiques
-> refutation terminale de la source candidate
```

## Extracteur arithmetique positif

Dans `Meta/Tarski/TruthGap.lean`, conserver ou ajouter :

```lean
def ArithmeticTarskiContext.explicitTruthCounterexample
    (context : ArithmeticTarskiContext)
    (tau : context.Predicate) :
    { sentence : context.Sentence //
      (
        context.models sentence <->
        context.models (context.applyQuote tau sentence)
      ) -> False }
```

Ce theoreme est indispensable parce qu'il donne la lecture non cachee :

```text
pour chaque candidat tau,
voici la phrase diagonale ou tau echoue.
```

Puis :

```lean
theorem ArithmeticTarskiContext.undefinability_of_truth_via_explicitCounterexample
```

doit etre le corollaire negatif.

## Criteres d'acceptation

L'implementation est acceptable seulement si les points suivants sont vrais.

### Criteres mathematiques

1. `TarskiDiagonalReturnSource` reste la source candidate complete, pas un etat
   coherent autonome.

2. Le code prouve explicitement :

```lean
theorem tarskiDiagonalReturnSource_refuted
    (source : TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    False
```

3. Le code construit explicitement :

```lean
def tarskiCausalTraceOfSource
```

avant de consommer la contradiction.

4. `TarskiCausalTrace` contient au minimum :

```text
index
formed
shadow
sameSyntax
truth_to_holds
holds_to_not_truth
shadow_not_truth
truth_formed
obstruction
obstruction_eq_reconstructed
obstruction_eq
```

5. `TarskiCausalTrace` ne contient aucun champ de contradiction close de type
   `False`. Les champs negatifs locaux comme `shadow_not_truth` ou `separated`
   sont permis parce qu'ils portent une donnee mathematique localisee.

6. La refutation de la source est un theorem separe qui consomme la trace,
   obligatoirement via `trace.obstruction` dans la version causale principale.

7. La trace prouve que `trace.obstruction` est reconstruit depuis ses champs
   locaux. Sans cette egalite, le gap pourrait etre seulement ajoute a cote de
   la trace.

8. Aucun champ substantiel de `TarskiCausalTrace`, `TarskiCausalRepair`,
   `TarskiCausalDynamicWitness` ou `tarskiCausalLocalRecovery` n'est prouve par
   `False.elim`.

9. Le constructeur `tarskiCausalTraceOfSource` n'appelle aucun theorem de
   refutation terminale : ni `tarskiDiagonalReturnSource_refuted`, ni
   `exactProjectedTruthDefinition_refutedByProjectiveCorollary`, ni
   `notProjectedTruthDefinable`.

10. Le gap oriente `TarskiDiagonalObstruction` reste la structure principale de
   la factorisation Tarski.

11. `LocalTruthMismatch` reste une vue oublieuse ou complementaire, pas le
   remplacement du gap oriente.

12. Les nouveaux witness/reparation causaux ne sont pas `Unit`.

13. Aucune formulation du type :

```text
si une reparation externe existe, alors...
```

ne doit servir de fermeture principale.

### Criteres Lean

Chaque fichier Lean modifie doit avoir un unique bloc :

```lean
/- AXIOM_AUDIT_BEGIN -/
...
/- AXIOM_AUDIT_END -/
```

Le bloc doit etre a la fin du fichier.

Les nouvelles declarations principales doivent etre auditees :

```lean
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalTraceOfSource
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalTrace_refutesSource
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace.toObstruction
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace.toObstruction_eq_reconstructed
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalDynamicWitness
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalRepair
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalLocalRecovery
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalLocallyRecoveredDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_operationalGap
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_structuralGap
```

L'audit doit afficher :

```text
does not depend on any axioms
```

pour chaque declaration ajoutee.

Interdits :

```text
axiom
sorry
admit
Classical
propext
Quot.sound
noncomputable
unsafe
```

### Criteres de compilation

Compiler au minimum :

```text
lake env lean Meta/Tarski/TruthGap.lean
lake env lean Meta/Tarski/DynamicReturn.lean
lake env lean Meta/Tarski/GapContraction.lean
lake env lean Meta/Tarski/ReferentialOrder.lean
lake env lean Meta/Synthesis/TarskiBethGap.lean
lake env lean Meta/Synthesis/TarskiBethBellGap.lean
```

`Meta/Tarski/FoundationBridge.lean` est un cas separe : il importe Foundation
et depend deja de principes classiques via le theoreme officiel. Il ne doit pas
etre modifie dans cette implementation sauf decision explicite de l'isoler dans
une couche classique assumee.

## Documentation a mettre a jour apres implementation

Mettre a jour les documents qui parlent de la dynamique Tarski :

```text
Docs/TarskiDynamicReturnPlan.md
Docs/PrecisionAudit.md
Docs/GapOperatorPresentation.md
Docs/GapOperatorPresentation.en.md
README.md
```

Le texte doit distinguer clairement :

```text
gap oriente
  = factorisation de la refutation sous source candidate complete

mismatch local
  = vue positive obtenue depuis le point fixe seul

trace causale
  = chaine explicite source -> gap -> refutation

reparation causale locale
  = recuperation du pole forme produite par la trace
```

## Formulation finale visee

La revendication apres implementation doit etre :

```text
La source candidate de verite exacte n'est pas supposee coherente.
Elle est formalisee comme entree complete a refuter.
Le point fixe et la definition projetee candidate produisent causalement une
trace locale : meme phrase visible, pole semantique, pole syntaxique,
orientation de verite, obstruction projective et refutation de la source.
Cette trace alimente ensuite le retour dynamique, avec witness et reparation
non triviaux, sans cacher la causalite dans Unit.
```

Ce qui reste exclu :

```text
une reparation algorithmique globale de TruthAt ;
une derivation constructive du pont Foundation classique ;
une pretention que la source candidate est habitable comme etat coherent.
```

Ce qui devient etabli :

```text
la preuve de Tarski est refactorisee comme production causale d'un gap
projectif oriente, puis comme consommation dynamique de ce gap par les
theoremes generiques de non-contraction et de non-reconstruction.
```
