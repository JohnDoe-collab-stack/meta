/-!
# Standalone positive formed set core

This file is intentionally self-contained.  It has no `import` line and does
not depend on the existing `Meta/Core` modules.

It formalizes the small constructive core isolated by the v1.4 documents:
raw formed/visible signatures, projected identity, transport, diagonal cells,
empty and pair formations, pair rigidity, visible pair projection, and the
canonical positive diagonal obtained from a rigid formed pair whose visible
projection forgets orientation.
-/

namespace PositiveSetTheoryStandalone

universe u v m w l

/-! ## Raw two-level signature -/

structure RawPositiveSetSignature where
  FormedSet : Type u
  VisibleSet : Type v
  project : FormedSet -> VisibleSet
  Mem : FormedSet -> FormedSet -> Type m
  VisibleMem : VisibleSet -> VisibleSet -> Prop

structure MembershipProjection
    (S : RawPositiveSetSignature.{u, v, m}) where
  visibleMemOfMem :
    {x A : S.FormedSet} ->
      S.Mem x A ->
        S.VisibleMem (S.project x) (S.project A)

structure VisibleMembershipLift
    (S : RawPositiveSetSignature.{u, v, m})
    (U : S.VisibleSet)
    (A : S.FormedSet) where
  formed : S.FormedSet
  projected : S.project formed = U
  membership : S.Mem formed A

structure MembershipReflection
    (S : RawPositiveSetSignature.{u, v, m}) where
  reflected :
    {U : S.VisibleSet} ->
    {A : S.FormedSet} ->
      S.VisibleMem U (S.project A) ->
        Nonempty (VisibleMembershipLift S U A)

structure MembershipRealization
    (S : RawPositiveSetSignature.{u, v, m}) where
  realize :
    {U : S.VisibleSet} ->
    {A : S.FormedSet} ->
      S.VisibleMem U (S.project A) ->
        VisibleMembershipLift S U A

def membershipReflectionOfRealization
    {S : RawPositiveSetSignature.{u, v, m}}
    (realization : MembershipRealization S) :
    MembershipReflection S where
  reflected h := Nonempty.intro (realization.realize h)

structure VisibleExtensionalStructure
    (S : RawPositiveSetSignature.{u, v, m}) where
  visibleExtensionality :
    (V W : S.VisibleSet) ->
      ((U : S.VisibleSet) ->
        S.VisibleMem U V <-> S.VisibleMem U W) ->
          V = W

structure PositiveSetContext where
  raw : RawPositiveSetSignature.{u, v, m}
  membershipProjection : MembershipProjection raw
  visibleExtensionality : VisibleExtensionalStructure raw

/-! ## Internal, projected, and use identities -/

def InternalIdentity
    (S : RawPositiveSetSignature.{u, v, m})
    (A B : S.FormedSet) :
    Prop :=
  A = B

def ProjectedIdentity
    (S : RawPositiveSetSignature.{u, v, m})
    (A B : S.FormedSet) :
    Prop :=
  S.project A = S.project B

abbrev IdentityOfUse
    (S : RawPositiveSetSignature.{u, v, m})
    (A B : S.FormedSet) :
    Prop :=
  ProjectedIdentity S A B

theorem identityOfUse_iff_projectedIdentity
    {S : RawPositiveSetSignature.{u, v, m}}
    (A B : S.FormedSet) :
    IdentityOfUse S A B <-> ProjectedIdentity S A B :=
  Iff.rfl

def InterfaceTransport
    (S : RawPositiveSetSignature.{u, v, m})
    (A B : S.FormedSet) :
    Prop :=
  (Label : Type l) ->
  (read : S.VisibleSet -> Label) ->
    read (S.project A) = read (S.project B)

theorem projectedIdentity_to_interfaceTransport
    {S : RawPositiveSetSignature.{u, v, m}}
    {A B : S.FormedSet}
    (h : ProjectedIdentity S A B) :
    InterfaceTransport.{u, v, m, l} S A B :=
  fun _ read => congrArg read h

theorem interfaceTransport_to_projectedIdentity
    {S : RawPositiveSetSignature.{u, v, m}}
    {A B : S.FormedSet}
    (h : InterfaceTransport.{u, v, m, v} S A B) :
    ProjectedIdentity S A B :=
  h S.VisibleSet (fun visible => visible)

theorem interfaceTransport_iff_projectedIdentity
    {S : RawPositiveSetSignature.{u, v, m}}
    (A B : S.FormedSet) :
    InterfaceTransport.{u, v, m, v} S A B <->
      ProjectedIdentity S A B where
  mp := interfaceTransport_to_projectedIdentity
  mpr := projectedIdentity_to_interfaceTransport

/-! ## Diagonal cells and consequences -/

structure ProjectedSetCell
    (S : RawPositiveSetSignature.{u, v, m}) where
  formed : S.FormedSet
  shadow : S.FormedSet
  sameVisible : S.project formed = S.project shadow
  separated : formed = shadow -> False

def ProjectionFiberFaithful
    (S : RawPositiveSetSignature.{u, v, m}) :
    Prop :=
  (left right : S.FormedSet) ->
    S.project left = S.project right ->
      left = right

structure ProjectionInformationConserving
    (S : RawPositiveSetSignature.{u, v, m}) where
  recover : S.VisibleSet -> S.FormedSet
  reconstructs :
    (A : S.FormedSet) ->
      recover (S.project A) = A

theorem projectedSetCell_not_fiberFaithful
    {S : RawPositiveSetSignature.{u, v, m}}
    (cell : ProjectedSetCell S)
    (faithful : ProjectionFiberFaithful S) :
    False :=
  cell.separated
    (faithful cell.formed cell.shadow cell.sameVisible)

theorem projectedSetCell_not_informationConserving
    {S : RawPositiveSetSignature.{u, v, m}}
    (cell : ProjectedSetCell S)
    (conserving : ProjectionInformationConserving S) :
    False :=
  cell.separated
    (calc
      cell.formed =
          conserving.recover (S.project cell.formed) :=
        Eq.symm (conserving.reconstructs cell.formed)
      _ = conserving.recover (S.project cell.shadow) :=
        congrArg conserving.recover cell.sameVisible
      _ = cell.shadow :=
        conserving.reconstructs cell.shadow)

structure PositiveSetDiagonalization
    (S : RawPositiveSetSignature.{u, v, m})
    (WitnessOf : ProjectedSetCell S -> Type w)
    (Positive :
      (cell : ProjectedSetCell S) ->
        WitnessOf cell -> Prop) where
  cell : ProjectedSetCell S
  witness : WitnessOf cell
  witness_pos : Positive cell witness

/-! ## Empty and pair formations -/

structure EmptyFormation
    (S : RawPositiveSetSignature.{u, v, m}) where
  set : S.FormedSet
  elim :
    (x : S.FormedSet) ->
      S.Mem x set -> False

structure TypeEquiv (A : Sort u) (B : Sort v) :
    Type (max u v) where
  toFun : A -> B
  invFun : B -> A
  left_inv :
    (a : A) ->
      invFun (toFun a) = a
  right_inv :
    (b : B) ->
      toFun (invFun b) = b

inductive PairOccurrence
    (S : RawPositiveSetSignature.{u, v, m})
    (x A B : S.FormedSet) :
    Type u where
  | left : x = A -> PairOccurrence S x A B
  | right : x = B -> PairOccurrence S x A B

