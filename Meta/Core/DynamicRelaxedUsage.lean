import Meta.Core.DynamicCore
import Meta.Core.StrictRelaxation

/-!
# Dynamic synthesis of relaxed usage

This module links bilateral dynamic returns to relaxed, non-identitarian use.
The current projective gap generates a proof-relevant coordination, the
coordination and separation generate an authorized use, and that use generates
the permitted formed and visible transports. A gap-driven transition consumes
the complete causal state carrying the bilateral memory and both transports.
-/

namespace Meta
namespace DynamicRelaxedUsage

universe u v w a x y z r s

open ClosedStabilityTheorem
open RelaxedUsageRegime

/-! ## Intrinsic return families -/

/--
An intrinsic atlas of locally recovered dynamic returns.

The atlas carries all returns but no transition. The transition is introduced
only after the gap-generated use and its bilateral memory have been built.
-/
structure IntrinsicDynamicReturnFamily
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    (branch : Branch)
    (Source : Type a)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z)
    (Visible : Type r)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) where
  initial : Source
  returnAt :
    (source : Source) ->
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
        RepairOf
  returnAt_source :
    (source : Source) ->
      (returnAt source).formedReturn.source = source

namespace IntrinsicDynamicReturnFamily

variable
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}

variable
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)

/-- The intersection produced at a source. -/
def intersectionAt (source : Source) : complete.Intersection branch :=
  (family.returnAt source).formedReturn.intersection

/-- The formed pole recovered at a source. -/
def formedAt (source : Source) : Interface :=
  (family.returnAt source).localRecovery.formed

/-- The projectively coordinated shadow at a source. -/
def shadowAt (source : Source) : Interface :=
  (family.returnAt source).localRecovery.shadow

/-- The visible coordination carried by the current local recovery. -/
def sameProjectionAt (source : Source) :
    project (family.formedAt source) = project (family.shadowAt source) :=
  (family.returnAt source).localRecovery.sameProjection

/-- The internal separation carried by the current local recovery. -/
def separatedAt (source : Source) :
    family.formedAt source = family.shadowAt source -> False :=
  (family.returnAt source).localRecovery.separated

/-- The repair attached to the current formed pole. -/
def repairAt (source : Source) : RepairOf (family.formedAt source) :=
  (family.returnAt source).localRecovery.repair

end IntrinsicDynamicReturnFamily

/-! ## Dynamic contexts and readings -/

/-- A use context remembers both its source and the produced intersection. -/
structure DynamicUsageContext
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf) where
  source : Source
  intersection : complete.Intersection branch
  intersection_eq : intersection = family.intersectionAt source

namespace IntrinsicDynamicReturnFamily

variable
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}

variable
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)

/-- The canonical context at a source. -/
def contextAt (source : Source) : DynamicUsageContext family where
  source := source
  intersection := family.intersectionAt source
  intersection_eq := rfl

/-- The globally available initial context. -/
def initialContext : DynamicUsageContext family :=
  family.contextAt family.initial

end IntrinsicDynamicReturnFamily

/-- The two substantial readings authorized by the dynamic regime. -/
inductive DynamicGapReading where
  | formed
  | visible

/-! ## Gap-generated coordination and use -/

/--
The only non-reflexive coordination is the current formed-to-shadow gap.
Its indices retain the source and the exact poles from the dynamic return.
-/
inductive DynamicGapCoordination
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (context : DynamicUsageContext family) :
    Interface -> Interface -> Type (max u v w a x y z r s) where
  | current :
      DynamicGapCoordination
        family
        context
        (family.formedAt context.source)
        (family.shadowAt context.source)

/--
Proof-relevant dynamic use. A non-reflexive use stores both the separation and
the coordination that caused its authorization.
-/
inductive DynamicGapUse
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (context : DynamicUsageContext family) :
    Interface -> Interface -> Type (max u v w a x y z r s) where
  | refl (interface : Interface) :
      DynamicGapUse family context interface interface
  | of_noncontractive
      {left right : Interface}
      (separation : PLift (left = right -> False))
      (coordination : DynamicGapCoordination family context left right) :
      DynamicGapUse family context left right

