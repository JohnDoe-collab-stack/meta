# Dynamique tarskienne formee

## Objectif

Ce document decrit l'implementation d'une vraie couche dynamique pour Tarski.

La cible n'est pas de renommer le gap statique existant en dynamique. La cible
est de formaliser le processus diagonal comme un retour forme :

```text
fixed point diagonal
+ definition de verite projetee
-> retour diagonal
-> intersection typee
-> interface semantique formee
-> ombre syntaxique visible
-> recovery local
-> stabilite fermee recuperee
```

La version parfaite doit montrer que Tarski n'est pas seulement une obstruction
diagonale statique. Il devient une dynamique de retour : la syntaxe revient sur
le meme code visible, mais ce retour produit une interface formee qui ne se
contracte pas en egalite d'interface.

## Regle de rigueur

Il faut refuser la version faible :

la source dynamique ne peut pas etre l'obstruction Tarski deja produite, et
l'intersection dynamique ne peut pas etre une simple abreviation de cette
obstruction.

Cette version compilerait probablement, mais elle ne ferait que rhabiller le
gap deja produit.

La version a viser est :

```text
Source := donnees diagonales productrices
Intersection := point de contact diagonal entre la verite visible et l'interface
formed := semantic liar
shadow := syntactic liar
sameProjection := rfl
separation := truth_formed + shadow_not_truth
```

Le critere decisif :

```text
L'intersection doit porter la production du gap,
pas seulement le gap deja produit.
```

## Etat actuel du code

Le Core dynamique attend :

```lean
FormedDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
```

Un retour dynamique localement recupere doit fournir :

```lean
formedReturn : FormedDynamicReturn complete branch Source
formed : InterfaceWitness Interface WitnessOf
realizes :
  RealizesInterface
    (strongTerminalCycleFromIntersection
      complete
      coherence
      formedReturn.intersection)
    formed.interface
localRecovery : LocalProjectiveRecovery Interface Visible project RepairOf
localRecovery_sameInterface :
  localRecovery.formed = formed.interface
```

Le Tarski statique fournit deja :

```lean
TarskiDiagonalFixedPoint
ExactProjectedTruthDefinition
TarskiDiagonalObstruction
TarskiDiagonalObstruction.ofFixedPointAndExactProjectedTruthDefinition
TarskiDiagonalObstruction.localRecovery
TarskiDiagonalObstruction.localTruthGapRecovery
```

La nouvelle couche doit relier ces deux mondes sans faire remonter Tarski dans
`Meta/Core`.

## Fichier

La couche est portee par :

```text
Meta/Tarski/DynamicReturn.lean
```

Imports :

```lean
import Meta.Core.OrderGap
import Meta.Tarski.ReferentialOrder
```

Raison :

`Meta.Core.OrderGap` expose aussi les consequences d'ordre pour les retours
dynamiques. `Meta.Tarski.ReferentialOrder` fournit deja le gap Tarski comme
longueur referentielle enrichie et comme ligne d'ordre visible.

`Meta.lean` expose aussi :

```lean
import Meta.Tarski.DynamicReturn
```

Position recommandee : apres `Meta.Tarski.ReferentialOrder`.

## Objets Lean

### 1. Source diagonale

La source ne doit pas etre le gap final. Elle doit etre la paire qui produit le
gap :

```lean
structure TarskiDiagonalReturnSource
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  fixedPoint :
    TarskiDiagonalFixedPoint Sentence TruthAt Holds
  projectedDefinition :
    ExactProjectedTruthDefinition
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds)
      TruthAt
```

Lecture :

```text
source = le retour diagonal avant extraction du gap
```

### 2. Donnee backward typable

`ExactProjectedTruthDefinition` est une proposition. Or
`BidirectionalCompleteness.Backward` attend un `Type`. Il ne faut donc pas
utiliser directement :

```lean
Backward branch :=
  ExactProjectedTruthDefinition ...
```

Forme recommandee :

```lean
structure TarskiProjectedDefinitionData
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  marker : Unit := ()
  projectedDefinition :
    ExactProjectedTruthDefinition
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds)
      TruthAt
```

Le champ `marker` ne porte pas de contenu mathematique. Il force simplement la
donnee a vivre dans `Type` plutot que dans `Prop`.

Comme `Forward` vit au niveau du type des phrases, le `Backward` devra ensuite
etre releve au meme univers par `ULift`.

