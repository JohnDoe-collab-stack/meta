# Runs figés CP0

Tous les fichiers portant un suffixe timestamp + SHA-256 sont immuables.

## Runs normatifs

```text
CP0-DATA-M0
  20260719T065806Z_sha256-9121cdb2...

CP0-DATA-I0
  20260719T073503Z_sha256-c8ebfeb5...

CP0-ONTOLOGY-1 import moléculaire
  20260719T085207Z_sha256-df6b9ce0...

CP0-ONTOLOGY-2 import des environnements
  20260719T091321Z_sha256-ba12c048...
```

## Run supersédé, conservé

```text
CP0-DATA-I0 v3
  20260719T072736Z_sha256-d7fc340e...

CP0-ONTOLOGY-1 premier export
  20260719T080146Z_sha256-0efd910c...

CP0-ONTOLOGY-2 exports préparatoires
  20260719T083024Z_sha256-cb037f49...
  20260719T083619Z_sha256-5d6c650d...
```

`v3` a produit le même verdict et le même manifest. `v4` est normatif parce
qu'il vérifie en plus le wire type `float32` de chaque rendement et présente le
filtre CW1 comme une borne syntaxique, pas comme une preuve de valence.

Le premier export moléculaire a correctement audité les 194 espèces, mais son
rendu Lean imbriqué était syntaxiquement invalide ; il est donc conservé comme
trace et remplacé par le run `df6b9ce0...`, compilé sans axiome. Les deux
exports préparatoires d'environnement ont établi les mêmes comptes ; le run
`ba12c048...` est normatif parce que son export à constructeurs explicites
compile et certifie aussi les domaines 70 amines / 66 acides. Les deux exports
Lean invalides sont archivés octet pour octet sous l'extension `.lean.failed` ;
ils ne sont pas présentés comme des sources compilables.

Les nouvelles expériences doivent créer de nouveaux fichiers. Aucun run
historique ne doit être réexécuté vers les mêmes chemins ni modifié.
