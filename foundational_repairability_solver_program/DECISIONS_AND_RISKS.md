# Décisions gelées et registre de risques

## 1. Décisions d’architecture gelées

| ID | Décision | Justification | Changement autorisé |
|---|---|---|---|
| D01 | Théorème principal par plus petit point fixe gagnant | couvre autorisation dynamique, requêtes préparatoires et échec positif | version majeure du contrat |
| D02 | Deux certificats positifs `WIN`/`LOSE` | évite une branche négative opaque | jamais supprimé |
| D03 | État public fini explicitement énuméré | rend le solveur total et constructif | extension séparée par abstraction |
| D04 | Réponse déterministe dans le noyau 1 | minimise les hypothèses du premier résultat complet | extension adversariale après M5 |
| D05 | Requête jouable = autorisée + branche réalisable | évite les gains et obstructions vacuaires | jamais supprimé |
| D06 | Cible = non-vacuité + homogénéité d’action + décision + sûreté | distingue information et réalisation | jamais réduite silencieusement |
| D07 | Sur-approximation sûre entre posterior exact et ancienne fibre | conserve le monde réel et permet les abstractions | exactitude portée par un type séparé |
| D08 | Terminaison par cardinal du carrier interne | respecte la constructivité sans rang externe | optimisation interne permise |
| D09 | Vecteurs booléens canoniques, pas quotients | calcul, sérialisation et audit sans `Quot.sound` | représentation équivalente auditée |
| D10 | Coût primaire pire cas en `Nat` | cohérent avec garantie uniforme | coût probabiliste séparé |
| D11 | Coûts strictement positifs pour la première preuve optimale | évite les cycles nuls au jalon initial | extension explicite aux coûts nuls |
| D12 | Le réseau n’est jamais une autorité de preuve | borne nette de confiance | jamais assoupli pour un claim certifié |
| D13 | Abstention exposée comme résultat normal | sépare correction conditionnelle et couverture | seuils empiriques préenregistrés |
| D14 | Deux domaines appris indépendants | réduit le risque de résultat propre à un jouet unique | domaines additionnels permis |
| D15 | Dix seeds confirmatoires | inférence au niveau seed | augmentation permise avant gel seulement |
| D16 | Oracle brut + solveur indépendant + Lean | couvre modèle, extraction et sérialisation | une quatrième implémentation peut s’ajouter |
| D17 | E0 faisable avant E1 ambitieux | donne rapidement une couverture exhaustive réelle | bornes augmentées par version |
| D18 | Comparaisons formelles avec ADS, belief support et diagnostic | empêche une fausse revendication de nouveauté | nouvelles comparaisons permises |
| D19 | Artefact futur totalement autonome | publication et réplication propres | aucune importation métier externe |
| D20 | « game changer » est un objectif, jamais un statut auto-déclaré | protège la crédibilité | seul l’impact extérieur peut l’établir |

## 2. Registre de risques formels

### RF01 — complétude circulaire

- Signal : `CertifiedRepairableAt` est redéfini par le verdict du solveur.
- Prévention : définition indépendante par arbres publics finis.
- Test : preuve `tree_to_winningMember` partant d’un arbre arbitraire.
- Conséquence si non résolu : retirer toute revendication de caractérisation.

### RF02 — séparateur caché

- Signal : une fonction choisissant la bonne requête apparaît dans les hypothèses du théorème central.
- Prévention : recherche exhaustive sur `queryFinite.elements`.
- Test : grep des signatures et contre-modèles sans séparateur.
- Conséquence : résultat équivalent au cadre antérieur, pas saut décisif.

### RF03 — terminaison externalisée

- Signal : champ `rank`, `window`, `fuelCorrect` ou pont terminal dans le jeu.
- Prévention : borne dérivée uniquement de `stateFinite.elements.length`.
- Test : revue de l’API publique.
- Conséquence : porte M3 échouée.

### RF04 — mauvaise inclusion postérieure

- Signal : l’abstraction peut éliminer un monde compatible avec la réponse.
- Prévention : `posteriorContains` universel et test de rétention.
- Test : mutation retirant le monde réel.
- Conséquence : aucune garantie concrète.

### RF05 — fibre vide gagnante

- Signal : homogénéité obtenue par vacuité.
- Prévention : `FiberNonempty` dans `CertifiedTarget`.
- Test : contre-modèle dédié.
- Conséquence : correction WIN invalidée.

### RF06 — requête vacuaire

- Signal : requête autorisée sans réponse réalisable comptée comme gagnante ou utilisée dans LOSE.
- Prévention : type `Playable`.
- Test : contre-modèle dédié.
- Conséquence : point fixe incorrect.

### RF07 — état public insuffisant

- Signal : deux historiques fusionnés ont des autorisations ou invariants futurs différents.
- Prévention : inclure mémoire, contexte et provenance dans `State`.
- Test : requête préparatoire dynamique.
- Conséquence : complétude ou correction relative à une mauvaise abstraction seulement.

### RF08 — non-régression déduite à tort de la fibre

- Signal : aucune condition de frame sur les candidats ou obligations closes.
- Prévention : relation explicite `PriorClosuresRetained`.
- Test : réduction de fibre avec candidat modifié.
- Conséquence : claim de conservation supprimé.

### RF09 — obstruction trop faible

- Signal : sortie `LOSE` contient seulement `¬WIN`.
- Prévention : région fermée et fonction de contre-réponse.
- Test : checker indépendant de fermeture.
- Conséquence : pas de certificat négatif publiable.

