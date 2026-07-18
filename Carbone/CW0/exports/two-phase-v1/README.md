# Export `cw0-two-phase-v1`

`kernel.json` est produit par la cible Lean `export_two_phase`. Il décrit le
quotient fini des phases et non l'état complet à histoire non bornée.

Commande de régénération depuis la racine du dépôt :

```bash
lake exe export_two_phase Carbone/CW0/exports/two-phase-v1/kernel.json
```

Après régénération, le hash doit être recalculé et `MANIFEST.sha256` mis à
jour. Une modification manuelle de `kernel.json` lui retire son statut
d'export du modèle Lean.
