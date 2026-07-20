# Feuille de route d’implémentation

## 1. Règle de conduite

Chaque lot se termine par un artefact exécutable, des preuves, des tests, un audit et une décision de porte. Aucun lot aval ne peut être déclaré terminé si une dépendance amont est ouverte.

Statuts autorisés :

- `not_started` ;
- `in_progress` ;
- `blocked` avec cause reproductible ;
- `passed` avec hashes ;
- `failed` avec contre-exemple.

« Presque fini » et « marche sur l’exemple » ne sont pas des statuts.

## 2. Lot 0 — gel du problème

### Livrables

- copie autonome du présent dossier ;
- `lean-toolchain`, `lakefile.toml`, licence et citation ;
- glossaire des sortes et prédicats ;
- schémas JSON du jeu et des deux certificats ;
- registre de risques ;
- suite des dix contre-modèles sous forme de tables manuelles ;
- manifeste des versions.

### Vérifications

- chaque terme du théorème a un type prévu ;
- aucune hypothèse de séparateur ;
- aucun rang ou horizon externe ;
- portée déterministe finie explicitement annoncée ;
- indépendance du dépôt confirmée.

### Sortie

Porte M0 et A0 au niveau spécification.

## 3. Lot 1 — infrastructure constructive finie

### Ordre

1. `FiniteCarrier` ;
2. égalité booléenne et parcours ;
3. masque d’états ;
4. union, inclusion, cardinalité ;
5. chaîne croissante et stabilisation ;
6. sérialisation canonique de test.

### Tests minimaux

- carrier vide et non vide ;
- complétude ;
- `anyB`/`allB` ;
- `find?` témoin/absence ;
- invariance sous sérialisation aller-retour ;
- pas de doublon.

### Critère de sortie

Tous les lemmes finis utilisés ensuite sont constructifs et audités. Aucun module métier n’est encore requis.

## 4. Lot 2 — jeu public et cible

### Ordre

1. `EffectivePublicRepairGame` ;
2. fibre calculée ;
3. réponses réalisables ;
4. autorisation ;
5. posterior sûr ;
6. patch/provenance ;
7. invariants de conservation ;
8. compilateur de décision ;
9. `CertifiedTarget` et `targetB` ;
10. mesure de conflit d’action.

### Instance de test

Deux mondes, deux actions, une requête parfaitement discriminante, trois états publics. Une seconde instance a deux mondes mais une seule classe d’action et doit être cible immédiatement.

### Critère de sortie

Le booléen de cible est correct et la seconde instance démontre que la décision ne requiert pas l’identification complète.

## 5. Lot 3 — prédécesseur et point fixe

### Ordre

1. liste des réponses réalisables ;
2. requête sûre pour un masque ;
3. témoin calculé de prédécesseur ;
4. correction/complétude du calcul ;
5. monotonie ;
6. couche initiale ;
7. itération ;
8. témoins de première couche ;
9. stabilisation intrinsèque ;
10. minimalité du point fixe.

### Cas obligatoires

- cible immédiate ;
- gain en un pas ;
- requête préparatoire sans réduction immédiate de conflit ;
- boucle perdante ;
- requête sans réponse réalisable ;
- autorisation débloquée après transition.

### Critère de sortie

Porte M1 : masque gagnant et témoins calculés sans oracle positif.

## 6. Lot 4 — certificat gagnant

### Ordre

1. arbre public sémantique ;
2. arbre brut sérialisable ;
3. checker `WIN` ;
4. extraction depuis couches ;
5. finitude par décroissance interne ;
6. correction des feuilles ;
7. rétention du monde réel ;
8. provenance ;
9. préservation des clôtures ;
10. sérialisation.

### Critère de sortie

Porte M2 : toute sortie `WIN` produit une stratégie certifiée indépendante du monde réel.

## 7. Lot 5 — certificat perdant

### Ordre

1. complément calculé ;
2. extraction des contre-réponses ;
3. checker `LOSE` ;
4. absence de cible ;
5. fermeture adversariale ;
6. induction contre tout arbre public ;
7. sérialisation.

