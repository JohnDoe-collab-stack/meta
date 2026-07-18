# CW0 — rapport de conformité du quotient de phase

## Verdict

Le premier run figé est conforme à l'export Lean `cw0-two-phase-v1` sur les
deux sources du quotient fini :

```text
sources totales       : 2
sources contrôlées    : 2
divergences           : 0
transitions simulées  : 16
observations produites: 17
statut                : FINITE_PHASE_EXPORT_CONFORMANT
niveau                : SIM0_PLUS_PHASE_CONFORMANCE_NOT_SIM1
```

Ce verdict ne porte ni sur la chimie ni sur l'état Lean complet à histoire non
bornée. Il démontre seulement que l'interprète exécute exhaustivement la table
de phase exportée par Lean.

## Autorité formelle

Le théorème
`Meta.Carbone.CW0.twoPhaseKernel_commutes` établit pour tout point admissible
que l'observation de phase après le pas Core égale le pas du noyau fini. Les
audits de `FiniteKernel.lean` et `ExportTwoPhase.lean` n'affichent aucun axiome.

L'export a été régénéré deux fois, une fois au chemin versionné et une fois en
smoke-test dans `/tmp`; les fichiers étaient identiques octet par octet.

## Artefacts figés

```text
kernel.json SHA-256
34bfc418c7afea9c23c14311a203b351ae19846e54df1568f2f476436fbfeea6

simulateur figé SHA-256
45a74a0e3f3473d760d360c2689db334acca89aafac98e0482206c09a7be08f3

trace JSONL SHA-256
6f6a38ee247068d20175171010cdd90e093bc0d49bf7b579a1b9fcbbdcedb319

rapport TXT SHA-256
09260c93133c4bdf29a994e16a4bb7ea40c3b1a165c27e1333dd1b2ed6e63d20
```

La commande complète, les versions, la plateforme et les heures UTC figurent
dans le rapport TXT du run. Le manifeste du dossier permet de revérifier les
trois artefacts liés au script.

## Résultat calculé

Depuis `chain`, la trace alterne :

```text
chain → bridged → chain → … → chain
```

L'inventaire visible demeure `C2 O1` à chaque observation. `physical_time` et
`generation_index` restent explicitement `null` : le témoin ne définit ni
cinétique ni reproduction.

## Ce qui bloque encore `SIM1`

Le `WorldState` complet conserve chaque événement dans une liste non bornée.
Le présent export ne couvre que la phase, même si sa commutation est prouvée
pour toute histoire. Un statut `SIM1` du monde complet exigerait soit un domaine
fermé réellement fini conservant toute la sémantique revendiquée, soit un
protocole de certificats couvrant explicitement l'histoire non bornée.

Une comparaison à la réalité exige en plus une instance chimique documentée,
des paramètres et unités, un observable calibré et des prédictions gelées sur
des données tenues à l'écart. Rien de cela n'est revendiqué ici.