/-- The left endpoint of a coordination is the current formed pole. -/
def DynamicGapCoordination.left_eq_formed
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {context : DynamicUsageContext family}
    {left right : Interface}
    (coordination : DynamicGapCoordination family context left right) :
    left = family.formedAt context.source := by
  cases coordination
  rfl

/-- The right endpoint of a coordination is the current shadow pole. -/
def DynamicGapCoordination.right_eq_shadow
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {context : DynamicUsageContext family}
    {left right : Interface}
    (coordination : DynamicGapCoordination family context left right) :
    right = family.shadowAt context.source := by
  cases coordination
  rfl

/-- Every use is either reflexive or carries its non-contractive causes. -/
def DynamicGapUse.classify
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {context : DynamicUsageContext family}
    {left right : Interface}
    (use : DynamicGapUse family context left right) :
    PLift (left = right) ⊕
      (PLift (left = right -> False) ×
        DynamicGapCoordination family context left right) := by
  cases use with
  | refl =>
      exact Sum.inl (PLift.up rfl)
  | of_noncontractive separation coordination =>
      exact Sum.inr ⟨separation, coordination⟩

/-- Composition of all dynamically authorized uses. -/
def DynamicGapUse.compose
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {context : DynamicUsageContext family}
    {left middle right : Interface}
    (first : DynamicGapUse family context left middle)
    (second : DynamicGapUse family context middle right) :
    DynamicGapUse family context left right := by
  cases first.classify with
  | inl firstReflexive =>
      cases firstReflexive.down
      exact second
  | inr firstCauses =>
      cases second.classify with
      | inl secondReflexive =>
          cases secondReflexive.down
          exact
            DynamicGapUse.of_noncontractive
              firstCauses.1
              firstCauses.2
      | inr secondCauses =>
          have formed_eq_shadow :
              family.formedAt context.source =
                family.shadowAt context.source :=
            secondCauses.2.left_eq_formed.symm.trans
              firstCauses.2.right_eq_shadow
          exact (family.separatedAt context.source formed_eq_shadow).elim

/-- No current coordination exists in the reverse direction. -/
theorem dynamicGapCoordination_noBackward
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (context : DynamicUsageContext family)
    (coordination :
      DynamicGapCoordination
        family
        context
        (family.shadowAt context.source)
        (family.formedAt context.source)) :
    False := by
  exact
    family.separatedAt context.source
      coordination.left_eq_formed.symm

/-- Two current non-reflexive coordinations cannot compose. -/
theorem dynamicGapCoordination_not_composable
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (context : DynamicUsageContext family)
    {middle : Interface}
    (first :
      DynamicGapCoordination
        family context (family.formedAt context.source) middle)
    (second :
      DynamicGapCoordination
        family context middle (family.shadowAt context.source)) :
    False := by
  exact
    family.separatedAt context.source
      (second.left_eq_formed.symm.trans first.right_eq_shadow)

/-- No dynamically authorized use exists in the reverse direction. -/
theorem dynamicGapUse_noBackward
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (context : DynamicUsageContext family)
    (use :
      DynamicGapUse
        family
        context
        (family.shadowAt context.source)
        (family.formedAt context.source)) :
    False := by
  cases use.classify with
  | inl backwardReflexive =>
      exact family.separatedAt context.source backwardReflexive.down.symm
  | inr causes =>
      exact dynamicGapCoordination_noBackward family context causes.2

/-! ## Canonical relaxed regime -/

/--
Visible equality lifted to the same proof-relevant universe as dynamic use.
The family and context parameters retain the provenance of the equality.
-/
structure DynamicVisibleTransportRelation
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (context : DynamicUsageContext family)
    (left right : Visible) : Type (max u v w a x y z r s) where
  equality : left = right

