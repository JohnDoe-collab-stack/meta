# Audit de precision

## Statut

Cet audit separe ce que le code certifie, ce que le code structure, ce que la
documentation peut interpreter, et ce qui ne doit pas etre affirme sans
formalisation supplementaire.

## Controle Lean

Verification effectuee :

```text
lake build
```

Resultat :

```text
Build completed successfully (1138 jobs).
```

Les avertissements observes viennent de la bibliotheque externe `Foundation`.
Le pont `Meta/Tarski/FoundationBridge.lean` depend des axiomes externes
attendus :

```text
propext
Classical.choice
Quot.sound
```

Les couches internes du gap et de la dynamique abstraite restent independantes
de ces axiomes.

## Noyau certifie

| Niveau | Declaration Lean | Statut |
|---|---|---|
| Gap local | `LocalProjectiveRecovery` | Certifie par le Core |
| Gap structurel | `StructuralReferentialGap` | Certifie par le Core |
| Gap operationnel | `OperationalReferentialGap` | Certifie par le Core |
| Non-reconstruction projective | `noProjectiveReconstructionOfLocalProjectiveRecovery` | Certifie par le Core |
| Retour dynamique forme | `FormedDynamicReturn` | Certifie par le Core |
| Retour dynamique recupere | `LocallyRecoveredDynamicReturn` | Certifie par le Core |
| Stabilite issue du retour | `locallyRecoveredClosedStabilityOfDynamicReturn` | Certifie par le Core |
| Preordre visible | `VisiblePreorder` | Certifie par le Core |
| Ordre partiel visible | `VisiblePartialOrder` | Certifie par le Core |
| Ordre total visible | `VisibleTotalOrder` | Certifie par le Core |
| Equivalence par ordre visible | `VisibleOrderEquivalent` | Certifie par le Core |
| Projection contractive par ordre | `OrderContractiveProjection` | Certifie par le Core |
| Contraction ordonnee vers fidelite de fibre | `projectionFiberFaithful_of_orderContractive` | Certifie par le Core |
| Fidelite de fibre vers contraction ordonnee | `orderContractive_of_projectionFiberFaithful` | Certifie par le Core |
| Equivalence ordre/fibre en ordre partiel | `orderContractive_iff_projectionFiberFaithful` | Certifie par le Core |
| Equivalence ordre/gap contractible | `orderContractive_iff_contractibleReferentialGap` | Certifie par le Core |
| Equivalence ordre/presentation courte | `orderContractive_iff_shortReferentialPresentation` | Certifie par le Core |
| Conservation globale vers contraction ordonnee | `orderContractive_of_informationConserving` | Certifie par le Core |
| Egalite visible par ordre partiel | `visible_eq_of_visibleOrderEquivalent` | Certifie par le Core |
| Comparabilite totale visible | `visibleTotalOrder_project_comparable` | Certifie par le Core |
| Refutation de la contraction ordonnee | `structuralGap_not_orderContractive` | Certifie par le Core |
| Refutation structurelle en longueur enrichie | `structuralLength_not_orderContractive` | Certifie par le Core |
| Refutation operationnelle de la contraction ordonnee | `operationalGap_not_orderContractive` | Certifie par le Core |
| Refutation operationnelle en longueur enrichie | `operationalLength_not_orderContractive` | Certifie par le Core |
| Retour dynamique vers gap operationnel | `dynamicReturn_operationalGap` | Certifie par le Core |
| Retour dynamique vers gap structurel | `dynamicReturn_structuralGap` | Certifie par le Core |
| Retour dynamique et equivalence visible | `dynamicReturn_visibleOrderEquivalent` | Certifie par le Core |
| Retour dynamique et egalite visible partielle | `dynamicReturn_visible_eq_of_partialOrder` | Certifie par le Core |
| Retour dynamique contre contraction ordonnee | `dynamicReturn_not_orderContractive` | Certifie par le Core |
| Retour dynamique contre presentation courte | `dynamicReturn_refutes_shortReferentialPresentation` | Certifie par le Core |

