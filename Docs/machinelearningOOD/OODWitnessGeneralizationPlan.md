# Témoin interne et généralisation OOD

## 1. Objet du document

Ce document prépare une formalisation du lien entre le cadre `meta` et un
problème connu en apprentissage automatique :

```text
out-of-distribution generalization
```

Le but n'est pas de promettre qu'un modèle généralise toujours hors
distribution.

Le but est plus précis :

```text
démontrer qu'un témoin interne peut survivre à un changement réel de lecture
visible, alors que le visible seul ne reconstruit pas la cellule opératoire.
```

La cible formelle est donc :

```text
shift visible réel
+ source structurelle du shift
+ témoin interne conservé
+ visible seul insuffisant
```

Cette combinaison est le critère de non-trivialité.

Le document ne propose donc pas une analogie vague avec le machine learning.
Il prépare un test formel :

```text
est-ce qu'une structure peut rester opératoirement stable
quand sa lecture visible change réellement ?
```

La réponse attendue doit être portée par le code, pas par le vocabulaire.

## 2. Problème ML/stat visé

Le problème connu est :

```text
spurious correlations under distribution shift
```

Un modèle apprend une corrélation visible dans la distribution
d'entraînement.

Cette corrélation peut donner une bonne prédiction locale sans porter la
structure qui produit réellement le phénomène.

Quand la distribution change, la lecture visible peut changer.

Le modèle peut alors conserver la corrélation apprise et perdre la structure
pertinente.

Dans le vocabulaire du cadre :

```text
le modèle transporte une projection visible,
mais pas nécessairement le témoin opératoire.
```

Le problème concret est donc :

```text
une bonne corrélation visible peut être stable dans la distribution source
et cesser d'être structurelle dans la distribution cible.
```

La question formelle devient :

```text
peut-on certifier que ce qui est transporté n'est pas seulement le visible,
mais le témoin interne qui rend la cellule récupérable ?
```

## 3. Ce que la lecture projective standard voit

La lecture projective standard teste surtout :

```text
input
-> représentation visible
-> prédiction
-> performance OOD
```

Les approches usuelles cherchent des invariances :

```text
domain generalization
invariant risk minimization
causal representation learning
robustness under distribution shift
OOD detection
```

Le point difficile reste :

```text
comment savoir si une représentation transporte la structure
ou seulement une projection visible utile dans la distribution courante ?
```

Le cadre doit répondre à cette question en termes de témoin.

Dans ce document, le mot `OOD` ne désigne donc pas seulement une baisse de
performance hors distribution. Il désigne une situation où la lecture visible
change, et où il faut décider si la structure interne survit à ce changement.

Deux niveaux doivent rester séparés :

```text
projection : ce qui contracte l'interface ;
lecture    : ce qui expose un résultat visible à partir de la projection.
```

La non-reconstruction formelle porte d'abord sur la projection. La lecture sert
à manifester le shift.

## 4. Ce que le cadre doit prouver

Le cadre doit prouver :

```text
une lecture visible peut changer réellement,
mais le témoin interne reste disponible parce qu'il est porté par la cellule.
```

Il ne suffit pas de prouver :

```text
la même cellule garde le même témoin.
```

Cette preuve serait trop faible.

Il faut aussi prouver que :

```text
la lecture visible a réellement changé.
```

Mais ce changement visible ne doit pas être fabriqué par le choix libre de
deux fonctions de lecture.

Il faut prouver que :

```text
la séparation visible est dérivée d'une source structurelle du cadre.
```

et que :

```text
la projection visible seule ne reconstruit pas la cellule.
```

## 5. Contrat de non-trivialité

Un résultat OOD acceptable doit porter cinq données.

Ces cinq données doivent être présentes ensemble. Si l'une manque, le
résultat ne démontre pas encore une stabilité OOD structurelle.

### 5.1 Shift visible réel

Il doit exister deux lectures visibles :

```text
project_in  : Interface -> VisibleIn
project_out : Interface -> VisibleOut
```

et un test commun de lecture :

```text
read_in  : VisibleIn  -> Label
read_out : VisibleOut -> Label
```

avec une preuve de changement :

```text
read_in (project_in formed) ≠ read_out (project_out formed)
```

ou une séparation équivalente.

Sans cette preuve, le résultat est refusé.

