# Pont action Collatz / impair relaxe

## Objet

Ce document fixe le probleme exact restant entre :

```text
Nat enrichi :
role mediateur relaxe
-> gap relaxe maximal
-> temoin positif interne de diagonalisation
```

et :

```text
Collatz :
regime mediateur
-> action 3*n+1
```

Le point a corriger est strict :

```text
le code actuel attache bien 3*n+1 au regime mediateur,
mais il ne prouve pas encore que 3*n+1 exploite le role impair relaxe.
```

Il faut donc etudier puis formaliser un pont propre entre :

```text
mediatingValue k pris dans un gap relaxe
```

et :

```text
action Collatz 3*n+1.
```

## Etat actuel du code

### 1. Role mediateur enrichi

Dans :

```text
Meta/Arithmetic/Parity.lean
```

on a :

```lean
inductive NatEnrichedParityRole where
  | closingExcess : Nat -> NatEnrichedParityRole
  | mediatingValue : Nat -> NatEnrichedParityRole
```

La projection visible oublie le role :

```lean
natEnrichedParityRolePayload
```

avec :

```text
payload(closingExcess k) = k
payload(mediatingValue k) = k
```

Donc `closingExcess k` et `mediatingValue k` sont deux roles distincts avec le
meme payload.

### 2. Gap relaxe autour du role mediateur

Toujours dans :

```text
Meta/Arithmetic/Parity.lean
```

on a :

```lean
structure NatEnrichedParityRelaxedBilateralGap (k : Nat)
```

Cette structure porte :

```text
leftRole      = closingExcess k
mediatingRole = mediatingValue k
rightRole     = closingExcess rightPayload
divergence    > 0
```

Le cas canonique actuel est :

```lean
natEnrichedParityMaximallyRelaxedBilateralGap k
```

avec :

```lean
divergence = natEnrichedParityMaximalRelaxedDivergence k
```

et :

```lean
natEnrichedParityMaximalRelaxedDivergence k = (k + k) + 2
```

### 3. Temoin positif interne

Le meme fichier contient :

```lean
NatEnrichedParityPositiveInternalDiagonalWitness k
```

qui porte :

```text
relaxedGap
DiagonalCertificate core
ProjectionObstruction core
witness
witness = relaxedGap.divergence
witness > 0
witness = natEnrichedParityMaximalRelaxedDivergence k
```

Donc le temoin positif interne est bien relie au gap relaxe Nat enrichi.

### 4. Codage non relaxe

Plus bas dans `Meta/Arithmetic/Parity.lean`, on recupere une lecture classique :

```lean
natEnrichedParityRoleCode (closingExcess k) = 2*k
natEnrichedParityRoleCode (mediatingValue k) = 2*k+1
```

et :

```lean
OddClassical n := Exists (fun k : Nat => n = 2*k+1)
```

Ce codage est une lecture non relaxee.

Le code prouve aussi :

```lean
natEnrichedParityMaximalRelaxedDivergence_ne_nonrelaxedMediatingCode
```

qui dit que :

```text
divergence maximale relaxee
!=
code non relaxe du mediateur au meme index.
```

Ce point est important : l'impair relaxe ne doit pas etre defini par `2*k+1`.

### 5. Action Collatz actuelle

Dans :

```text
Meta/Collatz/OperationalParity.lean
```

on a :

```lean
def collatzParityAction (n : Nat) : ParityRegime -> Nat
  | ParityRegime.left => n / 2
  | ParityRegime.right => 3 * n + 1
```

Puis :

```lean
collatzMediatingActionOfIntersection intersection n = 3*n+1
```

Le fichier prouve bien :

```text
regime mediateur/shadow
-> action 3*n+1.
```

Mais cette preuve ne consomme pas encore le gap relaxe.

### 6. Instanciation relaxee actuelle cote Collatz

Toujours dans :

```text
Meta/Collatz/OperationalParity.lean
```

on a :

```lean
collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection intersection
```

de type :

```lean
NatEnrichedParityPositiveInternalDiagonalWitness
  (formedPositiveExcessOfIntersection intersection)
```

Donc Collatz instancie le temoin positif Nat enrichi a l'index forme :

```text
k = formedPositiveExcessOfIntersection intersection.
```

Mais cette instanciation ne depend pas de la valeur :

```text
3*n+1.
```

## Diagnostic strict

Le code actuel prouve :

