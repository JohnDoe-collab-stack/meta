# CR0-G0 — Audit des protocoles publics complémentaires

## Verdict

**Audit documentaire du 18 juillet 2026.**

Les sources primaires supplémentaires ferment une partie importante de la
faisabilité de `CR0-P` :

```text
GO      : une méthode publiée sépare les deux énantiomères de TMSPyr-OH ;
GO      : la condition cinétique TMSPyr retenue et son canal analytique sont
          documentés ;
GO      : la publication annonce trois répétitions par concentration ;
NO-GO   : aucun profil expérimental TMSPyr initialisé par (1S) n'a été trouvé ;
NO-GO   : l'incertitude du ee signé et les traces numériques brutes ne sont
          pas fournies dans les artefacts publics examinés ;
NO-GO   : le couple miroir strict reste donc à produire expérimentalement.
```

La disponibilité des deux mains est établie **comme méthode de préparation**,
pas comme disponibilité d'un stock qualifié dans un laboratoire partenaire.
L'assignation absolue, la pureté, la concentration et l'ee de chaque lot
devront être vérifiés avant le pilote.

## 1. Nouvelles sources figées

| ID | Source | Apport |
|---|---|---|
| `M2025-SI` | Möhler et al., supplément de *Nature Communications* (2025) | séparation préparative des énantiomères TMSPyr-OH, méthode FIA-HPLC, condition cinétique R |
| `HB2018-SI` | Hawbaker & Blackmond, supplément de *ACS Central Science* (2018) | précédents de préparation des produits R et S, HPLC chirale, répétitions de cinétiques avec produit R |
| `HB2019-SI` | Hawbaker & Blackmond, supplément de *Nature Chemistry* (2019) | expériences de brisure de symétrie et lot H miroir à faible ee, déjà audité |

Le supplément `HB2018-SI` a été récupéré par l'API de fichiers
supplémentaires d'Europe PMC. L'archive distante, le PDF qu'elle contient et
son extraction textuelle sont conservés séparément et hashés dans
[`MANIFEST.sha256`](./MANIFEST.sha256).

## 2. Ce que M2025-SI fixe pour TMSPyr

### 2.1 Accès aux deux énantiomères

La section 1.4, pages 4–5 du supplément, indique que les énantiomères du
TMSPyr-OH racémique ont été séparés par HPLC préparative chirale. Cela lève
l'incertitude sur l'existence d'une voie publiée vers les deux fractions.

Cette mention ne fournit toutefois pas, à elle seule :

- un stock disponible pour CR0 ;
- l'assignation absolue indépendante de chaque fraction ;
- les certificats de pureté et d'ee du lot qui sera utilisé ;
- une cinétique initialisée par la fraction S.

### 2.2 Condition d'ancrage

La figure supplémentaire 31, page 43, donne le profil source retenu :

```text
TMSPyr-CHO            25 mM
TMSPyr-OH (1R)         1,5 mM, ee > 99,9 %
iPr2Zn                 40 mM
solvant                toluène
température            ambiante
fenêtre publiée        0–4000 s environ
```

Il s'agit d'un identifiant de condition et non d'une procédure de paillasse.
Le supplément précise par ailleurs que les mesures cinétiques sont répétées
trois fois pour chaque concentration et que leur moyenne est utilisée.

### 2.3 Canal analytique

La section 4.1, pages 39–40, documente une analyse FIA-HPLC du système TMSPyr
avec une injection toutes les 2,3 minutes. Les figures 27 et 28 publient des
régressions de calibration :

```text
TMSPyr-CHO : y = 282,27 x - 29,213 ; R² = 0,9997
TMSPyr-OH  : y = 521,22 x + 203,78 ; R² = 0,9996
```

Ces valeurs montrent la linéarité rapportée pour la quantification. Elles ne
donnent pas une borne suffisante sur l'erreur du **ee signé** : les points de
calibration, résidus, répétitions, dérive et fichiers chromatographiques bruts
restent nécessaires.

## 3. Apport et limite de HB2018-SI

Le supplément de 2018 concerne le système pyrimidine historique, pas le
TMSPyr choisi pour CR0-P. Il apporte néanmoins deux contrôles de plausibilité
expérimentale :

- pages 8–9, les produits alcool R et S sont tous deux préparés et enrichis ;
- pages 15–17, des cinétiques avec produit R initial à 16 % et 79,7 % ee sont
  suivies en double par LC achirale et chirale.

Il ne contient pas le jumeau cinétique S correspondant. Il ne peut donc pas
être fusionné avec M2025-SI pour fabriquer artificiellement une paire. Les
différences de molécule, de température, de concentrations et de protocole
interdisent cette substitution.

Le même supplément note que des ee de l'ordre de 0,5–1 % étaient trop faibles
pour une mesure chirale précise dans le protocole considéré. Cette observation
justifie un seuil primaire CR0 nettement supérieur au voisinage analytique de
zéro ; elle ne constitue pas une estimation d'incertitude pour l'instrument du
futur laboratoire.

## 4. Matrice de fermeture

| Champ CR0-P | Après audit | Preuve encore requise |
|---|---|---|
| voie vers les deux énantiomères TMSPyr-OH | méthode publiée | qualification des lots réels |
| condition R de référence | publiée | reproduction locale |
| canal achiral concentration-temps | publié | calibration locale et données brutes |
| canal chiral R/S | publié en principe | borne locale sur l'erreur du ee |
| profil miroir S | absent | pilote expérimental |
| horizon primaire | figé à 3600 s pour le pilote | horodatage instrumenté |
| marge primaire sur l'alcool nouvellement formé | figée à 5 points de ee | erreur chirale locale ≤ 1 point et bilan R/S propagé |
| nombre confirmatoire | ouvert | variance et taux d'échec du pilote |

## 5. Conséquence

Le dossier est prêt pour une **qualification de laboratoire et un pilote**, pas
pour une affirmation empirique ni pour une instance Lean chimique. La prochaine
action bornée est décrite dans [`LAB_HANDOFF.md`](./LAB_HANDOFF.md).

## 6. Références

- [Möhler et al. 2025](https://doi.org/10.1038/s41467-025-62591-3) ;
- [Hawbaker & Blackmond 2018](https://doi.org/10.1021/acscentsci.8b00297) ;
- [Hawbaker & Blackmond 2019](https://doi.org/10.1038/s41557-019-0321-y).
