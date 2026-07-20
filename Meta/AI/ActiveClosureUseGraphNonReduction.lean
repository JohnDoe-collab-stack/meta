import Meta.AI.ActiveClosureFoundationalRealization
import Meta.Semantics.UseGraphNonReduction

/-!
# The finite active-closure semantics is not determined by its use graph

The two models below have definitionally the same proof-relevant `PoleUse`
family.  Their output relations both retain the full base transport, but only
the precise model retains the operational-use trace computed from that
transport.  A concrete first-gap transport distinguishes the models.  The
distinction is therefore in executed transport data, not in a constant
observer or in a changed edge relation.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace FoundationalNonReduction

open RelaxedSemantics
open Foundational

inductive TransportTraceMode where
  | precise
  | erased
  deriving DecidableEq

def operationalTrace
    (mode : TransportTraceMode)
    {context : ClosureContext}
    {left right : Pole} :
    PoleUse context left right -> List Bool
  | .identity _ => []
  | .authorizedGap _ _ _ _ =>
      match mode with
      | .precise => [true]
      | .erased => []

theorem operationalTrace_compose
    (mode : TransportTraceMode)
    {context : ClosureContext}
    {left middle right : Pole}
    (first : PoleUse context left middle)
    (second : PoleUse context middle right) :
    operationalTrace mode (PoleUse.compose first second) =
      operationalTrace mode first ++ operationalTrace mode second := by
  cases mode <;> cases first <;> cases second <;> rfl

theorem operationalTrace_reindex
    (mode : TransportTraceMode)
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma)
    {left right : Pole}
    (use : PoleUse gamma left right) :
    operationalTrace mode (reindexPoleUse substitution use) =
      operationalTrace mode use := by
  cases mode <;> cases use <;> rfl

structure AuditedPoleOutputRelation
    (mode : TransportTraceMode)
    (context : ClosureContext)
    (reading : PoleReading)
    (left right : PoleOutput reading) where
  base : PoleOutputRelation context reading left right
  operationalTrace : List Bool

theorem AuditedPoleOutputRelation.ext
    {mode : TransportTraceMode}
    {context : ClosureContext}
    {reading : PoleReading}
    {left right : PoleOutput reading}
    {first second : AuditedPoleOutputRelation mode context reading left right}
    (base_eq : first.base = second.base)
    (trace_eq : first.operationalTrace = second.operationalTrace) :
    first = second := by
  cases first
  cases second
  cases base_eq
  cases trace_eq
  rfl

def auditedTransport
    (mode : TransportTraceMode)
    {context : ClosureContext}
    {left right : Pole}
    (use : PoleUse context left right)
    (reading : PoleReading) :
    AuditedPoleOutputRelation mode context reading
      (readPole context reading left)
      (readPole context reading right) := by
  cases reading with
  | formed =>
      exact
        { base := use
          operationalTrace := operationalTrace mode use }
  | visible =>
      exact
        { base := visibleTransportOfPoleUse use
          operationalTrace := operationalTrace mode use }

def auditedOutIdentity
    (mode : TransportTraceMode)
    (context : ClosureContext)
    (reading : PoleReading)
    (pole : Pole) :
    AuditedPoleOutputRelation mode context reading
      (readPole context reading pole)
      (readPole context reading pole) := by
  cases reading with
  | formed =>
      exact { base := .identity pole, operationalTrace := [] }
  | visible =>
      exact
        { base := .identity context (readPole context .visible pole)
          operationalTrace := [] }

def auditedOutCompose
    (mode : TransportTraceMode)
    {context : ClosureContext}
    (reading : PoleReading)
    {left middle right : Pole}
    (first :
      AuditedPoleOutputRelation mode context reading
        (readPole context reading left)
        (readPole context reading middle))
    (second :
      AuditedPoleOutputRelation mode context reading
        (readPole context reading middle)
        (readPole context reading right)) :
    AuditedPoleOutputRelation mode context reading
      (readPole context reading left)
      (readPole context reading right) := by
  cases reading with
  | formed =>
      exact
        { base := PoleUse.compose first.base second.base
          operationalTrace := first.operationalTrace ++ second.operationalTrace }
  | visible =>
      exact
        { base := VisiblePoleTransport.compose first.base second.base
          operationalTrace := first.operationalTrace ++ second.operationalTrace }

