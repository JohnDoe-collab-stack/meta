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

Les fichiers ne contiennent ni cible, ni produit, ni rendement, ni loi de
réaction. La couche importée couvre les 194 espèces et les 94 environnements
observés, puis résout l'entrée complète sans conserver leurs hash de lookup.

## Fichier

- [`InputOntology.lean`](./InputOntology.lean)
- [`CanonicalImport.lean`](./CanonicalImport.lean), vérificateur calculable et
  micro-corpus de rejet ;
- [`ImportedSpecies.lean`](./ImportedSpecies.lean), export généré et certificat
  constructif 194/194 ;
- [`EnvironmentImport.lean`](./EnvironmentImport.lean), langage positif des
  quantités, protocoles et conditions, résolution et projection sans clé ;
- [`ImportedEnvironments.lean`](./ImportedEnvironments.lean), export généré,
  domaines amine/acide et certificats constructifs 94/94 ;
- [`ProducerContract.lean`](./ProducerContract.lean), projection intrinsèque,
  sortie rationnelle bornée et chaîne causale finie du futur producteur.

## Validation

```text
lake build Carbone
Build completed successfully
audit : aucun axiome sur toutes les déclarations CP0 imprimées
```

`validatedSpeciesImport` réduit constructivement à 194 espèces toutes valides,
avec identifiants et graphes uniques. `validatedInputDomainImport` réduit à 94
environnements valides, 70 amines et 66 acides uniques, tous reliés aux espèces
importées. `knownInputOrganization_resolves` et
`knownInputProjection_resolves` vérifient le chemin calculable jusqu'à une
entrée intrinsèque. `run_eq_executeRepair` vérifie que la prédiction ne peut
être émise qu'au terme de la chaîne gap–interaction–réponse–réparation. Le
producteur synthétique à 50 % ne teste que cette plomberie : aucune loi
chimique ni aucun paramètre appris n'est encore défini.
