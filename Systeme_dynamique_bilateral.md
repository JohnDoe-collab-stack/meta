# Système dynamique bilatéral

## Principe fondationnel

L'identité conserve sa souveraineté sur la coïncidence interne. Elle ne possède
plus le monopole de la coordination, de la substitution et du transport.

```text
InternalIdentityTransport
⊆
ProjectedIdentityTransport
⊊
RelaxedUsageTransport
```

Le gap projectif est une réalisation de cette relaxation, non son principe
fondateur. Le résultat décisif est qu'un usage peut être cohérent, composable,
directionnel et opératoire sans être engendré par une identité.

## Statut formel

Le résultat de stricte relaxation est formalisé dans
`Meta/Core/StrictRelaxation.lean` et compilé constructivement.

Son énoncé exact porte sur la relation propositionnelle :

```text
HasUse I γ x y := Nonempty (I.Use γ x y)
```

Il ne compare pas absolument deux formalismes. Il établit que les relations
d'usage exactement représentables par une égalité projetée forment une
sous-classe stricte des relations d'usage admises par le régime relaxé :

```text
ProjectedIdentityTransport ⊊ RelaxedUsageTransport
```

## Régime relaxé primitif

`RelaxedInterfaceRegime` sépare trois données qui ne doivent pas être
identifiées :

```text
Sep γ x y    : individuation interne
Coord γ x y  : coordination autorisée
Use γ x y    : transport disponible
```

La chaîne intrinsèque est :

```text
Sep + Coord → Use → transport
```

`CompositionalUse` ajoute des témoins d'identité et de composition directement
au niveau preuve-pertinent de `Use`.

## Instance projective exacte

Une `ExactProjectiveRepresentation I` fournit, pour chaque contexte `γ`, un
type visible et une projection tels que :

```text
HasUse I γ x y ↔ project γ x = project γ y
```

Cette équivalence exacte exclut les pseudo-représentations qui ne donneraient
qu'une implication vers une projection constante.

L'égalité projetée force alors :

```text
réflexivité de HasUse
symétrie de HasUse
transitivité de HasUse
```

Toute projection `project : X → Visible` induit canoniquement un régime relaxé
exactement projectif. L'identité interne est le cas particulier :

```text
Visible := X
project := id
```

L'identité projetée et l'identité interne sont donc incluses dans le transport
relaxé.

## Témoin strict et non trivial

Le contre-modèle utilise deux phases distinctes :

```text
before
after
```

et un type de témoins orientés :

```text
before → before
before → after
after  → after
```

Il n'existe aucun constructeur de :

```text
after → before
```

Le transport `before → after` est construit comme un
`NonContractiveUse` complet : il porte à la fois la séparation des phases, leur
coordination orientée, l'usage qui en résulte et la chaîne de transport locale.
Les compositions :

```text
before → before → after
before → after  → after
```

sont calculées explicitement.

Si ce régime possédait une représentation projective exacte, l'usage avant vers
après donnerait une égalité visible. Sa symétrie produirait alors un usage après
vers avant, en contradiction avec la définition inductive de `PhaseUse`.

La stricte inclusion ne repose donc ni sur un type vide, ni sur une projection
constante, ni sur une hypothèse externe de fermeture.

## Architecture résultante

Les racines indépendantes sont :

```text
RelaxedUsageRegime : usages et transports intrinsèques
BilateralCore      : fermeture, intersection et recomposition
ProjectiveCore     : projection, obstruction et récupération locale
```

Le sens conceptuel et le sens des imports utiles sont ensuite :

```text
RelaxedUsageRegime
        ↓
ProjectedIdentity
        ↓
StrictRelaxation

BilateralCore + ProjectiveCore
        ↓
ClosedStabilityTheorem
        ↓
DynamicCore
        ↓
DynamicRoleCarrier
        ↓
Parity
```

`OrderGap` reste une application en aval du noyau projectif et dynamique.

Le gap projectif n'est donc plus présenté comme le principe fondateur. Il est
une réalisation dérivée dans laquelle :

```text
égalité visible = coordination
séparation formée = non-contraction
```

L'architecture rend possible une synthèse dans laquelle la dynamique exploite
cette coordination sans transformer l'égalité visible en égalité interne.

## Synthèse dynamique formalisée

Le raccord est maintenant implémenté dans :

```text
Meta/Core/DynamicRelaxedUsage.lean
Meta/Core/DynamicRelaxedUsageModel.lean
```

La construction générique suit effectivement :

```text
retour dynamique courant
→ intersection source
→ contexte avec provenance
→ gap formé / ombre
→ séparation + coordination indexée
→ certificat d'usage causal
→ transports formé et visible
→ mémoire bilatérale
→ état causal complet
→ transition interne
→ nouveau gap et nouveau droit de transport
```

`Coord` et `Use` sont deux types distincts. Le constructeur non réflexif de
`Use` conserve littéralement la séparation et la coordination qui l'ont
produit. L'état causal consommé par la transition conserve simultanément :

```text
le cycle fort issu de l'intersection ;
l'égalité entre cette intersection et celle du retour ;
la non-contraction ;
l'usage courant ;
le transport formé ;
le transport visible.
```

La fonction `next` n'est pas une donnée indépendante. Elle est définie par
l'application de `advance` à la somme dépendante contenant la source et son
état causal canonique.

## Instance non triviale

Le modèle fini `DynamicRelaxedUsageModel` possède :

```text
deux états alternants ;
trois interfaces ;
deux visibles ;
une projection globalement non constante ;
une fibre visible contenant deux pôles séparés ;
quatre familles bilatérales typées distinctes ;
des témoins d'interface portant leur source ;
des réparations indexées avec une opération `apply` ;
une transition qui inspecte l'usage de l'état causal ;
une inversion effective de l'usage au pas suivant.
```

Dans l'état `leftToRight` :

```text
leftPole → rightPole
¬(rightPole → leftPole)
```

Dans l'état `rightToLeft` :

```text
rightPole → leftPole
¬(leftPole → rightPole)
```

Les deux pôles ont toujours le même visible, mais un troisième objet `marker`
possède un visible distinct. La contraction locale n'est donc pas dissimulée
dans une projection constante.

La récupération n'est pas juxtaposée à un jeton de réparation :

```text
localRecovery.recovered
=
localRecovery.repair.apply
```

et `apply_correct` fournit ensuite l'égalité avec le pôle formé.

## Résultat de stricte synthèse

Le régime dynamique générique n'admet aucune représentation projective
exacte. Un tel représentant transformerait l'usage courant en égalité visible,
puis sa symétrie produirait l'usage inverse que le gap réfute.

Le paquet fermé :

```text
switchDynamicRelaxationSynthesis
```

ne reçoit aucun argument et conserve la famille de retours, la transition, la
variation, l'étape initiale, les deux usages orientés, les réparations, la
non-constance de la projection et la non-réductibilité projective.

Le statut exact devient :

```text
relaxation non identitaire : démontrée
dynamique bilatérale       : démontrée
synthèse dynamique         : démontrée
instance non triviale       : construite
audits constructifs         : validés
```
