# Plan d’implémentation de `Prov_PA` et de la progression causale de prouvabilité

## 0. Décision architecturale

La cible n’est pas de remplacer `models` par `Provable` dans
`ArithmeticTarskiContext`.

Ce remplacement demanderait la loi incorrecte :

```text
Provable(dτ) ↔ ¬Provable(τ(⌜dτ⌝)).
```

Une diagonalisation syntaxique donne seulement :

```text
Provable(dτ) ↔ Provable(¬τ(⌜dτ⌝)).
```

La cohérence donne l’implication :

```text
Provable(¬φ) → ¬Provable(φ),
```

mais pas sa réciproque. Une phrase et sa négation peuvent être toutes deux
improuvables.

La construction doit donc séparer trois niveaux :

```text
Derivation_PA(φ)
    objet positif de preuve ;

PAProvable(φ)
    existence métamathématique d’une dérivation ;

Prov_PA(x)
    formule arithmétique représentant cette existence dans Nat.
```

La progression forte agit ensuite sur des théories :

```text
T
→ phrase de Rosser R_T
→ T + R_T
→ nouveau prédicat Prov_{T + R_T}
→ nouvelle phrase de Rosser.
```

Le résultat final doit être une instance fermée de la dynamique causale :

```text
gap absent de la théorie courante
+ inscription du gap comme nouvel axiome
+ conservation de toutes les preuves antérieures
→ progression additive fidèle et non récurrente.
```

## 1. Cible formelle terminale

La chaîne complète visée est :

```text
calcul de preuves classique pour PA
→ codage calculable des dérivations
→ vérificateur primitif récursif
→ formule arithmétique Proof_PA(p,x)
→ formule arithmétique Prov_PA(x)
→ lemme diagonal négatif interne à PA
→ théorème de Rosser constructif
→ extension cohérente T ↦ T + R_T
→ système causal accumulatif fermé
→ action additive fidèle des mots causaux
→ totalité historique non épuisable
→ coordonnée naturelle du temps causal seulement dans la couche finale.
```

`Nat` intervient nécessairement dès le départ comme domaine interne des codes
de Gödel. Ce qui est exclu avant la couche finale est un `Nat` servant d’index
temporel extérieur aux états. La progression doit produire son ordre causal ;
elle ne doit pas recevoir un compteur de stades.

La déclaration terminale devra avoir une forme fermée :

```text
paProvabilityClosedSystem : PAProvabilityClosedSystem
```

Elle ne devra recevoir aucun argument de cohérence, de correction, de
représentabilité ou de terminaison.

Les théorèmes génériques pourront naturellement prendre une théorie et un
certificat de cohérence. La valeur terminale pour PA devra construire puis
consommer elle-même tous ces certificats.

## 2. Ce qui existe déjà

Le dépôt fournit déjà les briques suivantes.

| Besoin | Déclaration ou module existant | Statut |
|---|---|---|
| Syntaxe `{0,S,+,×,=,∧,∨,→,∀,∃}` | `Syntax.lean` | fermé |
| Scoping intrinsèque De Bruijn | `Scoping.lean` | fermé |
| Substitution syntaxique générale | `Substitution.lean` | fermée sur les objets |
| Codage injectif termes/formules | `Coding.lean` | fermé |
| Décodage total avec carburant | `decodeTerm`, `decodeFormula` | fermé |
| Appariement et désappariement | `natPair`, `natUnpairLeft`, `natUnpairRight` | fermé |
| Langage de fonctions primitives récursives | `PRFunction` | fermé |
| Évaluateur structural total | `PRFunction.runCore` | fermé |
| Traces calculables | `PrimitiveRecursiveTrace.lean` | fermé |
| Encodage β constructif | `ConstructiveBetaEncoding.lean` | fermé |
| Compilateur PR vers graphes arithmétiques | `PRFunction.graphFormula` | fermé sémantiquement |
| Substitution codée par numéral | `machineSubstituteNumeralCode` | fermée seulement pour ce cas |
| Substitution générale d’un terme codé | aucun programme actuel | ouverte |
| Diagonalisation tarskienne négative | `Diagonal.lean` | fermée sémantiquement |
| Mots causaux et addition | `CausalAdditive.lean` | fermé |
| Totalité historique | `CausalTotality.lean` | fermé |

Deux distinctions doivent rester explicites.

Premièrement, `PRFunction.graphFormula_spec` prouve actuellement une exactitude
dans la sémantique standard. Le théorème de Rosser exige aussi des dérivations
internes à PA établissant les faits de calcul nécessaires.

Deuxièmement, `diagonal_spec` donne actuellement, pour un prédicat `τ` :

```text
models(dτ) ↔ ¬models(τ(⌜dτ⌝)).
```

La construction de Rosser exige la version interne de cette même orientation :

```text
PA ⊢ dτ ↔ ¬τ(⌜dτ⌝).
```

Le passage de la première ligne à la seconde est une vraie porte
d’implémentation. Il ne doit pas être déclaré automatique.

## 3. Calcul de preuves objet

### 3.1 Types de base

Ajouter un calcul de déduction naturelle contextuel, formulé comme donnée
positive dans `Type`.

