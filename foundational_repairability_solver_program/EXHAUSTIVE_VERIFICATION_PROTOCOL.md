# Protocole de vérification exhaustive et de falsification

## 1. Finalité

La preuve Lean garantit les théorèmes pour le modèle formalisé. La vérification exhaustive vise d’autres risques :

- erreur du générateur d’instances ;
- divergence entre modèle sérialisé et modèle Lean ;
- bug d’extraction ou du CLI ;
- branche réalisable oubliée ;
- certificat acceptant une instance mal formée ;
- hypothèse implicite non couverte par le type ;
- résultat empirique sélectionné après observation.

Elle ne remplace pas la preuve et ne transforme pas une borne finie en théorème universel.

## 2. Trois implémentations indépendantes

Les verdicts sont croisés entre :

1. solveur Lean de référence ;
2. solveur indépendant simple, écrit sans copier la récursion Lean ;
3. oracle par énumération brute des stratégies pour les très petites tailles.

Règle : la version indépendante calcule le point fixe avec une représentation différente. Exemple : Lean utilise des masques, Python utilise des ensembles immuables ; l’oracle brut énumère les arbres par profondeur.

Une divergence interrompt immédiatement la campagne. Aucun vote majoritaire ne décide quelle version est correcte.

## 3. Modèle canonique énuméré

Pour les tiers exhaustifs, un jeu brut déterministe est défini par :

- nombre de mondes `W` ;
- nombre d’états publics `S` ;
- nombre d’actions `A` ;
- nombre de requêtes `Q` ;
- nombre de réponses `R` ;
- table `required : W → A` ;
- matrice de compatibilité `S × W` ;
- table de réponse `W × Q → R` ;
- matrice d’autorisation `S × Q` ;
- table de transition `S × Q × R → S` ;
- table optionnelle de décisions `S → Option A` ;
- coût `S × Q → Nat`.

Les instances non bien formées sont soit :

- filtrées par un prédicat explicite et comptées comme rejetées ;
- incluses dans un corpus négatif de validation de schéma.

Jamais supprimées silencieusement.

## 4. Paliers exhaustifs gelés

### E0 — totalité brute sans réduction par isomorphisme

Le palier est séparé en profils dont le nombre brut est calculé avant lancement.

```text
E0a exact statique :
  1 ≤ W ≤ 3, 1 ≤ A ≤ 2, 1 ≤ Q ≤ 2, 1 ≤ R ≤ 2 ;
  états = toutes les fibres non vides atteignables ;
  transition = intersection exacte ; autorisation = sous-ensemble statique de Q.

E0b contexte dynamique :
  1 ≤ W ≤ 2, 1 ≤ C ≤ 2, 1 ≤ A ≤ 2, 1 ≤ Q ≤ 2, R = 2 ;
  états = fibre exacte × contexte ;
  toutes les tables d’autorisation C×Q et de transition de contexte C×Q×R.

E0c langage partiel :
  mêmes bornes que E0b ;
  toutes les disponibilités de décision par classe d’action.

E0d coût :
  mêmes instances canoniques que E0a/E0b ;
  coûts statiques par requête dans {0,1,2} ;
  optimalité comparée à l’oracle brut.

E0e tables publiques génériques :
  W ≤ 2, S ≤ 2, A ≤ 2, Q = 1, R ≤ 2 ;
  toutes les compatibilités, réponses, autorisations, transitions et décisions,
  avec filtrage explicite des jeux non bien formés.
```

Chaque combinaison du profil déclaré est visitée. Aucun profil dont le compte brut prévisionnel dépasse 50 millions n’est lancé sans optimisation ou nouvelle version explicite du protocole. Le manifeste publie : formule de comptage, nombre prévisionnel, brut visité, rejeté, valide, gagnant, perdant et divergences.

### E1 — exhaustive modulo isomorphisme

Bornes minimales :

```text
E1a : W = 4, 1 ≤ A ≤ 3, 1 ≤ Q ≤ 3, R = 2,
      états = fibres canoniques non vides, autorisation statique.

E1b : W = 5, A = 2, 1 ≤ Q ≤ 3, R = 2,
      états = fibres canoniques non vides, autorisation statique.
```

Les symétries de noms des mondes, actions, requêtes et réponses sont réduites par canonisation. Une preuve papier ou un test exhaustif sur E0 vérifie que deux objets fusionnés sont réellement isomorphes et ont le même verdict.

Les réponses ternaires et les contextes dynamiques de taille supérieure passent dans E2 tant qu’un compte E1 réaliste n’est pas gelé. E1 ne peut être annoncé « exhaustif » que si :

