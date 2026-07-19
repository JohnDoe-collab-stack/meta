# CP0 Lean

## Statut

`CP0-ONTOLOGY-1` fournit le premier langage positif constructif des entrées :

- dix éléments, exactement ceux requis avec H ;
- charge formelle entière par atome ;
- liaisons simples, doubles, triples et aromatiques ;
- stéréochimie atomique et de liaison explicite ;
- graphes moléculaires avec bornes, absence de boucles et de doublons ;
- certificat positif de connexité par chemins stockés ;
- mélanges de fragments pour ne pas déclarer un sel connexe ;
- rôles, quantités rationnelles positives et conditions physiques.

Le fichier ne contient ni cible, ni produit, ni rendement, ni loi de réaction.
La couche importée couvre maintenant les 194 espèces observées.

## Fichier

- [`InputOntology.lean`](./InputOntology.lean)
- [`CanonicalImport.lean`](./CanonicalImport.lean), vérificateur calculable et
  micro-corpus de rejet ;
- [`ImportedSpecies.lean`](./ImportedSpecies.lean), export généré et certificat
  constructif 194/194.

## Validation

```text
lake build Carbone
Build completed successfully
audit : aucun axiome sur toutes les déclarations CP0 imprimées
```

`validatedSpeciesImport` réduit constructivement à 194 espèces toutes valides,
avec identifiants et graphes uniques. La prochaine étape est l'import sans cible
des conditions et quantités, puis la représentation Core de l'entrée complète.