```text
ScopedFormula(bound)
FormulaContext(bound)
TheoryAxiom(formula)
Derivation(theory, context, conclusion) : Type
```

`PAProvable(φ)` sera ensuite une proposition d’existence, jamais la définition
première des preuves :

```text
PAProvable(φ) :⇔ Nonempty(Derivation(PA, [], φ)).
```

En Lean, une présentation équivalente par `Nonempty` est acceptable pour la
frontière propositionnelle, mais les transformations de preuves doivent
toujours travailler sur `Derivation` dans `Type`.

### 3.2 Règles logiques

Le calcul doit contenir des constructeurs vérifiables pour :

```text
hypothèse ;
introduction et élimination de → ;
introduction et élimination de ∧ ;
introduction et élimination de ∨ ;
élimination de ⊥ ;
introduction et élimination de ∀ ;
introduction et élimination de ∃ ;
égalité : réflexivité, symétrie, transitivité et substitution ;
double négation : de ¬¬φ dériver φ, uniquement en mode classique.
```

Le calcul choisit donc une présentation unique de la logique classique :

```text
doubleNegationElimination :
  Derivation(classical,T,Γ,¬¬φ)
  → Derivation(classical,T,Γ,φ).
```

Il ne faut pas ajouter en parallèle un second schéma classique.

Les règles quantifiées doivent être verrouillées par les opérations De Bruijn
suivantes :

```text
allIntroduction :
  Derivation(T,liftContext(Γ),φ)
  → Derivation(T,Γ,∀φ)

allElimination :
  Derivation(T,Γ,∀φ)
  → WellScoped(bound,t)
  → Derivation(T,Γ,instantiate(φ,t))

existsIntroduction :
  Derivation(T,Γ,instantiate(φ,t))
  → WellScoped(bound,t)
  → Derivation(T,Γ,∃φ)

existsElimination :
  Derivation(T,Γ,∃φ)
  → Derivation(T,φ :: liftContext(Γ),liftFormula(ψ))
  → Derivation(T,Γ,ψ).
```

Les types Lean exacts pourront transporter les bornes de scoping en indices,
mais ils devront réaliser ces quatre formes. Aucune règle ne doit contenir une
fonction Lean arbitraire ou un test sémantique.

### 3.3 Axiomes arithmétiques

La théorie PA doit contenir exactement des schémas syntaxiques calculables :

```text
S(x) ≠ 0 ;
S(x) = S(y) → x = y ;
x + 0 = x ;
x + S(y) = S(x + y) ;
x × 0 = 0 ;
x × S(y) = x × y + x ;
schéma complet d’induction, paramètres autorisés.
```

L’égalité est entièrement régie par les règles logiques de la section 3.2 ;
elle ne doit pas être dupliquée par une seconde famille d’axiomes.

Le schéma d’induction doit être construit depuis une formule bien scopée. Il
ne doit pas être reconnu par un prédicat sémantique du type « formule vraie ».

### 3.4 Deux modes logiques

Le même noyau de règles doit distinguer :

```text
PA : arithmétique classique ;
HA : arithmétique intuitionniste.
```

Le mode classique ajoute uniquement `doubleNegationElimination`. Le mode
intuitionniste n’en contient aucune occurrence. Cette séparation servira à
construire la cohérence de PA sans utiliser `Classical` dans Lean.

### 3.5 Prérequis : substitution générale de termes codés

La substitution syntaxique générale existe déjà sur `RawTerm` et
`RawFormula`, mais la machine primitive récursive actuelle ne traite que
l’instanciation par un numéral. Le calcul de preuves quantifié et le schéma
d’induction exigent donc de construire :

```text
substituteTermCode(formulaCode,variable,termCode) ;
liftTermCode(termCode,cutoff) ;
liftFormulaCode(formulaCode,cutoff) ;
instantiateTermCode(formulaCode,termCode) ;
universalClosureCode(formulaCode,bound).
```

Chaque fonction doit avoir un programme `PRFunction` et une spécification sur
les codes fraîchement construits. Le programme doit transporter explicitement
la profondeur courante sous les quantificateurs, comme la machine de
substitution par numéral déjà fermée.

### Sorties exigées

```text
LogicMode
ScopedFormula
FormulaContext
ArithmeticTheory
Derivation
paTheory
haTheory
PAProvable
HAProvable
Derivation.weaken
Derivation.substitute
Derivation.implicationIntroduction
Derivation.modusPonens
PRFunction.substituteTermCode
PRFunction.liftTermCode
PRFunction.liftFormulaCode
PRFunction.instantiateTermCode
PRFunction.universalClosureCode
```

### Porte P1

```text
toutes les règles sont syntaxiques et finitaires ;
les preuves vivent dans Type ;
PA et HA partagent les mêmes axiomes arithmétiques ;
seul le mode logique diffère ;
la substitution générale de termes codés est primitive récursive ;
les quatre règles quantifiées sont vérifiables sur les codes ;
aucune règle ne consulte RawFormula.Holds ou Sentence.models.
```

## 4. Codage des dérivations

### 4.1 Archive β d’une preuve

Une dérivation codée sera une archive finie de lignes :