```text
intersection
-> role mediateur/shadow
-> action 3*n+1
```

et separement :

```text
intersection
-> index forme k
-> gap relaxe maximal Nat enrichi
-> temoin positif interne
-> consommation countdown
```

Ce qui manque est le pont :

```text
action 3*n+1
-> exploitation du role mediateur relaxe
-> meme support que le temoin positif interne.
```

Sans ce pont, l'action `3*n+1` est seulement posee sur le regime `right`.
Elle n'est pas encore demontree comme action propre de l'impair relaxe.

## Verification de portee

Le diagnostic ci-dessus est soutenu par le code.

Ce qui est soutenu :

```text
mediatingValue k
-> regime right
-> action 3*n+1
```

par :

```lean
parityRegimeOfNatRole
collatzParityAction
collatzMediatingActionOfIntersection_eq_three_mul_add_one
```

Ce qui est aussi soutenu :

```text
mediatingValue k dans un gap relaxe
-> DiagonalCertificate
-> ProjectionObstruction
-> witness positif
-> witness = natEnrichedParityMaximalRelaxedDivergence k
```

par :

```lean
NatEnrichedParityRelaxedBilateralGap
natEnrichedParityRelaxedDiagonalCertificate
natEnrichedParityRelaxedProjectionObstruction
NatEnrichedParityPositiveInternalDiagonalWitness
```

Ce qui n'est pas encore soutenu :

```text
3*n+1
-> meme support que witness
```

ou :

```text
3*n+1
-> consommation de la divergence relaxee
```

ou :

```text
l'action 3*n+1 est definie depuis NatEnrichedParityRelaxedBilateralGap.
```

Ces trois phrases ne doivent pas etre utilisees tant qu'un theoreme Lean ne les
porte pas explicitement.

## Objet a isoler : impair relaxe

Le code actuel ne possede pas encore un objet nomme :

```lean
NatEnrichedRelaxedOddRole k
```

ou equivalent.

Il faut probablement introduire une structure positive, avant Collatz, du type :

```lean
structure NatEnrichedRelaxedOddRole (k : Nat) where
  mediatingRole : NatEnrichedParityRole
  mediatingRole_eq :
    mediatingRole = NatEnrichedParityRole.mediatingValue k
  relaxedGap :
    NatEnrichedParityRelaxedBilateralGap k
  relaxedGap_mediating :
    relaxedGap.mediatingRole = mediatingRole
  diagonalCertificate :
    DiagonalCertificate
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload
  projectionObstruction :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload
  positiveWitness : Nat
  positiveWitness_eq_divergence :
    positiveWitness = relaxedGap.divergence
  positiveWitness_pos :
    0 < positiveWitness
```

Cette structure doit etre une facade de ce qui existe deja :

```lean
natEnrichedParityPositiveInternalDiagonalWitnessOfMaximallyRelaxedGap k
```

mais elle doit nommer explicitement :

```text
l'impair relaxe = role mediateur + gap relaxe + temoin positif.
```

Elle ne doit pas mentionner :

```text
2*k+1
OddClassical
natEnrichedParityRoleCode
```

dans sa definition.

Cette etape est implementable immediatement, parce qu'elle ne cree aucun pont
nouveau. Elle nomme seulement un paquet deja porte par `Parity.lean`.

Implementation attendue possible :

```text
Meta/Arithmetic/RelaxedOdd.lean
```

ou une section separee dans :

```text
Meta/Arithmetic/Parity.lean
```

si l'on veut eviter un fichier trop mince.

Theoremes publics attendus :

```lean
natEnrichedRelaxedOddRole_mediating_eq
natEnrichedRelaxedOddRole_witness_eq_divergence
natEnrichedRelaxedOddRole_witness_pos
natEnrichedRelaxedOddRole_witness_eq_maximalDivergence
natEnrichedRelaxedOddRole_diagonal_left_eq_closing
natEnrichedRelaxedOddRole_diagonal_right_eq_mediating
```

Critere d'audit pour cette etape :

```text
aucun usage de OddClassical ;
aucun usage de natEnrichedParityRoleCode ;
aucun usage de 2*k+1 ;
aucun nouveau champ conditionnel.
```

## Pont Collatz vise

Une fois l'objet `NatEnrichedRelaxedOddRole k` isole, la couche Collatz doit
cesser de partir seulement de :

```text
ParityRegime.right
```

Elle doit partir d'un role relaxe.