/-- The relaxed regime generated by every gap in an intrinsic return family. -/
def dynamicRelaxedRegimeOfReturnFamily
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf) :
    RelaxedInterfaceRegime Interface where
  Ctx := DynamicUsageContext family
  defaultCtx := family.initialContext
  Read := fun _ => DynamicGapReading
  defaultRead := fun _ => DynamicGapReading.formed
  Out := fun _ reading =>
    match reading with
    | DynamicGapReading.formed => ULift.{r} Interface
    | DynamicGapReading.visible => ULift.{x} Visible
  read := fun _ reading interface =>
    match reading with
    | DynamicGapReading.formed => ULift.up interface
    | DynamicGapReading.visible => ULift.up (project interface)
  Sep := fun _ left right => PLift (left = right -> False)
  Coord := fun context left right =>
    DynamicGapCoordination family context left right
  Use := fun context left right =>
    DynamicGapUse family context left right
  OutRel := fun context reading =>
    match reading with
    | DynamicGapReading.formed =>
        fun left right => DynamicGapUse family context left.down right.down
    | DynamicGapReading.visible =>
        fun left right =>
          DynamicVisibleTransportRelation
            family context left.down right.down
  use_of_noncontractive := fun separation coordination =>
    DynamicGapUse.of_noncontractive separation coordination
  transport := by
    intro context left right use reading
    cases reading with
    | formed =>
        exact use
    | visible =>
        cases use.classify with
        | inl reflexive =>
            exact
              DynamicVisibleTransportRelation.mk
                (congrArg project reflexive.down)
        | inr causes =>
            exact
              DynamicVisibleTransportRelation.mk
                ((congrArg project causes.2.left_eq_formed).trans
                  ((family.sameProjectionAt context.source).trans
                    (congrArg project causes.2.right_eq_shadow.symm)))

/-- The dynamic regime has intrinsic identities and composition. -/
def dynamicCompositionalUseOfReturnFamily
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf) :
    CompositionalUse (dynamicRelaxedRegimeOfReturnFamily family) where
  identity := fun _ interface => DynamicGapUse.refl interface
  compose := fun first second => first.compose second

/-- Dynamic use composition satisfies identity and associativity laws. -/
def dynamicLawfulCompositionalUseOfReturnFamily
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf) :
    LawfulCompositionalUse
      (dynamicRelaxedRegimeOfReturnFamily family)
      (dynamicCompositionalUseOfReturnFamily family) where
  leftIdentity := by
    intro context left right use
    cases use <;> rfl
  rightIdentity := by
    intro context left right use
    cases use <;> rfl
  associativity := by
    intro context firstPoint secondPoint thirdPoint fourthPoint
      first second third
    cases first with
    | refl => rfl
    | of_noncontractive firstSeparation firstCoordination =>
        cases second with
        | refl => rfl
        | of_noncontractive secondSeparation secondCoordination =>
            exact
              (family.separatedAt context.source
                (secondCoordination.left_eq_formed.symm.trans
                  firstCoordination.right_eq_shadow)).elim

/-- Identity for visible equality transport. -/
def DynamicVisibleTransportRelation.identity
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {context : DynamicUsageContext family}
    (visible : Visible) :
    DynamicVisibleTransportRelation family context visible visible where
  equality := rfl

/-- Composition of visible equality transports. -/
def DynamicVisibleTransportRelation.compose
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {context : DynamicUsageContext family}
    {left middle right : Visible}
    (first :
      DynamicVisibleTransportRelation family context left middle)
    (second :
      DynamicVisibleTransportRelation family context middle right) :
    DynamicVisibleTransportRelation family context left right where
  equality := first.equality.trans second.equality

/-- Visible equality transports with fixed endpoints are proof-irrelevant. -/
theorem DynamicVisibleTransportRelation.unique
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {context : DynamicUsageContext family}
    {left right : Visible}
    (first second :
      DynamicVisibleTransportRelation family context left right) :
    first = second := by
  cases first
  cases second
  rfl

