# Plan de cloture de l'orbite constructive et de l'instance Foundation

## 0. Objet

Le mecanisme central est maintenant habite et causal :

```text
gap_n
-> usage_n
-> transport_n
-> repair_n
-> candidat_(n+1)
-> gap_(n+1).
```

Deux travaux restent. Ils sont distincts et doivent etre fermes dans cet ordre :

```text
A. decrire exactement l'orbite du modele syntaxique fini deja construit ;
B. instancier le meme mecanisme sur la syntaxe arithmetique reelle de Foundation.
```

Le premier travail prouve la geometrie globale de l'instance actuelle. Le
second change d'instance ; il ne peut pas etre remplace par un renommage du
modele fini, par le theoreme officiel de Tarski ou par un pont conditionnel.

## 1. Frontiere apres suppression de l'ancienne API

La voie qui patchait directement une fonction semantique
`Sentence -> Prop` est supprimee. Elle est interdite dans la suite.

La seule chaine causale admise est interne au type des candidats :

```text
Predicate
-> diagonalSentence
-> LocalTruthMismatch
-> patchPredicate
-> nextPredicate : Predicate
-> LocalTruthMismatch suivant.
```

Le noyau reutilisable est :

```text
Meta/Tarski/TruthGap.lean
  ArithmeticTarskiContext
  PatchableArithmeticTarskiContext

Meta/Tarski/DynamicRelaxedUsage.lean
  TarskiDynamicRelaxedUsageSynthesis
  tarskiPatchGapDrivenDynamicSystem
  tarskiPatchIterate_eq_iteratePredicate

Meta/Tarski/ConstructivePatchModel.lean
  constructivePatchableTarskiContext
  constructiveTarskiClosedSystem.
```

## 2. Contraintes de fond

Chaque nouveau fichier Lean doit respecter simultanement :

```text
aucun axiom ;
aucun sorry ou admit ;
aucun Classical ;
aucun propext ;
aucun Quot.sound ;
aucun noncomputable ;
aucun unsafe ;
un unique bloc AXIOM_AUDIT a la fin du fichier.
```

Sont egalement interdits :

```text
un candidat defini comme une fonction semantique arbitraire ;
un patch donne comme fonction externe ;
un next independant du gap courant ;
Use, RepairOf, WitnessOf ou OutRel remplaces par Unit ;
une projection constante comme unique preuve de coordination ;
une contradiction utilisee pour fabriquer une donnee positive ;
un rang, une fenetre ou un pont terminal ajoutes comme hypothese ;
un alias vers le theoreme officiel presente comme derivation projective ;
une conclusion Foundation conditionnee par un adaptateur non construit.
```

Les entiers `n`, `k` et `m` peuvent indexer des theoremes d'iteration. Ils ne
doivent pas etre reintroduits comme champ externe certifiant artificiellement
la fermeture d'un etat.

## 3. Graphe cible

```text
TruthGap
  |
  v
DynamicRelaxedUsage
  |
  v
ConstructivePatchModel
  |
  v
ConstructivePatchOrbit

Foundation syntax + rewriting + Nat semantics
  |
  v
FoundationConstructiveDiagonal
  |
  v
FoundationPatchableContext
  |
  v
FoundationDynamicRelaxedUsage
  |
  v
FoundationBridge
```

`ConstructivePatchOrbit` ne doit pas importer Foundation. Les modules
Foundation ne doivent pas importer le modele fini pour obtenir leurs preuves.
Les deux branches partagent seulement les interfaces abstraites de Tarski et
de l'usage relaxe.

# Partie A - Theorie exacte de l'orbite concrete

## 4. Nouveau module

Creer :

```text
Meta/Tarski/ConstructivePatchOrbit.lean
```

avec l'unique import :

```lean
import Meta.Tarski.ConstructivePatchModel
```

Le fichier doit exposer une description calculable de chaque itere, pas
seulement deux premieres transitions et une induction d'incompletude.

## 5. Forme canonique des supports

Introduire une liste descendante sans duplicate :

