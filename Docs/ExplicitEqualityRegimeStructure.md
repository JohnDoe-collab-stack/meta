# Structure explicite de regime d'usage totalement relaxe

## Objet

Ce document fixe uniquement la version totalement relaxee.

On ne part plus de :

```text
x = y
q(x) = q(y)
forall r : V -> L
r(q(x)) = r(q(y))
```

Ces formes appartiennent a des cas plus contractifs.

La version totalement relaxee part d'un regime d'interface :

```text
I sur X
```

qui autorise une coordination d'usage entre poles maintenus separes.

Formule directrice :

```text
Meme coordination.
Pas meme etre.
Pas meme projection.
Pas meme sortie.
Seulement transport autorise.
```

## 1. Objet central

L'objet central n'est pas une egalite.

L'objet central est un regime d'interface non contractif.

Il contient :

```text
poles internes
separations internes
coordinations d'usage
lectures autorisees
sorties de lecture
relations de sortie
regle de transport controlee
```

La chaine devient :

```text
Sep_I(gamma,x,y)
+
Coord_I(gamma,x,y)
->
Use_I(gamma,x,y)
->
transport des lectures autorisees
```

et jamais :

```text
Use_I(gamma,x,y) -> x = y
```

## 2. Definition conceptuelle

Un regime d'interface totalement relaxe sur `X` donne, pour chaque contexte
d'usage :

```text
gamma : Ctx_I
```

une structure de lecture et de coordination.

Separation :

```text
Sep_I(gamma,x,y)
```

signifie :

```text
x et y sont maintenus comme poles separes dans le regime gamma.
```

Coordination :

```text
Coord_I(gamma,x,y)
```

signifie :

```text
x et y sont coordonnes par le regime gamma.
```

Usage :

```text
Use_I(gamma,x,y)
```

signifie :

```text
x et y peuvent etre utilises comme coordonnes pour les lectures autorisees
par gamma.
```

Lectures :

```text
Read_I(gamma)
```

est la classe des lectures autorisees dans le contexte `gamma`.

Pour chaque lecture :

```text
rho : Read_I(gamma)
```

on a une sortie :

```text
Out_I(gamma,rho)
```

et une evaluation :

```text
read_I(gamma,rho,x) : Out_I(gamma,rho)
```

Enfin, chaque sortie possede une relation de compatibilite :

```text
OutRel_I(gamma,rho,a,b)
```

Cette relation n'est pas forcement une egalite.

Elle peut etre :

```text
egalite stricte
equivalence
compatibilite
tolerance
approximation
simulation
indiscernabilite
relation experimentale
relation contextuelle
```

## 3. Regle operatoire centrale

Le regime porte deux passages :

```text
Coord_I(gamma,x,y)
->
Use_I(gamma,x,y)
```

puis :

```text
Use_I(gamma,x,y)
->
forall rho : Read_I(gamma),
  OutRel_I
    gamma
    rho
    (read_I gamma rho x)
    (read_I gamma rho y)
```

Donc :

```text
la coordination d'usage transporte les lectures autorisees.
```

Elle ne transporte rien d'autre.

## 4. Non-contraction

La version non contractive est :

```text
NonContractive_I(gamma,x,y) :=
  Sep_I(gamma,x,y)
  *
  Coord_I(gamma,x,y)
```

Lecture :

```text
x et y sont maintenus separes,
mais coordonnes pour l'usage du regime gamma.
```

Point crucial :

```text
Sep_I(gamma,x,y)
```

n'a pas besoin d'etre defini par :

```text
x != y
```

Dans la version totalement relaxee, la separation est elle-meme une donnee du
regime.

On ne definit donc pas la separation par negation d'egalite.

On dit plus primitivement :

```text
le regime maintient deux poles.
```

## 5. Le vrai critere : l'eliminateur autorise

La difference decisive n'est pas seulement la relation.

La difference decisive est l'eliminateur autorise.

L'egalite logique donne un eliminateur global :

```text
x = y
->
substitution de x par y dans tout contexte
```

Le regime d'interface totalement relaxe ne donne pas cela.

Il donne seulement :

```text
Use_I(gamma,x,y)
->
transport dans les lectures autorisees par gamma
```

Donc :

```text
Use_I n'est pas une egalite affaiblie.
Use_I est une licence locale d'usage.
```

Formule centrale :

```text
Use_I n'a pas l'eliminateur de l'egalite.
Use_I a seulement l'eliminateur des lectures autorisees.
```

## 6. Forme typee abstraite

```text
X : type des poles internes

I : regime d'interface

Ctx_I : type des contextes d'usage

Sep_I :
  Ctx_I -> X -> X -> Type s

Coord_I :
  Ctx_I -> X -> X -> Type k

Use_I :
  Ctx_I -> X -> X -> Type l

Read_I :
  Ctx_I -> Type

Out_I :
  forall gamma : Ctx_I,
  Read_I(gamma) -> Type

read_I :
  forall gamma : Ctx_I,
  forall rho : Read_I(gamma),
  X -> Out_I(gamma,rho)

OutRel_I :
  forall gamma : Ctx_I,
  forall rho : Read_I(gamma),
  Out_I(gamma,rho) -> Out_I(gamma,rho) -> Type m
```

Les quatre lignes `Sep_I`, `Coord_I`, `Use_I` et `OutRel_I` sont volontairement
en `Type`.

Cela permet de conserver les temoins :

```text
modes de separation
modes de coordination
protocoles d'usage
preuves ou instruments de compatibilite en sortie
```

La version en `Prop` est seulement une specialisation plus contractee, dans
laquelle on ne garde que le fait qu'une separation, coordination, usage ou
compatibilite existe.