Ce point est décisif. Une structure qui transporte le même témoin sans prouver
que la lecture visible a changé ne teste pas l'OOD. Elle teste seulement une
identité interne.

La preuve de shift doit donc être une donnée explicite du théorème :

```text
visibleShift :
  read_in (project_in formed) = read_out (project_out formed) -> False
```

ou une formulation équivalente.

Mais cette donnée seule ne suffit pas.

Elle doit être accompagnée de sa provenance structurelle.

### 5.2 Source structurelle du shift

Le `visibleShift` doit être dérivé d'une source déjà portée par la cellule ou
par l'instance considérée.

Forme abstraite :

```text
ShiftSource : Type
shiftSource : ShiftSource
visibleShiftOfSource :
  ShiftSource ->
    read_in (project_in formed) = read_out (project_out formed) -> False
```

Le shift effectif est alors :

```text
visibleShift := visibleShiftOfSource shiftSource
```

Cette provenance est obligatoire.

Elle ne garantit pas, à elle seule, que la source est riche.

La couche abstraite rend la provenance inspectable. L'instance concrète doit
ensuite prouver que cette provenance n'est pas ad hoc.

Sera donc refusée dans une instance concrète une source du type :

```text
ShiftSource := read_in (project_in formed) = read_out (project_out formed)
  -> False
```

avec :

```text
visibleShiftOfSource := fun h => h
```

Ce serait seulement déplacer la preuve flottante dans `ShiftSource`.

Elle empêche le faux résultat suivant :

```text
Label := Bool
read_in  := fun _ => true
read_out := fun _ => false
```

Un tel choix prouve une séparation visible, mais ne prouve rien sur la
structure.

Un shift acceptable doit venir d'une source comme :

```text
séparation de rôles déjà formalisée ;
écart de payload porté par un témoin positif ;
obstruction diagonale déjà portée par la cellule ;
théorème structurel existant de l'instance.
```

Dans l'instance arithmétique, une séparation de rôles seule peut être une
source, mais elle n'est pas automatiquement un shift OOD complet.

Elle doit encore produire :

```text
deux lectures visibles distinctes
+ même formed/shadow
+ same_in
+ same_out
```

### 5.3 Cellule opératoire conservée

La cellule interne doit rester portée :

```text
formed : Interface
shadow : Interface
separated : formed = shadow -> False
repair : RepairOf formed
recovered : Interface
recovered_eq_formed : recovered = formed
```

Chaque projection doit produire son propre certificat visible :

```text
same_in  : project_in formed = project_in shadow
same_out : project_out formed = project_out shadow
```

Il ne faut pas remplacer cette cellule par deux cellules indépendantes.

Le point est précisément :

```text
même formed/shadow interne
+ deux projections visibles
+ deux lectures visibles
+ shift réel entre lectures
```

Sinon on ne prouve pas que la même structure survit au shift.

### 5.4 Témoin interne conservé

Le témoin doit être interne.

Il ne doit pas être défini par la projection visible.

Forme abstraite :

```text
Witness : Type
witness : Witness
```

Forme positive :

```text
positiveWitness : Nat
positiveWitness_pos : 0 < positiveWitness
```

Le théorème doit produire :

```text
witness_in = witness_out
```

ou mieux :

```text
witness_out est le transport du même witness interne
```

Le témoin ne doit pas être reconstruit depuis `read_in` ou `read_out`.

Il ne doit pas non plus être fourni comme un champ libre sans lien avec la
cellule.

Le témoin doit être attaché à la cellule ou extrait d'elle :

```text
cellule
-> témoin interne
-> lectures visibles
```

et non :

```text
témoin
-> témoin
```

Il doit être porté avant la lecture visible :

```text
cellule interne
-> témoin
-> projections visibles
```

et non :

```text
projection visible
-> reconstruction du témoin
```

### 5.5 Visible seul insuffisant

Le théorème doit aussi réutiliser l'obstruction projective :

```text
ProjectionObstruction
LocalProjectiveRecovery
noProjectiveReconstruction
```

Il faut donc démontrer :

```text
le témoin survit par structure interne,
pas parce que la projection visible suffit.
```

Ce point empêche de confondre généralisation structurelle et simple invariance
visible.

Formulation stricte :

```text
project_in ne reconstruit pas l'interface ;
project_out ne reconstruit pas l'interface.
```

