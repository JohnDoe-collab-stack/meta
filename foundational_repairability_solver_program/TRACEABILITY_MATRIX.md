# Matrice de traçabilité

## 1. Usage

Chaque ligne reçoit, pendant l’implémentation :

- statut ;
- chemin de déclaration Lean ;
- test associé ;
- artefact sérialisé ;
- hash du run scientifique si applicable ;
- claim de papier autorisé.

Le tableau initial contient les identifiants stables. Les colonnes de preuve restent `not_started` tant que les fichiers n’existent pas.

## 2. Exigences formelles

| ID | Exigence | Déclaration cible | Test/contre-modèle | Porte | Statut initial |
|---|---|---|---|---|---|
| F01 | carrier fini complet | `FiniteCarrier.complete` | carrier singleton/3 éléments | M1 | not_started |
| F02 | égalité booléenne correcte | `FiniteCarrier.eqb_spec` | permutations | M1 | not_started |
| F03 | réponse réalisable exacte | `realizableResponses_spec` | réponse absente/présente | M1 | not_started |
| F04 | cible booléenne exacte | `targetB_correct` | fibre vide et homogène | M1 | not_started |
| F05 | mesure conflit nulle ssi suffisance | `actionConflictMeasure_eq_zero_iff` | action identique/différente | M1 | not_started |
| F06 | prédécesseur calculé correct | `cpreWitness_sound` | requête sûre | M1 | not_started |
| F07 | prédécesseur calculé complet | `cpreWitness_complete` | requêtes préparatoires | M1 | not_started |
| F08 | monotonie | `cpre_mono` | métamorphique | M1 | not_started |
| F09 | stabilisation intrinsèque | `winningIteration_stabilizes` | chaînes maximales | M1 | not_started |
| F10 | minimalité du point fixe | `winningRegion_least` | oracle E0 | M1 | not_started |
| F11 | extraction WIN | `winningMember_to_tree` | gain 0/1/n pas | M2 | not_started |
| F12 | correction WIN | `solver_win_sound` | mutations WIN | M2 | not_started |
| F13 | monde réel retenu | `winningExecution_retains_world` | posterior exact | M2 | not_started |
| F14 | non-régression | `winningStrategy_preserves` | candidat modifié | M2 | not_started |
| F15 | arbre vers point fixe | `tree_to_winningMember` | oracle arbres | M3 | not_started |
| F16 | complétude WIN | `solver_win_complete` | E0 | M3 | not_started |
| F17 | fermeture région LOSE | `losing_region_closed` | boucle perdante | M4 | not_started |
| F18 | obstruction contre tout arbre | `losing_no_public_tree` | arbre brut | M4 | not_started |
| F19 | correction LOSE | `solver_lose_sound` | mutations LOSE | M4 | not_started |
| F20 | solveur total | `solve_total` | E0 | M5 | not_started |
| F21 | exclusivité | `solve_exclusive` | E0 | M5 | not_started |
| F22 | caractérisation | `certifiedRepairable_iff_winningFixedPoint` | E0 | M5 | not_started |
| F23 | exactitude postérieure | `exactAdvance_iff` | intersections | M7 | not_started |
| F24 | transcription = fibre | `leafFiber_eq_transcriptFiber` | arbres | M7 | not_started |
| F25 | coût recalculé | `optimal_sound` | E0d | M6 | not_started |
| F26 | optimalité globale | `optimal_lower_bound` | oracle coût | M6 | not_started |
| F27 | certificat learned sûr | `acceptedLearnedCertificate_sound` | paquet forgé | M7 | not_started |
| F28 | abstention sûre | `rejectedPacket_noCertifiedAction` | rejet | M7 | not_started |
| F29 | simulation abstraite | `abstractWin_transfers` | abstraction grossière | M8 | not_started |
| F30 | complétude relative | `completeAbstraction_iff` | exact/grossier | M8 | not_started |

## 3. Exigences constructives