```text
ProofArchive :=
  (nombre strictement positif de lignes,
   dividende β,
   coefficient β).
```

Si le nombre de lignes est `succ(n)`, la conclusion de l’archive est, par
définition, la ligne située à l’index `n`. Aucun second index de conclusion ne
doit être stocké.

Chaque valeur β à la position `i` code une ligne :

```text
ProofLineCode :=
  (tag de règle,
   code du contexte,
   code de la conclusion,
   références aux lignes prémisses,
   paramètres syntaxiques de la règle).
```

Toute référence à une prémisse doit être strictement inférieure à l’index de
la ligne courante. Cette orientation fournit la terminaison intrinsèque du
vérificateur.

L’encodage β existant doit être réutilisé pour construire les témoins d’une
archive depuis une liste finie de lignes. Les opérations d’accès doivent être
compilées en fonctions primitives récursives.

### 4.2 Accès β exécutable

Le dépôt possède la fonction Lean `constructiveRemainder` et la formule
arithmétique `betaValueFormula`, mais pas encore les arbres `PRFunction`
nécessaires au vérificateur. Construire explicitement :

```text
PRFunction.constructiveQuotient : PRFunction 2
PRFunction.constructiveRemainder : PRFunction 2
PRFunction.betaModulus : PRFunction 2
PRFunction.betaLookup : PRFunction 3
```

avec :

```text
PRFunction.betaLookup.run(dividend,coefficient,index)
= betaComponent(dividend,coefficient,index).
```

La division doit être une récursion primitive structurelle sur le dividende ;
elle ne doit pas importer un quotient ou un algorithme non certifié.

### 4.3 Codage des contextes et des théories finies

Les contextes locaux et les extensions finies de PA seront codés séparément :

```text
ContextCode := séquence finie de codes de formules ;
TheoryHistoryCode := séquence finie de codes de phrases ajoutées.
```

La présence d’une phrase dans l’extension finie doit être décidée par un
parcours borné calculable.

### 4.4 Linéarisation et exactitude du codage

Une valeur inductive `Derivation` est un arbre, tandis qu’une archive β est une
suite de lignes référant vers le passé. Construire une linéarisation qui :

```text
concatène les archives des prémisses ;
rebase toutes leurs références ;
ajoute la ligne de la règle courante ;
place la conclusion à la dernière position.
```

Le rebasing des références doit être une fonction calculable et préserver la
validité de chaque ligne.

Construire deux directions explicites :

```text
encodeDerivation : Derivation(T,Γ,φ) → ProofArchive

decodeCheckedDerivation :
  ChecksDerivation(Tcode,Γcode,archive,⌜φ⌝)
  → Derivation(T,Γ,φ).
```

La deuxième direction ne doit pas choisir arbitrairement une formule depuis
un code. Elle doit utiliser `decodeFormula`, les preuves de scoping et les
égalités de codage déjà disponibles.

### Sorties exigées

```text
ProofRuleTag
ProofLine
ProofArchive
ProofArchive.quote
ContextCode
TheoryHistory
TheoryHistory.quote
linearizeDerivation
rebaseProofArchive
encodeDerivation
checkArchive
checkArchive_encodeDerivation
decodeCheckedDerivation
```

### Porte P2

```text
le code final contient toutes les données nécessaires à la vérification ;
la conclusion est exactement la dernière ligne de toute archive non vide ;
aucune référence de ligne ne pointe vers le futur ;
la linéarisation rebase correctement toutes les références ;
le décodage d’une archive acceptée reconstruit une vraie dérivation ;
la vérification ne dépend d’aucune égalité de propositions.
```

## 5. Vérificateur primitif récursif

### 5.1 Reconnaisseurs syntaxiques

Les décodeurs Lean existants ne suffisent pas, à eux seuls, à établir que le
vérificateur numérique est primitif récursif. Construire des programmes
explicites pour :

```text
isTermCode ;
isFormulaCode ;
isScopedTermCode ;
isScopedFormulaCode ;
isContextCode ;
isPAAxiomCode ;
isHistoryAxiomCode ;
isRuleInstanceCode.
```

Leur correction doit être prouvée contre les décodeurs et les prédicats de
scoping existants.

### 5.2 Vérification d’une ligne

Définir une fonction totale :

```text
checkProofLine(historyCode, archiveCode, lineIndex) ∈ {0,1}.
```

Elle doit vérifier :

```text
la validité du tag ;
la validité des codes de formules et de contextes ;
les références strictement antérieures ;
la correspondance exacte entre prémisses et conclusion ;
les conditions de scoping ;
l’appartenance aux axiomes de PA ou à l’histoire finie.
```

### 5.3 Vérification de l’archive

Définir :

```text
proofCheckBit(historyCode, proofCode, sentenceCode) ∈ {0,1}.
```

Le résultat vaut `1` exactement si :

```text
toutes les lignes sont valides
et
la dernière ligne conclut sentenceCode sous contexte vide.
```

Le parcours des lignes est une récursion primitive bornée par la longueur
inscrite dans l’archive. La validité des références antérieures empêche toute
dépendance circulaire.

### 5.4 Programme positif

Construire l’arbre de programme :