```lean
def descendingSupport : Nat -> List Nat
  | 0 => []
  | Nat.succ n => Nat.succ n :: descendingSupport n

def orbitCandidate (n : Nat) : PatchCandidate :=
  { acceptedAtoms := descendingSupport n }

def orbitIndex (n : Nat) : PatchSentence :=
  PatchSentence.atom (Nat.succ n)
```

La forme attendue est exactement :

```text
descendingSupport 0 = []
descendingSupport 1 = [1]
descendingSupport 2 = [2, 1]
...

candidat_n accepte exactement 1, ..., n ;
index_n = atom (n + 1).
```

Le choix d'une liste descendante correspond definitionnellement au patch
actuel, qui ajoute le nouvel atome en tete. Il n'introduit aucune nouvelle
dynamique.

## 6. Lemmes structurels requis

Prouver constructivement :

```text
length (descendingSupport n) = n ;

maximumAtom (descendingSupport n) = n ;

(k > 0 et k <= n)
-> containsAtom (descendingSupport n) k = true ;

containsAtom (descendingSupport n) k = true
-> k > 0 et k <= n ;

containsAtom (descendingSupport n) (n + 1) = false.
```

La preuve de caracterisation doit utiliser la recursion de
`descendingSupport`, `containsAtom` et `maximumAtom`. Elle ne doit pas invoquer
une extensionnalite de listes ou d'ensembles obtenue classiquement.

Ajouter ensuite :

```text
orbitCandidate n .fresh = n + 1 ;

patchDiagonal (orbitCandidate n) = orbitIndex n ;

patchCandidate (orbitCandidate n) (orbitIndex n)
= orbitCandidate (n + 1).
```

## 7. Formule exacte de l'iteration

Le theoreme principal de calcul syntaxique doit etre :

```lean
theorem iteratePredicate_initial_eq_orbitCandidate
    (n : Nat) :
    constructivePatchableTarskiContext.iteratePredicate
        n
        initialPatchCandidate =
      orbitCandidate n
```

La version dynamique doit etre derivee du theoreme deja existant qui identifie
les deux iterations :

```lean
theorem dynamicIterate_initial_eq_orbitCandidate
    (n : Nat) :
    constructiveGapDrivenSystem.iterateSource
        n
        initialPatchCandidate =
      orbitCandidate n
```

Il est interdit de redemontrer une seconde fois l'equivalence entre iteration
dynamique et syntaxique ou d'introduire une fonction `next` concurrente.

## 8. Accord cumulatif et nouveau gap

Pour chaque rang `n`, prouver les quatre proprietes distinctes :

```text
1. rejet courant :
   candidat_n(index_n) = false ;

2. reparation immediate :
   candidat_(n+1)(index_n) = true ;

3. persistance :
   k < n -> candidat_n(index_k) = true ;

4. nouveau mismatch :
   candidat_(n+1) rejette index_(n+1)
   alors que patchModels index_(n+1).
```

Les enonces publics doivent etre donnes dans le vocabulaire semantique du
contexte patchable :

```text
truthAt candidat_n index_k
models index_k
LocalTruthMismatch au rang n.
```

Les egalites booleennes restent des lemmes de calcul internes utilises pour
prouver ces enonces.

## 9. Separation globale de l'orbite

Prouver :

```text
orbitIndex k = orbitIndex n -> k = n ;

orbitCandidate k = orbitCandidate n -> k = n ;

iteratePredicate k initial = iteratePredicate n initial -> k = n ;

iterateSource k initial = iterateSource n initial -> k = n.
```

La separation des candidats doit etre obtenue par la longueur exacte de leur
support, ou par un ancien challenge accepte d'un cote et refuse de l'autre.
Elle ne doit pas etre postulee dans une structure.

En deduire pour cette instance particuliere :

```text
p > 0
-> iterateSource (n + p) initial = iterateSource n initial
-> False.
```

Ce resultat est une absence de retour exact de l'orbite concrete. Il ne doit
pas etre remonte en axiome du Core, dont les cycles bilateraux restent licites.

## 10. Paquet de cloture de l'orbite

Ajouter une structure de resultats, sans champs libres permettant de choisir
une autre orbite :