### 3. Branche dynamique

Pour eviter une branche artificiellement vide, la branche doit garder le type
de phrases et les predicats concernes.

Option envisagee mais non retenue pour la premiere implementation :

```lean
structure TarskiDynamicBranch where
  Sentence : Type u
  TruthAt : Sentence -> Prop
  Holds : Sentence -> Prop
```

Mais cette structure porte des champs de types dependants. Il faudra verifier
si l'inference Lean reste confortable.

Option plus simple et probablement plus robuste :

```lean
inductive TarskiDynamicBranch
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  | diagonal : TarskiDynamicBranch Sentence TruthAt Holds
```

Cette option garde la branche specialisee a un contexte Tarski fixe, tout en
evitant une branche singleton totalement anonyme.

Option retenue pour la premiere implementation :

```lean
inductive TarskiDynamicBranch
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  | diagonal : TarskiDynamicBranch Sentence TruthAt Holds
```

Cette option a ete testee dans un squelette Lean temporaire.

### 4. Intersection diagonale

L'intersection doit porter la source et le gap produit par cette source.

```lean
structure TarskiDiagonalIntersection
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) where
  obstruction :
    TarskiDiagonalObstruction
      Sentence
      (TarskiInterface Sentence)
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds)
  obstruction_eq :
    obstruction =
      TarskiDiagonalObstruction.ofFixedPointAndExactProjectedTruthDefinition
        source.fixedPoint
        source.projectedDefinition
```

Point important :

```text
L'intersection n'est pas seulement le gap.
Elle garde la source et certifie que le gap est produit par la source.
```

Une simple abreviation de l'obstruction perdrait la provenance. La structure
avec `obstruction_eq` garde au contraire le fait que l'obstruction est produite
par la source diagonale.

### 5. Completeness dynamique

Il faut instancier :

```lean
BidirectionalCompleteness Branch
```

Pour un contexte Tarski fixe, la branche peut etre :

```lean
TarskiDynamicBranch Sentence TruthAt Holds
```

Les composants pourraient etre :

```lean
Complete branch :=
  TarskiDiagonalReturnSource Sentence TruthAt Holds

Forward branch :=
  TarskiDiagonalFixedPoint Sentence TruthAt Holds

Backward branch :=
  ULift.{u, 0}
    (TarskiProjectedDefinitionData Sentence TruthAt Holds)

Intersection branch :=
  Sigma fun source =>
    TarskiDiagonalIntersection source
```

Mappings :

```lean
forwardOfComplete source := source.fixedPoint
backwardOfComplete source :=
  ULift.up
    { marker := ()
      projectedDefinition := source.projectedDefinition }
intersectionOfComplete source :=
  ⟨source, producedIntersection source⟩
completeOfIntersection intersection :=
  intersection.1
```

Avec ce choix, les round trips sont substantiels mais simples :

```lean
completeOfIntersection (intersectionOfComplete source) = source
intersectionOfComplete (completeOfIntersection intersection) = intersection
```

Le deuxieme round trip a ete teste dans un squelette Lean temporaire. Il est
gerable avec un lemme canonique :

```lean
theorem tarskiIntersectionCanonical
    (intersection : TarskiDiagonalIntersection source) :
    tarskiDiagonalIntersectionOfSource source = intersection := by
  cases intersection with
  | mk obstruction obstruction_eq =>
      cases obstruction_eq
      rfl
```

La preuve repose sur le fait que l'intersection transporte explicitement
`obstruction_eq`.

### 6. Production de l'intersection

Definition :

```lean
def tarskiDiagonalIntersectionOfSource
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    TarskiDiagonalIntersection source :=
  { obstruction :=
      TarskiDiagonalObstruction.ofFixedPointAndExactProjectedTruthDefinition
        source.fixedPoint
        source.projectedDefinition
    obstruction_eq := rfl }
```

### 7. Interface formee

L'interface formee doit etre :

```lean
TarskiInterface.semantic source.fixedPoint.liar
```

Le witness peut rester minimal mais doit nommer le role :

```lean
def TarskiDynamicWitness
    {Sentence : Type u}
    (_interface : TarskiInterface Sentence) :
    Type :=
  Unit
```

Puis :

