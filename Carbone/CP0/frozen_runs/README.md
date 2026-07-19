# Runs figés CP0

Tous les fichiers portant un suffixe timestamp + SHA-256 sont immuables.

## Runs normatifs

```text
CP0-DATA-M0
  20260719T065806Z_sha256-9121cdb2...

CP0-DATA-I0
  20260719T073503Z_sha256-c8ebfeb5...

CP0-ONTOLOGY-1 import moléculaire
  20260719T080146Z_sha256-0efd910c...
```

## Run supersédé, conservé

```text
CP0-DATA-I0 v3
  20260719T072736Z_sha256-d7fc340e...
```

`v3` a produit le même verdict et le même manifest. `v4` est normatif parce
qu'il vérifie en plus le wire type `float32` de chaque rendement et présente le
filtre CW1 comme une borne syntaxique, pas comme une preuve de valence.

Les nouvelles expériences doivent créer de nouveaux fichiers. Aucun run
historique ne doit être réexécuté vers les mêmes chemins ni modifié.