### Cas critique

Une requête peut avoir plusieurs réponses réalisables : le certificat doit en choisir au moins une restant perdante pour chaque couple état/requête, jamais prétendre que toutes restent perdues si ce n’est pas vrai.

### Critère de sortie

Porte M4 : obstruction positive complète.

## 8. Lot 6 — caractérisation totale

### Ordre des théorèmes

1. extraction gagnante ;
2. correction `WIN` ;
3. induction arbre vers couche ;
4. complétude `WIN` ;
5. correction `LOSE` ;
6. totalité de `solve` ;
7. exclusivité ;
8. équivalence avec `CertifiedRepairableAt` ;
9. checker soundness ;
10. audit global.

### Critère de sortie

Portes M3 et M5. C’est le premier jalon publiable mathématiquement.

## 9. Lot 7 — posterior exact et indiscernabilité

### Ordre

1. états canoniques par masque ;
2. intersection postérieure ;
3. exactitude ;
4. transcription = fibre ;
5. no-go adaptatif comme corollaire ;
6. corollaire d’homogénéité sous hypothèses fortes ;
7. contre-modèles lorsque chaque hypothèse manque ;
8. famille action-suffisante avant identification.

### Critère de sortie

Le papier peut expliquer précisément quand la formule par indiscernabilité est valide et pourquoi le jeu est la caractérisation générale.

## 10. Lot 8 — coût optimal

### Précondition

Lots 1–7 stables. Coûts strictement positifs dans la première version.

### Ordre

1. coût d’un arbre ;
2. coût pire cas ;
3. solveur dynamique ;
4. correction du coût annoncé ;
5. borne inférieure ;
6. atteinte du minimum ;
7. départage canonique ;
8. extension aux coûts nuls après contraction des composantes ;
9. oracle brut E0d.

### Critère de sortie

Porte M6. Si la preuve des coûts nuls est incomplète, la publication limite explicitement le théorème aux coûts positifs.

## 11. Lot 9 — vérificateur indépendant

### Ordre

1. schémas JSON définitifs ;
2. parseur strict ;
3. jeu canonique ;
4. checker `WIN` ;
5. checker `LOSE` ;
6. erreurs structurées ;
7. tests golden ;
8. vingt mutations ;
9. fuzzing du parseur ;
10. comparaison octet-par-octet.

### Critère de sortie

Porte A1.

## 12. Lot 10 — vérification exhaustive

### Ordre

1. oracle de stratégies brut ;
2. générateur E0 ;
3. manifestes et scripts figés ;
4. E0a, E0b, E0c, E0d ;
5. réduction automatique des divergences ;
6. second générateur ;
7. canonisation ;
8. E1 ;
9. stress E2 ;
10. réplication.

### Critère de sortie

Portes X0–X4 selon le protocole. E0 sans divergence est obligatoire avant la première release.

## 13. Lot 11 — comparaisons formelles

### Ordre

1. ADS ;
2. famille de stricte économie d’action ;
3. belief support ;
4. diagnostic actif ;
5. simulation abstraite sûre ;
6. perte de complétude ;
7. complétude relative ;
8. projection oubliant la réparation ;
9. contre-exemples de sûreté ;
10. audit bibliographique actualisé.

### Critère de sortie

Porte M8. Aucun claim de dépassement ne repose uniquement sur une ressemblance verbale.

## 14. Lot 12 — transfert latent appris

### Ordre

1. trace concrète ;
2. paquet appris sérialisé ;
3. état abstrait reconnu ;
4. vérification de simulation/sur-approximation ;
5. composition avec checker `WIN` ;
6. décision concrète correcte ;
7. abstention sûre ;
8. conservation ;
9. complétude relative ;
10. API Python.

### Critère de sortie

Porte M7. Aucun réseau n’est nécessaire pour compiler le théorème.

## 15. Lot 13 — domaines appris et baselines

### Ordre

