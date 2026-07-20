# Installation de v23 pour les smoke-tests CPU et CUDA

Ce guide installe et vérifie l’implémentation v23 sur Linux ou WSL2. Le profil
décrit ici est destiné au développement local et aux smoke-tests. Il ne réduit
aucune exigence de la campagne scientifique confirmatoire.

## 1. Configuration validée

La procédure a été exécutée avec succès sur la configuration suivante :

- WSL2, Linux x86-64 ;
- Python 3.10.12 ;
- NVIDIA GeForce RTX 4070, 12 Gio ;
- pilote NVIDIA compatible CUDA 13.1 ;
- environnement isolé `torch 2.5.1+cu121` ;
- CUDA Runtime 12.1 et cuDNN 9.1 fournis par les wheels PyTorch ;
- Lean géré par `elan` et le fichier `lean-toolchain` du projet.

PyTorch publie officiellement le couple `torch 2.5.1` / CUDA 12.1 dans son
archive des versions :
<https://pytorch.org/get-started/previous-versions/>.

Le toolkit CUDA local et `nvcc` ne sont pas requis pour ces smoke-tests : les
wheels PyTorch embarquent leurs bibliothèques d’exécution. Le pilote NVIDIA
doit néanmoins exposer correctement le GPU à Linux ou WSL2.

## 2. Prérequis

Vérifier la présence de Python, du module `venv`, du pilote NVIDIA et de Lean :

~~~bash
python3 --version
python3 -m venv --help
nvidia-smi
lake --version
~~~

Versions Python acceptées par le préflight v23 : Python 3.10, 3.11 ou 3.12.

Prévoir au minimum :

- environ 5 Gio pour `.venv-smoke-cuda` ;
- plusieurs Gio temporaires pour le cache et l’extraction des wheels ;
- un nouveau répertoire sous `/tmp` pour chaque smoke-test.

Si `python3 -m venv` échoue sur Debian ou Ubuntu, installer le paquet
`python3-venv` avec le gestionnaire système avant de continuer.

## 3. Se placer dans le projet

~~~bash
cd /path/to/meta/v23_full_campaign_implementation
~~~

Tous les chemins des sections suivantes supposent que cette commande a été
exécutée.

## 4. Créer l’environnement CUDA isolé

Lancer :

~~~bash
./setup_smoke_cuda_v23.sh
~~~

Le script :

1. crée `.venv-smoke-cuda/` sans modifier le Python utilisateur ;
2. installe les versions déclarées dans `requirements-smoke-cuda.txt` ;
3. installe le projet en mode éditable sans dupliquer ses sources ;
4. vérifie que PyTorch voit effectivement le GPU.

La dernière ligne attendue ressemble à :

~~~text
2.5.1+cu121 12.1 NVIDIA GeForce RTX 4070
~~~

Le répertoire du venv et les métadonnées `*.egg-info` sont ignorés par Git.

### Installation WSL plus rapide

L’extraction d’un venv sous `/mnt/c` peut être lente. Pour conserver le venv
sur le système de fichiers Linux, choisir explicitement un autre emplacement :

~~~bash
V23_SMOKE_VENV=/home/$(id -un)/.venvs/v23-smoke-cuda \
  TMPDIR=/tmp \
  ./setup_smoke_cuda_v23.sh
~~~

Dans ce cas, remplacer `.venv-smoke-cuda/bin/python` par le chemin choisi dans
`V23_SMOKE_VENV`, suivi de `/bin/python`, dans les commandes suivantes.

## 5. Vérifier l’environnement

Vérifier les dépendances :

~~~bash
.venv-smoke-cuda/bin/python -m pip check
~~~

Vérifier CUDA depuis le bon interpréteur :

~~~bash
.venv-smoke-cuda/bin/python -c '
import torch
print("torch:", torch.__version__)
print("CUDA compilé:", torch.version.cuda)
print("CUDA disponible:", torch.cuda.is_available())
print("GPU:", torch.cuda.get_device_name(0))
print("VRAM:", torch.cuda.get_device_properties(0).total_memory)
'
~~~

Le résultat doit notamment contenir :

~~~text
CUDA disponible: True
GPU: NVIDIA GeForce RTX 4070
~~~

## 6. Exécuter les tests de base

Lancer les tests Python sans écrire de cache scientifique :

~~~bash
PYTHONDONTWRITEBYTECODE=1 \
  .venv-smoke-cuda/bin/python -m pytest -q -s -p no:cacheprovider
~~~

Le statut validé est de 31 tests réussis.

Compiler ensuite le noyau Lean :

~~~bash
lake build
~~~

La sortie doit confirmer que `V23.certifiedIsValid` ne dépend d’aucun axiome.

## 7. Exécuter le smoke logique v23

Toujours choisir un dossier de sortie neuf :

~~~bash
.venv-smoke-cuda/bin/python -m v23.cli smoke \
  --out-dir /tmp/v23_logic_smoke_001
~~~

Le rapport final doit contenir :

~~~json
"scientific_result": false,
"ok": true
~~~

Ce test vérifie notamment les trois domaines, les traces, la fermeture exacte,
le scellement OOD local, les statistiques et les audits structurels.

## 8. Exécuter le smoke CUDA complet

La variable `CUBLAS_WORKSPACE_CONFIG` est obligatoire pour le déterminisme :

~~~bash
CUBLAS_WORKSPACE_CONFIG=:4096:8 \
  .venv-smoke-cuda/bin/python smoke_cuda_v23_v2.py \
  --out-dir /tmp/v23_cuda_smoke_001 \
  --iterations 2
