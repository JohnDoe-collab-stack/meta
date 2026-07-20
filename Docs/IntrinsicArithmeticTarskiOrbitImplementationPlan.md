# Plan d'implementation d'une orbite de Tarski arithmetique intrinseque

## 0. Decision et objectif

L'objectif n'est pas de construire un second modele jouet de Tarski, ni de
reformuler la diagonalisation comme un constructeur semantique primitif.

La cible est la suivante :

```text
syntaxe arithmetique brute {0, S, +, *, =, ->, /\, \/, forall, exists}
        |
        v
codage de Goedel calculable et injectif
        |
        v
substitution syntaxique et substitution sur les codes
        |
        v
representabilite arithmetique de la substitution diagonale
        |
        v
lemme diagonal construit dans la syntaxe arithmetique
        |
        v
patch syntaxique intrinseque
        |
        v
PatchableArithmeticTarskiContext ferme
        |
        v
theoreme generique d'orbite injective
```

Le resultat final doit etre independant de la bibliotheque externe
`Foundation`. Le fichier historique `Meta/Tarski/FoundationBridge.lean` peut
rester dans le depot, mais il ne doit pas etre importe par `Meta.lean` ni par
un module de la nouvelle chaine.

Le critere central est plus fort que la seule absence d'axiomes : le point fixe
doit etre **produit** par le codage, la substitution et leur representabilite
arithmetique. Il ne doit pas etre suppose ou incorpore dans la grammaire.

### 0.1 Etat d'execution au 20 juillet 2026

```text
G0 fermee : prototypes fixed/closed retires de Meta.lean ;
G1 fermee : syntaxe nue et scoping positif ;
G2 fermee : semantique Nat et substitution capture-avoiding ;
G3 fermee : coupleur local, decodeurs, round-trips et quotation injective ;
G4 fermee : substitution diagonale totale sur les codes ;
G5 ouverte : langage PR positif et relation d'execution construits,
             addition, doublement, coupleur, controle, parite, moitie et
             deux composantes du decoupleur deja internalises,
             programme PR de substitution encore a construire ;
G6-G10 non fermees.
```

Un premier essai avec l'appariement de Mathlib a ete rejete par l'audit parce
qu'il faisait remonter `propext`, `Classical.choice` et `Quot.sound`. Le module
`Coding.lean` utilise desormais un coupleur et un decoupleur locaux, dont tous
les audits sont vides.

La semantique du langage PR est actuellement une relation inductive positive
`PRFunction.Evaluates`. Un evaluateur mutuellement recursif teste pendant
l'implementation a ete rejete parce que son equationneur faisait remonter
`propext`. Fermer G5 demande donc de construire le programme de substitution,
puis de prouver existence, fonctionnalite et correction de son execution sans
reintroduire cet evaluateur impropre.

## 1. Etat actuel et decision de conservation

### 1.1 Resultat acquis

Le fichier suivant est conserve comme noyau valide :

```text
Meta/Tarski/GenericPatchOrbit.lean
```

Il etablit, pour tout `PatchableArithmeticTarskiContext` :

```text
correction cumulative des anciens defis ;
fraicheur du nouveau defi derivee du mismatch ;
injectivite des indices diagonaux ;
injectivite des candidats syntaxiques ;
injectivite de l'orbite dynamique ;
absence de retour de periode positive ;
incompletude globale de chaque candidat.
```

Ce resultat ne depend d'aucun rang, d'aucune fenetre, d'aucun atome frais
fourni de l'exterieur et d'aucun pont terminal.

### 1.2 Prototype a sortir du chemin de preuve principal

Les fichiers actuels :

```text
Meta/Tarski/IntrinsicArithmeticSyntax.lean
Meta/Tarski/IntrinsicArithmeticPatch.lean
```

constituent un prototype reflexif utile pour tester l'interface, mais pas
l'instance arithmetique finale. Les constructeurs suivants sont incompatibles
avec la cible :

```lean
RawFormula.closed
RawFormula.fixed
```

`fixed` rend la loi diagonale presque definitionnelle. `closed` remplace une
propriete de cloture syntaxique par une instruction semantique. Ils ne doivent
apparaitre dans aucune declaration finale.

