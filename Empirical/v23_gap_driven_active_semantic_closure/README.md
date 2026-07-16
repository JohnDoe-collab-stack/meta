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
1. écrire SCIENTIFIC_PROTOCOL.md à partir du plan validé ;
2. définir le schéma de trace brut et son vérificateur indépendant ;
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

Racine empirique initialisée. Le modèle Lean fini de référence existe désormais
dans `Meta/AI/FiniteActiveSemanticClosure.lean`, mais aucun environnement
Python v23, run, résultat appris ou certificat de trace n'existe encore. Ce
README ne revendique donc aucun résultat empirique.
