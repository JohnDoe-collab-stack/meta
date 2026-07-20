# CP0-TARGET-0 — protocole de rendement tenu à l'écart

## 1. Statut

Préenregistrement et gel du lecteur synthétique, sans ouverture des valeurs
réelles — 19 juillet 2026.

```text
cible      = pourcentage de rendement du produit désiré
niveau     = CP0-R rétrospectif public
unité test = paire amine–acide entièrement absente de construction
métrique   = MAE en points de pourcentage, agrégée par entrée unique
```

L'entrée sans cible est maintenant implémentée par `CP0-ONTOLOGY-2` : 47 015
lignes concordent avec le manifest I0 et leurs domaines appartiennent aux 194
espèces et 94 environnements certifiés. Le contrat du producteur, `T1` et `T2`
sont achevés sans décoder de rendement réel. Le lecteur figé n'expose que les
modes `construction` et `selection` ; il n'offre aucun mode `held_out_test`.

La présence de 47 015 valeurs est établie par enveloppe protobuf. Leur contenu
et leur distribution restent inconnus du pipeline réalisé.

## 2. Compartiments gelés

Le manifest normatif est celui de `CP0-DATA-I0`, SHA-256 :

```text
da963892cf8caebf3ad5983773b866a13333260869805542b16d0be1aa01cb9b
```

Utilisation :

```text
construction
  valeurs ouvrables pour ajuster paramètres et règles ;

selection
  valeurs ouvrables pour choisir exclusivement parmi des variantes et grilles
  préenregistrées ;

held_out_test
  valeurs interdites jusqu'au gel du producteur, des baselines et du vérificateur ;

excluded_cross
  valeurs jamais utilisées dans CP0-R.
```

## 3. Unité statistique

Une entrée unique est le triplet :

```text
(amine canonique, acide canonique, condition sémantique)
```

Lorsque plusieurs lignes partagent ce triplet, leur cible de référence est la
moyenne arithmétique de leurs rendements valides. Ce choix est fixé avant
lecture afin que les 804 répétitions ne surpondèrent pas certaines entrées.

Tout rendement non numérique, non fini ou hors de `[0, 100]` provoque un échec
de protocole. Il n'est ni imputé ni tronqué silencieusement.

## 4. Prédiction exigée

Chaque méthode reçoit uniquement les structures d'entrée, rôles, quantités et
conditions autorisés. Elle retourne pour chaque triplet :

```text
une valeur réelle de rendement prédit ;
ou une abstention explicitement comptée.
```

Pour la métrique principale, les prédictions numériques de toutes les méthodes
sont projetées dans `[0, 100]` par la même fonction gelée. Une abstention reçoit
une erreur absolue de 100 points et reste rapportée séparément.

## 5. Métriques

### Primaire

```text
MAE_grouped
  = moyenne, sur les triplets uniques du test,
    de |rendement_prédit − rendement_moyen_observé|.
```

### Secondaires

```text
RMSE_grouped ;
corrélation de rang de Spearman ;
MAE par paire amine–acide ;
MAE par condition ;
taux et largeur d'abstention ;
erreur absolue médiane et quantile 90 %.
```

Les métriques secondaires ne peuvent sauver un échec sur la métrique primaire.

## 6. Baselines obligatoires

Les baselines utilisent exactement le même split et la même agrégation :

```text
B0 — moyenne globale des cibles de construction ;

B1 — moyenne par condition sémantique, apprise sur construction ;

B2 — k plus proches paires moléculaires sous la même condition,
     similarité Tanimoto sur Morgan radius=2, 2048 bits ;

B3 — régression ridge sur fingerprints Morgan amine + acide et one-hot des
     94 conditions ;

B4 — ExtraTreesRegressor sur les mêmes descripteurs,
     sans identifiant de ligne, de plaque ou de dataset.
```

Grilles autorisées :

```text
B2 : k ∈ {1, 3, 5, 10}
B3 : alpha ∈ {0.1, 1, 10, 100}
B4 : n_estimators=500, bootstrap=false, random_state=0, n_jobs=1,
     max_features ∈ {"sqrt", 0.25}, min_samples_leaf ∈ {1, 2, 5}
```

