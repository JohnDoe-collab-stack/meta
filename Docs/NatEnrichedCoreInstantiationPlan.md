# Plan d'implementation : instance Nat enrichie exhaustive du Core Meta

## Objectif

Construire une instance arithmetique Nat enrichie qui reprenne strictement la
chaine abstraite du Core Meta.

Le but n'est pas de coller des noms arithmetiques sur des poles abstraits. Le
but est de montrer que la structure Nat enrichie realise effectivement :

```text
closed stability
-> gap
-> referential length
-> two-pole
-> dynamic return
-> dynamic two-pole
-> dynamic role carrier
-> mediated dynamic roles
-> dynamic parity separation
-> operational parity roles
-> order-visible test
-> equivalence with classical even / odd
```

L'equivalence avec pair / impair classique doit venir a la fin. Elle doit etre
une consequence de l'instance Nat enrichie, pas son point de depart.

## Non-negociable

Ne pas faire :

```text
left = pair
right = impair
Role := Bool
even := left
odd := right
```

Ce serait une instance triviale et donc fausse par rapport au cadre.

L'instance doit passer par la matiere deja presente dans Nat enrichi :

```lean
NatTraceAtom.excess k
NatTraceAtom.value k
tracePayloads
formedTraceOfIntersection
payloadOnlyTraceOfIntersection
formedPositiveExcessOfIntersection
localProjectiveRecoveryOfIntersection
```

La separation a exploiter est :

```text
formed trace = prefix ++ [excess k]
shadow trace = prefix ++ [value k]
same visible payload
separated enriched interface
local repair on the formed side
```

## Core abstrait a instancier

L'instance Nat enrichie doit reprendre tous les facteurs Core suivants.

### 1. Closed stability

Declarations Core concernees :

```text
BidirectionalCompleteness
TerminalCycle
CoherentTerminalCycle
RoundTripCoherence
StrongTerminalCycle
StrongTerminalCycleFromIntersection
InterfaceWitness
WeakClosedStability
StrongClosedStability
StrongClosedStabilityFromIntersection
NonProjectiveStrongClosedStability
RecoveredNonProjectiveClosedStability
LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
```

Etat actuel Nat enrichi :

```lean
MemoryBranch
PrimitiveMemoryReadingIntersection
primitiveCompleteOfIntersection
bidirectionalCompleteness
enrichedNatRoundTripCoherence
NatInterfaceWitness
NatInterfaceRealization
NatClosedStabilityArithmeticInstance
natClosedStability_of_arithmeticInstance
canonicalNatClosedStabilityArithmeticInstance
repeatedIndexNatClosedStabilityArithmeticInstance
```

Travail attendu :

```text
verifier que toute future instance parity/role s'appuie sur ces objets,
et ne reconstruit jamais une autre notion de fermeture arithmetique.
```

### 2. Projection gap

Declarations Core concernees :

```text
ProjectionObstruction
ProjectionFiberFaithful
ProjectionInformationConserving
DiagonalCertificate
LocalProjectiveRecovery
LocalTruthGapRecovery
RecoveryBundle
TerminalProjection
```

Etat actuel Nat enrichi :

```lean
diagonalCertificateOfIntersection
payloadProjectionObstructionOfIntersection
localProjectiveRecoveryOfIntersection
NatEnrichedReferentialGap
NatEnrichedReferentialGap.obstruction
NatEnrichedReferentialGap.notFiberFaithful
NatEnrichedReferentialGap.notInformationConserving
NatEnrichedReferentialGap.truthGapRecovery
NatEnrichedReferentialGap.localFormationProjectedTruthIndependent
recoveryBundleOfIntersection
terminalProjectionOfIntersection
LocalIntersectionRecoveryPackage
```

Travail attendu :

```text
aucune nouvelle obstruction artificielle ;
tout doit etre derive de l'obstruction payload existante.
```

### 3. Gap / referential length

Declarations Core concernees :

```text
ContractibleReferentialGap
StructuralReferentialGap
OperationalReferentialGap
ShortReferentialPresentation
EnrichedStructuralReferentialLength
EnrichedOperationalReferentialLength
```

Etat actuel Nat enrichi :

```lean
ArithmeticShortPayloadPresentation
arithmeticStructuralGapOfIntersection
arithmeticOperationalGapOfIntersection
arithmeticStructuralGap_refutes_shortPresentation
arithmeticOperationalGap_refutes_shortPresentation
arithmeticDynamicRowStructuralGap
arithmeticDynamicRowOperationalGap
arithmeticDynamicRow_refutes_shortPresentation
```

Travail attendu :

```text
conserver cette couche comme base de toute instance two-pole / role / parity.
```

### 4. Two-pole

Declarations Core concernees :

```text
StructuralTwoPole
OperationalTwoPole
structuralTwoPole_leftPole
structuralTwoPole_rightPole
structuralTwoPole_sameVisible
structuralTwoPole_separatedPoles
operationalTwoPole_leftPole
operationalTwoPole_rightPole
operationalTwoPole_sameVisible
operationalTwoPole_separatedPoles
operationalTwoPole_repair
operationalTwoPole_recovered
operationalTwoPole_structural
operationalTwoPole_refutes_shortPresentation
operationalTwoPole_not_contractible
operationalTwoPole_noProjectiveReconstruction
```

Etat actuel Nat enrichi :

```lean
arithmeticDynamicRowStructuralTwoPole
arithmeticDynamicRowOperationalTwoPole
arithmeticDynamicRowTwoPole_refutes_shortPresentation
repeatedIndexArithmeticOperationalTwoPole
trajectoryArithmeticOperationalTwoPole
boundedWindowArithmeticOperationalTwoPole
postPeakWindowArithmeticOperationalTwoPole
countdownTerminalOperationalTwoPole
countdownTerminalStructuralTwoPole
fullyConstructedCountdownOperationalTwoPole
fullyConstructedCountdownStructuralTwoPole
```

Travail attendu :