Lois operatoires portees par le regime :

```text
use_of_coord :
  Coord_I(gamma,x,y)
  ->
  Use_I(gamma,x,y)

transport :
  Use_I(gamma,x,y)
  ->
  forall rho : Read_I(gamma),
    OutRel_I
      gamma
      rho
      (read_I gamma rho x)
      (read_I gamma rho y)
```

Structure non contractive :

```text
NonContractive_I(gamma,x,y) :=
  Sep_I(gamma,x,y)
  *
  Coord_I(gamma,x,y)
```

## 7. Version Lean propre

Cette esquisse est le noyau totalement relaxe.

```lean
universe u c r o s k l m

structure RelaxedInterfaceRegime (X : Type u) where
  Ctx : Type c

  Read :
    Ctx -> Type r

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

structure NonContractiveUse
    {X : Type u}
    (I : RelaxedInterfaceRegime X)
    (gamma : I.Ctx)
    (x y : X) where
  separation :
    I.Sep gamma x y

  coordination :
    I.Coord gamma x y

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
  I.transport (I.use_of_coord h.coordination) rho
```

Ce code ne donne jamais :

```text
x = y
```

Il donne seulement :

```text
I.OutRel gamma rho
  (I.read gamma rho x)
  (I.read gamma rho y)
```

pour une lecture autorisee `rho`.

## 8. Ce qui est absent volontairement

La structure ne contient pas :

```text
collapse :
  I.Use gamma x y -> x = y
```

Elle ne contient pas :

```text
global_subst :
  I.Use gamma x y ->
  forall P : X -> Prop,
    P x -> P y
```

Elle ne contient pas :

```text
all_reads :
  forall L, X -> L
```

Elle ne contient pas :

```text
output_eq :
  I.read gamma rho x = I.read gamma rho y
```

sauf si le regime choisit explicitement :

```text
OutRel := egalite stricte
```

Donc la non-contraction n'est pas seulement une propriete ajoutee.

Elle est inscrite dans la forme meme de l'elimination autorisee.

## 9. Non-trivialite minimale

Un regime totalement relaxe peut devenir vide si ses donnees sont arbitraires.

Cas vide :

```text
Read_I(gamma) est vide.
```

Alors aucun transport n'est teste.

Autre cas vide :

```text
OutRel_I(gamma,rho,a,b) := True
```

Alors toute sortie est compatible avec toute sortie.

Il faut donc ajouter, dans les instances concretes, une contrainte de
non-trivialite adaptee au domaine :

```text
lecture admissible effectivement presente
relation de sortie informativement contrainte
coordination produite par une structure interne
transport lie a un temoin ou a une obstruction
```

La non-trivialite ne doit pas etre imposee de maniere uniforme dans le noyau.

Elle doit etre prouvee dans les instances.

## 10. Diagonalisation totalement relaxee

La diagonalisation relaxee n'est pas :

```text
x != y
and
q(x) = q(y)
```

Elle est :

```text
Sep_I(gamma,x,y)
and
Coord_I(gamma,x,y)
```

avec transport :

```text
Coord_I(gamma,x,y)
->
Use_I(gamma,x,y)
->
transport des lectures autorisees
```

Donc la diagonale relaxee est :

```text
un maintien de deux poles
+
une coordination d'usage
+
un eliminateur local limite aux lectures autorisees.
```

## 11. Lecture finale

La version totalement relaxee dit :

```text
deux poles peuvent etre maintenus separes
et pourtant coordonnes par un regime d'usage.
```

Cette coordination n'est pas une egalite.

Elle est une source controlee de transports.

Ces transports ne valent que pour les lectures autorisees.

Les sorties ne doivent pas etre egales.

Elles doivent seulement satisfaire la relation de sortie du regime.

Formule courte :

```text
Separation des poles.
Coordination d'usage.
Transport local.
Aucun collapse.
```

Formule centrale :

```text
Le regime totalement relaxe ne definit pas ce qui est egal.

Il definit ce qui peut etre lu comme compatible
sans cesser d'etre maintenu comme separe.
```

Formule finale :

```text
Meme coordination.
Seulement transport autorise.
Aucun collapse.
```

## Annexe A. Specialisation contractive : cas strict projectif

Cette annexe ne fait pas partie du noyau totalement relaxe.

Elle sert seulement a montrer comment une forme plus contractee peut etre
recuperee comme specialisation.

Le cas strict projectif ajoute :

```text
V : Type
q : X -> V

Read gamma := Sigma (fun L : Type v => V -> L)
Out gamma rho := rho.1
read gamma rho x := rho.2(q(x))
OutRel := egalite stricte
```

La lecture identite est alors disponible comme :

```text
rho_id := (V, id_V)
```

Si, dans cette specialisation, `Use` est defini comme le transport total sur
toutes ces lectures, alors :

```text
Use_I(gamma,x,y)
->
q(x) = q(y)
```

par la lecture `rho_id`.

Et inversement :

```text
q(x) = q(y)
->
Use_I(gamma,x,y)
```

par transport de l'egalite dans toute lecture.

Donc, pour cette specialisation contractive :

```text
Use_I(gamma,x,y) <-> q(x) = q(y)
```

Ce n'est pas le modele general. C'est une contraction du regime totalement
relaxe.

## Annexe B. Specialisation plus contractive : cas classique

Le cas classique est encore plus contracte.

Il correspond au regime ou l'usage recupere l'identite interne :

```text
Id_use := Id_X
```

Dans ce cas, le regime autorise la substitution globale.

Le cadre totalement relaxe ne suppose pas cela.
