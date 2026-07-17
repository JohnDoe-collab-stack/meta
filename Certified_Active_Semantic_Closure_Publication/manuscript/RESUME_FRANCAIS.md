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

Le dossier contient maintenant aussi une caractérisation adaptative générale
pour une classe explicitement finie, déterministe et publique. La stratégie ne
reçoit jamais le monde réel : il intervient seulement dans l’exécution pour
produire la réponse environnementale. Un no-go adaptatif prouve qu’une paire de
mondes en conflit d’action, indiscernable par tous les arbres publics admis,
interdit la réparabilité certifiée.

Réciproquement, sous une interface totale de réalisation des candidats sur les
fibres homogènes, la réparabilité certifiée est équivalente à l’existence d’un
arbre public dont toutes les feuilles sont suffisantes pour l’action. Un
synthétiseur construit cet arbre à partir d’épisodes séparateurs composables. Sa
récursion est justifiée uniquement par la diminution du nombre calculé de
paires en conflit ; aucun rang terminal externe n’est fourni.

Un compilateur exact donne en outre l’égalité entre la fibre de chaque feuille
générée et son posterior de transcription. Quatre contre-modèles formalisés
montrent la nécessité de la composabilité, de l’expressivité du candidat, de la
séparation public/privé et d’une frame explicite. Une instance exacte à deux
mondes valide la chaîne complète et exclut toute vacuité du théorème.

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
`certifiedAdaptiveClosurePublicationValidation` assemble la publication
latente antérieure, la caractérisation adaptative et son instance positive avec
les no-go visible et passif, la conservativité de
l’identité stricte, la cohérence constructive et l’agent quantifié à cinq têtes
certifié sur 697 obligations réifiées.

La portée est précise : le résultat est complet pour les systèmes publiés et
générique pour la nécessité informationnelle, le pont fermeture-suffisance et
la caractérisation finie sous ses hypothèses explicites. Il ne revendique ni généralisation statistique hors
catalogue, ni robustesse à des réponses bruitées, ni supériorité sur un
benchmark externe.
