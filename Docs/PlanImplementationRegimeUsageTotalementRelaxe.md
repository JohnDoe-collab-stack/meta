# Plan d'implementation Lean du regime d'usage totalement relaxe

## Objet

Ce document prepare l'implementation Lean autonome du regime d'usage totalement
relaxe.

La cible Lean doit etre totalement independante :

```text
aucun import
aucune dependance a un autre fichier du projet
aucun axiome
aucune dependance a Classical
aucune dependance a propext
aucune dependance a Quot.sound
```

Le fichier Lean cible sera :

```text
Meta/Core/RelaxedUsageRegime.lean
```

Il devra formaliser uniquement la version totalement relaxee.

Il devra aussi etre exhaustif pour ce noyau. Cela signifie :

```text
definitions centrales
constructeurs canoniques
eliminateurs autorises
facades de lecture
non-trivialite locale portee par le regime
absence de tout eliminateur de collapse
presence des seuls eliminateurs locaux autorises
audit final
```

Exhaustif ne signifie pas ajouter des instances concretes, ni ajouter une
specialisation projective ou classique. Exhaustif signifie que tout ce qui est
necessaire au noyau totalement relaxe est present dans ce fichier unique.

Il ne doit pas partir de :

```text
x = y
q(x) = q(y)
forall r : V -> L
r(q(x)) = r(q(y))
```

Ces formes appartiennent aux specialisations contractives. Elles ne doivent pas
etre le noyau.

## Principe formel

Le noyau est un regime d'interface :

```text
I sur X
```

Il porte :

```text
Ctx      : contextes d'usage
Read     : lectures autorisees par contexte
defaultRead : lecture autorisee disponible dans chaque contexte
Out      : sorties dependantes des lectures
read     : evaluation d'une lecture sur un pole
Sep      : modes de separation
Coord    : modes de coordination
Use      : modes d'usage
OutRel   : relation ou compatibilite de sortie
```

Les objets `Sep`, `Coord`, `Use` et `OutRel` doivent etre en `Type`, pas en
`Prop`.

Raison :

```text
Type conserve les temoins.
Prop ecrase les temoins en simple existence propositionnelle.
```

Donc la version totalement relaxee doit conserver :

```text
modes de separation
modes de coordination
protocoles d'usage
instruments ou temoins de compatibilite en sortie
```

La non-trivialite minimale doit etre portee par le noyau :

```text
chaque contexte possede au moins une lecture autorisee.
```

Sans cela, le transport serait vide dans un contexte sans lecture.

Cette non-trivialite ne force pas une egalite, ne force pas une projection, et
ne force pas une relation de sortie particuliere. Elle garantit seulement que
le regime a toujours au moins un point de lecture sur lequel son eliminateur
local agit.

Portee exacte :

```text
non-trivialite partout dans le noyau
=
pour tout contexte gamma, une lecture autorisee existe ;
pour toute non-contraction, un transport concret existe via cette lecture.
```

L'informativite specifique de `OutRel` ne peut pas etre imposee uniformement
sans ajouter une semantique de domaine. Elle doit donc rester portee par les
instances concretes. Le noyau interdit seulement la vacuite structurelle :

```text
pas de contexte sans lecture ;
pas de non-contraction sans transport concret.
```

## Structure Lean cible

Le noyau doit etre de la forme suivante.

```lean
universe u c r o s k l m

namespace Meta
namespace RelaxedUsageRegime

structure RelaxedInterfaceRegime (X : Type u) where
  Ctx : Type c

  Read :
    Ctx -> Type r

  defaultRead :
    forall gamma : Ctx, Read gamma

  Out :
    forall gamma : Ctx, Read gamma -> Type o

  read :
    forall gamma : Ctx, forall rho : Read gamma, X -> Out gamma rho

  Sep :
    Ctx -> X -> X -> Type s

  Coord :
    Ctx -> X -> X -> Type k

  Use :
    Ctx -> X -> X -> Type l

  OutRel :
    forall gamma : Ctx,
    forall rho : Read gamma,
      Out gamma rho -> Out gamma rho -> Type m

  use_of_coord :
    forall {gamma : Ctx} {x y : X},
      Coord gamma x y ->
      Use gamma x y

  transport :
    forall {gamma : Ctx} {x y : X},
      Use gamma x y ->
      forall rho : Read gamma,
        OutRel gamma rho
          (read gamma rho x)
          (read gamma rho y)
```