Ajouter les projections et consequences Nat explicites, par exemple :

```text
arithmeticDynamicRow_leftPole
arithmeticDynamicRow_rightPole
arithmeticDynamicRow_sameVisible
arithmeticDynamicRow_separatedPoles
arithmeticDynamicRow_repair
arithmeticDynamicRow_noProjectiveReconstruction
```

Ces declarations ne doivent pas etre de simples aliases decoratifs. Elles
doivent exposer :

```text
left pole  = formed trace
right pole = payload-only shadow
same visible payload
separation enriched trace
repair on formed trace
```

### 5. Dynamic return / dynamic two-pole

Declarations Core concernees :

```text
FormedDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
dynamicReturn_operationalGap
dynamicReturn_structuralGap
dynamicReturn_refutes_shortReferentialPresentation
dynamicReturn_operationalTwoPole
dynamicReturn_structuralTwoPole
dynamicReturn_twoPole_refutes_shortPresentation
```

Etat actuel Nat enrichi :

```lean
observedFormedDynamicReturn
observedLocallyRecoveredDynamicReturn
observedLocallyRecoveredClosedStabilityOfDynamicReturn
observedBoundedWindowFormedDynamicReturn
observedBoundedWindowLocallyRecoveredDynamicReturn
observedBoundedWindowLocallyRecoveredClosedStabilityOfDynamicReturn
```

Travail attendu :

Ajouter une couche Nat explicite qui relie les dynamic returns observes aux
two-poles arithmetiques :

```text
observedDynamicReturn_operationalTwoPole
observedDynamicReturn_structuralTwoPole
observedDynamicReturn_sameVisible
observedDynamicReturn_separated
observedDynamicReturn_repair
observedDynamicReturn_refutes_shortPresentation
```

Le but est que la dynamique Nat ne reste pas seulement dans `Dynamics`, mais
qu'elle soit visible comme realisation du Core dynamique.

### 6. Dynamic role carrier

Declarations Core concernees :

```text
DynamicRoleCarrier
dynamicRoleCarrier_dynamicOperationalTwoPole
dynamicRoleCarrier_roleOperationalTwoPole
dynamicRoleCarrier_formedRole
dynamicRoleCarrier_shadowRole
dynamicRoleCarrier_formedVisibleRole
dynamicRoleCarrier_shadowVisibleRole
dynamicRoleCarrier_sameRoleVisible
dynamicRoleCarrier_separatedRoles
dynamicRoleCarrier_dynamicRepair
dynamicRoleCarrier_roleRepair
dynamicRoleCarrier_noRoleProjectiveReconstruction
MediatedDynamicRoles
mediatedDynamicRolesOfCarrier
mediatedDynamicRoles_closingRole
mediatedDynamicRoles_mediatingRole
mediatedDynamicRoles_sameVisible
mediatedDynamicRoles_separated
mediatedDynamicRoles_dynamicRepair
mediatedDynamicRoles_roleRepair
mediatedDynamicRoles_noRoleVisibleReconstruction
mediatedDynamicRoles_sameRoleProjection
```

Etat actuel Nat enrichi :

```text
pas encore instancie exhaustivement
```

Travail attendu :

Construire un role carrier non trivial dont les roles sont portes par la trace
enrichie.

Il faut introduire un role arithmetique enrichi qui ne soit pas un simple
label. Exemple de cible :

```lean
inductive NatEnrichedParityRole where
  | closingExcess : Nat -> NatEnrichedParityRole
  | mediatingValue : Nat -> NatEnrichedParityRole
```

ou une structure equivalente, a condition qu'elle porte le payload interne.

Projection role-visible :

```text
closingExcess k  -> k
mediatingValue k -> k
```

Separation :

```text
closingExcess k != mediatingValue k
```

Reparation :

```text
role repair on closingExcess k
```

Le carrier doit etre derive de :

```text
formed trace terminal atom = excess k
shadow trace terminal atom = value k
```

et non impose de l'exterieur.

### 7. Dynamic parity separation

Declarations Core concernees :

```text
ParityRegime
ParityVisible
parityProjection
ParityRegimeRepair
parityStructuralTwoPole
parityOperationalTwoPole
parityOppositeOperationalTwoPole
DynamicParitySeparation
dynamicParitySeparation_roleCarrier
dynamicParitySeparation_sameParityVisible
dynamicParitySeparation_separatedParityRegimes
dynamicParitySeparation_refutesParityShortPresentation
dynamicParitySeparation_parityNotContractible
OperationalParityRoles
operationalParityRolesOfDynamicParitySeparation
operationalParityRoles_mediatedDynamicRoles
operationalParityRoles_closingRegime
operationalParityRoles_mediatingRegime
operationalParityRoles_sameVisible
operationalParityRoles_separated
operationalParityRoles_dynamicRepair
operationalParityRoles_sameParityProjection
operationalParityRoles_refutesParityShortPresentation
operationalParityRoles_parityNotContractible
```

Etat actuel Nat enrichi :

```text
pas encore instancie
```

Travail attendu :

Construire un raccord Nat enrichi vers la parite separatrice minimale.

La lecture doit etre derivee :

```text
formed terminal excess -> closing regime
shadow terminal value   -> mediating regime
```

Mais le code ne doit pas dire seulement :

```text
formed -> left
shadow -> right
```

Il doit prouver que le `formed` et le `shadow` viennent de la distinction
enrichie :

```text
excess k / value k
```

Il faudra donc probablement disposer avant cette phase de lemmes d'analyse du
dernier atome :

```text
formedTrace_terminalAtom_is_excess
payloadOnlyTrace_terminalAtom_is_value
formed_shadow_terminalPayload_eq
formed_shadow_terminalRoles_separated
```

### 8. Order-visible test

Declarations Core concernees :