/-- Both dynamic readings carry lawful composition preserved by transport. -/
def dynamicCompositionalTransportOfReturnFamily
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf) :
    CompositionalTransport
      (dynamicRelaxedRegimeOfReturnFamily family)
      (dynamicCompositionalUseOfReturnFamily family) where
  useLaws := dynamicLawfulCompositionalUseOfReturnFamily family
  outIdentity := by
    intro context reading interface
    cases reading with
    | formed => exact DynamicGapUse.refl interface
    | visible =>
        exact
          DynamicVisibleTransportRelation.identity
            (project interface)
  outCompose := by
    intro context reading left middle right first second
    cases reading with
    | formed => exact first.compose second
    | visible => exact first.compose second
  outLeftIdentity := by
    intro context reading left right relation
    cases reading with
    | formed =>
        exact
          (dynamicLawfulCompositionalUseOfReturnFamily family).leftIdentity
            relation
    | visible =>
        exact DynamicVisibleTransportRelation.unique _ _
  outRightIdentity := by
    intro context reading left right relation
    cases reading with
    | formed =>
        exact
          (dynamicLawfulCompositionalUseOfReturnFamily family).rightIdentity
            relation
    | visible =>
        exact DynamicVisibleTransportRelation.unique _ _
  outAssociativity := by
    intro context reading firstPoint secondPoint thirdPoint fourthPoint
      first second third
    cases reading with
    | formed =>
        exact
          (dynamicLawfulCompositionalUseOfReturnFamily family).associativity
            first second third
    | visible =>
        exact DynamicVisibleTransportRelation.unique _ _
  transportIdentity := by
    intro context reading interface
    cases reading <;> rfl
  transportComposition := by
    intro context reading left middle right first second
    cases reading with
    | formed => rfl
    | visible =>
        exact DynamicVisibleTransportRelation.unique _ _

/-! ## Causal extraction from the current gap -/

/-- Non-contractive use at an arbitrary context of the family. -/
def dynamicGapNonContractiveUseAtContext
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (context : DynamicUsageContext family) :
    NonContractiveUse
      (dynamicRelaxedRegimeOfReturnFamily family)
      context
      (family.formedAt context.source)
      (family.shadowAt context.source) where
  separation := PLift.up (family.separatedAt context.source)
  coordination := DynamicGapCoordination.current

/-- The canonical non-contractive use at a source. -/
def dynamicGapNonContractiveUse
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    NonContractiveUse
      (dynamicRelaxedRegimeOfReturnFamily family)
      (family.contextAt source)
      (family.formedAt source)
      (family.shadowAt source) :=
  dynamicGapNonContractiveUseAtContext family (family.contextAt source)

/-- The use authorized by the canonical gap. -/
def dynamicGapAuthorizedUse
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    DynamicGapUse
      family
      (family.contextAt source)
      (family.formedAt source)
      (family.shadowAt source) :=
  NonContractiveUse.use (dynamicGapNonContractiveUse family source)

/-- The authorized use is definitionally generated from separation and coordination. -/
theorem dynamicGapAuthorizedUse_eq_of_noncontractive
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    dynamicGapAuthorizedUse family source =
      DynamicGapUse.of_noncontractive
        (PLift.up (family.separatedAt source))
        DynamicGapCoordination.current :=
  rfl

/-- Formed transport generated from the current non-contractive use. -/
def dynamicGapFormedTransport
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    DynamicGapUse
      family
      (family.contextAt source)
      (family.formedAt source)
      (family.shadowAt source) :=
  NonContractiveUse.transport
    (dynamicGapNonContractiveUse family source)
    DynamicGapReading.formed

/-- Visible transport generated from the current non-contractive use. -/
def dynamicGapVisibleTransport
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    DynamicVisibleTransportRelation
      family
      (family.contextAt source)
      (project (family.formedAt source))
      (project (family.shadowAt source)) :=
  NonContractiveUse.transport
    (dynamicGapNonContractiveUse family source)
    DynamicGapReading.visible

/-- The visible transport is exactly the projection equality of the local gap. -/
theorem dynamicGapVisibleTransport_down
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    (dynamicGapVisibleTransport family source).equality =
      family.sameProjectionAt source :=
  rfl