Controle cible :

```text
FormedDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
dynamicReturn_operationalGap
dynamicReturn_structuralGap
dynamicReturn_visibleOrderEquivalent
dynamicReturn_visible_eq_of_partialOrder
dynamicReturn_partialOrder_visible_eq_not_interface_eq
dynamicReturn_not_orderContractive
dynamicReturn_refutes_shortReferentialPresentation
```

Statut :

```text
does not depend on any axioms
```

## Dynamique observee

| Niveau | Declaration Lean | Statut |
|---|---|---|
| Collision observee comme retour forme | `observedFormedDynamicReturn` | Instance certifiee |
| Collision observee comme retour recupere | `observedLocallyRecoveredDynamicReturn` | Instance certifiee |
| Stabilite issue de la collision observee | `observedDynamicClosedStabilityRow` | Instance certifiee |
| Fenetre bornee comme retour forme | `observedBoundedWindowFormedDynamicReturn` | Instance certifiee |
| Fenetre bornee comme retour recupere | `observedBoundedWindowLocallyRecoveredDynamicReturn` | Instance certifiee |
| Stabilite issue de la fenetre bornee | `observedBoundedWindowDynamicClosedStabilityRow` | Instance certifiee |

Controle cible :

```text
observedFormedDynamicReturn
observedLocallyRecoveredDynamicReturn
observedDynamicClosedStabilityRow
observedBoundedWindowFormedDynamicReturn
observedBoundedWindowLocallyRecoveredDynamicReturn
observedBoundedWindowDynamicClosedStabilityRow
```

Statut :

```text
does not depend on any axioms
```

## Theorie des ordres

Le test d'ordre formalise une petite hierarchie interne :

```text
VisiblePreorder
VisiblePartialOrder
VisibleTotalOrder
```

Il isole le cas critique :

```text
visible ordonne
+ meme projection visible
+ comparabilite mutuelle visible
+ separation conservee de l'interface
```

Dans le code :

```lean
VisiblePreorder
VisiblePartialOrder
VisibleTotalOrder
VisibleOrderEquivalent
OrderContractiveProjection
projectionFiberFaithful_of_orderContractive
orderContractive_of_projectionFiberFaithful
orderContractive_iff_projectionFiberFaithful
orderContractive_iff_contractibleReferentialGap
orderContractive_iff_shortReferentialPresentation
orderContractive_of_informationConserving
visible_eq_of_visibleOrderEquivalent
structuralGap_visible_le_left_right
structuralGap_visible_le_right_left
structuralGap_visibleOrderEquivalent
structuralGap_visible_eq_of_partialOrder
structuralGap_partialOrder_visible_eq_not_interface_eq
visibleTotalOrder_project_comparable
structuralGap_not_orderContractive
structuralLength_not_orderContractive
operationalGap_visible_le_formed_shadow
operationalGap_visible_le_shadow_formed
operationalGap_visibleOrderEquivalent
operationalGap_visible_eq_of_partialOrder
operationalGap_partialOrder_visible_eq_not_interface_eq
operationalGap_not_orderContractive
operationalLength_not_orderContractive
dynamicReturn_operationalGap
dynamicReturn_structuralGap
dynamicReturn_visible_le_formed_shadow
dynamicReturn_visible_le_shadow_formed
dynamicReturn_visibleOrderEquivalent
dynamicReturn_visible_eq_of_partialOrder
dynamicReturn_partialOrder_visible_eq_not_interface_eq
dynamicReturn_not_orderContractive
dynamicReturn_refutes_shortReferentialPresentation
```

Lecture stricte :

```text
Un preordre visible peut comparer deux projections dans les deux sens.
Un ordre partiel visible peut identifier les valeurs projetees.
Cette identification visible ne suffit pas a identifier les interfaces formees.
```

Raccord au Core :

```text
En ordre partiel visible,
contraction ordonnee de l'interface
<->
fidelite de fibre de la projection.
```

