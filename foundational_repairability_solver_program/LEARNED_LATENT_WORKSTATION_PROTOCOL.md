# Protocole latent appris sur une station de travail

## 1. But expérimental exact

La campagne ne cherche pas à « prouver les mathématiques par GPU ». Elle teste quatre questions empiriques qui restent après les théorèmes :

1. un encodeur appris peut-il proposer assez souvent une abstraction que le vérificateur accepte ?
2. l’acquisition active réduit-elle les échecs dus à l’aliasing causal par rapport à des modèles passifs comparables ?
3. la réparation certifiée conserve-t-elle les décisions déjà closes sous interventions ?
4. le coût de requête reste-t-il compétitif face à un oracle symbolique et à des baselines actives ?

La contribution mathématique est le contrat `certificat accepté → décision correcte`. La contribution expérimentale est la couverture, le coût et la généralisation observés sous ce contrat.

## 2. Profil matériel cible

Profil de référence prévu :

- un GPU NVIDIA de classe RTX 4070 avec 12 Go de VRAM ;
- entraînement séquentiel, jamais plusieurs gros modèles simultanés ;
- précision mixte uniquement après un smoke test de stabilité ;
- `num_workers` borné pour préserver la reproductibilité ;
- budget disque de campagne plafonné à 30 Go ;
- checkpoints `best` et `final` seulement pour les runs confirmatoires ;
- données générées procéduralement, seeds et configurations publiées.

Si le matériel réel diffère, le protocole de calibration ci-dessous choisit le nombre de mises à jour sans modifier la matrice, les hypothèses, les seeds ni les ensembles de test.

## 3. Domaines contrôlés

Deux familles indépendantes sont obligatoires.

### D1 — diagnostic actif avec autorisation dynamique

Un monde contient :

- un défaut latent ;
- un mode de fonctionnement ;
- un contexte de sécurité ;
- une table de capteurs partiellement aliasée.

Certaines lectures ne deviennent autorisées qu’après une requête préparatoire. Plusieurs défauts peuvent exiger la même action corrective : l’identification complète n’est pas nécessaire.

Variables de difficulté :

- nombre de mondes ;
- degré d’aliasing ;
- profondeur préparatoire ;
- taux de capteurs non informatifs ;
- coût des requêtes ;
- nombre de classes d’action.

### D2 — contrôle partiellement observable à règles composées

Un monde contient :

- état dynamique discret ;
- règle de transition cachée ;
- contrainte active ;
- objectif local.

Une observation visible identique peut requérir des continuations incompatibles. Une requête ou interaction publique modifie le contexte, puis une réparation met à jour la mémoire et la décision.

Variables de difficulté : profondeur, branchement, composition de règles, nouveaux couples de règles, longueur d’épisode, coût de capteur.

Les deux familles doivent partager l’interface du jeu sans partager leur générateur de contenu.

## 4. Génération des données

Chaque exemple conserve le monde et la fibre exacte pour l’évaluation, mais le modèle ne reçoit que l’historique public.

Un exemple contient :

```text
domain_id, generator_version, seed, world_id,
public_history, authorized_query_mask,
exact_world_mask, required_action,
optimal_solver_verdict, optimal_query, optimal_cost,
prior_closed_obligations, intervention_metadata.
```

Partitions par identifiants de structures, pas par épisodes tirés de la même structure :

- `train` : structures et paramètres de base ;
- `validation` : structures inédites dans la même plage ;
- `iid_test` : nouveaux seeds et structures ;
- `ood_size` : plus de mondes et épisodes plus longs ;
- `ood_composition` : combinaisons de règles absentes du train ;
- `ood_aliasing` : degré d’aliasing supérieur ;
- `ood_authorization` : chaînes préparatoires plus longues ;
- `intervention` : paires contrefactuelles contrôlées.

Les identifiants exacts des partitions sont gelés avant le premier entraînement confirmatoire.

## 5. Systèmes comparés

### O0 — oracle belief exact

Reçoit la fibre exacte et choisit une action lorsque celle-ci est suffisante. Plafond de décision non appris, sans coût actif optimal.

### O1 — solveur actif optimal certifié

Reçoit l’état symbolique exact et utilise `solveOptimal`. Plafond de couverture et plancher de coût dans le jeu déclaré.

### B1 — MLP passif à fenêtre fixe

Encode l’historique aplati, ne peut pas requêter. Contrôle minimal de l’insuffisance visible.

### B2 — GRU passif

