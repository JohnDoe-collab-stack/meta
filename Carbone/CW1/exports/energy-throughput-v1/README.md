# Export `cw1-energy-throughput-v1`

`kernel.json` est produit par la cible Lean `export_cw1_energy`. Il conserve les
deux états structurels de `CW0` et ajoute, pour chaque transition, les champs
certifiés suivants :

```text
requested_energy
energy_inflow
energy_dissipated
available_before
available_after
```

Chaque valeur provient d'une charge utile indexée par sa phase et prouvée égale
au calcul Lean. Le bilan démontré est celui d'un système formel ouvert :

```text
available_before + energy_inflow
= available_after + energy_dissipated.
```

Commande de régénération depuis la racine du dépôt :

```bash
lake exe export_cw1_energy Carbone/CW1/exports/energy-throughput-v1/kernel.json
```

Les jetons d'énergie n'ont ici aucune unité physique. Cet export ne constitue
ni une thermodynamique, ni une cinétique, ni une validation chimique.