Ce fichier ne doit pas importer `Init`, ni un fichier du projet, ni un fichier
Mathlib. Lean charge son noyau minimal automatiquement ; la source doit commencer
directement par :

```lean
universe u c r o s k l m
```

## Non-contraction

La non-contraction est une donnee structurelle :

```text
Sep gamma x y
+
Coord gamma x y
```

Elle ne doit pas etre definie comme :

```text
x != y
```

Lean :

```lean
structure NonContractiveUse
    {X : Type u}
    (I : RelaxedInterfaceRegime X)
    (gamma : I.Ctx)
    (x y : X) where
  separation :
    I.Sep gamma x y

  coordination :
    I.Coord gamma x y
```

## Eliminateur local autorise

Le point central de la formalisation est l'eliminateur.

`Use` ne donne pas :

```text
x = y
```

Il ne donne pas :

```text
substitution globale
```

Il donne seulement :

```text
transport dans les lectures autorisees
```

Lean :

```lean
def NonContractiveUse.use
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    I.Use gamma x y :=
  I.use_of_coord h.coordination

def NonContractiveUse.transport
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y)
    (rho : I.Read gamma) :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y) :=
  I.transport (NonContractiveUse.use h) rho
```

Ce sont les deux declarations principales du fichier.

## Non-trivialite locale obligatoire

Le fichier doit exposer le transport obtenu par la lecture canonique du contexte.

Cette declaration est importante : elle interdit que la non-contraction soit
seulement une structure sans lecture disponible.

```lean
def NonContractiveUse.defaultTransport
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    I.OutRel gamma (I.defaultRead gamma)
      (I.read gamma (I.defaultRead gamma) x)
      (I.read gamma (I.defaultRead gamma) y) :=
  NonContractiveUse.transport h (I.defaultRead gamma)
```

## Facades structurelles obligatoires

Pour que le fichier soit exhaustif, il ne suffit pas de definir la structure.
Il faut exposer les facades qui rendent la lecture du regime directe.

### Acces a la separation

```lean
def NonContractiveUse.separationWitness
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    I.Sep gamma x y :=
  h.separation
```

### Acces a la coordination

```lean
def NonContractiveUse.coordinationWitness
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    I.Coord gamma x y :=
  h.coordination
```

### Transport depuis la coordination seule

Cette facade rend explicite que la coordination suffit a produire l'usage puis
le transport autorise.

```lean
def transportOfCoord
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (coord : I.Coord gamma x y)
    (rho : I.Read gamma) :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y) :=
  I.transport (I.use_of_coord coord) rho
```

### Transport depuis l'usage

Cette facade isole l'eliminateur local de `Use`.

```lean
def transportOfUse
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (use : I.Use gamma x y)
    (rho : I.Read gamma) :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y) :=
  I.transport use rho
```

## Structure de chaine constructive

Pour rendre la dynamique explicite, ajouter un paquet de chaine constructive.

Ce paquet ne doit pas ajouter de nouvelle hypothese.

Il doit seulement regrouper :

```text
separation
coordination
use
transport pour une lecture donnee
```

Lean :

```lean
structure LocalTransportChain
    {X : Type u}
    (I : RelaxedInterfaceRegime X)
    (gamma : I.Ctx)
    (x y : X)
    (rho : I.Read gamma) where
  nonContractive :
    NonContractiveUse I gamma x y

  use :
    I.Use gamma x y

  use_eq :
    use = NonContractiveUse.use nonContractive

  transported :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y)
```

