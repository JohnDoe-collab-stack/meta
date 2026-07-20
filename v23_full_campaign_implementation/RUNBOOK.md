# Runbook de campagne v23

Toutes les commandes scientifiques passent par `freeze_and_run_v23.py`. Les
commandes directes servent uniquement au développement local.

## 1. Préflight

~~~bash
python3 -m v23.cli preflight --scientific
python3 -m unittest discover -s tests -v
lake build
~~~

Le préflight doit retourner zéro. Ne pas abaisser les seuils pour faire passer
la machine disponible.

Sur chaque classe de machine cible, geler d’abord le benchmark et l’affectation :

~~~bash
python3 benchmark_resources_v23.py --device cuda --out configs/smoke_benchmark.json
python3 assign_resources_v23.py --resources resources.json --benchmark configs/smoke_benchmark.json --out configs/resource_assignments.json
~~~

## 2. Données publiques et OOD scellé

~~~bash
python3 build_data_manifest_v23.py --out manifests/data_manifest.json
python3 freeze_and_run_v23.py \
  --profile sealed-ood \
  --campaign-key-file /support-hors-machine/campaign.key \
  --episodes-per-ood-family 8192 \
  --out-root /volume-immuable/v23
~~~

La clé contient 32 octets aléatoires ou 64 caractères hexadécimaux. Elle ne
doit être ni dans le dépôt, ni dans l’image, ni sur la machine de train après le
scellement.

## 3. Conformance et agent certifiable

~~~bash
python3 freeze_and_run_v23.py --profile finite-conformance --out-root /volume-immuable/v23
python3 freeze_and_run_v23.py --profile certifiable-agent --out-root /volume-immuable/v23
~~~

## 4. Matrices et entraînements

Générer les matrices :

~~~bash
python3 campaign_v23.py matrix --kind tune --out manifests/tuning_matrix.json
python3 campaign_v23.py matrix --kind final --out manifests/final_matrix.json
~~~

Pour chaque cellule, créer un JSON `TrainConfig`. Le wrapper remplace seulement
`output_directory` par le dossier immuable du run et conserve le hash de la
configuration originale.

~~~bash
python3 freeze_and_run_v23.py --profile tune --cell-config cell.json --out-root /volume-immuable/v23
python3 freeze_and_run_v23.py --profile final-train --cell-config cell.json --out-root /volume-immuable/v23
~~~

Les cellules finales exigent `run_kind=final`, seeds 0–9, 120000 updates,
batch 64, CUDA et le manifeste complet. Les réplications exigent
`run_kind=replication` et seeds 10–19.

## 5. Évaluation et causalité

Une configuration `EvaluationConfig` fixe checkpoint, domaine, système, taille,
seed, split, 8192 épisodes et budget. Elle est exécutée sous le profil
`certify` :

~~~bash
python3 freeze_and_run_v23.py --profile certify --cell-config evaluation.json --out-root /volume-immuable/v23
~~~

Une configuration `InterventionRunConfig` fixe les seeds 0–9 et 4096 épisodes
par seed :

~~~bash
python3 freeze_and_run_v23.py --profile interventions --cell-config interventions.json --out-root /volume-immuable/v23
python3 compute_stats_v23.py --paired-jsonl paired_interventions.jsonl --out causality.json
~~~

## 6. Artefacts retenus

~~~bash
python3 certify_quantized_v23.py --checkpoint checkpoint.pt --out-dir quantized
python3 export_onnx_v23.py --checkpoint checkpoint.pt --system B13 --size base --out model.onnx
python3 generate_lean_v23.py --traces learned_traces.jsonl --out-dir lean_generated
python3 falsify_verifiers_v23.py --out-dir falsification
~~~

Compiler chaque bundle Lean avec le noyau gelé et archiver la sortie complète
des `#print axioms`. Exécuter la parité ONNX sur toutes les traces publiées.

## 7. Réplication et verdict

~~~bash
python3 freeze_and_run_v23.py --profile replicate-eval --cell-config evaluation.json --out-root /volume-immuable/v23
python3 freeze_and_run_v23.py --profile replicate-train --cell-config train.json --out-root /volume-immuable/v23
python3 audit_scientific_contract_v23.py --run-root /volume-immuable/v23 --require-all-gates
~~~

Un code non nul, une porte `NOT_RUN`, une divergence, une mutation acceptée ou
une obligation structurelle non nulle interdit la revendication confirmatoire.
