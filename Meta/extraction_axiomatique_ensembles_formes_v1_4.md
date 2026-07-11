# Extraction axiomatique de la théorie des ensembles formés

**Document analysé :** `theorie_constructive_ensembles_formes_v1_4.md`  
**Objet :** identifier les axiomes réellement nécessaires, distinguer les principes nouveaux des théorèmes dérivés, et isoler le premier mécanisme canonique de diagonalisation positive.

---

## 1. Conclusion principale

La diagonalisation positive ne doit pas être introduite par un axiome nu :

```text
Σ cell,
Σ witness,
  Positive cell witness
```

Un tel axiome cacherait la provenance du témoin et pourrait être satisfait par
une famille arbitraire telle que `Unit`.

Le premier mécanisme canonique provient du contraste :

```text
rigidité de la formation interne
+
extensionalité de la projection visible.
```

La paire formée donne le premier exemple complet :

```text
formed := pair⁺ A B
shadow := pair⁺ B A
```

Le niveau visible identifie ces deux paires par commutativité extensionnelle.
Le niveau formé les sépare lorsque :

```text
A = B → False
```

et que la paire est rigide dans l’ordre de ses paramètres.

Le principe caractéristique est donc :

```text
provenance ou rigidité de formation
```

Dans une axiomatique abstraite, cette loi est ajoutée comme axiome. Dans un
modèle syntaxique inductif, elle doit être dérivée du principe de
non-confusion des constructeurs.

et non :

```text
axiome d’obstruction
axiome de non-reconstruction
axiome d’existence diagonale sans contenu.
```

---

## 2. Métathéorie supposée

Ces principes ne sont pas des axiomes de la théorie interne :

```text
Type
Prop
Π
Σ
égalité intentionnelle
types inductifs
Empty
Unit
équivalences
Nonempty
```

La cohérence de la théorie sera relative à cette métathéorie constructive.

---

## 3. Signature primitive

| Code | Symbole | Statut |
|---|---|---|
| S1 | `FormedSet : Typeᵤ` | sorte formée |
| S2 | `VisibleSet : Typeᵥ` | sorte visible |
| S3 | `project : FormedSet → VisibleSet` | projection |
| S4 | `Mem : FormedSet → FormedSet → Typeₘ` | appartenance preuve-pertinente |
| S5 | `VisibleMem : VisibleSet → VisibleSet → Prop` | appartenance visible |

Ce sont des symboles, pas encore des axiomes.

---

## 4. Principes de présentation

### P1 — projection de l’appartenance

```text
Mem x A
→
VisibleMem (project x) (project A)
```

### P2ʳ — réflexion propositionnelle

```text
VisibleMem U (project A)
→
Nonempty (VisibleMembershipLift U A)
```

Cette loi donne une adéquation propositionnelle sans choisir de représentant
calculable.

### P2⁺ — réalisation en données, extension forte

```text
VisibleMem U (project A)
→
VisibleMembershipLift U A
```

`P2⁺` implique `P2ʳ`. Il ne révèle pas une donnée déjà contenue dans
`VisibleMem`, puisque `VisibleMem : Prop`. Il ajoute une section globale vers
un représentant formé et doit être classé comme principe fort, proche d’un
choix de représentants.

La preuve-irrélevance implique que deux applications de P2⁺ à deux preuves de
la même appartenance visible donnent des relèvements égaux. P2⁺ canonise donc
un relèvement pour chaque couple visible habité.

### P3 — extensionalité visible

```text
(
  ∀ U,
    VisibleMem U V ↔ VisibleMem U W
)
→
V = W
```

Aucune extensionalité interne n’est ajoutée.

---

## 5. Trois routes axiomatiques

### Route diagonale locale

```text
P3
+
lois de projection propres aux constructeurs utilisés
```

Elle suffit à la diagonale canonique de la paire.

### Route adéquate propositionnelle

```text
P1 + P2ʳ + P3
```

Elle dérive les lois visibles du vide, de la paire et de l’union.

### Route réalisée en données

```text
P1 + P2⁺ + P3
```

