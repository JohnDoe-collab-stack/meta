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

Échec volontaire et correct :

- PyTorch installé en build CPU (`2.10.0+cpu`) ;
- CUDA indisponible dans l’environnement Python ;
- ONNX et ONNX Runtime absents ;
- environ 47 Go libres, contre environ 18,7 To exigés par la règle de marge
  1,5× appliquée à l’estimation complète actuelle ;
- aucun digest d’image OCI fourni par `V23_OCI_IMAGE_DIGEST` ;
- `CUBLAS_WORKSPACE_CONFIG` non fixé pour le déterminisme CUDA.
- benchmark matériel et affectation exhaustive des cellules non encore gelés
  dans `configs/smoke_benchmark.json` et `configs/resource_assignments.json`.

Le code refuse donc d’y démarrer une campagne finale. Les tests CPU et les
preuves Lean restent valides ; le résultat scientifique complet nécessite une
machine/environnement satisfaisant le préflight.

## Décision encore humaine

Avant diffusion publique, le détenteur des droits doit choisir et ajouter la
licence du code et des documents, ainsi que les auteurs/identifiants à placer
dans `CITATION.cff`. L’implémentation ne peut attribuer ces droits ou cette
paternité automatiquement.