```lean
def tarskiDynamicInterfaceWitness
    (intersection : ...)
    : InterfaceWitness
        (TarskiInterface Sentence)
        (@TarskiDynamicWitness Sentence) :=
  { interface :=
      TarskiInterface.semantic intersection.1.fixedPoint.liar
    witness := () }
```

### 8. Realisation de l'interface

Il faut relier le `StrongTerminalCycleFromIntersection` a l'interface formee.

Forme robuste :

```lean
structure TarskiDynamicInterfaceRealization
    (cycle :
      StrongTerminalCycleFromIntersection complete branch)
    (interface : TarskiInterface Sentence) :
    Type where
  marker : Unit := ()
  realizes :
    interface =
      TarskiInterface.semantic
        cycle.sourceIntersection.1.fixedPoint.liar
```

Mais le chemin exact vers `sourceIntersection.1.fixedPoint.liar` dependra de la
forme concrete de l'intersection.

L'egalite est emballee comme donnee typable, car le Core dynamique attend une
famille `RealizesInterface ... -> Type`, pas une proposition nue.

But :

```text
Le cycle fort ne realise pas une interface arbitraire.
Il realise l'interface semantique du liar de la source diagonale.
```

### 9. Local recovery dynamique

Le `localRecovery` doit venir de l'obstruction produite :

```lean
localRecovery :=
  (intersection.2.obstruction).localRecovery
```

Il faut montrer :

```lean
localRecovery_sameInterface :
  localRecovery.formed = formed.interface
```

Si `obstruction_eq = rfl`, cela devrait etre `rfl` ou un `simp` court.

### 10. Retour dynamique forme

Definition :

```lean
def tarskiFormedDynamicReturn
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    FormedDynamicReturn
      tarskiBidirectionalCompleteness
      TarskiDynamicBranch.diagonal
      (TarskiDiagonalReturnSource Sentence TruthAt Holds) :=
  { source := source
    intersection := ⟨source, tarskiDiagonalIntersectionOfSource source⟩ }
```

### 11. Retour dynamique localement recupere

Definition :

```lean
def tarskiLocallyRecoveredDynamicReturn
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    LocallyRecoveredDynamicReturn
      tarskiBidirectionalCompleteness
      tarskiRoundTripCoherence
      TarskiDynamicBranch.diagonal
      (TarskiDiagonalReturnSource Sentence TruthAt Holds)
      (TarskiInterface Sentence)
      (@TarskiDynamicWitness Sentence)
      TarskiDynamicInterfaceRealization
      Sentence
      (@TarskiInterface.project Sentence)
      (@TarskiTruthRepair (TarskiInterface Sentence)) :=
  ...
```

Cette definition est le centre de la couche.

### 12. Stabilite fermee recuperee

Definition :

```lean
def tarskiLocallyRecoveredClosedStabilityOfDynamicReturn
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    LocallyRecoveredNonProjectiveClosedStabilityFromIntersection ... :=
  locallyRecoveredClosedStabilityOfDynamicReturn
    (tarskiLocallyRecoveredDynamicReturn source)
```

### 13. Consequences ordre/longueur depuis le retour dynamique

Une fois `tarskiLocallyRecoveredDynamicReturn` obtenu, `Meta.Core.OrderGap`
donne gratuitement :

```lean
dynamicReturn_operationalGap
dynamicReturn_structuralGap
dynamicReturn_visibleOrderEquivalent
dynamicReturn_visible_eq_of_partialOrder
dynamicReturn_partialOrder_visible_eq_not_interface_eq
dynamicReturn_not_orderContractive
dynamicReturn_refutes_shortReferentialPresentation
```

Il faudra exposer des aliases Tarski propres :

```lean
tarskiDynamicReturn_operationalGap
tarskiDynamicReturn_structuralGap
tarskiDynamicReturn_visibleOrderEquivalent
tarskiDynamicReturn_visible_eq_of_partialOrder
tarskiDynamicReturn_notOrderContractive
tarskiDynamicReturn_refutesShortPresentation
```

## Architecture

Le sens des imports doit rester :

```text
Meta.Core.*
-> Meta.Tarski.TruthGap
-> Meta.Tarski.GapContraction
-> Meta.Tarski.ReferentialOrder
-> Meta.Tarski.DynamicReturn
-> Meta.Synthesis.*
```

Interdits :

```text
Meta/Core importing Meta/Tarski
Meta/Tarski/DynamicReturn importing Meta/Dynamics observed arithmetic layers
```