Forme possible :

```lean
def collatzRelaxedOddAction
    {k : Nat}
    (odd : NatEnrichedRelaxedOddRole k)
    (n : Nat) :
    Nat :=
  3 * n + 1
```

Mais cette definition seule serait insuffisante si elle ne raccorde pas `n` au
role.

La vraie question de type est donc :

```text
quel est le n visible sur lequel agit 3*n+1 ?
```

Il y a deux candidats possibles.

### Candidat A : action sur le payload du role mediateur

On peut poser :

```text
n = natEnrichedParityRolePayload odd.mediatingRole
```

alors :

```text
n = k.
```

L'action devient :

```text
3*k+1.
```

Pont cible :

```lean
collatzRelaxedOddAction odd =
  3 * natEnrichedParityRolePayload odd.mediatingRole + 1
```

Mais il faut ensuite expliquer le rapport entre :

```text
3*k+1
```

et :

```text
positiveWitness = natEnrichedParityMaximalRelaxedDivergence k = (k+k)+2.
```

Il n'y a pas d'egalite generale entre ces deux valeurs.

Donc ce candidat ne suffit pas a lui seul.

### Candidat B : action sur une interface qui porte aussi la divergence

On peut au lieu de cela construire un paquet :

```lean
structure CollatzRelaxedOddActivation ...
```

qui porte simultanement :

```text
mediating payload
Collatz action value
relaxed positive witness
relation structurelle entre les deux
```

Mais il faut que la relation structurelle soit reelle et prouvable.
Elle ne peut pas etre un champ conditionnel du type :

```text
si un pont existe alors...
```

Le document ne permet pas encore d'affirmer quelle relation est correcte.

## Ce qui n'est pas encore implementable

Le pont fort :

```text
3*n+1 exploite le temoin positif du role relaxe
```

n'est pas encore implementable tel quel.

Raison precise :

```text
3*n+1
```

depend d'un argument visible `n`, alors que :

```text
natEnrichedParityMaximalRelaxedDivergence k
```

depend de l'index enrichi `k`.

Le code actuel ne donne pas de relation structurelle non conditionnelle entre
ces deux donnees.

En particulier, il ne faut pas introduire artificiellement :

```text
n = k
```

si cela ne vient pas d'un objet deja porte par la couche d'intersection.

Il ne faut pas non plus chercher une egalite numerique generale :

```text
3*k+1 = (k+k)+2
```

car elle est fausse en general.

Donc l'etape Collatz forte doit rester bloquee tant que le type exact du
support commun n'est pas trouve.

## Pont faible implementable

Un pont faible est implementable :

```text
intersection
-> mediatingRole = mediatingValue formedPositiveExcess
-> relaxedOddRole formedPositiveExcess
```

Ce pont dirait seulement :

```text
l'intersection Collatz active l'objet impair relaxe Nat enrichi
au meme index forme.
```

Il ne dirait pas encore :

```text
3*n+1 consomme ce temoin.
```

Fichier possible :

```text
Meta/Collatz/RelaxedOddActivation.lean
```

Theoremes possibles :

```lean
collatzRelaxedOddRoleOfIntersection
collatzRelaxedOddRoleOfIntersection_mediating_eq
collatzRelaxedOddRoleOfIntersection_witness_eq_positiveDiagonalValue
collatzRelaxedOddRoleOfIntersection_diagonal_right_eq_mediatingRole
```

Cette etape serait utile parce qu'elle remplacerait la phrase vague :

```text
Collatz utilise l'impair relaxe
```

par une phrase prouvee mais faible :

```text
Collatz active l'objet impair relaxe a l'index forme de l'intersection.
```

Elle ne doit pas etre vendue comme le pont complet vers `3*n+1`.

## Recherche du support commun

Le pont fort exige un support commun entre :

```text
action Collatz : 3*n+1
```

et :

```text
temoin positif du role relaxe :
natEnrichedParityMaximalRelaxedDivergence k.
```

Ce support commun ne doit pas etre ajoute comme hypothese.
Il doit etre produit par une structure deja presente, ou par une nouvelle
structure positive strictement intrinseque.

La recherche doit tester les candidats suivants dans l'ordre.

## Solution candidate principale retenue : support = rightPayload relaxe

La relecture du code indique que le support commun n'est pas :

```text
witness seul
```

mais :

```text
rightPayload du gap relaxe.
```

Statut apres re-etude :

