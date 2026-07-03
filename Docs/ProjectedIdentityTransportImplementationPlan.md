# Implementation plan: interface equality transport

## Objectif

Formaliser dans `Meta/Core/ProjectedIdentity.lean` toute la partie explicite du
document :

```text
q(x) = q(y)
-> Id_use(x, y)
-> transport par lecture
-> coordination de la chaine longue
```

Terminologie conceptuelle a stabiliser :

```text
interface-induced observational equivalence
```

Dans le code Lean, cette notion reste nommee techniquement :

```text
ProjectedIdentity
```

Le plan ne demande donc pas de renommer les definitions. Il demande de rendre
explicite que `ProjectedIdentity` est l'equivalence observationnelle induite
par l'interface, et que `InterfaceTransport` en est la forme operatoire.

Sans creer de nouveau fichier Lean.

Le but n'est pas seulement d'ajouter le transport minimal.

Le but est de rendre auditable dans le noyau existant :

```text
separation interne
+
identite d'usage projective
+
transport par lecture
```

et aussi :

```text
ProjectedIdentityCell
-> IdentityOfUseCell
-> ConstructiveInterfaceChain
```

puis, pour une relaxation contrainte deja presente dans le fichier :

```text
chaine d'entree
+ chaine de sortie
+ shift visible entre regimes
```

## Fichier cible

```text
Meta/Core/ProjectedIdentity.lean
```

Le fichier importe deja :

```lean
import Meta.Core.ClosedStabilityTheorem
```

Aucun nouvel import ne doit etre ajoute.

## Contraintes

L'implementation doit rester :

```text
constructive
sans axiome
sans Classical
sans propext
sans Quot
sans nouveau fichier Lean
```

Le bloc `AXIOM_AUDIT` existant doit etre mis a jour a la fin du fichier.

## Position dans le fichier

Ajouter les nouvelles facades juste apres :

```lean
theorem interfaceIdentityOfUse_iff_projectedIdentity
```

et avant :

```lean
structure IdentityOfUseCell
```

Raison : le transport depend seulement de :

```lean
ProjectedIdentity
InterfaceIdentityOfUse
```

et ne depend pas encore des cellules.

Les facades sur cellule peuvent etre ajoutees apres :

```lean
theorem projectedIdentityCell_internalDifference_usedIdentity
```

Raison : elles utilisent `ProjectedIdentityCell`, `InterfaceIdentityOfUse` et le
transport par lecture.

## Declaration 1 : transport lu par interface

Ajouter :

```lean
/--
Read transport induced by an interface projection.

This is the Lean form of `r(q(x)) = r(q(y))`.
-/
abbrev InterfaceReadTransport
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    (project : Interface -> Visible)
    (read : Visible -> Label)
    (left right : Interface) :
    Prop :=
  read (project left) = read (project right)
```

Lecture :

```text
Transport_q^L(x, y)
```

avec `L := Label`.

## Declaration 2 : transport depuis identite projective

Ajouter :

```lean
/-- A projected identity transports through every fixed reading. -/
theorem interfaceReadTransportOfProjectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    {read : Visible -> Label}
    {left right : Interface}
    (identity : ProjectedIdentity project left right) :
    InterfaceReadTransport project read left right :=
  congrArg read identity
```

Lecture :

```text
Id_q(x, y) -> r(q(x)) = r(q(y))
```

## Declaration 3 : transport depuis identite d'usage

Ajouter :

```lean
/-- An identity of use transports through every fixed reading. -/
theorem interfaceReadTransportOfIdentityOfUse
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    {read : Visible -> Label}
    {left right : Interface}
    (identity : InterfaceIdentityOfUse project left right) :
    InterfaceReadTransport project read left right :=
  interfaceReadTransportOfProjectedIdentity identity
```

Lecture :

```text
Id_use(x, y) -> r(q(x)) = r(q(y))
```

## Declaration 4 : retour du transport identite vers identite projective

Ajouter :