structure PairEquivFormation
    (S : RawPositiveSetSignature.{u, v, m})
    (A B : S.FormedSet) where
  set : S.FormedSet
  membership :
    (x : S.FormedSet) ->
      TypeEquiv (S.Mem x set) (PairOccurrence S x A B)

structure PairRigidity
    (S : RawPositiveSetSignature.{u, v, m})
    (pair :
      (A B : S.FormedSet) ->
        PairEquivFormation S A B) :
    Prop where
  parameters :
    (A B C D : S.FormedSet) ->
      (pair A B).set = (pair C D).set ->
        A = C /\ B = D

def PairProjectionLaw
    {S : RawPositiveSetSignature.{u, v, m}}
    {A B : S.FormedSet}
    (P : PairEquivFormation S A B) :
    Prop :=
  (U : S.VisibleSet) ->
    S.VisibleMem U (S.project P.set) <->
      (U = S.project A \/ U = S.project B)

theorem pairSwap_sameVisible
    {S : RawPositiveSetSignature.{u, v, m}}
    (visible : VisibleExtensionalStructure S)
    (pair :
      (A B : S.FormedSet) ->
        PairEquivFormation S A B)
    (pairProjection :
      (A B : S.FormedSet) ->
        PairProjectionLaw (pair A B))
    (A B : S.FormedSet) :
    S.project (pair A B).set =
      S.project (pair B A).set :=
  visible.visibleExtensionality
    (S.project (pair A B).set)
    (S.project (pair B A).set)
    (fun U =>
      Iff.intro
        (fun h => by
          have hCases := (pairProjection A B U).mp h
          cases hCases with
          | inl hA =>
              exact (pairProjection B A U).mpr (Or.inr hA)
          | inr hB =>
              exact (pairProjection B A U).mpr (Or.inl hB))
        (fun h => by
          have hCases := (pairProjection B A U).mp h
          cases hCases with
          | inl hB =>
              exact (pairProjection A B U).mpr (Or.inr hB)
          | inr hA =>
              exact (pairProjection A B U).mpr (Or.inl hA)))

def canonicalLeft
    {S : RawPositiveSetSignature.{u, v, m}}
    (empty : EmptyFormation S) :
    S.FormedSet :=
  empty.set

def canonicalRight
    {S : RawPositiveSetSignature.{u, v, m}}
    (empty : EmptyFormation S)
    (pair :
      (A B : S.FormedSet) ->
        PairEquivFormation S A B) :
    S.FormedSet :=
  (pair empty.set empty.set).set

theorem canonicalParameters_separated
    {S : RawPositiveSetSignature.{u, v, m}}
    (empty : EmptyFormation S)
    (pair :
      (A B : S.FormedSet) ->
        PairEquivFormation S A B) :
    canonicalLeft empty = canonicalRight empty pair -> False := by
  intro h
  let E : S.FormedSet := empty.set
  let reflexivePair : PairEquivFormation S E E := pair E E
  have memberEInReflexivePair :
      S.Mem E reflexivePair.set :=
    (reflexivePair.membership E).invFun
      (PairOccurrence.left (S := S) (x := E) (A := E) (B := E) rfl)
  have memberEInEmpty : S.Mem E E := by
    change S.Mem E (canonicalLeft empty)
    rw [h]
    exact memberEInReflexivePair
  exact empty.elim E memberEInEmpty

def canonicalPairCell
    {S : RawPositiveSetSignature.{u, v, m}}
    (visible : VisibleExtensionalStructure S)
    (empty : EmptyFormation S)
    (pair :
      (A B : S.FormedSet) ->
        PairEquivFormation S A B)
    (rigidity : PairRigidity S pair)
    (pairProjection :
      (A B : S.FormedSet) ->
        PairProjectionLaw (pair A B)) :
    ProjectedSetCell S where
  formed :=
    (pair (canonicalLeft empty) (canonicalRight empty pair)).set
  shadow :=
    (pair (canonicalRight empty pair) (canonicalLeft empty)).set
  sameVisible :=
    pairSwap_sameVisible visible pair pairProjection
      (canonicalLeft empty)
      (canonicalRight empty pair)
  separated := by
    intro h
    have parameters :=
      rigidity.parameters
        (canonicalLeft empty)
        (canonicalRight empty pair)
        (canonicalRight empty pair)
        (canonicalLeft empty)
        h
    exact canonicalParameters_separated empty pair parameters.left

structure PairOccurrenceWitness
    {S : RawPositiveSetSignature.{u, v, m}}
    {A B x : S.FormedSet}
    (P : PairEquivFormation S A B)
    (occurrence : PairOccurrence S x A B) where
  member : S.Mem x P.set
  decodes_to :
    (P.membership x).toFun member = occurrence

def pairOccurrenceWitnessOfOccurrence
    {S : RawPositiveSetSignature.{u, v, m}}
    {A B x : S.FormedSet}
    (P : PairEquivFormation S A B)
    (occurrence : PairOccurrence S x A B) :
    PairOccurrenceWitness P occurrence where
  member := (P.membership x).invFun occurrence
  decodes_to := (P.membership x).right_inv occurrence

structure PairSwapWitness
    (S : RawPositiveSetSignature.{u, v, m})
    (pair :
      (A B : S.FormedSet) ->
        PairEquivFormation S A B)
    (A B : S.FormedSet)
    (cell : ProjectedSetCell S) where
  formed_is_pair :
    cell.formed = (pair A B).set
  shadow_is_swapped_pair :
    cell.shadow = (pair B A).set
  parameters_separated :
    A = B -> False
  a_left_in_formed :
    PairOccurrenceWitness
      (pair A B)
      (PairOccurrence.left (S := S) (x := A) (A := A) (B := B) rfl)
  b_right_in_formed :
    PairOccurrenceWitness
      (pair A B)
      (PairOccurrence.right (S := S) (x := B) (A := A) (B := B) rfl)
  b_left_in_shadow :
    PairOccurrenceWitness
      (pair B A)
      (PairOccurrence.left (S := S) (x := B) (A := B) (B := A) rfl)
  a_right_in_shadow :
    PairOccurrenceWitness
      (pair B A)
      (PairOccurrence.right (S := S) (x := A) (A := B) (B := A) rfl)

def PairSwapPositive
    {S : RawPositiveSetSignature.{u, v, m}}
    {pair :
      (A B : S.FormedSet) ->
        PairEquivFormation S A B}
    (A B : S.FormedSet)
    (_cell : ProjectedSetCell S)
    (_witness : PairSwapWitness S pair A B _cell) :
    Prop :=
  A = B -> False