Lecture en termes de gap :

```text
En ordre partiel visible,
contraction ordonnee de l'interface
<->
gap contractible.
```

Lecture en termes de longueur referentielle :

```text
En ordre partiel visible,
contraction ordonnee de l'interface
<->
presentation courte.
```

Lecture dynamique :

```text
Un retour dynamique localement recupere
-> porte un gap operationnel
-> donne une equivalence visible entre forme et ombre
-> refute la contraction ordonnee
-> refute la presentation courte.
```

Ce point ne pretend pas remplacer une theorie complete des ordres, mais il
verifie le mecanisme central : l'ordre visible peut devenir une contraction si
on lui demande de determiner l'egalite de l'interface.

Controle cible :

```text
VisiblePreorder
VisiblePartialOrder
VisibleTotalOrder
VisibleOrderEquivalent
OrderContractiveProjection
projectionFiberFaithful_of_orderContractive
orderContractive_of_projectionFiberFaithful
orderContractive_iff_projectionFiberFaithful
orderContractive_iff_contractibleReferentialGap
orderContractive_iff_shortReferentialPresentation
orderContractive_of_informationConserving
visible_eq_of_visibleOrderEquivalent
structuralGap_partialOrder_visible_eq_not_interface_eq
visibleTotalOrder_project_comparable
structuralGap_not_orderContractive
structuralLength_not_orderContractive
operationalGap_partialOrder_visible_eq_not_interface_eq
operationalGap_not_orderContractive
operationalLength_not_orderContractive
dynamicReturn_operationalGap
dynamicReturn_structuralGap
dynamicReturn_visibleOrderEquivalent
dynamicReturn_visible_eq_of_partialOrder
dynamicReturn_partialOrder_visible_eq_not_interface_eq
dynamicReturn_not_orderContractive
dynamicReturn_refutes_shortReferentialPresentation
```

Statut :

```text
does not depend on any axioms
```

## Tarski : longueur, ordre visibles et retour dynamique

La couche Tarski instancie maintenant trois consequences transverses du Core :

```text
obstruction diagonale de Tarski
-> gap operationnel
-> longueur referentielle enrichie
-> equivalence par ordre visible
-> refutation de la contraction ordonnee
-> retour diagonal forme
-> stabilite fermee recuperee depuis ce retour
```

Dans le code :

```lean
TarskiDiagonalObstruction.operationalLength
TarskiDiagonalObstruction.structuralLength
TarskiDiagonalObstruction.refutesShortPresentation
TarskiDiagonalObstruction.visible_le_formed_shadow
TarskiDiagonalObstruction.visible_le_shadow_formed
TarskiDiagonalObstruction.visibleOrderEquivalent
TarskiDiagonalObstruction.visible_eq_of_partialOrder
TarskiDiagonalObstruction.partialOrder_visible_eq_not_interface_eq
TarskiDiagonalObstruction.notOrderContractive
TarskiDiagonalObstruction.operationalLength_notOrderContractive
TarskiDiagonalReturnSource
TarskiProjectedDefinitionData
TarskiDiagonalIntersection
tarskiDiagonalIntersectionOfSource
tarskiIntersectionCanonical
tarskiBidirectionalCompleteness
tarskiRoundTripCoherence
tarskiFormedDynamicReturn
tarskiLocallyRecoveredDynamicReturn
tarskiLocallyRecoveredClosedStabilityOfDynamicReturn
tarskiDynamicReturn_operationalGap
tarskiDynamicReturn_structuralGap
tarskiDynamicReturn_visibleOrderEquivalent
tarskiDynamicReturn_visible_eq_of_partialOrder
tarskiDynamicReturn_partialOrder_visible_eq_not_interface_eq
tarskiDynamicReturn_notOrderContractive
tarskiDynamicReturn_refutesShortPresentation
```

Lecture stricte :