### RF10 — coût faussement optimal

- Signal : comparaison seulement aux stratégies extraites par le même algorithme.
- Prévention : borne universelle contre tout arbre public valide et oracle E0d.
- Test : stratégies sous-optimales injectées.
- Conséquence : publier seulement un coût calculé, pas minimal.

## 3. Registre de risques d’implémentation

### RI01 — explosion du sous-ensemble

- Signal : `|State|` rend le solveur inutilisable avant E2.
- Prévention : noyau simple d’abord, DAG, worklist et précurseurs inverses ensuite.
- Repli : limiter la portée aux carriers explicitement énumérés et publier la courbe.

### RI02 — divergence Lean/checker

- Signal : certificats acceptés par un seul vérificateur.
- Prévention : schéma canonique, corpus golden, mutations.
- Repli : geler l’instance, réduire et invalider le run.

### RI03 — preuve correcte, extraction erronée

- Signal : terme Lean correct mais JSON incomplet.
- Prévention : `checkWin`/`checkLose` sur l’objet brut réimporté.
- Repli : aucune sortie non réimportée ne peut être citée.

### RI04 — dépendance classique indirecte

- Signal : `#print axioms` mentionne une dépendance interdite.
- Prévention : audit à chaque module, primitives finies explicites.
- Repli : réécriture constructive, jamais dérogation.

### RI05 — schéma instable

- Signal : les runs ont des formats incompatibles.
- Prévention : version dans chaque objet, migrations uniquement additives en mineur.
- Repli : nouvelle version majeure et maintien du checker ancien.

### RI06 — scripts historiques modifiés

- Signal : hash divergent pour un résultat cité.
- Prévention : copie timestamp+hash avant toute exécution scientifique.
- Repli : invalider le résultat et relancer avec nouveau suffixe.

## 4. Registre de risques expérimentaux

### RE01 — fuite du monde latent

- Signal : baseline passive réussit sur des paires visibles identiques.
- Prévention : réindexation, splits structurels, test de labels permutés.
- Repli : corriger le générateur et invalider tous les runs affectés.

### RE02 — baseline faible

- Signal : écarts de paramètres, tuning ou budget.
- Prévention : ±5 %, même protocole et trois seeds de développement.
- Repli : ajouter une baseline forte avant confirmation, puis regeler.

### RE03 — couverture certifiée faible

- Signal : H2 échoue malgré zéro erreur acceptée.
- Prévention : apprentissage du masque, calibration d’abstention.
- Repli : revendiquer seulement la sûreté conditionnelle, pas l’utilité.

### RE04 — certificat accepté incorrect

- Signal : une action acceptée contredit l’oracle concret.
- Prévention : vérification hors processus et theorem-to-code tests.
- Repli : blocage immédiat de publication jusqu’à résolution complète.

### RE05 — avantage dû au coût supérieur

- Signal : M1 utilise plus de requêtes ou de paramètres.
- Prévention : regret relatif à O1, paramètres appariés, courbes coût-performance.
- Repli : réduire le claim à une courbe de compromis.

### RE06 — OOD choisi après coup

- Signal : splits ajoutés selon les résultats.
- Prévention : hashes avant entraînement confirmatoire.
- Repli : étiqueter toute analyse nouvelle « exploratoire ».

### RE07 — manque de puissance statistique

- Signal : intervalles larges au niveau seed.
- Prévention : dix seeds, mesures appariées, épisodes suffisants.
- Repli : ne pas conclure à l’absence d’effet ; publier l’incertitude.

### RE08 — saturation disque ou temps

- Signal : espace libre sous 10 Go ou projection au-delà de 21 jours.
- Prévention : budget automatique et plafond 150 Mo/run.
- Repli : profil core préengagé, sans réduire seeds ni tests.

## 5. Registre de risques de nouveauté

### RN01 — reformulation d’un jeu standard

- Signal : les champs de réparation n’interviennent dans aucun théorème distinctif.
- Prévention : R7 et théorème de transfert appris avec conservation.
- Repli : présenter honnêtement un artefact de formalisation/intégration, pas une nouvelle fondation.

### RN02 — antériorité ADS/diagnostic

- Signal : le théorème de coût ou séparation correspond exactement à un résultat connu.
- Prévention : revue primaire et embeddings.
- Repli : citer l’antériorité et déplacer l’apport vers C4/C7.

### RN03 — généralisation abusive

- Signal : « toute IA », « tout latent », « espace continu » apparaît sans morphisme prouvé.
- Prévention : audit des claims et non-revendications.
- Repli : limiter le résumé à la classe finie déclarée.

### RN04 — absence de validation extérieure

- Signal : seule l’équipe reproduit le résultat.
- Prévention : artefact autonome, DOI, procédure courte E0.
- Repli : publier comme prépublication en attente de réplication.

## 6. Risques critiques bloquants

Publication bloquée si l’un reste ouvert :

- RF01, RF02, RF03, RF04, RF05, RF06, RF09 ;
- RI02, RI04 ;
- RE04 ;
- RN01 sans reformulation honnête.

Les autres risques peuvent conduire à une réduction de portée explicitement documentée, jamais à une dissimulation.

## 7. Procédure de mise à jour

Chaque incident ajoute : date UTC, version, instance, symptôme, cause, impact, résultats invalidés, correctif, test de régression et nouveau hash. Une décision D01–D20 modifiée exige :

- justification écrite ;
- nouvelle version du programme ;
- réaudit des exigences dépendantes ;
- nouveau gel avant résultats confirmatoires.
