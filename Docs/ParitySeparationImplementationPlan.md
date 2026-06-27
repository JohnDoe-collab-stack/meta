# Plan d'implementation : parite comme realisation separatrice

## Statut

Ce plan a ete applique. La parite separatrice minimale est formalisee dans
`Meta/Core/ParitySeparation.lean` comme realisation separatrice de
`OperationalTwoPole`.

## Objectif

Formaliser l'etat vise par `Docs/OperationalTwo.md` :

```text
parite separatrice minimale, formalisee :
deux poles comme separation de regimes
```

Le but n'est pas d'introduire une arithmetique de la parite. Le but est de
formaliser la realisation separatrice minimale du `2` operationnel deja expose
par :

```lean
StructuralTwoPole
OperationalTwoPole
```

La realisation attendue est :

```text
2 = separation minimale de regimes
```

Elle doit donc instancier le schema :

```text
pole gauche
pole droit
meme projection visible
separation conservee
reparation locale du pole forme
refus de la presentation contractee
```

## Base formelle existante

Le noyau fournit deja :

```lean
ProjectionObstruction
LocalProjectiveRecovery
StructuralReferentialGap
OperationalReferentialGap
ShortReferentialPresentation
StructuralTwoPole
OperationalTwoPole
```

Le champ decisif de `OperationalTwoPole` vient de `LocalProjectiveRecovery` :

```lean
repair : RepairOf formed
recovered : Interface
recovered_eq_formed : recovered = formed
```

Donc une realisation separatrice correcte ne peut pas etre seulement deux
constructeurs distincts. Elle doit aussi porter une reparation locale indexee
par le pole forme.

## Emplacement retenu

Nouveau fichier :

```text
Meta/Core/ParitySeparation.lean
```

Import unique :

```lean
import Meta.Core.TwoPole
```

Raison :

* la realisation separatrice est independante de l'arithmetique ;
* elle ne depend ni de `Dynamics`, ni de `Tarski`, ni de `Bell`, ni de `Beth` ;
* elle est une instance minimale du vocabulaire transversal du noyau ;
* elle ne doit pas importer `Classical`, `propext`, `Quot.sound`, ni aucun
  fichier externe.

`Meta.lean` devra importer ce fichier dans le bloc Core, apres
`Meta.Core.TwoPole` et avant les couches dynamiques ou ordonnees :

```lean
import Meta.Core.TwoPole
import Meta.Core.ParitySeparation
import Meta.Core.DynamicStability
```

## Definitions Lean a ajouter

### Regimes separes

```lean
inductive ParityRegime where
  | left
  | right
```

Ce type porte seulement la separation minimale de regimes. Les noms `left` et
`right` sont preferes a des noms arithmetiques pour eviter toute confusion avec
une theorie numerique externe.

### Visible contracte

```lean
inductive ParityVisible where
  | contracted
```

La projection visible doit oublier le regime :

```lean
def parityProjection : ParityRegime -> ParityVisible
  | _ => ParityVisible.contracted
```

avec :

```lean
parityProjection ParityRegime.left = ParityVisible.contracted
parityProjection ParityRegime.right = ParityVisible.contracted
```

### Separation interne

Ajouter les lemmes constructifs :

```lean
theorem parityRegime_left_ne_right :
    ParityRegime.left = ParityRegime.right -> False

theorem parityRegime_right_ne_left :
    ParityRegime.right = ParityRegime.left -> False

theorem parityProjection_left_eq_right :
    parityProjection ParityRegime.left =
      parityProjection ParityRegime.right

theorem parityProjection_right_eq_left :
    parityProjection ParityRegime.right =
      parityProjection ParityRegime.left
```

Ces preuves doivent etre par reduction/cas sur les constructeurs, sans
`Classical`.

Strategie de preuve attendue :

```lean
by
  intro h
  cases h
```

Pour les egalites de projection, la preuve attendue est `rfl`.

### Reparation locale

La reparation doit etre indexee par le regime forme :