Mémoire récurrente, politique d’action et abstention, sans acquisition active.

### B3 — état prédictif récurrent

Encodeur entraîné à prédire un ensemble fixe de tests futurs et l’action. Baseline inspirée des predictive-state representations, adaptée sans prétendre reproduire une méthode particulière.

### B4 — agent actif par gain d’information

Encodeur récurrent, requête choisie par réduction d’entropie estimée, mise à jour neuronale, sans certificat de réparation.

### M1 — réparation active certifiée

Le modèle propose l’état abstrait et les priorités de requête. Le solveur choisit uniquement parmi les requêtes certifiées gagnantes ; la décision est exécutée seulement si le vérificateur accepte.

### A1 — M1 sans mémoire cumulative

Ablation où l’encodeur ne reçoit pas le registre de réparations antérieures.

### A2 — M1 sans contrainte de provenance/non-régression

Ablation expérimentale : les sorties restent vérifiées pour la décision courante mais la vérification de conservation est retirée dans une branche explicitement marquée non certifiée. Elle ne peut produire un certificat complet et sert uniquement à mesurer le rôle du contrat.

Les modèles appris B1–B4, M1, A1 et A2 ont un nombre de paramètres ajusté à ±5 %. O0 et O1 sont rapportés séparément comme oracles, jamais inclus dans un classement de capacité apprise.

## 6. Architecture de M1

### 6.1 Encodeur

- tokens : observations, requêtes, réponses, patchs, obligations ;
- GRU ou petit Transformer causal, choisi lors de la phase pilote puis gelé ;
- dimension cible 256 ;
- deux couches ;
- sortie normalisée uniquement pour l’apprentissage, sans usage dans la preuve.

### 6.2 Têtes

- masque de mondes abstrait ou identifiant d’état canonique ;
- logits de requête ;
- logits d’action ;
- probabilité d’abstention ;
- prédiction de conservativité pour apprentissage auxiliaire, recalculée par le vérificateur.

### 6.3 Couche symbolique

1. reconstruire le paquet candidat ;
2. vérifier la cohérence de l’historique ;
3. vérifier la sur-approximation de la fibre lorsque la fibre concrète est accessible dans le domaine contrôlé ;
4. appeler le solveur sur l’état reconnu ;
5. choisir la requête certifiée du coût minimal, les logits ne départageant que les égalités de coût ;
6. après réponse, construire le patch et vérifier la transition ;
7. exécuter une action uniquement sur une feuille certifiée ;
8. sinon s’abstenir.

Le réseau ne peut pas forcer une action si le solveur ou le vérificateur refuse.

## 7. Objectifs d’apprentissage

Perte de base :

```text
L = λstate Lstate
  + λquery Lquery
  + λaction Laction
  + λfuture Lfuture
  + λabstain Labstain
  + λcal Lcalibration.
```

Valeurs initiales gelées pour le pilote :

```text
λstate=1.0, λquery=1.0, λaction=1.0,
λfuture=0.5, λabstain=0.25, λcal=0.1.
```

Les poids peuvent être ajustés uniquement avec les trois seeds de développement et un espace de recherche publié. Une fois choisis, ils restent identiques pour les dix seeds confirmatoires.

La loss ne constitue pas la certification. Elle sert à augmenter la couverture et à réduire le coût.

## 8. Calibration de faisabilité, sans résultat scientifique

### 8.1 Smoke fonctionnel

- 128 exemples ;
- 20 mises à jour par système ;
- un passage d’évaluation ;
- sorties exclusivement dans `/tmp` ou suffixées `_smoke_` ;
- vérification des gradients, formes, seeds, VRAM et sérialisation.

### 8.2 Benchmark de débit

- 1 000 mises à jour de M1 sur D1 ;
- 1 000 mises à jour de B3 sur D2 ;
- trois répétitions ;
- médiane et minimum du débit ;
- aucune métrique de qualité consultée pour sélectionner le budget.

### 8.3 Règle préengagée de budget

Matrice confirmatoire fixe :

```text
7 systèmes appris × 2 domaines × 10 seeds = 140 entraînements.
```

Choisir le plus grand budget dans :

```text
{5 000, 10 000, 20 000, 30 000} mises à jour
```

tel que l’estimation conservatrice des 140 runs tienne dans 21 jours calendaires à 70 % d’utilisation de la station. L’estimation utilise le plus faible débit observé, multiplié par `1,25` pour l’évaluation et les entrées-sorties.