Les fonctions :

```text
read_in
read_out
```

servent à exposer le shift visible. Elles ne sont pas directement la cible de
`noProjectiveReconstruction`, sauf si l'on construit explicitement une
projection composée :

```text
read_in ∘ project_in
read_out ∘ project_out
```

## 6. Forme Lean cible

### 6.1 Structure du shift OOD

Structure candidate :

```lean
structure OODProjectionShift
    (Interface : Type u)
    (VisibleIn : Type v)
    (VisibleOut : Type w)
    (Label : Type z)
    (ShiftSource : Type r)
    (projectIn : Interface -> VisibleIn)
    (projectOut : Interface -> VisibleOut)
    (readIn : VisibleIn -> Label)
    (readOut : VisibleOut -> Label) where
  formed : Interface
  shadow : Interface
  sameIn : projectIn formed = projectIn shadow
  sameOut : projectOut formed = projectOut shadow
  separated : formed = shadow -> False
  shiftSource : ShiftSource
  visibleShiftOfSource :
    ShiftSource ->
      readIn (projectIn formed) = readOut (projectOut formed) -> False
```

Le shift visible effectif doit ensuite être défini, pas stocké une seconde
fois :

```lean
def OODProjectionShift.visibleShift
    (shift : OODProjectionShift
      Interface VisibleIn VisibleOut Label ShiftSource
      projectIn projectOut readIn readOut) :
    readIn (projectIn shift.formed) =
      readOut (projectOut shift.formed) -> False :=
  shift.visibleShiftOfSource shift.shiftSource
```

Point important :

```text
visibleShift
```

est donc le résultat dérivé du shift, mais :

```text
shiftSource
visibleShiftOfSource
```

sont les données qui empêchent le shift d'être seulement décoratif.

Cette structure ne contient pas encore la réparation. Elle isole seulement la
situation OOD minimale :

```text
même paire opératoire formed/shadow,
deux projections,
deux lectures,
source structurelle du shift,
shift visible prouvé.
```

Le shift visible ne doit pas être un champ indépendant. Il doit être obtenu par
application de `visibleShiftOfSource` à `shiftSource`. Si l'implémentation
laisse ces données sans lien, elle est refusée.

La couche abstraite ne peut pas décider seule qu'une source est
conceptuellement riche. Elle doit rendre la provenance inspectable. La charge
de non-artificialité est ensuite vérifiée dans chaque instance concrète.

### 6.2 Cellule récupérée sous shift

Structure candidate :

```lean
structure OODRecoveredCell
    ...
    (RepairOf : Interface -> Type s) where
  shift : OODProjectionShift ...
  repair : RepairOf shift.formed
  recovered : Interface
  recovered_eq_formed : recovered = shift.formed
```

Cette structure doit produire :

```lean
DiagonalCertificate Interface VisibleIn projectIn
DiagonalCertificate Interface VisibleOut projectOut
LocalProjectiveRecovery Interface VisibleIn projectIn RepairOf
LocalProjectiveRecovery Interface VisibleOut projectOut RepairOf
```

La production doit être directe :

```text
shift.formed
shift.shadow
shift.sameIn
shift.sameOut
shift.separated
repair
recovered
recovered_eq_formed
```

Il ne faut pas ajouter une hypothèse externe du type :

```text
si une récupération existe alors...
```

La récupération doit être portée par la cellule.

### 6.3 Transport du témoin

Structure candidate abstraite :

```lean
structure OODWitnessTransport
    ...
    (WitnessOf : Interface -> Type q) where
  cell : OODRecoveredCell ...
  witnessOfCell : WitnessOf cell.shift.formed
  witnessIn : WitnessOf cell.shift.formed
  witnessOut : WitnessOf cell.shift.formed
  witnessIn_eq : witnessIn = witnessOfCell
  witnessOut_eq : witnessOut = witnessOfCell
```

Dans une version positive Nat :

```lean
structure OODPositiveWitnessTransport where
  cell : OODRecoveredCell ...
  witnessOfCell : Nat
  witness_pos : 0 < witnessOfCell
  witnessIn : Nat
  witnessOut : Nat
  witnessIn_eq : witnessIn = witnessOfCell
  witnessOut_eq : witnessOut = witnessOfCell
```

Le point n'est pas seulement l'égalité.

