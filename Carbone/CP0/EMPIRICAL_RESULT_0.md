# CP0-EMPIRICAL-0 — première réfutation numérique

## 1. Verdict

La première opérationnalisation prédictive du cadre échoue sur le compartiment
`selection`.

```text
verdict                         = NO-GO-C0-BIR-SELECTION
groupes construction           = 17 130
groupes selection              = 1 428
recouvrement amines            = 0
recouvrement acides            = 0
meilleure MAE baseline         = 14,59081197
meilleure MAE C0-BIR           = 18,50213433
retard C0-BIR                  = 3,91132236 points
held_out_test ouvert           = non
structures produit décodées    = 0
```

Ce résultat est négatif et informatif. La règle `C0-BIR` est réfutée comme
candidate compétitive sur `selection`. Le résultat ne réfute pas le cadre
formel général : il réfute cette traduction numérique particulière du cadre.
Il ne justifie ni ouverture du test final, ni revendication de percée.

## 2. Données effectivement ouvertes

Le lecteur gelé `cp0_target_reader_v1.py` a ouvert successivement :

```text
construction : 17 318 lignes, 17 130 triplets uniques ;
selection    :  1 441 lignes,  1 428 triplets uniques.
```

Les 29 697 enveloppes hors `construction` ont été sautées lors de `T3`. Lors
de l'ouverture `selection`, seules les 1 441 lignes de ce compartiment ont été
décodées. Le lecteur ne possède aucun mode `held_out_test`; les 2 317 lignes du
test final n'ont pas été ouvertes.

Chaque cible est la moyenne rationnelle exacte des répétitions partageant le
triplet `(amine, acide, environnement sémantique)`. Les modèles reçoivent sa
valeur flottante seulement après cette agrégation gelée.

## 3. Règle candidate C0-BIR

`C0-BIR`, pour « Carbon 0 — Bilateral Intrinsic Repair », est la première
hypothèse calculatoire branchée sur la forme du contrat. Elle décompose son
entrée en quatre blocs :

```text
gap evidence
  = différence symétrique des voisinages Morgan des deux substrats
    + différences absolues de descripteurs moléculaires ;

interaction
  = empreintes orientées amine/acide
    + intersection des empreintes
    + produits bilatéraux des descripteurs ;

environmental response
  = empreintes des auxiliaires séparées par groupe fonctionnel
    + rôles, quantités et ordres d'addition ;

execute repair
  = ridge sur la concaténation des trois blocs, puis projection dans [0,100].
```

Les quatre valeurs `alpha ∈ {0,1 ; 1 ; 10 ; 100}` étaient présentes dans le
script avant ouverture de `selection`. Les hash de molécule et d'environnement
servent exclusivement de clés de résolution. Ils ne sont jamais convertis en
variables numériques de `C0-BIR`.

Cette architecture est une opérationnalisation falsifiable inspirée de la
chaîne gap–interaction–réponse–réparation. Ce n'est ni une conséquence
mathématique du Core, ni une loi chimique dérivée de premiers principes. Une
régression conventionnelle demeure l'étape d'exécution de la réparation.

## 4. Baselines

Le même harnais évalue les familles préenregistrées :

```text
B0 : moyenne globale de construction ;
B1 : moyenne de construction par environnement exact ;
B2 : k voisins moléculaires sous le même environnement, k ∈ {1,3,5,10} ;
B3 : ridge sur Morgan amine + Morgan acide + environnement one-hot ;
B4 : ExtraTrees, 500 arbres, six couples de paramètres gelés.
```

`B2` emploie la moyenne des similarités Tanimoto amine–amine et acide–acide,
puis la pondération carrée préenregistrée. La v2 départage les similarités
exactement égales par les identités moléculaires, jamais par leur cible. `B4`
utilise exactement `random_state=0`, `bootstrap=false` et `n_jobs=1`.

## 5. Contrôle bilatéral interne à construction

Avant ouverture de `selection`, les identités de `construction` ont été
réparties déterministiquement en sous-domaines internes. L'entraînement
contient 12 353 groupes, 31 amines et 30 acides. L'évaluation contient 170
groupes, 2 amines et 3 acides, et ne partage aucun partenaire avec cet
entraînement. Sa petite taille interdit d'en faire seule une conclusion forte.

Résultats principaux :

| Méthode | Variante | MAE | RMSE | Spearman |
|---|---:|---:|---:|---:|
| B4 | max_features=0,25 ; leaf=1 | 16,91900736 | 19,99150552 | 0,69926173 |
| B4 | max_features=0,25 ; leaf=2 | 16,97465196 | 19,82936165 | 0,72817948 |
| C0-BIR | alpha=10 | 17,45649738 | 21,11954172 | 0,70638587 |
| B2 | k=1 | 18,18648439 | 24,48933340 | 0,58458786 |
| B1 | moyenne condition | 20,16903258 | 23,49194176 | 0,50163850 |
| B0 | moyenne globale | 22,32366246 | 27,37636258 | 0,00000000 |

Avant calcul de B4, `C0-BIR` semblait battre B2 de 0,73 point. La baseline B4
a annulé ce signal et devance `C0-BIR` de 0,53749002 point. Cette inversion est
la raison pour laquelle une comparaison exhaustive était nécessaire.

## 6. Résultat sur selection

Tous les modèles sont réentraînés sur les 17 130 groupes de `construction`,
puis évalués sur les 1 428 groupes de `selection`. Les deux partenaires
moléculaires sont absents de l'entraînement.