Decision d'execution :

1. ne pas utiliser ces deux fichiers comme preuve de l'ancrage arithmetique ;
2. retirer leurs imports de `Meta.lean` pendant la reconstruction ;
3. conserver `GenericPatchOrbit.lean` dans l'agregateur principal ;
4. reutiliser uniquement les fragments dont l'audit est independant de
   `closed` et `fixed`, apres extraction dans des modules non reflexifs ;
5. ne supprimer ni renommer les prototypes sans decision explicite.

### 1.3 Fragments reutilisables sous audit

Les fragments suivants peuvent etre repris, mais pas copies aveuglement :

```text
le coupleur naturel constructif et sa preuve d'injectivite ;
la structure de l'evaluation des termes ;
les environnements de De Bruijn ;
les preuves de substitution des termes ;
la forme syntaxique du patch.
```

Chaque fragment extrait doit recevoir son propre audit. Une dependance propre
dans le prototype ne dispense pas d'auditer la nouvelle declaration.

## 2. Enonce cible exact

La chaine finale doit produire une valeur fermee de la forme :

```lean
def bareArithmeticTarskiClosedSystem :
    BareArithmeticTarskiClosedSystem
```

Cette valeur doit contenir au minimum :

```text
1. une syntaxe arithmetique sans constructeur reflexif ;
2. une semantique standard dans Nat ;
3. une quotation injective ;
4. une substitution syntaxique correcte ;
5. une substitution diagonale calculable sur les codes ;
6. une formule arithmetique representant son graphe ;
7. un diagonaliseur syntaxique et sa specification ;
8. un patch syntaxique et ses deux lois ;
9. un PatchableArithmeticTarskiContext ferme ;
10. l'instance du GenericPatchOrbitTheorem ;
11. un certificat de non-trivialite semantique et dynamique.
```

La specification diagonale finale reste exactement celle attendue par le
contexte generique :

```lean
models (diagonal tau) <->
  (models (applyQuote tau (diagonal tau)) -> False)
```

Mais cette equivalence doit etre derivee d'un theoreme de representabilite et
d'un calcul de codes, pas de la definition de `Holds`.

## 3. Contraintes non negociables

Pour tous les nouveaux fichiers Lean :

```text
aucun axiom ;
aucun sorry ou admit ;
aucun Classical ;
aucun propext ;
aucun Quot.sound ;
aucun unsafe ;
aucun noncomputable pour le codage ou la substitution ;
un unique bloc AXIOM_AUDIT a la fin du fichier.
```

Sont interdits dans la solution finale :

```text
un constructeur de formule fixed, diagonal, quote ou closed ;
une clause semantique qui mentionne le code de la formule en cours d'evaluation ;
un diagonaliseur fourni comme champ sans construction ;
une fonction arithmetique ajoutee comme symbole primitif uniquement pour
  obtenir la diagonalisation ;
un theoreme "si la substitution est representable, alors..." livre comme
  resultat terminal ;
un decodeur partiel dont la correction n'est prouvee que sur une hypothese
  externe non transportee par les types ;
un rang, une fenetre ou un pont terminal ;
une egalite de propositions obtenue par extensionnalite ;
une contradiction utilisee pour fabriquer une donnee syntaxique positive.
```

L'usage de `Nat` pour indexer une iteration ou un code est normal. Ce qui est
interdit est de transformer un rang externe en certificat artificiel de
fraicheur ou de fermeture.

## 4. Architecture des modules

La nouvelle chaine doit etre separee en modules courts, chacun ferme par une
porte d'acceptation.

```text
Meta/Tarski/BareArithmetic/Syntax.lean
Meta/Tarski/BareArithmetic/Scoping.lean
Meta/Tarski/BareArithmetic/Semantics.lean
Meta/Tarski/BareArithmetic/Substitution.lean
Meta/Tarski/BareArithmetic/Coding.lean
Meta/Tarski/BareArithmetic/CodeSubstitution.lean
Meta/Tarski/BareArithmetic/PrimitiveRecursive.lean
Meta/Tarski/BareArithmetic/PrimitiveRecursiveArithmetic.lean
Meta/Tarski/BareArithmetic/PrimitiveRecursiveControl.lean
Meta/Tarski/BareArithmetic/PrimitiveRecursiveUnpair.lean
Meta/Tarski/BareArithmetic/Representability.lean
Meta/Tarski/BareArithmetic/Diagonal.lean
Meta/Tarski/BareArithmetic/Patch.lean
Meta/Tarski/BareArithmetic/ClosedOrbit.lean
```

