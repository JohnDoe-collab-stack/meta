# Plan d'integration Tarski / Core

## Objectif

Ce document prepare l'integration de deux couches du `Core` dans le dossier
`Meta/Tarski` :

1. la longueur referentielle ;
2. la theorie des ordres visibles.

Le but n'est pas de modifier le contenu diagonal de Tarski. Le but est de
montrer que l'obstruction diagonale deja formalisee consomme davantage du noyau
abstrait :

```text
Tarski diagonal obstruction
-> gap operationnel
-> longueur referentielle enrichie
-> refutation de la presentation courte
-> refutation de la contraction ordonnee visible
```

La couche `Core` doit rester abstraite. Les noms `Tarski`, `Beth`, `Bell` ou
autres instances ne doivent pas remonter dans `Meta/Core`.

## Etat actuel

Le dossier `Meta/Tarski` exploite deja le noyau projectif principal.

Dans `Meta/Tarski/TruthGap.lean`, une obstruction diagonale contient :

```lean
formed : Meaning
shadow : Meaning
sameSyntax : project formed = project shadow
truth_formed : Truth formed
shadow_not_truth : Truth shadow -> False
```

Elle donne deja :

```lean
TarskiDiagonalObstruction.localRecovery
TarskiDiagonalObstruction.localTruthGapRecovery
TarskiDiagonalObstruction.notFiberFaithful
TarskiDiagonalObstruction.notInformationConserving
TarskiDiagonalObstruction.noProjectiveReconstruction
TarskiDiagonalObstruction.localFormationProjectedTruthIndependent
```

Dans `Meta/Tarski/GapContraction.lean`, elle est deja exposee comme :

```lean
TarskiDiagonalObstruction.structuralGap
TarskiDiagonalObstruction.operationalGap
TarskiDiagonalObstruction.notContractible
TarskiDiagonalObstruction.notInformationConservingByContraction
TarskiDiagonalObstruction.truthGapRecoveryOfDiagonalObstruction
```

Avant cette implementation, la longueur referentielle apparaissait seulement
dans la synthese :

```lean
tarskiBethBell_tarskiOperationalLength
tarskiBethBell_tarskiRefutesShortPresentation
```

Elle est maintenant disponible comme couche Tarski propre dans
`Meta/Tarski/ReferentialOrder.lean`.

La theorie des ordres visibles est maintenant instanciee pour Tarski dans le
meme fichier.

## Fichier propose

Ajouter un fichier dedie :

```text
Meta/Tarski/ReferentialOrder.lean
```

Imports proposes :

```lean
import Meta.Core.OrderGap
import Meta.Tarski.GapContraction
```

Raison :

`Meta.Core.OrderGap` importe deja la longueur referentielle et la dynamique
abstraite dont il a besoin. `Meta.Tarski.GapContraction` fournit l'obstruction
tarskienne comme gap operationnel.

Le fichier doit rester une couche d'instance :

```text
Core -> Tarski
```

Il ne doit introduire aucun import de `Meta.Tarski` dans `Meta/Core`.

## Validation du plan

Les fragments Lean proposes dans ce document ont ete testes dans un fichier
temporaire avec les imports suivants :

```lean
import Meta.Core.OrderGap
import Meta.Tarski.GapContraction
```

Le test compile. Les noms proposes sont donc directement implementables sous
reserve de ne pas entrer en conflit avec une future declaration ajoutee entre
temps.

## Statut d'implementation

Implementation realisee dans :

```text
Meta/Tarski/ReferentialOrder.lean
```

Import global ajoute dans :

```text
Meta.lean
```

Les declarations suivent les noms prepares ci-dessous.

## Partie 1 : longueur referentielle de Tarski

Ajouter dans le namespace existant :

```lean
namespace Meta
namespace ClosedStabilityTheorem

universe u v
```

Definitions proposees :

```lean
def TarskiDiagonalObstruction.operationalLength
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    EnrichedOperationalReferentialLength
      Meaning
      Syntax
      project
      (@TarskiTruthRepair Meaning) :=
  gap.operationalGap
```

```lean
def TarskiDiagonalObstruction.structuralLength
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    EnrichedStructuralReferentialLength Meaning Syntax project :=
  structuralLengthOfOperationalLength gap.operationalLength
```

Theoreme propose :

```lean
theorem TarskiDiagonalObstruction.refutesShortPresentation
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (short :
      ShortReferentialPresentation Meaning Syntax project) :
    False :=
  operationalLength_refutes_shortPresentation
    gap.operationalLength
    short
```

Ce que cette partie expose :

```text
La couche Tarski n'est pas seulement exposee comme gap operationnel.
Elle est aussi exposee comme longueur referentielle enrichie refutant la
presentation courte.
```

Cela deplace la lecture :

```text
syntax determines truth
```

vers :

```text
visible syntax is too short to carry the formed semantic interface
```