```text
ce n'est plus seulement une intuition ;
la concordance doublee est prouvable en Lean sans axiome dans un test scratch.
```

La partie encore non acquise est seulement la version divisee par `/2`.

Dans `Meta/Arithmetic/Parity.lean`, le gap relaxe porte deja :

```lean
right_payload_eq_left_plus_divergence :
  natEnrichedParityRolePayload rightRole =
    natEnrichedParityRolePayload leftRole + divergence
```

Dans le cas maximal :

```lean
rightPayload =
  natEnrichedParityMaximallyRelaxedRightPayload k
```

avec :

```lean
natEnrichedParityMaximallyRelaxedRightPayload k =
  k + natEnrichedParityMaximalRelaxedDivergence k
```

Comme :

```text
natEnrichedParityMaximalRelaxedDivergence k = (k+k)+2
```

on obtient :

```text
rightPayload = k + ((k+k)+2) = 3*k+2.
```

Or la branche visible classique appliquee au code mediateur non relaxe donne :

```text
3*(2*k+1)+1 = 6*k+4 = 2*(3*k+2).
```

Donc la forme auditable prioritaire est :

```text
3*(2*k+1)+1 = 2 * rightPayload.
```

La forme divisee :

```text
(3*(2*k+1)+1) / 2 = rightPayload
```

est la lecture attendue du repli pair, mais elle demande un lemme constructif
local sur `/2` avant d'etre exposee comme theoreme officiel.

Ce point change le diagnostic.

Le temoin positif n'est pas directement la valeur visible `3*n+1`.
Le temoin positif est le deplacement interne :

```text
witness = divergence
```

et le support commun avec Collatz est :

```text
rightPayload = payload mediateur + witness.
```

La branche `3*n+1` visible produit alors :

```text
2 * rightPayload
```

lorsque `n` est la lecture non relaxee du role mediateur.

Autrement dit :

```text
role mediateur relaxe a l'index k
-> payload source k
-> witness = divergence maximale
-> rightPayload = k + witness
```

et la lecture visible classique donne :

```text
odd code visible = 2*k+1
Collatz odd step = 3*(2*k+1)+1
                  = 2 * rightPayload
```

Le `2*k+1` n'est donc pas la definition de l'impair relaxe.
Il intervient seulement comme lecture visible non relaxee du role mediateur au
moment de verifier la concordance avec l'ecriture classique de Collatz.

Cette solution evite l'erreur :

```text
3*k+1 = witness
```

et remplace par :

```text
3*(2*k+1)+1 = 2 * (k + witness).
```

Dans cette lecture :

```text
witness
```

mesure l'ecart produit par la relaxation, tandis que :

```text
rightPayload
```

est la valeur cible apres repli pair minimal.

## Theoremes Lean cibles de la solution

La solution doit etre formalisee sans definir l'impair relaxe par le code
classique.

### 1. Theoreme Nat enrichi : rightPayload maximal

Dans la couche Nat enrichi :

```lean
theorem natEnrichedParityMaximallyRelaxedRightPayload_eq_source_add_witness
    (k : Nat) :
    natEnrichedParityMaximallyRelaxedRightPayload k =
      k + natEnrichedParityMaximalRelaxedDivergence k :=
  rfl
```

Puis une facade :

```lean
theorem natEnrichedParityMaximallyRelaxedRightPayload_eq_three_mul_add_two
    (k : Nat) :
    natEnrichedParityMaximallyRelaxedRightPayload k =
      3*k + 2
```

Cette preuve est arithmetique interne, mais elle ne definit pas l'impair
relaxe par `2*k+1`.

### 2. Theoreme de concordance visible avec l'ecriture Collatz

Dans une couche de concordance separee :

```lean
theorem collatzVisibleOddStep_eq_two_mul_relaxedRightPayload
    (k : Nat) :
    3 * (natEnrichedParityRoleCode
          (NatEnrichedParityRole.mediatingValue k)) + 1 =
      2 * natEnrichedParityMaximallyRelaxedRightPayload k
```

Ce theoreme utilise `natEnrichedParityRoleCode` uniquement comme lecture
visible classique du role mediateur.

Il ne doit pas etre utilise pour construire :

```text
NatEnrichedRelaxedOddRole.
```

Verification scratch effectuee :

```text
ce theoreme est prouvable en Lean sans axiome,
sans omega,
sans Nat.add_mul,
sans Nat.mul_assoc,
sans propext,
sans Quot.sound.
```