Graphe d'import cible :

```text
Syntax
  |
  +--> Scoping
  |
  +--> Semantics
  |
  +--> Substitution
          |
          v
        Coding
          |
          v
    CodeSubstitution
          |
          v
  PrimitiveRecursive
          |
          v
   Representability
          |
          v
       Diagonal
          |
          v
        Patch
          |
          +----------------------+
                                 v
GenericPatchOrbit ----------> ClosedOrbit
```

Aucun de ces modules ne doit importer :

```text
Foundation.*
Meta.Tarski.FoundationBridge
Meta.Tarski.IntrinsicArithmeticSyntax
Meta.Tarski.IntrinsicArithmeticPatch
Meta.Tarski.ConstructivePatchModel
```

## 5. Phase 0 - Remise a zero des claims

### Travail

1. retirer temporairement de `Meta.lean` les imports des deux prototypes
   reflexifs ;
2. conserver l'import de `GenericPatchOrbit.lean` ;
3. ajouter un commentaire de statut dans le plan historique indiquant que
   l'ancienne voie Foundation n'est plus la voie principale ;
4. verifier que `lake build Meta` ne traverse ni Foundation ni le prototype
   reflexif.

### Porte G0

```text
Meta compile ;
GenericPatchOrbit reste expose ;
FoundationBridge est peripherique ;
aucun claim "arithmetique ferme" ne repose sur fixed ou closed.
```

La suite est bloquee si G0 echoue.

## 6. Phase 1 - Syntaxe arithmetique nue

### 6.1 Grammaire

Le fichier `Syntax.lean` doit contenir uniquement :

```lean
inductive RawTerm where
  | bvar : Nat -> RawTerm
  | zero : RawTerm
  | succ : RawTerm -> RawTerm
  | add : RawTerm -> RawTerm -> RawTerm
  | mul : RawTerm -> RawTerm -> RawTerm

inductive RawFormula where
  | falsum : RawFormula
  | equal : RawTerm -> RawTerm -> RawFormula
  | conj : RawFormula -> RawFormula -> RawFormula
  | disj : RawFormula -> RawFormula -> RawFormula
  | impl : RawFormula -> RawFormula -> RawFormula
  | all : RawFormula -> RawFormula
  | ex : RawFormula -> RawFormula
```

Les numeraux sont soit des abreviations de `succ`, soit une optimisation dont
la compilation vers `zero/succ` est prouvee. Ils ne doivent pas modifier la
puissance expressive de la grammaire.

### 6.2 Cloture et arite comme proprietes

`Scoping.lean` doit definir :

```lean
def RawTerm.WellScoped : Nat -> RawTerm -> Prop
def RawFormula.WellScoped : Nat -> RawFormula -> Prop

structure Sentence where
  raw : RawFormula
  closed : raw.WellScoped 0

structure Predicate where
  raw : RawFormula
  unary : raw.WellScoped 1
```

Il faut prouver la monotonie du scoping :

```text
WellScoped n objet -> n <= m -> WellScoped m objet.
```

Cette monotonie remplacera le constructeur reflexif `closed` lors de
l'insertion d'une phrase fermee dans un predicat unaire.

### Porte G1

```text
la grammaire ne contient aucun constructeur reflexif ;
Sentence et Predicate sont habites ;
leurs champs de scoping sont constructifs ;
les audits sont vides.
```

Ajouter un test textuel bloquant :

```bash
rg -n "fixed|closed : RawFormula|diagonal : RawFormula" \
  Meta/Tarski/BareArithmetic
```

Le resultat ne doit contenir aucune declaration interdite.

## 7. Phase 2 - Semantique et substitution

### 7.1 Semantique standard