/-- The complete formed transport chain. -/
def dynamicGapFormedTransportChain
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    LocalTransportChain
      (dynamicRelaxedRegimeOfReturnFamily family)
      (family.contextAt source)
      (family.formedAt source)
      (family.shadowAt source)
      DynamicGapReading.formed :=
  localTransportChain
    (dynamicGapNonContractiveUse family source)
    DynamicGapReading.formed

/-- The complete visible transport chain. -/
def dynamicGapVisibleTransportChain
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    LocalTransportChain
      (dynamicRelaxedRegimeOfReturnFamily family)
      (family.contextAt source)
      (family.formedAt source)
      (family.shadowAt source)
      DynamicGapReading.visible :=
  localTransportChain
    (dynamicGapNonContractiveUse family source)
    DynamicGapReading.visible

/-! ## Bilateral memory and causal state -/

/-- The strong bilateral cycle generated from a dynamic usage context. -/
def dynamicUsageStrongCycle
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    (context : DynamicUsageContext family) :
    StrongTerminalCycleFromIntersection complete branch :=
  strongTerminalCycleFromIntersection complete coherence context.intersection

/--
Bilateral memory of a gap-generated use. The cycle source is explicitly tied
to the intersection produced by the same dynamic return.
-/
structure DynamicUsageMemory
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (context : DynamicUsageContext family) where
  cycle : StrongTerminalCycleFromIntersection complete branch
  cycle_eq : cycle = dynamicUsageStrongCycle context
  cycleSource_eq_returnIntersection :
    cycle.sourceIntersection = family.intersectionAt context.source
  nonContractive :
    NonContractiveUse
      (dynamicRelaxedRegimeOfReturnFamily family)
      context
      (family.formedAt context.source)
      (family.shadowAt context.source)
  use :
    DynamicGapUse
      family
      context
      (family.formedAt context.source)
      (family.shadowAt context.source)
  use_eq : use = NonContractiveUse.use nonContractive
  sourceIntersection_preserved :
    intersectionOfComplete
        complete
        (completeOfIntersection complete context.intersection) =
      context.intersection

/-- Canonical bilateral memory at a context. -/
def dynamicUsageMemory
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (context : DynamicUsageContext family) :
    DynamicUsageMemory family context where
  cycle := dynamicUsageStrongCycle context
  cycle_eq := rfl
  cycleSource_eq_returnIntersection := context.intersection_eq
  nonContractive := dynamicGapNonContractiveUseAtContext family context
  use := NonContractiveUse.use (dynamicGapNonContractiveUseAtContext family context)
  use_eq := rfl
  sourceIntersection_preserved :=
    coherence.intersectionRoundTrip.intersection_stable
      branch
      context.intersection

/--
The complete causal state consumed by a transition: bilateral memory and both
transport chains generated from the same non-contractive use.
-/
structure DynamicGapCausalState
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) where
  memory : DynamicUsageMemory family (family.contextAt source)
  formedTransport :
    LocalTransportChain
      (dynamicRelaxedRegimeOfReturnFamily family)
      (family.contextAt source)
      (family.formedAt source)
      (family.shadowAt source)
      DynamicGapReading.formed
  visibleTransport :
    LocalTransportChain
      (dynamicRelaxedRegimeOfReturnFamily family)
      (family.contextAt source)
      (family.formedAt source)
      (family.shadowAt source)
      DynamicGapReading.visible
  formedUse_eq_memoryUse : formedTransport.use = memory.use
  visibleUse_eq_memoryUse : visibleTransport.use = memory.use

/-- The causal state computed from one source, with no external bridge. -/
def dynamicGapCausalState
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    DynamicGapCausalState family source where
  memory := dynamicUsageMemory family (family.contextAt source)
  formedTransport := dynamicGapFormedTransportChain family source
  visibleTransport := dynamicGapVisibleTransportChain family source
  formedUse_eq_memoryUse := rfl
  visibleUse_eq_memoryUse := rfl