```lean
structure ParityRegimeRepair
    (regime : ParityRegime) where
  visible : ParityVisible
  recovered : ParityRegime
  visible_eq_projection : visible = parityProjection regime
  recovered_eq_regime : recovered = regime
```

Puis :

```lean
def parityRegimeRepair
    (regime : ParityRegime) :
    ParityRegimeRepair regime
```

Cette reparation est volontairement locale : elle ne reconstruit pas tous les
regimes depuis le visible. Elle restaure seulement le regime forme deja porte
par l'interface operationnelle.

Implementation attendue :

```lean
def parityRegimeRepair
    (regime : ParityRegime) :
    ParityRegimeRepair regime where
  visible := parityProjection regime
  recovered := regime
  visible_eq_projection := rfl
  recovered_eq_regime := rfl
```

## Realisations deux-poles

### Orientation gauche-droite

```lean
def parityStructuralTwoPole :
    StructuralTwoPole
      ParityRegime
      ParityVisible
      parityProjection
```

avec :

```lean
left := ParityRegime.left
right := ParityRegime.right
sameProjection := parityProjection_left_eq_right
separatedInterface := parityRegime_left_ne_right
```

Puis :

```lean
def parityOperationalTwoPole :
    OperationalTwoPole
      ParityRegime
      ParityVisible
      parityProjection
      ParityRegimeRepair
```

avec :

```lean
formed := ParityRegime.left
shadow := ParityRegime.right
sameProjection := parityProjection_left_eq_right
separated := parityRegime_left_ne_right
repair := parityRegimeRepair ParityRegime.left
recovered := ParityRegime.left
recovered_eq_formed := rfl
```

### Orientation droite-gauche

La realisation separatrice ne doit pas figer arbitrairement un seul pole forme.
Il faut donc ajouter l'orientation inverse :

```lean
def parityOppositeStructuralTwoPole :
    StructuralTwoPole
      ParityRegime
      ParityVisible
      parityProjection

def parityOppositeOperationalTwoPole :
    OperationalTwoPole
      ParityRegime
      ParityVisible
      parityProjection
      ParityRegimeRepair
```

avec `formed := right` et `shadow := left`.

## Theoremes a ajouter

### Projection et separation

```lean
theorem parityOperationalTwoPole_sameVisible :
    parityProjection
      (operationalTwoPole_leftPole parityOperationalTwoPole) =
    parityProjection
      (operationalTwoPole_rightPole parityOperationalTwoPole)

theorem parityOperationalTwoPole_separated :
    operationalTwoPole_leftPole parityOperationalTwoPole =
      operationalTwoPole_rightPole parityOperationalTwoPole -> False
```

Memes theoremes pour `parityOppositeOperationalTwoPole`.

Noms attendus :

```lean
theorem parityOppositeOperationalTwoPole_sameVisible :
    parityProjection
      (operationalTwoPole_leftPole parityOppositeOperationalTwoPole) =
    parityProjection
      (operationalTwoPole_rightPole parityOppositeOperationalTwoPole)

theorem parityOppositeOperationalTwoPole_separated :
    operationalTwoPole_leftPole parityOppositeOperationalTwoPole =
      operationalTwoPole_rightPole parityOppositeOperationalTwoPole -> False
```

### Refus de la contraction

```lean
theorem parityStructuralTwoPole_refutes_shortPresentation
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False

theorem parityOperationalTwoPole_refutes_shortPresentation
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False
```

Memes theoremes pour l'orientation inverse.

Noms attendus :

```lean
theorem parityOppositeStructuralTwoPole_refutes_shortPresentation
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False

theorem parityOppositeOperationalTwoPole_refutes_shortPresentation
    (short :
      ShortReferentialPresentation
        ParityRegime
        ParityVisible
        parityProjection) :
    False
```

### Non-contractibilite

```lean
theorem parityOperationalTwoPole_not_contractible
    (contractible :
      ContractibleReferentialGap
        ParityRegime
        ParityVisible
        parityProjection) :
    False
```

