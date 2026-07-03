# Egalite d'interface comme chaine constructive

## Objet

Ce document precise ce qui est encode lorsque le cadre remplace l'egalite
interne par une identite d'usage produite par une interface.

Le point n'est pas seulement :

```text
q n'est pas injective
```

ni seulement :

```text
x =_q y  :=  q(x) = q(y)
```

Le point est plus fort :

```text
une egalite projective devient une identite d'usage
dans une chaine qui conserve la separation interne des poles.
```

## Idee a ne pas perdre

Le cadre ne nie pas l'egalite.

Il deplace le lieu ou l'egalite agit.

Dans la lecture contractee, on voudrait utiliser :

```text
x = y
```

Dans la lecture longue, on utilise :

```text
q(x) = q(y)
```

comme identite operative entre deux poles qui restent separes :

```text
x != y
```

Donc l'egalite n'est pas placee entre les poles internes.

Elle est placee dans l'interface, puis elle agit sur tout ce qui passe par cette
interface.

Formule directrice :

```text
le cadre ne contracte pas les poles ;
il fait travailler l'egalite au niveau du mediateur.
```

## Statique et dynamique

La cellule minimale peut s'ecrire de facon statique :

```text
x != y
q(x) = q(y)
```

Mais cette ecriture ne donne pas encore le coeur du cadre.

Le coeur est dynamique au sens structurel : l'egalite d'interface agit dans une
chaine.

Elle ne reste pas seulement une propriete constatee.

Elle devient :

```text
Id_use(x, y)
```

puis elle autorise des transports :

```text
r(q(x)) = r(q(y))
```

pour les lectures qui factorisent par l'interface.

La difference est donc :

```text
forme statique :
  x != y
  q(x) = q(y)

forme dynamique :
  q(x) = q(y)
  -> Id_use(x, y)
  -> transport par lecture
  -> coordination de la chaine longue
```

Si l'on garde seulement la forme statique, on retombe dans la lecture pauvre :

```text
q n'est pas injective
```

La lecture dynamique dit au contraire :

```text
l'egalite visible devient une operation de coordination.
```

## Signe egal dynamique et changement de regime

Le signe egal dynamique n'est pas un nouveau signe qui prouverait :

```text
x = y
```

Il est le signe egal projectif considere dans son action de changement de
regime.

Il encode le passage entre deux regimes d'identite :

```text
regime interne :
  Id_X(x, y) := (x = y)

regime d'interface :
  Id_q(x, y) := (q(x) = q(y))
```

La cellule diagonale porte :

```text
not Id_X(x, y)
Id_q(x, y)
```

Le deplacement consiste a faire de `Id_q` l'identite utilisee :

```text
Id_use := Id_q
```

Donc le signe egal dynamique encode la variation de statut suivante :

```text
dans le regime interne :
  x et y restent separes

dans le regime d'interface :
  x et y sont traites comme une meme identite d'usage
```

Forme compacte :

```text
not Id_X(x, y)
and
Id_use(x, y)
```

avec :

```text
Id_use := Id_q.
```

La variation ne porte donc pas sur les poles eux-memes.

Elle porte sur le regime d'identite par lequel la chaine les relie.

Le signe egal dynamique est ce qui rend cette variation operatoire :

```text
Id_X refuse la contraction interne ;
Id_q fournit la coordination projective ;
Id_use active cette coordination dans la chaine.
```

## Donnees minimales

On fixe :

```text
X
q : X -> V
```

avec deux poles internes :

```text
x, y : X
```

La cellule porte simultanement :

```text
x != y
q(x) = q(y)
```

Pris seul, ce fait peut seulement dire que l'interface confond deux poles.
Dans le cadre, il devient plus precis parce qu'il est utilise comme identite
d'usage.

## Trois niveaux d'identite

### Identite interne

L'identite interne est :

```text
Id_X(x, y) := (x = y)
```

Elle identifie les poles dans `X`.

La cellule diagonale porte au contraire :

```text
not Id_X(x, y)
```

Donc la contraction interne :

```text
x = y
```

est exclue.

### Identite projective

L'identite projective est :

```text
Id_q(x, y) := (q(x) = q(y))
```

Elle ne dit pas que `x` et `y` sont identiques dans `X`.

Elle dit que les deux poles ont la meme image par l'interface.

### Identite d'usage

Le deplacement central est :

```text
Id_use := Id_q
```

Le systeme n'utilise pas :

```text
Id_X
```

comme identite operative de la cellule.

Il utilise :

```text
Id_q
```

Donc la forme exacte est :

```text
not Id_X(x, y)
and
Id_use(x, y)
```

avec :

```text
Id_use(x, y) := q(x) = q(y)
```

Il n'y a pas contradiction : l'identite interne est refusee, l'identite
projective est utilisee.

## Chaine longue

La presentation courte voudrait contracter :

```text
x = y
```

La presentation longue conserve :

```text
x  --q-->  q(x) = q(y)  <--q--  y
```

Le signe egal actif est donc :

```text
q(x) = q(y)
```

