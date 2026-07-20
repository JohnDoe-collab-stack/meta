# Contrat exécutable v23.1

Ce fichier résume les invariants que l’implémentation refuse de relâcher. Le
document d’autorité exhaustif est identifié, dans `protocol.lock.json`, par son
SHA-256. Une évolution de ces invariants exige une nouvelle version de
protocole et ne peut réécrire une campagne commencée.

1. Chaque famille fermée comporte exactement 32 mondes, au moins deux
   observations publiques distinctes et au moins quatre mondes dans la fibre
   réelle. Cette fibre contient un conflit d’action et une expérience autorisée
   le réduit.
2. Aucun module appris ne reçoit le monde, la cible, une réponse future, la clé
   OOD ou le patch correct. Les masques typés ne dépendent que de l’état public.
3. B13 calcule gap, use, transport, query et repair dans cet ordre. La réponse
   vient du domaine. L’état suivant est l’exécution de la réparation; il n’existe
   pas de tête directe `next`.
4. B1–B13 sont tous publiés. B9 et B12 restent diagnostiques. Les comparaisons
   principales respectent les budgets de données, paramètres, FLOPs, pas,
   requêtes et réponses.
5. Les seeds finales sont 0–9; les seeds de réglage 100–102; la réplication
   d’entraînement utilise 10–19. Aucune seed faible ou divergente n’est remplacée.
6. L’OOD est généré et scellé avant entraînement, puis ouvert seulement après
   gel des checkpoints et de l’évaluateur. Toute ouverture prématurée invalide
   la partition.
7. H3/H4/H7 utilisent les seeds comme unités indépendantes, 10 000 bootstraps
   hiérarchiques, les 1024 inversions exactes de signe et Holm sur six tests.
8. Une obligation structurelle tolère zéro violation. Les portes utilisent
   `PASS`, `FAIL`, `NOT_RUN`; une preuve manquante ne devient jamais un succès.
9. Toute sortie scientifique est nouvelle, figée, hashée et accompagnée de la
   commande, du hash source, de l’environnement, des seeds et des partitions.
10. La certification Lean réifie les données et calcule les preuves; aucun JSON
    n’est admis comme axiome.