Le point est :

```text
égalité du témoin
+ visibleShift
+ shiftSource
+ noProjectiveReconstruction
```

Sans `visibleShift`, l'égalité du témoin est trop faible.

Sans `noProjectiveReconstruction`, le résultat peut encore être lu comme une
simple reconstruction visible.

Avec les deux, le témoin est bien ce qui traverse le shift là où le visible ne
suffit pas.

Avec `shiftSource`, on sait aussi pourquoi ce shift appartient au cadre.

Dans une instance concrète, `witnessOfCell` ne doit pas être choisi librement.
Il doit être une projection directe d'un champ ou d'un théorème de la cellule.

## 7. Théorèmes à démontrer

### 7.1 Certificats diagonaux sous deux projections

```text
oodDiagonalIn
oodDiagonalOut
```

doivent produire :

```text
DiagonalCertificate Interface VisibleIn  projectIn
DiagonalCertificate Interface VisibleOut projectOut
```

### 7.2 Obstruction projective des deux côtés

```text
oodProjectionObstructionIn
oodProjectionObstructionOut
```

doivent produire :

```text
ProjectionObstruction Interface VisibleIn  projectIn
ProjectionObstruction Interface VisibleOut projectOut
```

### 7.3 Non-reconstruction visible

```text
oodNoProjectiveReconstructionIn
oodNoProjectiveReconstructionOut
```

doivent montrer que chaque projection visible seule est insuffisante.

Forme stricte :

```text
projectIn  ne reconstruit pas l'interface ;
projectOut ne reconstruit pas l'interface.
```

Les lectures `readIn` et `readOut` interviennent dans `visibleShift`, pas dans
la non-reconstruction projective, sauf construction explicite de projections
composées.

### 7.4 Survie du témoin sous shift

```text
oodWitnessSurvives
```

doit démontrer :

```text
le témoin interne est conservé
malgré visibleShift.
```

Formulation minimale acceptable :

```text
witnessIn = witness
witnessOut = witness
```

Formulation préférable :

```text
witnessOut est obtenu par transport du même témoin interne.
```

Dans les deux cas, le théorème doit rester couplé au shift visible et aux deux
non-reconstructions projectives.

Le théorème doit aussi exhiber le chemin :

```text
cellule
-> witnessOfCell
-> witnessIn / witnessOut
```

Il ne doit pas se réduire à deux champs posés égaux par définition.

### 7.5 Résultat de synthèse

Le résultat final doit avoir la forme :

```text
visibleShift
+ source structurelle du shift
+ diagonal certificate in
+ diagonal certificate out
+ noProjectiveReconstruction in
+ noProjectiveReconstruction out
+ witness transported
```

Ce résultat est le certificat OOD du cadre.

Il doit se lire ainsi :

```text
le visible change,
ce changement vient d'une source structurelle,
la reconstruction visible échoue des deux côtés,
mais le témoin interne reste porté par la cellule.
```

## 8. Instance arithmétique comme banc d'essai

L'instance arithmétique est le meilleur banc d'essai actuel.

Elle porte déjà :

```text
NatEnrichedParityRole
NatEnrichedParityRelaxedBilateralGap
NatEnrichedParityPositiveInternalDiagonalWitness
NatEnrichedRelaxedOddRole
```

Le témoin positif est :

```text
positiveWitness
=
natEnrichedParityMaximalRelaxedDivergence k
```

avec :

```text
0 < positiveWitness
positiveWitness = divergence du gap relaxé
positiveWitness = divergence maximale
rightPayload = k + positiveWitness
```

L'instance OOD arithmétique doit être construite avec deux lectures visibles
réellement différentes.

Direction stricte :

```text
lecture source du rôle médiateur par son code visible
lecture cible du payload de retour relaxé
```

Il faudra démontrer que ces lectures diffèrent réellement, puis que le témoin
positif reste le même témoin interne de divergence.

Le code existant donne déjà les pièces à ne pas dénaturer :

```text
NatEnrichedRelaxedOddRole k
positiveWitness = natEnrichedParityMaximalRelaxedDivergence k
rightPayload = k + positiveWitness
rightPayload = natEnrichedParityMaximallyRelaxedRightPayload k
```

et la concordance visible :

```text
3 * natEnrichedParityRoleCode mediatingRole + 1
=
2 * rightPayload
```