```text
VisiblePreorder
VisiblePartialOrder
VisibleTotalOrder
VisibleOrderEquivalent
OrderContractiveProjection
structuralGap_visibleOrderEquivalent
structuralGap_not_orderContractive
operationalGap_visibleOrderEquivalent
operationalGap_not_orderContractive
dynamicReturn_visibleOrderEquivalent
dynamicReturn_not_orderContractive
```

Etat actuel Nat enrichi :

```text
pas encore instancie comme test visible specifique
```

Travail attendu :

Construire le test visible sur les payloads ou sur les roles visibles.

Option minimale :

```text
visible order on List Nat
```

Option plus ciblee :

```text
visible order on terminal payload Nat
```

Le point a prouver :

```text
visible equality / mutual comparability does not recover enriched equality
```

Donc l'ordre doit servir a montrer que la projection ordonnee contracte trop,
pas a remplacer la separation enrichie.

### 9. Equivalence avec pair / impair classique

Cette phase vient apres l'instance Core exhaustive.

Elle doit introduire une lecture numerique non triviale des roles enrichis :

```text
closingExcess k  -> 2 * k
mediatingValue k -> 2 * k + 1
```

Definitions classiques a viser :

```text
EvenClassical n := exists k, n = 2 * k
OddClassical n  := exists k, n = 2 * k + 1
```

Theoremes attendus :

```text
closingExcess_code_even
mediatingValue_code_odd
even_code_recovers_closing_payload
odd_code_recovers_mediating_payload
closing_not_odd
mediating_not_even
```

Si possible, prouver des equivalences :

```text
isClosingCode n <-> EvenClassical n
isMediatingCode n <-> OddClassical n
```

Ces equivalences doivent etre obtenues par calcul Nat constructif, sans
`Classical`, sans axiome, sans quotient.

## Audit exhaustif Core -> Nat enrichi

Cette section est la checklist stricte. Une implementation ne sera pas
consideree complete si une declaration Core ci-dessous n'a pas un statut clair
dans l'instance Nat enrichie.

Statuts :

```text
DONE    = deja realise dans Nat enrichi
PARTIAL = realise partiellement, mais pas encore expose dans toute la chaine
MISSING = pas encore instancie
TARGET  = declaration de support a consommer ou a exposer explicitement
```

### ClosedStabilityTheorem