Les lemmes propres a introduire avant lui sont :

```lean
theorem nat_three_mul_eq_double_add
    (k : Nat) :
    3 * k = (k + k) + k
```

preuve propre par :

```lean
change Nat.succ 2 * k = (k + k) + k
rw [Nat.succ_mul, Nat.two_mul]
```

puis :

```lean
theorem nat_three_mul_two_mul_eq_two_mul_three_mul
    (k : Nat) :
    3 * (2 * k) = 2 * (3 * k)
```

preuve propre par induction avec seulement :

```lean
Nat.mul_succ
Nat.mul_add
```

Ces lemmes ont ete testes en scratch avec :

```lean
#print axioms
```

et ne dependent d'aucun axiome.

Script scratch complet teste :

```lean
theorem nat_three_mul_eq_double_add
    (k : Nat) :
    3 * k = (k + k) + k := by
  change Nat.succ 2 * k = (k + k) + k
  rw [Nat.succ_mul, Nat.two_mul]

theorem nat_three_mul_two_mul_eq_two_mul_three_mul
    (k : Nat) :
    3 * (2 * k) = 2 * (3 * k) := by
  induction k with
  | zero => rfl
  | succ k ih =>
      rw [Nat.mul_succ 2 k]
      rw [Nat.mul_succ 3 k]
      rw [Nat.mul_add]
      rw [Nat.mul_add]
      rw [ih]

theorem natEnrichedParityMaximallyRelaxedRightPayload_eq_three_mul_add_two
    (k : Nat) :
    natEnrichedParityMaximallyRelaxedRightPayload k =
      3 * k + 2 := by
  unfold natEnrichedParityMaximallyRelaxedRightPayload
  rw [natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two]
  calc
    k + ((k + k) + 2) = (k + (k + k)) + 2 := by
      rw [← Nat.add_assoc k (k + k) 2]
    _ = ((k + k) + k) + 2 := by
      rw [Nat.add_comm k (k + k)]
    _ = 3 * k + 2 := by
      rw [← nat_three_mul_eq_double_add k]

theorem collatzVisibleOddStep_eq_two_mul_relaxedRightPayload
    (k : Nat) :
    3 * (natEnrichedParityRoleCode
          (NatEnrichedParityRole.mediatingValue k)) + 1 =
      2 * natEnrichedParityMaximallyRelaxedRightPayload k := by
  rw [natEnrichedParityMaximallyRelaxedRightPayload_eq_three_mul_add_two]
  unfold natEnrichedParityRoleCode
  rw [Nat.mul_add]
  rw [Nat.mul_one]
  rw [nat_three_mul_two_mul_eq_two_mul_three_mul]
  rw [Nat.mul_add]
```

Audit scratch obtenu :

```text
nat_three_mul_eq_double_add
does not depend on any axioms

natEnrichedParityMaximallyRelaxedRightPayload_eq_three_mul_add_two
does not depend on any axioms

nat_three_mul_two_mul_eq_two_mul_three_mul
does not depend on any axioms

collatzVisibleOddStep_eq_two_mul_relaxedRightPayload
does not depend on any axioms
```

Contraintes de preuve :

```text
ne pas utiliser omega ;
ne pas utiliser ac_rfl ;
ne pas utiliser Nat.add_mul ;
ne pas utiliser Nat.mul_assoc ;
ne pas utiliser Nat.mul_div_right pour la version /2.
```

### 3. Theoreme de repli pair

Si l'on veut exposer le repli pair minimal :

```lean
theorem collatzVisibleOddStep_div_two_eq_relaxedRightPayload
    (k : Nat) :
    (3 * (natEnrichedParityRoleCode
            (NatEnrichedParityRole.mediatingValue k)) + 1) / 2 =
      natEnrichedParityMaximallyRelaxedRightPayload k
```

Ce theorem est la forme la plus proche du comportement usuel :

```text
odd step puis division par 2
```

mais il doit etre presente comme concordance visible, pas comme definition de
l'impair relaxe.

Attention audit :

```lean
Nat.mul_div_right
```

depend de `propext` dans cet environnement.

Donc ce theoreme ne doit pas etre prouve avec `Nat.mul_div_right`.

Deux options propres :

```text
1. reporter ce theorem ;
2. prouver un lemme constructif local specialise :
   ((2 * x) / 2 = x)
   sans utiliser Nat.mul_div_right.
```