`Semantics.lean` doit definir structurellement :

```lean
abbrev Environment := Nat -> Nat
def RawTerm.evaluate : RawTerm -> Environment -> Nat
def RawFormula.Holds : RawFormula -> Environment -> Prop
def Sentence.models : Sentence -> Prop
```

La clause `Holds` ne peut inspecter ni quotation, ni code, ni formule parente.
Elle ne fait qu'interpreter les constructeurs de la grammaire.

### 7.2 Substitution generale

`Substitution.lean` doit definir une substitution de termes, et pas seulement
le remplacement par un numeral :

```lean
def RawTerm.rename
def RawFormula.rename
def RawTerm.substitute
def RawFormula.substitute
def RawFormula.instantiateTerm
def RawFormula.instantiateNumeral
```

Obligations :

```text
identite de renommage ;
composition des renommages ;
identite de substitution ;
composition substitution/renommage ;
preservation du scoping ;
lemme semantique pour les termes ;
lemme semantique pour les formules ;
independance de l'environnement pour les phrases fermees.
```

Le dernier lemme doit avoir une forme constructive :

```lean
theorem Sentence.holds_environment_independent
    (sentence : Sentence)
    (left right : Environment) :
    sentence.raw.Holds left <-> sentence.raw.Holds right
```

Il faut eviter une egalite de fonctions d'environnement ; l'enonce doit etre
prouve par induction syntaxique ou par accord pointwise.

### Porte G2

```text
substitution generale executable ;
scoping preserve ;
semantique de substitution prouvee ;
aucune extensionnalite fonctionnelle interdite dans les dependances.
```

## 8. Phase 3 - Codage et decodage de Goedel

### 8.1 Coupleur total

`Coding.lean` doit fournir un coupleur calculable :

```lean
def pair : Nat -> Nat -> Nat
def unpair : Nat -> Nat × Nat
theorem unpair_pair
theorem pair_injective
```

Le coupleur doit etre implemente localement ou importe seulement si son audit
est propre. Une preuve Mathlib qui introduit une dependance interdite doit etre
remplacee par une preuve structurelle locale.

### 8.2 Codes syntaxiques

Definir :

```lean
def RawTerm.code : RawTerm -> Nat
def RawFormula.code : RawFormula -> Nat
def decodeTerm : Nat -> Option RawTerm
def decodeFormula : Nat -> Option RawFormula
```

Obligations fortes :

```lean
decodeTerm (term.code) = some term ;
decodeFormula (formula.code) = some formula ;
RawTerm.code injectif ;
RawFormula.code injectif ;
les codes des sous-objets sont strictement inferieurs au code parent,
ou une mesure explicite alternative justifie la terminaison du decodeur.
```

La quotation des phrases est :

```lean
def quote (sentence : Sentence) : Nat := sentence.raw.code
```

Son injectivite doit tenir compte des preuves de scoping sans utiliser une
extensionnalite propositionnelle. L'egalite des structures doit etre obtenue
par l'egalite de leur champ `raw`, les preuves etant irrelevantes dans le
noyau.

### Porte G3

```text
round-trip decode/encode prouve ;
quotation injective ;
aucune branche du decodeur n'est specifiee par une hypothese externe ;
codage et decodage sont calculables.
```

## 9. Phase 4 - Substitution sur les codes

`CodeSubstitution.lean` doit construire une fonction totale sur `Nat` :

```lean
def substituteCode : Nat -> Nat -> Nat -> Nat
-- code de formule, profondeur, valeur numerique

def diagonalSubstitutionCode (code : Nat) : Nat :=
  substituteCode code 0 code
```

Sur les codes invalides, la fonction peut retourner le code de `falsum`. Ce
choix doit etre definitionnel et ne doit jamais intervenir dans la preuve sur
un code produit par `RawFormula.code`.

Theoreme de commutation obligatoire :

```lean
theorem substituteCode_quote
    (formula : RawFormula)
    (depth value : Nat) :
    substituteCode formula.code depth value =
      (formula.instantiateNumeral depth value).code
```

Corollaire diagonal :