| Declaration Core | Statut Nat enrichi | Cible / temoin Nat |
| --- | --- | --- |
| `BidirectionalCompleteness` | DONE | `bidirectionalCompleteness` |
| `forwardOfComplete` | DONE | champs de `bidirectionalCompleteness` |
| `backwardOfComplete` | DONE | champs de `bidirectionalCompleteness` |
| `intersectionOfComplete` | DONE | champs de `bidirectionalCompleteness` |
| `completeOfIntersection` | DONE | `primitiveCompleteOfIntersection` |
| `TerminalCycle` | DONE | produit par les theoremes Core consommes dans `Canonical` / `RepeatedIndex` |
| `terminalCycleOfComplete` | TARGET | verifier exposition Nat si necessaire |
| `terminalCycleOfIntersection` | TARGET | verifier exposition Nat si necessaire |
| `CoherentTerminalCycle` | DONE | derive par `enrichedNatRoundTripCoherence` |
| `coherentTerminalCycleOfComplete` | TARGET | verifier exposition Nat si necessaire |
| `coherentTerminalCycleOfIntersection` | TARGET | verifier exposition Nat si necessaire |
| `ReextractionCoherence` | DONE | champ de `RoundTripCoherence`, via `enrichedNatRoundTripCoherence` |
| `IntersectionRecompositionCoherence` | DONE | champ de `RoundTripCoherence`, via `enrichedNatRoundTripCoherence` |
| `RoundTripCoherence` | DONE | `enrichedNatRoundTripCoherence` |
| `StrongTerminalCycle` | DONE | `enrichedNatStrongTerminalCycleFromIntersection`, `repeatedIndexStrongTerminalCycleFromIntersection` |
| `StrongTerminalCycleFromIntersection` | DONE | `enrichedNatStrongTerminalCycleFromIntersection`, `repeatedIndexStrongTerminalCycleFromIntersection` |
| `strongTerminalCycleOfIntersection` | TARGET | verifier exposition Nat si necessaire |
| `strongTerminalCycleFromIntersection` | DONE | consomme par instances Nat |
| `InterfaceWitness` | DONE | `canonicalInterfaceWitness`, `repeatedIndexInterfaceWitness` |
| `interfaceOf` | TARGET | projection a exposer si la couche Nat en a besoin |
| `witnessOf` | TARGET | projection a exposer si la couche Nat en a besoin |
| `FormedReferentialClosure` | PARTIAL | equivalent porte par `formedTraceOfIntersection`, a expliciter si necessaire |
| `FormedInterfaceWitness` | PARTIAL | equivalent porte par `NatInterfaceWitness`, a expliciter si necessaire |
| `formedInterfaceWitnessOfClosure` | TARGET | a consommer si une couche closure Nat est exposee |
| `closureOfFormedInterfaceWitness` | TARGET | a consommer si une couche closure Nat est exposee |
| `closure_roundtrip` | TARGET | verifier si necessaire pour l'exhaustivite documentaire |
| `formedInterfaceWitness_roundtrip` | TARGET | verifier si necessaire pour l'exhaustivite documentaire |
| `WeakClosedStability` | DONE | `weakClosedStabilityTheorem` consomme indirectement |
| `StrongClosedStability` | DONE | `enrichedNatStrongClosedStabilityFromIntersection` |
| `StrongClosedStabilityFromIntersection` | DONE | `enrichedNatStrongClosedStabilityFromIntersection`, `repeatedIndexStrongClosedStabilityFromIntersection` |
| `weakOfStrongClosedStability` | TARGET | verifier exposition Nat si necessaire |
| `SelfCoupling` | MISSING | decider si Nat doit exposer un couplage propre ou seulement consommer le Core |
| `commonStabilityOfStrongTerminalCycle` | MISSING | cible possible si l'instance Nat doit exposer une stabilite commune |
| `ProjectionObstruction` | DONE | `payloadProjectionObstructionOfIntersection` |
| `ProjectionFiberFaithful` | DONE | refute par `NatEnrichedReferentialGap.notFiberFaithful` |
| `ProjectionInformationConserving` | DONE | refute par `NatEnrichedReferentialGap.notInformationConserving` |
| `projectionFiberFaithful_of_informationConserving` | TARGET | consomme via refutation de conservation |
| `projectionObstruction_notFiberFaithful` | DONE | via `NatEnrichedReferentialGap.notFiberFaithful` |
| `projectionObstruction_notInformationConserving` | DONE | via `NatEnrichedReferentialGap.notInformationConserving` |
| `noProjectiveReconstruction` | PARTIAL | expose par `enrichedNatNoProjectiveReconstructionFromIntersection`, `repeatedIndexNoProjectiveReconstructionFromIntersection` |
| `DiagonalCertificate` | DONE | `diagonalCertificateOfIntersection` |
| `projectionObstructionOfDiagonalCertificate` | DONE | `payloadProjectionObstructionOfIntersection` |
| `LocalProjectiveRecovery` | DONE | `localProjectiveRecoveryOfIntersection` |
| `localProjectiveRecovery_obstruction` | DONE | `NatEnrichedReferentialGap.obstruction` |
| `noProjectiveReconstructionOfLocalProjectiveRecovery` | PARTIAL | doit etre expose dans la couche two-pole / role Nat |
| `localProjectiveRecovery_notFiberFaithful` | DONE | `NatEnrichedReferentialGap.notFiberFaithful` |
| `localProjectiveRecovery_notInformationConserving` | DONE | `NatEnrichedReferentialGap.notInformationConserving` |
| `ReferentialScene` | DONE | consomme par `NatEnrichedReferentialGap.localFormationProjectedTruthIndependent` |
| `GeometricFormation` | DONE | idem |
| `ProjectedLocalTruth` | DONE | idem |
| `LocalTruthGapRecovery` | DONE | `NatEnrichedReferentialGap.truthGapRecovery`, `arithmeticTruthGapRecoveryOfIntersection` |
| `localTruthGapRecovery_fullScene` | TARGET | verifier exposition Nat si necessaire |
| `localTruthGapRecovery_shadowScene` | TARGET | verifier exposition Nat si necessaire |
| `localTruthGapRecovery_fullScene_geometricFormation` | TARGET | verifier exposition Nat si necessaire |
| `localTruthGapRecovery_fullScene_not_projectedDynamicTruth` | TARGET | verifier exposition Nat si necessaire |
| `localTruthGapRecovery_shadowScene_projectedDynamicTruth` | TARGET | verifier exposition Nat si necessaire |
| `localTruthGapRecovery_shadowScene_not_geometricFormation` | TARGET | verifier exposition Nat si necessaire |
| `localTruthGapRecovery_localFormation_projectedTruth_independent` | DONE | `NatEnrichedReferentialGap.localFormationProjectedTruthIndependent` |
| `RecoveryBundle` | DONE | `recoveryBundleOfIntersection`, `canonicalRecoveryBundle`, `repeatedIndexRecoveryBundle` |
| `recoveryBundleOfLocalProjectiveRecovery` | TARGET | verifier exposition Nat si necessaire |
| `TerminalProjection` | DONE | `terminalProjectionOfIntersection`, `canonicalTerminalProjection`, `repeatedIndexTerminalProjection` |
| `terminalProjectionOfLocalProjectiveRecovery` | TARGET | verifier exposition Nat si necessaire |
| `NonProjectiveStrongClosedStability` | DONE | `enrichedNatNonProjectiveStrongClosedStabilityFromIntersection` |
| `noProjectiveReconstructionOfStability` | PARTIAL | a relier a la couche role/parity Nat |
| `RecoveredNonProjectiveClosedStability` | DONE | `enrichedNatClosedStabilityInstance`, `repeatedIndexClosedStabilityInstance` |
| `NonProjectiveStrongClosedStabilityFromIntersection` | DONE | `enrichedNatNonProjectiveStrongClosedStabilityFromIntersection`, `repeatedIndexNonProjectiveStrongClosedStabilityFromIntersection` |
| `RecoveredNonProjectiveClosedStabilityFromIntersection` | DONE | `enrichedNatClosedStabilityInstance`, `repeatedIndexClosedStabilityInstance` |
| `LocallyRecoveredNonProjectiveClosedStabilityFromIntersection` | DONE | `enrichedNatLocallyRecoveredClosedStabilityInstance`, `repeatedIndexLocallyRecoveredClosedStabilityInstance` |
| `noProjectiveReconstructionOfStabilityFromIntersection` | DONE | `enrichedNatNoProjectiveReconstructionFromIntersection`, `repeatedIndexNoProjectiveReconstructionFromIntersection` |
| `weakClosedStabilityTheorem` | TARGET | consomme indirectement ; verifier exposition si necessaire |
| `strongClosedStabilityTheorem` | TARGET | consomme indirectement ; verifier exposition si necessaire |
| `strongClosedStabilityFromIntersectionTheorem` | DONE | instances Nat canoniques et repeated-index |
| `strongClosedStabilityFromIntersectionLinkedTheorem` | DONE | `enrichedNatStrongClosedStabilityFromIntersection`, `repeatedIndexStrongClosedStabilityFromIntersection` |
| `nonProjectiveStrongClosedStabilityTheorem` | TARGET | verifier exposition Nat si necessaire |
| `recoveredNonProjectiveClosedStabilityTheorem` | TARGET | verifier exposition Nat si necessaire |
| `nonProjectiveStrongClosedStabilityFromIntersectionTheorem` | DONE | instances non-projectives Nat |
| `recoveredNonProjectiveClosedStabilityFromIntersectionTheorem` | DONE | instances recovered Nat |
| `locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem` | DONE | `natClosedStability_of_arithmeticInstance` |

### Gap

