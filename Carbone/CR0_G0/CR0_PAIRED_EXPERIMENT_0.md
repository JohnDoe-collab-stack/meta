# CR0-P — Préspécification de l'expérience miroir 0

## Statut

**Préspécification révisée, non protocole de paillasse — 18 juillet 2026.**

Ce texte définit les données nécessaires pour lever le NO-GO de CR0. Il ne
donne pas d'instructions de manipulation de réactifs. Toute réalisation devra
être traduite en protocole opérationnel et revue par un laboratoire qualifié,
selon ses procédures institutionnelles et les méthodes de l'article source.

Ce document n'est pas encore une préinscription confirmatoire finale. L'audit
complémentaire a fermé l'accès méthodologique aux deux énantiomères, l'horizon
du pilote et la marge primaire. La qualification des lots, l'incertitude
locale et la taille confirmatoire exigent encore le pilote séparé décrit dans
[`LAB_HANDOFF.md`](./LAB_HANDOFF.md).

## 1. Question primaire

> Deux états contenant la même quantité totale d'alcool autocatalytique et des
> excès énantiomériques de même magnitude mais de signes opposés ont-ils le
> même visible achiral encodé et des ensembles de réponses chirales séparés
> après une intervention identique ?

La question porte sur `CR0-P`, où la graine chirale est le produit
autocatalytique lui-même. Elle ne porte pas sur l'initiateur externe de
HB2019.

## 2. Système d'ancrage provisoire

Le système provisoire est `TMSPyr`, documenté dans M2025-SI. Le supplément
publie notamment un profil pour :

```text
25 mM de TMSPyr-CHO ;
1,5 mM de TMSPyr-OH (1R), ee > 99,9 % ;
40 mM de iPr2Zn ;
toluène anhydre ;
température ambiante.
```

Ces valeurs identifient une condition source ; elles ne constituent pas une
instruction de préparation. M2025-SI publie une séparation préparative des
deux énantiomères du TMSPyr-OH racémique. L'accès méthodologique à la main S
est donc établi, mais la disponibilité et la qualification des lots réels
restent à démontrer par le laboratoire. Les lectures achirale et chirale
doivent également être calibrées localement.

## 3. Bras expérimentaux

Chaque bloc apparié comporte au minimum :

| Bras | Graine | Rôle |
|---|---|---|
| `P-R` | alcool produit, `+e` | témoin formé |
| `P-S` | même alcool produit, `−e` | ombre miroir |
| `P-0` | même quantité totale, mélange racémique | contrôle de symétrie |
| `P-∅` | aucune graine alcool | contrôle de fond |

Contraintes :

```text
abs(e_R) = abs(e_S)
totalAlcohol(P-R) = totalAlcohol(P-S) = totalAlcohol(P-0)
substrate(P-R) = substrate(P-S)
organozinc(P-R) = organozinc(P-S)
conditions(P-R) = conditions(P-S)
intervention(P-R) = intervention(P-S).
```

Le pilote emploie l'ancrage fortement enrichi de M2025-SI : les deux lots
doivent satisfaire `abs(ee) ≥ 99,9 %`, avec une différence entre leurs
magnitudes au plus égale à `0,10` point de ee. Il comporte quatre blocs. Ces
blocs servent à qualifier le dispositif et ne sont pas des données
confirmatoires. Le nombre de blocs de confirmation reste à calculer depuis le
pilote. Les faibles ee constituent une expérience ultérieure, plus
informative mais stochastiquement plus difficile.

## 4. Appariement et randomisation

Un bloc partage :

```text
lots de substrat, alcool, réactif et solvant ;
date ou fenêtre de préparation ;
matériel et calibration ;
température et atmosphère ;
volumes ;
ordre et temps des interventions ;
fenêtres de mesure.
```

L'ordre des bras dans chaque bloc est randomisé avant acquisition. La clé de
randomisation est conservée séparément du fichier visible fourni au
producteur et au vérificateur. Les exclusions techniques admissibles et leurs
preuves sont préenregistrées ; aucun bras ne peut être retiré en fonction de
son ee final.