Tant que ce lemme local n'est pas disponible avec audit propre, la forme
officielle du pont doit rester :

```text
3*(2*k+1)+1 = 2 * rightPayload
```

et non :

```text
(3*(2*k+1)+1)/2 = rightPayload.
```

### 4. Theoreme Collatz sur role relaxe

Une fois `NatEnrichedRelaxedOddRole k` isole :

```lean
theorem collatzRelaxedOddVisibleStep_eq_two_mul_rightPayload
    {k : Nat}
    (odd : NatEnrichedRelaxedOddRole k) :
    3 * natEnrichedParityRoleCode odd.mediatingRole + 1 =
      2 * odd.rightPayload
```

ou, si `rightPayload` n'est pas un champ direct de `NatEnrichedRelaxedOddRole`,
il faudra l'ajouter explicitement comme champ derive du `relaxedGap`.

Cette forme est preferable, car elle dit :

```text
Collatz visible sur le mediateur non relaxe
= double du payload cible du role relaxe.
```

Donc l'action `3*n+1` exploite bien la relaxation, mais via son payload cible,
pas par egalite directe avec le witness.

## Consequence conceptuelle

Le pont correct semble etre :

```text
impair relaxe
= role mediateur + divergence positive

rightPayload
= payload source + divergence

Collatz visible impair
= 2 * rightPayload
```

Donc `3*n+1` n'est pas le temoin positif lui-meme.
Il est la lecture visible doublee de la sortie relaxee.

La division par `2` n'est alors pas un detail externe :

```text
elle est le repli de la sortie visible doublee vers le rightPayload relaxe.
```

Mais formellement, dans l'etat actuel, le resultat auditable principal doit
etre l'egalite doublee :

```text
sortie visible = 2 * rightPayload.
```

La formulation avec division par deux demande un lemme constructif
supplementaire sur `/`.

Cela donne enfin un role precis au countdown et a la parite :

```text
la branche visible produit une sortie paire ;
le repli pair recupere le rightPayload relaxe ;
ce rightPayload contient le witness comme ecart interne.
```

Cette solution doit encore etre prouvee dans Lean.
Mais contrairement aux candidats precedents, elle identifie un support commun
precis :

```text
rightPayload = k + witness.
```

## Candidat 1 : support = payload du mediateur

Definition candidate :

```text
n = natEnrichedParityRolePayload odd.mediatingRole
```

Dans le cas canonique :

```text
n = k.
```

Action obtenue :

```text
3*k+1.
```

Temoin positif :

```text
natEnrichedParityMaximalRelaxedDivergence k = (k+k)+2.
```

Constat :

```text
3*k+1 != (k+k)+2
```

en general.

Donc ce candidat ne peut pas donner une egalite directe entre l'action et le
temoin.

Ce qu'il peut encore donner :

```text
Collatz agit sur le payload visible du role mediateur relaxe.
```

Theoreme faible possible :

```lean
theorem collatzRelaxedOddAction_eq_three_mul_payload_add_one
    {k : Nat}
    (odd : NatEnrichedRelaxedOddRole k) :
    collatzRelaxedOddAction odd =
      3 * natEnrichedParityRolePayload odd.mediatingRole + 1
```

Critere d'echec pour le pont fort :

```text
si le seul support trouve est le payload du mediateur,
alors le pont fort vers le temoin positif n'est pas obtenu.
```

## Candidat 2 : support = index forme de l'intersection

Definition candidate :

```text
k = formedPositiveExcessOfIntersection intersection
```

C'est le support deja utilise par :

```lean
collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
```

Theoreme deja soutenu :

```text
intersection
-> relaxedOddRole k
```

avec :

```text
k = formedPositiveExcessOfIntersection intersection.
```

Ce candidat donne un pont propre entre :

```text
intersection Collatz
```

et :

```text
impair relaxe Nat enrichi.
```

Mais il ne donne pas encore le lien avec :

```text
3*n+1.
```

Theoreme faible attendu :

```lean
def collatzRelaxedOddRoleOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedRelaxedOddRole
      (formedPositiveExcessOfIntersection intersection)
```

Puis :

```lean
theorem collatzRelaxedOddRoleOfIntersection_mediating_eq
theorem collatzRelaxedOddRoleOfIntersection_witness_eq_positiveDiagonalValue
theorem collatzRelaxedOddRoleOfIntersection_diagonal_right_eq_mediatingRole
```