1. D1 et oracle ;
2. D2 et oracle ;
3. splits structuraux ;
4. tests anti-fuite ;
5. O0/O1 ;
6. B1–B4 ;
7. M1 ;
8. A1/A2 ;
9. paramétrage ±5 % ;
10. interventions.

### Critère de sortie

Porte E-L1 avant tout pilote de performance.

## 16. Lot 14 — campagne station

### Ordre

1. smoke CPU ;
2. smoke CUDA ;
3. débit ;
4. règle de budget ;
5. trois seeds développement ;
6. sélection unique ;
7. gel ;
8. matrice confirmatoire ;
9. évaluation aveugle ;
10. statistiques ;
11. rapport complet ;
12. réplication.

### Critère de sortie

Portes E-L0 à E-L6. Tout run manquant apparaît dans le tableau final.

## 17. Lot 15 — publication

### Artefacts

- papier ;
- annexe de preuves ;
- dépôt autonome ;
- archive DOI ;
- documentation d’installation CPU/CUDA ;
- corpus E0/E1 ;
- certificats golden ;
- scripts et manifests ;
- modèles confirmatoires ;
- résultats négatifs ;
- déclaration de limites ;
- fiche de reproductibilité.

### Revues internes

- audit mathématique ;
- audit Lean ;
- audit sécurité du checker ;
- audit statistique ;
- audit related work ;
- audit claims ;
- reproduction depuis machine propre.

### Critère de sortie

Toutes les lignes obligatoires de `TRACEABILITY_MATRIX.md` sont `passed`, ou la revendication correspondante est retirée du papier.

## 18. Chemin critique

```text
Lot 0
→ Lots 1–3
→ Lots 4–6       caractérisation totale
→ Lots 7–8       portée et optimalité
→ Lots 9–10      falsification exhaustive
→ Lots 11–12     distinction et transfert IA
→ Lots 13–14     preuve empirique contrôlée
→ Lot 15          publication
```

Les lots 9 et 11 peuvent commencer en parallèle seulement après stabilisation des schémas du lot 6. Les expériences ne doivent pas détourner l’effort du théorème central.

## 19. Priorités si les ressources deviennent limitées

Ordre de conservation :

1. correction et complétude du solveur ;
2. obstruction positive ;
3. audits constructifs ;
4. E0 et mutations ;
5. comparaison formelle ;
6. transfert latent ;
7. coût optimal ;
8. campagne apprise core ;
9. E1/E2 ;
10. extensions probabilistes.

Ne jamais sacrifier 1–4 pour augmenter le nombre de runs neuronaux.

## 20. Estimation de charge, non contractuelle

Pour une personne expérimentée en Lean et ML :

| Bloc | Charge indicative |
|---|---:|
| Lots 0–3 | 3–5 semaines |
| Lots 4–6 | 5–9 semaines |
| Lots 7–8 | 4–8 semaines |
| Lots 9–10 | 3–6 semaines + temps machine |
| Lots 11–12 | 5–9 semaines |
| Lots 13–14 | 4–7 semaines + 3 semaines machine |
| Lot 15 | 3–5 semaines |

Total réaliste : plusieurs mois, avec forte variance selon les difficultés de complétude et d’optimalité. Cette estimation sert à éviter une fausse promesse ; elle ne réduit aucune exigence.

## 21. Première séquence d’implémentation concrète

Les dix premières tâches sont fixées :

1. initialiser le futur dépôt autonome et geler Lean/Mathlib ;
2. implémenter `FiniteCarrier` ;
3. implémenter `StateMask` ;
4. prouver la stabilisation des chaînes croissantes ;
5. définir `EffectivePublicRepairGame` ;
6. définir `Realizable` et son calcul ;
7. définir `CertifiedTarget` et `targetB` ;
8. construire les deux petites instances de test ;
9. implémenter `cpreWitness?` ;
10. prouver sa correction et sa complétude.

Aucune décision supplémentaire n’est requise pour commencer ces tâches.