```text
Tarski instancie les consequences ordre/longueur deja prouvees dans le Core.
La syntaxe visible peut etre identifiee apres projection.
Cette identification visible ne contracte pas les interfaces formees.
Le retour dynamique Tarski part des donnees diagonales productrices, forme une
intersection typee, puis consomme le Core dynamique abstrait.
```

Controle cible :

```text
TarskiDiagonalObstruction.operationalLength
TarskiDiagonalObstruction.structuralLength
TarskiDiagonalObstruction.refutesShortPresentation
TarskiDiagonalObstruction.visibleOrderEquivalent
TarskiDiagonalObstruction.visible_eq_of_partialOrder
TarskiDiagonalObstruction.partialOrder_visible_eq_not_interface_eq
TarskiDiagonalObstruction.notOrderContractive
TarskiDiagonalObstruction.operationalLength_notOrderContractive
TarskiDiagonalReturnSource
TarskiProjectedDefinitionData
TarskiDiagonalIntersection
tarskiFormedDynamicReturn
tarskiLocallyRecoveredDynamicReturn
tarskiLocallyRecoveredClosedStabilityOfDynamicReturn
tarskiDynamicReturn_operationalGap
tarskiDynamicReturn_visibleOrderEquivalent
tarskiDynamicReturn_visible_eq_of_partialOrder
tarskiDynamicReturn_partialOrder_visible_eq_not_interface_eq
tarskiDynamicReturn_notOrderContractive
tarskiDynamicReturn_refutesShortPresentation
```

Statut :

```text
La ligne ordre/longueur ne depend d'aucun axiome.
Les donnees source/intersection du retour dynamique ne dependent d'aucun axiome.
Les consequences dynamiques recuperees dependent de `propext` via
`tarskiRoundTripCoherence`.
```

## Architecture

| Point | Statut |
|---|---|
| `Meta/Core/DynamicStability.lean` depend de `Meta.Core.Gap` | Correct |
| `Meta/Core/DynamicStability.lean` ne depend pas de `Meta.Dynamics` | Correct |
| `Meta/Core/DynamicStability.lean` ne depend pas de `Meta.Arithmetic` | Correct |
| `Meta/Core/DynamicStability.lean` ne depend pas de `Meta.Tarski` | Correct |
| `Meta/Tarski/ReferentialOrder.lean` instancie la longueur et l'ordre du Core | Correct |
| `Meta/Tarski/DynamicReturn.lean` instancie le retour dynamique du Core | Correct |
| Les couches observees instancient le schema abstrait | Correct |
| Le pont Foundation/Tarski reste dans la couche Tarski externe | Correct |

## Discipline des affirmations