def reindexAuditedRelation
    (mode : TransportTraceMode)
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma)
    (reading : PoleReading)
    {left right : Pole}
    (relation :
      AuditedPoleOutputRelation mode gamma reading
        (readPole gamma reading left)
        (readPole gamma reading right)) :
    AuditedPoleOutputRelation mode delta reading
      (readPole delta reading left)
      (readPole delta reading right) := by
  cases reading with
  | formed =>
      exact
        { base := reindexPoleUse substitution relation.base
          operationalTrace := relation.operationalTrace }
  | visible =>
      exact
        { base := reindexVisiblePoleTransport substitution relation.base
          operationalTrace := relation.operationalTrace }

abbrev auditedClosureRegime (mode : TransportTraceMode) :
    ContextualRelaxedRegime closureContextCategory closureTermLanguage where
  Read := fun _ _ => PoleReading
  defaultRead := fun _ _ => .formed
  Out := fun _ _ reading => PoleOutput reading
  read := fun {context _} reading pole => readPole context reading pole
  Sep := fun {context _} left right => PoleSeparation context left right
  Coord := fun {context _} left right => PoleCoordination context left right
  Use := fun {context _} left right => PoleUse context left right
  OutRel := fun {context _} reading =>
    AuditedPoleOutputRelation mode context reading
  identityUse := fun {_ _} pole => .identity pole
  composeUse := fun {_ _ _ _ _} first second => first.compose second
  useOfNoncontractive := fun {_ _ _ _} separation coordination =>
    poleUseOfNoncontractive separation coordination
  transport := fun {_ _ _ _} use reading => auditedTransport mode use reading
  outIdentity := fun {context _} reading pole =>
    auditedOutIdentity mode context reading pole
  outCompose := fun {_ _} reading {_ _ _} first second =>
    auditedOutCompose mode reading first second
  reindexRead := fun {_ _} _ {_} reading => reading
  reindexSep := fun {_ _} substitution {_ _ _} separation =>
    reindexPoleSeparation substitution separation
  reindexCoord := fun {_ _} substitution {_ _ _} coordination =>
    reindexPoleCoordination substitution coordination
  reindexUse := fun {_ _} substitution {_ _ _} use =>
    reindexPoleUse substitution use
  reindexOutRel := fun {_ _} substitution {_} reading {_ _} relation =>
    reindexAuditedRelation mode substitution reading relation