## 5. Mesures

### M0 — Visible achiral initial

Mesure avant l'intervention discriminante :

```text
quantité totale d'alcool ;
quantité de substrat ;
volume ;
condition et temps ;
identifiant de calibration achirale.
```

M0 ne contient ni le signe de l'ee, ni l'étiquette `P-R/P-S`.

### C0 — Contrôle chiral initial

Une lecture chirale indépendante confirme le signe et la magnitude de l'ee
initial. C0 est placée sous embargo : elle sert à valider l'appariement après
gel des prédictions, pas à construire le visible ou à choisir la transition.

### R(t) — Réponse temporelle

La réponse primaire est l'ee signé de l'alcool **nouvellement formé** à
`t* = 3600 s`. Cet horizon est
figé avant toute série S depuis la fenêtre R publiée, qui s'étend jusqu'à
environ 4000 s pour la condition retenue. Les profils temporels de substrat,
produit R, produit S et sous-produit sont conservés comme réponses secondaires
et comme audit du bilan de matière.

La graine et le produit ont la même identité chimique. Pour éviter qu'un test
positif ne soit la simple relecture de la graine initiale, la réponse est
calculée par bilan énantiomérique :

```text
newR = productR(t*) - productR(0)
newS = productS(t*) - productS(0)
newTotal = newR + newS
newEe = 100 * (newR - newS) / newTotal.
```

Les soustractions et la division portent sur des intervalles avec propagation
des erreurs. Si la borne inférieure de `newTotal` n'est pas strictement
positive, la réponse primaire est indéterminée et le bloc ne peut pas produire
un GO. L'ee total observé est conservé comme mesure secondaire, jamais comme
substitut à `newEe`.

La méthode source annonce une injection FIA-HPLC toutes les 2,3 minutes. Le
laboratoire doit préenregistrer la règle instrumentale qui donne la valeur à
3600 s, sans sélectionner un point selon le résultat. La méthode locale et
cette règle sont gelées avant la confirmation.

## 6. Égalité visible constructive

Les mesures physiques comportent des erreurs ; CR0 ne prétendra pas leur
égalité réelle. Une fonction de discrétisation préenregistrée produit un état
visible fini :

```text
encodeVisible : AchiralMeasurement → CarbonVisible
```

La collision requise est une égalité exacte des encodages :

```text
encodeVisible(M0(P-R)) = encodeVisible(M0(P-S)).
```

Les largeurs de classes sont fixées depuis la calibration instrumentale avant
les résultats de confirmation. Des classes élargies après coup invalident
CR0-H1.

## 7. Critère primaire de séparation

La marge primaire est figée à `ε = 5,0` points de ee. La validation analytique
doit établir une borne d'erreur absolue `δee ≤ 1,0` point. Le GO strict exige,
pour tous les réplicats admissibles, après propagation de `δee` :

```text
NewResponseSet(P-R, t*) ⊆ [ ε, 100]
NewResponseSet(P-S, t*) ⊆ [-100, -ε].
```

Les ensembles incluent l'incertitude instrumentale. Ils doivent donc être
disjoints après propagation des erreurs, pas seulement après arrondissement
des valeurs centrales.

Une seule inversion de signe valide entraîne un NO-GO pour `F-det`. Elle peut
motiver une analyse distributionnelle séparée, mais ne doit pas être exclue ni
reclassée.

## 8. Taille de l'étude

Le pilote comporte quatre blocs indépendants répartis sur au moins deux
séquences instrumentales. Ils ne sont pas inclus dans la confirmation. Le
nombre de blocs confirmatoires n'est pas encore fixé et doit être calculé
depuis :

```text
la variance d'un pilote distinct ;
la fréquence des inversions de signe ;
la marge ε ;
le taux maximal de défaillance technique préenregistré ;
et la revendication exacte F-det ou F-dist.
```

Utiliser uniquement le groupe R publié pour choisir `t*` et une borne de
variance est admissible si ces choix sont gelés avant toute observation du
groupe S de confirmation. Le pilote ne doit pas être réintroduit comme donnée
confirmatoire.