/-- The canonical formed transport is exactly the image of the memorized use. -/
theorem dynamicGapCausalState_formedTransport_eq_memoryTransport
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    (dynamicGapCausalState family source).formedTransport.transported =
      (dynamicRelaxedRegimeOfReturnFamily family).transport
        (dynamicGapCausalState family source).memory.use
        DynamicGapReading.formed :=
  rfl

/-- The canonical visible transport is the second image of the same use. -/
theorem dynamicGapCausalState_visibleTransport_eq_memoryTransport
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (source : Source) :
    (dynamicGapCausalState family source).visibleTransport.transported =
      (dynamicRelaxedRegimeOfReturnFamily family).transport
        (dynamicGapCausalState family source).memory.use
        DynamicGapReading.visible :=
  rfl

/-- Dynamic transport sends every use composition to output composition. -/
theorem dynamicTransport_preservesComposition
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    {context : DynamicUsageContext family}
    {left middle right : Interface}
    (reading : DynamicGapReading)
    (first : DynamicGapUse family context left middle)
    (second : DynamicGapUse family context middle right) :
    (dynamicRelaxedRegimeOfReturnFamily family).transport
        (DynamicGapUse.compose first second)
        reading =
      (dynamicCompositionalTransportOfReturnFamily family).outCompose
        reading
        ((dynamicRelaxedRegimeOfReturnFamily family).transport first reading)
        ((dynamicRelaxedRegimeOfReturnFamily family).transport second reading) :=
  (dynamicCompositionalTransportOfReturnFamily family).transportComposition
    reading first second

/-! ## Gap-driven transition and iteration -/

/-- A transition can run only from a complete causal state of the current gap. -/
structure GapDrivenDynamicSystem
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf) where
  advance : (Σ source : Source, DynamicGapCausalState family source) -> Source

namespace GapDrivenDynamicSystem

variable
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}

/-- The canonical dependent input at a source. -/
def canonicalCausalInput (source : Source) :
    Σ current : Source, DynamicGapCausalState family current :=
  ⟨source, dynamicGapCausalState family source⟩

/-- The successor is computed by advancing the canonical causal state. -/
def next (system : GapDrivenDynamicSystem family) (source : Source) : Source :=
  system.advance (canonicalCausalInput source)

/-- Intrinsic iteration of the gap-driven transition. -/
def iterateSource
    (system : GapDrivenDynamicSystem family) :
    Nat -> Source -> Source
  | 0, source => source
  | Nat.succ n, source => system.next (system.iterateSource n source)

end GapDrivenDynamicSystem

/-- One complete causal step, including the next causal state. -/
structure DynamicUsageStep
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    (system : GapDrivenDynamicSystem family)
    (source : Source) where
  transitionCause : DynamicGapCausalState family source
  transitionCause_eq : transitionCause = dynamicGapCausalState family source
  nextSource : Source
  nextSource_eq : nextSource = system.advance ⟨source, transitionCause⟩
  nextSource_eq_canonical : nextSource = system.next source
  nextCausalState : DynamicGapCausalState family nextSource
  nextCausalState_eq :
    nextCausalState = dynamicGapCausalState family nextSource

/-- The canonical dynamic step at a source. -/
def dynamicUsageStep
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    (system : GapDrivenDynamicSystem family)
    (source : Source) :
    DynamicUsageStep system source where
  transitionCause := dynamicGapCausalState family source
  transitionCause_eq := rfl
  nextSource := system.next source
  nextSource_eq := rfl
  nextSource_eq_canonical := rfl
  nextCausalState := dynamicGapCausalState family (system.next source)
  nextCausalState_eq := rfl

namespace GapDrivenDynamicSystem

variable
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}

/-- The source reached after `n` steps. -/
def iterationSource
    (system : GapDrivenDynamicSystem family)
    (n : Nat) : Source :=
  system.iterateSource n family.initial

/-- The context reached after `n` steps. -/
def iterationContext
    (system : GapDrivenDynamicSystem family)
    (n : Nat) : DynamicUsageContext family :=
  family.contextAt (system.iterationSource n)