| Rang | Méthode | Variante | MAE | RMSE | Spearman |
|---:|---|---|---:|---:|---:|
| 1 | B2 | k=3 | 14,59081197 | 19,78201794 | 0,74881028 |
| 2 | B4 | max_features=0,25 ; leaf=1 | 14,94441643 | 20,29954993 | 0,71074716 |
| 3 | B4 | max_features=0,25 ; leaf=2 | 15,19832412 | 20,32685406 | 0,70146770 |
| 5 | B2 | k=5 | 15,47628284 | 20,79736809 | 0,70380359 |
| 9 | B3 | alpha=0,1 | 16,89639589 | 21,56387962 | 0,65743564 |
| 13 | B1 | moyenne condition | 17,76706934 | 22,13763469 | 0,63039872 |
| 14 | C0-BIR | alpha=100 | 18,50213433 | 23,95889983 | 0,59197873 |
| 20 | B0 | moyenne globale | 25,56128600 | 28,74813099 | 0,00000000 |

La meilleure variante du cadre est moins bonne que B2 de 3,91132236 points de
MAE et moins bonne que B4 de 3,55771790 points. Elle ne satisfait évidemment
pas le critère préenregistré exigeant une avance d'au moins deux points.

Le résultat interne n'a donc pas généralisé. Le choix `alpha=10`, meilleur dans
le contrôle interne, chute à une MAE de 20,05063710 sur `selection`. La variante
`alpha=100`, moins flexible, devient la meilleure C0-BIR mais reste nettement
derrière les baselines.

## 7. Reproductibilité

Scripts empiriques :

```text
cp0_empirical_comparison_v1.py
SHA-256 = c3b517d2f9d3793a830ef0387316d17948744a7afd36d29f437387883dcbfcaf

cp0_empirical_comparison_v2.py
SHA-256 = ede5dde8c86e3e0c5b4d62e80df41c270f27431598e413e300449752b626ba24
```

La v1 a calculé les six forêts B4, C0-BIR et les autres baselines. Son départage
B2 utilisait par erreur la cible lorsque deux similarités étaient exactement
égales ; ses chiffres B2 sont retirés. La v2 remplace ce départage par les deux
identités moléculaires et recalcule B0–B3 et C0-BIR. Les prédictions B0, B1, B3
et C0-BIR sont inchangées octet pour octet après extraction ; B4 n'est pas
affecté par le défaut et reste pris dans le run v1.

Versions figées :

```text
Python          3.10.12
RDKit           2026.03.4
NumPy           2.2.6
SciPy           1.15.3
scikit-learn    1.7.2
joblib          1.5.2
threadpoolctl   3.6.0
```

Runs et empreintes principales :

```text
T3 construction
  suffixe cibles       20260719T095919Z_sha256-4bdec976...
  cibles SHA-256       9f9c80b1f3fd21e5dcea70b258a4a3c6d57cbe196dca4a42f0d3781d87f9e26b

contrôle construction
  suffixe              20260719T100749Z_sha256-c3b517d2...
  rapport JSONL        6c42e9af5ec07e5f17249f09b30502530f8f4f9d2147b3f411b716951fcd766b
  prédictions          4f96897a5baf9cc5fcbd5c8c4a3b945bfd43888f2abdac11953d3c90fbedbb94

T5 selection
  suffixe cibles       20260719T102545Z_sha256-4bdec976...
  cibles SHA-256       0aa64bf2d7030229cb32993c8f0f24b0768b109225ae9398021b1b0a17923f8e

comparaison selection
  suffixe              20260719T102608Z_sha256-c3b517d2...
  rapport JSONL        a67710f38fae9c9faa796d95c8b376cdea05d2251f2c80e27d6fb11128d1592b
  rapport texte        0304d70b524db37ca2ed9c02b1cf09bb3249055537014443b65a1761ddbcb9c6
  prédictions          6d6bd24589d87480c04ed549a872f50c32d126820c1ac62b410545618893938e
  dépendances          206ec42283276a0d5ff4197ba85077da4eb8a039574b464d0666cb19c175773f

audit B2 corrigé et résultats normatifs B0–B3/C0-BIR
  suffixe              20260719T110304Z_sha256-ede5dde8...
  rapport JSONL        3147565149f34894fe6af4134f0377e49e4a8cc31a6da6409d652b28d51800fa
  rapport texte        1af1942dc6b2e175620c786257644e82b484a1ae1526940a00a6ffd20fc0aef7
  prédictions          67acebea3b00c0a11c80d1548d831591b7bc555a829df522ac443280bc254b87
  dépendances          4fa60fe6eb392edb9b9f4f03925403acdf8b990455e0dd54804af582e6bee389
```

Chaque rapport texte contient la commande complète et le hash du script. Les
copies empiriques figées sont octet pour octet identiques à leur version
historique. Tous les résultats sont produits localement, sans service payant.

## 8. Décision scientifique

`CP0-EMPIRICAL-0` s'arrête à `selection` avec un NO-GO. Ouvrir
`held_out_test` n'apporterait rien à la décision et gaspillerait l'unique test
scellé pour une candidate déjà dominée.

La prochaine candidate doit changer le contenu scientifique de la réparation,
pas seulement sa présentation. En particulier, elle doit introduire une
prédiction mécanistique ou une contrainte dérivée du cadre que B4 ne peut pas
reproduire par interpolation. Toute nouvelle famille devra être enregistrée
comme une expérience distincte ; elle ne pourra plus traiter `selection` comme
un compartiment jamais vu.
