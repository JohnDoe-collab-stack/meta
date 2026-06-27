# Plan d'implementation : raccord dynamique de la parite separatrice

## Statut

Ce plan a ete applique. Le raccord dynamique transversal est formalise dans
`Meta/Core/DynamicParitySeparation.lean`.

## Objectif

Formaliser le raccord entre :

```text
LocallyRecoveredDynamicReturn
```

et :

```text
parite separatrice minimale
```

deja formalisee dans :

```text
Meta/Core/ParitySeparation.lean
```

Le but n'est pas de redefinir la parite, ni d'ajouter une dynamique
particuliere. Le but est de donner une structure transversale qui dit quand une
dynamique localement recuperee porte effectivement la separation minimale de
regimes.

La formule visee est :

```text
retour dynamique localement recupere
+ lecture de regimes
+ projection visible de parite
= raccord dynamique a la realisation separatrice
```

## Etat actuel du code

### Parite separatrice minimale

Le fichier `Meta/Core/ParitySeparation.lean` fournit deja :

```lean
ParityRegime
ParityVisible
parityProjection
ParityRegimeRepair
parityStructuralTwoPole
parityOperationalTwoPole
parityOppositeStructuralTwoPole
parityOppositeOperationalTwoPole
```

Il fournit aussi les consequences :

```lean
parityOperationalTwoPole_sameVisible
parityOperationalTwoPole_separated
parityOperationalTwoPole_refutes_shortPresentation
parityOperationalTwoPole_not_contractible
parityOperationalTwoPole_noProjectiveReconstruction
```

et les memes consequences pour l'orientation opposee.

Cette couche est volontairement non dynamique : elle fixe la realisation
separatrice minimale du `2` operationnel.

### Dynamique abstraite

Le fichier `Meta/Core/DynamicStability.lean` fournit :

```lean
FormedDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
```

La donnee centrale de `LocallyRecoveredDynamicReturn` est :

```lean
formedReturn
formed
realizes
localRecovery
localRecovery_sameInterface
```

Elle dit qu'une source dynamique produit une intersection typee, que cette
intersection forme une interface, et que cette interface porte une recuperation
locale.

### Dynamique comme two-pole

Le fichier `Meta/Core/DynamicTwoPole.lean` expose deja :

```lean
dynamicReturn_operationalGap
dynamicReturn_structuralGap
dynamicReturn_operationalTwoPole
dynamicReturn_structuralTwoPole
dynamicReturn_refutes_shortReferentialPresentation
```

Donc toute dynamique localement recuperee porte deja un `OperationalTwoPole`
generique.

Ce qui manque n'est pas le two-pole dynamique. Ce qui manque est le raccord
entre ce two-pole dynamique et la realisation separatrice de parite.

## Principe du raccord

Il ne faut pas prouver que toute dynamique arbitraire donne automatiquement une
parite separatrice. Ce serait trop fort et faux : une dynamique peut porter un
gap operationnel sans que ses interfaces soient deja classees par la separation
minimale de regimes.

Il faut plutot introduire une structure positive :

```text
DynamicParitySeparation
```

Cette structure est une dynamique localement recuperee equipee de sa lecture
separatrice interne.

Autrement dit, on ne livre pas un raccord externe optionnel. On livre une
donnee intrinsique :

```text
une dynamique qui porte sa lecture separatrice est deja raccordee
```

## Emplacement retenu

Nouveau fichier :

```text
Meta/Core/DynamicParitySeparation.lean
```

Imports :

```lean
import Meta.Core.DynamicTwoPole
import Meta.Core.ParitySeparation
```

Raison :

* le fichier depend de la dynamique abstraite ;
* il depend de la realisation separatrice minimale ;
* il ne depend pas de l'arithmetique ;
* il ne depend pas de Tarski, Bell, Beth, ni des instances observees ;
* il reste dans `Core` parce qu'il exprime un raccord transversal.

Integration dans `Meta.lean` :

