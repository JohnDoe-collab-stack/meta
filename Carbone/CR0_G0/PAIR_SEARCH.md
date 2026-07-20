# CR0-G0 — Recherche du couple R/S apparié

## Verdict

**NO-GO sur les données publiques examinées pour la version stricte de CR0.**

Un candidat exact existe pour l'entrée, et des candidats fortement séparés
existent pour la sortie, mais aucun groupe ne réalise les deux propriétés à la
fois avec les champs disponibles.

```text
appariement miroir exact + futur déterministement séparé
                         = non trouvé.
```

Ce verdict ne réfute ni l'autocatalyse de Soai, ni l'amplification chirale. Il
réfute uniquement l'affirmation que le témoin exact exigé par CR0 est déjà
constructible à partir des trois suppléments publics audités.

## 1. Test de M2025-SI

Le supplément 2025 fournit de nombreux profils expérimentaux pour quatre
systèmes et une modélisation détaillée. Les profils expérimentaux sélectionnés
emploient des alcools initiaux `(1R)` à `ee > 99,9 %`. Les cycles R et S du
modèle sont symétriques, mais une symétrie de modèle n'est pas une expérience
miroir.

Résultat :

```text
collision projective conceptuelle : oui ;
paire expérimentale initiale R/S : non trouvée ;
transition cinétique exploitable : oui, après extraction quantitative ;
témoin CR0 strict : non.
```

## 2. Test de HB2019-SI

La table supplémentaire 1 contient les résultats de toutes les expériences de
brisure de symétrie déclarées par les auteurs.

### Groupe A

Conditions tabulées communes : lot A, trois injections, `1,6 mmol`
d'aldéhyde ajouté.

```text
entrée R : 96 % ee, 11 expériences, produit final de +17,1 à +100,0 % ee ;
entrée S : 85 % ee, 11 expériences, produit final de −63,4 à −2,5 % ee.
```

Les futurs sont séparés par le signe dans la table, mais les entrées ne sont
pas miroirs en magnitude. Le groupe A échoue au critère d'appariement strict.

### Groupe B

Conditions tabulées communes : lot B, trois injections, `1,6 mmol`
d'aldéhyde ajouté.

```text
entrée R : 52 % ee, 11 expériences, produit final de +73,4 à +90,1 % ee ;
entrée S : 39 % ee, 11 expériences, dix ee finaux négatifs et un +19,7 %.
```

La séparation reste forte mais les magnitudes initiales diffèrent. Le groupe B
échoue lui aussi au critère d'appariement strict.

### Groupe H

Conditions tabulées communes : lot H, quatre injections, `4,1 mmol`
d'aldéhyde ajouté.

```text
entrée R : 0,10 % ee, 12 expériences, produit final de −65,6 à +76,1 % ee ;
entrée S : 0,10 % ee, 12 expériences, produit final de −59,3 à +19,6 % ee.
```

Les magnitudes initiales et les interventions tabulées sont appariées. Le
groupe H est donc le meilleur candidat à CR0-H1. Cependant, les plages de
réponse se recouvrent largement ; les deux signes finaux apparaissent dans les
deux groupes. Il échoue à la séparation déterministe CR0-H2.

De plus, la table ne publie pas dans ses colonnes la quantité totale
d'initiateur, le volume, la température ou l'intervalle exact des injections.
Ces informations doivent être récupérées dans le texte principal ou les
protocoles référencés avant de déclarer l'égalité complète de projection.

## 3. Test de HB2018-SI

Le supplément 2018 fournit des précédents de préparation des produits alcool
R et S du système pyrimidine et des cinétiques en double initialisées par le
produit R à 16 % ou 79,7 % ee. Aucun profil apparié initialisé par le produit S
n'a été trouvé.

Ce supplément ne ferme donc pas le témoin strict. Il ne peut pas davantage
être apparié aux données TMSPyr de 2025, car l'identité chimique et les
conditions diffèrent.

## 4. Changement de système implicite

HB2019 ne fournit pas exactement l'état initial prévu dans le contrat
original. La variable chirale est un initiateur isotopiquement chiral, tandis
que CR0 avait retenu comme mémoire initiale l'alcool produit autocatalytique.

Adopter HB2019 créerait donc une variante :

```text
CR0-P : graine = produit autocatalytique chiral ;
CR0-I : graine = initiateur chiral externe.
```

`CR0-I` peut étudier la brisure de symétrie et une réponse distributionnelle,
mais il affaiblit l'endogénéité de la mémoire. Il ne doit pas remplacer
silencieusement `CR0-P`.

## 5. Premier verdict sur les hypothèses

| Hypothèse | Verdict | Justification |
|---|---|---|
| `CR0-H1`, collision projective stricte | PROVISOIRE | groupe H apparié dans les colonnes publiées, champs expérimentaux encore manquants |
| `CR0-H2`, futurs disjoints | NO-GO | les réponses du groupe H se recouvrent |
| `CR0-H3`, dépendance causale du signe | OUVERT | tendance compatible, mais exactitude du protocole et analyse préenregistrée absentes |
| `CR0-H4`, gain autocatalytique | DOCUMENTÉ | mécanisme et profils publiés, mais pas encore réencodés dans CR0 |
| `CR0-H5`, concordance exécutable tenue à l'écart | NO-GO | producteur et jeu tenu à l'écart non construits |

## 6. Expérience minimale manquante

Pour débloquer `CR0-P`, il faut une expérience explicitement appariée :

```text
même alcool autocatalytique ;
même quantité totale et même |ee| initial ;
signes R et S opposés ;
mêmes substrat, réactif, solvant, volume et température ;
même ordre et même temps d'ajout ;
lecture achirale initiale confirmant le même visible ;
lecture chirale initiale conservée hors du contrôleur visible ;
plusieurs réplicats ;
horizon et seuil de séparation préenregistrés ;
contrôle racémique ;
données temporelles brutes R et S.
```

Deux sorties sont acceptables :

1. réponses disjointes selon la marge préenregistrée : GO pour CR0 strict ;
2. réponses recouvrantes mais distributions différentes : résultat
   scientifique possible, nécessitant un contrat `CR0-distributionnel` séparé.

## 7. Décision immédiate

Ne pas écrire maintenant un théorème Lean appelé « Soai certifié ». La prochaine
action licite est l'une des suivantes :

```text
A — obtenir le protocole complet et les données brutes HB2019 ;
B — concevoir la paire expérimentale CR0-P manquante ;
C — ouvrir explicitement CR0-I comme référence stochastique distincte ;
D — basculer le niveau A vers le réseau bistable de bases de Schiff.
```

Pour préserver la cible de percée, l'option recommandée est `B`, avec `A` en
parallèle documentaire. `C` est utile scientifiquement mais ne doit pas être
présenté comme une fermeture matérielle autonome.