| Formulation | Statut | Commentaire |
|---|---|---|
| Le gap porte une mediation constructive entre referentiels. | Soutenu | C'est la lecture du triplet projection, separation, recuperation locale. |
| Le retour dynamique produit une stabilite fermee recuperee. | Certifie au niveau abstrait et pour les instances codees | Le schema abstrait et les instances observees sont presents. |
| L'egalite visible est un cas contracte de la mediation. | Soutenu | A dire comme lecture structurelle, pas comme unique definition de l'egalite. |
| Tarski apparait comme un cas diagonal particulier. | Soutenu dans le cadre | Le code fournit `TarskiDiagonalObstruction` comme gap operationnel. |
| Tarski instancie une longueur referentielle enrichie. | Certifie dans la couche Tarski | Le code donne `TarskiDiagonalObstruction.operationalLength` et `refutesShortPresentation`. |
| Tarski instancie les consequences d'ordre visible du Core. | Certifie dans la couche Tarski | Le code donne `visibleOrderEquivalent`, `partialOrder_visible_eq_not_interface_eq` et `notOrderContractive`. |
| Tarski instancie le retour dynamique forme. | Certifie dans la couche Tarski | Le code donne `tarskiFormedDynamicReturn`, `tarskiLocallyRecoveredDynamicReturn` et les consequences dynamiques d'ordre et de presentation courte. |
| Beth mesure la lisibilite visible d'une propriete enrichie. | Certifie dans la couche Beth | Le code donne `BethSeparation`, `ExplicitDefinitionOnVisible` et la refutation du collapse par separation de propriete. |
| Bell fournit une instance pre-probabiliste. | Soutenu | Le code traite co-indexation, compatibilite et obstruction d'amalgamation. |
| Un ordre visible ne suffit pas a contracter une interface formee. | Certifie au niveau abstrait | Le Core refute `OrderContractiveProjection` en presence d'un gap structurel ou operationnel. |
| Un ordre partiel visible identifie les projections, pas les interfaces formees. | Certifie au niveau abstrait | Le Core donne `structuralGap_partialOrder_visible_eq_not_interface_eq` et `operationalGap_partialOrder_visible_eq_not_interface_eq`. |
| La contraction ordonnee est le test de fidelite de fibre en ordre partiel. | Certifie au niveau abstrait | Le Core donne `orderContractive_iff_projectionFiberFaithful`. |
| La contraction ordonnee est le regime gap contractible en ordre partiel. | Certifie au niveau abstrait | Le Core donne `orderContractive_iff_contractibleReferentialGap`. |
| La contraction ordonnee est la presentation courte en ordre partiel. | Certifie au niveau abstrait | Le Core donne `orderContractive_iff_shortReferentialPresentation`. |
| Un retour dynamique localement recupere porte un gap operationnel. | Certifie au niveau abstrait | Le Core donne `dynamicReturn_operationalGap`. |
| Un retour dynamique localement recupere refute la contraction ordonnee. | Certifie au niveau abstrait | Le Core donne `dynamicReturn_not_orderContractive`. |
| Un retour dynamique localement recupere refute la presentation courte. | Certifie au niveau abstrait | Le Core donne `dynamicReturn_refutes_shortReferentialPresentation`. |
| Un ordre total visible totalise les projections. | Certifie au niveau abstrait | Le Core donne `visibleTotalOrder_project_comparable`, sans en faire une totalisation de l'interface. |
| Toute incomparabilite vient d'un gap. | Non certifie actuellement | Le code traite la contraction par ordre visible, pas toutes les incomparabilites possibles. |
| Tsirelson est un gap operationnel complet. | Non certifie actuellement | La documentation doit garder le statut certifie actuel : gap structure par borne. |
| La loi des grands nombres est demontree par le cadre. | Non certifie actuellement | Pour l'instant, c'est une lecture structurelle, pas un theoreme Lean du projet. |
| Les nombres complexes sont formalises comme instance du gap. | Non certifie actuellement | Pour l'instant, c'est une interpretation possible, pas une instance Lean. |
| Le cadre remplace les mathematiques classiques. | Non certifie actuellement | Le cadre organise une mediation plus fine ; il ne remplace pas les theories existantes. |

## Formulations sures

```text
Le gap n'est pas seulement une obstruction de contraction.
Il porte la mediation constructive entre un visible projete et une interface
formee.
```

```text
La dynamique donne une lecture positive du gap : le retour observable devient
une source formee, une intersection typee, puis une stabilite fermee recuperee.
```

```text
Tarski est traite comme une instance diagonale du schema projectif, pas comme
le point de depart conceptuel du cadre.
```

```text
Dans un referentiel ordonne visible, la comparabilite mutuelle des projections
ne suffit pas a contracter l'interface formee.
```

```text
Dans un retour dynamique localement recupere, la forme et son ombre peuvent
etre identifiees au niveau visible tout en restant separees comme interfaces.
```

## Formulations a surveiller

```text
prouve que toutes les mathematiques viennent du gap
```

```text
resout la loi des grands nombres
```

```text
formalise les nombres complexes
```

```text
fait venir toute incomparabilite d'un gap
```

```text
fait de Tsirelson une instance operationnelle complete
```

Ces phrases depassent l'etat actuel du code. Elles peuvent etre remplacees par
des formulations de lecture structurelle lorsque le projet ne contient pas
encore l'instance Lean correspondante.