```lean
import Meta.Core.DynamicTwoPole
import Meta.Core.DynamicParitySeparation
import Meta.Core.OrderGap
```

## Definition principale

La structure doit etre generique sur toute dynamique localement recuperee :

```lean
structure DynamicParitySeparation
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf) :
    Type (max u v w x y z r s a) where
  regimeOf : Interface -> ParityRegime
  visibleOf : Visible -> ParityVisible
  parityTwoPole :
    OperationalTwoPole
      ParityRegime
      ParityVisible
      parityProjection
      ParityRegimeRepair
  formed_regime :
    regimeOf dynamicReturn.localRecovery.formed =
      operationalTwoPole_leftPole parityTwoPole
  shadow_regime :
    regimeOf dynamicReturn.localRecovery.shadow =
      operationalTwoPole_rightPole parityTwoPole
  formed_visible :
    visibleOf (project dynamicReturn.localRecovery.formed) =
      parityProjection (regimeOf dynamicReturn.localRecovery.formed)
  shadow_visible :
    visibleOf (project dynamicReturn.localRecovery.shadow) =
      parityProjection (regimeOf dynamicReturn.localRecovery.shadow)
```

### Pourquoi cette forme est correcte

`dynamicReturn` reste la source dynamique concrete.

`regimeOf` lit les interfaces dynamiques comme regimes de parite.

`visibleOf` lit le visible dynamique comme visible de parite.

`parityTwoPole` force le raccord a passer par l'instance formelle deja
existante de `OperationalTwoPole`. On ne recree donc pas une parite concurrente.

`formed_regime` et `shadow_regime` attachent les deux poles dynamiques aux deux
poles de la realisation separatrice.

`formed_visible` et `shadow_visible` disent que la projection visible dynamique
est compatible avec la projection contractee de parite.

## Consequences a fournir

Le fichier doit exposer les projections du raccord :

```lean
def dynamicParitySeparation_dynamicOperationalTwoPole ...
def dynamicParitySeparation_parityOperationalTwoPole ...
def dynamicParitySeparation_dynamicStructuralTwoPole ...
def dynamicParitySeparation_parityStructuralTwoPole ...
def dynamicParitySeparation_formedRegime ...
def dynamicParitySeparation_shadowRegime ...
def dynamicParitySeparation_formedVisible ...
def dynamicParitySeparation_shadowVisible ...
```

La distinction `dynamic...` / `parity...` est obligatoire. Le premier nom
designe le two-pole porte par le retour dynamique. Le second nom designe le
two-pole separateur de parite auquel ce retour est raccorde.

Puis les consequences separatrices :

```lean
theorem dynamicParitySeparation_sameParityVisible ...
theorem dynamicParitySeparation_separatedParityRegimes ...
theorem dynamicParitySeparation_refutesParityShortPresentation ...
theorem dynamicParitySeparation_parityNotContractible ...
def dynamicParitySeparation_noParityProjectiveReconstruction ...
```

Ces consequences doivent etre obtenues en reutilisant :

```lean
operationalTwoPole_sameVisible
operationalTwoPole_separatedPoles
operationalTwoPole_refutes_shortPresentation
operationalTwoPole_not_contractible
operationalTwoPole_noProjectiveReconstruction
```

Il ne faut pas recopier la logique de `ParitySeparation.lean`.

## Cas canoniques directs

Le raccord doit pouvoir accepter directement :

```lean
parityOperationalTwoPole
parityOppositeOperationalTwoPole
```

Il faut donc fournir deux constructeurs de commodite :

```lean
def dynamicParitySeparation_leftRight ...
def dynamicParitySeparation_rightLeft ...
```

Ces constructeurs ne doivent pas supposer une dynamique arithmetique. Ils ne
fabriquent pas non plus une lecture de regimes depuis rien.

Ils devront prendre comme arguments :

```lean
regimeOf
visibleOf
formed_regime
shadow_regime
formed_visible
shadow_visible
```

