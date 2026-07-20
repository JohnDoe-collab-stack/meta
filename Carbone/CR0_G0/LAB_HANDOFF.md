# CR0-PILOT-TMSPYR-01 — Passation au laboratoire

## Décision demandée

Le laboratoire doit répondre à une question bornée :

> Peut-il qualifier deux lots TMSPyr-OH de configurations opposées et produire
> quatre blocs pilotes R/S strictement appariés sous la condition source, avec
> une erreur chirale absolue au plus égale à 1 point de ee ?

Ce pilote ne prouve pas CR0. Il établit si une étude confirmatoire aveugle est
techniquement justifiée et fournit les données nécessaires à sa taille.

## 1. Limite de sécurité

Ce document est une spécification scientifique et documentaire, pas un mode
opératoire. Le système emploie un réactif organozincique sensible à l'air et à
l'humidité. Seul un laboratoire qualifié peut traduire les conditions sources
en procédure, après revue institutionnelle des risques, de la formation, des
équipements, des déchets et des procédures d'urgence. Les méthodes publiées et
les procédures internes du laboratoire font autorité pour l'exécution.

## 2. Condition source à reproduire

Identifiant : `CR0-PILOT-TMSPYR-01`

| Variable | Valeur cible documentaire |
|---|---|
| système | TMSPyr-CHO / TMSPyr-OH |
| substrat initial | 25 mM |
| alcool initial total | 1,5 mM |
| réactif organozincique initial | 40 mM |
| milieu | toluène, condition source M2025-SI |
| température | ambiante, valeur mesurée et archivée |
| horizon primaire | `t* = 3600 s` après l'intervention commune |
| lecture primaire | ee signé de l'alcool nouvellement formé à `t*` |
| seuil de séparation | `ε = 5,0` points de ee |

Les valeurs identifient la condition publiée de la figure supplémentaire 31.
Le laboratoire doit produire sa propre procédure versionnée sans modifier ces
cibles silencieusement. Toute adaptation est une déviation déclarée et peut
entraîner une nouvelle version de l'identifiant.

## 3. Qualification préalable des matériaux

Avant tout bloc pilote, le laboratoire fournit pour les deux mains :

```text
identité chimique ;
assignation absolue indépendante ;
pureté ;
concentration ;
ee signé et incertitude ;
lot, date et méthode ;
chromatogrammes et fichiers instrumentaux bruts.
```

Porte d'entrée proposée :

```text
ee(R) ≥ +99,9 %
ee(S) ≤ -99,9 %
abs(abs(ee(R)) - abs(ee(S))) ≤ 0,10 point de ee.
```

Si la méthode locale ne peut pas justifier ces bornes, le pilote s'arrête avec
un résultat `NOT_READY_MATERIAL`, sans ajustement post hoc du seuil.

## 4. Validation analytique

Le laboratoire estime une borne `δee` sur l'erreur absolue du ee signé. Elle
doit inclure au minimum répétabilité, préparation des échantillons, intégration,
linéarité pertinente, dérive inter-série et classification R/S.

Porte analytique :

```text
δee ≤ 1,0 point de ee
```

La concentration totale d'alcool et celle du substrat reçoivent également des
classes finies, définies avant le pilote. Ces classes alimentent
`encodeVisible`; elles ne peuvent pas être élargies après lecture de R et S.

La réponse primaire n'est pas l'ee du mélange total. Le laboratoire doit
quantifier séparément les concentrations R et S au temps initial et à 3600 s,
puis propager leurs intervalles dans :

```text
newR = R(3600) - R(0)
newS = S(3600) - S(0)
newEe = 100 * (newR - newS) / (newR + newS).
```

La borne inférieure de `newR + newS` doit être strictement positive. Cette
soustraction empêche la graine initiale de suffire, à elle seule, à franchir
le seuil de séparation.

## 5. Plan du pilote

Le pilote contient quatre blocs indépendants, répartis sur au moins deux
séquences instrumentales. Chaque bloc comprend :

| Bras | État initial |
|---|---|
| `P-R` | alcool TMSPyr-OH fortement enrichi R |
| `P-S` | même quantité totale, fortement enrichie S |
| `P-0` | même quantité totale, racémique |
| `P-∅` | sans alcool initial |

Dans un bloc, les bras R et S partagent les lots, la fenêtre de préparation,
la température, le matériel, les cibles de concentration, l'intervention et
les fenêtres de mesure. L'ordre des quatre bras est randomisé avant acquisition.

Le pilote conserve les profils temporels non lissés. La décision primaire se
fait à 3600 s ; les autres temps sont exploratoires. Une règle instrumentale
préenregistrée doit définir comment est obtenue la valeur à cet horizon sans
choisir le point en fonction du résultat.

## 6. Aveuglement minimal

Trois fichiers séparés sont requis :

```text
randomization_key.csv      accès limité au préparateur ;
instrument_blinded.csv     identifiants opaques, sans signe attendu ;
analysis_unblinded.csv     produit seulement après gel du rapport analytique.
```

Le producteur formel ne reçoit ni la clé ni les lectures chirales initiales.
L'analyste classe les traces et propage `δee` avant levée de l'aveugle.

## 7. Sorties obligatoires

Le paquet du laboratoire contient :

```text
protocol.pdf ou protocol.md versionné ;
safety_review_id.txt ;
material_qualification.csv ;
achiral_calibration.csv ;
chiral_calibration.csv ;
randomization_commitment.sha256 ;
instrument_blinded.csv ;
chromatogrammes natifs ;
timecourses_raw.csv ;
deviations.csv ;
pilot_report_blinded.md ;
analysis_unblinded.csv ;
MANIFEST.sha256.
```

Chaque ligne de mesure porte au minimum les champs de
[`DATA_SCHEMA.md`](./DATA_SCHEMA.md). Aucun fichier brut n'est remplacé après
création ; une correction reçoit un nouvel identifiant et conserve l'original.

## 8. Décision de sortie

Le pilote est `READY_FOR_CONFIRMATION` seulement si :

- les deux lots franchissent la qualification ;
- la borne `δee ≤ 1,0` est démontrée ;
- les quatre blocs sont appariables selon les règles gelées ;
- les quatre collisions visibles R/S sont obtenues ;
- `newEe` est calculable avec un dénominateur strictement positif dans chaque
  bras R/S ;
- aucune variable de lot, d'ordre ou de série n'est confondue avec le signe ;
- les traces et déviations sont reconstructibles ;
- une taille confirmatoire peut être calculée sans utiliser le pilote comme
  preuve finale.

La séparation R/S observée dans le pilote est informative, mais elle n'est pas
un GO scientifique. Après le pilote, le protocole confirmatoire est figé,
hashé et exécuté sur de nouveaux lots ou de nouvelles unités expérimentales.

## 9. Réponse attendue du laboratoire

Le premier retour peut tenir en une page et doit donner :

```text
capacité : OUI / NON / À SOUS-TRAITER ;
accès réel aux deux mains : OUI / NON ;
méthode d'assignation absolue ;
borne d'ee réaliste ;
format des données instrumentales ;
écarts nécessaires à la condition source ;
délai et coût estimés par le laboratoire ;
responsable scientifique et responsable sécurité.
```

Un brouillon de demande documentaire aux auteurs est disponible dans
[`AUTHOR_DATA_REQUEST.md`](./AUTHOR_DATA_REQUEST.md). Il n'a pas été envoyé.