Elle fournit des représentants calculables, implique la route précédente et
doit être modélisée séparément.

La loi visible d’une séparation exige en plus une sémantique visible du code
et une factorisation du prédicat par `project`.

---

## 6. Axiomes de formation

| Code | Axiome | Contenu |
|---|---|---|
| F0 | `empty⁺` | vide formé avec éliminateur |
| F1 | `pair⁺` | paire avec occurrences gauche/droite |
| F2 | `pairRigidity` | égalité de présentations de paire ⇒ paramètres ordonnés égaux |
| V1 | `pairProjection` | loi visible de chaque paire formée |
| F3 | `union⁺` | union avec provenance complète |
| F4 | `separateBounded⁺` | séparation sur codes bornés dépendant de la base |

F2 est la première loi abstraite de provenance. Elle est axiomatique dans une
signature abstraite, mais devient un théorème de non-confusion lorsque les
formations sont une syntaxe inductive. Elle ne doit donc pas être présentée
comme un axiome universel indépendant du choix de représentation.

Le symbole `pair⁺ A B` désigne une présentation formée orientée de la paire
visible non ordonnée.

---

## 7. Schéma de provenance

Pour un constructeur :

```text
form : Parameters → FormedSet
```

une loi de provenance est :

```text
form p = form q
→
SameFormationParameters p q.
```

Exemples futurs :

```text
PairRigidity
UnionProvenance
SeparationProvenance
ImageProvenance
```

Le schéma doit être validé constructeur par constructeur.

Une rigidité universelle serait injustifiée.

Pour F4, la signature cohérente est :

```text
BoundedPredicateCode : FormedSet → Type
Satisfies : BoundedPredicateCode A → FormedSet → Prop
```

La loi visible de séparation exige en plus `VisibleSatisfies` et :

```text
Mem x A
→
(
  Satisfies code x
  ↔
  VisibleSatisfies code (project x)
).
```

---

## 8. Dérivation de la diagonale canonique

### Étape 1 — deux paramètres séparés

```text
E := empty⁺.set
S := (pair⁺ E E).set
```

La paire contient `E`, le vide ne contient rien :

```text
E = S → False.
```

### Étape 2 — deux formations orientées

```text
P := (pair⁺ E S).set
Q := (pair⁺ S E).set
```

### Étape 3 — égalité visible

V1, c’est-à-dire `pairProjection E S` et `pairProjection S E`,
donne les mêmes membres visibles pour `P` et `Q`.

P3 donne :

```text
project P = project Q.
```

### Étape 4 — séparation interne

Une égalité :

```text
P = Q
```

donnerait par F2 :

```text
E = S
```

donc `False`.

### Étape 5 — témoin positif

Le témoin dépendant conserve :

```text
la séparation E = S → False
E comme occurrence gauche dans P
S comme occurrence droite dans P
S comme occurrence gauche dans Q
E comme occurrence droite dans Q.
```

L’orientation est certifiée par un type `PairOccurrenceWitness` contenant :

```text
member : Mem x pair.set
decodes_to : pair.membership.toFun member = occurrence attendue
```

Le champ propositionnel `Positive` certifie la cohérence de cette donnée ; le
contenu substantiel est porté par le témoin de permutation lui-même.

On obtient :

```text
canonicalPositiveDiagonal.
```

---

## 9. Graphe de dépendance

```text
F0 empty⁺
   |
   +-------------------+
                       |
F1 pair⁺               |
   |                   |
   +--> E ≠ pair E E <-+
   |
F2 PairRigidity
   |
PairProjectionLaw + P3
   |
   v
canonicalPairCell
   |
PairSwapWitness
   |
   v
canonicalPositiveDiagonal
   |
   +--> transport d’usage
   +--> obstruction à la fidélité
   +--> non-reconstruction globale
   +--> gap de vérité construit
```

Les quatre dernières conséquences ne sont pas des axiomes.

---

## 10. Axiomes constructifs forts

Pour une théorie comparable à un fragment de CZF :