et choisir seulement l'orientation :

```lean
parityOperationalTwoPole
```

ou :

```lean
parityOppositeOperationalTwoPole
```

Ainsi, l'orientation est fournie par le Core, mais la dynamique continue de
porter positivement sa propre lecture separatrice.

## Rapport aux dynamiques existantes

### Countdown

Le countdown reste une realisation terminale par retour.

Le nouveau raccord ne doit pas le renommer en parite. Il pourra seulement
servir plus tard si une lecture separatrice de ses interfaces est fournie
intrinsequement.

### Dynamiques observees

Les dynamiques observees produisent deja des retours localement recuperes. Le
raccord devra pouvoir les recevoir sans changer leur code, a condition que la
lecture separatrice soit donnee comme donnee positive.

### Tarski

Le raccord ne doit pas importer Tarski.

Tarski pourra consommer ce raccord plus tard comme instance particuliere, mais
le fichier `Core` doit rester pur.

### Ordres

Le raccord ne doit pas importer `OrderGap.lean`.

Les consequences d'ordre peuvent etre tirees ensuite depuis la combinaison :

```text
DynamicParitySeparation
+ OrderGap
```

mais le raccord dynamique de parite ne doit pas dependre d'une theorie des
ordres.

## Non-objectifs

Ne pas introduire :

```text
Nat
arithmetique de la parite
division
decidabilite globale
Classical
propext
Quot.sound
axiom
```

Ne pas faire :

```text
toute dynamique arbitraire donne automatiquement la parite
```

Ne pas remplacer :

```text
OperationalTwoPole
```

par une structure concurrente.

Ne pas raccorder la parite a une instance particuliere dans ce fichier.

## Ordre d'implementation

### Phase 1 : fichier Core

Creer :

```text
Meta/Core/DynamicParitySeparation.lean
```

avec :

```lean
import Meta.Core.DynamicTwoPole
import Meta.Core.ParitySeparation
```

### Phase 2 : structure positive

Ajouter :

```lean
structure DynamicParitySeparation ...
```

La structure doit porter le `dynamicReturn` en parametre, et non le cacher dans
un champ, afin que les theoremes puissent reutiliser directement les projections
existantes de `DynamicTwoPole.lean`.

### Phase 3 : projections

Ajouter les definitions :

```lean
dynamicParitySeparation_dynamicOperationalTwoPole
dynamicParitySeparation_parityOperationalTwoPole
dynamicParitySeparation_dynamicStructuralTwoPole
dynamicParitySeparation_parityStructuralTwoPole
dynamicParitySeparation_formedRegime
dynamicParitySeparation_shadowRegime
dynamicParitySeparation_formedVisible
dynamicParitySeparation_shadowVisible
```

### Phase 4 : consequences

Ajouter les theoremes :

```lean
dynamicParitySeparation_sameParityVisible
dynamicParitySeparation_separatedParityRegimes
dynamicParitySeparation_refutesParityShortPresentation
dynamicParitySeparation_parityNotContractible
dynamicParitySeparation_noParityProjectiveReconstruction
```

### Phase 5 : constructeurs d'orientation

Ajouter :

```lean
dynamicParitySeparation_leftRight
dynamicParitySeparation_rightLeft
```

Ces constructeurs doivent utiliser respectivement :

```lean
parityOperationalTwoPole
parityOppositeOperationalTwoPole
```

### Phase 6 : integration

Ajouter dans `Meta.lean` :

```lean
import Meta.Core.DynamicParitySeparation
```

Position :

```lean
import Meta.Core.DynamicTwoPole
import Meta.Core.DynamicParitySeparation
import Meta.Core.OrderGap
```

### Phase 7 : documentation

Mettre a jour `Docs/OperationalTwo.md` pour remplacer :

```text
Les raccords dynamiques particuliers restent separes de cette formalisation
minimale.
```

par :

