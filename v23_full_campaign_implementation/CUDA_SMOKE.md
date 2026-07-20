# Smoke-tests CUDA v23

Ce profil est strictement non scientifique. Il vérifie que la machine peut
exécuter l’inférence, la rétropropagation et les deux branches d’entraînement
v23 sur GPU. Il ne modifie pas le seuil confirmatoire de 20 Gio et ne produit
aucun résultat publiable.

## Installation isolée

~~~bash
./setup_smoke_cuda_v23.sh
~~~

L’environnement est créé dans `.venv-smoke-cuda/`, ignoré par Git. Les versions
sont séparées de l’installation Python utilisateur. Le profil utilise le build
officiel `torch 2.5.1+cu121`, compris dans la plage verrouillée du projet
(`torch >=2.4,<3`) et compatible avec la RTX 4070.

## Exécution

Chaque smoke doit écrire dans un nouveau dossier sous `/tmp` :

~~~bash
CUBLAS_WORKSPACE_CONFIG=:4096:8 \
  .venv-smoke-cuda/bin/python smoke_cuda_v23_v2.py \
  --out-dir /tmp/v23_cuda_smoke_001 \
  --iterations 2
~~~

Le succès exige `CUDA_SMOKE_OK=True`. Le rapport
`cuda_smoke_report.json` enregistre le hash du script, la commande, les versions,
le GPU, le pic mémoire, les benchmarks, la mise à jour supervisée et les deux
exécutions causales de contrôle.

Le contrôle ciblé suivant exige en plus une perte causale et des gradients non
nuls sur un batch de 64 épisodes :

~~~bash
CUBLAS_WORKSPACE_CONFIG=:4096:8 \
  .venv-smoke-cuda/bin/python smoke_cuda_causal_gradient_v3.py \
  --out /tmp/v23_cuda_causal_gradient_smoke_001.json
~~~

La variante v2 conserve les logits, l’inférence et les gradients sur CUDA. Le
tirage catégoriel non différentiable de la branche causale passe par le noyau
CPU déterministe, car `Categorical.sample` n’a pas de noyau CUDA déterministe
dans le build utilisé. Un second run causal de même seed doit produire des
métriques et un `state_dict` bit-à-bit identiques.

Le préflight scientifique reste volontairement distinct : la RTX 4070 de
12 Gio peut passer ce smoke mais ne satisfait pas l’exigence confirmatoire de
20 Gio.