et non :

```text
x = y
```

La chaine complete garde ensemble :

```text
pole gauche       : x
mediateur visible : q(x) = q(y)
pole droit        : y
separation        : x != y
identite d'usage  : Id_use := Id_q
```

Dans la notation du cadre :

```text
1 + gap + 1
```

les deux `1` sont les deux poles internes, et le `gap` est organise par
l'egalite projective utilisee comme mediateur.

## Le second signe egal

L'egalite projective n'autorise pas la substitution interne :

```text
x = y
```

Elle autorise un transport seulement dans les contextes qui passent par
l'interface.

C'est en ce sens precis qu'elle impose un autre signe egal.

Elle n'impose pas :

```text
x = y
```

Elle impose des egalites derivees dans les lectures admissibles.

Pour toute lecture :

```text
r : V -> L
```

la preuve :

```text
q(x) = q(y)
```

produit :

```text
r(q(x)) = r(q(y))
```

Le second signe egal n'est donc pas une egalite interne entre `x` et `y`.

Il est une egalite de lecture imposee par l'egalite projective :

```text
Id_use(x, y)
-------------------------
r(q(x)) = r(q(y))
```

La chaine constructive devient :

```text
x
--q-->
q(x) = q(y)
--r-->
r(q(x)) = r(q(y))
<--r--
q(y)
<--q--
y
```

avec toujours :

```text
x != y
```

## Interdependance

Le mot `interdependance` doit etre lu de facon precise.

Il ne signifie pas une relation vague entre `x` et `y`.

Il signifie :

```text
les poles restent separes dans X,
mais toute operation qui passe par l'interface doit respecter leur identite
d'usage commune.
```

Autrement dit :

```text
X separe les poles.
q les co-indexe.
Id_use utilise cette co-indexation.
Les lectures factorisees par q transportent cette identite.
```

Donc l'interdependance est :

```text
separation interne
+
co-indexation projective
+
transport par lecture
```

Elle ne remplace pas la difference interne par une identite interne.

Elle transforme l'egalite visible en regle de coordination pour les lectures
admissibles.

## Ce qui est encode dans Lean

Dans `Meta/Core/ProjectedIdentity.lean`, la structure :

```lean
ProjectedIdentityCell Interface Visible project
```

porte :

```lean
formed
shadow
sameVisible : project formed = project shadow
separated   : formed = shadow -> False
```

Elle encode :

```text
not Id_X(formed, shadow)
and
Id_q(formed, shadow)
```

La structure :

```lean
IdentityOfUseCell Interface Visible project
```

renomme l'egalite projective comme identite utilisee :

```lean
usedIdentity : InterfaceIdentityOfUse project formed shadow
```

avec :

```lean
InterfaceIdentityOfUse project formed shadow
  := project formed = project shadow
```

Le theoreme :

```lean
projectedIdentityCell_internalDifference_usedIdentity
```

donne :

```lean
(InternalIdentity project formed shadow -> False)
and
InterfaceIdentityOfUse project formed shadow
```

Il formalise donc :

```text
difference interne
+
identite d'usage projective
```

Enfin :

```lean
readIdentityCellOfProjectedIdentityCell
```

encode le transport par lecture :

```text
project formed = project shadow
--------------------------------
read(project formed) = read(project shadow)
```

C'est la formalisation du second signe egal : l'egalite visible produit une
egalite lue, mais seulement dans un contexte qui factorise par l'interface.

## Ce que ce n'est pas

Le cadre ne dit pas :

```text
x = y
```

Il ne dit pas :

```text
la difference interne disparait
```

Il ne dit pas seulement :

```text
q est non injective
```

Il dit :

```text
x != y
mais
Id_use(x, y)
```

avec :

```text
Id_use := Id_q
```

## Formule stabilisee

```text
Une egalite d'interface devient constructive lorsqu'elle est utilisee comme
identite d'usage entre deux poles que la structure interne continue de separer.
```

Cette formule signifie :

```text
l'egalite visible n'est pas un effacement ;
elle est un mediateur operatoire.
```

Elle conserve simultanement :

```text
la difference interne
et
la coordination projective.
```

Forme longue :

```text
Le cadre ne contracte pas x et y.
Il remplace l'identite operative :

Id_X

par :

Id_q

et conserve la preuve que ces deux regimes d'identite ne coincident pas sur la
cellule diagonale.
```

Forme courte :

```text
x != y
mais
Id_use(x, y)

avec

Id_use := Id_q.
```

## Point eventuel a formaliser plus tard

Le noyau est deja code par :

```text
ProjectedIdentityCell
IdentityOfUseCell
ReadIdentityCell
readIdentityCellOfProjectedIdentityCell
```

Si l'on veut rendre la lecture encore plus explicite, on peut ajouter une
facade nommee du type :

```lean
projectedIdentityCell_readTransport
```

qui exposerait directement :

```text
project formed = project shadow
-> read(project formed) = read(project shadow)
```

Mais le contenu est deja present via `readIdentityCellOfProjectedIdentityCell`.