~~~

Le succès est annoncé par :

~~~text
CUDA_SMOKE_OK=True
~~~

Le fichier `/tmp/v23_cuda_smoke_001/cuda_smoke_report.json` contient :

- les versions Python, PyTorch, CUDA et cuDNN ;
- le nom, la capacité de calcul et la mémoire du GPU ;
- le hash SHA-256 du script et de l’adaptateur de sampling ;
- les six benchmarks `symbolic/perceptual × small/base/large` ;
- une mise à jour supervisée CUDA ;
- deux exécutions causales de même seed ;
- le verdict de reproductibilité bit-à-bit des deux `state_dict`.

### Pourquoi utiliser la variante v2 ?

Le noyau CUDA utilisé par `Categorical.sample` n’implémente pas le mode
déterministe exigé par v23 dans le build validé. La variante v2 conserve sur
CUDA les logits, l’inférence, la perte et les gradients. Seul le tirage discret
non différentiable est effectué avec le noyau CPU déterministe, puis retransmis
au GPU.

Cet adaptateur refuse explicitement tout `run_kind` différent de `smoke`. Il ne
peut donc pas être utilisé silencieusement pour une expérience confirmatoire.

## 9. Vérifier un gradient causal non nul

Le petit smoke de reproductibilité peut légitimement obtenir une récompense
uniforme et une perte REINFORCE nulle. Le contrôle suivant utilise un batch de
64 épisodes afin de vérifier une vraie rétropropagation causale :

~~~bash
CUBLAS_WORKSPACE_CONFIG=:4096:8 \
  .venv-smoke-cuda/bin/python smoke_cuda_causal_gradient_v3.py \
  --out /tmp/v23_cuda_causal_gradient_smoke_001.json \
  --batch-size 64 \
  --training-seed 25
~~~

Le succès est annoncé par :

~~~text
CUDA_CAUSAL_GRADIENT_SMOKE_OK=True
~~~

La configuration validée a produit une perte non nulle, 57 tenseurs de
gradient et 124 369 éléments de gradient non nuls. Ces nombres sont un contrôle
d’exécution local, pas un résultat scientifique.

## 10. Préflight smoke et préflight scientifique

Préflight de développement :

~~~bash
.venv-smoke-cuda/bin/python -m v23.cli preflight
~~~

Il doit retourner un code zéro et `"ok": true` lorsque les dépendances de base
et le verrou de protocole sont valides.

Préflight scientifique :

~~~bash
CUBLAS_WORKSPACE_CONFIG=:4096:8 \
  .venv-smoke-cuda/bin/python -m v23.cli preflight --scientific
~~~

Sur la RTX 4070 de 12 Gio, ce second préflight doit rester en échec. La campagne
confirmatoire exige notamment :

- au moins 20 Gio de VRAM ;
- environ 18,7 To de stockage libre selon la matrice exhaustive actuelle ;
- ONNX et ONNX Runtime ;
- un digest d’image OCI ;
- un benchmark matériel figé ;
- une affectation complète des ressources.

Ne pas modifier ou abaisser ces seuils pour faire passer la machine locale.

## 11. Dépannage

### `nvidia-smi: command not found`

Le pilote NVIDIA n’est pas exposé à Linux ou WSL2. Corriger d’abord
l’installation du pilote côté hôte et l’intégration WSL.

### `torch.cuda.is_available()` retourne `False`

Vérifier l’interpréteur utilisé :

~~~bash
.venv-smoke-cuda/bin/python -c 'import sys, torch; print(sys.executable); print(torch.__version__)'
~~~

Une version terminant par `+cpu` indique que la commande utilise encore le
Python utilisateur au lieu du venv CUDA.

### `deterministic CUDA smoke requires CUBLAS_WORKSPACE_CONFIG`

Relancer la commande en la préfixant exactement par :

~~~bash
export CUBLAS_WORKSPACE_CONFIG=:4096:8
~~~

La variable doit exister avant le démarrage de Python.

### `FileExistsError`

Les sorties sont volontairement créées en mode exclusif. Utiliser un nouveau
nom, par exemple `/tmp/v23_cuda_smoke_002`. Ne jamais écraser un smoke antérieur
cité ou audité.

### Mémoire GPU insuffisante

Fermer les autres applications GPU et vérifier l’utilisation avec
`nvidia-smi`. Les smokes validés utilisent un batch de benchmark égal à 1 et
restent très en dessous des 12 Gio de la RTX 4070.

### Installation très lente sous `/mnt/c`

Utiliser la variante de la section « Installation WSL plus rapide » avec un
venv sous `/home` et `TMPDIR=/tmp`.

## 12. Critère final de réussite

L’installation smoke est considérée comme prête seulement si toutes les
conditions suivantes sont vraies :

- `pip check` ne signale aucune dépendance cassée ;
- les 31 tests Python passent ;
- `lake build` passe sans axiome ;
- le smoke logique retourne `"ok": true` ;
- le smoke CUDA retourne `CUDA_SMOKE_OK=True` ;
- le replay causal est bit-à-bit identique ;
- le smoke de gradient retourne `CUDA_CAUSAL_GRADIENT_SMOKE_OK=True` ;
- les sorties sont sous `/tmp` et marquées `"scientific_result": false`.

Cette procédure établit l’exécutabilité locale CPU/CUDA. Elle ne constitue ni
une exécution de G0–G8, ni une validation empirique confirmatoire.