/-- The causal step reached after `n` steps. -/
def iterationStep
    (system : GapDrivenDynamicSystem family)
    (n : Nat) : DynamicUsageStep system (system.iterationSource n) :=
  dynamicUsageStep system (system.iterationSource n)

/-- The bilateral usage memory reached after `n` steps. -/
def iterationMemory
    (system : GapDrivenDynamicSystem family)
    (n : Nat) : DynamicUsageMemory family (system.iterationContext n) :=
  dynamicUsageMemory family (system.iterationContext n)

end GapDrivenDynamicSystem

/-! ## Genuine variation -/

/-- A constructive certificate that the transition reverses the current poles. -/
structure GenuineDynamicUsageVariation
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    (system : GapDrivenDynamicSystem family) where
  source : Source
  source_ne_next : source = system.next source -> False
  next_formed_eq_current_shadow :
    family.formedAt (system.next source) = family.shadowAt source
  next_shadow_eq_current_formed :
    family.shadowAt (system.next source) = family.formedAt source

/-- A variation carries the current forward use. -/
def GenuineDynamicUsageVariation.currentUse
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {system : GapDrivenDynamicSystem family}
    (variation : GenuineDynamicUsageVariation system) :
    DynamicGapUse
      family
      (family.contextAt variation.source)
      (family.formedAt variation.source)
      (family.shadowAt variation.source) :=
  dynamicGapAuthorizedUse family variation.source

/-- A variation carries the reversed use at the next source. -/
def GenuineDynamicUsageVariation.nextUse
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {system : GapDrivenDynamicSystem family}
    (variation : GenuineDynamicUsageVariation system) :
    DynamicGapUse
      family
      (family.contextAt (system.next variation.source))
      (family.formedAt (system.next variation.source))
      (family.shadowAt (system.next variation.source)) :=
  dynamicGapAuthorizedUse family (system.next variation.source)

/-- The current forward use is rejected after the transition reverses the poles. -/
theorem genuineVariation_currentUse_refutedAtNext
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {system : GapDrivenDynamicSystem family}
    (variation : GenuineDynamicUsageVariation system)
    (use :
      HasUse
        (dynamicRelaxedRegimeOfReturnFamily family)
        (family.contextAt (system.next variation.source))
        (family.formedAt variation.source)
        (family.shadowAt variation.source)) :
    False := by
  have backward :
      HasUse
        (dynamicRelaxedRegimeOfReturnFamily family)
        (family.contextAt (system.next variation.source))
        (family.shadowAt (system.next variation.source))
        (family.formedAt (system.next variation.source)) := by
    rw [variation.next_shadow_eq_current_formed]
    rw [variation.next_formed_eq_current_shadow]
    exact use
  exact
    Nonempty.elim backward
      (fun impossible =>
        dynamicGapUse_noBackward
          family
          (family.contextAt (system.next variation.source))
          impossible)

/-- The contexts before and after a genuine variation are distinct. -/
theorem genuineVariation_contextsSeparated
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf}
    {system : GapDrivenDynamicSystem family}
    (variation : GenuineDynamicUsageVariation system)
    (sameContext :
      family.contextAt variation.source =
        family.contextAt (system.next variation.source)) :
    False :=
  variation.source_ne_next
    (congrArg DynamicUsageContext.source sameContext)

/--
A closed dynamic usage system carries its return atlas, causal transition, and
an intrinsic certificate of effective variation in one package.
-/
structure GenuinelyVaryingDynamicUsageSystem
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    (branch : Branch)
    (Source : Type a)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z)
    (Visible : Type r)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) where
  family :
    IntrinsicDynamicReturnFamily
      complete coherence branch Source Interface WitnessOf
      RealizesInterface Visible project RepairOf
  dynamics : GapDrivenDynamicSystem family
  variation : GenuineDynamicUsageVariation dynamics

/-! ## Strict non-projective representability -/