```lean
theorem diagonalSubstitutionCode_quote
    (formula : RawFormula) :
    diagonalSubstitutionCode formula.code =
      (formula.instantiateNumeral 0 formula.code).code
```

### Porte G4

```text
fonction totale calculable ;
commutation code/substitution prouvee ;
aucun symbole arithmetique nouveau n'a ete ajoute a RawTerm.
```

## 10. Phase 5 - Noyau de fonctions primitives recursives

Cette phase est la plus importante et ne doit pas etre escamotee.

### 10.1 Langage metasyntaxique des fonctions PR

`PrimitiveRecursive.lean` doit definir un petit langage type par arite :

```lean
inductive PRFunction : Nat -> Type
  | zero
  | succ
  | projection
  | composition
  | primitiveRecursion
```

Il doit fournir une semantique positive et le programme principal :

```lean
inductive PRFunction.Evaluates
def diagonalSubstitutionPR : PRFunction 1
```

et prouver :

```lean
theorem diagonalSubstitutionPR_correct (code : Nat) :
  PRFunction.Evaluates diagonalSubstitutionPR ![code]
    (diagonalSubstitutionCode code)
```

Si le coupleur, le decodeur ou la recursion bornee demandent des fonctions
auxiliaires, chacune doit etre construite dans `PRFunction` avec un theoreme de
correction. Une affirmation informelle de primitive-recursivite n'est pas une
preuve acceptable.

### 10.2 Choix de representation des sequences

Avant l'implementation, fixer dans le code une seule methode :

```text
option recommandee : fonction beta de Goedel avec preuve constructive
d'encodage de toute sequence finie ;

option alternative : traces de calcul bornees codees par le coupleur local,
avec une formule arithmetique verifiant chaque transition.
```

Le choix doit etre documente dans `PrimitiveRecursive.lean`. Il est interdit de
melanger deux encodages en laissant leur equivalence comme obligation future.

### Porte G5

```text
diagonalSubstitutionPR est une donnee positive fermee ;
son evaluation est egale a diagonalSubstitutionCode pour tout Nat ;
toutes les fonctions auxiliaires sont internes au langage PR.
```

## 11. Phase 6 - Representabilite dans l'arithmetique nue

`Representability.lean` doit compiler une fonction PR vers une formule de
graphe dans la grammaire arithmetique de la phase 1.

Interface cible :

```lean
def PRFunction.graphFormula (f : PRFunction arity) : RawFormula

theorem PRFunction.graphFormula_spec
    (f : PRFunction arity)
    (inputs : Fin arity -> Nat)
    (output : Nat) :
    HoldsGraph (f.graphFormula) inputs output <->
      output = f.evaluate inputs
```

La direction existence et la direction fonctionnalite sont toutes deux
obligatoires. Le diagonaliseur utilisera au minimum :

```lean
def diagonalSubstitutionGraph : RawFormula :=
  diagonalSubstitutionPR.graphFormula

theorem diagonalSubstitutionGraph_spec (input output : Nat) :
  HoldsBinary diagonalSubstitutionGraph input output <->
    output = diagonalSubstitutionCode input
```

La formule de graphe ne doit utiliser que les constructeurs de `RawFormula` et
les termes `zero`, `succ`, `add`, `mul`.

### Porte G6 - porte bloquante principale

```text
la formule de graphe est une formule arithmetique ordinaire ;
la specification est biconditionnelle et fermee ;
existence et unicite de la sortie sont constructives ;
aucun symbole de fonction PR n'apparait dans RawTerm ;
aucune hypothese de representabilite n'est exportee vers les phases suivantes.
```

Tant que G6 n'est pas fermee, il est interdit de creer le
`ArithmeticTarskiContext` final.

## 12. Phase 7 - Construction effective du lemme diagonal

### 12.1 Corps auto-applicatif

Pour un predicat unaire `tau`, construire une formule unaire `body tau` qui
exprime :

```text
il existe y tel que
  diagonalSubstitutionGraph(x, y)
  et non tau(y).
```

Toutes les operations de decalage de variables doivent passer par les lemmes
de `Substitution.lean`. Aucun indice de De Bruijn ne doit etre ajuste a la main
sans lemme de scoping et lemme semantique.