def auditedClosureRegimeLaws (mode : TransportTraceMode) :
    LawfulContextualRelaxedRegime (auditedClosureRegime mode) where
  contextLaws := closureContextLaws
  termLaws := closureTermLanguageLaws
  separationRefutesIdentity := by
    intro context sort left right separation equality
    cases separation
    cases equality
  useLeftIdentity := by
    intro context sort left right use
    change PoleUse.compose (.identity left) use = use
    exact PoleUse.leftIdentity use
  useRightIdentity := by
    intro context sort left right use
    change PoleUse.compose use (.identity right) = use
    exact PoleUse.rightIdentity use
  useAssociativity := by
    intro context sort a b c d first second third
    change PoleUse.compose (PoleUse.compose first second) third =
      PoleUse.compose first (PoleUse.compose second third)
    exact PoleUse.associativity first second third
  outLeftIdentity := by
    intro context sort reading left right relation
    change
      auditedOutCompose mode reading
          (auditedOutIdentity mode context reading left) relation = relation
    apply AuditedPoleOutputRelation.ext
    · cases reading with
      | formed => exact PoleUse.leftIdentity relation.base
      | visible => exact relation.base.leftIdentity
    · cases reading
      · rfl
      · rfl
  outRightIdentity := by
    intro context sort reading left right relation
    change
      auditedOutCompose mode reading relation
          (auditedOutIdentity mode context reading right) = relation
    apply AuditedPoleOutputRelation.ext
    · cases reading with
      | formed => exact PoleUse.rightIdentity relation.base
      | visible => exact relation.base.rightIdentity
    · cases reading
      · exact listAppendNil relation.operationalTrace
      · exact listAppendNil relation.operationalTrace
  outAssociativity := by
    intro context sort reading a b c d first second third
    change
      auditedOutCompose mode reading
          (auditedOutCompose mode reading first second) third =
        auditedOutCompose mode reading first
          (auditedOutCompose mode reading second third)
    apply AuditedPoleOutputRelation.ext
    · cases reading with
      | formed =>
          exact PoleUse.associativity first.base second.base third.base
      | visible =>
          exact VisiblePoleTransport.associativity
            first.base second.base third.base
    · cases reading
      · exact listAppendAssociative
          first.operationalTrace second.operationalTrace third.operationalTrace
      · exact listAppendAssociative
          first.operationalTrace second.operationalTrace third.operationalTrace
  transportIdentity := by
    intro context sort reading pole
    change auditedTransport mode (.identity pole) reading =
      auditedOutIdentity mode context reading pole
    apply AuditedPoleOutputRelation.ext
    · cases reading <;> rfl
    · cases mode <;> rfl
  transportComposition := by
    intro context sort reading left middle right first second
    change auditedTransport mode (PoleUse.compose first second) reading =
      auditedOutCompose mode reading
        (auditedTransport mode first reading)
        (auditedTransport mode second reading)
    apply AuditedPoleOutputRelation.ext
    · cases reading with
      | formed => cases first <;> cases second <;> rfl
      | visible => exact visibleTransportOfPoleUse_compose first second
    · cases reading
      · exact operationalTrace_compose mode first second
      · exact operationalTrace_compose mode first second
  reindexReadIdentity := by intros; rfl
  reindexReadComposition := by intros; rfl
  transportReindexing := by
    intro delta gamma substitution sort reading left right use
    change
      reindexAuditedRelation mode substitution reading
          (auditedTransport mode use reading) =
        auditedTransport mode (reindexPoleUse substitution use) reading
    apply AuditedPoleOutputRelation.ext
    · cases reading with
      | formed => rfl
      | visible => exact visibleTransportOfPoleUse_reindex substitution use
    · cases reading
      · exact (operationalTrace_reindex mode substitution use).symm
      · exact (operationalTrace_reindex mode substitution use).symm

abbrev auditedClosureDoctrine (mode : TransportTraceMode) :
    AdmissiblePredicateDoctrine (auditedClosureRegime mode) where
  Pred := fun _ _ => MonotonePolePredicate
  Holds := fun predicate pole => predicate.Holds pole
  top := fun _ _ => polePredicateTop
  bottom := fun _ _ => polePredicateBottom
  conjunction := polePredicateConjunction
  reindexPred := fun {_ _} _ {_} predicate => predicate
  substituteUse := fun {_ _ _ _} use predicate proof =>
    predicate.preserves use proof

def auditedClosureDoctrineLaws (mode : TransportTraceMode) :
    LawfulAdmissiblePredicateDoctrine (auditedClosureDoctrine mode) where
  holdsTop := by intros; exact True.intro
  holdsBottomRefuted := fun impossible => impossible
  holdsConjunctionLeft := fun proof => proof.1
  holdsConjunctionRight := fun proof => proof.2
  holdsConjunction := fun left right => ⟨left, right⟩
  reindexHolds := by intros; assumption
  reindexReflectsHolds := by intros; assumption
  substitutionIdentity := by intros; exact Subsingleton.elim _ _
  substitutionComposition := by intros; exact Subsingleton.elim _ _

def activeClosureSameUseGraph :
    SameContextualUseGraph
      (auditedClosureRegime .precise)
      (auditedClosureRegime .erased) where
  forward := fun use => use
  backward := fun use => use
  backwardForward := fun _ => rfl
  forwardBackward := fun _ => rfl

def traceIsNonempty {Element : Type} : List Element -> Bool
  | [] => false
  | _ :: _ => true

def activeClosureTransportDistinction :
    TransportSemanticDistinction
      (auditedClosureRegime .precise)
      (auditedClosureRegime .erased) where
  context := contextOfState .initial
  sort := ClosureSort.gap
  source := .origin
  target := .destination
  leftUse := regimeUseOfAuthorization .first
  rightUse := regimeUseOfAuthorization .first
  leftReading := .visible
  rightReading := .visible
  observeLeft := fun relation => traceIsNonempty relation.operationalTrace
  observeRight := fun relation => traceIsNonempty relation.operationalTrace
  leftObserved := rfl
  rightObserved := rfl