Si même 5 000 mises à jour ne tiennent pas, le profil `workstation-core` est réduit à B2, B3, B4, M1 et A1, soit 100 entraînements. A2 passe en analyse secondaire. Les domaines, dix seeds et tests ne sont jamais réduits.

Cette règle est appliquée avant toute comparaison de qualité et inscrite dans le manifeste gelé.

## 9. Seeds et séparation développement/confirmation

Seeds de développement : `1001, 1002, 1003`.  
Seeds confirmatoires : `2101, 2203, 2309, 2411, 2521, 2633, 2741, 2851, 2963, 3079`.

Les seeds de développement servent à :

- choisir GRU vs petit Transformer pour M1 ;
- choisir learning rate dans `{1e-4, 3e-4, 1e-3}` ;
- choisir dropout dans `{0.0, 0.1, 0.2}` ;
- vérifier les pertes auxiliaires.

Une seule configuration finale est sélectionnée par moyenne géométrique de : couverture certifiée, erreur d’action pénalisée et coût normalisé sur validation. Aucun test confirmatoire n’est consulté avant gel.

## 10. Évaluation par run

Pour chaque split et seed :

- 4 096 épisodes minimum ;
- génération déterministe depuis le manifeste ;
- batch d’évaluation identique entre systèmes ;
- mêmes mondes et mêmes réponses pour les comparaisons appariées ;
- aucune augmentation de test ;
- timeout déclaré et compté comme échec ou abstention selon l’API préenregistrée.

Mesures primaires :

1. taux d’action incorrecte sur tous les épisodes ;
2. couverture certifiée de M1 ;
3. taux d’action incorrecte conditionnel à acceptation ;
4. regret de coût par rapport à O1 ;
5. taux de fermeture de l’obligation dans le budget de requêtes ;
6. taux de violation des clôtures antérieures.

Mesures secondaires :

- nombre de requêtes ;
- profondeur ;
- calibration de l’abstention ;
- exactitude du masque latent ;
- taille de la sur-approximation ;
- temps et mémoire ;
- couverture par difficulté ;
- taux de rejet par cause.

## 11. Interventions causales

Chaque famille fournit des paires où un seul facteur latent change tandis que l’état visible initial est identique.

Facteurs D1 : défaut, mode, autorisation, fiabilité d’un capteur.  
Facteurs D2 : règle cachée, contrainte, transition, objectif.

Pour chaque facteur, 1 024 paires par seed et par domaine :

- mesurer si la première requête change lorsque le facteur modifie la classe d’action ;
- mesurer si elle reste stable lorsqu’il ne la modifie pas ;
- suivre le gap typé avant/après ;
- vérifier que la réponse discriminante modifie le posterior prévu ;
- vérifier que la réparation conserve les obligations closes.

Le test clé n’est pas seulement la corrélation du latent. C’est la chaîne interventionnelle :

```text
conflit d’action
→ requête autorisée
→ réponse différente
→ posterior vérifié
→ patch accepté
→ décision correcte ou nouvelle requête
```

## 12. Hypothèses préenregistrées

### H1 — sûreté conditionnelle

M1 ne produit aucune action certifiée incorrecte sur l’ensemble confirmatoire. Tout contre-exemple falsifie H1, même si l’accuracy moyenne est élevée.

### H2 — couverture utile

La couverture certifiée médiane de M1 est au moins 80 % en IID et au moins 50 % sur chacun des quatre splits OOD. En dessous, le transfert reste valide mais son utilité empirique est jugée insuffisante.

### H3 — avantage actif

Sur les épisodes initialement aliasés et réparables, M1 a un taux de fermeture supérieur à B2 et B3, avec intervalle de confiance simultané excluant zéro.

### H4 — coût

Le coût pire cas observé de M1 ne dépasse pas 1,25 fois celui de O1 sur les épisodes acceptés en IID, et 1,50 en OOD.

### H5 — non-régression

M1 a zéro violation de clôture antérieure ; A2 doit montrer une dégradation mesurable sur les cas construits pour solliciter cette contrainte. Si A2 ne dégrade pas, l’affirmation empirique sur l’utilité de la provenance est retirée.

### H6 — nécessité de l’activité

B4 et M1 surpassent les modèles passifs sur les paires causalement indécidables sans nouvelle observation. Si les passifs réussissent, le générateur ou la fuite d’information est audité avant toute interprétation.

## 13. Statistiques