| Declaration Core | Statut Nat enrichi | Cible / temoin Nat |
| --- | --- | --- |
| `ContractibleReferentialGap` | DONE | `ArithmeticShortPayloadPresentation` comme regime court a refuter |
| `StructuralReferentialGap` | DONE | `arithmeticStructuralGapOfIntersection` |
| `OperationalReferentialGap` | DONE | `arithmeticOperationalGapOfIntersection` |
| `structuralGapOfOperationalGap` | DONE | `arithmeticStructuralGapOfOperationalIntersection` |
| `structuralGap_not_contractible` | DONE | `arithmeticStructuralGap_refutes_shortPresentation` |
| `structuralGap_not_informationConserving` | PARTIAL | deja au niveau `NatEnrichedReferentialGap`; a exposer au niveau arithmetic si necessaire |
| `operationalGap_not_contractible` | DONE | `arithmeticOperationalGap_refutes_shortPresentation` |
| `operationalGap_not_informationConserving` | PARTIAL | a exposer au niveau arithmetic operational |
| `noProjectiveReconstructionOfOperationalGap` | PARTIAL | a exposer dans `Meta/Arithmetic/TwoPole.lean` et role/parity |

### ReferentialLength

| Declaration Core | Statut Nat enrichi | Cible / temoin Nat |
| --- | --- | --- |
| `ShortReferentialPresentation` | DONE | `ArithmeticShortPayloadPresentation` |
| `EnrichedStructuralReferentialLength` | DONE | `arithmeticStructuralGapOfIntersection`, `arithmeticDynamicRowStructuralGap` |
| `EnrichedOperationalReferentialLength` | DONE | `arithmeticOperationalGapOfIntersection`, `arithmeticDynamicRowOperationalGap` |
| `structuralLength_refutes_shortPresentation` | DONE | `arithmeticStructuralGap_refutes_shortPresentation` |
| `operationalLength_refutes_shortPresentation` | DONE | `arithmeticOperationalGap_refutes_shortPresentation`, `arithmeticDynamicRow_refutes_shortPresentation` |
| `structuralLengthOfOperationalLength` | DONE | `arithmeticStructuralGapOfOperationalIntersection` |

### TwoPole

| Declaration Core | Statut Nat enrichi | Cible / temoin Nat |
| --- | --- | --- |
| `StructuralTwoPole` | DONE | `arithmeticDynamicRowStructuralTwoPole`, countdown structural two-poles |
| `OperationalTwoPole` | DONE | `arithmeticDynamicRowOperationalTwoPole`, countdown operational two-poles |
| `structuralTwoPole_leftPole` | PARTIAL | a exposer comme projection Nat explicite |
| `structuralTwoPole_rightPole` | PARTIAL | a exposer comme projection Nat explicite |
| `structuralTwoPole_sameVisible` | PARTIAL | a exposer comme theorem Nat explicite |
| `structuralTwoPole_separatedPoles` | PARTIAL | a exposer comme theorem Nat explicite |
| `operationalTwoPole_leftPole` | PARTIAL | a exposer comme `arithmeticDynamicRow_leftPole` |
| `operationalTwoPole_rightPole` | PARTIAL | a exposer comme `arithmeticDynamicRow_rightPole` |
| `operationalTwoPole_sameVisible` | PARTIAL | a exposer comme `arithmeticDynamicRow_sameVisible` |
| `operationalTwoPole_separatedPoles` | PARTIAL | a exposer comme `arithmeticDynamicRow_separatedPoles` |
| `operationalTwoPole_repair` | PARTIAL | a exposer comme `arithmeticDynamicRow_repair` |
| `operationalTwoPole_recovered` | PARTIAL | a exposer comme `arithmeticDynamicRow_recovered` |
| `operationalTwoPole_recovered_eq_leftPole` | PARTIAL | a exposer comme theorem Nat explicite |
| `operationalTwoPole_structural` | DONE | `countdownTerminalStructuralTwoPole`, `fullyConstructedCountdownStructuralTwoPole` |
| `structuralTwoPole_refutes_shortPresentation` | PARTIAL | a exposer au niveau Nat structural |
| `operationalTwoPole_refutes_shortPresentation` | DONE | `arithmeticDynamicRowTwoPole_refutes_shortPresentation` |
| `operationalTwoPole_not_contractible` | PARTIAL | a exposer au niveau Nat two-pole |
| `operationalTwoPole_noProjectiveReconstruction` | PARTIAL | a exposer au niveau Nat two-pole |

### DynamicStability et DynamicTwoPole

| Declaration Core | Statut Nat enrichi | Cible / temoin Nat |
| --- | --- | --- |
| `FormedDynamicReturn` | DONE | `observedFormedDynamicReturn`, `observedBoundedWindowFormedDynamicReturn` |
| `LocallyRecoveredDynamicReturn` | DONE | `observedLocallyRecoveredDynamicReturn`, `observedBoundedWindowLocallyRecoveredDynamicReturn` |
| `locallyRecoveredClosedStabilityOfDynamicReturn` | DONE | `observedLocallyRecoveredClosedStabilityOfDynamicReturn`, bounded variant |
| `dynamicReturn_operationalGap` | PARTIAL | a exposer pour observed Nat |
| `dynamicReturn_structuralGap` | PARTIAL | a exposer pour observed Nat |
| `dynamicReturn_refutes_shortReferentialPresentation` | PARTIAL | a exposer pour observed Nat |
| `dynamicReturn_operationalTwoPole` | PARTIAL | a exposer pour observed Nat |
| `dynamicReturn_structuralTwoPole` | PARTIAL | a exposer pour observed Nat |
| `dynamicReturn_twoPole_refutes_shortPresentation` | PARTIAL | a exposer pour observed Nat |

### DynamicRoleCarrier