## 9. Producteur et vérificateur

### Producteur

Entrées : visible achiral, intervention et paramètres cinétiques gelés.

Sortie : ensemble fini de classes de réponses à `t*`, avec bornes d'erreur et
hash des paramètres.

### Vérificateur

Entrées : prédiction gelée, trace instrumentale brute et schéma de calibration.

Le vérificateur ne reçoit pas :

```text
le signe attendu ;
le nom du bras ;
la trajectoire choisie par le producteur ;
ni une règle d'exclusion dépendant du résultat.
```

Il vérifie séparément : appariement, invariants, admissibilité de la trace,
collision visible et séparation de réponse.

## 10. Falsification et arrêts

CR0-P strict est réfuté pour ce domaine si :

- M0 ne produit pas le même encodage pour les bras R et S ;
- C0 ne confirme pas des magnitudes initiales appariées ;
- les ensembles de réponses se recouvrent ;
- une inversion de signe valide apparaît ;
- une variable de lot ou de procédure reste confondue avec le signe ;
- les bilans ou calibrations nécessaires ne peuvent pas être reconstruits ;
- le producteur n'est correct qu'après ajustement sur les données de
  confirmation ;
- une baseline visible-seulement obtient la même prédiction.

Une défaillance de manipulation documentée invalide le réplicat selon une
règle préexistante ; elle ne réfute pas la chimie. Si la preuve de défaillance
n'était pas définie avant l'expérience, le réplicat reste dans l'analyse
primaire.

## 11. Paquet de données exigé

```text
protocole opérationnel versionné par le laboratoire ;
lots et certificats analytiques ;
clé de randomisation scellée ;
calibrations achirales et chirales ;
chromatogrammes bruts ;
profils temporels non lissés ;
journal des interventions ;
registre des déviations ;
schéma de données ;
hashes de tous les artefacts ;
prédictions gelées ;
rapport du vérificateur ;
et résultat négatif conservé le cas échéant.
```

## 12. Porte Lean

Une instance Lean chimiquement nommée reste interdite jusqu'à ce que le paquet
confirmatoire fournisse :

```text
sR ≠ sS ;
project sR = project sS ;
une intervention commune ;
deux ensembles finis non vides de réponses ;
leur séparation selon ε ;
et des mises à jour stœchiométriques vérifiées.
```

Lean certifiera alors la structure et le calcul sur les données finies. Il ne
transformera ni la calibration, ni la validité du protocole, ni la réplication
expérimentale en vérités logiques gratuites.

## 13. Décision avant réalisation confirmatoire

L'audit public et la préspécification fixent maintenant :

```text
t* = 3600 s ;
ε = 5,0 points de ee ;
δee admissible ≤ 1,0 point ;
quatre blocs pilotes, hors confirmation.
```

Trois portes restent ouvertes :

| Champ | État |
|---|---|
| voie publiée vers la graine `(1S)` | CONFIRMÉE PAR M2025-SI |
| lots R/S réels et caractérisés | À QUALIFIER PAR LE LABORATOIRE |
| borne locale `δee ≤ 1,0` | À DÉMONTRER PAR CALIBRATION |
| nombre de blocs confirmatoires | À CALCULER DEPUIS LE PILOTE |

Le pilote est prêt à être évalué par un laboratoire qualifié. L'expérience
confirmatoire ne démarre pas tant que les trois dernières portes ne sont pas
fermées et que sa préinscription n'est pas figée et hashée.

## 14. Sources et raccord

- [paquet de provenance CR0-G0](./README.md) ;
- [verdict de recherche de paire](./PAIR_SEARCH.md) ;
- [schéma minimal des données](./DATA_SCHEMA.md) ;
- [audit complémentaire des protocoles publics](./PUBLIC_PROTOCOL_AUDIT.md) ;
- [passation du pilote au laboratoire](./LAB_HANDOFF.md) ;
- [supplément M2025 figé](./sources/Mohler_et_al_2025_supplement.pdf) ;
- [article primaire M2025](https://doi.org/10.1038/s41467-025-62591-3).
