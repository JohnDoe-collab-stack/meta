# Nouveauté, comparaisons et portes de publication

## 1. Principe

Une contribution peut être mathématiquement correcte sans être nouvelle, et nouvelle sans être suffisamment générale pour être majeure. Le programme sépare donc :

- validité formelle ;
- nouveauté relative à la littérature ;
- portée de la classe traitée ;
- valeur expérimentale ;
- importance historique, qui ne peut être auto-attribuée.

Le but ambitieux est légitime. La formulation publique reste proportionnée aux preuves disponibles.

## 2. Domaines voisins à traiter explicitement

### 2.1 Adaptive distinguishing sequences

Les séquences adaptatives distinguantes construisent des arbres de tests pour identifier un état d’une machine finie ; existence, cas incomplets et optimisation de coût ont une littérature établie.

Conséquence : ni « arbre adaptatif », ni « requête qui sépare des mondes », ni « coût minimal de test » ne peuvent être revendiqués seuls comme nouveaux.

Comparaison obligatoire :

- traduire une machine finie dans le jeu de réparation ;
- montrer que la cible singleton récupère le problème d’identification ;
- montrer un exemple où la cible par classe d’action termine plus tôt ;
- identifier ce qu’ajoutent patch, provenance, langage de décision et non-régression.

Références de départ :

