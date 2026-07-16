# ASLMT v22 Perceptual Local-Global Dynamic Infinite

V22 is a new experiment folder. It is not a modification of v20 or v21.

Strict claim:

- v22 keeps the v20 perceptual learning task: raw rendered cue/image inputs, learned mediator `z`, nontrivial target reconstruction, IID/OOD checks, and `z < n` negative controls.
- v22 adds bridge certificates: the local/global, dynamic-context, and infinite-schema claims are accepted only after the perceptual proofpack passes and after the Lean-aligned `LocalFiniteClosureCover` schema has been verified.
- v22 does not claim a Lean theorem and does not claim exhaustive empirical infinity.

Success condition:

- structural verifier passes for `z = n` on IID and OOD;
- marginal-only controls pass as no-go checks;
- minproof/dimension controls prove `z < n` is structurally insufficient;
- learned metrics pass the hard gates: `z_acc = q_acc = res_acc = 1.0`, perceptual `A_iou >= 0.80`, trivial baselines at `0.0`;
- local/global bridge rejects image-only, cue-only, ablated, and swapped-original shortcuts;
- dynamic/infinite bridge files preserve their explicit local-window scope and verify the parameterized `ctx : Nat`, `time : Nat` local-global schema;
- falsification mutations are rejected.

This is intentionally stricter than v21: a fast abstract certificate is not enough.
