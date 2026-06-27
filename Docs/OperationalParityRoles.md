# Roles operationnels de la parite

## Statut

Ce document fixe le vocabulaire de la couche
`Meta/Core/OperationalParityRoles.lean`. Il ne modifie pas la parite
separatrice minimale deja formalisee, et il ne remplace pas le raccord
dynamique transversal deja present dans
`Meta/Core/DynamicParitySeparation.lean`.

Son role est d'expliciter l'orientation operationnelle des deux poles :

```text
role de fermeture locale
role de mediation active
```

Ces roles ne remplacent pas les constructeurs `ParityRegime.left` et
`ParityRegime.right`. Ils sont portes par une orientation explicite au-dessus
du raccord dynamique.

## Point de depart

La parite separatrice minimale est maintenant formalisee comme structure a deux
poles :

```text
ParityRegime.left
ParityRegime.right
```

Le raccord dynamique transversal est aussi formalise :

```text
DynamicParitySeparation
```

Il permet a une dynamique localement recuperee de porter une lecture
separatrice :

```text
Interface -> ParityRegime
Visible   -> ParityVisible
```

Ce qui est ajoute n'est pas l'existence de la separation. Elle existe deja.
Ce qui est explicite est son orientation operationnelle.

## Probleme

La lecture arithmetique classique dit :

```text
classe paire et classe impaire
```

comme deux classes numeriques.

Notre cadre ne doit pas simplement recopier cette lecture. Il doit expliquer ce
que ces deux poles font.

Le risque serait de coder trop vite une identification directe entre les deux
constructeurs neutres `left` / `right` et les deux roles `pair` / `impair`.
Une telle identification serait trop pauvre : elle donnerait seulement des noms
aux constructeurs, sans exhiber le role profond de la separation.

## Lecture operationnelle

Dans le cadre, la parite doit etre lue comme :

```text
separation minimale de regimes
```

et non comme :

```text
classification numerique
```

Les roles attendus sont :

```text
role pair   = fermeture / recuperation / stabilisation locale
role impair = mediation / gap actif / transformation de regime
```

Ces roles ne doivent pas etre definis par une operation arithmetique externe.
Ils doivent etre definis par leur place dans la structure :

```text
meme visible
separation conservee
reparation locale du pole forme
impossibilite de reconstruction globale par le visible seul
```

## Role pair

Le role pair n'est pas seulement une classe de nombres.

Dans cette lecture, il designe le pole ou la dynamique peut etre relue comme
fermeture ou recuperation locale.

Il est associe a :

```text
pole forme
reparation locale
recuperation
meme visible de parite
```

Ce role correspond au cote ou le cadre peut dire :

```text
la structure revient localement a elle-meme
```

Il ne s'agit pas d'une fermeture globale sans gap. La fermeture reste locale et
portee par le cadre.

## Role impair

Le role impair n'est pas seulement le complement arithmetique du pair.

Dans cette lecture, il designe le pole ou la separation reste active.

Il est associe a :

```text
pole shadow
gap actif
mediation
transformation de regime
non-reconstruction par le visible seul
```

Le role impair est donc le temoin positif que la parite n'est pas une simple
egalite visible. Il porte le fait que deux regimes peuvent partager une meme
projection tout en restant separes.

Ce role correspond au cote ou le cadre peut dire :

```text
la dynamique ne se reduit pas a sa projection visible
```

## Orientation

La structure abstraite garde les noms neutres :

```text
left
right
```

L'orientation operationnelle doit etre ajoutee comme donnee positive.

Il ne faut donc pas imposer dans le Core une lecture fixe des constructeurs
neutres comme roles operationnels.

Il faut plutot definir une orientation du type :

```text
closingRegime   : ParityRegime
mediatingRegime : ParityRegime
```

avec :

```text
closingRegime   = role pair
mediatingRegime = role impair
```

Cette orientation peut ensuite etre raccordee a une dynamique concrete.