```lean
/--
Identity reading transport is exactly projected identity.

This is the local Lean version of the fact that polymorphic `Transport_q`
recovers `Id_q` by taking `L := V` and `r := id`.
-/
theorem interfaceReadTransport_id_iff_projectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (left right : Interface) :
    InterfaceReadTransport project (fun visible => visible) left right <->
      ProjectedIdentity project left right :=
  Iff.rfl
```

Lecture :

```text
Transport_q(x, y) -> Id_q(x, y)
```

via la lecture identite.

Cette declaration evite de tenter d'encoder une quantification polymorphe
inutilement lourde dans Lean.

Elle prouve exactement le point dont on a besoin :

```text
Transport_q n'ajoute pas une hypothese differente ;
il est Id_q vu comme principe d'action.
```

## Declaration 4 bis : transport polymorphe complet

Le document parle aussi de :

```text
Transport_q(x, y) :=
  forall {L} (r : V -> L),
    r(q(x)) = r(q(y))
```

On peut l'encoder dans Lean au meme univers que `Visible` :

```lean
/--
Polymorphic interface transport.

This is `Id_q` seen as its full action on readings.
-/
abbrev InterfaceTransport
    {Interface : Type u}
    {Visible : Type v}
    (project : Interface -> Visible)
    (left right : Interface) :
    Prop :=
  forall {Label : Type v} (read : Visible -> Label),
    InterfaceReadTransport project read left right
```

Ajouter ensuite :

```lean
/-- Projected identity gives polymorphic interface transport. -/
theorem interfaceTransportOfProjectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {left right : Interface}
    (identity : ProjectedIdentity project left right) :
    InterfaceTransport project left right :=
  fun read => interfaceReadTransportOfProjectedIdentity identity

/-- Polymorphic interface transport recovers projected identity. -/
theorem projectedIdentityOfInterfaceTransport
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {left right : Interface}
    (transport : InterfaceTransport project left right) :
    ProjectedIdentity project left right :=
  transport (fun visible => visible)

/-- Polymorphic transport is exactly projected identity. -/
theorem interfaceTransport_iff_projectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (left right : Interface) :
    InterfaceTransport project left right <->
      ProjectedIdentity project left right :=
  Iff.intro
    projectedIdentityOfInterfaceTransport
    interfaceTransportOfProjectedIdentity

/-- Identity of use gives polymorphic interface transport. -/
theorem interfaceTransportOfIdentityOfUse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {left right : Interface}
    (identity : InterfaceIdentityOfUse project left right) :
    InterfaceTransport project left right :=
  interfaceTransportOfProjectedIdentity identity
```

Lecture :

```text
Transport_q n'est pas une hypothese ajoutee.
Transport_q <-> Id_q.
Transport_q est Id_q comme principe d'action.
```

## Declaration 5 : transport lu d'une cellule projective

Ajouter apres `projectedIdentityCell_internalDifference_usedIdentity` :

```lean
/-- A projected identity cell transports through every fixed reading. -/
theorem projectedIdentityCell_readTransport
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    (read : Visible -> Label)
    (cell : ProjectedIdentityCell Interface Visible project) :
    InterfaceReadTransport project read cell.formed cell.shadow :=
  interfaceReadTransportOfIdentityOfUse
    (projectedIdentityCell_identityOfUse cell)
```

Lecture :

```text
ProjectedIdentityCell
-> Transport_q^L(formed, shadow)
```

## Declaration 6 : transport depuis une cellule d'identite d'usage

Ajouter :

```lean
/-- An identity-of-use cell transports through every fixed reading. -/
theorem identityOfUseCell_readTransport
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    (read : Visible -> Label)
    (cell : IdentityOfUseCell Interface Visible project) :
    InterfaceReadTransport project read cell.formed cell.shadow :=
  interfaceReadTransportOfIdentityOfUse cell.usedIdentity
```

Lecture :

```text
IdentityOfUseCell
-> Transport_q^L(formed, shadow)
```

Cela evite que la dynamique reste seulement attachee a
`ProjectedIdentityCell`. Elle est aussi disponible depuis la cellule qui porte
directement `Id_use`.

## Declaration 7 : chaine dynamique complete