def activeClosurePredicateDistinction :
    PredicateSemanticDistinction
      (auditedClosureDoctrine .precise)
      (auditedClosureDoctrine .erased) where
  context := contextOfState .initial
  sort := ClosureSort.gap
  term := .destination
  leftPredicate := reachedRightPole
  rightPredicate := polePredicateBottom
  leftHolds := True.intro
  rightRefuted := fun impossible => impossible

def activeClosureUseGraphSemanticNonReduction :
    UseGraphSemanticNonReduction
      (auditedClosureRegime .precise)
      (auditedClosureRegime .erased)
      (auditedClosureDoctrine .precise)
      (auditedClosureDoctrine .erased) where
  sameGraph := activeClosureSameUseGraph
  transportDistinction := activeClosureTransportDistinction
  predicateDistinction := activeClosurePredicateDistinction

def preciseFirstTransport :
    AuditedPoleOutputRelation .precise
      (contextOfState .initial) .visible
      (readPole (contextOfState .initial) .visible .origin)
      (readPole (contextOfState .initial) .visible .destination) :=
  @(auditedClosureRegime .precise).transport
    (contextOfState .initial) ClosureSort.gap .origin .destination
    (regimeUseOfAuthorization .first) .visible

def erasedFirstTransport :
    AuditedPoleOutputRelation .erased
      (contextOfState .initial) .visible
      (readPole (contextOfState .initial) .visible .origin)
      (readPole (contextOfState .initial) .visible .destination) :=
  @(auditedClosureRegime .erased).transport
    (contextOfState .initial) ClosureSort.gap .origin .destination
    (regimeUseOfAuthorization .first) .visible

theorem preciseFirstTransport_trace :
    preciseFirstTransport.operationalTrace = [true] :=
  rfl

theorem erasedFirstTransport_trace :
    erasedFirstTransport.operationalTrace = [] :=
  rfl

structure AIUseGraphNonReductionCertificate where
  preciseLaws :
    LawfulContextualRelaxedRegime (auditedClosureRegime .precise)
  erasedLaws :
    LawfulContextualRelaxedRegime (auditedClosureRegime .erased)
  preciseDoctrineLaws :
    LawfulAdmissiblePredicateDoctrine (auditedClosureDoctrine .precise)
  erasedDoctrineLaws :
    LawfulAdmissiblePredicateDoctrine (auditedClosureDoctrine .erased)
  nonReduction :
    UseGraphSemanticNonReduction
      (auditedClosureRegime .precise)
      (auditedClosureRegime .erased)
      (auditedClosureDoctrine .precise)
      (auditedClosureDoctrine .erased)
  concretePreciseTrace :
    preciseFirstTransport.operationalTrace = [true]
  concreteErasedTrace :
    erasedFirstTransport.operationalTrace = []

def aiUseGraphNonReductionCertificate :
    AIUseGraphNonReductionCertificate where
  preciseLaws := auditedClosureRegimeLaws .precise
  erasedLaws := auditedClosureRegimeLaws .erased
  preciseDoctrineLaws := auditedClosureDoctrineLaws .precise
  erasedDoctrineLaws := auditedClosureDoctrineLaws .erased
  nonReduction := activeClosureUseGraphSemanticNonReduction
  concretePreciseTrace := preciseFirstTransport_trace
  concreteErasedTrace := erasedFirstTransport_trace

end FoundationalNonReduction
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.FoundationalNonReduction.auditedClosureRegimeLaws
#print axioms Meta.ActiveSemanticClosure.FoundationalNonReduction.activeClosureSameUseGraph
#print axioms Meta.ActiveSemanticClosure.FoundationalNonReduction.activeClosureTransportDistinction
#print axioms Meta.ActiveSemanticClosure.FoundationalNonReduction.activeClosureUseGraphSemanticNonReduction
#print axioms Meta.ActiveSemanticClosure.FoundationalNonReduction.aiUseGraphNonReductionCertificate
/- AXIOM_AUDIT_END -/