### 12.2 Phrase diagonale

Definir :

```lean
def diagonal (tau : Predicate) : Sentence :=
  instantiateBodyWithOwnCode (body tau)
```

Le calcul de code attendu est :

```text
quote(diagonal tau)
= diagonalSubstitutionCode(quote(body tau)).
```

### 12.3 Specification

Prouver, uniquement avec :

```text
semantique de substitution ;
specification de diagonalSubstitutionGraph ;
commutation de la substitution sur les codes ;
calcul du code de diagonal tau.
```

Theoreme final :

```lean
theorem diagonal_spec (tau : Predicate) :
  models (diagonal tau) <->
    (models (applyQuote tau (diagonal tau)) -> False)
```

### Porte G7

Audit manuel obligatoire de la grammaire de `diagonal tau` :

```text
aucun constructeur reflexif ;
aucune clause semantique speciale ;
aucune hypothese ajoutee ;
le code de la phrase est calcule par les fonctions des phases 3 et 4.
```

Un `diagonal_spec` definitionnel ou prouve par `rfl` est un signal d'echec,
pas une optimisation.

## 13. Phase 8 - Patch syntaxique intrinseque

`Patch.lean` doit definir, pour `tau : Predicate` et `d : Sentence` :

```text
tau+(x) :=
  (x = numeral(quote d) /\ d)
  \/
  (not (x = numeral(quote d)) /\ tau(x)).
```

La phrase `d` est inseree dans le contexte unaire grace a la monotonie du
scoping. Aucun constructeur `closed` n'est necessaire.

Obligations :

```lean
theorem patch_agrees_at (tau : Predicate) (d : Sentence) :
  truthAt (patch tau d) d <-> models d

theorem patch_preserves_off_index
    (tau : Predicate)
    (d sentence : Sentence)
    (different : sentence = d -> False) :
  truthAt (patch tau d) sentence <-> truthAt tau sentence
```

La preuve de `patch_agrees_at` ne doit pas decider `models d`. La preuve de
preservation doit utiliser l'injectivite de quotation pour convertir une
egalite de codes en egalite de phrases.

### Porte G8

```text
patch : Predicate -> Sentence -> Predicate est syntaxique ;
scoping unaire prouve ;
accord local et preservation prouves ;
aucune decision de verite semantique.
```

## 14. Phase 9 - Contexte ferme et orbite generique

`ClosedOrbit.lean` construit enfin :

```lean
def bareArithmeticTarskiContext : ArithmeticTarskiContext

def bareArithmeticPatchableContext :
  PatchableArithmeticTarskiContext

def initialBareArithmeticPredicate : Predicate

def bareArithmeticGenericPatchOrbitTheorem :
  PatchableArithmeticTarskiContext.GenericPatchOrbitTheorem
    bareArithmeticPatchableContext
    initialBareArithmeticPredicate
```

L'initial peut etre le predicat constamment faux, construit dans la syntaxe
ordinaire et prouve unaire par scoping.

La phase ne doit contenir aucune nouvelle preuve de fraicheur, d'injectivite ou
de non-retour. Elle doit instancier les theoremes de
`GenericPatchOrbit.lean`.

### Porte G9

```text
contexte ferme sans parametre ;
diagonal_spec provient de G7 ;
patch_agrees_at et patch_preserves_off_index proviennent de G8 ;
orbite generique instanciee sans hypothese additionnelle.
```

## 15. Phase 10 - Non-trivialite obligatoire

L'absence d'axiomes ne suffit pas. `ClosedOrbit.lean` doit aussi fournir une
structure fermee :

```lean
structure BareArithmeticNontriviality where
  trueSentenceModeled : ...
  falseSentenceRefuted : ...
  semanticValuesSeparated : ...
  quotationInjective : ...
  firstStepSeparated : ...
  allCandidatesSeparated : ...
  allIndicesSeparated : ...
  everyStepChangesSemantics : ...
  diagonalNotPrimitive : GrammarCertificate ...
```

Les obligations semantiques sont :