- le générateur produit une clé canonique unique ;
- un second générateur indépendant retrouve les mêmes clés et comptes ;
- toutes les partitions du carrier visé sont couvertes ;
- le hash final du corpus est publié.

### E2 — stress non exhaustif

Tailles :

```text
W ∈ {8,16,32,64}
S ∈ {16,64,256,1024}
Q ∈ {4,8,16}
R ∈ {2,4,8}
```

Familles : aléatoires uniformes, fortement aliasées, requêtes préparatoires, autorisation rare, longues chaînes, graphes cycliques, régions gagnantes minuscules, régions perdantes minuscules.

E2 mesure performance et robustesse ; il ne porte aucune revendication exhaustive.

## 5. Oracle brut des stratégies

Pour E0, énumérer par profondeur :

```text
T₀(s) : succès si Target(s)
Tₙ₊₁(s) : succès si Target(s), ou s’il existe q autorisée
           tel que toutes les réponses réalisables mènent à Tₙ.
```

Explorer jusqu’à `S` profondeurs. Comparer :

- verdict ;
- première profondeur gagnante ;
- coût minimal lorsque le profil le permet ;
- ensemble perdant ;
- contre-réponse pour chaque couple état/requête.

L’oracle ne lit jamais le certificat produit par le solveur pour décider son verdict.

## 6. Propriétés vérifiées sur chaque instance

### 6.1 Structure

- indices dans les bornes ;
- carriers non vides lorsque requis ;
- états initiaux bien formés ;
- tables totales ;
- réponses réalisables cohérentes avec les mondes compatibles ;
- transitions fermées dans le carrier ;
- hachage canonique stable.

### 6.2 Point fixe

- `W₀` égale exactement la cible ;
- chaîne croissante ;
- stabilisation ;
- idempotence au point fixe ;
- aucun état perdant n’est prédécesseur contrôlable du gagnant ;
- chaque état ajouté possède un témoin valide de couche antérieure.

### 6.3 Certificat `WIN`

- racine exacte ;
- requêtes jouables ;
- au moins une branche réalisable ;
- toutes et seulement les réponses réalisables couvertes ;
- transitions recalculées ;
- feuilles cibles non vides ;
- décision correcte pour tous les mondes de chaque feuille ;
- invariants et non-régression ;
- absence de cycle non justifié ;
- profondeur égale à la couche annoncée ou inférieure ;
- coût annoncé égal au coût recalculé.

### 6.4 Certificat `LOSE`

- racine dans la région ;
- région non vide ;
- aucune cible dans la région ;
- pour chaque état de la région et chaque requête jouable, une réponse réalisable maintient dans la région ;
- chaque contre-réponse est recalculée ;
- aucune omission de requête ;
- la région est disjointe de la région gagnante calculée indépendamment.

### 6.5 Caractérisation

- `WIN` si et seulement si l’oracle trouve un arbre ;
- `LOSE` si et seulement si l’oracle n’en trouve aucun dans la borne complète ;
- jamais `WIN` et `LOSE` simultanément ;
- toujours exactement l’un des deux sur une entrée valide.

## 7. Suite de mutations obligatoire

Pour chaque certificat de référence, générer au moins :

1. modification du hash du jeu ;
2. suppression d’une branche réalisable ;
3. ajout d’une branche irréalisable ;
4. remplacement d’une réponse ;
5. remplacement d’un état enfant ;
6. requête non autorisée ;
7. décision incorrecte ;
8. fibre vide déclarée cible ;
9. coût diminué artificiellement ;
10. cycle introduit ;
11. doublon de nœud ou d’identifiant ;
12. état perdant retiré pour casser la fermeture ;
13. contre-réponse non réalisable ;
14. requête jouable omise du certificat négatif ;
15. version de schéma inconnue ;
16. clé JSON inconnue en mode strict ;
17. entier négatif ou débordant ;
18. sérialisation non canonique ;
19. provenance altérée ;
20. ancienne clôture marquée conservée alors qu’elle ne l’est pas.

Taux de détection requis : 100 %. Toute mutation survivante est un échec de porte.

## 8. Tests métamorphiques

Les transformations suivantes doivent préserver le verdict :

- permutation cohérente des noms de mondes ;
- permutation cohérente des actions ;
- permutation cohérente des requêtes ;
- permutation cohérente des réponses ;
- ajout d’un état public inaccessible ;
- duplication syntaxique éliminée par canonisation.

Transformations monotones attendues :

