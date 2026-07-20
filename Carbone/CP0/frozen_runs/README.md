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

CP0-TARGET-T2 lecteur et audit synthétiques
  20260719T094729Z_sha256-4bdec976...

CP0-TARGET-T3 cibles construction
  20260719T095919Z_sha256-4bdec976...

CP0-EMPIRICAL-0 contrôle construction
  20260719T100749Z_sha256-c3b517d2...

CP0-TARGET-T5 cibles selection
  20260719T102545Z_sha256-4bdec976...

CP0-EMPIRICAL-0 comparaison selection
  20260719T102608Z_sha256-c3b517d2...

CP0-EMPIRICAL-0 correction B2 et audit selection
  20260719T110304Z_sha256-ede5dde8...

CP0-EMPIRICAL-1 centres réactifs, construction et selection
  20260719T114249Z_sha256-5848ca30...
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

Le run `4bdec976...` est normatif pour `T2`. Il a exécuté une copie figée du
lecteur sous CPython 3.10.12, produit cinq groupes synthétiques déterministes et
rejeté 22/22 cas négatifs. Son rapport atteste que ni la source ORD réelle, ni
le manifest I0, ni une valeur cible réelle n'ont été ouverts.

Les runs suivants ouvrent uniquement `construction`, puis `selection`. Le
contrôle interne donne B4=16,9190 et C0-BIR=17,4565 de MAE. La comparaison de
selection corrigée donne B2=14,5908, B4=14,9444 et C0-BIR=18,5021, soit le
verdict `NO-GO-C0-BIR-SELECTION`. Le B2 de la v1 est supersédé parce que ses
égalités de similarité étaient départagées par la cible ; la v2 utilise les
identités moléculaires. Aucun run de ce dossier n'ouvre `held_out_test`.

Les nouvelles expériences doivent créer de nouveaux fichiers. Aucun run
historique ne doit être réexécuté vers les mêmes chemins ni modifié.

Le run `5848ca30...` détecte exactement un N réactif dans 70/70 amines et un
carbone carboxylique dans 66/66 acides. C1 centre seul obtient 14,7821 de MAE
contre B2=14,5908. C2 local–global atteint 13,6389, mais son gain de 0,9519 est
inférieur au seuil et l'IC 95 % `[-2,5417 ; +0,6898]` contient zéro. La
configuration C2 est explicitement marquée comme choisie sur `selection` déjà
ouvert ; le verdict protocolaire est un NO-GO et `held_out_test` reste scellé.