```text
ConstructiveTarskiOrbitTheorem
```

Elle doit conserver au minimum :

```text
la formule exacte du candidat au rang n ;
la formule exacte de l'indice au rang n ;
l'accord cumulatif sur tous les challenges anterieurs ;
le rejet du challenge courant ;
la reparation au rang suivant ;
la distinction deux a deux des indices ;
la distinction deux a deux des candidats ;
l'absence de retour exact ;
l'incompletude globale de chaque itere ;
l'identite des iterations dynamique et syntaxique.
```

Construire un habitant ferme :

```lean
def constructiveTarskiOrbitTheorem :
    ConstructiveTarskiOrbitTheorem
```

Ce paquet doit referencer les definitions canoniques existantes. Il ne recoit
ni orbite, ni fonction de transition, ni preuve de fraicheur comme argument.

## 11. Criteres de cloture de la partie A

La partie A est terminee seulement si :

```text
iterate n initial = candidat_n est compile pour tout n ;
index_n = atom (n + 1) est compile pour tout n ;
les accords passes et le mismatch courant sont tous exposes ;
l'orbite est injective ;
l'absence de retour exact est derivee ;
le paquet ferme est habite ;
l'audit du nouveau fichier est vide d'axiomes interdits.
```

# Partie B - Instance arithmetique Foundation reelle

## 12. Obstacle actuel a traiter explicitement

Le fichier actuel :

```text
Meta/Tarski/FoundationBridge.lean
```

importe le theoreme final de Foundation et le renomme. Il ne construit pas le
contexte arithmetique local.

De plus, l'implementation Foundation actuellement utilisee de
`Bootstrapping.FixedPoint` ouvre `Classical` et declare ses constructeurs
`diag` et `fixedpoint` comme `noncomputable`. Cette voie ne peut donc pas etre
importee silencieusement dans le noyau constructif exige ici.

Ce constat est un verrou d'implementation, pas une permission d'affaiblir la
cible. La partie B doit construire un diagonaliseur syntaxique calculable sur
les types Foundation, ou elle n'est pas terminee. Aucun theoreme conditionnel
ne sera livre comme substitut.

## 13. Types Foundation obligatoires

L'instance finale doit utiliser exactement :

```text
Sentence  := LO.FirstOrder.Sentence LO.FirstOrder.Arithmetic.ℒₒᵣ
Predicate := LO.FirstOrder.Semisentence
               LO.FirstOrder.Arithmetic.ℒₒᵣ 1

models sentence := Nat ⊧ₘ sentence

applyQuote tau sentence := tau/[⌜sentence⌝]
```

Une syntaxe locale isomorphe, une liste d'atomes ou un predicat Lean
`Sentence -> Prop` ne satisfait pas ce jalon.

## 14. Frontiere constructive Foundation

Creer d'abord :

```text
Meta/Tarski/FoundationConstructiveSyntax.lean
```

Ce module doit importer seulement les briques Foundation necessaires pour :

```text
construire des sentences et semisentences ;
former negation, conjonction, disjonction et egalite ;
injecter un numeral ferme ;
substituer ce numeral dans une semisentence unaire ;
evaluer la formule obtenue dans Nat ;
coder une sentence et prouver l'injectivite du codage utilise.
```

Avant toute diagonalisation, chaque declaration Foundation reutilisee dans la
chaine finale doit etre auditee par `#print axioms`. Toute declaration qui
depend de `Classical.choice`, `propext` ou `Quot.sound` doit etre remplacee par
une construction syntaxique locale sur les memes types Foundation.

Il n'existe pas de voie de secours semantique. Si la citation officielle
`⌜sentence⌝` n'est pas calculable dans cette frontiere, il faut en extraire une
version calculable et prouver son egalite avec le codage Foundation avant de
continuer.

## 15. Diagonaliseur Foundation constructif

Creer :

```text
Meta/Tarski/FoundationConstructiveDiagonal.lean
```

Le module doit definir, sans appeler le `fixedpoint` non calculable existant :