Ajouter :

```lean
/- The constructive chain carried by an interface equality. -/
abbrev ConstructiveInterfaceChain
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    (project : Interface -> Visible)
    (read : Visible -> Label)
    (left right : Interface) :
    Prop :=
  And
    (InternalIdentity project left right -> False)
    (And
      (InterfaceIdentityOfUse project left right)
      (InterfaceReadTransport project read left right))

/--
A projected identity cell carries the constructive chain:
internal separation, identity of use, and read transport.
-/
theorem projectedIdentityCell_constructiveChain
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    (read : Visible -> Label)
    (cell : ProjectedIdentityCell Interface Visible project) :
    ConstructiveInterfaceChain project read cell.formed cell.shadow :=
  And.intro
    (projectedIdentityCell_notInternalIdentity cell)
    (And.intro
      (projectedIdentityCell_identityOfUse cell)
      (projectedIdentityCell_readTransport read cell))
```

Lecture :

```text
separation interne
+
Id_use
+
transport par lecture
```

C'est la facade Lean directe de :

```text
q(x) = q(y)
-> Id_use(x, y)
-> transport par lecture
-> coordination de la chaine longue
```

Ajouter aussi la version depuis `IdentityOfUseCell` :

```lean
/-- An identity-of-use cell carries the constructive chain directly. -/
theorem identityOfUseCell_constructiveChain
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    (read : Visible -> Label)
    (cell : IdentityOfUseCell Interface Visible project) :
    ConstructiveInterfaceChain project read cell.formed cell.shadow :=
  And.intro
    cell.internalSeparation
    (And.intro
      cell.usedIdentity
      (identityOfUseCell_readTransport read cell))
```

## Declaration 8 : transport polymorphe de cellule

Ajouter :

```lean
/-- A projected identity cell carries full polymorphic transport. -/
theorem projectedIdentityCell_interfaceTransport
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : ProjectedIdentityCell Interface Visible project) :
    InterfaceTransport project cell.formed cell.shadow :=
  interfaceTransportOfIdentityOfUse
    (projectedIdentityCell_identityOfUse cell)

/-- An identity-of-use cell carries full polymorphic transport. -/
theorem identityOfUseCell_interfaceTransport
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : IdentityOfUseCell Interface Visible project) :
    InterfaceTransport project cell.formed cell.shadow :=
  interfaceTransportOfIdentityOfUse cell.usedIdentity
```

Lecture :

```text
la cellule ne porte pas seulement une lecture particuliere ;
elle porte Id_q comme principe d'action sur toutes les lectures.
```

## Declaration 9 : dynamique de relaxation contrainte

Le fichier contient deja :

```lean
ConstrainedProjectionRelaxation
```

Cette structure est le niveau ou la dynamique entre regimes doit etre exposee.

Ajouter :

```lean
/-- Input constructive chain carried by a constrained relaxation. -/
def constructiveChainInOfConstrainedRelaxation
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    ConstructiveInterfaceChain
      projectIn
      readIn
      relaxation.formed
      relaxation.shadow :=
  projectedIdentityCell_constructiveChain
    readIn
    (projectedIdentityCellInOfConstrainedRelaxation relaxation)

/-- Output constructive chain carried by a constrained relaxation. -/
def constructiveChainOutOfConstrainedRelaxation
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    ConstructiveInterfaceChain
      projectOut
      readOut
      relaxation.formed
      relaxation.shadow :=
  projectedIdentityCell_constructiveChain
    readOut
    (projectedIdentityCellOutOfConstrainedRelaxation relaxation)
```

Puis exposer la variation de regime complete :

```lean
/--
A constrained relaxation carries input chain, output chain, and visible shift.
-/
theorem constrainedProjectionRelaxation_constructiveRegimeChange
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    And
      (ConstructiveInterfaceChain
        projectIn
        readIn
        relaxation.formed
        relaxation.shadow)
      (And
        (ConstructiveInterfaceChain
          projectOut
          readOut
          relaxation.formed
          relaxation.shadow)
        (readIn (projectIn relaxation.formed) =
          readOut (projectOut relaxation.formed) -> False)) :=
  And.intro
    (constructiveChainInOfConstrainedRelaxation relaxation)
    (And.intro
      (constructiveChainOutOfConstrainedRelaxation relaxation)
      relaxation.visibleShift)
```

