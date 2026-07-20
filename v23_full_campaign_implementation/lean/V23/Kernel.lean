namespace V23

structure RawStep where
  beforeFiber : List Nat
  afterFiber : List Nat
  query : Nat
  response : Nat
  repair : Nat
  provenance : List Nat
  retainedClosures : Nat
  memoryBefore : List Nat
  memoryAfter : List Nat
  transitionDerivedFromRepair : Bool
deriving Repr, DecidableEq

structure RawTrace where
  initialFiber : List Nat
  actualWorld : Nat
  steps : List RawStep
  finalFiber : List Nat
  requiredAction : Nat
  predictedAction : Nat
  closed : Bool
deriving Repr, DecidableEq

def listSubset (left right : List Nat) : Bool :=
  left.all fun item => right.contains item

def validStep (current : List Nat) (actualWorld : Nat) (expectedRetained : Nat)
    (step : RawStep) : Bool :=
  (step.beforeFiber == current) &&
  !step.afterFiber.isEmpty &&
  listSubset step.afterFiber step.beforeFiber &&
  (step.afterFiber.length < step.beforeFiber.length) &&
  step.afterFiber.contains actualWorld &&
  step.provenance.contains step.query &&
  step.provenance.contains step.response &&
  listSubset step.memoryBefore step.memoryAfter &&
  (step.retainedClosures == expectedRetained) &&
  step.transitionDerivedFromRepair

def validOrbitFrom : Nat → List Nat → Nat → List RawStep → List Nat → Bool
  | _, current, _, [], finalFiber => current == finalFiber
  | index, current, actualWorld, step :: remaining, finalFiber =>
      validStep current actualWorld index step &&
      validOrbitFrom (index + 1) step.afterFiber actualWorld remaining finalFiber

def validOrbit (current : List Nat) (actualWorld : Nat)
    (steps : List RawStep) (finalFiber : List Nat) : Bool :=
  validOrbitFrom 0 current actualWorld steps finalFiber

def validTrace (trace : RawTrace) : Bool :=
  !trace.initialFiber.isEmpty &&
  trace.initialFiber.contains trace.actualWorld &&
  validOrbit trace.initialFiber trace.actualWorld trace.steps trace.finalFiber &&
  (trace.closed == (trace.requiredAction == trace.predictedAction))

def ValidTrace (trace : RawTrace) : Prop := validTrace trace = true

instance validTraceDecidable (trace : RawTrace) : Decidable (ValidTrace trace) := by
  unfold ValidTrace
  infer_instance

structure ValidCertifiedRun where
  trace : RawTrace
  valid : ValidTrace trace

theorem certifiedIsValid (run : ValidCertifiedRun) : ValidTrace run.trace := by
  exact run.valid

end V23

/- AXIOM_AUDIT_BEGIN -/
#print axioms V23.certifiedIsValid
/- AXIOM_AUDIT_END -/