```lean
def foundationDiagonalSentence
    (tau : Semisentence ℒₒᵣ 1) :
    Sentence ℒₒᵣ
```

et prouver directement par la semantique de la reecriture :

```text
Nat ⊧ₘ foundationDiagonalSentence tau
<->
not (Nat ⊧ₘ tau/[⌜foundationDiagonalSentence tau⌝]).
```

La preuve doit suivre le calcul syntaxique :

```text
construction du code de la matrice diagonale ;
substitution de son propre numeral ;
evaluation de la substitution ;
evaluation de la negation du candidat.
```

Elle ne doit pas passer par :

```text
Foundation.undefinability_of_truth ;
la consistance d'une theorie ;
une completude semantique ;
un choix global de point fixe ;
un axiome de codage fourni comme champ.
```

## 16. Contexte arithmetique ferme

A partir du diagonaliseur, construire :

```lean
def foundationArithmeticTarskiContext :
    ArithmeticTarskiContext
```

avec les types et operations exacts de la section 13.

Le champ `diagonal_spec` doit etre le theoreme semantique de la section 15. Il
ne peut pas etre une consequence du theoreme final d'indefinissabilite, sous
peine de circularite.

Ajouter les resultats positifs :

```text
pour tout tau, une phrase diagonale explicite ;
pour tout tau, un TarskiPositiveDiagonal habite ;
pour tout tau, un LocalTruthMismatch habite ;
pour tout tau, un contre-exemple local explicite a la correction globale.
```

## 17. Patch syntaxique arithmetique

Creer :

```text
Meta/Tarski/FoundationPatchableContext.lean
```

Pour `tau : Semisentence ℒₒᵣ 1` et `sigma : Sentence ℒₒᵣ`, definir une nouvelle
semisentence unaire representant :

```text
(x = code(sigma) et sigma)
ou
(tau(x) et x != code(sigma)).
```

Le patch doit etre un arbre syntaxique Foundation. Il ne doit pas inspecter la
valeur semantique de `sigma` dans sa definition.

Prouver par evaluation dans Nat :

```text
patch_agrees_at :
  models (applyQuote (patch tau sigma) sigma)
  <-> models sigma ;

patch_preserves_off_index :
  pi != sigma
  ->
  (models (applyQuote (patch tau sigma) pi)
   <-> models (applyQuote tau pi)).
```

La seconde preuve doit utiliser l'injectivite constructive du codage des
sentences :

```text
pi != sigma -> code(pi) != code(sigma).
```

Construire ensuite, sans argument restant :

```lean
def foundationPatchableTarskiContext :
    PatchableArithmeticTarskiContext
```

## 18. Dynamique Foundation fermee

Creer :

```text
Meta/Tarski/FoundationDynamicRelaxedUsage.lean
```

Choisir un candidat initial syntaxique explicite, par exemple la semisentence
fausse `x != x`, puis construire :

```text
foundationInitialPredicate
foundationTarskiDynamicRelaxedUsageSynthesis
foundationGapDrivenDynamicSystem
foundationFirstPredicate
foundationSecondPredicate.
```

Prouver :

```text
le candidat initial possede un mismatch diagonal ;
le gap initial autorise le repair syntaxique ;
le repair produit definitionnellement le premier candidat ;
le premier candidat repare son ancien indice ;
le premier candidat possede un nouvel indice et un nouveau mismatch ;
le second etat est produit depuis ce nouveau gap ;
chaque itere reste globalement incomplet ;
la dynamique Foundation n'est pas exactement projectivement representable.
```

Les preuves de changement d'etat doivent venir du mismatch generique et de la
loi de patch. Une inegalite syntaxique postulee est interdite.

## 19. Remplacement du pont nominal

Une fois les sections 14 a 18 compilees, modifier :

```text
Meta/Tarski/FoundationBridge.lean
```

Le theoreme public final doit etre derive de :

```text
foundationArithmeticTarskiContext
-> explicitTruthCounterexample
-> TarskiPositiveDiagonal
-> obstruction projective
-> indefinissabilite globale.
```

Il doit avoir exactement la forme Foundation :

