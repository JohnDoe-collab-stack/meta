# CW0-SIM0 — protocole du noyau fini à deux phases

## Statut

Ce protocole valide uniquement la conformité calculatoire entre un quotient
fini prouvé en Lean et un interprète Python. Il ne valide aucune loi chimique,
aucune cinétique, aucun temps physique et aucune comparaison empirique.

Le premier run figé est documenté dans
[`reports/CONFORMANCE.md`](./reports/CONFORMANCE.md). Son statut est
`FINITE_PHASE_EXPORT_CONFORMANT`, explicitement inférieur à `SIM1` complet.

## Domaine exporté

Le monde Lean complet conserve une histoire de longueur non bornée. Elle n'est
ni tronquée ni rendue cyclique. Le noyau fini exporte seulement la phase
structurelle courante :

```text
0 = chain
1 = bridged
```

Les deux phases portent le même visible atomique : deux carbones et un oxygène.
Elles diffèrent par leur liste de liaisons. L'environnement fixe contient une
unité d'énergie et aucune ressource libre.

## Loi normative

La loi finie n'est pas ajoutée comme un second successeur. Elle est la
projection du pas réparateur déjà défini :

```text
twoPhaseOfPoint (twoPhaseGapRepairAlgebra.next point)
  = twoPhaseKernelStep (twoPhaseOfPoint point).
```

Le théorème Lean `twoPhaseKernel_commutes` établit cette égalité pour tout
point admissible et toute histoire. La table exhaustive attendue contient :

```text
chain   → bridged
bridged → chain
```

## Observables et prédictions

Le premier interprète doit vérifier exhaustivement :

1. les deux identifiants de phase existent une fois chacun ;
2. chaque source possède exactement une transition ;
3. les cibles appartiennent au domaine ;
4. l'inventaire visible reste `C2 O1` ;
5. deux transitions ramènent à la phase initiale ;
6. une trajectoire de longueur `n` contient exactement `n + 1` observations.

## Réfutation et portée

Une divergence Python sur l'un des deux cas réfute la conformité de
l'interprète ou de l'export (`CONFORMANCE`). Elle ne réfute pas la chimie.

Ce noyau ne peut pas être comparé honnêtement à une expérience : l'alternance
des squelettes est un témoin construit, sans mécanisme, paramètres, unités ni
provenance physique. Le passage à `SIM2/SIM3` reste bloqué jusqu'à l'existence
d'une instance empirique telle que CR0 et d'un export Lean de ses réponses.

## Traçabilité

Tout run cité utilisera une copie figée du script contenant un timestamp et le
préfixe de son SHA-256. Les sorties reprendront exactement ce suffixe et le
rapport texte enregistrera la commande, les hashes et la plateforme. Les
essais avant gel écriront seulement dans `/tmp` ou dans un chemin `smoke`.