Lecture :

```text
entree  : separation + Id_use + transport
sortie  : separation + Id_use + transport
shift   : changement visible de regime
```

C'est le point qui manquait au plan minimal : la dynamique n'est pas seulement
le transport dans un regime fixe, elle est aussi le passage entre les deux
regimes d'une relaxation contrainte.

## Mise a jour du document

Dans :

```text
Docs/EqualityAsConstructiveChainWorkingNotes.md
```

remplacer le passage :

```text
Une facade nommee peut rendre le transport plus explicite
```

par une mention indiquant que les facades Lean sont :

```text
InterfaceReadTransport
InterfaceTransport
interfaceReadTransportOfProjectedIdentity
interfaceReadTransportOfIdentityOfUse
interfaceReadTransport_id_iff_projectedIdentity
interfaceTransportOfProjectedIdentity
projectedIdentityOfInterfaceTransport
interfaceTransport_iff_projectedIdentity
interfaceTransportOfIdentityOfUse
projectedIdentityCell_readTransport
identityOfUseCell_readTransport
ConstructiveInterfaceChain
projectedIdentityCell_constructiveChain
identityOfUseCell_constructiveChain
projectedIdentityCell_interfaceTransport
identityOfUseCell_interfaceTransport
constructiveChainInOfConstrainedRelaxation
constructiveChainOutOfConstrainedRelaxation
constrainedProjectionRelaxation_constructiveRegimeChange
```

## Audit Lean

Ajouter les nouvelles declarations au bloc final :

```lean
#print axioms Meta.ClosedStabilityTheorem.InterfaceReadTransport
#print axioms Meta.ClosedStabilityTheorem.InterfaceTransport
#print axioms Meta.ClosedStabilityTheorem.interfaceReadTransportOfProjectedIdentity
#print axioms Meta.ClosedStabilityTheorem.interfaceReadTransportOfIdentityOfUse
#print axioms Meta.ClosedStabilityTheorem.interfaceReadTransport_id_iff_projectedIdentity
#print axioms Meta.ClosedStabilityTheorem.interfaceTransportOfProjectedIdentity
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityOfInterfaceTransport
#print axioms Meta.ClosedStabilityTheorem.interfaceTransport_iff_projectedIdentity
#print axioms Meta.ClosedStabilityTheorem.interfaceTransportOfIdentityOfUse
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCell_readTransport
#print axioms Meta.ClosedStabilityTheorem.identityOfUseCell_readTransport
#print axioms Meta.ClosedStabilityTheorem.ConstructiveInterfaceChain
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCell_constructiveChain
#print axioms Meta.ClosedStabilityTheorem.identityOfUseCell_constructiveChain
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCell_interfaceTransport
#print axioms Meta.ClosedStabilityTheorem.identityOfUseCell_interfaceTransport
#print axioms Meta.ClosedStabilityTheorem.constructiveChainInOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.constructiveChainOutOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.constrainedProjectionRelaxation_constructiveRegimeChange
```

## Verification

Executer :

```bash
lake build Meta.Core.ProjectedIdentity
lake env lean Meta.lean
```

Puis verifier que l'audit n'affiche :

```text
aucun axiome
aucune dependance a Classical
aucune dependance a propext
aucune dependance a Quot.sound
```

## Cible conceptuelle atteinte

L'implementation doit permettre de lire directement dans Lean :

```text
Id_q          = equivalence observationnelle induite par l'interface
Transport_q  = meme equivalence vue comme principe d'action
```

et :

```text
ProjectedIdentityCell
-> separation interne
-> Id_use
-> transport par lecture
```

Donc la dynamique est bien capturee :

```text
egalite projective
-> identite d'usage
-> transport
-> chaine constructive
-> regime change dans ConstrainedProjectionRelaxation
```