def canonicalPairSwapWitness
    {S : RawPositiveSetSignature.{u, v, m}}
    (visible : VisibleExtensionalStructure S)
    (empty : EmptyFormation S)
    (pair :
      (A B : S.FormedSet) ->
        PairEquivFormation S A B)
    (rigidity : PairRigidity S pair)
    (pairProjection :
      (A B : S.FormedSet) ->
        PairProjectionLaw (pair A B)) :
    PairSwapWitness S pair
      (canonicalLeft empty)
      (canonicalRight empty pair)
      (canonicalPairCell visible empty pair rigidity pairProjection) where
  formed_is_pair := rfl
  shadow_is_swapped_pair := rfl
  parameters_separated :=
    canonicalParameters_separated empty pair
  a_left_in_formed :=
    pairOccurrenceWitnessOfOccurrence
      (pair (canonicalLeft empty) (canonicalRight empty pair))
      (PairOccurrence.left
        (S := S)
        (x := canonicalLeft empty)
        (A := canonicalLeft empty)
        (B := canonicalRight empty pair)
        rfl)
  b_right_in_formed :=
    pairOccurrenceWitnessOfOccurrence
      (pair (canonicalLeft empty) (canonicalRight empty pair))
      (PairOccurrence.right
        (S := S)
        (x := canonicalRight empty pair)
        (A := canonicalLeft empty)
        (B := canonicalRight empty pair)
        rfl)
  b_left_in_shadow :=
    pairOccurrenceWitnessOfOccurrence
      (pair (canonicalRight empty pair) (canonicalLeft empty))
      (PairOccurrence.left
        (S := S)
        (x := canonicalRight empty pair)
        (A := canonicalRight empty pair)
        (B := canonicalLeft empty)
        rfl)
  a_right_in_shadow :=
    pairOccurrenceWitnessOfOccurrence
      (pair (canonicalRight empty pair) (canonicalLeft empty))
      (PairOccurrence.right
        (S := S)
        (x := canonicalLeft empty)
        (A := canonicalRight empty pair)
        (B := canonicalLeft empty)
        rfl)

def canonicalPositiveDiagonal
    {S : RawPositiveSetSignature.{u, v, m}}
    (visible : VisibleExtensionalStructure S)
    (empty : EmptyFormation S)
    (pair :
      (A B : S.FormedSet) ->
        PairEquivFormation S A B)
    (rigidity : PairRigidity S pair)
    (pairProjection :
      (A B : S.FormedSet) ->
        PairProjectionLaw (pair A B)) :
    PositiveSetDiagonalization S
      (PairSwapWitness S pair
        (canonicalLeft empty)
        (canonicalRight empty pair))
      (PairSwapPositive
        (pair := pair)
        (canonicalLeft empty)
        (canonicalRight empty pair)) where
  cell :=
    canonicalPairCell visible empty pair rigidity pairProjection
  witness :=
    canonicalPairSwapWitness visible empty pair rigidity pairProjection
  witness_pos :=
    canonicalParameters_separated empty pair

/-! ## Visible representation and exact membership adequacy -/

structure RepresentedVisible
    (S : RawPositiveSetSignature.{u, v, m})
    (V : S.VisibleSet) where
  formed : S.FormedSet
  projected : S.project formed = V

def VisibleCoverage
    (S : RawPositiveSetSignature.{u, v, m}) :
    Type (max u v) :=
  (V : S.VisibleSet) -> RepresentedVisible S V

def VisibleCovered
    (S : RawPositiveSetSignature.{u, v, m}) :
    Prop :=
  (V : S.VisibleSet) -> Nonempty (RepresentedVisible S V)

theorem visibleCoveredOfCoverage
    {S : RawPositiveSetSignature.{u, v, m}}
    (coverage : VisibleCoverage S) :
    VisibleCovered S :=
  fun V => Nonempty.intro (coverage V)

theorem visibleMembershipLift_to_visibleMem
    {S : RawPositiveSetSignature.{u, v, m}}
    (projection : MembershipProjection S)
    {U : S.VisibleSet}
    {A : S.FormedSet}
    (lift : VisibleMembershipLift S U A) :
    S.VisibleMem U (S.project A) := by
  have h :=
    projection.visibleMemOfMem lift.membership
  rw [lift.projected] at h
  exact h

theorem membershipReflection_iff_visibleMembershipLift
    {S : RawPositiveSetSignature.{u, v, m}}
    (projection : MembershipProjection S)
    (reflection : MembershipReflection S)
    {U : S.VisibleSet}
    {A : S.FormedSet} :
    S.VisibleMem U (S.project A) <->
      Nonempty (VisibleMembershipLift S U A) where
  mp := reflection.reflected
  mpr := fun h =>
    h.elim
      (fun lift =>
        visibleMembershipLift_to_visibleMem projection lift)

/-! ## Projection laws derivable from reflection -/

def EmptyProjectionLaw
    {S : RawPositiveSetSignature.{u, v, m}}
    (E : EmptyFormation S) :
    Prop :=
  (U : S.VisibleSet) ->
    S.VisibleMem U (S.project E.set) -> False

theorem emptyProjectionLawOfReflection
    {S : RawPositiveSetSignature.{u, v, m}}
    (reflection : MembershipReflection S)
    (E : EmptyFormation S) :
    EmptyProjectionLaw E :=
  fun _ h =>
    (reflection.reflected h).elim
      (fun lift =>
        E.elim lift.formed lift.membership)

theorem pairProjectionLawOfReflection
    {S : RawPositiveSetSignature.{u, v, m}}
    (projection : MembershipProjection S)
    (reflection : MembershipReflection S)
    {A B : S.FormedSet}
    (P : PairEquivFormation S A B) :
    PairProjectionLaw P :=
  fun U =>
    Iff.intro
      (fun h => by
        have reflected := reflection.reflected h
        exact
          reflected.elim
            (fun lift => by
              have occurrence :=
                (P.membership lift.formed).toFun lift.membership
              cases occurrence with
              | left hx =>
                  exact Or.inl
                    ((Eq.symm lift.projected).trans
                      (congrArg S.project hx))
              | right hx =>
                  exact Or.inr
                    ((Eq.symm lift.projected).trans
                      (congrArg S.project hx))))
      (fun h => by
        cases h with
        | inl hU =>
            rw [hU]
            exact
              projection.visibleMemOfMem
                ((P.membership A).invFun
                  (PairOccurrence.left
                    (S := S) (x := A) (A := A) (B := B) rfl))
        | inr hU =>
            rw [hU]
            exact
              projection.visibleMemOfMem
                ((P.membership B).invFun
                  (PairOccurrence.right
                    (S := S) (x := B) (A := A) (B := B) rfl)))

/-! ## Union, separation, images, replacement, and collection -/

structure UnionMembership
    (S : RawPositiveSetSignature.{u, v, m})
    (A x : S.FormedSet) where
  middle : S.FormedSet
  middle_mem : S.Mem middle A
  member_mem : S.Mem x middle

structure UnionFormation
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet) where
  set : S.FormedSet
  membership :
    (x : S.FormedSet) ->
      TypeEquiv (S.Mem x set) (UnionMembership S A x)

def UnionProjectionLaw
    {S : RawPositiveSetSignature.{u, v, m}}
    {A : S.FormedSet}
    (U : UnionFormation S A) :
    Prop :=
  (X : S.VisibleSet) ->
    S.VisibleMem X (S.project U.set) <->
      Exists
        (fun V : S.VisibleSet =>
          S.VisibleMem V (S.project A) /\
            S.VisibleMem X V)