```text
PRFunction.proofCheck : PRFunction 3
```

avec la spécification :

```text
PRFunction.proofCheck.run(historyCode, proofCode, sentenceCode)
= proofCheckBit(historyCode, proofCode, sentenceCode).
```

### Sorties exigées

```text
PRFunction.isTermCode
PRFunction.isFormulaCode
PRFunction.isScopedFormulaCode
PRFunction.constructiveQuotient
PRFunction.constructiveRemainder
PRFunction.betaLookup
PRFunction.isPAAxiomCode
PRFunction.historyContains
PRFunction.checkProofLine
PRFunction.proofCheck
PRFunction.proofCheck_evaluates
proofCheckBit_eq_one_iff
```

### Porte P3

```text
proofCheck est un vrai arbre PRFunction ;
aucun constructeur n’embarque une fonction Lean ;
le test est total sur tous les nombres ;
acceptation ↔ existence d’une dérivation décodée ;
la preuve de correction est constructive.
```

## 6. `Proof_T` et `Prov_T` dans l’arithmétique

### 6.1 Formule de vérification

Compiler `PRFunction.proofCheck` avec l’infrastructure existante :

```text
proofCheckGraph := PRFunction.proofCheck.graphFormula.
```

Construire ensuite une formule à trois entrées :

```text
Proof(history,p,x)
:⇔ proofCheckGraph(history,p,x,1).
```

Pour une histoire fermée `h` :

```text
Proof_h(p,x) := Proof(⌜h⌝,p,x).
```

### 6.2 Prédicat de prouvabilité

Définir la formule unaire :

```text
Prov_h(x) :⇔ ∃p, Proof_h(p,x).
```

La formule demandée pour PA est :

```text
Prov_PA := Prov_root.
```

En Lean, garder des noms non ambigus :

```text
TheoryProvable(history, sentence) : Prop
provabilityPredicate(history) : Predicate
provPA : Predicate
```

### 6.3 Spécification sémantique exacte

Prouver :

```text
models(Proof_h(p̄,⌜φ⌝))
↔ proofCheckBit(⌜h⌝,p,⌜φ⌝) = 1

models(Prov_h(⌜φ⌝))
↔ TheoryProvable(h,φ)

models(Prov_PA(⌜φ⌝))
↔ PAProvable(φ).
```

Cette équivalence est la représentabilité sémantique exacte de `Prov_PA`.
Elle ne prétend pas que PA prouve toutes les non-prouvabilités.

### Sorties exigées

```text
proofCheckGraph
proofFormula
proofFormula_spec
provabilityPredicate
provabilityPredicate_spec
provPA
provPA_spec
```

### Porte P4

```text
Prov_PA est une formule de la syntaxe arithmétique ordinaire ;
sa sémantique ne contient aucun appel réflexif ;
son exactitude dérive du vérificateur PR ;
la quantification sur les preuves est l’existentielle arithmétique ordinaire.
```

## 7. Représentabilité interne à PA

La spécification sémantique de la section précédente ne suffit pas au théorème
d’incomplétude. Il faut produire des dérivations dans PA.

### 7.1 Calculs numériques prouvables

Pour chaque programme primitif récursif utilisé par le vérificateur, construire
des preuves arithmétiques de ses calculs sur numéraux :

```text
f(a₁,…,aₙ) = b
→ PA ⊢ Graph_f(ā₁,…,āₙ,b̄)

f(a₁,…,aₙ) ≠ b
→ PA ⊢ ¬Graph_f(ā₁,…,āₙ,b̄).
```

La seconde ligne est requise pour les vérifications bornées du raisonnement de
Rosser.

### 7.2 Fonctionnalité interne

Pour les graphes employés dans la diagonalisation, prouver dans PA :

```text
PA ⊢
  Graph_f(x⃗,y) ∧ Graph_f(x⃗,z)
  → y = z.
```

Le paquet sémantique actuel `CertifiedArithmeticGraph` doit être complété par
un paquet proof-producing distinct :

```text
InternallyRepresentedPRFunction(program).
```

Il contiendra au minimum :

```text
graphe arithmétique ;
exactitude sémantique ;
construction de preuves sur numéraux ;
construction de réfutations sur numéraux ;
preuve interne de fonctionnalité.
```

### 7.3 Conditions de dérivabilité

Établir les transformations effectives correspondant aux conditions usuelles :

```text
D1 : T ⊢ φ → T ⊢ Prov_T(⌜φ⌝)

D2 : T ⊢
     Prov_T(⌜φ → ψ⌝)
     → (Prov_T(⌜φ⌝) → Prov_T(⌜ψ⌝))

D3 : T ⊢
     Prov_T(⌜φ⌝)
     → Prov_T(⌜Prov_T(⌜φ⌝)⌝).
```

Chaque condition doit être obtenue par une fonction explicite transformant
les codes ou les objets de dérivation.

### Sorties exigées

```text
InternallyRepresentedPRFunction
PRFunction.internalGraphNumeralProof
PRFunction.internalGraphNumeralRefutation
PRFunction.internalGraphFunctional
TheoryProvable.quoteProof
TheoryProvable.internalModusPonens
TheoryProvable.internalPositiveIntrospection
```

