# Audit de la spécification

Date : 2026-07-20  
Portée : dossier `foundational_repairability_solver_program` uniquement  
Verdict : **spécification cohérente et suffisamment déterminée pour commencer l’implémentation ; aucun théorème ou résultat expérimental encore produit**.

## 1. Contrôles structurels

| Contrôle | Résultat |
|---|---|
| documents normatifs annoncés présents | passé |
| JSON syntaxiquement valides | passé |
| `program.lock.json` conforme à `schemas/program.schema.json` | passé |
| références internes aux documents | passé |
| marqueurs de travail temporaires ou ellipses | zéro |
| statut des lots non implémentés | explicitement `not_started` |
| dépendance au code métier existant | aucune dans le dossier |
| usage de Git pendant la préparation | aucun |

Les fragments Lean des documents sont des signatures normatives ou pseudocodes typés. Ils ne sont pas comptés comme fichiers `.lean` et ne prétendent pas compiler avant la création du futur artefact.

## 2. Contrôles mathématiques

### 2.1 Quantification de la stratégie

La réparabilité est définie indépendamment du solveur par un arbre public fini. La complétude doit partir de cet arbre, ce qui évite une équivalence définitionnelle vide.

Résultat de l’audit : passé au niveau spécification.

### 2.2 Requêtes préparatoires

La caractérisation ne suppose pas qu’une requête réduise immédiatement une mesure de conflit. Un état peut progresser en modifiant son contexte d’autorisation ; le point fixe sur l’état public complet capture ce cas.

Résultat : la faiblesse de la séparabilité ponctuelle est correctement traitée.

### 2.3 Requêtes sans réponse

Une requête est `Playable` seulement si elle est autorisée et possède une réponse réalisable. Le prédécesseur, l’arbre et l’obstruction emploient ce type. Cela évite :

- un gain universel vide ;
- une obstruction exigeant une réponse inexistante.

Résultat : correction apportée pendant l’audit.

### 2.4 Direction de l’inclusion postérieure

Le contrat sûr est désormais :

```text
posterior exact ⊆ fibre abstraite suivante ⊆ fibre précédente.
```

L’exactitude ajoute l’inclusion inverse par cohérence avec la réponse. La première version de travail risquait de confondre sous-approximation et sur-approximation ; elle a été corrigée avant livraison.

Résultat : cohérent avec la rétention du monde réel et le transfert abstrait.

### 2.5 Cible non vacuaire

`CertifiedTarget` exige une fibre non vide, une classe d’action homogène, une décision exprimable et la sûreté de l’état.

Résultat : aucun succès par vacuité.

### 2.6 Fermeture perdante

Le certificat `LOSE` fournit, pour chaque état perdu et requête jouable, une réponse réalisable maintenant dans la région. L’impossibilité est relative au jeu déclaré et non universelle au-delà de ses capteurs ou de son langage.

Résultat : obstruction positive suffisamment forte pour une induction contre tout arbre public fini.

### 2.7 Terminaison

La borne vient du nombre d’états explicitement énumérés. Aucun `rank`, horizon ou pont terminal n’est une hypothèse du jeu.

Résultat : conforme aux contraintes constructives. La preuve Lean reste à écrire.

### 2.8 Indiscernabilité

L’homogénéité des classes d’indiscernabilité adaptative est un corollaire sous hypothèses fortes, pas le théorème principal en contexte dynamique général.

Résultat : la caractérisation n’est pas sur-généralisée.

### 2.9 Optimalité

Le premier théorème de coût vise le pire cas et des coûts naturels strictement positifs. Les cycles de coût nul sont une extension explicitement séparée.

Résultat : claim d’optimalité borné à une classe démontrable.

### 2.10 Transfert appris

Le réseau propose ; le vérificateur accepte ou rejette. La garantie ne dépend pas de la loss ni de l’architecture. Couverture et correction conditionnelle sont séparées.

Résultat : frontière de confiance nette.

## 3. Contrôles de faisabilité

### 3.1 Exhaustivité

La première proposition brute sur des tables arbitraires aurait produit un espace irréaliste. Elle a été remplacée par cinq profils E0 comptables et par E1 binaire modulo isomorphisme. Un seuil de 50 millions de cas bruts impose un nouveau gel si une borne le dépasse.

Résultat : protocole exigeant mais crédible sur une station.

### 3.2 Campagne apprise

La matrice complète comporte 140 entraînements ; une règle de débit aveugle aux métriques choisit le budget. Un profil core préengagé conserve deux domaines et dix seeds si le débit minimal est insuffisant.

Résultat : adaptation au matériel sans sélection postérieure des résultats.

### 3.3 Stockage

Plafond de 150 Mo par run et 30 Go pour la campagne, avec arrêt préventif sous 10 Go libres.

Résultat : compatible avec le profil de station déclaré, sous contrôle du manifeste au moment du lancement.

## 4. Contrôles de nouveauté

Le dossier reconnaît explicitement les antécédents proches :

- adaptive distinguishing sequences ;
- diagnostic actif ;
- belief supports et jeux partiellement observables ;
- predictive-state representations ;
- CEGAR et synthèse de contrôleurs.

Le point fixe n’est pas revendiqué comme nouveauté. La contribution distinctive visée est la combinaison démontrée de : décision par classe d’action, réparation preuve-pertinente, sécurité/non-régression, certificat négatif, coût sûr, comparaison formelle et transfert d’un latent appris par vérification indépendante.

Résultat : positionnement honnête. La nouveauté réelle reste à confirmer par revue bibliographique finale et validation extérieure.

## 5. Contrôles de traçabilité

- identifiants F01–F30 pour les exigences formelles ;
- C01–C10 pour la constructivité ;
- A01–A12 pour l’artefact ;
- E01–E14 pour l’expérience ;
- N01–N10 pour les claims ;
- D01–D20 pour les décisions ;
- registres RF, RI, RE et RN pour les risques.

Résultat : chaque résultat futur possède une place prédéfinie et un statut initial non ambigu.

## 6. Ce que cet audit ne valide pas

Il ne valide pas encore :

- la compilabilité d’un solveur Lean inexistant ;
- la vérité des théorèmes avant leurs preuves ;
- la performance du solveur ;
- l’exhaustivité d’un corpus non généré ;
- la couverture d’un latent non entraîné ;
- la nouveauté après revue complète de la littérature ;
- une qualification de « game changer ».

## 7. Décision de départ

L’implémentation peut commencer sans choix conceptuel bloquant. La première action est WP00, puis les dix tâches fixées à la fin de `IMPLEMENTATION_ROADMAP.md`.

Le premier objectif de vérité n’est pas une expérience GPU. C’est la porte M5 :

```text
solve_total
+ solver_win_sound
+ solver_win_complete
+ solver_lose_sound
+ losing_region_closed
+ audits sans axiome.
```

Après M5 seulement, le programme passe du statut de plan à celui de résultat formel.