```text
Le raccord dynamique transversal est formalise dans
Meta/Core/DynamicParitySeparation.lean. Les instances particulieres restent
separees.
```

## Audit Lean obligatoire

Le nouveau fichier devra se terminer par un unique bloc :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.DynamicParitySeparation
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_dynamicOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_parityOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_dynamicStructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_parityStructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_formedRegime
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_shadowRegime
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_formedVisible
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_shadowVisible
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_sameParityVisible
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_separatedParityRegimes
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_refutesParityShortPresentation
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_parityNotContractible
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_noParityProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_leftRight
#print axioms Meta.ClosedStabilityTheorem.dynamicParitySeparation_rightLeft
/- AXIOM_AUDIT_END -/
```

Si un nom change pendant l'implementation, le bloc audit doit utiliser le nom
final reel.

## Validation

Apres implementation :

```bash
lake build
```

Puis :

```bash
rg -n "open Classical|Classical\\.|propext|Quot\\.sound|^axiom" \
  Meta/Core/DynamicParitySeparation.lean
```

Verifier aussi :

```bash
python3 - <<'PY'
from pathlib import Path
p = Path("Meta/Core/DynamicParitySeparation.lean")
s = p.read_text()
print(s.count("/- AXIOM_AUDIT_BEGIN -/"))
print(s.count("/- AXIOM_AUDIT_END -/"))
print(s.rstrip().endswith("/- AXIOM_AUDIT_END -/"))
PY
```

Critere d'acceptation :

* `lake build` passe ;
* le fichier a exactement un bloc `AXIOM_AUDIT` ;
* le bloc est a la fin ;
* tous les noms audites existent ;
* l'audit n'affiche aucun axiome ;
* aucune dependance interdite n'apparait ;
* `Meta.lean` importe le nouveau fichier au niveau Core ;
* `Docs/OperationalTwo.md` distingue clairement :
  * parite separatrice minimale ;
  * raccord dynamique transversal ;
  * instances dynamiques particulieres.

## Verification prealable du plan

La forme centrale du raccord a ete testee dans un squelette Lean temporaire
important :

```lean
import Meta.Core.DynamicTwoPole
import Meta.Core.ParitySeparation
```

Le squelette complet contenait :

```lean
DynamicParitySeparation
dynamicParitySeparation_dynamicOperationalTwoPole
dynamicParitySeparation_parityOperationalTwoPole
dynamicParitySeparation_dynamicStructuralTwoPole
dynamicParitySeparation_parityStructuralTwoPole
dynamicParitySeparation_formedRegime
dynamicParitySeparation_shadowRegime
dynamicParitySeparation_formedVisible
dynamicParitySeparation_shadowVisible
dynamicParitySeparation_sameParityVisible
dynamicParitySeparation_separatedParityRegimes
dynamicParitySeparation_refutesParityShortPresentation
dynamicParitySeparation_parityNotContractible
dynamicParitySeparation_noParityProjectiveReconstruction
dynamicParitySeparation_leftRight
dynamicParitySeparation_rightLeft
```

Commande executee :

```bash
lake env lean /tmp/DynamicParitySeparationPlanFullCheck.lean
```

Resultat :

```text
compilation reussie
```

Cela verifie que le plan est compatible avec les types reels de
`LocallyRecoveredDynamicReturn`, `OperationalTwoPole` et `ParitySeparation`.

## Resultat attendu

Apres implementation, le cadre dira formellement :

```text
Une dynamique localement recuperee expose deja un two-pole operationnel.
La parite separatrice minimale expose deja un two-pole operationnel.
DynamicParitySeparation raccorde les deux quand la dynamique porte
intrinsequement une lecture separatrice de regimes.
```

Ce raccord ne confond pas :

```text
fermeture dynamique
```

avec :

```text
separation de regimes
```

Il dit seulement que la dynamique peut porter la separation comme structure
interne, au lieu de la laisser comme lecture informelle.