### Porte P5

```text
aucune utilisation de la vérité sémantique ne remplace une dérivation PA ;
les preuves internes sont des valeurs de Derivation ;
la diagonalisation interne peut consommer ces valeurs ;
les trois transformations de dérivabilité sont calculables.
```

## 8. Lemme diagonal négatif interne

### 8.1 Construction

Réutiliser exactement le diagonaliseur tarskien négatif déjà construit, mais
ajouter la preuve objet manquante.

Pour tout prédicat arithmétique `τ(x)`, conserver :

```text
internalLiarDiagonal(τ) := diagonal(τ)
```

et une dérivation :

```text
PA ⊢ internalLiarDiagonal(τ)
    ↔ ¬τ(⌜internalLiarDiagonal(τ)⌝).
```

Le symbole `↔` pourra rester une abréviation pour les deux implications. Il
ne faut pas transformer silencieusement ce résultat en point fixe positif.
Un point fixe général pourra ultérieurement être obtenu en appliquant une
construction séparée au prédicat voulu, mais Rosser n’en a pas besoin.

### 8.2 Différence avec le résultat actuel

Conserver deux théorèmes nommés séparément :

```text
diagonal_spec
    exactitude dans Sentence.models ;

internalLiarDiagonal_derivable
    dérivation de l’équivalence négative dans PA.
```

La seconde preuve doit utiliser la représentabilité interne de la substitution
de codes. Elle ne doit pas être obtenue par la correction sémantique de PA.

### Sorties exigées

```text
internalLiarDiagonal
internalLiarDiagonal_quote
internalLiarDiagonal_derivable_forward
internalLiarDiagonal_derivable_backward
internalLiarDiagonal_derivable
```

### Porte P6

```text
le point fixe négatif reste construit ;
aucun constructeur réflexif n’est ajouté à RawFormula ;
PA possède une dérivation codée de l’équivalence négative exacte ;
l’audit de cette dérivation est vide.
```

## 9. Cohérence constructive de PA

La progression terminale ne peut pas prendre `Consistent(PA)` comme argument.
Elle doit le construire.

### 9.1 Traduction négative

Définir une traduction syntaxique :

```text
negativeTranslation : RawFormula → RawFormula.
```

Construire récursivement :

```text
Derivation(PA,Γ,φ)
→ Derivation(HA,Γᴺ,φᴺ).
```

Le traitement de la règle classique et du schéma d’induction doit être
explicite.

### 9.2 Correction constructive de HA

Prouver par induction sur les dérivations intuitionnistes :

```text
HA ⊢ φ → models(φ)
```

pour les phrases closes, et la version contextuelle avec environnements pour
les formules ouvertes.

Cette preuve est constructive : les règles intuitionnistes sont interprétées
directement dans `RawFormula.Holds`.

### 9.3 Cohérence de PA

Comme la traduction négative de `⊥` reste `⊥` :

```text
PA ⊢ ⊥
→ HA ⊢ ⊥
→ models(⊥)
→ False.
```

Définir finalement :

```text
paConsistent : Consistent(rootTheoryHistory).
```

Cette route évite toute utilisation de `Classical` dans Lean tout en gardant
PA comme calcul objet classique.

### Sorties exigées

```text
RawFormula.negativeTranslation
Derivation.negativeTranslate
haDerivation_sound
ha_not_provable_false
paConsistent
```

### Porte P7

```text
PA reste classiquement axiomatisée au niveau objet ;
Lean reste entièrement constructif au niveau méta ;
paConsistent est une valeur fermée ;
aucun axiome de cohérence n’est déclaré.
```

## 10. Phrase de Rosser uniforme

### 10.1 Pourquoi Rosser

La progression doit préserver la cohérence après l’ajout du gap. Pour une
théorie cohérente effectivement axiomatisée, la phrase de Rosser fournit :

```text
T ⊬ R_T
et
T ⊬ ¬R_T.
```

La seconde exclusion permet de prouver constructivement la cohérence de
`T + R_T` par le théorème de déduction.

### 10.2 Prédicat de Rosser

Construire un prédicat arithmétique signifiant qu’il existe une preuve de la
phrase avant toute preuve de sa négation :

```text
RosserBad_T(x)
:⇔ ∃p,
    Proof_T(p,x)
    ∧ ∀q ≤ p, ¬Proof_T(q,negCode(x)).
```

Puis définir :

```text
R_T := internalLiarDiagonal(RosserBad_T).
```

Ainsi PA, puis chaque extension finie, dérive l’équivalence de Rosser
appropriée.

### 10.3 Indépendance constructive

Formaliser les deux transformations :

```text
Consistent(T)
→ Provable(T,R_T)
→ False

Consistent(T)
→ Provable(T,¬R_T)
→ False.
```

Le second argument utilise seulement :

```text
décidabilité du vérificateur ;
recherche bornée sous un code de preuve donné ;
représentabilité interne des réponses positives et négatives ;
cohérence de T.
```

Il ne doit pas invoquer une alternative classique sur la prouvabilité globale.

### 10.4 Conservation de la cohérence

Définir l’extension finie :

```text
extendTheory(T,R_T) := T + R_T.
```