```text
not exists tau : Semisentence ℒₒᵣ 1,
  forall sentence : Sentence ℒₒᵣ,
    (Nat models sentence)
    <->
    (Nat models tau/[code(sentence)]).
```

Le corps de la preuve ne doit contenir aucun appel a :

```text
LO.FirstOrder.Arithmetic.undefinability_of_truth
foundationProjectiveTarskiStatement_from_official.
```

Le nom de compatibilite `from_projectiveGap` ne peut etre conserve que s'il
pointe desormais vers cette derivation effective. Le theoreme `from_official`
doit etre supprime de la couche active ou deplace dans un module Legacy qui
n'est importe ni par `Meta.lean` ni par le noyau constructif.

## 20. Orbite arithmetique : objectif apres l'instance

L'instance Foundation doit au minimum exposer l'iteration. Elle ne doit pas
revendiquer immediatement la meme formule fermee que le modele a listes.

Les invariants a prouver ensuite sont :

```text
chaque candidat est une semisentence Foundation construite ;
chaque indice est une sentence Foundation construite ;
le candidat n + 1 corrige l'indice n ;
les corrections anterieures sont preservees lorsqu'elles portent
sur des sentences distinctes du nouvel indice ;
chaque rang produit un mismatch local ;
aucun rang ne donne une definition globale de la verite.
```

La distinction deux a deux des indices arithmetiques exigera une propriete de
fraicheur syntaxique supplementaire. Elle ne doit pas etre affirmee avant
d'avoir ete derivee d'un codage ou d'un generateur interne concret.

## 21. Audits et compilation

Pour chaque fichier Lean cree ou modifie :

```text
exactement un AXIOM_AUDIT ;
bloc place a la fin ;
noms audites existants ;
sortie sans axiome interdit.
```

Executer a chaque etape :

```text
lake env lean <fichier>
```

Puis, aux deux clotures :

```text
lake build Meta.Tarski.ConstructivePatchOrbit

lake build Meta.Tarski.FoundationConstructiveSyntax
lake build Meta.Tarski.FoundationConstructiveDiagonal
lake build Meta.Tarski.FoundationPatchableContext
lake build Meta.Tarski.FoundationDynamicRelaxedUsage
lake build Meta.Tarski.FoundationBridge
lake build
```

Le controle textuel final doit exclure des nouveaux modules :

```text
axiom
sorry
admit
Classical
propext
Quot.sound
noncomputable
unsafe.
```

## 22. Ordre d'execution

```text
1. Formaliser descendingSupport et ses lemmes de calcul.
2. Prouver la forme exacte de l'iteration syntaxique.
3. Transferer cette forme a l'iteration dynamique.
4. Prouver accord cumulatif, separation et absence de retour.
5. Fermer ConstructiveTarskiOrbitTheorem.
6. Auditer la frontiere constructive des types Foundation.
7. Construire la citation et la substitution calculables necessaires.
8. Construire le diagonaliseur Foundation constructif.
9. Fermer foundationArithmeticTarskiContext.
10. Construire le patch arithmetique et ses deux lois semantiques.
11. Fermer foundationPatchableTarskiContext.
12. Instancier la dynamique Foundation sur un candidat initial syntaxique.
13. Remplacer le pont nominal par la derivation projective effective.
14. Compiler le depot entier et archiver les sorties d'audit.
```

## 23. Definition de termine

Le chantier est termine seulement lorsque les deux enonces suivants sont des
theoremes compiles et constructifs :

```text
Modele ferme :
  l'orbite issue du candidat vide a au rang n
  le support [n, ..., 1], l'indice atom (n + 1),
  conserve toutes les corrections anterieures,
  reste globalement incomplete et ne revient jamais exactement.

Foundation :
  chaque semisentence unaire candidate produit une sentence diagonale
  Foundation, un mismatch local, un patch syntaxique Foundation et un
  candidat suivant ; l'indefinissabilite officielle est derivee de cette
  production sans appel au theoreme officiel deja prouve.
```

Tout resultat plus faible, conditionnel ou seulement isomorphe reste une etape
intermediaire et ne ferme pas ce plan.
