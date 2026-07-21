# Plan de fermeture arithmétique et causale complète

## 0. Cible

Le but est de fermer la chaîne suivante sans `Foundation`, sans oracle
sémantique et sans hypothèse terminale ajoutée :

```text
syntaxe arithmétique ordinaire
→ substitution capture-avoiding calculable
→ représentation arithmétique de son graphe
→ diagonalisation interne
→ patch syntaxique local
→ contexte de Tarski patchable fermé
→ dynamique causale additive et fidèle
→ totalité historique non épuisable
→ identification finale à Nat
```

La sortie terminale doit être une valeur Lean fermée. Elle ne doit contenir ni
rang injecté, ni fenêtre, ni générateur externe de fraîcheur, ni pont de
fermeture conditionnel.

## 1. Réparer le noyau arithmétique constructif

### Travail

1. remplacer l’évaluation relationnelle fragile des programmes primitifs
   récursifs par un évaluateur structural total ;
2. conserver une relation positive d’exécution sous forme d’égalité avec cet
   évaluateur ;
3. construire une machine à piles qui transporte explicitement la profondeur
   de De Bruijn ;
4. prouver son exécution exacte sur les termes et les formules ;
5. compiler la machine en un programme primitif récursif positif.

### Sorties exigées

```text
PRFunction.runCore
PRFunctionVector.runCore
substitutionMachineRun
RawTerm.substitutionMachineRun_correct
RawFormula.substitutionMachineRun_correct
machineSubstituteNumeralCode_code
PRFunction.captureAvoidingDiagonalSubstitution
PRFunction.captureAvoidingDiagonalSubstitution_evaluates_code
```

### Porte 1

```text
la machine traite réellement les quantificateurs ;
le résultat commute avec la substitution syntaxique ;
le carburant est borné par une fonction calculable du code ;
aucune preuve de correction ne dépend d’un axiome.
```

## 2. Éliminer les dépendances interdites

### Travail

1. remplacer les preuves d’arithmétique qui font remonter `propext`,
   `Quot.sound` ou `Classical` ;
2. remplacer l’encodage β fondé sur des résultats classiques de type CRT par
   un encodage factoriel constructif ;
3. exprimer les certificats vectoriels de représentabilité par une structure
   positive dans `Type` ;
4. supprimer les reliquats `noncomputable` de la chaîne exécutable ;
5. auditer chaque module à sa frontière publique.

### Sorties exigées

```text
ConstructiveBetaEncoding.lean
ArithmeticGraphVector.Represents : Type
PRFunction.graphFormula_spec
diagonalSubstitutionGraph_code
```

### Porte 2

Le grep des sources actives doit être vide pour :

```text
axiom
sorry
admit
Classical
propext
Quot.sound
noncomputable
unsafe
```

Les occurrences qui nomment ces termes dans une phrase d’audit documentaire
ne constituent pas des dépendances Lean ; elles doivent rester hors des
déclarations.

## 3. Construire le contexte arithmétique patchable ordinaire

### Travail

1. représenter la substitution diagonale par une formule de l’arithmétique
   `{0, S, +, ×, =, ∧, ∨, →, ∀, ∃}` ;
2. construire la phrase diagonale par auto-substitution de son corps ;
3. dériver sa spécification sémantique depuis le graphe représenté ;
4. définir le patch :

```text
τ⁺(x) := (x = ⌜d⌝ ∧ d) ∨ (x ≠ ⌜d⌝ ∧ τ(x))
```

5. prouver l’accord au code réparé et la préservation hors de ce code ;
6. fermer `ArithmeticTarskiContext` puis
   `PatchableArithmeticTarskiContext`.

### Sorties exigées

```text
diagonal
diagonal_spec
patch
patch_agrees_at
patch_preserves_off_index
bareArithmeticTarskiContext
bareArithmeticPatchableContext
```

### Porte 3

La grammaire ne contient aucun constructeur réflexif. La sémantique n’inspecte
aucun code. Le diagonaliseur est une construction, pas un champ supposé. Le
patch n’a pas besoin de décider la vérité de la phrase diagonale.

## 4. Spécialiser le paquet causal complet

### Travail

Instancier, avec le contexte arithmétique précédent :

```text
GenericPatchOrbitTheorem
GenericVisibleCausalNonRecurrenceTheorem
TarskiCausalAdditiveRealizationTheorem
```

Le troisième paquet doit transporter au minimum :

```text
croissance exacte de la mémoire ;
totalité historique et non-épuisement ;
horloge intrinsèque ;
cardinalité finie exacte de chaque mémoire ;
action additive fidèle des mots causaux ;
addition de l’objet réalisé ;
identité et individuation par l’état causal complet ;
coordonnée naturelle additive et bijective ;
injection de Nat dans les gaps historiques.
```

### Sorties exigées

```text
bareArithmeticGenericPatchOrbitTheorem
bareArithmeticVisibleCausalNonRecurrenceTheorem
bareArithmeticCausalAdditiveRealizationTheorem
bareArithmeticTarskiClosedSystem
```

### Porte 4

`bareArithmeticTarskiClosedSystem` doit contenir les trois paquets et le
certificat de non-trivialité. Son audit doit être vide.

## 5. Ordre de vérification

```text
lake env lean Meta/Tarski/BareArithmetic/SubstitutionMachine.lean
lake env lean Meta/Tarski/BareArithmetic/PrimitiveRecursiveSubstitutionMachine.lean
lake build Meta.Tarski.BareArithmetic.Diagonal
lake build Meta.Tarski.BareArithmetic.ClosedOrbit
lake build Meta
```

Puis vérifier textuellement :

```text
un unique bloc AXIOM_AUDIT à la fin de chaque fichier Lean modifié ;
aucun import de FoundationBridge dans la chaîne ;
aucune dépendance interdite dans les sorties de #print axioms.
```

## 6. Statut d’exécution

Les quatre portes sont fermées dans le dépôt :

```text
1. machine de substitution exacte et primitive récursive : fermée ;
2. chaîne constructive sans dépendance interdite : fermée ;
3. contexte arithmétique patchable ordinaire : fermé ;
4. spécialisation causale-additive complète : fermée.
```

La déclaration terminale est :

```text
Meta.BareArithmeticTarski.bareArithmeticTarskiClosedSystem
```

Sa composante causale complète est :

```text
Meta.BareArithmeticTarski.bareArithmeticCausalAdditiveRealizationTheorem
```