Le théorème de déduction doit être une transformation de dérivations, et non
une invocation informelle :

```text
finiteExtensionDeduction :
  Derivation(T + R,Γ,φ)
  → Derivation(T,R :: Γ,φ)

removeExtensionFromContradiction :
  Derivation(T + R,[],⊥)
  → Derivation(T,[],R → ⊥).
```

La première transformation remplace chaque utilisation de l’axiome ajouté par
la règle d’hypothèse. La seconde applique ensuite l’introduction de `→`.

Si `T + R_T ⊢ ⊥`, cette transformation construit :

```text
T ⊢ ¬R_T,
```

ce que l’indépendance de Rosser exclut. On obtient :

```text
Consistent(T) → Consistent(T + R_T).
```

### Sorties exigées

```text
formulaNegationCode
rosserBadPredicate
rosserSentence
rosserFixedPointDerivation
rosser_not_provable
rosser_negation_not_provable
finiteExtensionDeduction
removeExtensionFromContradiction
extendWithRosser_consistent
```

### Porte P8

```text
RosserSentence est calculée depuis le code de la théorie ;
les deux directions d’indépendance sont constructives ;
le théorème de déduction est une fonction totale sur les dérivations ;
la cohérence du successeur est construite depuis celle de la source ;
aucune vérité externe de R_T n’est un champ de la construction.
```

## 11. Progression causale de théories

### 11.1 État

Définir une histoire finie des phrases ajoutées :

```text
TheoryHistory.root
TheoryHistory.extend(previous,event).
```

Puis un état certifié :

```text
CertifiedTheoryState :=
  (history,
   consistency : Consistent(history)).
```

La cohérence n’est pas une hypothèse externe attachée arbitrairement. Elle est
construite à la racine par `paConsistent`, puis transportée par
`extendWithRosser_consistent`.

### 11.2 Gap et avance

```text
gap(S) := rosserSentence(S.history)

advance(S) :=
  (S.history.extend(gap(S)),
   preuve construite de cohérence).
```

### 11.3 Deux mémoires à ne pas confondre

La mémoire causale exacte est l’histoire des événements :

```text
EventMemory(S,d) :⇔ d apparaît dans S.history.
```

L’observable proof-théorique est :

```text
Theorems(S,φ) :⇔ TheoryProvable(S.history,φ).
```

Il serait faux de demander :

```text
Theorems(advance(S),φ)
↔ Theorems(S,φ) ∨ φ = gap(S).
```

L’ajout d’un axiome produit aussi toutes ses conséquences logiques. L’exactitude
du pas porte donc sur `EventMemory`, tandis que la monotonie porte sur
`Theorems`.

### 11.4 Lois causales exactes

Prouver :

```text
¬EventMemory(S,gap(S))

EventMemory(advance(S),gap(S))

EventMemory(S,d)
→ EventMemory(advance(S),d)

EventMemory(advance(S),d)
↔ d = gap(S) ∨ EventMemory(S,d).
```

La première loi dérive de Rosser : si le gap était déjà dans l’histoire, il
serait un axiome, donc prouvable dans la théorie courante. Cette implication
doit être réalisée par une transformation explicite :

```text
historyMember_provable :
  EventMemory(S,d)
  → TheoryProvable(S.history,d).
```

### 11.5 Lois de prouvabilité

Prouver séparément :

```text
¬Theorems(S,gap(S))

Theorems(advance(S),gap(S))

Theorems(S,φ)
→ Theorems(advance(S),φ).
```

La deuxième loi est fournie par le constructeur de preuve « axiome ajouté ».
La troisième est une transformation explicite des dérivations et de leurs
codes.

### Sorties exigées

```text
CertifiedTheoryState
CertifiedTheoryState.gap
CertifiedTheoryState.advance
CertifiedTheoryState.EventMemory
CertifiedTheoryState.Theorems
provabilityGap_not_mem
provabilityGap_inscribed
provabilityEventMemory_preserved
provabilityAdvance_memory_iff
historyMember_provable
provabilityGap_not_provable
provabilityGap_provable_after_advance
provabilityTheorems_preserved
```

### Porte P9

```text
advance reconstruit le prédicat de prouvabilité de la nouvelle théorie ;
le gap courant est réellement improuvable avant l’avance ;
il est réellement prouvable après l’avance ;
les anciennes dérivations sont transformées, pas seulement réinterprétées ;
la mémoire causale garde une loi d’extension exacte.
```

## 12. Raccord au Core causal

Instancier directement :

```text
AccumulatingCausalSystem
  CertifiedTheoryState
  Sentence
```

avec :

```text
gap     := CertifiedTheoryState.gap
Memory  := CertifiedTheoryState.EventMemory
advance := CertifiedTheoryState.advance.
```

La racine est :

```text
initialPAState :=
  (TheoryHistory.root, paConsistent).
```

Les théorèmes génériques donnent alors sans compteur ajouté :

```text
fidélité de eval ;
injectivité des mots causaux réalisés ;
absence de retour positif ;
croissance stricte de la mémoire événementielle ;
fraîcheur intrinsèque des phrases de Rosser ;
totalité historique non épuisable ;
injection des mots causaux dans les gaps historiques ;
action additive fidèle.
```