- unité principale : seed, non épisode ;
- différences appariées par seed et instance ;
- intervalles bootstrap hiérarchiques à 95 % ;
- correction de Holm pour H3–H6 ;
- taille d’effet avec intervalle, pas seulement p-value ;
- courbes couverture-risque ;
- intervalle binomial exact ou Wilson pour l’erreur conditionnelle ;
- tous les échecs, abstentions et timeouts inclus ;
- pas d’arrêt anticipé sur performance.

H1 est une exigence de falsification stricte, pas un test de non-infériorité. Un zéro observé ne prouve pas un zéro populationnel ; le papier rapporte aussi la borne supérieure de confiance.

## 14. Contrôles anti-fuite

- aucune structure de test dans le train ;
- IDs de monde réindexés aléatoirement par épisode ;
- permutation des labels d’action cohérente pour empêcher la mémorisation de position ;
- padding masqué et longueur non corrélée à la classe ;
- seeds de générateur distinctes de celles des poids ;
- oracle exact inaccessible aux baselines au test ;
- inspection automatique des features ;
- baseline « labels permutés » au hasard ;
- test passif sur paire identique visible devant rester au hasard avant requête.

## 15. Checkpoints, disque et journalisation

Par run confirmatoire :

- configuration JSON ;
- log JSONL compact ;
- checkpoint `best` ;
- checkpoint `final` seulement si différent ;
- métriques agrégées et prédictions compressées ;
- certificat pour chaque erreur, rejet et échantillon stratifié ;
- manifeste de hash.

Limites :

- 100 Mo maximum par checkpoint appris ;
- 150 Mo maximum par run ;
- 30 Go maximum pour la campagne entière ;
- arrêt avant écriture si l’espace libre descend sous 10 Go ;
- aucun checkpoint périodique conservé après validation sauf run explicitement diagnostique.

La suppression éventuelle d’artefacts nécessite une procédure explicite et ne peut toucher les résultats de référence.

## 16. Reproductibilité Python obligatoire

Chaque script scientifique est copié sous un nom timestamp + hash avant exécution. Les sorties reprennent le même suffixe. Le rapport texte contient :

- commande complète ;
- SHA-256 du script ;
- SHA-256 de la configuration ;
- versions Python, PyTorch, CUDA, pilote ;
- GPU, CPU, RAM ;
- seeds ;
- durée ;
- statut de déterminisme ;
- fichiers produits et hashes.

Les scripts historiques ne sont jamais édités après citation. Toute correction crée une nouvelle variante et invalide explicitement les résultats concernés.

## 17. Ordre d’exécution

1. générateurs et oracles exacts ;
2. tests de fuite ;
3. smoke CPU ;
4. smoke CUDA ;
5. benchmark de débit ;
6. trois seeds de développement ;
7. gel du manifeste confirmatoire ;
8. entraînement des 140 cellules ou du profil core déterminé par la règle ;
9. évaluation aveugle de tous les splits ;
10. interventions ;
11. statistiques gelées ;
12. rapport automatique ;
13. réplication d’un sous-ensemble depuis environnement propre.

## 18. Portes expérimentales

### E-L0 — infrastructure

Smoke CPU/CUDA, déterminisme, reprise et limites disque validés.

### E-L1 — validité des domaines

Oracles exacts, paires causalement aliasées et absence de fuite démontrés.

### E-L2 — pilote

Pipeline complet sur trois seeds, sans lecture du confirmatoire.

### E-L3 — gel

Manifeste, code, versions, hypothèses, budgets et hashes publiés avant run.

### E-L4 — confirmation

Toutes les cellules terminées ou échecs rapportés ; aucune cellule supprimée.

### E-L5 — certification

Chaque acceptation de M1 est revérifiée hors du processus d’entraînement ; toute erreur certifiée bloque la revendication.

### E-L6 — réplication

Au moins un domaine, trois seeds et le vérificateur reproduits sur une autre installation.

## 19. Interprétation autorisée

Si H1–H6 et les portes sont satisfaites, la formulation maximale est :

> Sur deux familles finies partiellement observables préenregistrées, un latent appris couplé à un solveur public certifié a produit des décisions vérifiées avec la couverture et le coût rapportés, a résisté aux interventions déclarées et a mieux fermé les ambiguïtés d’action que les baselines passives appariées.

Il reste interdit d’écrire :

- « preuve expérimentale universelle » ;
- « toute représentation latente peut être réparée » ;
- « résolution générale de la partial observability » ;
- « zéro erreur en dehors des certificats acceptés » ;
- « supériorité sur toute méthode de belief state ou predictive state ».
