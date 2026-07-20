# CP0-EMPIRICAL-1 — voisinages réactifs et diagnostic multiscalaire

## 1. Verdict

La première candidate explicitement centrée sur les atomes réactifs ne bat
pas la meilleure baseline. Un mélange local–global fait mieux en valeur
ponctuelle, mais échoue aux deux critères préenregistrés.

```text
verdict C1                    = NO-GO-C1-RC-KNN-SELECTION
verdict protocolaire C2       = NO-GO-PROTOCOL-C2-MS-REPAIR-SELECTION
groupes construction          = 17 130
groupes selection             = 1 428, 19 paires
meilleure baseline B2         = 14,59081197 MAE
meilleure C1 centre seul      = 14,78209735 MAE
C2 local–global               = 13,63890761 MAE
gain ponctuel C2              = 0,95190435 point
IC 95 % de différence C2−B2  = [-2,54173868 ; +0,68983065]
gain exigé                    = au moins 2 points
held_out_test ouvert          = non
```

C2 est un signal de développement, pas un succès. Son gain est inférieur à
deux points, son intervalle contient zéro et sa configuration a été choisie
après ouverture de `selection`. Il serait scientifiquement incorrect d'ouvrir
le test final ou de parler de prédiction confirmée.

## 2. Question réellement testée

L'expérience pose une question plus étroite que « le cadre calcule-t-il la
chimie du carbone ? » :

> Pour un couplage amide sous un environnement déjà connu, la proximité des
> voisinages du N nucléophile et du carbone carboxylique suffit-elle à
> transférer les rendements vers deux partenaires moléculaires absents de
> l'apprentissage ?

Cette question est réfutable sur `selection`, car aucune amine ni aucun acide
de ce compartiment n'apparaît dans `construction`. Elle ne teste pas un
environnement inédit, une transformation inconnue, ni une dynamique chimique
de premiers principes.

## 3. Détection intrinsèque des centres

Le centre amine est l'unique atome qui satisfait simultanément :

```text
numéro atomique = 7 ;
non aromatique ;
charge formelle = 0 ;
au moins un hydrogène total.
```

Le centre acide est le carbone de l'unique motif :

```text
[C;X3](=[O;X1])[O;H1,-1]
```

Ces règles sont évaluées sur les seules structures d'entrée. Elles détectent
exactement un centre dans chacune des 70 amines et chacun des 66 acides. La
répartition auditée est :

| Domaine | Classe | Espèces |
|---|---|---:|
| amine | aniline | 38 |
| amine | aliphatique primaire | 17 |
| amine | aliphatique secondaire | 11 |
| amine | sulfonamide | 4 |
| acide | aromatique | 38 |
| acide | aliphatique | 28 |

La règle accepte volontairement les quatre sulfonamides : ils sont porteurs du
N réactif déclaré par les entrées ORD, même si leur nucléophilie est diminuée.
Aucune cible, structure produit ou identité de compartiment n'intervient dans
le choix des centres.

## 4. Candidate C1-RC-KNN

Pour chaque centre, C1 calcule une empreinte Morgan enracinée uniquement sur
l'atome réactif, avec rayons `1`, `2` ou `3` et 2 048 bits. Ce n'est pas
l'empreinte de la molécule entière.

La traduction opérationnelle de la chaîne du cadre est :

```text
gap
  = dissemblance de Tanimoto entre voisinages N–N et Ccarboxyle–Ccarboxyle ;

interaction bilatérale
  = moyenne, minimum (« bottleneck ») ou moyenne géométrique
    des deux similarités ;

réponse au milieu
  = transfert autorisé seulement sous le même environnement intrinsèque exact ;

réparation
  = moyenne des k rendements voisins, pondérée par max(similarité, 10⁻⁶)²,
    avec k ∈ {1, 3, 5, 10}.
```

Les identités hachées ne sont que des clés de résolution et de départage
déterministe. Elles ne deviennent jamais des variables numériques. Le milieu
est un verrou exact : C1 ne sait donc pas extrapoler vers une condition
nouvelle.

C1 reste une hypothèse numérique inspirée par le cadre. Une empreinte Morgan
et un transfert k-NN sont des outils conventionnels ; aucune preuve Lean ne
dérive leur métrique ou leurs rendements du Core.

## 5. Diagnostic C2-MS-REPAIR

C1 perd l'information portée par le squelette au-delà du rayon réactif. C2
teste si les échelles locale et globale portent des erreurs complémentaires :

```text
P_global = B2, k=1, empreintes des molécules entières ;
P_local  = C1, rayon=3, interaction moyenne, k=10 ;
P_C2     = 0,4 × P_global + 0,6 × P_local.
```

Cette configuration a été choisie lors d'une exploration de `selection` déjà
ouvert. Le script gelé et son rapport portent explicitement
`c2_configuration_selected_after_selection_was_opened = true`. C2 ne peut donc
être jugée que sur un compartiment ultérieur resté fermé. En outre, sa
composante globale interdit de présenter son gain comme une dérivation propre
du Core : c'est un diagnostic multiscalaire.

## 6. Contrôle bilatéral interne

Le split déterministe de `construction` entraîne sur 12 353 groupes et évalue
sur 170 groupes, avec zéro recouvrement des amines et des acides.

| Méthode | Variante | MAE | RMSE | Spearman |
|---|---|---:|---:|---:|
| B2 | k=1 | 18,18648439 | 24,48933340 | 0,58458786 |
| B1 | moyenne condition | 20,16903258 | 23,49194176 | 0,50163850 |
| C2 | mélange fixé | 21,10081269 | 25,38223769 | 0,51747974 |
| C1 | rayon=2, moyenne, k=10 | 25,21255750 | 29,97111226 | 0,28941079 |