Ajouter le résultat proof-théorique propre :

```text
si u précède v,
alors tous les théorèmes de T_u restent théorèmes de T_v ;

si u précède strictement v,
alors T_v prouve le gap produit à u,
tandis que T_u ne le prouve pas.
```

La progression réalise donc simultanément :

```text
une histoire exacte d’événements indépendants ;
une chaîne croissante de théories cohérentes ;
une arithmétique causale additive sans contraction.
```

### Sorties exigées

```text
paProvabilityAccumulatingSystem
initialPAState
paProvability_eval_faithful
paProvability_eval_injective
paProvability_no_positive_return
paProvability_historicalGap_injective
paProvability_no_stage_exhausts_history
paProvability_theorems_monotone
paProvability_oldGap_separates
```

### Porte P10

```text
l’instance du Core est fermée ;
les trois lois causales sont dérivées du théorème de Rosser et de l’histoire ;
aucun rang, compteur ou générateur de fraîcheur n’est stocké dans l’état ;
aucun Nat ne sert d’index temporel extérieur au système causal ;
les Nat présents restent les codes arithmétiques internes des syntaxes
et des preuves.
```

## 13. Paquet terminal

Définir :

```text
structure PAProvabilityClosedSystem : Type where
  proofCalculus
  proofCoding
  primitiveRecursiveChecker
  proofFormula
  provabilityFormula
  provPASpecification
  internalRepresentability
  internalLiarDiagonalLemma
  paConsistency
  rosserIndependence
  consistencyPreservation
  causalSystem
  additiveFaithfulness
  cumulativeTotality
  theoremPreservation
```

Puis construire :

```text
paProvabilityClosedSystem : PAProvabilityClosedSystem.
```

Le paquet doit permettre d’extraire directement :

```text
models(Prov_PA(⌜φ⌝)) ↔ PAProvable(φ) ;

∀S, ¬Provable(S,gap(S)) ;

∀S, Provable(advance(S),gap(S)) ;

∀S φ, Provable(S,φ) → Provable(advance(S),φ) ;

eval(initialPAState,u) ≃mem eval(initialPAState,v)
→ u = v.
```

## 14. Découpage des fichiers

Créer les fichiers dans cet ordre :

```text
Meta/Tarski/BareArithmetic/PrimitiveRecursiveGeneralSubstitution.lean
Meta/Tarski/BareArithmetic/PrimitiveRecursiveDivision.lean
Meta/Tarski/BareArithmetic/PrimitiveRecursiveBetaLookup.lean
Meta/Tarski/BareArithmetic/ProofSystem.lean
Meta/Tarski/BareArithmetic/ProofCoding.lean
Meta/Tarski/BareArithmetic/PrimitiveRecursiveProofChecking.lean
Meta/Tarski/BareArithmetic/ProofRepresentability.lean
Meta/Tarski/BareArithmetic/InternalRepresentability.lean
Meta/Tarski/BareArithmetic/InternalLiarDiagonal.lean
Meta/Tarski/BareArithmetic/NegativeTranslation.lean
Meta/Tarski/BareArithmetic/PAConsistency.lean
Meta/Tarski/BareArithmetic/FiniteExtensionDeduction.lean
Meta/Tarski/BareArithmetic/Rosser.lean
Meta/Tarski/BareArithmetic/ProvabilityProgression.lean
Meta/Tarski/BareArithmetic/ProvabilityClosedOrbit.lean
```

Dépendances :

```text
PrimitiveRecursiveGeneralSubstitution
  ← Syntax + Scoping + Substitution

ProofSystem
  ← Syntax + Scoping + Substitution

ProofCoding
  ← ProofSystem

PrimitiveRecursiveDivision
  ← PrimitiveRecursiveArithmetic

PrimitiveRecursiveBetaLookup
  ← PrimitiveRecursiveDivision

PrimitiveRecursiveProofChecking
  ← ProofCoding
  ← PrimitiveRecursiveGeneralSubstitution
  ← PrimitiveRecursiveBetaLookup

ProofRepresentability
  ← PrimitiveRecursiveProofChecking

InternalRepresentability
  ← ProofRepresentability
  ← ProofSystem

InternalLiarDiagonal
  ← InternalRepresentability

NegativeTranslation
  ← ProofSystem

PAConsistency
  ← NegativeTranslation

FiniteExtensionDeduction
  ← ProofSystem

Rosser
  ← InternalLiarDiagonal
  ← PAConsistency
  ← FiniteExtensionDeduction

ProvabilityProgression
  ← Rosser

ProvabilityClosedOrbit
  ← ProvabilityProgression
  ← CausalAdditive + CausalTotality
```

`Meta.lean` ne doit importer `ProvabilityClosedOrbit` qu’après fermeture des
portes P1 à P10.

## 15. Ordre d’exécution

### Lot A — calcul et codes

```text
A1  substitution générale de termes codés
A2  division et reste primitifs récursifs
A3  accès β primitif récursif
A4  ProofSystem avec règles quantifiées et DNE exactes
A5  ProofCoding et linéarisation avec rebasing
A6  équivalence dérivation ↔ archive vérifiée
```

