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