C1 est dominée de 7,02607311 points et C2 de 2,91432830 points par le
meilleur B2 interne. Le petit ensemble de 170 groupes est instable, mais il
interdit toute lecture triomphale du résultat de `selection`.

## 7. Résultat sur selection

Les modèles utilisent les 17 130 groupes de `construction`, puis prédisent les
1 428 groupes de `selection`. Le recouvrement est nul pour les deux domaines de
partenaires.

| Méthode | Variante | MAE | RMSE | Spearman |
|---|---|---:|---:|---:|
| C2 | global k=1 ; local r=3, moyenne, k=10 ; poids local=0,6 | 13,63890761 | 18,97460637 | 0,74482374 |
| B2 | k=3 | 14,59081197 | 19,78201794 | 0,74881028 |
| C1 | rayon=3, géométrique, k=10 | 14,78209735 | 19,80161048 | 0,71887874 |
| C1 | rayon=3, moyenne, k=10 | 14,84300342 | 19,87829254 | 0,71593664 |
| B1 | moyenne condition | 17,76706934 | 22,13763469 | 0,63039872 |

Le centre seul arrive à 0,19128538 point de B2. Cela montre que les voisinages
réactifs contiennent une grande partie du signal utile, mais pas qu'ils
suffisent. C2 améliore la MAE ponctuelle de 0,95190435 point et la RMSE de
0,80741157 point. Sa corrélation de rang reste légèrement inférieure à B2.

## 8. Test statistique et décision

Le bootstrap apparié utilise les 19 paires amine–acide de `selection` comme
grappes, 10 000 rééchantillonnages et la graine `0`. La quantité rééchantillonnée
est :

```text
|erreur C2| − |erreur meilleure B2|.
```

Le résultat est `[-2,54173868 ; +0,68983065]`. Les deux portes du protocole
échouent :

```text
gain MAE observé >= 2 points       : faux ;
borne supérieure IC 95 % < 0      : faux.
```

Le verdict demeure donc `NO-GO-PROTOCOL-C2-MS-REPAIR-SELECTION`. Les 2 317
lignes et 30 paires de `held_out_test` restent scellées.

## 9. Ce que le résultat démontre — et ne démontre pas

Il démontre empiriquement, sur le domaine de développement ouvert, que :

1. une règle locale définie sans cible peut couvrir tous les centres réactifs
   de CP0 ;
2. le voisinage réactif seul est presque compétitif avec B2 sur `selection`,
   mais échoue nettement sur le contrôle interne ;
3. les informations locales et globales sont complémentaires sur `selection`.

Il ne démontre pas que le Core prédit un rendement, une transformation ou une
propriété du carbone. Il ne démontre pas non plus que le gain C2 généralisera :
la sélection est adaptative, l'intervalle contient zéro, la marge exigée n'est
pas atteinte et C2 contient une méthode conventionnelle.

## 10. Ingrédient manquant maintenant identifié

La prochaine candidate ne doit pas ajouter une autre moyenne de fingerprints.
Elle doit remplacer la similarité par des quantités chimiques intrinsèques
reliées au centre et au milieu :

```text
attaque      : charge locale, classe N, conjugaison et accessibilité stérique ;
activation   : classe mécanistique de l'agent, additif, base et ordre d'ajout ;
couplage     : compatibilité acide–amine et maillon limitant explicite ;
réparation   : fonction totale gelée de ces trois états vers [0,100].
```

Cette fonction devra être écrite comme une nouvelle candidate, ajustée sur
`construction` et `selection` considérés ensemble comme développement, puis
franchir le seuil de deux points et l'intervalle de confiance sur un contrôle
de développement avant toute demande d'ouverture du test final. Tant qu'elle
n'est pas reliée formellement aux structures du Core, son statut restera
« opérationnalisation », pas « conséquence du cadre ».

## 11. Reproductibilité

Script historique :

```text
cp0_reactive_center_comparison_v1.py
SHA-256 = 5848ca3045b40993416ee38dbea6adf372ea108d9953fafb106fa5ac93882296
```

Copie et suffixe figés :

```text
20260719T114249Z_sha256-5848ca3045b40993416ee38dbea6adf372ea108d9953fafb106fa5ac93882296
```

Artefacts du contrôle construction :

```text
rapport JSONL   61607065d677208cca829c485f82c00f6dada92d3ceecef8cec6702b897fe9aa
rapport texte   05f4e61d3b9a99f5f3b58e38c7d4ed374f835652d6b4c77305a2dabab00b27f5
prédictions     83c2514234af93a7a59a58c02b56fc0dc8793e407df1d711ce8f811600c3c01d
dépendances     a090ee5cd60190d8e8016855537202b1c56ed84df0901e018a10e45b0264288d
```

Artefacts de `selection` :

```text
rapport JSONL   7cccc53c9fe7715256c7b1ab1040e153671338f0d9f971c9bc8ea9dbfbccc3ce
rapport texte   acc221c056400a82f35b4d2643f3d4dd6f6b137cd83b15d5910857d2b59d138c
prédictions     9c513d8f26c09c34feb777bf263836f5bf202bc3e22f8650e8eb345cbac628d2
dépendances     648b5fd3eab1a63cf8583cc55f6b47fd56897544431e0a223ad1c801df746ce5
```

Les rapports texte contiennent la commande complète et le hash du script. Le
script charge B2 depuis la copie v2 hashée
`ede5dde8c86e3e0c5b4d62e80df41c270f27431598e413e300449752b626ba24`.
Les versions Python, RDKit, NumPy, SciPy et scikit-learn ainsi que les hashes de
leurs wheels sont repris dans chaque fichier de dépendances.