| Code | Principe |
|---|---|
| C1 | infini formé |
| C2 | collection forte preuve-pertinente |
| C3 | induction sur l’appartenance formée |
| C4 | éventuellement subset collection |

La puissance pleine doit rester séparée tant que les univers et un modèle ne
sont pas fixés.

---

## 11. Extensions diagonales optionnelles

### R — réparation locale

```text
RepairOf : FormedSet → Type
LocalProjectiveRecovery RepairOf
```

Une version causale relie explicitement `repair` à `recovered`.

### T — vérité formée admissible

```text
TruthData : FormedSet → Type
```

Une notion d’admissibilité doit empêcher que toute vérité soit réduite à :

```text
X = formed.
```

### P — persistance sous changement de projection

Un témoin diagonal peut être transporté ou conservé entre plusieurs régimes
visibles.

Ces principes ne doivent pas être inclus dans le noyau diagonal minimal.

---

## 12. Hiérarchie proposée

```text
PFS_D :
  P3
  F0 F1 F2
  V1 pairProjection

PFS₀ʳ :
  P1 P2ʳ P3
  F0 F1 F2 F3 F4

PFS₀⁺ :
  PFS₀ʳ
  + P2⁺

PFS_C :
  PFS₀ʳ
  + infini
  + collection forte
  + induction formée

PFS_C⁺ :
  PFS_C
  + P2⁺

PFS_P :
  PFS_C
  + puissance ou subset collection

PFS_R :
  PFS₀ʳ
  + réparation locale

PFS_T :
  PFS₀ʳ
  + vérité formée admissible
```

`PFS_D` ne requiert aucun relèvement global. `PFS₀ʳ` est une base candidate
pour une comparaison constructive future avec CZF. `PFS₀⁺` ajoute une section forte
de réalisation.

---

## 13. Principes caractéristiques dégagés

### Provenance formée

L’égalité interne d’une formation conserve les données de construction que la
projection visible peut oublier.

```text
égalité formée
→
égalité de provenance.
```

C’est le moteur spécifique de la diagonalisation lorsque cette loi rencontre
une équation extensionnelle visible.

### Réflexion et réalisation

La réflexion propositionnelle :

```text
VisibleMem
→
Nonempty donnée de représentation
```

est une loi d’adéquation.

La réalisation forte :

```text
VisibleMem
→
donnée de représentation
```

est une section supplémentaire, proche d’un choix de représentants. Elle est
utile mais ne constitue pas la nouveauté minimale de la théorie et n’intervient
pas dans la diagonale canonique lorsque V1 est fourni localement.

---

## 14. Obligations de modèle

Un modèle complet doit montrer simultanément :

```text
1. existence des constructeurs formés ;

2. preuve-pertinence de Mem ;

3. rigidité de la paire ou provenance équivalente ;

4. extensionalité du visible ;

5. adéquation propositionnelle entre Mem et VisibleMem ;

5⁺. éventuellement une section de réalisation, si P2⁺ est retenu ;

6. égalités visibles des constructeurs ;

7. cohérence de l’infini et de la collection ;

8. non-trivialité du témoin diagonal choisi.
```

Le noyau `PFS_D` possède déjà un modèle explicite :

```text
FormedSet := syntaxe empty | pair A B
VisibleSet := ensembles héréditairement finis
project empty := ∅
project (pair A B) := {project A, project B}
```

L’injectivité du constructeur `pair` donne F2, et la sémantique de l’ensemble
non ordonné donne V1 et P3. Ce modèle valide la diagonale canonique. Les
extensions par union, séparation, collection, infini et puissance demandent
des modèles supplémentaires.

---

## 15. Verdict

Les principes caractéristiques ne doivent pas être cherchés sous forme de
négations.

Le noyau diagonal minimal est :

```text
formation positive
+
provenance rigide des présentations
+
loi d’extensionalisation visible.
```

La réalisation `P2⁺` est une extension forte et optionnelle ; elle ne doit pas
être confondue avec la diagonalisation positive elle-même.

La diagonalisation positive est un résultat construit et le noyau minimal
qui la produit possède un modèle explicite :

```text
la formation retient ce que le visible contracte.
```
