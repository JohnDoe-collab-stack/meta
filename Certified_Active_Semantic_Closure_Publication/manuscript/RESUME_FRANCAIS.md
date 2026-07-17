# Résumé scientifique français

Le dossier résout formellement le problème ciblé sur deux réalisations exactes,
finie et ouverte, et ajoute le pont générique qui manquait au développement.

Le point de départ est un aliasing de continuation : deux situations cachées
ont la même représentation accessible mais exigent des décisions différentes.
Le théorème générique
`continuationAliasing_informationNecessity` prouve constructivement qu’aucune
règle factorisée par cette représentation ne peut être correcte sur les deux.

Dans le système sémantique, un aliasing est une paire de mondes compatibles avec
la même vue dont les cibles diffèrent à l’indice critique. Les théorèmes
`latentAliasing_refutesFiberDeterminacy` et
`latentAliasing_informationNecessity` montrent que cette situation interdit la
détermination de la fibre et la correction connue du candidat.

La réparation ne se contente pas de faire disparaître un signal d’erreur.
`closureRestoresLocalSufficiency` prouve qu’un certificat `GapClosedBy` fournit
simultanément :

- la compatibilité du monde réel après réparation ;
- la correction sur tous les mondes encore compatibles ;
- l’unicité de la cible sur cette fibre ;
- la correction dans le monde réel.

Donc, après fermeture, l’aliasing ne peut plus subsister à l’indice réparé.

Chaque étape certifiée contient la chaîne complète : gap ouvert et typé,
aliasing avant réparation, requête exactement sélectionnée et strictement
informative, successeur dérivé de la réparation intrinsèque, réduction stricte
de la fibre compatible, fermeture, suffisance restaurée et impossibilité d’un
aliasing résiduel.

Dans le modèle fini, trois étapes réduisent le nombre de gaps de `3` à `0`,
préservent les préfixes déjà clos et atteignent un état terminal stable. Dans le
modèle ouvert, pour tout stade naturel, deux complétions compatibles diffèrent
sur l’indice frais ; la requête les sépare, la réponse élimine explicitement une
complétion, ferme le gap courant et préserve toutes les entrées précédentes. Il
n’existe pas de clôture globale à un stade fini, mais chaque transition est
effective et chaque gap courant est fermé.

L’objet final
`Meta.ActiveSemanticClosure.LatentRepair.certifiedLatentRepairPublication`
assemble ces résultats avec les no-go visible et passif, la conservativité de
l’identité stricte, la cohérence constructive et l’agent quantifié à cinq têtes
certifié sur 697 obligations réifiées.

La portée est précise : le résultat est complet pour les systèmes publiés et
générique pour le théorème de nécessité informationnelle et le pont
fermeture-suffisance. Il ne revendique ni généralisation statistique hors
catalogue, ni robustesse à des réponses bruitées, ni supériorité sur un
benchmark externe.