| Declaration Core | Statut Nat enrichi | Cible / temoin Nat |
| --- | --- | --- |
| `DynamicRoleCarrier` | MISSING | construire le carrier Nat enrichi non trivial |
| `dynamicRoleCarrier_dynamicOperationalTwoPole` | MISSING | projection du carrier Nat |
| `dynamicRoleCarrier_roleOperationalTwoPole` | MISSING | role two-pole Nat enrichi |
| `dynamicRoleCarrier_formedRole` | MISSING | role derive du terminal `excess k` |
| `dynamicRoleCarrier_shadowRole` | MISSING | role derive du terminal `value k` |
| `dynamicRoleCarrier_formedVisibleRole` | MISSING | payload role-visible |
| `dynamicRoleCarrier_shadowVisibleRole` | MISSING | payload role-visible |
| `dynamicRoleCarrier_formedRole_eq_leftPole` | MISSING | preuve derivee du terminal excess |
| `dynamicRoleCarrier_shadowRole_eq_rightPole` | MISSING | preuve derivee du terminal value |
| `dynamicRoleCarrier_formedVisible_eq_projection` | MISSING | compatibilite payload role |
| `dynamicRoleCarrier_shadowVisible_eq_projection` | MISSING | compatibilite payload role |
| `dynamicRoleCarrier_sameRoleVisible` | MISSING | meme payload role-visible |
| `dynamicRoleCarrier_separatedRoles` | MISSING | separation `closingExcess k` / `mediatingValue k` |
| `dynamicRoleCarrier_dynamicRepair` | MISSING | reparation de la dynamique Nat |
| `dynamicRoleCarrier_roleRepair` | MISSING | reparation du role closing |
| `dynamicRoleCarrier_refutesRoleShortPresentation` | MISSING | refus presentation courte role-visible |
| `dynamicRoleCarrier_roleNotContractible` | MISSING | role non contractible |
| `dynamicRoleCarrier_noRoleProjectiveReconstruction` | MISSING | pas de reconstruction role-visible globale |
| `MediatedDynamicRoles` | MISSING | extrait du carrier Nat |
| `mediatedDynamicRolesOfCarrier` | MISSING | construction Nat |
| `mediatedDynamicRoles_closingRole` | MISSING | closing role Nat |
| `mediatedDynamicRoles_mediatingRole` | MISSING | mediating role Nat |
| `mediatedDynamicRoles_closing_eq_formed` | MISSING | closing = formed role |
| `mediatedDynamicRoles_mediating_eq_shadow` | MISSING | mediating = shadow role |
| `mediatedDynamicRoles_sameVisible` | MISSING | meme visible |
| `mediatedDynamicRoles_separated` | MISSING | separation |
| `mediatedDynamicRoles_dynamicRepair` | MISSING | reparation dynamique |
| `mediatedDynamicRoles_roleRepair` | MISSING | reparation role |
| `mediatedDynamicRoles_noRoleVisibleReconstruction` | MISSING | non reconstruction |
| `mediatedDynamicRoles_sameRoleProjection` | MISSING | meme projection role |
| `mediatedDynamicRoles_refutesRoleShortPresentation` | MISSING | refus short |
| `mediatedDynamicRoles_roleNotContractible` | MISSING | non contractible |

### ParitySeparation

| Declaration Core | Statut Nat enrichi | Cible / temoin Nat |
| --- | --- | --- |
| `ParityRegime` | MISSING | raccord depuis roles Nat enrichis |
| `ParityVisible` | MISSING | raccord depuis role-visible Nat |
| `parityProjection` | MISSING | projection apres contraction de regime |
| `parityRegime_left_ne_right` | MISSING | separation regime apres raccord |
| `parityRegime_right_ne_left` | MISSING | separation regime opposee |
| `parityProjection_left_eq_right` | MISSING | meme visible de parite |
| `parityProjection_right_eq_left` | MISSING | meme visible oppose |
| `ParityRegimeRepair` | MISSING | reparation cote regime |
| `parityRegimeRepair` | MISSING | reparation regime |
| `parityStructuralTwoPole` | MISSING | structural two-pole de parite consomme par Nat |
| `parityOperationalTwoPole` | MISSING | operational two-pole de parite consomme par Nat |
| `parityOppositeStructuralTwoPole` | TARGET | option d'orientation |
| `parityOppositeOperationalTwoPole` | TARGET | option d'orientation |
| `parityOperationalTwoPole_sameVisible` | MISSING | consequence a relier aux roles Nat |
| `parityOperationalTwoPole_separated` | MISSING | consequence a relier aux roles Nat |
| `parityOppositeOperationalTwoPole_sameVisible` | TARGET | orientation opposee si retenue |
| `parityOppositeOperationalTwoPole_separated` | TARGET | orientation opposee si retenue |
| `parityStructuralTwoPole_refutes_shortPresentation` | MISSING | a exposer si short parite est refute |
| `parityOperationalTwoPole_refutes_shortPresentation` | MISSING | a exposer par roles Nat |
| `parityOppositeStructuralTwoPole_refutes_shortPresentation` | TARGET | orientation opposee |
| `parityOppositeOperationalTwoPole_refutes_shortPresentation` | TARGET | orientation opposee |
| `parityOperationalTwoPole_not_contractible` | MISSING | a exposer par roles Nat |
| `parityOppositeOperationalTwoPole_not_contractible` | TARGET | orientation opposee |
| `parityOperationalTwoPole_noProjectiveReconstruction` | MISSING | a relier a non reconstruction role-visible |
| `parityOppositeOperationalTwoPole_noProjectiveReconstruction` | TARGET | orientation opposee |

### DynamicParitySeparation et OperationalParityRoles