## Lien avec `DynamicParitySeparation`

Un `DynamicParitySeparation` donne deja les projections formelles suivantes :

```text
dynamicParitySeparation_dynamicOperationalTwoPole
dynamicParitySeparation_parityOperationalTwoPole
dynamicParitySeparation_formedRegime
dynamicParitySeparation_shadowRegime
dynamicParitySeparation_formedVisible
dynamicParitySeparation_shadowVisible
dynamicParitySeparation_sameParityVisible
dynamicParitySeparation_separatedParityRegimes
```

La couche `OperationalParityRoles` extrait :

```text
closingRegime   = regimeOf formed
mediatingRegime = regimeOf shadow
```

Cette extraction ne doit pas etre inversee par simple changement
d'orientation. Le pole de fermeture reste le pole forme de la dynamique,
parce que c'est lui qui porte la reparation locale. L'orientation choisit
seulement quel constructeur de `ParityRegime` joue ce role.

Le point essentiel est que l'impair ne doit pas etre ajoute comme etiquette.
Il doit etre reconnu comme le role du pole mediant.

La correspondance doit donc rester orientee :

```text
orientation left/right :
closingRegime   = dynamicParitySeparation_formedRegime
mediatingRegime = dynamicParitySeparation_shadowRegime

orientation right/left :
closingRegime   = dynamicParitySeparation_formedRegime
mediatingRegime = dynamicParitySeparation_shadowRegime
```

Dans la premiere orientation, le role de fermeture est lu comme
`ParityRegime.left`. Dans la seconde, il est lu comme `ParityRegime.right`.
Le statut dynamique des roles, lui, ne change pas.

## Formalisation retenue

La structure formelle est :

```text
OperationalParityRoles
```

Elle porte :

```text
closingRegime
mediatingRegime
sameVisible
separated
dynamicRepair
noVisibleReconstruction
```

`dynamicRepair` designe la reparation locale portee par le two-pole dynamique.
La reparation minimale portee par `ParityRegimeRepair` reste le temoin du cote
de la parite separatrice, mais elle ne remplace pas la reparation dynamique.

Dans un raccord dynamique, elle est liee a :

```text
DynamicParitySeparation
```

par :

```text
closingRegime   = dynamic formed regime
mediatingRegime = dynamic shadow regime
```

L'orientation opposee change seulement la lecture de ces roles dans
`ParityRegime`; elle ne change pas quel cote dynamique est closing ou
mediating.

## Verification formelle

La structure `OperationalParityRoles` est construite a partir d'un
`DynamicParitySeparation` avec :

```text
closingRegime   = dynamicParitySeparation_formedRegime
mediatingRegime = dynamicParitySeparation_shadowRegime
sameVisible     = dynamicParitySeparation_sameParityVisible
separated       = dynamicParitySeparation_separatedParityRegimes
dynamicRepair   = operationalTwoPole_repair
                    dynamicParitySeparation_dynamicOperationalTwoPole
```

Commande executee :

```bash
lake env lean Meta/Core/OperationalParityRoles.lean
```

Resultat :

```text
compilation reussie sans axiome pour les declarations auditees
```

## Non-objectifs

Ne pas introduire ici :

```text
Nat
division
arithmetique externe de la parite
calcul de classes
decidabilite globale
```

Ne pas reduire le role impair au simple complement negatif du role pair.

Le role impair doit etre positif :

```text
impair = mediation active du gap
```

Ne pas reduire le role pair a un pole vide ou purement negatif.

Le role pair doit rester local :

```text
pair = fermeture / recuperation portee par le cadre
```

## Resultat conceptuel

La parite n'est alors plus seulement :

```text
deux classes numeriques
```

Elle devient :

```text
une interface operationnelle a deux roles
```

avec :

```text
pair   = role de fermeture locale
impair = role de mediation active
```

Ce deplacement est le point important. Il donne a la parite un statut
structurel que la lecture arithmetique classique ne rend pas explicite.