## Audit axiomes

Bloc :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalReturnSource
#print axioms Meta.ClosedStabilityTheorem.TarskiProjectedDefinitionData
#print axioms Meta.ClosedStabilityTheorem.tarskiDiagonalIntersectionOfSource
#print axioms Meta.ClosedStabilityTheorem.tarskiIntersectionCanonical
#print axioms Meta.ClosedStabilityTheorem.tarskiBidirectionalCompleteness
#print axioms Meta.ClosedStabilityTheorem.tarskiRoundTripCoherence
#print axioms Meta.ClosedStabilityTheorem.tarskiFormedDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiLocallyRecoveredDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiLocallyRecoveredClosedStabilityOfDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_operationalGap
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_notOrderContractive
/- AXIOM_AUDIT_END -/
```

Statut attendu :

```text
Les donnees source/intersection ne dependent d'aucun axiome.
Les retours dynamiques recuperes dependent de `propext` via
`tarskiRoundTripCoherence`.
```

Exception :

Le pont `FoundationBridge` peut garder ses axiomes externes attendus
`propext`, `Classical.choice`, `Quot.sound`. La couche dynamique Tarski ne
doit pas dependre de `Classical.choice` ni de `Quot.sound`.

## Verification

Commandes :

```text
lake env lean Meta/Tarski/DynamicReturn.lean
lake build
rg -n "import Meta.Tarski|Tarski|Beth|Bell|Tsirelson|arithmetic" Meta/Core
```

Resultats attendus :

```text
Build completed successfully
```

et aucune reference d'instance dans `Meta/Core`.

## Risques techniques

### Egalite de l'intersection

Le principal risque Lean vient du round trip :

```lean
intersectionOfComplete (completeOfIntersection intersection) = intersection
```

Si l'intersection contient des preuves, l'egalite definitionnelle peut echouer.

Le squelette teste montre que la forme recommandee evite ce blocage avec :

```lean
tarskiIntersectionCanonical
```

Si l'implementation finale diverge de cette forme, les solutions possibles,
par ordre de preference, restent :

1. garder une intersection avec source canonique et obstruction produite par
   calcul ;
2. garder les preuves de provenance dans un lemme canonique separe ;
3. en dernier recours, parametrer la coherence comme donnee si elle reste
   constructive et sans axiome.

### Branch singleton trop faible

Une branche singleton peut etre acceptable si le contexte Tarski fixe reste
dans les parametres du type. Elle devient faible seulement si elle efface la
source diagonale.

Critere :

```text
La branche peut etre simple.
La source et l'intersection ne doivent pas l'etre.
```

### Recovery artificiel

Le recovery doit venir de :

```lean
TarskiDiagonalObstruction.ofFixedPointAndExactProjectedTruthDefinition
```

et non d'un gap donne directement par l'utilisateur.

## Version implementee

La version parfaite doit permettre la lecture suivante :

```text
La dynamique tarskienne part d'un retour diagonal producteur :
un fixed point et une definition projetee tentent de refermer la verite
syntaxique sur le meme code visible.

Cette tentative produit une intersection typee : le code visible revient sur
lui-meme, mais sous deux roles d'interface, semantic et syntactic.

Le retour forme l'interface semantic liar, produit son ombre syntactic liar,
porte leur meme projection, conserve leur separation, et recupere localement
l'interface formee.

La stabilite obtenue n'est donc pas l'egalite syntaxique. Elle est la stabilite
fermee d'un retour diagonal forme et non contractible.
```

## Documentation

Documents de presentation :

```text
Docs/PrecisionAudit.md
Docs/GapOperatorPresentation.md
Docs/GapOperatorPresentation.en.md
README.md
```

Formulation sure :

```text
Tarski is now exposed not only as a diagonal operational gap, but as a formed
diagonal return: the projected syntax returns to the same visible code while the
formed semantic interface remains separated from its syntactic shadow.
```

Formulations a eviter : toute lecture qui transformerait Tarski en systeme
temporel, qui ferait du retour dynamique un simple renommage du gap statique,
ou qui presenterait la couche dynamique comme un theoreme de verite independant
des donnees diagonales.

La formulation correcte est :

```text
The dynamic layer internalizes the production of the Tarski gap as a formed
diagonal return and then consumes the abstract dynamic Core.
```