Meme theoreme pour l'orientation inverse.

Nom attendu :

```lean
theorem parityOppositeOperationalTwoPole_not_contractible
    (contractible :
      ContractibleReferentialGap
        ParityRegime
        ParityVisible
        parityProjection) :
    False
```

### Pas de reconstruction globale

```lean
def parityOperationalTwoPole_noProjectiveReconstruction :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False)
```

Meme definition pour l'orientation inverse.

Nom attendu :

```lean
def parityOppositeOperationalTwoPole_noProjectiveReconstruction :
    ((recover : ParityVisible -> ParityRegime) ->
      ((regime : ParityRegime) ->
        recover (parityProjection regime) = regime) ->
      False)
```

## Ordre d'implementation

### Phase 1 : fichier noyau

Creer :

```text
Meta/Core/ParitySeparation.lean
```

Ajouter dans cet ordre :

1. `import Meta.Core.TwoPole`
2. module doc ;
3. `namespace Meta`;
4. `namespace ClosedStabilityTheorem`;
5. `inductive ParityRegime`;
6. `inductive ParityVisible`;
7. `def parityProjection`;
8. lemmes de projection ;
9. lemmes de separation ;
10. `structure ParityRegimeRepair`;
11. `def parityRegimeRepair`;
12. orientations structurelles ;
13. orientations operationnelles ;
14. theoremes de projection/separation ;
15. theoremes de refus de short presentation ;
16. theoremes de non-contractibilite ;
17. definitions de non-reconstruction ;
18. fermeture des namespaces ;
19. bloc `AXIOM_AUDIT` final.

### Phase 2 : agregateur

Modifier :

```text
Meta.lean
```

Ajouter seulement :

```lean
import Meta.Core.ParitySeparation
```

Ne pas modifier l'ordre des autres familles sauf necessite de compilation.

### Phase 3 : documentation

Modifier :

```text
Docs/OperationalTwo.md
```

Remplacer l'etat futur de la parite separatrice minimale par l'etat formalise.
Conserver comme futur uniquement les raccords dynamiques particuliers.

### Phase 4 : validation

Executer :

```bash
lake build
```

Puis verifier le nouveau fichier par recherche textuelle des interdits.

### Phase 5 : controle git

Avant commit eventuel :

```bash
git status -sb
git diff --stat
git diff -- Meta/Core/ParitySeparation.lean Meta.lean Docs/OperationalTwo.md
```

Le scope attendu est strictement :

```text
Meta/Core/ParitySeparation.lean
Meta.lean
Docs/OperationalTwo.md
```

S'il y a un autre fichier modifie, il faut l'expliquer ou le retirer du scope.

## Documentation a mettre a jour

Modifier `Docs/OperationalTwo.md`.

Remplacer l'ancien etat preparatoire :

```text
parite separatrice minimale :
deux poles comme separation de regimes
```

par un etat en deux temps :

```text
parite separatrice minimale, formalisee :
deux poles comme separation de regimes

raccords dynamiques particuliers :
hors de cette passe
```

Il faut conserver la distinction :

```text
countdown = realisation terminale par retour
parite   = realisation separatrice de regimes
```

La documentation ne doit pas suggerer que la parite separatrice depend d'une
dynamique particuliere.

## Integration dans `Meta.lean`

Ajouter :

```lean
import Meta.Core.ParitySeparation
```

Position :

```lean
import Meta.Core.TwoPole
import Meta.Core.ParitySeparation
import Meta.Core.DynamicStability
```

Cela garde l'ordre conceptuel :

```text
gap
referential length
two-pole
parity separation
dynamic stability
order gap
instances
```

## Bloc audit obligatoire

