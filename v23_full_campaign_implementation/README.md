# v23 — fermeture sémantique active certifiée

Ce dossier est une implémentation autonome de la campagne dont le document
d’autorité est verrouillé par SHA-256 dans `protocol.lock.json` et dont les
invariants exécutables sont reproduits dans `PROTOCOL_CONTRACT.md`. Il ne
modifie ni ne dépend des scripts expérimentaux historiques du dépôt. Son
objectif est de rendre exécutables, dans une même architecture auditable :

- les familles fermées de 32 mondes et leur ambiguïté pertinente pour l’action ;
- les domaines perceptuel compositionnel et symbolique SSA ;
- un agent à décisions discrètes typées et les systèmes B1–B13 ;
- les interventions causales appariées, la dynamique et la persistance ;
- le scellement OOD, les traces complètes et les statistiques confirmatoires ;
- les portes G0–G8, sans transformer l’absence d’un run en succès.

## Statut exact

Le code, les contrats, les générateurs, les modèles, les audits et les profils
d’exécution sont implémentés ici. Une campagne finale n’est scientifiquement
validée qu’après exécution de tous les runs préenregistrés, ouverture contrôlée
de l’OOD, réplication indépendante et certification. Les rapports générés
conservent donc trois états distincts : `PASS`, `FAIL` et `NOT_RUN`.

## Démarrage

~~~bash
cd v23_full_campaign_implementation
python3 -m v23.cli preflight
python3 -m v23.cli smoke --out-dir /tmp/v23_smoke
python3 -m unittest discover -s tests -v
lake build
~~~

Pour une exécution scientifique, ne lancez jamais directement le script de
travail. Le wrapper crée une copie figée portant le timestamp UTC et le SHA-256,
puis inscrit la commande et le hash dans le manifeste :

~~~bash
python3 freeze_and_run_v23.py --profile finite-conformance --out-root /volume-immuable/v23
~~~

Le préflight scientifique exige explicitement CUDA, ONNX Runtime, le verrou de
protocole et les ressources minimales. Chaque run scientifique exige en plus
ses manifestes et entrées scellées. Le lanceur s’arrête avant le calcul si une
précondition manque.

## Structure

- `v23/` : implémentation de référence ;
- `tests/` : tests unitaires et tests anti-contournement ;
- `configs/` : profils immuables de campagne ;
- `schemas/` : schémas JSON des traces et manifestes ;
- `campaign_v23.py` : entrée de campagne ;
- `freeze_and_run_v23.py` : exécution scientifique figée ;
- `verify_v23.py` : audit indépendant d’un répertoire de résultats.

Voir `RUNBOOK.md` pour la séquence complète et `IMPLEMENTATION_STATUS.md` pour
la frontière exacte entre logiciel vérifié, smokes exécutés et campagne encore
non lancée.

## Garanties de conception

Les nombres flottants sont interdits dans les objets canoniques destinés au
hashage. Les identifiants sont dérivés du contenu. Les seeds de sous-systèmes
sont dérivées par domaine séparé. Les fichiers scientifiques sont créés en mode
exclusif. Les traces contiennent observation, décisions, masques, provenance,
postérieur, réparation, transition, mémoire et verdict. Un audit rejette une
trace qui omet un maillon causal ou utilise une information interdite.

Ce dossier n’affirme aucun résultat empirique avant que les sorties correspondantes
n’existent et passent leur vérificateur indépendant.