Critere de validation :

```text
aucun 2*k+1 ;
aucun OddClassical ;
aucune relation ajoutee entre 3*n+1 et witness.
```

Critere d'echec pour le pont fort :

```text
si l'action 3*n+1 reste independante de cette structure,
alors on a seulement l'activation du role relaxe, pas son exploitation par
Collatz.
```

## Candidat 3 : support = valeur de l'action 3*n+1

Definition candidate :

```text
a = 3*n+1.
```

On pourrait essayer d'indexer le temoin positif par `a` :

```text
NatEnrichedRelaxedOddRole a
```

Mais cela deplace le probleme :

```text
on obtient un temoin au support 3*n+1,
pas un lien entre le support de depart et le temoin active.
```

Cette route risque donc de produire seulement :

```text
pour toute valeur a, Nat enrichi sait produire un temoin positif.
```

Ce qui est deja vrai pour tout index, et ne caracterise pas Collatz.

Theoreme possible mais insuffisant :

```lean
def collatzActionValueRelaxedOddRole
    (n : Nat) :
    NatEnrichedRelaxedOddRole (3*n+1)
```

Critere d'echec :

```text
si le role relaxe est construit apres coup au support 3*n+1,
alors Collatz ne l'a pas exploite ; on a seulement reindexe Nat enrichi.
```

Donc ce candidat est probablement a refuser comme pont fort.

## Candidat 4 : support = interface action + temoin

Definition candidate :

Construire une interface enrichie qui porte simultanement :

```text
mediatingRole
actionValue = 3*n+1
positiveWitness
```

Mais la structure doit contenir une relation produite, pas une relation
postulee.

Forme possible :

```lean
structure CollatzRelaxedOddActionInterface
    {k : Nat}
    (odd : NatEnrichedRelaxedOddRole k) where
  actionInput : Nat
  actionValue : Nat
  actionValue_eq :
    actionValue = 3 * actionInput + 1
  witness : Nat
  witness_eq :
    witness = odd.positiveWitness
  relation : ...
```

Le champ difficile est :

```lean
relation
```

Il ne peut pas etre une hypothese libre.
Il doit etre une egalite, une inegalite, une obstruction ou une consommation
derivee des donnees deja presentes.

Relations candidates a tester :

### 4.a Relation d'egalite

```text
actionValue = witness
```

Refusee en general, car :

```text
3*k+1 != (k+k)+2.
```

### 4.b Relation d'ordre

```text
actionValue <= witness
```

ou :

```text
witness <= actionValue
```

Ces relations dependent de `k`.

Par exemple :

```text
3*k+1 <= 2*k+2
```

est faux pour `k > 1`.

Et :

```text
2*k+2 <= 3*k+1
```

demande `1 <= k`.

Donc une relation d'ordre generale demanderait un domaine ou un index
supplementaire. Elle est dangereuse si elle est vendue comme totale.

### 4.c Relation de consommation

Une relation possible serait :

```text
actionValue produit une interface dont le formedPositiveExcess est witness.
```

Mais le code actuel ne contient pas une telle interface.

Il faudrait produire constructivement une intersection ou une trace :

```text
from actionValue
to formedPositiveExcess = witness
```

Sans cela, ce candidat reste non implementable.

### 4.d Relation de changement de role

Une autre possibilite serait :

```text
l'action 3*n+1 transforme une lecture mediating en lecture closing
```

Mais le code actuel n'a pas une fonction :

```text
NatEnrichedParityRole -> NatEnrichedParityRole
```

associee a l'action Collatz.

Il faudrait definir une action sur roles, pas seulement sur regimes :

```lean
def collatzActionOnParityRole
    (role : NatEnrichedParityRole) :
    NatEnrichedParityRole
```

Puis prouver qu'elle respecte le payload attendu.

Cette voie est peut-etre la plus proche du cadre, mais elle exige un nouveau
design.

## Candidat 5 : support = changement de regime, pas valeur numerique

Le pont pourrait ne pas etre une relation numerique entre :

```text
3*n+1
```

et :

```text
witness.
```

Il pourrait etre une relation de regime :

```text
mediating/shadow
-> action Collatz
-> production d'un etat qui doit etre relu par closing/forming
```

Dans ce cas, le support commun n'est pas un nombre, mais une interface :

```text
role mediateur
action
role closing de retour
```

Forme possible :

