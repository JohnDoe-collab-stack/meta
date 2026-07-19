# Scripts CP0

Règle d'immuabilité : chaque variante ayant produit un résultat est conservée.
Ne modifier aucun de ces fichiers ; créer une nouvelle version.

```text
ord_metadata_audit.py  audit M0 exécuté sous copie figée ;
ord_input_audit_v1.py  smoke-test initial, sans cache ;
ord_input_audit_v2.py  smoke-test avec cache moléculaire ;
ord_input_audit_v3.py  correction charge atomique/nette, premier run scientifique ;
ord_input_audit_v4.py  check float32 et borne CW1 explicite, run normatif I0.
ord_canonical_import_v1.py  smoke initial, sans marquage des centres potentiels ;
ord_canonical_import_v2.py  centres assignés/non assignés, audit externe 194/194 ;
ord_canonical_import_v3.py  essai de séparateurs explicites, rendu Lean invalide ;
ord_canonical_import_v4.py  constructeurs Lean explicites, limites par défaut insuffisantes ;
ord_canonical_import_v5.py  constructeurs et budgets Lean explicites, run normatif 194/194 ;
ord_environment_import_v1.py  premier smoke-test des 94 environnements ;
ord_environment_import_v2.py  traçage exact du hash de reaction_id ;
ord_environment_import_v3.py  domaines 70 amines / 66 acides, rendu Lean imbriqué invalide ;
ord_environment_import_v4.py  constructeurs explicites, parenthésage Option incomplet ;
ord_environment_import_v5.py  rendu Lean compilable, run normatif 94/94 ;
cp0_target_reader_v1.py  lecteur strict et audit synthétique normatif T1–T2.
cp0_empirical_comparison_v1.py  comparaison initiale C0-BIR/B0–B4 ; B2 supersédé ;
cp0_empirical_comparison_v2.py  départage B2 indépendant de la cible, run normatif B0–B3/C0.
cp0_reactive_center_comparison_v1.py  C1 centres réactifs et diagnostic C2 multiscalaire.
```

Le run normatif I0 est la copie `ord_input_audit_20260719T073503Z_...py`
conservée dans [`frozen_runs`](../frozen_runs/). Son hash est
`c8ebfeb5d1884789c846e4336ea03b1a4312a07304e47f0deb5f6ddce10a5a9f`.

Le run normatif d'import moléculaire est la copie
`ord_canonical_import_20260719T085207Z_...py`. Son hash est
`df6b9ce0236f0ae755fdf17d125ecf4c56b53e6fd67d1da3007190fd69ff5f84`.

Le run normatif d'import des environnements est la copie
`ord_environment_import_20260719T091321Z_...py`. Son hash est
`ba12c0482fd4a541d77cc4e90232a8ccf53e298feafaae30d547db53a1d65e37`.

Le run normatif du lecteur de cible synthétique est la copie
`cp0_target_reader_20260719T094729Z_...py`. Son hash est
`4bdec976e5920568e9d0ea401ded8ff85bc6bdecb3257d3acb05b220694c07a2`.
Il vérifie 6 lignes positives, 5 groupes et 22/22 rejets sans ouvrir la source
ORD, le manifest I0 ni une cible réelle. Ses seuls modes réels sont
`construction` et `selection` ; aucun mode `held_out_test` n'est disponible.

La v1 a pour hash
`c3b517d2f9d3793a830ef0387316d17948744a7afd36d29f437387883dcbfcaf`.
Ses copies `20260719T100749Z_...` et `20260719T102608Z_...` produisent le
contrôle bilatéral et les forêts B4 de selection. Son départage B2 par cible est
supersédé. La v2, hash
`ede5dde8c86e3e0c5b4d62e80df41c270f27431598e413e300449752b626ba24`,
produit les valeurs normatives B0–B3/C0-BIR sous `20260719T110304Z_...`.
C0-BIR n'utilise les hash que comme clés de résolution ; ses variables sont
calculées à partir des graphes et des environnements positifs.

La comparaison des centres réactifs a pour hash
`5848ca3045b40993416ee38dbea6adf372ea108d9953fafb106fa5ac93882296`.
Sa copie `20260719T114249Z_...` reproduit B2, évalue C1 sans empreinte globale,
puis C2 avec un mélange local–global déclaré comme choisi sur `selection` déjà
ouvert. Le verdict est `NO-GO-PROTOCOL-C2-MS-REPAIR-SELECTION` ; aucun rendement
`held_out_test` n'est ouvert.