| ID | Exigence | Contrôle | Porte | Statut initial |
|---|---|---|---|---|
| C01 | aucun `axiom` | scan + `#print axioms` | M5 | not_started |
| C02 | aucun `Classical` | scan + audit | M5 | not_started |
| C03 | aucun `propext` | scan + audit | M5 | not_started |
| C04 | aucun `Quot.sound` | scan + audit | M5 | not_started |
| C05 | aucun `sorry`/`admit` | scan | M5 | not_started |
| C06 | aucun rang externe | revue des signatures | M3 | not_started |
| C07 | témoins calculés par énumération | revue + extraction | M3 | not_started |
| C08 | unique bloc audit par fichier | script d’audit | M5 | not_started |
| C09 | audit physiquement final | script d’audit | M5 | not_started |
| C10 | build isolé | conteneur/copie fraîche | A0 | not_started |

## 4. Exigences artefact

| ID | Exigence | Preuve attendue | Porte | Statut initial |
|---|---|---|---|---|
| A01 | schéma jeu versionné | JSON Schema + tests | A1 | not_started |
| A02 | schéma WIN versionné | JSON Schema + tests | A1 | not_started |
| A03 | schéma LOSE versionné | JSON Schema + tests | A1 | not_started |
| A04 | checker Lean | théorème soundness | A1 | not_started |
| A05 | checker indépendant | suite golden | A1 | not_started |
| A06 | 20 mutations rejetées | rapport 100 % | A1 | not_started |
| A07 | déterminisme des octets | hashes multi-OS | A1 | not_started |
| A08 | E0 complet | manifeste et corpus | A2 | not_started |
| A09 | E1 modulo isomorphisme | doubles comptes concordants | A2 | not_started |
| A10 | stress E2 | rapport limites | A2 | not_started |
| A11 | DOI et archive | identifiant public | A5 | not_started |
| A12 | réplication extérieure | manifeste tiers | A4 | not_started |

## 5. Exigences expérimentales

| ID | Exigence | Mesure | Porte | Statut initial |
|---|---|---|---|---|
| E01 | D1 valide | oracle et anti-fuite | E-L1 | not_started |
| E02 | D2 valide | oracle et anti-fuite | E-L1 | not_started |
| E03 | baselines appariées | paramètres ±5 % | E-L2 | not_started |
| E04 | budget choisi sans résultat | manifeste débit | E-L3 | not_started |
| E05 | splits gelés | hashes | E-L3 | not_started |
| E06 | 10 seeds complets | tableau cellules | E-L4 | not_started |
| E07 | H1 sûreté | erreurs acceptées | E-L5 | not_started |
| E08 | H2 couverture | IID et quatre OOD | E-L4 | not_started |
| E09 | H3 avantage actif | IC apparié | E-L4 | not_started |
| E10 | H4 regret coût | ratio O1 | E-L4 | not_started |
| E11 | H5 non-régression | violations | E-L5 | not_started |
| E12 | H6 causalité | paires interventions | E-L4 | not_started |
| E13 | résultats négatifs publiés | archive complète | A5 | not_started |
| E14 | réplication learned | 1 domaine, 3 seeds | E-L6 | not_started |

## 6. Exigences de comparaison et claims

| ID | Claim potentiel | Preuve minimale | Formulation autorisée si passée | Statut initial |
|---|---|---|---|---|
| N01 | récupération ADS | R1 formel | généralise la cible d’identification dans la classe encodée | not_started |
| N02 | économie action/identification | R2 + famille | peut terminer sans identifier le monde | not_started |
| N03 | correspondance belief support | R3 | récupère l’atteignabilité sur supports exacts | not_started |
| N04 | transfert abstraction sûre | R4 | garantie abstraite transférée sous simulation | not_started |
| N05 | limite sur-approximation | R5 | correction sans complétude en général | not_started |
| N06 | complétude relative | R6 | équivalence sous abstraction complète | not_started |
| N07 | sécurité additionnelle | R7 | filtre les stratégies violant la réparation | not_started |
| N08 | nouveauté bibliographique | audit daté externe | contribution distinctive selon la recherche déclarée | not_started |
| N09 | portée empirique | E-L0–E-L6 | résultats sur deux familles contrôlées | not_started |
| N10 | résultat majeur | M0–M8 + A0–A5 + revue externe | candidat à contribution majeure | not_started |

## 7. Règle de clôture

Une ligne passe à `passed` seulement avec un lien vers l’artefact exact et son hash. Une ligne `failed` entraîne soit :

- correction et nouveau hash ;
- réduction explicite du claim ;
- suppression du claim.

Aucun texte de publication ne peut convertir `not_started` en résultat.