Le nouveau fichier Lean devra se terminer par un unique bloc :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ParityRegime
#print axioms Meta.ClosedStabilityTheorem.ParityVisible
#print axioms Meta.ClosedStabilityTheorem.parityProjection
#print axioms Meta.ClosedStabilityTheorem.parityRegime_left_ne_right
#print axioms Meta.ClosedStabilityTheorem.parityRegime_right_ne_left
#print axioms Meta.ClosedStabilityTheorem.parityProjection_left_eq_right
#print axioms Meta.ClosedStabilityTheorem.parityProjection_right_eq_left
#print axioms Meta.ClosedStabilityTheorem.ParityRegimeRepair
#print axioms Meta.ClosedStabilityTheorem.parityRegimeRepair
#print axioms Meta.ClosedStabilityTheorem.parityStructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOppositeStructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_sameVisible
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_separated
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_sameVisible
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_separated
#print axioms Meta.ClosedStabilityTheorem.parityStructuralTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.parityOppositeStructuralTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_not_contractible
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_not_contractible
#print axioms Meta.ClosedStabilityTheorem.parityOperationalTwoPole_noProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.parityOppositeOperationalTwoPole_noProjectiveReconstruction
/- AXIOM_AUDIT_END -/
```

Si un nom change pendant l'implementation, le bloc audit doit etre mis a jour
avec le vrai nom final. Aucun placeholder n'est acceptable.

## Validation obligatoire

Apres implementation :

```bash
lake build
```

Puis verifier :

```bash
rg -n "open Classical|Classical\\.|propext|Quot\\.sound|^axiom" \
  Meta/Core/ParitySeparation.lean
```

Critere d'acceptation :

* `lake build` passe ;
* `Meta/Core/ParitySeparation.lean` a exactement un bloc `AXIOM_AUDIT` ;
* le bloc est a la fin du fichier ;
* les noms du bloc existent ;
* les audits du nouveau fichier n'affichent aucun axiome ;
* aucune dependance interdite n'apparait dans le nouveau fichier ;
* `Meta.lean` importe le fichier au bon niveau ;
* `Docs/OperationalTwo.md` dit que la parite separatrice minimale est
  formalisee.

## Criteres de refus

L'implementation doit etre refusee si :

* elle utilise une notion arithmetique externe ;
* elle identifie la parite separatrice a une operation numerique ;
* elle cree une structure concurrente a `OperationalTwoPole` au lieu de
  l'instancier ;
* elle ne fournit qu'une orientation et oublie l'orientation inverse ;
* elle omet la reparation locale `RepairOf formed` ;
* elle prouve seulement une version conditionnelle du type
  "si une reparation existe alors..." ;
* elle laisse `Docs/OperationalTwo.md` dans un etat contradictoire ;
* elle ne met pas a jour `Meta.lean` ;
* elle ne compile pas ;
* elle introduit un axiome ou une dependance interdite.

## Non-objectifs

Ne pas introduire :

```text
Nat
modulo
terminologie arithmetique externe
division
decidabilite globale
Classical
propext
Quot.sound
axiom
```

Ne pas raccorder une dynamique particuliere dans cette passe.

Ne pas remplacer la realisation countdown : elle reste la realisation terminale
par retour.

Ne pas faire de la parite separatrice une nouvelle theorie concurrente du gap.
Elle doit etre une instance de `OperationalTwoPole`.

## Exhaustivite du plan

Le plan est complet parce qu'il couvre les quatre surfaces necessaires :

```text
1. noyau formel :
   type des regimes, visible contracte, projection, separation, reparation

2. instance two-pole :
   structural, operational, orientation directe, orientation inverse

3. consequences :
   meme visible, separation, refus de short presentation,
   non-contractibilite, non-reconstruction globale

4. integration projet :
   import Meta.lean, documentation OperationalTwo, audit, build, scope git
```

Toute implementation qui ne couvre pas ces quatre surfaces serait partielle.

## Resultat attendu

Apres implementation, le cadre dira formellement :

```text
La structure OperationalTwoPole existe transversalement.
Le countdown en donne une realisation terminale.
La parite separatrice minimale en donne une realisation separatrice.
Les deux realisations visent le meme 2 operationnel, mais par deux faces
distinctes : fermeture et separation.
```