```text
0 = 0 est vraie ;
falsum est fausse ;
la semantique n'est pas constante ;
pour k != n, candidat_k != candidat_n ;
pour k != n, index_k != index_n ;
au defi index_n, candidat_n et candidat_(n+1) ne sont pas equivalents ;
chaque candidat reste globalement incomplet.
```

`diagonalNotPrimitive` ne doit pas etre un booleen affirme a la main. Il doit
etre une consequence de la grammaire fermee de `RawFormula`, qui ne possede
aucun constructeur reflexif.

### Porte G10

```text
non-vacuite syntaxique ;
non-constance semantique ;
variation dynamique ;
diagonalisation non primitive ;
audits vides.
```

## 16. Integration dans Meta.lean

Les imports ne sont ajoutes a `Meta.lean` qu'apres G10 :

```lean
import Meta.Tarski.GenericPatchOrbit
import Meta.Tarski.BareArithmetic.ClosedOrbit
```

Ne pas importer chaque sous-module dans l'agregateur : `ClosedOrbit` doit
porter le graphe complet.

Ajouter a l'audit global :

```lean
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.genericPatchOrbitTheorem
#print axioms Meta.BareArithmeticTarski.bareArithmeticTarskiContext
#print axioms Meta.BareArithmeticTarski.bareArithmeticPatchableContext
#print axioms Meta.BareArithmeticTarski.bareArithmeticGenericPatchOrbitTheorem
#print axioms Meta.BareArithmeticTarski.bareArithmeticNontriviality
#print axioms Meta.BareArithmeticTarski.bareArithmeticTarskiClosedSystem
```

`FoundationBridge` reste absent de `Meta.lean`.

## 17. Strategie d'audit par phase

Chaque porte doit executer :

```bash
lake build Meta.Tarski.BareArithmetic.<Module>
```

Puis, sur tous les fichiers de la nouvelle chaine :

```bash
rg -n "^\s*axiom\b|\bsorry\b|\badmit\b|open\s+Classical|Classical\.|propext|Quot\.sound|unsafe|noncomputable" \
  Meta/Tarski/BareArithmetic
```

Enfin :

```bash
lake build Meta
git diff --check
```

Critere des blocs d'audit :

```text
exactement un AXIOM_AUDIT_BEGIN ;
exactement un AXIOM_AUDIT_END ;
bloc a la toute fin ;
tous les noms existent ;
toutes les sorties indiquent "does not depend on any axioms".
```

## 18. Matrice de tracabilite

| Exigence initiale | Module | Declaration de sortie | Porte |
|---|---|---|---|
| Formules De Bruijn brutes | `Syntax` | `RawTerm`, `RawFormula` | G1 |
| Cloture sans constructeur semantique | `Scoping` | `Sentence`, `Predicate` | G1 |
| Evaluation dans `Nat` | `Semantics` | `RawTerm.evaluate`, `RawFormula.Holds` | G2 |
| Substitution syntaxique | `Substitution` | `instantiateTerm`, `instantiateNumeral` | G2 |
| Codage de Goedel calculable | `Coding` | `code`, `decodeFormula`, `quote` | G3 |
| Substitution sur les codes | `CodeSubstitution` | `substituteCode` | G4 |
| Diagonalisation primitive recursive | `PrimitiveRecursive` | `diagonalSubstitutionPR` | G5 |
| Representabilite arithmetique | `Representability` | `diagonalSubstitutionGraph_spec` | G6 |
| Lemme diagonal construit | `Diagonal` | `diagonal`, `diagonal_spec` | G7 |
| Patch syntaxique | `Patch` | `patch`, `patch_agrees_at`, `patch_preserves_off_index` | G8 |
| Contexte patchable ferme | `ClosedOrbit` | `bareArithmeticPatchableContext` | G9 |
| Orbite injective | `GenericPatchOrbit` + `ClosedOrbit` | `bareArithmeticGenericPatchOrbitTheorem` | G9 |
| Non-trivialite | `ClosedOrbit` | `bareArithmeticNontriviality` | G10 |

Une ligne sans declaration fermee signifie que l'objectif correspondant n'est
pas termine.

## 19. Risques mathematiques et decisions d'arret

### R1 - Representabilite sous-estimee

