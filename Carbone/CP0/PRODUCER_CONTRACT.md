# CP0-PRODUCER-C0 — contrat intrinsèque et lecteur de cible gelé

## 1. Verdict exact

Au 19 juillet 2026, la frontière entre entrée, producteur et cible est
implémentée avant toute ouverture de rendement réel.

```text
CP0-PRODUCER-C0 = CONTRACT_QUALIFIED
CP0-TARGET-T1   = SYNTHETIC_READER_QUALIFIED
CP0-TARGET-T2   = SYNTHETIC_TARGET_READER_FROZEN

rendements réels décodés = 0
source ORD réelle ouverte par T2 = non
manifest I0 ouvert par T2 = non
producteur chimique ajusté = non
prédiction empirique produite = non
```

Ces verdicts établissent un contrat calculable, une chaîne causale positive et
un lecteur de cible strict. Ils ne démontrent ni l'exactitude d'une loi de
rendement, ni la supériorité du cadre, ni une propriété nouvelle du carbone.

## 2. Surface d'entrée autorisée

[`ProducerContract.lean`](./Lean/ProducerContract.lean) définit
`IntrinsicInputView`, obtenu par l'unique `admissibleProjection` depuis
`InputOrganization`. Cette vue contient exactement :

```text
structure moléculaire complète de l'amine ;
structure moléculaire complète de l'acide ;
quantités exactes des deux substrats ;
auxiliaires résolus, rôles et quantités ;
étapes d'addition ordonnées ;
condition physique.
```

Elle ne possède aucun champ pour un identifiant de dataset, un identifiant de
réaction, une position de plaque, un hash de molécule, un hash de condition,
un index de ligne, un produit observé ou un rendement observé. Les structures
moléculaires ne sont pas remplacées par leurs clés de résolution.

Cette absence est une garantie de type sur l'exécution : une valeur interdite
ne peut pas être passée par cette interface. Elle ne prouve pas à elle seule la
provenance honnête de constantes ou de paramètres définis ailleurs. Le gel du
code et l'audit des données d'ajustement restent donc obligatoires.

## 3. Sortie exacte et abstention

`BoundedYield` représente un rationnel exact `numérateur / dénominateur` avec
deux preuves internes :

```text
0 < dénominateur ;
numérateur ≤ 100 × dénominateur.
```

`YieldPrediction` vaut soit ce rendement borné, soit une abstention explicite.
Le constructeur calculable `boundedYield?` accepte exactement les valeurs
valides. Les témoins par réduction acceptent `0` et `100`, rejettent `101` et
rejettent le dénominateur nul.

Le contrat n'emploie donc ni flottant, ni troncature, ni imputation pour
fabriquer une sortie interne. Une future méthode numérique devra convertir son
résultat vers ce domaine de façon explicite et auditée.

## 4. Chaîne causale imposée au producteur

`CoreYieldProducer` impose la dépendance suivante :

```text
IntrinsicInputView
  → GapEvidence
  → Interaction
  → EnvironmentalResponse
  → RepairOf réponse
  → executeRepair
  → YieldPrediction.
```

À chacune des quatre étapes intermédiaires, le producteur doit fournir une
liste finie et explicite de candidats, l'objet effectivement sélectionné et
une preuve constructive de son appartenance à cette liste.

`RepairOf` dépend du gap, de l'interaction et de la réponse environnementale
effectivement sélectionnés. Il n'existe pas de champ indépendant `predict` ou
`next` pouvant court-circuiter cette chaîne. `canonicalCausalTrace` conserve
les quatre preuves de sélection, et `run` ne peut produire une valeur qu'en
appelant `executeRepair` sur la réparation obtenue. Le théorème
`run_eq_executeRepair` est prouvé par réduction définitionnelle.

Cette structure fixe la forme endogène exigée par le Core. Elle n'est pas
encore une instanciation chimique de `GapRepairAlgebra` et ne fournit aucune
règle moléculaire. `syntheticProducer`, dont toutes les étapes sont `Unit` et
la sortie constante vaut 50 %, sert uniquement à calculer le branchement de
bout en bout. Le présenter comme un prédicteur serait faux.

Le build Lean et l'audit final ne rapportent aucun axiome, notamment aucune
dépendance à `Classical`, `propext` ou `Quot.sound`.

## 5. Contrat strict du lecteur de cible

[`cp0_target_reader_v1.py`](./scripts/cp0_target_reader_v1.py) est un lecteur
protobuf brut, limité à la bibliothèque standard. Ses seuls modes réels sont
`construction` et `selection`. Aucun mode `held_out_test` n'existe.