Constructeur canonique :

```lean
def localTransportChain
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y)
    (rho : I.Read gamma) :
    LocalTransportChain I gamma x y rho where
  nonContractive := h
  use := NonContractiveUse.use h
  use_eq := rfl
  transported := NonContractiveUse.transport h rho
```

Cette chaine est importante parce qu'elle rend explicite :

```text
Sep + Coord -> Use -> transport autorise
```

## Chaine non triviale par defaut

La chaine locale par defaut utilise la lecture `defaultRead`.

Elle garantit que toute non-contraction produit au moins un transport concret,
sans attendre qu'une lecture soit fournie de l'exterieur.

```lean
def defaultLocalTransportChain
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    LocalTransportChain I gamma x y (I.defaultRead gamma) :=
  localTransportChain h (I.defaultRead gamma)
```

## Projections depuis la chaine

Le fichier doit aussi permettre de relire la chaine sans destructurer
manuellement la structure.

```lean
def LocalTransportChain.separation
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    {rho : I.Read gamma}
    (chain : LocalTransportChain I gamma x y rho) :
    I.Sep gamma x y :=
  chain.nonContractive.separation

def LocalTransportChain.coordination
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    {rho : I.Read gamma}
    (chain : LocalTransportChain I gamma x y rho) :
    I.Coord gamma x y :=
  chain.nonContractive.coordination

def LocalTransportChain.transport
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    {rho : I.Read gamma}
    (chain : LocalTransportChain I gamma x y rho) :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y) :=
  chain.transported
```

## Ce qui doit rester absent

Le fichier ne doit pas contenir :

```lean
collapse :
  I.Use gamma x y -> x = y
```

Il ne doit pas contenir :

```lean
global_subst :
  I.Use gamma x y ->
  forall P : X -> Prop,
    P x -> P y
```

Il ne doit pas imposer :

```lean
I.read gamma rho x = I.read gamma rho y
```

La sortie doit seulement satisfaire :

```lean
I.OutRel gamma rho
  (I.read gamma rho x)
  (I.read gamma rho y)
```

Le fichier ne doit pas definir de version stricte projective, ni de version
classique. Ces formes appartiennent a d'autres fichiers ou a une annexe
documentaire, pas au noyau Lean autonome.

En particulier, le fichier cible ne doit pas contenir :

```text
q : X -> V
Id_q
ProjectedIdentity
Read := forall L, V -> L
OutRel := egalite stricte
```

## Audit Lean obligatoire

Le fichier cible etant un fichier Lean, il doit finir par un bloc unique :

```lean
/- AXIOM_AUDIT_BEGIN -/
#print axioms NonContractiveUse.use
#print axioms NonContractiveUse.transport
#print axioms NonContractiveUse.defaultTransport
#print axioms transportOfCoord
#print axioms transportOfUse
#print axioms localTransportChain
#print axioms defaultLocalTransportChain
#print axioms LocalTransportChain.transport
/- AXIOM_AUDIT_END -/
```

Le bloc doit etre place tout a la fin du fichier.

Le resultat attendu est :

```text
does not depend on any axioms
```

pour chaque declaration auditee.

## Verification attendue

Commandes :

```text
lake env lean Meta/Core/RelaxedUsageRegime.lean
```

Controle textuel :

```text
aucun import
aucun axiom
aucun Classical
aucun propext
aucun Quot.sound
aucun collapse
aucun global_subst
```

## Cible conceptuelle finale

Le fichier Lean doit formaliser ceci :

```text
Meme coordination.
Aucun collapse.
Transport seulement la ou le regime l'autorise.
```

Il ne doit pas formaliser une egalite affaiblie.

Il doit formaliser un regime d'usage dont le seul eliminateur est local aux
lectures autorisees.
