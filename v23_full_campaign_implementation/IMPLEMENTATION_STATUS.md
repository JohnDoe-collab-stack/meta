# État vérifié de l’implémentation

Date d’audit : 2026-07-20.

## Livré et exécuté en smoke

- projet autonome, sans import depuis les scripts v23 historiques ;
- sérialisation canonique, identifiants de contenu, seeds séparées et écritures
  exclusives ;
- familles fermées de 32 mondes dans trois domaines : référence finie, SSA
  symbolique et scènes compositionnelles rasterisées en entier ;
- politique active exacte, posterior exact, provenance, mémoire cumulative et
  transition dérivée de la réparation ;
- modèle latent appris small/base/large, CNN, Transformer pré-norm, décisions
  gap/use/transport/query/repair typées et absence de `NextHead` dans B13 ;
- registre et chemins d’information distincts B1–B13 ;
- entraînement supervisé, intermédiaire et causal avec estimateur discret
  leave-one-out ;
- évaluation IID/OOD et cinq familles OOD structurellement disjointes ;
- 18 interventions appariées avec recalcul des descendants ;
- scellement AES-256-GCM, nonces uniques et racine de Merkle ;
- statistiques appariées, bootstrap hiérarchique, 1024 inversions de signe et
  correction de Holm ;
- quantification Int8/Int32, export ONNX optionnel, audit des flux et des
  ressources ;
- génération Lean par blocs de 256 et noyau constructif ;
- mutation/falsification de 17 champs et portes G0–G8 fail-closed ;
- wrapper scientifique produisant une copie timestamp+SHA, un transcript et
  `completion.marker` en dernier.

Vérifications locales obtenues :

- 29 tests Python : succès ;
- `lake build` : succès ;
- audits Lean : aucune dépendance à un axiome ;
- module de trace Lean généré : compilation et audit sans axiome ;
- conformance : 96/96 traces fermées et structurellement valides ;
- smoke entraînement → checkpoint → évaluation : exécutable ;
- smoke des 18 interventions : 18/18 paires, refus `I_next_bypass` présent ;
- agent certifiable : 697/697 décisions Int8/Int32, zéro erreur, marges
  strictes et replay indépendant identique ;
- wrapper figé : exécution achevée, hashes et marqueur final présents.
- environnement smoke isolé : `torch 2.5.1+cu121`, CUDA 12.1 et cuDNN 9.1 ;
- RTX 4070 détectée par PyTorch, calcul tensoriel CUDA et six couples de
  benchmark domaine/taille exécutés ;
- entraînement CUDA supervisé exécuté, branche causale exécutée avec tirage
  discret déterministe sur CPU et gradients/logits sur CUDA ;
- replay causal de même seed : métriques et `state_dict` bit-à-bit identiques ;
- smoke causal batch 64 : perte non nulle, 57 tenseurs et 124 369 éléments de
  gradient non nuls.

Ces smokes démontrent l’exécutabilité du logiciel. Ils ne sont pas les résultats
confirmatoires de la campagne.

## Non exécuté — donc non revendiqué

- engagements complets des partitions 4096/8192 ;
- 8 424 cellules de réglage ;
- 2 340 entraînements finaux avant évaluations ;
- 10 seeds × 4096 épisodes × 18 interventions par domaine ;
- toutes les évaluations IID et OOD à 8192 épisodes ;
- réplication d’évaluation et réentraînement seeds 10–19 ;
- export/parité ONNX de chaque checkpoint retenu ;
- certification Lean de toutes les traces finales ;
- validation externe et humaine indépendante ;
- passage effectif de G0–G8.

L’auditeur retourne donc actuellement `NOT_RUN` pour les portes sans preuves. Il
est interdit de présenter le dossier comme une validation empirique ou une
percée avant ces exécutions.

## Préflight scientifique de cette machine

Le profil smoke CUDA fonctionne. Le préflight scientifique reste en échec
volontaire et correct :

- l’installation Python utilisateur reste en build CPU (`2.10.0+cpu`), tandis
  que `.venv-smoke-cuda` fournit `torch 2.5.1+cu121` avec CUDA disponible ;
- la RTX 4070 expose 12 Gio, sous le minimum confirmatoire de 20 Gio ;
- ONNX et ONNX Runtime absents ;
- environ 40 Go libres, contre environ 18,7 To exigés par la règle de marge
  1,5× appliquée à l’estimation complète actuelle ;
- aucun digest d’image OCI fourni par `V23_OCI_IMAGE_DIGEST` ;
- `CUBLAS_WORKSPACE_CONFIG` non fixé pour le déterminisme CUDA.
- benchmark matériel et affectation exhaustive des cellules non encore gelés
  dans `configs/smoke_benchmark.json` et `configs/resource_assignments.json`.

Le code refuse donc d’y démarrer une campagne finale. Le profil v2 de tirage
déterministe est explicitement limité aux runs `smoke` : son adoption dans une
campagne confirmatoire demanderait une nouvelle variante figée et un audit du
protocole. Les tests CPU/CUDA et les preuves Lean restent valides ; le résultat
scientifique complet nécessite une machine et un environnement satisfaisant le
préflight.

## Décision encore humaine

Avant diffusion publique, le détenteur des droits doit choisir et ajouter la
licence du code et des documents, ainsi que les auteurs/identifiants à placer
dans `CITATION.cff`. L’implémentation ne peut attribuer ces droits ou cette
paternité automatiquement.