ainsi que :

```text
(3 * natEnrichedParityRoleCode mediatingRole + 1) / 2
=
rightPayload
```

L'instance OOD ne doit donc pas redéfinir l'impair relaxé.

Elle doit montrer que le même témoin positif porté par `NatEnrichedRelaxedOddRole`
survit à un changement de lecture visible :

```text
lecture source : rôle médiateur non relaxé lu par son code visible
lecture cible  : payload de retour relaxé porté par rightPayload
```

La non-trivialité arithmétique attendue est :

```text
la lecture visible source et la lecture visible cible ne sont pas la même
lecture,
mais elles sont raccordées par le même témoin positif interne.
```

Il faut éviter deux erreurs :

```text
1. réduire le témoin à une égalité numérique visible ;
2. confondre rightPayload avec le témoin.
```

Le témoin est :

```text
positiveWitness
```

Le payload de retour est :

```text
rightPayload = k + positiveWitness
```

La source structurelle du shift arithmétique doit donc être construite à partir
du rôle enrichi, pas à partir d'une lecture constante.

Sources admissibles pour l'instance :

```text
1. la divergence positive :
   positiveWitness = natEnrichedParityMaximalRelaxedDivergence k
   0 < positiveWitness ;

2. le payload de retour :
   rightPayload = k + positiveWitness ;

3. la concordance visible du pas relaxé :
   3 * natEnrichedParityRoleCode mediatingRole + 1 = 2 * rightPayload ;

4. l'obstruction diagonale portée par NatEnrichedRelaxedOddRole.
```

La meilleure instance doit utiliser au moins la divergence positive et le
payload de retour.

La séparation de rôles seule est insuffisante si elle ne produit pas les deux
lectures visibles du shift.

Le verrou technique de l'instance est le choix de :

```text
projectOut
readOut
```

Il faut obtenir simultanément :

```text
sameOut : projectOut formed = projectOut shadow
visibleShift :
  readIn (projectIn formed) = readOut (projectOut formed) -> False
```

Donc :

```text
projectOut doit rester assez contractant pour préserver sameOut ;
readOut doit rester assez structuré pour exposer le shift.
```

Si `projectOut` transporte trop d'information, `sameOut` risque d'échouer.

Si `projectOut` transporte trop peu d'information, le shift risque de devenir
artificiel.

Le fait :

```text
rightPayload = k + positiveWitness
```

ne suffit donc pas seul.

L'objectif arithmétique complet est :

```text
rightPayload = k + positiveWitness
+ 0 < positiveWitness
+ lecture source / lecture cible séparées
+ même cellule formed/shadow
+ sameIn
+ sameOut
```

## 9. Ce qui serait refusé

Sera refusé :

```text
un théorème conditionnel du type :
si le témoin se transporte, alors il se transporte.
```

Sera refusé :

```text
une simple égalité de champs sans preuve de shift visible réel.
```

Sera refusé :

```text
un visibleShift obtenu par des fonctions readIn/readOut constantes ou
arbitraires.
```

Sera refusé :

```text
un visibleShift qui ne porte pas explicitement sa source structurelle.
```

Sera refusé :

```text
un ShiftSource qui est seulement le visibleShift rebaptisé.
```

Sera refusé :

```text
un résultat qui ne produit pas d'obstruction de reconstruction visible.
```

Sera refusé :

```text
une analogie ML sans structure Lean correspondante.
```

Sera refusé :

```text
une instance arithmétique qui introduit un nouveau témoin au lieu de réutiliser
NatEnrichedRelaxedOddRole.positiveWitness.
```

Sera refusé :

```text
un témoin fourni librement au lieu d'être extrait de la cellule.
```

Sera refusé :

```text
une preuve qui ne sépare pas explicitement témoin, lecture source,
lecture cible et payload de retour.
```

Sera refusé :

```text
une instance qui prend la séparation de rôles comme résultat final sans
démontrer le changement de lecture visible correspondant.
```

Sera refusé :

```text
une preuve qui prétend que readIn/readOut ne reconstruisent pas l'interface
alors que seule la non-reconstruction de projectIn/projectOut a été démontrée.
```

## 10. Ce que le résultat prouverait

Si cette phase est implémentée correctement, elle prouvera :

