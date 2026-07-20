# CR0-G0 — Schéma minimal des données

## But

Ce schéma empêche qu'un « couple apparié » soit déclaré sur la seule égalité
du signe opposé. Chaque champ requis doit être fourni ou explicitement marqué
comme manquant.

## 1. Enregistrement source

```text
SourceRecord
  source_id
  DOI
  artifact_path
  artifact_sha256
  publication_date
  retrieval_date
  source_page
  figure_or_table
  extraction_method
  transcription_status
```

Valeurs autorisées de `transcription_status` :

```text
machine_extracted_unchecked
visually_checked_once
independently_checked
author_source_data
```

## 2. État initial expérimental

```text
InitialStateRecord
  sample_id
  system_id
  substrate_identity
  substrate_amount
  substrate_concentration
  organozinc_identity
  organozinc_amount
  organozinc_concentration
  chiral_species_identity
  chiral_species_role
  chiral_species_total_amount
  chiral_species_total_concentration
  signed_initial_ee
  absolute_initial_ee
  solvent
  temperature
  atmosphere
  volume
  vessel
  agitation
  batch
```

`chiral_species_role` distingue obligatoirement :

```text
autocatalytic_product_seed
external_chiral_initiator
other.
```

Cette distinction est essentielle : le supplément HB2019 emploie un
initiateur chiral isotopique, alors que la version originale de CR0 porte sur
un produit alcool autocatalytique déjà présent.

## 3. Intervention et réponse

```text
InterventionRecord
  injection_count
  addition_order
  amount_added_per_injection
  total_aldehyde_added
  total_organozinc_added
  interval_between_injections
  observation_horizon
  sampling_protocol

ResponseRecord
  signed_product_ee
  signed_product_ee_error_bound
  initial_product_r_concentration
  initial_product_s_concentration
  final_product_r_concentration
  final_product_s_concentration
  newly_formed_r_interval
  newly_formed_s_interval
  newly_formed_signed_ee_interval
  product_total_amount
  conversion
  measurement_method
  instrument_timestamp
  elapsed_time
  native_file_id
  calibration_id
  measurement_error
  replicate_id
  exclusion_status
```

Pour un profil temporel, un `ResponseRecord` est conservé pour chaque point
brut. Une valeur à l'horizon primaire porte aussi l'identifiant de la règle
préenregistrée qui l'a produite : mesure directe, fenêtre fixe ou interpolation
autorisée. Cette règle ne peut dépendre du signe ou de la valeur observée.

La réponse primaire CR0-P est `newly_formed_signed_ee_interval`, construite par
soustraction des concentrations R/S initiales puis finales. L'ee du produit
total est secondaire : il contient la graine et ne démontre pas seul une
propagation autocatalytique de l'information chirale.

## 4. Clé d'appariement stricte

Deux enregistrements `x` et `y` forment un candidat miroir strict seulement
si toutes les conditions suivantes sont établies :

```text
x.system_id                    = y.system_id
x.substrate_identity           = y.substrate_identity
x.substrate_amount             = y.substrate_amount
x.organozinc_amount            = y.organozinc_amount
x.chiral_species_identity      = y.chiral_species_identity
x.chiral_species_role          = y.chiral_species_role
x.chiral_species_total_amount  = y.chiral_species_total_amount
abs(x.signed_initial_ee)       = abs(y.signed_initial_ee)
sign(x.signed_initial_ee)      ≠ sign(y.signed_initial_ee)
x.solvent                      = y.solvent
x.temperature                  = y.temperature
x.atmosphere                   = y.atmosphere
x.volume                       = y.volume
x.batch                        = y.batch
x.intervention                 = y.intervention.
```

Une égalité non publiée ou non mesurée reçoit le statut `unknown`, jamais
`true`. Un couple comportant un champ requis `unknown` reste provisoire.

Pour les données physiques nouvelles, l'égalité stricte des réels non connus
est remplacée par l'égalité exacte d'encodages finis préenregistrés. Les valeurs
centrales, bornes d'erreur et encodages sont tous conservés ; une compatibilité
d'intervalles n'est jamais réécrite comme égalité des valeurs physiques.

## 5. Projection achirale

La projection CR0 proposée conserve :

```text
identités chimiques achirales ;
quantités totales ;
conditions ;
batch ;
intervention ;
temps ;
protocole de mesure.
```

Elle oublie uniquement :

```text
le signe de l'ee ;
et la décomposition R/S lorsqu'elle est compatible avec la quantité totale.
```

La magnitude absolue de l'ee n'est pas oubliée dans le test strict, car la
supprimer permettrait aux groupes A et B de paraître artificiellement
appariés malgré leurs entrées de magnitudes différentes.

## 6. Critère de futur différentiel

CR0 distingue deux revendications qui ne doivent pas être confondues :

```text
F-det : les ensembles finis de réponses admissibles sont disjoints ;
F-dist : les distributions de réponses diffèrent selon un test préenregistré.
```

La version actuelle de `CARBON_REFERENCE_0` exige `F-det` ou une marge
préenregistrée équivalente. Le groupe H ne la satisfait pas, car les valeurs
finales sous initiateurs R et S se recouvrent. Passer à `F-dist` serait une
révision scientifique du contrat, pas une correction de données.
