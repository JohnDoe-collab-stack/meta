# Critique du plan OOD par temoin interne

## Verdict court

Le plan `OODWitnessGeneralizationPlan.md` est une direction solide.

Il ne propose pas seulement une analogie avec l'apprentissage automatique. Il
propose un critere formel testable :

```text
shift visible reel
+ meme cellule operatoire
+ temoin interne conserve
+ obstruction de reconstruction visible
```

Cette combinaison est bien alignee avec le cadre `meta`.

La difficulte principale n'est pas la couche abstraite. La couche abstraite est
implementable.

La difficulte est l'instance arithmetique : il faut produire un `visibleShift`
non artificiel, c'est-a-dire un changement de lecture qui vient vraiment des
roles enrichis et non d'un choix arbitraire de `readIn/readOut`.

## Ce qui est fort

### 1. Le plan refuse la trivialite

Le document impose :

```text
readIn (projectIn formed) != readOut (projectOut formed)
```

ou une separation equivalente.

C'est le bon verrou.

Sans cette preuve, le resultat serait seulement :

```text
la meme cellule garde son temoin
```

ce qui est vrai mais insuffisant pour parler d'OOD.

Le plan exige donc un vrai changement de lecture visible.

### 2. Le plan garde une seule cellule operatoire

Le document refuse deux cellules independantes.

Il impose :

```text
meme formed
meme shadow
meme separation
deux projections visibles
deux lectures visibles
```

C'est essentiel.

Si on utilisait deux cellules, on ne prouverait pas que la meme structure
survit au shift. On comparerait seulement deux constructions separees.

### 3. Le temoin reste interne

Le plan dit explicitement que le temoin ne doit pas etre reconstruit depuis :

```text
readIn
readOut
projectIn
projectOut
```

Il doit etre porte avant la projection :

```text
cellule interne
-> temoin
-> projections visibles
```

Cette orientation est correcte.

Elle evite l'erreur qui consisterait a faire du temoin une simple valeur lue
dans le visible.

### 4. L'obstruction projective est indispensable

Le plan demande :

```text
ProjectionObstruction
LocalProjectiveRecovery
noProjectiveReconstruction
```

C'est le bon niveau.

L'OOD structurel n'est pas :

```text
le visible est invariant
```

mais :

```text
le visible change ou devient insuffisant,
et pourtant le temoin interne reste porte par la cellule.
```

## Ce qui est deja compatible avec le code

La partie arithmetique citee par le document existe deja dans le code.

Dans `Meta/Arithmetic/RelaxedOdd.lean`, `NatEnrichedRelaxedOddRole k` porte :

```text
mediatingRole
relaxedGap
rightPayload
diagonalCertificate
projectionObstruction
positiveWitness
positiveWitness_pos
positiveWitness_eq_maximalDivergence
```

Le code separe bien :

```text
temoin positif
```

et :

```text
payload de retour
```

On a notamment :

```text
positiveWitness = natEnrichedParityMaximalRelaxedDivergence k
rightPayload = k + positiveWitness
```

Cette separation est importante.

L'instance OOD ne devra pas identifier le temoin au payload.

## Point dur principal

Le verrou est le choix de :

```text
projectIn
projectOut
readIn
readOut
```

Il faut obtenir simultanement :

```text
sameIn  : projectIn formed = projectIn shadow
sameOut : projectOut formed = projectOut shadow
visibleShift :
  readIn (projectIn formed) = readOut (projectOut formed) -> False
```

Ce triplet est non trivial.

Pourquoi ?

Parce que `sameIn` et `sameOut` demandent que formed/shadow soient confondus
par chaque projection, tandis que `visibleShift` demande que les lectures
obtenues par les deux regimes soient reellement separees.

Donc l'instance doit etre construite avec precision.

Si les projections sont trop grossieres, on obtient `sameIn/sameOut`, mais le
shift devient artificiel.

Si les projections sont trop riches, on perd `sameIn/sameOut`.

Le bon choix doit donc exposer :

```text
une meme cellule diagonale
confondue localement par chaque projection
mais lue differemment par les deux regimes de lecture
```

## Risque principal

Le risque est de fabriquer le shift.

Exemple de mauvaise implementation :

```text
Label := Bool
readIn  := fun _ => true
readOut := fun _ => false
```

Cela prouverait un shift visible, mais il serait sans contenu.

Ce serait formellement facile et conceptuellement mauvais.

Le shift doit venir d'une difference deja portee par la structure :

```text
role source
role cible
payload source
payload cible
temoin positif
retour relaxe
```

Il faut donc imposer une regle de qualite :

```text
visibleShift doit etre derive d'un theoreme structurel existant,
pas d'une lecture constante choisie pour separer artificiellement les labels.
```

## Critere de shift acceptable

Un `visibleShift` acceptable doit verifier au moins une des conditions
suivantes.

### Option A : separation par role

Le shift est acceptable s'il derive d'une separation de roles deja formalisee,
par exemple :

```text
closingExcess k != mediatingValue k
```

ou d'une separation equivalente.

### Option B : separation par payload structurel

Le shift est acceptable s'il derive d'un ecart de payload deja porte par le
temoin :

```text
rightPayload = k + positiveWitness
0 < positiveWitness
```

Dans ce cas, le shift vient du fait que le retour relaxe porte un excedent
positif interne.