/--
Every intrinsic return family yields a relaxed regime that cannot be exactly
represented by projected equality: the initial gap use is directional.
-/
theorem dynamicRelaxedRegime_not_exactProjective
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (family :
      IntrinsicDynamicReturnFamily
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (representation :
      ExactProjectiveRepresentation
        (dynamicRelaxedRegimeOfReturnFamily family)) :
    False := by
  have forward :
      HasUse
        (dynamicRelaxedRegimeOfReturnFamily family)
        family.initialContext
        (family.formedAt family.initial)
        (family.shadowAt family.initial) :=
    Nonempty.intro (dynamicGapAuthorizedUse family family.initial)
  exact
    not_exactProjective_of_asymmetric_use
      forward
      (fun backward =>
        Nonempty.elim backward
          (fun impossible =>
            dynamicGapUse_noBackward
              family family.initialContext impossible))
      representation

/-- The same strictness theorem read from a closed varying system. -/
theorem GenuinelyVaryingDynamicUsageSystem.not_exactProjective
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch ->
        Interface ->
        Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (system :
      GenuinelyVaryingDynamicUsageSystem
        complete coherence branch Source Interface WitnessOf
        RealizesInterface Visible project RepairOf)
    (representation :
      ExactProjectiveRepresentation
        (dynamicRelaxedRegimeOfReturnFamily system.family)) :
    False :=
  dynamicRelaxedRegime_not_exactProjective system.family representation

end DynamicRelaxedUsage
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.DynamicRelaxedUsage.IntrinsicDynamicReturnFamily
#print axioms Meta.DynamicRelaxedUsage.DynamicGapCoordination
#print axioms Meta.DynamicRelaxedUsage.DynamicGapUse
#print axioms Meta.DynamicRelaxedUsage.DynamicGapUse.compose
#print axioms Meta.DynamicRelaxedUsage.dynamicGapUse_noBackward
#print axioms Meta.DynamicRelaxedUsage.dynamicRelaxedRegimeOfReturnFamily
#print axioms Meta.DynamicRelaxedUsage.dynamicLawfulCompositionalUseOfReturnFamily
#print axioms Meta.DynamicRelaxedUsage.DynamicVisibleTransportRelation.compose
#print axioms Meta.DynamicRelaxedUsage.dynamicCompositionalTransportOfReturnFamily
#print axioms Meta.DynamicRelaxedUsage.dynamicGapNonContractiveUse
#print axioms Meta.DynamicRelaxedUsage.dynamicGapAuthorizedUse
#print axioms Meta.DynamicRelaxedUsage.dynamicGapVisibleTransport
#print axioms Meta.DynamicRelaxedUsage.DynamicUsageMemory
#print axioms Meta.DynamicRelaxedUsage.dynamicUsageMemory
#print axioms Meta.DynamicRelaxedUsage.DynamicGapCausalState
#print axioms Meta.DynamicRelaxedUsage.dynamicGapCausalState
#print axioms Meta.DynamicRelaxedUsage.dynamicGapCausalState_formedTransport_eq_memoryTransport
#print axioms Meta.DynamicRelaxedUsage.dynamicGapCausalState_visibleTransport_eq_memoryTransport
#print axioms Meta.DynamicRelaxedUsage.dynamicTransport_preservesComposition
#print axioms Meta.DynamicRelaxedUsage.GapDrivenDynamicSystem
#print axioms Meta.DynamicRelaxedUsage.dynamicUsageStep
#print axioms Meta.DynamicRelaxedUsage.GenuineDynamicUsageVariation
#print axioms Meta.DynamicRelaxedUsage.genuineVariation_currentUse_refutedAtNext
#print axioms Meta.DynamicRelaxedUsage.genuineVariation_contextsSeparated
#print axioms Meta.DynamicRelaxedUsage.GenuinelyVaryingDynamicUsageSystem
#print axioms Meta.DynamicRelaxedUsage.dynamicRelaxedRegime_not_exactProjective
#print axioms Meta.DynamicRelaxedUsage.GenuinelyVaryingDynamicUsageSystem.not_exactProjective
/- AXIOM_AUDIT_END -/