La compilation des fonctions primitives recursives en formules arithmetiques
est probablement la plus grande partie du travail. Elle ne doit pas etre
remplacee par un symbole de fonction primitif.

Decision d'arret : si G6 ne peut pas etre fermee constructivement, ne pas
publier d'instance arithmetique. Livrer uniquement le theoreme generique et un
rapport precis de l'obligation manquante.

### R2 - Codage non adapte a la recursion

Un codage injectif peut etre inutilisable pour definir un decodeur ou une
substitution primitive recursive.

Decision : prouver la mesure de decroissance des sous-codes avant de construire
la couche PR. Sinon, changer le codage a G3, pas apres G5.

### R3 - Erreurs de De Bruijn

Une formule diagonalisee peut compiler tout en liant la mauvaise variable.

Decision : aucune construction de `body tau` sans theoremes de scoping et de
semantique pour chaque operation de renommage/substitution.

### R4 - Non-trivialite seulement syntaxique

L'injectivite des arbres ne suffit pas si tous les candidats ont la meme
semantique.

Decision : G10 exige la variation semantique au defi courant.

### R5 - Reintroduction indirecte de Foundation

Une dependance peut revenir par un import intermediaire.

Decision : auditer le graphe d'import et verifier :

```bash
rg -n '^import (Foundation|Meta\.Tarski\.FoundationBridge)' \
  Meta/Tarski/BareArithmetic Meta/Tarski/GenericPatchOrbit.lean
```

Le resultat doit etre vide.

## 20. Ordre strict d'execution

```text
G0  nettoyage des claims
 |
G1  syntaxe et scoping
 |
G2  semantique et substitution
 |
G3  codage et decodage
 |
G4  substitution sur les codes
 |
G5  preuve de primitive-recursivite
 |
G6  representabilite arithmetique       <- porte principale
 |
G7  diagonaliseur reel
 |
G8  patch syntaxique
 |
G9  contexte ferme et orbite
 |
G10 non-trivialite et integration
```

Il est interdit de commencer G7 par un constructeur provisoire `fixed`. Les
tests de l'interface generique peuvent utiliser le prototype historique hors du
chemin principal, mais aucune de ses declarations ne valide une porte.

## 21. Definition de termine

Le programme est termine seulement si toutes les affirmations suivantes sont
simultanement vraies :

```text
1. RawFormula ne contient ni fixed ni closed ;
2. la semantique ne consulte aucun code syntaxique ;
3. code/decode et substitution sur les codes sont calculables et corrects ;
4. diagonalSubstitutionCode est representee par une formule de {0,S,+,*} ;
5. diagonal tau est construit par auto-substitution codee ;
6. diagonal_spec ne repose sur aucune hypothese externe ;
7. le patch est une formule arithmetique ordinaire ;
8. le contexte patchable est une valeur fermee ;
9. le theoreme generique fournit l'injectivite et le non-retour ;
10. la non-trivialite semantique et dynamique est prouvee ;
11. Meta compile sans importer FoundationBridge ;
12. tous les audits sont vides.
```

Avant ces douze points, la formulation correcte est :

```text
"theoreme generique d'orbite acquis ; instance arithmetique en construction".
```

Apres ces douze points, la formulation autorisee devient :

```text
"la non-recurrence de l'orbite de patch est une consequence intrinseque de
Tarski dans une syntaxe arithmetique constructive autonome".
```

## 22. Premier lot d'implementation recommande

Le premier lot ne doit pas tenter la diagonalisation. Il doit fermer G0 a G3 :

```text
Lot 1A : quarantaine des claims reflexifs dans Meta.lean ;
Lot 1B : Syntax + Scoping ;
Lot 1C : Semantics + Substitution ;
Lot 1D : Coding avec decodeur et round-trip.
```

Livrables du lot 1 :

```text
quatre modules compilables ;
audits vides ;
aucun constructeur reflexif ;
un rapport court sur la mesure des codes ;
aucune declaration de contexte Tarski ferme.
```

Ce lot fournit la base sur laquelle la difficulte reelle, G4 a G7, peut etre
attaquee sans nouveau raccourci semantique.