```lean
structure CollatzRelaxedOddRoleTransition
    {k : Nat}
    (odd : NatEnrichedRelaxedOddRole k) where
  sourceRole : NatEnrichedParityRole
  sourceRole_eq : sourceRole = odd.mediatingRole
  actionValue : Nat
  targetRole : NatEnrichedParityRole
  targetRole_eq :
    targetRole = NatEnrichedParityRole.closingExcess ...
  diagonalWitness : Nat
  diagonalWitness_eq : diagonalWitness = odd.positiveWitness
```

Le verrou devient :

```text
quel index doit porter targetRole ?
```

Les candidats pour cet index sont :

```text
actionValue
positiveWitness
formedPositiveExcess
```

Chacun donne une signification differente.

Ce candidat est le plus conceptuel, mais il demande le plus de precision avant
implementation.

## Ordre de travail recommande

### Etape 1 : isoler l'impair relaxe Nat

Implementer :

```text
NatEnrichedRelaxedOddRole
```

comme facade stricte de :

```text
NatEnrichedParityPositiveInternalDiagonalWitness
```

Sans Collatz.

Objectif :

```text
avoir un objet auditable pour l'impair relaxe.
```

### Etape 2 : instancier cet objet sur une intersection Collatz

Implementer :

```text
CollatzRelaxedOddActivation
```

ou :

```text
collatzRelaxedOddRoleOfIntersection
```

Objectif :

```text
Collatz active l'impair relaxe a l'index forme de l'intersection.
```

Ce n'est pas encore :

```text
3*n+1 exploite l'impair relaxe.
```

### Etape 3 : etudier l'action sur roles

Avant de chercher une relation numerique, etudier une fonction :

```lean
collatzActionOnParityRole
```

ou une structure de transition :

```lean
CollatzRelaxedOddRoleTransition
```

Objectif :

```text
faire agir Collatz sur l'interface de role,
pas seulement sur ParityRegime.
```

### Etape 4 : seulement ensuite chercher la relation au witness

Une fois l'action sur role definie, chercher si le temoin positif intervient
comme :

```text
target index
consumed excess
closing role
obstruction
ordre diagonal
```

Ne pas choisir a l'avance.


## Critere de reussite

Une implementation finale acceptable du pont fort doit prouver au minimum :

```text
1. un objet RelaxedOddRole existe dans Nat enrichi ;
2. il porte le role mediateur, le gap relaxe et le temoin positif ;
3. Collatz agit sur cet objet, pas seulement sur ParityRegime.right ;
4. l'action 3*n+1 est raccordee au support du temoin positif par un theoreme
   non conditionnel ;
5. aucun codage 2*k+1 n'est utilise pour definir l'impair relaxe.
```

Le point 4 est le verrou.

Avant le point 4, seules deux sous-etapes sont acceptables :

```text
A. isoler RelaxedOddRole dans Nat enrichi ;
B. instancier RelaxedOddRole sur une intersection Collatz.
```

Ces sous-etapes sont utiles, mais elles ne ferment pas le pont fort.

## Critere d'echec

L'implementation doit etre refusee si elle fait seulement :

```text
mediating regime = right
right -> 3*n+1
```

car cela est deja prouve et ne raccorde pas le gap relaxe.

Elle doit aussi etre refusee si elle fait :

```text
RelaxedOdd k := OddClassical (2*k+1)
```

ou si elle utilise `natEnrichedParityRoleCode` pour definir l'objet relaxe.

Elle doit encore etre refusee si elle ajoute une donnee aval :

```text
bridge : relation entre 3*n+1 et witness
```

sans la produire depuis les structures deja presentes.

## Conclusion actuelle

Etat strict :

```text
Nat enrichi possede le role mediateur relaxe et son temoin positif.
Collatz possede l'action 3*n+1 sur le regime mediateur.
Le code ne prouve pas encore que l'action 3*n+1 exploite le role mediateur
relaxe.
```

Donc la prochaine tache n'est pas de parler de pic, de hauteur de vol ou de
borne.

La prochaine tache est :

```text
isoler l'impair relaxe comme objet Nat enrichi,
puis l'instancier sur une intersection Collatz,
puis seulement chercher le support commun exact entre cet objet et l'action
Collatz 3*n+1.
```

Tant que ce support commun n'est pas identifie, il faut s'interdire de dire :

```text
Collatz utilise deja l'impair relaxe au sens fort.
```
