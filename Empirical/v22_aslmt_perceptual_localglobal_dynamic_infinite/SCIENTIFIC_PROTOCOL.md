# Scientific Protocol

## What v22 Tests

V22 is a perceptual world-model learning test with additional proof obligations.

The learner receives rendered tensors, not symbolic `(h, k)` labels as direct features. The task forces a mediated representation: the image channel alone is insufficient, the cue channel alone is insufficient, and a learned `z` channel must carry the missing interface information. The learned model is then checked by independent certificate and verifier scripts.

## What v22 Adds Over v20

V20 already tested hard perceptual learning and a dimension lower bound. V22 keeps that part and adds bridge obligations:

- local/global: the learned mediator must be necessary for closing the paired image/cue obligations;
- dynamic-context: the same learned perceptual kernel must verify over the renderer temporal parameter and IID/OOD context families;
- infinite-schema: the claimed non-finite part is the Lean-aligned `LocalFiniteClosureCover` schema over `ctx : Nat` and `time : Nat`. Each finite prefix is only a reading of that parameterized schema, not a replacement for it, and it depends on the verified finite perceptual kernel plus the `z < n` lower-bound controls.

## What v22 Does Not Claim

V22 does not turn the empirical result into a Lean proof. It does not exhaust an actual infinity by running finite code. It must, however, verify the same local-global shape as the Lean layer: no global enumeration, no finite exhaustive reduction, finite windows per required distinction, and dynamic stable-section elimination by local zero-coordinate windows.

## Required Solid Run

Use CUDA when available:

```bash
cd /mnt/c/Users/frederick/Documents/forU2read
/home/frederick/anaconda3/envs/llama3/bin/python Empirical/aslmt/v22_aslmt_perceptual_localglobal_dynamic_infinite/aslmt_campaign_v22_perceptual_localglobal_dynamic_infinite.py \
  --profile solid \
  --device cuda \
  --n-classes-list 8 \
  --z-classes-list 8 \
  --seed-from 0 \
  --seed-to 0 \
  --steps 9000 \
  --batch-size 64 \
  --pair-n-ctx 64 \
  --rank-n-ctx 64 \
  --episodes 64 \
  --train-ood-ratio 0.5 \
  --rank-ood-ratio 0.5
```

The campaign automatically expands `--z-classes-list 8` into the full dimension scan `z = 1..8`.

## Smoke Run

Smoke runs are only mechanical checks and do not validate the scientific claim:

```bash
cd /mnt/c/Users/frederick/Documents/forU2read
/home/frederick/anaconda3/envs/llama3/bin/python Empirical/aslmt/v22_aslmt_perceptual_localglobal_dynamic_infinite/aslmt_campaign_v22_perceptual_localglobal_dynamic_infinite.py \
  --profile smoke \
  --device cuda \
  --n-classes-list 4 \
  --z-classes-list 4 \
  --seed-from 0 \
  --seed-to 0 \
  --steps 20 \
  --batch-size 8 \
  --pair-n-ctx 4 \
  --rank-n-ctx 4 \
  --episodes 2
```