```text
le cadre peut certifier une stabilité OOD structurelle
lorsque la projection visible change.
```

Elle prouvera aussi :

```text
le témoin interne est plus stable que la forme visible.
```

En langage ML/stat :

```text
le cadre fournit un certificat structurel contre les corrélations parasites :
une représentation n'est pas jugée stable parce que la prédiction reste bonne,
mais parce que le témoin opératoire survit au shift visible.
```

Formule finale :

```text
la lecture projective reconnaît des formes ;
le cadre transporte des témoins.
```

Ce résultat ne prouverait pas qu'un algorithme d'apprentissage particulier est
performant sur tout shift.

Il prouverait quelque chose de plus structurel :

```text
le cadre sait formuler et certifier une stabilité interne qui n'est pas
réductible à la stabilité de la projection visible, parce que le shift visible
est lui-même relié à une source structurelle inspectable.
```

C'est exactement le type de certificat qui manque dans les situations OOD :
la projection peut tromper, mais le témoin interne donne un critère plus fort
que la seule performance visible.

## 11. Critère d'achèvement

La phase sera achevée uniquement si le code final prouve :

```text
1. OODProjectionShift avec visibleShift non trivial ;
2. source structurelle explicite du visibleShift ;
3. visibleShift dérivé de cette source, non stocké indépendamment ;
4. deux DiagonalCertificate issus du même formé/shadow sous deux projections ;
5. deux obstructions projectives ;
6. deux non-reconstructions visibles ;
7. non-reconstruction portée par projectIn/projectOut, pas par readIn/readOut ;
8. un témoin interne extrait de la cellule ;
9. une instance arithmétique non triviale.
```

Sans ces neuf points, la phase n'est pas complète.

Le banc d'essai arithmétique doit en plus vérifier :

```text
10. le témoin utilisé est bien celui de NatEnrichedRelaxedOddRole ;
11. le payload de retour reste distinct du témoin ;
12. la concordance visible avec le pas relaxé est conservée ;
13. le shift est dérivé de la divergence positive et/ou du payload de retour ;
14. projectOut/readOut sont construits de façon à obtenir sameOut et visibleShift ;
15. aucune condition externe ne remplace la cellule opératoire.
```

## 12. Ordre d'implémentation

La phase doit être découpée en deux niveaux.

### 12.1 Couche OOD abstraite

Créer une couche abstraite, par exemple :

```text
Meta/OOD/WitnessTransport.lean
```

Cette couche doit contenir le certificat OOD général :

```text
OODProjectionShift
OODRecoveredCell
OODWitnessTransport
OODStructuralCertificate
```

Elle ne doit pas dépendre de l'arithmétique.

Son rôle est de verrouiller :

```text
même cellule opératoire
+ deux projections
+ deux lectures
+ source structurelle du shift
+ shift visible dérivé de cette source
+ témoin transporté
+ non-reconstruction projective des deux côtés
```

Cette couche ne prétend pas encore que `ShiftSource` est substantiel. Elle rend
seulement la provenance formelle et inspectable.

### 12.2 Instance arithmétique

Créer ensuite l'instance arithmétique, par exemple :

```text
Meta/Arithmetic/RelaxedOddOOD.lean
```

Cette instance doit partir de :

```text
NatEnrichedRelaxedOddRole k
```

et produire :

```text
OODStructuralCertificate
```

Le shift ne doit pas être choisi.

Il doit être dérivé des théorèmes déjà présents autour de :

```text
positiveWitness
rightPayload
natEnrichedRelaxedOddRole_visibleOddStep_eq_two_mul_rightPayload
natEnrichedRelaxedOddRole_visibleOddStep_div_two_eq_rightPayload
projectionObstruction
```

Conditions particulières de l'instance :

```text
1. ShiftSource ne doit pas être le visibleShift rebaptisé ;
2. witnessOfCell doit être NatEnrichedRelaxedOddRole.positiveWitness ;
3. projectOut/readOut doivent produire à la fois sameOut et visibleShift ;
4. noProjectiveReconstruction doit porter sur projectIn/projectOut ;
5. rightPayload = k + positiveWitness doit être utilisé avec une séparation
   effective des lectures.
```

La réussite de cette instance dira exactement :

```text
la lecture visible change,
le changement est produit par la divergence relaxée,
le témoin positif interne reste conservé.
```