theorem unionProjectionLawOfReflection
    {S : RawPositiveSetSignature.{u, v, m}}
    (projection : MembershipProjection S)
    (reflection : MembershipReflection S)
    {A : S.FormedSet}
    (U : UnionFormation S A) :
    UnionProjectionLaw U :=
  fun X =>
    Iff.intro
      (fun h => by
        exact
          (reflection.reflected h).elim
            (fun lift => by
              let decoded :=
                (U.membership lift.formed).toFun lift.membership
              exists S.project decoded.middle
              constructor
              · exact projection.visibleMemOfMem decoded.middle_mem
              · have hx :=
                  projection.visibleMemOfMem decoded.member_mem
                rw [lift.projected] at hx
                exact hx))
      (fun h => by
        rcases h with ⟨V, hVA, hXV⟩
        exact
          (reflection.reflected hVA).elim
            (fun liftMiddle => by
              have hXV' : S.VisibleMem X (S.project liftMiddle.formed) := by
                have hXVCopy := hXV
                rw [← liftMiddle.projected] at hXVCopy
                exact hXVCopy
              exact
                (reflection.reflected hXV').elim
                  (fun liftMember => by
                    have memberUnion :
                        S.Mem liftMember.formed U.set :=
                      (U.membership liftMember.formed).invFun
                        { middle := liftMiddle.formed
                          middle_mem := liftMiddle.membership
                          member_mem := liftMember.membership }
                    have visibleMember :=
                      projection.visibleMemOfMem memberUnion
                    rw [liftMember.projected] at visibleMember
                    exact visibleMember)))

structure SeparatedMembership
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet)
    (P : S.FormedSet -> Prop)
    (x : S.FormedSet) where
  base : S.Mem x A
  property : P x

structure SeparationFormation
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet)
    (P : S.FormedSet -> Prop) where
  set : S.FormedSet
  membership :
    (x : S.FormedSet) ->
      TypeEquiv (S.Mem x set) (SeparatedMembership S A P x)

def SeparationProjectionLaw
    {S : RawPositiveSetSignature.{u, v, m}}
    {A : S.FormedSet}
    {P : S.FormedSet -> Prop}
    (Sep : SeparationFormation S A P)
    (PVisible : S.VisibleSet -> Prop) :
    Prop :=
  (X : S.VisibleSet) ->
    S.VisibleMem X (S.project Sep.set) <->
      (S.VisibleMem X (S.project A) /\ PVisible X)

theorem separationProjectionLawOfReflection
    {S : RawPositiveSetSignature.{u, v, m}}
    (projection : MembershipProjection S)
    (reflection : MembershipReflection S)
    {A : S.FormedSet}
    {P : S.FormedSet -> Prop}
    (Sep : SeparationFormation S A P)
    (PVisible : S.VisibleSet -> Prop)
    (factor :
      (x : S.FormedSet) ->
        S.Mem x A ->
          (P x <-> PVisible (S.project x))) :
    SeparationProjectionLaw Sep PVisible :=
  fun X =>
    Iff.intro
      (fun h => by
        exact
          (reflection.reflected h).elim
            (fun lift => by
              let decoded :=
                (Sep.membership lift.formed).toFun lift.membership
              constructor
              · have hBase :=
                  projection.visibleMemOfMem decoded.base
                rw [lift.projected] at hBase
                exact hBase
              · have hProperty :=
                  (factor lift.formed decoded.base).mp decoded.property
                rw [lift.projected] at hProperty
                exact hProperty))
      (fun h => by
        rcases h with ⟨hXA, hPX⟩
        exact
          (reflection.reflected hXA).elim
            (fun lift => by
              have hPProject : PVisible (S.project lift.formed) := by
                rw [lift.projected]
                exact hPX
              have hP : P lift.formed :=
                (factor lift.formed lift.membership).mpr hPProject
              have memberSep :
                  S.Mem lift.formed Sep.set :=
                (Sep.membership lift.formed).invFun
                  { base := lift.membership
                    property := hP }
              have visibleMember :=
                projection.visibleMemOfMem memberSep
              rw [lift.projected] at visibleMember
              exact visibleMember))

structure BoundedSeparationData
    (S : RawPositiveSetSignature.{u, v, m}) where
  BoundedPredicateCode : S.FormedSet -> Type w
  Satisfies :
    {A : S.FormedSet} ->
      BoundedPredicateCode A -> S.FormedSet -> Prop
  separateBounded :
    (A : S.FormedSet) ->
    (code : BoundedPredicateCode A) ->
      SeparationFormation S A (fun x => Satisfies code x)

structure BoundedPredicateVisibleSemantics
    (S : RawPositiveSetSignature.{u, v, m})
    (bounded : BoundedSeparationData.{u, v, m, w} S) where
  VisibleSatisfies :
    {A : S.FormedSet} ->
      bounded.BoundedPredicateCode A -> S.VisibleSet -> Prop
  factors :
    {A : S.FormedSet} ->
    (code : bounded.BoundedPredicateCode A) ->
    (x : S.FormedSet) ->
      S.Mem x A ->
        (bounded.Satisfies code x <->
          VisibleSatisfies code (S.project x))

structure ImagePreimage
    (S : RawPositiveSetSignature.{u, v, m})
    (f : S.FormedSet -> S.FormedSet)
    (A y : S.FormedSet) where
  source : S.FormedSet
  source_mem : S.Mem source A
  image_eq : y = f source

structure ImageFormation
    (S : RawPositiveSetSignature.{u, v, m})
    (f : S.FormedSet -> S.FormedSet)
    (A : S.FormedSet) where
  set : S.FormedSet
  membership :
    (y : S.FormedSet) ->
      TypeEquiv (S.Mem y set) (ImagePreimage S f A y)

structure RelationalImageWitness
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet)
    (R : S.FormedSet -> S.FormedSet -> Type w)
    (y : S.FormedSet) where
  source : S.FormedSet
  source_mem : S.Mem source A
  related : R source y

structure RelationalImageFormation
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet)
    (R : S.FormedSet -> S.FormedSet -> Type w) where
  set : S.FormedSet
  membership :
    (y : S.FormedSet) ->
      TypeEquiv (S.Mem y set) (RelationalImageWitness S A R y)

def StrictFunctionalOn
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet)
    (R : S.FormedSet -> S.FormedSet -> Type w) :
    Prop :=
  (x : S.FormedSet) ->
  S.Mem x A ->
  (y z : S.FormedSet) ->
    R x y -> R x z -> y = z

def ProjectedFunctionalOn
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet)
    (R : S.FormedSet -> S.FormedSet -> Type w) :
    Prop :=
  (x : S.FormedSet) ->
  S.Mem x A ->
  (y z : S.FormedSet) ->
    R x y -> R x z -> S.project y = S.project z

def TotalOnOccurrences
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet)
    (R : S.FormedSet -> S.FormedSet -> Type w) :
    Type (max u m w) :=
  (x : S.FormedSet) ->
  S.Mem x A ->
    Sigma (fun y : S.FormedSet => R x y)

structure ReplacementFormation
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet)
    (R : S.FormedSet -> S.FormedSet -> Type w) where
  image : RelationalImageFormation S A R
  total : TotalOnOccurrences S A R
  functional : StrictFunctionalOn S A R

structure CollectionFormation
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet)
    (R : S.FormedSet -> S.FormedSet -> Type w) where
  set : S.FormedSet
  coverage :
    (x : S.FormedSet) ->
    S.Mem x A ->
      Sigma
        (fun y : S.FormedSet =>
          S.Mem y set × R x y)
  soundness :
    (y : S.FormedSet) ->
      S.Mem y set ->
        Sigma
          (fun x : S.FormedSet =>
            Sigma
              (fun _member : S.Mem x A =>
                R x y))

/-! ## Infinity, power, foundation, and recursion specifications -/