## Partie 2 : ordres visibles de Tarski

La couche ordre ne doit pas supposer que `Syntax` possede naturellement un
ordre canonique. Elle doit rester parametree par un ordre visible donne par
l'utilisateur.

Definitions/theoremes proposes :

```lean
theorem TarskiDiagonalObstruction.visible_le_formed_shadow
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePreorder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    order.le (project gap.formed) (project gap.shadow) :=
  operationalGap_visible_le_formed_shadow
    order
    gap.operationalGap
```

```lean
theorem TarskiDiagonalObstruction.visible_le_shadow_formed
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePreorder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    order.le (project gap.shadow) (project gap.formed) :=
  operationalGap_visible_le_shadow_formed
    order
    gap.operationalGap
```

```lean
theorem TarskiDiagonalObstruction.visibleOrderEquivalent
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePreorder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    VisibleOrderEquivalent
      order
      (project gap.formed)
      (project gap.shadow) :=
  operationalGap_visibleOrderEquivalent
    order
    gap.operationalGap
```

Pour un ordre partiel visible :

```lean
theorem TarskiDiagonalObstruction.visible_eq_of_partialOrder
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePartialOrder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    project gap.formed = project gap.shadow :=
  operationalGap_visible_eq_of_partialOrder
    order
    gap.operationalGap
```

```lean
theorem TarskiDiagonalObstruction.partialOrder_visible_eq_not_interface_eq
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePartialOrder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    project gap.formed = project gap.shadow ∧
      (gap.formed = gap.shadow -> False) :=
  operationalGap_partialOrder_visible_eq_not_interface_eq
    order
    gap.operationalGap
```

Refutation de la contraction ordonnee :

```lean
theorem TarskiDiagonalObstruction.notOrderContractive
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    {order : VisiblePreorder Syntax}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (contractive :
      OrderContractiveProjection Meaning Syntax project order) :
    False :=
  operationalGap_not_orderContractive
    gap.operationalGap
    contractive
```

Version longueur referentielle :

```lean
theorem TarskiDiagonalObstruction.operationalLength_notOrderContractive
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    {order : VisiblePreorder Syntax}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (contractive :
      OrderContractiveProjection Meaning Syntax project order) :
    False :=
  operationalLength_not_orderContractive
    gap.operationalLength
    contractive
```

Ce que cette partie expose :

```text
La syntaxe visible peut identifier ou rendre comparables les deux faces.
Le cadre conserve pourtant leur separation d'interface.
```

La lecture obtenue ajoute une couche transverse a la non-definissabilite :

```text
ordre visible
+ meme projection syntaxique
+ equivalence visible
+ separation semantique conservee
```

Tarski devient ainsi un cas ou l'ordre visible compare, et dans un ordre
partiel identifie, les projections syntaxiques, tandis que le gap operationnel
conserve la separation des interfaces et refute la contraction ordonnee.

## Mise a jour des imports globaux

Ajouter dans `Meta.lean` :

```lean
import Meta.Tarski.ReferentialOrder
```

Position recommandee : apres `Meta.Tarski.GapContraction` et avant les couches
de synthese qui comparent Tarski avec Beth/Bell.

## Audit axiomes

Ajouter un bloc d'audit dans le nouveau fichier :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.operationalLength
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.structuralLength
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.refutesShortPresentation
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.visible_eq_of_partialOrder
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.partialOrder_visible_eq_not_interface_eq
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.notOrderContractive
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.operationalLength_notOrderContractive
/- AXIOM_AUDIT_END -/
```

Statut attendu :

```text
does not depend on any axioms
```

## Verification

Commandes a lancer :

```text
lake build
rg -n "import Meta.Tarski|Tarski|Beth|Bell|Tsirelson|arithmetic" Meta/Core
```

Resultat attendu :

```text
Build completed successfully
```

et aucune reference d'instance dans `Meta/Core`.

## Documentation apres implementation

Apres implementation, mettre a jour :

```text
Docs/PrecisionAudit.md
Docs/GapOperatorPresentation.md
Docs/GapOperatorPresentation.en.md
README.md
```

Point a dire sobrement :

```text
Tarski is now also exposed as an enriched referential-length row and as a
visible-order row refuting contraction.
```

Point a eviter :

```text
Tarski proves a new order theorem by itself.
```

La formulation correcte est :

```text
The Tarski diagonal gap instantiates the order-sensitive consequences already
proved in the abstract Core.
```

## Limite volontaire

Ce plan n'integre pas encore la dynamique tarskienne.

Raison : la dynamique demande une source diagonale formee explicite. Elle ne
doit pas etre ajoutee comme simple emballage de l'obstruction existante.

La dynamique devra faire l'objet d'un second plan si l'on veut formaliser :

```text
retour diagonal
-> intersection typee
-> interface formee
-> recovery local
-> stabilite fermee
```
