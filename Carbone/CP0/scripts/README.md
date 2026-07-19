# Scripts CP0

Règle d'immuabilité : chaque variante ayant produit un résultat est conservée.
Ne modifier aucun de ces fichiers ; créer `v4`, `v5`, etc.

```text
ord_metadata_audit.py  audit M0 exécuté sous copie figée ;
ord_input_audit_v1.py  smoke-test initial, sans cache ;
ord_input_audit_v2.py  smoke-test avec cache moléculaire ;
ord_input_audit_v3.py  correction charge atomique/nette, premier run scientifique ;
ord_input_audit_v4.py  check float32 et borne CW1 explicite, run normatif I0.
ord_canonical_import_v1.py  smoke initial, sans marquage des centres potentiels ;
ord_canonical_import_v2.py  centres assignés/non assignés, run normatif 194/194.
```

Le run normatif I0 est la copie `ord_input_audit_20260719T073503Z_...py`
conservée dans [`frozen_runs`](../frozen_runs/). Son hash est
`c8ebfeb5d1884789c846e4336ea03b1a4312a07304e47f0deb5f6ddce10a5a9f`.

Le run normatif d'import est la copie
`ord_canonical_import_20260719T080146Z_...py`. Son hash est
`0efd910c53dddb4014752533035a70268cfe03e637afe5323c91ccb74e874344`.