structure InfinityFormation
    (S : RawPositiveSetSignature.{u, v, m}) where
  zero : S.FormedSet
  succ : S.FormedSet -> S.FormedSet
  omega : S.FormedSet
  omega_zero : S.Mem zero omega
  omega_succ :
    (n : S.FormedSet) ->
      S.Mem n omega -> S.Mem (succ n) omega
  omega_induction :
    (P : S.FormedSet -> Prop) ->
      P zero ->
      ((n : S.FormedSet) ->
        S.Mem n omega ->
          P n -> P (succ n)) ->
        (n : S.FormedSet) ->
          S.Mem n omega -> P n

structure Subformation
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet) where
  carrier : S.FormedSet
  inclusion :
    {x : S.FormedSet} ->
      S.Mem x carrier -> S.Mem x A

structure SubformationRepresentation
    (S : RawPositiveSetSignature.{u, v, m})
    (A B : S.FormedSet) where
  subformation : Subformation S A
  carrier_eq : subformation.carrier = B

structure PowerFormation
    (S : RawPositiveSetSignature.{u, v, m})
    (A : S.FormedSet) where
  set : S.FormedSet
  membership :
    (B : S.FormedSet) ->
      TypeEquiv
        (S.Mem B set)
        (SubformationRepresentation S A B)

def MemRel
    (S : RawPositiveSetSignature.{u, v, m})
    (x A : S.FormedSet) :
    Prop :=
  Nonempty (S.Mem x A)

structure FormedFoundation
    (S : RawPositiveSetSignature.{u, v, m}) where
  wellFounded : WellFounded (MemRel S)