### Option C : separation par obstruction diagonale

Le shift est acceptable s'il est derive d'un `DiagonalCertificate` ou d'une
`ProjectionObstruction` deja presente dans la cellule.

Cette option est la plus proche du cadre.

## Critere de shift refuse

Un shift doit etre refuse s'il vient seulement :

```text
d'un type Label choisi trop librement
d'une fonction readIn/readOut constante
d'une distinction sans lien avec formed/shadow
d'une egalite numerique ajoutee apres coup
d'une reconstruction visible du temoin
```

Dans ces cas, on aurait une preuve Lean, mais pas un resultat OOD structurel.

## Couche abstraite recommandee

Il faut commencer par une couche abstraite :

```text
Meta/OOD/WitnessTransport.lean
```

ou :

```text
Meta/MachineLearning/OODWitness.lean
```

La couche abstraite doit contenir :

```lean
structure OODProjectionShift
structure OODRecoveredCell
structure OODWitnessTransport
structure OODStructuralCertificate
```

Elle doit produire :

```text
oodDiagonalIn
oodDiagonalOut
oodProjectionObstructionIn
oodProjectionObstructionOut
oodNoProjectiveReconstructionIn
oodNoProjectiveReconstructionOut
```

Cette couche est implementable directement a partir de :

```text
DiagonalCertificate
ProjectionObstruction
LocalProjectiveRecovery
noProjectiveReconstruction
```

Elle ne devrait pas utiliser l'arithmetique.

## Pourquoi abstrait d'abord

Il faut eviter de melanger deux problemes :

```text
1. formuler le certificat OOD du cadre ;
2. trouver la bonne instance arithmetique non artificielle.
```

La couche abstraite verrouille le sens exact de :

```text
le temoin traverse le shift
```

L'instance arithmetique vient ensuite comme banc d'essai.

Si on commence directement par l'arithmetique, on risque de confondre :

```text
temoin
payload
code visible
retour relaxe
label
```

## Critique de l'instance arithmetique proposee

L'idee :

```text
lecture source : role mediateur lu par son code visible
lecture cible  : payload de retour relaxe porte par rightPayload
```

est prometteuse.

Elle est prometteuse parce que le code a deja :

```text
3 * code(mediatingRole) + 1 = 2 * rightPayload
(3 * code(mediatingRole) + 1) / 2 = rightPayload
rightPayload = k + positiveWitness
```

Mais elle doit etre maniee avec prudence.

Le code visible du mediateur ne doit pas redevenir la definition de l'impair
relaxe.

La bonne lecture est :

```text
le code visible fournit une concordance de projection,
mais le role relaxe est porte par la structure enrichie.
```

Donc l'instance arithmetique devra dire :

```text
le visible source raccorde le role mediateur ;
le visible cible raccorde le payload de retour ;
le temoin positif reste celui de NatEnrichedRelaxedOddRole ;
le payload de retour est distinct du temoin.
```

## Ce qui serait un vrai resultat

Un vrai resultat serait :

```text
NatEnrichedRelaxedOddRole k
-> OODStructuralCertificate
```

avec :

```text
visibleShift non artificiel
diagonalCertificate in
diagonalCertificate out
projectionObstruction in
projectionObstruction out
noProjectiveReconstruction in
noProjectiveReconstruction out
positiveWitness conserve
rightPayload = k + positiveWitness
```

Cette forme serait forte.

Elle dirait que la relaxation impaire donne une instance concrete de
stabilite OOD structurelle :

```text
la lecture visible change,
mais le temoin positif interne reste la structure stable.
```

## Ce qui resterait limite

Meme avec cette preuve, il ne faudrait pas dire :

```text
le cadre resout la generalisation OOD pour les modeles ML.
```

Il faudrait dire :

```text
le cadre formalise un certificat structurel de stabilite sous shift visible.
```

Ce certificat peut ensuite inspirer des criteres ML, mais il ne donne pas
directement un algorithme d'apprentissage robuste.

## Recommandation

La suite doit se faire en deux phases.

### Phase 1 : OOD abstrait

Implementer :

```text
Meta/OOD/WitnessTransport.lean
```

avec le certificat abstrait complet.

Critere de succes :

```text
aucune instance concrete
aucune arithmetique
aucun choix artificiel de lecture
certificats diagonaux et noProjectiveReconstruction produits des deux cotes
```

### Phase 2 : instance arithmetique

Implementer :

```text
Meta/Arithmetic/RelaxedOddOOD.lean
```

ou :

```text
Meta/OOD/ArithmeticRelaxedOdd.lean
```

Critere de succes :

```text
le temoin est exactement NatEnrichedRelaxedOddRole.positiveWitness
le shift est derive d'une separation structurelle
rightPayload reste distingue du temoin
la concordance visible avec le pas relaxe est conservee
```

## Conclusion

Le plan est bon.

Il peut produire une vraie avance du cadre si l'implementation respecte deux
regles :

```text
1. abstraire d'abord le certificat OOD ;
2. refuser tout visibleShift artificiel dans l'instance arithmetique.
```

Le resultat attendu n'est pas :

```text
une analogie ML
```

mais :

```text
un certificat formel de stabilite structurelle sous changement de lecture
visible.
```

C'est exactement dans la ligne du cadre :

```text
la projection peut changer,
le temoin interne reste l'objet stable.
```