- Hierons et Türker, adaptive distinguishing sequences for finite-state machines, [The Computer Journal](https://academic.oup.com/comjnl/article/58/11/3089/449735) ;
- travaux sur les ADS de coût optimal, [Information and Software Technology](https://www.sciencedirect.com/science/article/abs/pii/S0950584916300192).

### 2.2 Diagnostic actif et diagnosabilité

Le diagnostic actif choisit des actions ou observations pour distinguer des fautes ; la planification pour la diagnosabilité et la synthèse d’exigences d’observabilité sont proches.

Comparaison obligatoire :

- diagnostic = classe d’action corrective ;
- requête = action de test ;
- contre-stratégie = observation conservant l’ambiguïté ;
- distinction entre diagnostiquer une faute et fermer une obligation de continuation ;
- rôle formel des réparations et de leur conservation.

Références :

- active diagnosis, [Journal of Computer and System Sciences](https://www.sciencedirect.com/science/article/pii/S0022000016300198) ;
- planning for diagnosability, [AAAI proceedings](https://ojs.aaai.org/index.php/AAAI/article/download/10694/10553) ;
- symbolic synthesis of observability requirements, [AAAI proceedings](https://ojs.aaai.org/index.php/AAAI/article/view/8225).

### 2.3 Belief states, POMDP et synthèse de contrôleurs

Une fibre exacte est un belief support. Les jeux partiellement observables et la synthèse de contrôleurs finis couvrent déjà de nombreux objectifs d’atteignabilité.

Conséquence : le point fixe gagnant est une base algorithmique standard. La nouveauté visée doit résider dans la caractérisation certifiée de la réparation, le langage de mise à jour, les obligations de décision, la provenance/non-régression et le transfert appris vérifié.

Comparaison obligatoire :

- embedding du belief support exact ;
- différence entre état public complet et simple support ;
- comparaison avec synthèse de contrôleur fini ;
- limites de l’explosion en sous-ensembles ;
- cas où l’abstraction sur-approximative reste sûre mais perd de la complétude.

Références :

- controller synthesis under partial observability, [ICAPS proceedings](https://ojs.aaai.org/index.php/ICAPS/article/view/13555) ;
- sensor synthesis for POMDPs, [ICAPS proceedings](https://ojs.aaai.org/index.php/ICAPS/article/view/13875) ;
- CEGAR pour MDP, [arXiv:0807.1173](https://arxiv.org/abs/0807.1173) ;
- CEGAR pour POMDP, [arXiv:1701.06209](https://arxiv.org/abs/1701.06209).

### 2.4 Predictive-state representations et latents appris

Les predictive-state representations représentent l’état par des prédictions de tests futurs ; des variantes apprises et neuronales existent.

Comparaison obligatoire :

- PSR comme représentation prédictive, pas comme réparation preuve-pertinente par défaut ;
- mesure de l’information utile pour l’action vs prédiction de tests ;
- baseline PSR sérieuse dans les expériences ;
- contrat de transfert : le latent peut être quelconque, seule l’abstraction certifiée est crue ;
- ne pas prétendre que la mémoire ou les états prédictifs sont nouveaux.

Références :

- Littman, Sutton et Singh, PSR, [NeurIPS 2001](https://papers.nips.cc/paper_files/paper/2001/hash/1e4d36177d71bbb3558e43af9577d70e-Abstract.html) ;
- apprentissage de PSR, [ICML 2003](https://wap.aaai.org/Library/ICML/2003/icml03-093.php) ;
- Predictive-State Decoders, [NeurIPS 2017](https://papers.nips.cc/paper_files/paper/2017/hash/61b4a64be663682e8cb037d9719ad8cd-Abstract.html) ;
- PSRNN, [NeurIPS 2017](https://papers.nips.cc/paper_files/paper/2017/hash/2bb0502c80b7432eee4c5847a5fd077b-Abstract.html) ;
- représentations d’états causaux apprises sous observabilité partielle, [arXiv:1906.10437](https://arxiv.org/abs/1906.10437).

Cette liste est une base minimale, pas une revue finale. Une recherche bibliographique datée doit être relancée avant toute soumission.

## 3. Décomposition de la contribution visée

La revendication forte ne doit jamais être « nous avons inventé les jeux d’atteignabilité ». Elle doit être décomposée en apports vérifiables :

### C1 — objet unifié

Un jeu public où l’état porte simultanément : fibre, contexte d’autorisation, mémoire, provenance, patch et obligations closes.

### C2 — caractérisation constructive totale

Une fonction axiom-free retourne soit une stratégie publique de réparation, soit une obstruction fermée, avec correction et complétude vis-à-vis de tous les arbres publics finis.

### C3 — décision plutôt qu’identification

La cible est l’homogénéité relative à la continuation exigée et sa réalisation dans un langage de décision. Un théorème et une famille d’exemples quantifient l’économie par rapport à l’identification du monde.

### C4 — sécurité de la réparation

Chaque transition enregistre réponse, patch et provenance, conserve le monde réel, l’identité stricte, la cohérence des transports et les clôtures antérieures déclarées.

### C5 — certificat négatif exploitable

Le système explique l’impossibilité relative au capteur et au langage actuels par une région fermée et des contre-réponses, plutôt que par un échec opaque.

### C6 — optimalité sûre

Le coût minimal est calculé parmi les stratégies qui satisfont déjà C4, non parmi toutes les politiques informationnelles.

### C7 — transfert learned-to-formal

Un latent appris peut proposer une abstraction, mais le théorème ne dépend que d’un paquet accepté par un vérificateur indépendant. La couverture empirique est séparée de la correction conditionnelle.

### C8 — comparaison formelle

Des traductions prouvées situent ADS, belief supports et diagnostic actif comme cas ou projections, et isolent les champs additionnels nécessaires à C4 et C7.

La combinaison C1–C8 est la candidate à une contribution distinctive. Chacun pris isolément a des antécédents probables.

## 4. Théorèmes de comparaison requis

### R1 — récupération des ADS

```text
ADSInstance M
→ RepairGame M avec required(w)=w
→ ADS gagnante ↔ réparation certifiée gagnante.
```

### R2 — quotient par classe d’action sans quotient Lean

Construire directement la fonction `required`. Montrer :

```text
identification gagnante → action-réparation gagnante,
```

et fournir une famille infinie finie-paramétrée où la réciproque échoue et où le coût d’action reste borné tandis que le coût d’identification croît.

Éviter les types quotient afin de respecter l’audit constructif.

### R3 — belief support exact

```text
ExactPosteriorGame POMDP-support
→ état canonique = support postérieur
→ solveur = stratégie d’atteignabilité sûre sur supports.
```

### R4 — simulation sûre d’une abstraction

Si chaque état concret compatible est représenté dans l’abstraction et chaque transition concrète est couverte, alors tout certificat gagnant abstrait se transfère au concret.

### R5 — perte de complétude par sur-approximation

Un contre-modèle montre qu’une abstraction saine mais grossière peut être déclarée perdante alors que le jeu concret est gagnant. La correction est préservée, pas la complétude.

### R6 — complétude relative

Sous exactitude ou bisimulation publique suffisante, la gagnabilité abstraite et concrète coïncident.

### R7 — ajout propre de la réparation

Définir une projection qui oublie patch, provenance et clôtures. Prouver que toute stratégie certifiée se projette en stratégie informationnelle, puis donner des stratégies informationnelles rejetées parce qu’elles violent les invariants. Ne pas appeler cela « irréductibilité absolue ».

## 5. Résultat additionnel réellement discriminant

Le point fixe seul risque d’être évalué comme une reformulation de synthèse de jeu fini. Le programme doit donc livrer au moins un résultat qui ne disparaît pas sous cette réduction.

Cible prioritaire :

> Théorème de transfert certifié avec abstention : pour toute représentation apprise et toute histoire concrète, l’acceptation du paquet par le vérificateur implique la correction de la continuation dans tous les mondes concrets cohérents, la conservation des obligations closes et la validité de chaque acquisition publique ; le rejet ne produit aucune action certifiée.

Renforcement souhaité :

> Complétude relative et coût : si la représentation apprise propose une abstraction exacte ou une simulation complète appartenant au domaine gagnant, le vérificateur accepte une stratégie de coût minimal parmi les réparations publiques sûres de l’abstraction.

Ce théorème doit être modèle-agnostique : aucune hypothèse de réseau, loss ou architecture dans Lean.

## 6. Tests de nouveauté avant rédaction

Pour chaque claim C1–C8 :

1. formulation en une phrase quantifiée ;
2. recherche exacte des mots-clés et synonymes ;
3. lecture d’au moins les sources primaires les plus proches ;
4. tableau « même objet / mêmes hypothèses / même conclusion / exécutable / formalisé » ;
5. identification de l’écart minimal ;
6. retrait ou réduction du claim si l’écart disparaît ;
7. validation par au moins un chercheur extérieur au projet.

Le journal bibliographique stocke date, requête, bases interrogées, articles lus et décision sur le claim.

## 7. Portes mathématiques

### M0 — spécification

- classe finie exacte ;
- cibles et invariants typés ;
- non-revendications écrites ;
- dix contre-modèles définis.

### M1 — calcul effectif

- carriers complets ;
- prédécesseur décidable ;
- point fixe exécuté ;
- stabilisation intrinsèque.

### M2 — correction

- `WIN → arbre correct` ;
- monde réel retenu ;
- décision correcte ;
- clôtures préservées.

### M3 — complétude

- arbre public fini arbitraire `→ WIN` ;
- aucun oracle de séparateur ;
- aucune hypothèse externe de rang.

### M4 — obstruction

- `LOSE` positif ;
- fermeture pour chaque requête jouable ;
- branche perdante contre tout arbre.

### M5 — décision totale

- exactement `WIN` ou `LOSE` ;
- verdict décidable ;
- audits sans axiome.

### M6 — coût

- coût recalculé ;
- borne inférieure universelle ;
- minimum atteint ;
- cycles de coût nul traités.

### M7 — transfert appris

- checker formalisé ;
- correction concrète ;
- abstention sûre ;
- non-régression ;
- complétude relative si revendiquée.

### M8 — comparaison

- R1–R7 compilent ;
- exemples stricts ;
- texte de positionnement cohérent avec les théorèmes.

## 8. Portes artefact et expériences

### A0 — autonomie

Build dans une copie isolée, aucun import métier externe, versions gelées.

### A1 — certificats

Deux vérificateurs, schémas versionnés, 100 % des mutations rejetées.

### A2 — exhaustivité

E0 terminé sans divergence ; E1 terminé avant le label « exhaustive modulo isomorphisme ».

### A3 — learned protocol

Préenregistrement, matrice complète, erreurs et abstentions publiées.

### A4 — réplication

Build, E0 et sous-campagne apprise reproduits extérieurement.

### A5 — archivage

Archive immuable avec DOI, licence, citation, hashes, commandes et données suffisantes.

## 9. Échelle de verdict public

### V0 — idée

Architecture plausible, aucune preuve complète.

### V1 — contribution formelle

M0–M5 et A0–A2. Formulation : « caractérisation constructive certifiée pour une classe finie ».

### V2 — contribution méthodologique forte

V1 + M6–M8. Formulation : « synthèse optimale sûre, située formellement par rapport aux cadres voisins ».

### V3 — pont IA démontré

V2 + M7 + protocole expérimental réussi. Formulation : « pont certifié entre latent appris et réparation active sur domaines contrôlés ».

### V4 — résultat majeur candidat

V3 + comparaison expérimentale solide + réplication extérieure + réception positive en revue/conférence compétitive.

### V5 — résultat ayant fait date

Ne peut être attribué par les auteurs à la publication. Il dépend de l’adoption, des extensions indépendantes et de l’impact rétrospectif.

Le mot « game changer » n’a donc aucun statut scientifique interne. L’objectif opérationnel réaliste est V3, puis laisser la communauté décider si V4 ou V5 est justifié.

## 10. Conditions de falsification

Réduire ou abandonner la revendication centrale si :

- la complétude exige de réintroduire un séparateur comme hypothèse ;
- l’état public fini doit contenir secrètement le monde réel ;
- `LOSE` n’est qu’une négation sans contre-stratégie ;
- la correction du transfert suppose la justesse du réseau au lieu de la vérifier ;
- la comparaison montre que C1–C8 sont une instance directe déjà formalisée sans apport distinct ;
- une mutation de branche ou de provenance est acceptée ;
- un certificat accepté mène à une action incorrecte ;
- les avantages expérimentaux disparaissent face aux baselines appariées ;
- la couverture certifiée est trop faible pour l’usage revendiqué ;
- la reproduction échoue sans cause matérielle ou versionnée identifiable.

Un échec empirique ne réfute pas nécessairement le théorème, mais il réfute l’affirmation d’efficacité. Un échec formel bloque toute revendication fondationnelle.

## 11. Structure du papier cible

1. problème et distinction action/identification ;
2. jeu public de réparation et invariants ;
3. point fixe constructif ;
4. certificats gagnants et perdants ;
5. correction, complétude et décision totale ;
6. coût minimal ;
7. transfert aux latents appris ;
8. comparaisons formelles ;
9. vérification exhaustive ;
10. expériences préenregistrées ;
11. limites et extensions ;
12. related work détaillé.

Le résumé doit séparer explicitement : « nous prouvons », « nous implémentons », « nous observons » et « nous ne couvrons pas ».

## 12. Audit final des claims

Avant soumission, chaque phrase du résumé, de l’introduction et de la conclusion reçoit :

- un identifiant de claim ;
- un type : theorem / computed / empirical / contextual / conjecture ;
- une source précise ;
- les hypothèses ;
- la population ou classe couverte ;
- un test de sur-généralisation ;
- le statut de réplication.

Toute phrase sans ligne dans la matrice est supprimée ou reformulée.