structure MembershipPresentation
    (S : RawPositiveSetSignature.{u, v, m}) where
  Position : S.FormedSet -> Type w
  child :
    (A : S.FormedSet) ->
      Position A -> S.FormedSet
  membership :
    (x A : S.FormedSet) ->
      TypeEquiv
        (S.Mem x A)
        { p : Position A // child A p = x }

def OccurrenceInductionStep
    {S : RawPositiveSetSignature.{u, v, m}}
    (presentation : MembershipPresentation.{u, v, m, w} S)
    (P : S.FormedSet -> Sort l) :=
  (A : S.FormedSet) ->
    ((p : presentation.Position A) ->
      P (presentation.child A p)) ->
        P A

/-! ## Local repair, causal repair, truth, and scenes -/

structure LocalProjectiveRecovery
    (S : RawPositiveSetSignature.{u, v, m})
    (RepairOf : S.FormedSet -> Type w) where
  formed : S.FormedSet
  shadow : S.FormedSet
  sameProjection : S.project formed = S.project shadow
  separated : formed = shadow -> False
  repair : RepairOf formed
  recovered : S.FormedSet
  recovered_eq_formed : recovered = formed

def localProjectiveRecovery_cell
    {S : RawPositiveSetSignature.{u, v, m}}
    {RepairOf : S.FormedSet -> Type w}
    (recovery : LocalProjectiveRecovery S RepairOf) :
    ProjectedSetCell S where
  formed := recovery.formed
  shadow := recovery.shadow
  sameVisible := recovery.sameProjection
  separated := recovery.separated

theorem localProjectiveRecovery_not_fiberFaithful
    {S : RawPositiveSetSignature.{u, v, m}}
    {RepairOf : S.FormedSet -> Type w}
    (recovery : LocalProjectiveRecovery S RepairOf)
    (faithful : ProjectionFiberFaithful S) :
    False :=
  projectedSetCell_not_fiberFaithful
    (localProjectiveRecovery_cell recovery)
    faithful

theorem localProjectiveRecovery_not_informationConserving
    {S : RawPositiveSetSignature.{u, v, m}}
    {RepairOf : S.FormedSet -> Type w}
    (recovery : LocalProjectiveRecovery S RepairOf)
    (conserving : ProjectionInformationConserving S) :
    False :=
  projectedSetCell_not_informationConserving
    (localProjectiveRecovery_cell recovery)
    conserving

structure RepairAction
    (S : RawPositiveSetSignature.{u, v, m})
    (RepairOf : S.FormedSet -> Type w) where
  applyRepair :
    (A : S.FormedSet) ->
      RepairOf A -> S.FormedSet

structure CausalLocalProjectiveRecovery
    (S : RawPositiveSetSignature.{u, v, m})
    (RepairOf : S.FormedSet -> Type w) where
  recovery : LocalProjectiveRecovery S RepairOf
  action : RepairAction S RepairOf
  repair_produces_recovered :
    action.applyRepair recovery.formed recovery.repair =
      recovery.recovered

structure RepairRelation
    (S : RawPositiveSetSignature.{u, v, m})
    (RepairOf : S.FormedSet -> Type w) where
  Repairs :
    (A : S.FormedSet) ->
      RepairOf A -> S.FormedSet -> Type l

structure RelationalLocalProjectiveRecovery
    (S : RawPositiveSetSignature.{u, v, m})
    (RepairOf : S.FormedSet -> Type w) where
  recovery : LocalProjectiveRecovery S RepairOf
  relation : RepairRelation.{u, v, m, w, l} S RepairOf
  repair_realizes :
    relation.Repairs
      recovery.formed
      recovery.repair
      recovery.recovered

structure LocalSetTruthGap
    (S : RawPositiveSetSignature.{u, v, m})
    (TruthData : S.FormedSet -> Type w)
    (RepairOf : S.FormedSet -> Type l) where
  recovery : LocalProjectiveRecovery S RepairOf
  formed_truth : TruthData recovery.formed
  shadow_not_truth : TruthData recovery.shadow -> False

theorem localSetTruthGap_noVisibleTruthClassifier
    {S : RawPositiveSetSignature.{u, v, m}}
    {TruthData : S.FormedSet -> Type w}
    {RepairOf : S.FormedSet -> Type l}
    (gap : LocalSetTruthGap S TruthData RepairOf)
    (visibleTruth : S.VisibleSet -> Prop)
    (classifier :
      (A : S.FormedSet) ->
        visibleTruth (S.project A) <->
          Nonempty (TruthData A)) :
    False := by
  have formedVisible :
      visibleTruth (S.project gap.recovery.formed) :=
    (classifier gap.recovery.formed).mpr
      (Nonempty.intro gap.formed_truth)
  have shadowVisible :
      visibleTruth (S.project gap.recovery.shadow) := by
    rw [gap.recovery.sameProjection] at formedVisible
    exact formedVisible
  have shadowTruth :
      Nonempty (TruthData gap.recovery.shadow) :=
    (classifier gap.recovery.shadow).mp shadowVisible
  exact
    shadowTruth.elim
      (fun truth => gap.shadow_not_truth truth)

def Scene
    (S : RawPositiveSetSignature.{u, v, m}) :
    Type u :=
  S.FormedSet -> Prop

structure GeometricFormationData
    (S : RawPositiveSetSignature.{u, v, m})
    (TruthData : S.FormedSet -> Type w)
    (scene : Scene S) where
  formed : S.FormedSet
  in_scene : scene formed
  truth : TruthData formed

def GeometricFormationProp
    (S : RawPositiveSetSignature.{u, v, m})
    (TruthData : S.FormedSet -> Type w)
    (scene : Scene S) :
    Prop :=
  Nonempty (GeometricFormationData S TruthData scene)

def ProjectedLocalTruth
    (S : RawPositiveSetSignature.{u, v, m})
    (TruthData : S.FormedSet -> Type w)
    (scene : Scene S) :
    Prop :=
  (A B : S.FormedSet) ->
    scene A ->
    scene B ->
    S.project A = S.project B ->
      (Nonempty (TruthData A) <->
        Nonempty (TruthData B))

def fullScene
    {S : RawPositiveSetSignature.{u, v, m}}
    {TruthData : S.FormedSet -> Type w}
    {RepairOf : S.FormedSet -> Type l}
    (gap : LocalSetTruthGap S TruthData RepairOf) :
    Scene S :=
  fun A =>
    A = gap.recovery.formed \/
      A = gap.recovery.shadow

def shadowScene
    {S : RawPositiveSetSignature.{u, v, m}}
    {TruthData : S.FormedSet -> Type w}
    {RepairOf : S.FormedSet -> Type l}
    (gap : LocalSetTruthGap S TruthData RepairOf) :
    Scene S :=
  fun A => A = gap.recovery.shadow

def fullSceneFormation
    {S : RawPositiveSetSignature.{u, v, m}}
    {TruthData : S.FormedSet -> Type w}
    {RepairOf : S.FormedSet -> Type l}
    (gap : LocalSetTruthGap S TruthData RepairOf) :
    GeometricFormationData S TruthData (fullScene gap) where
  formed := gap.recovery.formed
  in_scene := Or.inl rfl
  truth := gap.formed_truth

theorem fullScene_not_projectedTruth
    {S : RawPositiveSetSignature.{u, v, m}}
    {TruthData : S.FormedSet -> Type w}
    {RepairOf : S.FormedSet -> Type l}
    (gap : LocalSetTruthGap S TruthData RepairOf)
    (stable :
      ProjectedLocalTruth S TruthData (fullScene gap)) :
    False :=
  let transported :=
    (stable
      gap.recovery.formed
      gap.recovery.shadow
      (Or.inl rfl)
      (Or.inr rfl)
      gap.recovery.sameProjection).mp
        (Nonempty.intro gap.formed_truth)
  transported.elim
    (fun truth => gap.shadow_not_truth truth)

theorem shadowScene_projectedTruth
    {S : RawPositiveSetSignature.{u, v, m}}
    {TruthData : S.FormedSet -> Type w}
    {RepairOf : S.FormedSet -> Type l}
    (gap : LocalSetTruthGap S TruthData RepairOf) :
    ProjectedLocalTruth S TruthData (shadowScene gap) := by
  intro A B hA hB _sameVisible
  cases hA
  cases hB
  exact Iff.rfl

theorem shadowScene_no_formation
    {S : RawPositiveSetSignature.{u, v, m}}
    {TruthData : S.FormedSet -> Type w}
    {RepairOf : S.FormedSet -> Type l}
    (gap : LocalSetTruthGap S TruthData RepairOf)
    (formation :
      GeometricFormationData S TruthData (shadowScene gap)) :
    False := by
  have shadowTruth : TruthData gap.recovery.shadow := by
    rw [← formation.in_scene]
    exact formation.truth
  exact gap.shadow_not_truth shadowTruth

/-! ## Constructive choice from data -/

def choiceFromData
    {A : Type u}
    {B : A -> Type v}
    {R : (x : A) -> B x -> Type w}
    (h :
      (x : A) ->
        Sigma (fun y : B x => R x y)) :
    Sigma
      (fun f : ((x : A) -> B x) =>
        (x : A) -> R x (f x)) :=
  ⟨fun x => (h x).1, fun x => (h x).2⟩

/-! ## Global optional principles and hierarchy packages -/

structure UnionPrinciple
    (S : RawPositiveSetSignature.{u, v, m}) where
  union :
    (A : S.FormedSet) ->
      UnionFormation S A

structure ImagePrinciple
    (S : RawPositiveSetSignature.{u, v, m}) where
  image :
    (f : S.FormedSet -> S.FormedSet) ->
    (A : S.FormedSet) ->
      ImageFormation S f A

structure RelationalImagePrinciple
    (S : RawPositiveSetSignature.{u, v, m}) where
  relationalImage :
    (A : S.FormedSet) ->
    (R : S.FormedSet -> S.FormedSet -> Type w) ->
      RelationalImageFormation S A R

structure StrongCollectionPrinciple
    (S : RawPositiveSetSignature.{u, v, m}) where
  collect :
    (A : S.FormedSet) ->
    (R : S.FormedSet -> S.FormedSet -> Type w) ->
      TotalOnOccurrences S A R ->
        CollectionFormation S A R

structure PowerPrinciple
    (S : RawPositiveSetSignature.{u, v, m}) where
  power :
    (A : S.FormedSet) ->
      PowerFormation S A

structure FormedInductionPrinciple
    (S : RawPositiveSetSignature.{u, v, m}) where
  induction :
    (P : S.FormedSet -> Prop) ->
      ((A : S.FormedSet) ->
        ((x : S.FormedSet) ->
          MemRel S x A -> P x) ->
            P A) ->
        (A : S.FormedSet) -> P A

structure Normalization
    (S : RawPositiveSetSignature.{u, v, m}) where
  normalize : S.FormedSet -> S.FormedSet
  sameProjection :
    (A : S.FormedSet) ->
      S.project (normalize A) = S.project A
  faithfulOnNormal :
    (A B : S.FormedSet) ->
      S.project (normalize A) = S.project (normalize B) ->
        normalize A = normalize B

abbrev VisibleRepresentativeSelection
    (S : RawPositiveSetSignature.{u, v, m}) :
    Type (max u v) :=
  VisibleCoverage S

structure ProjectionRegime
    (FormedSet : Type u) where
  VisibleSet : Type v
  project : FormedSet -> VisibleSet
  VisibleMem : VisibleSet -> VisibleSet -> Prop

structure ProjectionChange
    (S : RawPositiveSetSignature.{u, v, m})
    (R : ProjectionRegime.{u, v} S.FormedSet) where
  mapVisible : S.VisibleSet -> R.VisibleSet
  commutes :
    (A : S.FormedSet) ->
      mapVisible (S.project A) = R.project A

structure ProjectedRegimeCell
    (FormedSet : Type u)
    (R : ProjectionRegime.{u, v} FormedSet) where
  formed : FormedSet
  shadow : FormedSet
  sameVisible : R.project formed = R.project shadow
  separated : formed = shadow -> False

def projectedRegimeCellOfChange
    {S : RawPositiveSetSignature.{u, v, m}}
    {R : ProjectionRegime.{u, v} S.FormedSet}
    (change : ProjectionChange S R)
    (cell : ProjectedSetCell S) :
    ProjectedRegimeCell S.FormedSet R where
  formed := cell.formed
  shadow := cell.shadow
  sameVisible :=
    calc
      R.project cell.formed =
          change.mapVisible (S.project cell.formed) :=
        Eq.symm (change.commutes cell.formed)
      _ = change.mapVisible (S.project cell.shadow) :=
        congrArg change.mapVisible cell.sameVisible
      _ = R.project cell.shadow :=
        change.commutes cell.shadow
  separated := cell.separated

structure PositiveDiagonalPersistence
    (S : RawPositiveSetSignature.{u, v, m})
    (WitnessOf : ProjectedSetCell S -> Type w)
    (Positive :
      (cell : ProjectedSetCell S) ->
        WitnessOf cell -> Prop)
    (diag : PositiveSetDiagonalization S WitnessOf Positive)
    (R : ProjectionRegime.{u, v} S.FormedSet) where
  change : ProjectionChange S R
  targetCell : ProjectedRegimeCell S.FormedSet R
  target_matches_change :
    targetCell =
      projectedRegimeCellOfChange change diag.cell

structure PFSD where
  S : RawPositiveSetSignature.{u, v, m}
  visible : VisibleExtensionalStructure S
  empty : EmptyFormation S
  pair :
    (A B : S.FormedSet) ->
      PairEquivFormation S A B
  rigidity : PairRigidity S pair
  pairProjection :
    (A B : S.FormedSet) ->
      PairProjectionLaw (pair A B)

def PFSD.canonicalDiagonal
    (T : PFSD.{u, v, m}) :
    PositiveSetDiagonalization T.S
      (PairSwapWitness T.S T.pair
        (canonicalLeft T.empty)
        (canonicalRight T.empty T.pair))
      (PairSwapPositive
        (pair := T.pair)
        (canonicalLeft T.empty)
        (canonicalRight T.empty T.pair)) :=
  canonicalPositiveDiagonal
    T.visible
    T.empty
    T.pair
    T.rigidity
    T.pairProjection

structure PFS0Reflected where
  S : RawPositiveSetSignature.{u, v, m}
  projection : MembershipProjection S
  reflection : MembershipReflection S
  visible : VisibleExtensionalStructure S
  empty : EmptyFormation S
  pair :
    (A B : S.FormedSet) ->
      PairEquivFormation S A B
  rigidity : PairRigidity S pair
  union : UnionPrinciple S
  bounded : BoundedSeparationData.{u, v, m, w} S

def PFS0Reflected.pairProjection
    (T : PFS0Reflected.{u, v, m, w})
    (A B : T.S.FormedSet) :
    PairProjectionLaw (T.pair A B) :=
  pairProjectionLawOfReflection
    T.projection
    T.reflection
    (T.pair A B)

def PFS0Reflected.toPFSD
    (T : PFS0Reflected.{u, v, m, w}) :
    PFSD.{u, v, m} where
  S := T.S
  visible := T.visible
  empty := T.empty
  pair := T.pair
  rigidity := T.rigidity
  pairProjection := T.pairProjection

structure PFS0Realized where
  base : PFS0Reflected.{u, v, m, w}
  realization : MembershipRealization base.S

structure PFSCollectionCore where
  base : PFS0Reflected.{u, v, m, w}
  infinity : InfinityFormation base.S
  collection : StrongCollectionPrinciple.{u, v, m, l} base.S
  induction : FormedInductionPrinciple base.S

structure PFSCollectionCoreRealized where
  base : PFSCollectionCore.{u, v, m, w, l}
  realization : MembershipRealization base.base.S

structure PFSPower where
  base : PFSCollectionCore.{u, v, m, w, l}
  power : PowerPrinciple base.base.S

structure PFSOperational where
  base : PFS0Reflected.{u, v, m, w}
  RepairOf : base.S.FormedSet -> Type l
  recovery : LocalProjectiveRecovery base.S RepairOf

structure PFSTruth where
  base : PFS0Reflected.{u, v, m, w}
  TruthData : base.S.FormedSet -> Type l
  RepairOf : base.S.FormedSet -> Type w
  truthGap : LocalSetTruthGap base.S TruthData RepairOf

structure ModelObligations
    (S : RawPositiveSetSignature.{u, v, m}) where
  projection : MembershipProjection S
  visible : VisibleExtensionalStructure S
  empty : EmptyFormation S
  pair :
    (A B : S.FormedSet) ->
      PairEquivFormation S A B
  rigidity : PairRigidity S pair
  pairProjection :
    (A B : S.FormedSet) ->
      PairProjectionLaw (pair A B)

/-! ## Degenerate toy model for the raw adequate skeleton -/

def degenerateRaw :
    RawPositiveSetSignature.{0, 0, 0} where
  FormedSet := Bool
  VisibleSet := Unit
  project := fun _ => ()
  Mem := fun _ _ => Empty
  VisibleMem := fun _ _ => False

def degenerateMembershipProjection :
    MembershipProjection degenerateRaw where
  visibleMemOfMem h := nomatch h

def degenerateMembershipReflection :
    MembershipReflection degenerateRaw where
  reflected h := nomatch h

def degenerateVisibleExtensionality :
    VisibleExtensionalStructure degenerateRaw where
  visibleExtensionality V W _ := by
    cases V
    cases W
    rfl

def degenerateCell :
    ProjectedSetCell degenerateRaw where
  formed := true
  shadow := false
  sameVisible := rfl
  separated := by
    intro h
    cases h

def degenerateEmptyFormation :
    EmptyFormation degenerateRaw where
  set := true
  elim _ h := nomatch h

end PositiveSetTheoryStandalone

/- AXIOM_AUDIT_BEGIN -/
#print axioms PositiveSetTheoryStandalone.RawPositiveSetSignature
#print axioms PositiveSetTheoryStandalone.MembershipProjection
#print axioms PositiveSetTheoryStandalone.VisibleMembershipLift
#print axioms PositiveSetTheoryStandalone.MembershipReflection
#print axioms PositiveSetTheoryStandalone.MembershipRealization
#print axioms PositiveSetTheoryStandalone.membershipReflectionOfRealization
#print axioms PositiveSetTheoryStandalone.VisibleExtensionalStructure
#print axioms PositiveSetTheoryStandalone.PositiveSetContext
#print axioms PositiveSetTheoryStandalone.RepresentedVisible
#print axioms PositiveSetTheoryStandalone.VisibleCoverage
#print axioms PositiveSetTheoryStandalone.VisibleCovered
#print axioms PositiveSetTheoryStandalone.visibleCoveredOfCoverage
#print axioms PositiveSetTheoryStandalone.visibleMembershipLift_to_visibleMem
#print axioms PositiveSetTheoryStandalone.membershipReflection_iff_visibleMembershipLift
#print axioms PositiveSetTheoryStandalone.InternalIdentity
#print axioms PositiveSetTheoryStandalone.ProjectedIdentity
#print axioms PositiveSetTheoryStandalone.IdentityOfUse
#print axioms PositiveSetTheoryStandalone.InterfaceTransport
#print axioms PositiveSetTheoryStandalone.identityOfUse_iff_projectedIdentity
#print axioms PositiveSetTheoryStandalone.projectedIdentity_to_interfaceTransport
#print axioms PositiveSetTheoryStandalone.interfaceTransport_to_projectedIdentity
#print axioms PositiveSetTheoryStandalone.interfaceTransport_iff_projectedIdentity
#print axioms PositiveSetTheoryStandalone.ProjectedSetCell
#print axioms PositiveSetTheoryStandalone.ProjectionFiberFaithful
#print axioms PositiveSetTheoryStandalone.ProjectionInformationConserving
#print axioms PositiveSetTheoryStandalone.projectedSetCell_not_fiberFaithful
#print axioms PositiveSetTheoryStandalone.projectedSetCell_not_informationConserving
#print axioms PositiveSetTheoryStandalone.PositiveSetDiagonalization
#print axioms PositiveSetTheoryStandalone.EmptyFormation
#print axioms PositiveSetTheoryStandalone.EmptyProjectionLaw
#print axioms PositiveSetTheoryStandalone.emptyProjectionLawOfReflection
#print axioms PositiveSetTheoryStandalone.TypeEquiv
#print axioms PositiveSetTheoryStandalone.PairOccurrence
#print axioms PositiveSetTheoryStandalone.PairEquivFormation
#print axioms PositiveSetTheoryStandalone.PairRigidity
#print axioms PositiveSetTheoryStandalone.PairProjectionLaw
#print axioms PositiveSetTheoryStandalone.pairProjectionLawOfReflection
#print axioms PositiveSetTheoryStandalone.pairSwap_sameVisible
#print axioms PositiveSetTheoryStandalone.canonicalLeft
#print axioms PositiveSetTheoryStandalone.canonicalRight
#print axioms PositiveSetTheoryStandalone.canonicalParameters_separated
#print axioms PositiveSetTheoryStandalone.canonicalPairCell
#print axioms PositiveSetTheoryStandalone.PairOccurrenceWitness
#print axioms PositiveSetTheoryStandalone.pairOccurrenceWitnessOfOccurrence
#print axioms PositiveSetTheoryStandalone.PairSwapWitness
#print axioms PositiveSetTheoryStandalone.PairSwapPositive
#print axioms PositiveSetTheoryStandalone.canonicalPairSwapWitness
#print axioms PositiveSetTheoryStandalone.canonicalPositiveDiagonal
#print axioms PositiveSetTheoryStandalone.UnionMembership
#print axioms PositiveSetTheoryStandalone.UnionFormation
#print axioms PositiveSetTheoryStandalone.UnionProjectionLaw
#print axioms PositiveSetTheoryStandalone.unionProjectionLawOfReflection
#print axioms PositiveSetTheoryStandalone.SeparatedMembership
#print axioms PositiveSetTheoryStandalone.SeparationFormation
#print axioms PositiveSetTheoryStandalone.SeparationProjectionLaw
#print axioms PositiveSetTheoryStandalone.separationProjectionLawOfReflection
#print axioms PositiveSetTheoryStandalone.BoundedSeparationData
#print axioms PositiveSetTheoryStandalone.BoundedPredicateVisibleSemantics
#print axioms PositiveSetTheoryStandalone.ImagePreimage
#print axioms PositiveSetTheoryStandalone.ImageFormation
#print axioms PositiveSetTheoryStandalone.RelationalImageWitness
#print axioms PositiveSetTheoryStandalone.RelationalImageFormation
#print axioms PositiveSetTheoryStandalone.StrictFunctionalOn
#print axioms PositiveSetTheoryStandalone.ProjectedFunctionalOn
#print axioms PositiveSetTheoryStandalone.TotalOnOccurrences
#print axioms PositiveSetTheoryStandalone.ReplacementFormation
#print axioms PositiveSetTheoryStandalone.CollectionFormation
#print axioms PositiveSetTheoryStandalone.InfinityFormation
#print axioms PositiveSetTheoryStandalone.Subformation
#print axioms PositiveSetTheoryStandalone.SubformationRepresentation
#print axioms PositiveSetTheoryStandalone.PowerFormation
#print axioms PositiveSetTheoryStandalone.MemRel
#print axioms PositiveSetTheoryStandalone.FormedFoundation
#print axioms PositiveSetTheoryStandalone.MembershipPresentation
#print axioms PositiveSetTheoryStandalone.OccurrenceInductionStep
#print axioms PositiveSetTheoryStandalone.LocalProjectiveRecovery
#print axioms PositiveSetTheoryStandalone.localProjectiveRecovery_cell
#print axioms PositiveSetTheoryStandalone.localProjectiveRecovery_not_fiberFaithful
#print axioms PositiveSetTheoryStandalone.localProjectiveRecovery_not_informationConserving
#print axioms PositiveSetTheoryStandalone.RepairAction
#print axioms PositiveSetTheoryStandalone.CausalLocalProjectiveRecovery
#print axioms PositiveSetTheoryStandalone.RepairRelation
#print axioms PositiveSetTheoryStandalone.RelationalLocalProjectiveRecovery
#print axioms PositiveSetTheoryStandalone.LocalSetTruthGap
#print axioms PositiveSetTheoryStandalone.localSetTruthGap_noVisibleTruthClassifier
#print axioms PositiveSetTheoryStandalone.Scene
#print axioms PositiveSetTheoryStandalone.GeometricFormationData
#print axioms PositiveSetTheoryStandalone.GeometricFormationProp
#print axioms PositiveSetTheoryStandalone.ProjectedLocalTruth
#print axioms PositiveSetTheoryStandalone.fullScene
#print axioms PositiveSetTheoryStandalone.shadowScene
#print axioms PositiveSetTheoryStandalone.fullSceneFormation
#print axioms PositiveSetTheoryStandalone.fullScene_not_projectedTruth
#print axioms PositiveSetTheoryStandalone.shadowScene_projectedTruth
#print axioms PositiveSetTheoryStandalone.shadowScene_no_formation
#print axioms PositiveSetTheoryStandalone.choiceFromData
#print axioms PositiveSetTheoryStandalone.UnionPrinciple
#print axioms PositiveSetTheoryStandalone.ImagePrinciple
#print axioms PositiveSetTheoryStandalone.RelationalImagePrinciple
#print axioms PositiveSetTheoryStandalone.StrongCollectionPrinciple
#print axioms PositiveSetTheoryStandalone.PowerPrinciple
#print axioms PositiveSetTheoryStandalone.FormedInductionPrinciple
#print axioms PositiveSetTheoryStandalone.Normalization
#print axioms PositiveSetTheoryStandalone.VisibleRepresentativeSelection
#print axioms PositiveSetTheoryStandalone.ProjectionRegime
#print axioms PositiveSetTheoryStandalone.ProjectionChange
#print axioms PositiveSetTheoryStandalone.ProjectedRegimeCell
#print axioms PositiveSetTheoryStandalone.projectedRegimeCellOfChange
#print axioms PositiveSetTheoryStandalone.PositiveDiagonalPersistence
#print axioms PositiveSetTheoryStandalone.PFSD
#print axioms PositiveSetTheoryStandalone.PFSD.canonicalDiagonal
#print axioms PositiveSetTheoryStandalone.PFS0Reflected
#print axioms PositiveSetTheoryStandalone.PFS0Reflected.pairProjection
#print axioms PositiveSetTheoryStandalone.PFS0Reflected.toPFSD
#print axioms PositiveSetTheoryStandalone.PFS0Realized
#print axioms PositiveSetTheoryStandalone.PFSCollectionCore
#print axioms PositiveSetTheoryStandalone.PFSCollectionCoreRealized
#print axioms PositiveSetTheoryStandalone.PFSPower
#print axioms PositiveSetTheoryStandalone.PFSOperational
#print axioms PositiveSetTheoryStandalone.PFSTruth
#print axioms PositiveSetTheoryStandalone.ModelObligations
#print axioms PositiveSetTheoryStandalone.degenerateRaw
#print axioms PositiveSetTheoryStandalone.degenerateMembershipProjection
#print axioms PositiveSetTheoryStandalone.degenerateMembershipReflection
#print axioms PositiveSetTheoryStandalone.degenerateVisibleExtensionality
#print axioms PositiveSetTheoryStandalone.degenerateCell
#print axioms PositiveSetTheoryStandalone.degenerateEmptyFormation
/- AXIOM_AUDIT_END -/