- ajouter une requête autorisée ne peut transformer un état gagnant en perdant si les anciennes transitions sont inchangées ;
- supprimer une requête ne peut transformer un état perdant en gagnant ;
- raffiner une fibre exacte peut fermer un conflit mais ne doit pas créer de nouvelle paire conflictuelle entre mondes conservés ;
- enrichir le langage de décision peut transformer perdu en gagné, pas l’inverse si l’ancien compilateur est conservé ;
- renforcer les invariants de sécurité peut transformer gagné en perdu, pas l’inverse.

Chaque propriété doit être testée et, lorsqu’elle est générale, prouvée en Lean.

## 9. Contre-modèles de frontière

Le corpus nommé `boundary/` contient les dix contre-modèles du contrat mathématique. Pour chacun :

- fichier de jeu canonique ;
- verdict attendu ;
- certificat attendu ou propriétés minimales ;
- explication de l’hypothèse manquante ;
- test Lean ;
- test du vérificateur indépendant.

Un changement qui inverse un verdict de frontière exige une révision de version majeure du modèle ou la correction d’un bug documenté.

## 10. Traçabilité des scripts scientifiques

Les règles suivantes s’appliquent à toute exécution citée :

1. ne jamais modifier un script historique ayant produit un résultat cité ;
2. créer une nouvelle variante dans un nouveau fichier ;
3. calculer le SHA-256 du script ;
4. copier le script sous un nom `nom_YYYYMMDDTHHMMSSZ_<hash12>.py` ;
5. exécuter uniquement cette copie figée ;
6. donner exactement le même suffixe aux sorties JSONL, TXT et manifeste ;
7. inclure dans le TXT la commande complète, le hash, le commit logique du programme et les versions ;
8. écrire les smoke tests dans `/tmp` ou dans des fichiers contenant `_smoke_` ;
9. ne jamais écraser un résultat de référence.

Le hash complet reste dans le manifeste même si le nom n’en expose que douze caractères.

## 11. Manifeste d’exécution

Chaque run produit un JSON contenant au minimum :

```json
{
  "schema": "repair-run-manifest/1",
  "run_id": "UTC_HASH",
  "scientific": true,
  "command": ["PROGRAM", "ARGUMENT"],
  "script_path": "FROZEN_SCRIPT_PATH",
  "script_sha256": "64_HEXADECIMAL_CHARACTERS",
  "input_sha256": "64_HEXADECIMAL_CHARACTERS",
  "output_sha256": "64_HEXADECIMAL_CHARACTERS",
  "lean_version": "PINNED_LEAN_VERSION",
  "mathlib_revision": "PINNED_MATHLIB_REVISION",
  "python_version": "PINNED_PYTHON_VERSION",
  "os": "RECORDED_OPERATING_SYSTEM",
  "cpu": "RECORDED_CPU",
  "gpu": "RECORDED_GPU_OR_NONE",
  "started_utc": "RFC3339_TIMESTAMP",
  "ended_utc": "RFC3339_TIMESTAMP",
  "counts": {
    "generated": 0,
    "valid": 0,
    "rejected": 0,
    "win": 0,
    "lose": 0,
    "divergence": 0
  }
}
```

## 12. Procédure en cas de divergence

1. figer l’instance minimale divergente ;
2. arrêter tous les runs dépendants ;
3. reproduire avec les trois implémentations ;
4. réduire l’instance sans modifier le verdict divergent ;
5. identifier si l’erreur est dans la spécification, Lean, l’oracle ou la sérialisation ;
6. ajouter un test de régression avant le correctif ;
7. créer de nouveaux scripts versionnés ;
8. invalider explicitement tous les résultats produits par la version fautive ;
9. relancer le palier complet ;
10. publier l’incident dans le journal de réplication.

Aucun résultat partiel du palier concerné ne peut être conservé comme référence après une divergence non résolue.

## 13. Critères de réussite

### Porte X0 — unité

- tous les modules unitaires passent ;
- tous les contre-modèles ont le verdict attendu.

### Porte X1 — E0

- totalité brute terminée ;
- zéro divergence ;
- zéro mutation survivante ;
- comptes et hashes publiés.

### Porte X2 — E1

- deux générateurs concordent ;
- canonisation validée ;
- zéro divergence ;
- corpus et manifestes publiés.

### Porte X3 — E2

- aucune erreur interne ;
- courbes temps/mémoire publiées ;
- timeout et limites rapportés comme tels.

### Porte X4 — réplication

- reproduction depuis environnement propre ;
- au moins E0 reproduit par une autre machine ou personne ;
- hash final identique ou différences expliquées par un manifeste.

Seules X0 et X1 sont obligatoires avant une prépublication mathématique. X2, X3 et X4 sont obligatoires avant la revendication d’un artefact expérimental de référence.