En mode réel, avant tout décodage sélectionné, il exige l'identité exacte de la
source ORD et du manifest I0 : taille, SHA-256, identité du dataset, nombre de
réactions, colonnes du manifest et unicité des hash de réaction. Pour chaque
réaction, il hash l'identifiant et consulte le compartiment gelé. Les
enveloppes de cibles des autres compartiments ne sont pas désérialisées.

Pour une ligne du compartiment demandé, le lecteur exige exactement :

```text
1 ReactionOutcome ;
1 produit ;
desired = vrai ;
rôle PRODUCT ;
1 mesure de type YIELD ;
1 cible Percentage ;
1 valeur float32 finie dans [0, 100].
```

Les champs inconnus sur les messages inspectés, les cibles numériques
alternatives et toute multiplicité ambiguë provoquent un échec. Le `float32`
est converti en rationnel binaire exact. Les lignes sont ensuite agrégées par
le triplet gelé `(amine, acide, environnement sémantique)` ; les répétitions
reçoivent une moyenne arithmétique exacte, puis l'export CSV gzip est trié et
déterministe.

## 6. Audit synthétique T1

Le corpus synthétique est construit directement en messages protobuf binaires
en mémoire. Les six lignes positives donnent cinq groupes :

```text
bornes 0 et 100 acceptées ;
deux répétitions 10 et 30 agrégées exactement en 20 ;
float32 0,1 conservé exactement comme 13421773 / 134217728 ;
50,125 conservé exactement comme 401 / 8.
```

Les 22 cas négatifs sont tous rejetés : valeurs sous 0 et au-dessus de 100,
NaN, infini, outcome absent ou dupliqué, produit absent ou dupliqué, produit
non désiré, rôle incorrect, rendement absent ou dupliqué, Percentage absent,
valeur Percentage dupliquée, mauvais wire type, cible numérique alternative,
identifiant de réaction absent ou dupliqué, champ Reaction inconnu, message
tronqué, réaction absente du manifest et tentative de mode `held_out_test`.

Un message dont la cible est volontairement malformée mais dont le compartiment
est `held_out_test` est traversé en mode `construction` sans décoder cette
cible. Cela vérifie directement la propriété de non-ouverture par compartiment.

## 7. Gel reproductible T2

Suffixe commun du run :

```text
20260719T094729Z_sha256-4bdec976e5920568e9d0ea401ded8ff85bc6bdecb3257d3acb05b220694c07a2
```

Empreintes :

```text
script figé          4bdec976e5920568e9d0ea401ded8ff85bc6bdecb3257d3acb05b220694c07a2
cibles synthétiques  d38a1fe7384771b48974f90f761a4ef439abd9940f0936793587b98893390bb6
rapport JSONL        e6ae347e83897500d71ff4266d8610bf0e6bb76c4c4193bcc334220d97485b2f
rapport texte        b19e752c5ce5158370f3cfea4ec1f1a6bdbbb1b6306944f0e9e291202346eb0f
dépendances          254e1f85e2624b09bf0652e83aea829edacbe5746f8ba1719afcb580c9553696
```

Le rapport texte contient la commande complète et le hash du script exécuté.
La copie exécutée porte le même suffixe que toutes ses sorties. L'environnement
est CPython 3.10.12 et le lecteur ne dépend que de la bibliothèque standard.

Le verdict figé est `T2_SYNTHETIC_TARGET_READER_FROZEN` : 6 lignes positives,
5 groupes, 22/22 rejets attendus, zéro source réelle ouverte, zéro manifest I0
ouvert et zéro cible réelle décodée.

## 8. Ce qui est acquis et ce qui reste réfutable

On sait désormais représenter une entrée réelle complète sans clé de corpus,
contraindre la forme d'un producteur, représenter exactement sa sortie et lire
une future cible sans ouvrir le test scellé. C'est une infrastructure nécessaire
à une comparaison loyale, pas un résultat scientifique sur le carbone.

Une première opérationnalisation, C0-BIR, a depuis été ajustée sur
`construction` et évaluée sur `selection`. Elle obtient 18,5021 de MAE contre
14,5908 pour la meilleure baseline et reçoit donc le verdict
`NO-GO-C0-BIR-SELECTION`. Le protocole, les chiffres et leurs limites sont
consignés dans [`EMPIRICAL_RESULT_0`](./EMPIRICAL_RESULT_0.md). Le test final
reste scellé.