| Declaration Core | Statut Nat enrichi | Cible / temoin Nat |
| --- | --- | --- |
| `DynamicParitySeparation` | MISSING | construire le raccord Nat enrichi |
| `dynamicParitySeparation_dynamicOperationalTwoPole` | MISSING | expose le two-pole dynamique Nat |
| `dynamicParitySeparation_parityOperationalTwoPole` | MISSING | expose le two-pole parite |
| `dynamicParitySeparation_dynamicStructuralTwoPole` | MISSING | expose le structural dynamique |
| `dynamicParitySeparation_parityStructuralTwoPole` | MISSING | expose le structural parite |
| `dynamicParitySeparation_roleCarrier` | MISSING | relie au carrier Nat |
| `dynamicParitySeparation_formedRegime` | MISSING | regime du terminal excess |
| `dynamicParitySeparation_shadowRegime` | MISSING | regime du terminal value |
| `dynamicParitySeparation_formedVisible` | MISSING | visible parite du formed |
| `dynamicParitySeparation_shadowVisible` | MISSING | visible parite du shadow |
| `dynamicParitySeparation_formedRegime_eq_leftPole` | MISSING | preuve non triviale depuis excess |
| `dynamicParitySeparation_shadowRegime_eq_rightPole` | MISSING | preuve non triviale depuis value |
| `dynamicParitySeparation_formedVisible_eq_projection` | MISSING | compatibilite projection |
| `dynamicParitySeparation_shadowVisible_eq_projection` | MISSING | compatibilite projection |
| `dynamicParitySeparation_sameParityVisible` | MISSING | meme visible parite |
| `dynamicParitySeparation_separatedParityRegimes` | MISSING | separation regimes |
| `dynamicParitySeparation_refutesParityShortPresentation` | MISSING | refus short parite |
| `dynamicParitySeparation_parityNotContractible` | MISSING | non contractible |
| `dynamicParitySeparation_noParityProjectiveReconstruction` | MISSING | non reconstruction parite |
| `dynamicParitySeparation_leftRight` | TARGET | constructeur possible si orientation left/right |
| `dynamicParitySeparation_rightLeft` | TARGET | constructeur possible si orientation right/left |
| `OperationalParityRoles` | MISSING | extraire roles operationnels Nat |
| `operationalParityRolesOfDynamicParitySeparation` | MISSING | construction depuis raccord Nat |
| `operationalParityRoles_mediatedDynamicRoles` | MISSING | lien vers mediated roles |
| `operationalParityRoles_closingRegime` | MISSING | closing regime Nat |
| `operationalParityRoles_mediatingRegime` | MISSING | mediating regime Nat |
| `operationalParityRoles_closing_eq_formed` | MISSING | closing = formed |
| `operationalParityRoles_mediating_eq_shadow` | MISSING | mediating = shadow |
| `operationalParityRoles_sameVisible` | MISSING | meme visible |
| `operationalParityRoles_separated` | MISSING | separation |
| `operationalParityRoles_dynamicRepair` | MISSING | reparation dynamique |
| `operationalParityRoles_noParityVisibleReconstruction` | MISSING | non reconstruction |
| `operationalParityRoles_sameParityProjection` | MISSING | meme projection |
| `operationalParityRoles_refutesParityShortPresentation` | MISSING | refus short |
| `operationalParityRoles_parityNotContractible` | MISSING | non contractible |
| `operationalParityRoles_leftRight` | TARGET | constructeur possible |
| `operationalParityRoles_rightLeft` | TARGET | constructeur possible |

### OrderGap

| Declaration Core | Statut Nat enrichi | Cible / temoin Nat |
| --- | --- | --- |
| `VisiblePreorder` | MISSING | ordre visible sur payload ou terminal payload |
| `VisiblePartialOrder` | MISSING | antisymmetrie visible |
| `VisibleTotalOrder` | TARGET | seulement si necessaire |
| `VisibleOrder` | MISSING | alias visible |
| `VisibleOrderEquivalent` | MISSING | equivalence visible Nat |
| `visibleOrderEquivalent_refl` | TARGET | consommer si necessaire |
| `visible_eq_of_visibleOrderEquivalent` | MISSING | contraction visible |
| `OrderContractiveProjection` | MISSING | projection payload contractive a refuter |
| `projectionFiberFaithful_of_orderContractive` | MISSING | pont vers fiber faithful |
| `orderContractive_of_projectionFiberFaithful` | TARGET | si ordre partiel visible |
| `orderContractive_iff_projectionFiberFaithful` | TARGET | si equivalence complete exposee |
| `orderContractive_iff_contractibleReferentialGap` | MISSING | raccord au gap contractible |
| `orderContractive_iff_shortReferentialPresentation` | MISSING | raccord au short |
| `orderContractive_of_informationConserving` | TARGET | si conservation visible exposee |
| `structuralGap_visible_le_left_right` | MISSING | comparabilite visible formed/shadow |
| `structuralGap_visible_le_right_left` | MISSING | comparabilite visible shadow/formed |
| `structuralGap_visibleOrderEquivalent` | MISSING | equivalence visible structural |
| `structuralGap_visible_eq_of_partialOrder` | MISSING | egalite visible structural |
| `structuralGap_partialOrder_visible_eq_not_interface_eq` | MISSING | visible egal, interface separee |
| `visibleTotalOrder_project_comparable` | TARGET | si total order choisi |
| `structuralGap_not_orderContractive` | MISSING | refutation structural |
| `structuralLength_not_orderContractive` | MISSING | refutation length |
| `operationalGap_visible_le_formed_shadow` | MISSING | comparabilite operational |
| `operationalGap_visible_le_shadow_formed` | MISSING | comparabilite operational |
| `operationalGap_visibleOrderEquivalent` | MISSING | equivalence visible operational |
| `operationalGap_visible_eq_of_partialOrder` | MISSING | egalite visible operational |
| `operationalGap_partialOrder_visible_eq_not_interface_eq` | MISSING | visible egal, poles separes |
| `operationalGap_not_orderContractive` | MISSING | refutation operational |
| `operationalLength_not_orderContractive` | MISSING | refutation enriched operational length |
| `dynamicReturn_visible_le_formed_shadow` | MISSING | comparabilite dynamic return |
| `dynamicReturn_visible_le_shadow_formed` | MISSING | comparabilite dynamic return |
| `dynamicReturn_visibleOrderEquivalent` | MISSING | equivalence visible dynamic |
| `dynamicReturn_visible_eq_of_partialOrder` | MISSING | egalite visible dynamic |
| `dynamicReturn_partialOrder_visible_eq_not_interface_eq` | MISSING | visible egal, interface dynamique separee |
| `dynamicReturn_not_orderContractive` | MISSING | refutation dynamic |

