# v23 — Gap-Driven Active Semantic Closure

Ce dossier est la racine de la nouvelle implémentation empirique décrite dans
[`Docs/ValidationIntegraleFermetureSemantiqueIA.md`](../../Docs/ValidationIntegraleFermetureSemantiqueIA.md).

Il est entièrement distinct de
`Empirical/v22_aslmt_perceptual_localglobal_dynamic_infinite`. Les scripts et
résultats v22 restent historiques et immuables.

## Cible finale

Ce dossier ne vise pas un simple test empirique v23. Le petit environnement
fini isomorphe à Lean est le premier jalon de validation, pas le livrable final.

La cible est une campagne v23 complète, successeur intégral de v22, avec le
même niveau de matérialité expérimentale : entraînements effectifs, baselines,
multi-seeds, checkpoints, poids, traces rejouables, interventions, OOD scellé,
certificats, falsification des vérificateurs et réplication. Sa portée est plus
forte : elle doit matérialiser et tester causalement toute la boucle `gap → use
→ transport → query → response → repair → next`, sa conservation cumulative et
les impossibilités bornées définies par le plan principal.

Une concordance Lean/Python sur le domaine fini autorise la campagne ; elle ne
la remplace pas.

## Contrat d'implémentation

Le contrat scientifique normatif est désormais
[`SCIENTIFIC_PROTOCOL.md`](SCIENTIFIC_PROTOCOL.md). Il fige les choix de
réalisation, les domaines, les architectures, les budgets, les baselines, les
interventions, les partitions, les seuils et les portes de décision avant le
premier run scientifique.

La première cible n'est pas un entraînement GPU. Elle est une petite instance
finie dont Python et Lean calculent exactement les mêmes objets :

```text
AgentClosureState
OperationalGap
GapAuthorizedUse
GapAuthorizedTransport
Query et Response
IntrinsicRepair
ActiveSemanticClosureState suivant
CompatibleWorlds et GapClosedBy
```

Le détecteur reçoit uniquement la vue de l'agent. Le monde fermé peut produire
les observations, les réponses et les certificats sémantiques, mais il ne peut
pas fournir directement le gap, l'usage, le transport, la requête, le patch ou
l'état suivant.

## Ordre initial

```text
1. maintenir `SCIENTIFIC_PROTOCOL.md` gelé pour la campagne identifiée ;
2. conserver le schéma de trace brut et son vérificateur structurel exécutable ;
3. implémenter le petit environnement fini isomorphe à Meta/AI ;
4. vérifier exhaustivement la concordance Lean/Python ;
5. prouver les no-go passif et visible factorisé ;
6. construire l'agent quantifié certifiable ;
7. seulement ensuite ajouter entraînement, scaling, OOD et réplication.
```

## Traçabilité

Chaque script scientifique est nouveau et n'est plus modifié après avoir produit
un résultat cité. Toute exécution scientifique utilise une copie figée dont le
nom contient un timestamp et le SHA-256 du script. Les sorties reprennent le
même suffixe et enregistrent la commande complète, le hash, les versions, les
seeds et la plateforme.

Les smoke tests écrivent dans `/tmp` ou dans des sorties explicitement nommées
`smoke`. Aucun script v23 ne remplace un résultat v22.

## Statut

Le niveau A exécutable est implémenté :

```text
schéma JSONL canonique et parseur strict ;
environnement Python exact sur les 27 mondes ;
vérificateur sémantique indépendant des fonctions causales du producteur ;
108 états naturels vérifiés, stases terminales comprises ;
matrice des 18 interventions déclarées, avec 8 avancées et 10 refus typés ;
vérificateur indépendant des interventions et de leur appariement naturel ;
snapshot Lean/Python de 108 états naturels et des 18 interventions, avec chaîne
causale complète pour chaque branche avancée et stade exact pour chaque refus ;
codage Lean constructif sans `Classical`, `propext` ni `Quot.sound` ;
no-go passif exact sur 64 candidates ;
no-go visible factorisé sur 30 actions et 900 contrôleurs ;
optimum randomisé rationnel exact ;
arbre adaptatif actif à 27 feuilles et capacité totale de 5 bits ;
tests adversariaux des traces et certificats.
```

Ces calculs sont pour l'instant des validations de développement. Ils ne sont
pas encore des résultats scientifiques citables : aucune exécution n'a été
gelée sous un nom `timestamp+sha256`, aucun `protocol.lock.json` final n'a été
émis et aucun bundle de résultats de référence n'est publié.

La concordance de développement couvre exhaustivement la dynamique naturelle
et les dix-huit interventions du protocole. Lean classe chaque intervention
dans `Meta/AI/FiniteInterventionMatrix.lean`, avec certificat interne de la
raison de chaque refus. Pour les huit interventions exécutables, le snapshot
compare aussi l'état initial, la fibre, le gap, l'usage, le transport, la
requête, la réponse, le patch, la mise à jour d'observation, l'historique et
l'état final. Python matérialise la trace complète, la vérifie indépendamment
et le comparateur échoue dès qu'un token du snapshot diffère.
G2 scientifique exige encore l'exécution figée et hashée prescrite par G0.

Restent ouverts : l'agent quantifié certifiable et sa réification Lean, les deux
domaines appris, le modèle et les baselines appariées, les certificats de
causalité et de dynamique, les runs multi-seeds, les OOD scellés, le gel G0,
les réplications et l'audit final G8. Aucun résultat appris v23 n'est donc
revendiqué à ce stade.
