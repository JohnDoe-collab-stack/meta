# Système dynamique bilatéral

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

La dynamique exploite cette coordination sans transformer l'égalité visible en
égalité interne.