## Consequence de l'audit

L'implementation devra avancer dans cet ordre strict :

```text
1. combler les PARTIAL utiles dans TwoPole / DynamicTwoPole ;
2. construire les roles enrichis Nat ;
3. construire DynamicRoleCarrier et MediatedDynamicRoles ;
4. construire DynamicParitySeparation et OperationalParityRoles ;
5. construire OrderGap Nat ;
6. seulement ensuite prouver pair / impair classique.
```

Les declarations marquees `TARGET` ne doivent pas forcement devenir des
nouveaux theoremes Nat nommes si elles sont seulement des projections internes.
Mais elles doivent etre consommees ou justifiees explicitement pendant
l'implementation, afin que rien du Core abstrait ne soit oublie.

Regle de passage :

```text
Une phase n'est terminee que si chaque declaration Core qu'elle mobilise a :

1. un temoin Lean Nat nomme ;
2. ou une consommation directe par un theoreme Nat nomme ;
3. ou une justification explicite disant que la declaration est seulement une
   projection interne deja consommee par 1 ou 2.
```

Cette regle interdit les couches seulement nominales. En particulier, la
couche pair / impair classique ne peut pas etre ajoutee avant que les roles
Nat enrichis, le carrier dynamique, la parite operationnelle et le test
ordonne aient ete raccordes a des objets Nat concrets.

## Fichiers cibles probables

Ne pas multiplier les fichiers sans facteur reel.

Fichiers existants a enrichir :

```text
Meta/Arithmetic/Core.lean
Meta/Arithmetic/GapContraction.lean
Meta/Arithmetic/TwoPole.lean
Meta/Dynamics/ObservedDynamicGap.lean
```

Nouveau fichier acceptable seulement si le facteur est reel :

```text
Meta/Arithmetic/Parity.lean
```

Ce fichier serait acceptable s'il contient toute la couche :

```text
Nat enriched roles
DynamicRoleCarrier instance
DynamicParitySeparation instance
OperationalParityRoles extraction
classical even / odd equivalence
```

Il ne serait pas acceptable s'il contient seulement des labels.

## Ordre d'implementation recommande

### Phase 1 : audit formel de couverture Core

Produire une table code/doc :

```text
Core declaration
Nat enriched declaration
status: done / partial / missing
```

Cette phase doit confirmer que rien du Core abstrait n'est oublie.

### Phase 2 : renforcer la couche two-pole arithmetique

Dans `Meta/Arithmetic/TwoPole.lean`, exposer toutes les projections et
consequences du two-pole arithmetique :

```text
formed pole
shadow pole
same visible
separated
repair
no reconstruction
```

### Phase 3 : lemmes terminaux `excess/value`

Ajouter les lemmes constructifs qui prouvent que les deux poles arithmetiques
ont vraiment les formes terminales :

```text
prefix ++ [excess k]
prefix ++ [value k]
```

Ces lemmes sont le verrou non trivial de toute la suite.

### Phase 4 : roles enrichis Nat

Introduire les roles enrichis en portant le payload :

```text
closingExcess k
mediatingValue k
```

Prouver :

```text
same role visible
separated roles
role repair on closing
no role visible reconstruction
```

### Phase 5 : DynamicRoleCarrier Nat

Construire l'instance :

```text
Nat enriched dynamic return
-> Nat enriched role two-pole
-> DynamicRoleCarrier
-> MediatedDynamicRoles
```

### Phase 6 : DynamicParitySeparation Nat

Raccorder les roles enrichis Nat a la parite separatrice minimale :

```text
closingExcess -> ParityRegime.left
mediatingValue -> ParityRegime.right
```

ou orientation opposee si elle est justifiee, mais toujours par preuve depuis
les poles enrichis.

### Phase 7 : OperationalParityRoles Nat

Extraire :

```text
closingRegime
mediatingRegime
sameVisible
separated
dynamicRepair
sameParityProjection
noParityVisibleReconstruction
```

Prouver que ces declarations sont les images des roles Nat enrichis, pas des
renommages.

### Phase 8 : OrderGap Nat

Instancier le test ordonne visible :

```text
visible order sees equality/comparability
enriched traces remain separated
order-contractive projection is refuted
```

### Phase 9 : pair / impair classique

Introduire l'encodage :

```text
closingExcess k  -> 2 * k
mediatingValue k -> 2 * k + 1
```

Puis prouver l'equivalence constructive avec les definitions classiques.

## Validation Lean obligatoire

Chaque fichier Lean modifie ou cree doit respecter :

```text
aucun axiom
aucun Classical
aucun propext
aucun Quot.sound
aucun sorry
un seul bloc AXIOM_AUDIT a la fin
```

Commandes minimales :

```bash
lake build Meta.Arithmetic.TwoPole
lake build Meta.Dynamics.ObservedDynamicGap
lake build
```

Si un nouveau fichier `Meta/Arithmetic/Parity.lean` est cree :

```bash
lake build Meta.Arithmetic.Parity
```

## Critere de reussite conceptuel

La tache est reussie seulement si l'on peut lire la chaine suivante dans le
code :

```text
Nat enriched trace
-> excess/value terminal distinction
-> same payload projection
-> separated enriched interfaces
-> local repair
-> operational two-pole
-> dynamic role carrier
-> mediated dynamic roles
-> dynamic parity separation
-> operational parity roles
-> classical even / odd equivalence
```

Et si la phrase suivante devient vraie formellement :

```text
La parite classique pair / impair est recuperee comme image arithmetique
constructive d'une separation operationnelle deja portee par Nat enrichi.
```