Sortie : une preuve PA possède un code fini vérifiable, mais `Prov_PA` n’est
pas encore déclaré.

### Lot B — calculabilité et formule

```text
B1  reconnaisseurs syntaxiques PR
B2  vérificateur de lignes PR
B3  vérificateur d’archives PR
B4  Proof_h et Prov_h
B5  provPA_spec
```

Sortie : `Prov_PA` est une vraie formule arithmétique dont la sémantique
standard coïncide avec l’existence d’une dérivation PA.

### Lot C — preuves internes

```text
C1  calculs PR prouvables sur numéraux
C2  réfutations PR prouvables sur numéraux
C3  fonctionnalité interne des graphes
C4  conditions D1, D2, D3
C5  lemme diagonal négatif interne
```

Sortie : PA peut raisonner syntaxiquement sur son propre prédicat de preuve.

### Lot D — cohérence fermée

```text
D1  traduction négative
D2  transport PA → HA
D3  correction constructive de HA
D4  paConsistent
```

Sortie : la cohérence initiale n’est plus une hypothèse.

### Lot E — Rosser et avance

```text
E1  prédicat de Rosser
E2  point fixe négatif interne
E3  deux non-prouvabilités
E4  théorème de déduction pour extension finie
E5  conservation de la cohérence
```

Sortie : `advance` peut être itéré sans pont terminal.

### Lot F — système causal fermé

```text
F1  CertifiedTheoryState
F2  EventMemory exacte
F3  Theorems monotone
F4  instance AccumulatingCausalSystem
F5  fidélité additive et totalité historique
F6  paquet terminal fermé
```

## 16. Vérifications

Après chaque lot :

```text
lake env lean <fichier terminal du lot>
```

À la fermeture :

```text
lake clean
lake build Meta.Tarski.BareArithmetic.ProvabilityClosedOrbit
lake build Meta
```

Audits décisifs :

```text
#print axioms Meta.BareArithmeticTarski.PRFunction.substituteTermCode
#print axioms Meta.BareArithmeticTarski.PRFunction.betaLookup
#print axioms Meta.BareArithmeticTarski.provPA
#print axioms Meta.BareArithmeticTarski.provPA_spec
#print axioms Meta.BareArithmeticTarski.internalLiarDiagonal_derivable
#print axioms Meta.BareArithmeticTarski.paConsistent
#print axioms Meta.BareArithmeticTarski.rosser_not_provable
#print axioms Meta.BareArithmeticTarski.finiteExtensionDeduction
#print axioms Meta.BareArithmeticTarski.extendWithRosser_consistent
#print axioms Meta.BareArithmeticTarski.paProvabilityAccumulatingSystem
#print axioms Meta.BareArithmeticTarski.paProvabilityClosedSystem
```

Toutes les sorties doivent indiquer qu’aucun axiome n’est utilisé.

## 17. Interdits spécifiques

La construction est rejetée si elle utilise l’un des raccourcis suivants :

```text
définir Prov_PA par Sentence.models ;
poser la représentabilité comme champ sans construire la formule ;
confondre Provable(¬φ) avec ¬Provable(φ) ;
reprendre le patch sémantique de vérité comme patch de prouvabilité ;
déclarer T + R cohérente par hypothèse ;
injecter un compteur dans CertifiedTheoryState ;
utiliser la longueur de l’histoire comme preuve de fraîcheur ;
utiliser une axiomatisation « vraie dans Nat » non calculable ;
utiliser Classical, propext ou Quot.sound ;
remplacer une dérivation objet par un théorème de vérité sémantique ;
annoncer le lemme diagonal négatif interne avec le seul diagonal_spec actuel ;
supposer un pont terminal de réflexion ou de correction.
```

Les contraintes globales du dépôt restent applicables :

```text
aucun axiom ;
aucun sorry ;
aucun admit ;
aucun noncomputable ;
un seul bloc AXIOM_AUDIT à la fin de chaque fichier Lean modifié ;
aucune dépendance à FoundationBridge.
```

## 18. Critère de réussite

Le projet `Prov_PA` est terminé seulement lorsque les cinq affirmations
suivantes sont simultanément formalisées.

```text
1. Prov_PA est une formule arithmétique construite depuis un vérificateur de
   preuves primitif récursif.

2. Sa vérité standard au code de φ équivaut exactement à l’existence d’une
   dérivation PA de φ.

3. PA possède les preuves internes nécessaires au lemme diagonal négatif et au
   raisonnement de Rosser.

4. La cohérence de PA puis de chaque extension est construite sans hypothèse
   terminale.

5. Les extensions successives forment une action causale additive fidèle dont
   le gap courant est improuvable avant l’avance, prouvable après l’avance et
   mémorisé irréversiblement.
```

La conclusion autorisée sera alors :

```text
Le cadre ne travaille plus seulement avec la vérité standard d’un candidat.
Il construit un prédicat arithmétique de prouvabilité, produit depuis chaque
théorie cohérente une indépendance nouvelle, transforme cette indépendance en
axiome, reconstruit la prouvabilité du nouvel état et réalise fidèlement la
progression entière comme objet causal additif.
```