Pour `B2`, la similarité d'une paire est la moyenne des similarités Tanimoto
amine–amine et acide–acide. La prédiction est la moyenne des `k` cibles voisines
pondérée par `max(similarité, 10⁻⁶)²`. Comme les 94 conditions sont présentes
dans chaque compartiment, le voisinage reste limité à la condition exacte.

`B3` concatène 2 048 bits amine, 2 048 bits acide et 94 indicatrices de
condition, avec intercept. `B4` reçoit exactement le même vecteur. Les versions
de calcul sont `RDKit 2026.03.4` et `scikit-learn 1.7.2`; leurs wheels et hashes
devront être figés avant l'étape `T3`.

Le choix dans les grilles se fait sur `selection` seulement. Aucune nouvelle
baseline ne peut être ajoutée après ouverture du test.

## 7. Critère de succès du cadre

Le cadre réussit CP0-R seulement si :

```text
MAE_cadre <= MAE_meilleure_baseline - 2 points de pourcentage ;
et
la borne supérieure de l'intervalle de confiance 95 % de
(erreur_cadre - erreur_baseline) est strictement négative.
```

L'intervalle est obtenu par 10 000 bootstrap appariés, graine `0`, en
rééchantillonnant les 30 paires test comme grappes. Le bootstrap ne
rééchantillonne pas indépendamment les 2 317 lignes.

Une égalité, une amélioration inférieure à deux points ou un intervalle qui
contient zéro est un `NO-GO-PREDICTION`, même si le logiciel est formellement
correct.

## 8. Séparation du cadre et des baselines

Le producteur du cadre doit être défini à partir des structures positives de
`CP0-ONTOLOGY-0` et du Core. Il ne peut recevoir :

```text
dataset_id ;
reaction_id ;
position de plaque ;
nom libre de condition ;
hash de molécule comme variable numérique ;
structure ou identifiant produit.
```

Les coefficients ajustables sont permis s'ils sont appris sur `construction`
et si leur forme était fixée avant ouverture. Le seul fait d'entraîner un
modèle conventionnel sur des fingerprints n'en fait pas un résultat du cadre :
un tel modèle appartient aux baselines.

## 9. Ordre d'ouverture

```text
T1 — implémenter et tester le lecteur de cible sur données synthétiques — terminé ;
T2 — geler son script, ses hashes et les checks [0,100] — terminé ;
T3 — ouvrir construction seulement — terminé, 17 130 groupes ;
T4 — ajuster le cadre et les baselines dans les familles autorisées — terminé ;
T5 — ouvrir selection et choisir une version — terminé, NO-GO C0-BIR ;
T6 — geler prédictions test, code et environnement ;
T7 — ouvrir held_out_test une seule fois dans le vérificateur ;
T8 — publier le verdict sans réajustement.
```

Le rapport normatif de `T1`–`T2`, ses 22 rejets synthétiques et ses empreintes
sont consignés dans [`PRODUCER_CONTRACT`](./PRODUCER_CONTRACT.md). Les wheels
RDKit/scikit-learn et le harnais de comparaison ont été gelés avant `T3`.

Le résultat de `T3`–`T5` est consigné dans
[`EMPIRICAL_RESULT_0`](./EMPIRICAL_RESULT_0.md). C0-BIR obtient 18,5021 de MAE
contre 14,5908 pour B2 sur `selection`. `T6`–`T8` ne sont pas exécutés : le
test final reste scellé pour ne pas le consommer avec une candidate déjà
réfutée.

## 10. Interprétation autorisée

Un succès montrerait qu'une règle calculable issue du cadre généralise à 30
paires d'amines et d'acides dont les deux partenaires étaient absents de la
construction, et bat les méthodes conventionnelles gelées.

Ce serait un résultat réellement intéressant et potentiellement surprenant,
mais encore rétrospectif. Une percée forte demanderait ensuite le maintien de
la règle sur de nouvelles expériences ou sur un lot publié après le gel.
