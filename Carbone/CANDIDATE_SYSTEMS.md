# Audit des systèmes carbonés candidats

## Statut

**Décision de travail — 18 juillet 2026.** Ce document choisit un premier
objet de formalisation ; il ne déclare ni percée, ni réalisation expérimentale
du Core, ni calculabilité générale du carbone.

La décision est volontairement dissociée :

```text
référence formelle initiale : autocatalyse asymétrique de Soai ;
cible évolutive de niveau D : gouttelettes de formose ;
alternative moléculaire évolutive : réplicateurs combinatoires dynamiques ;
smoke-test cinétique : réseau autocatalytique réversible de bases de Schiff.
```

Il n'existe donc pas encore de « gagnant universel ». Chaque système répond à
une partie différente de la chaîne recherchée.

## 1. Question de sélection

Le premier système doit permettre de construire, sans trajectoire cachée ni
successeur fourni de l'extérieur, un témoin de la forme :

```text
deux organisations carbonées distinctes
→ une même observation selon un protocole fixé
→ des réponses futures causalement différentes
→ une transition calculée depuis la réponse physique.
```

La cible ultérieure ajoute :

```text
persistance → reproduction → variation héritable
→ reproduction différentielle → sélection.
```

L'audit repose uniquement sur des articles expérimentaux primaires pour les
faits chimiques. Les scores et la décision sont des jugements du projet, pas
des mesures publiées.

## 2. Portes obligatoires

Un candidat ne peut devenir une instance du Core que s'il franchit les portes
suivantes.

| Porte | Question décisive |
|---|---|
| G1 — État | Peut-on encoder l'état complet utilisé par le modèle ? |
| G2 — Visible | Le protocole de projection est-il explicite et non constant ? |
| G3 — Collision | Peut-on exhiber deux états distincts de même visible ? |
| G4 — Futur | Ces deux états ont-ils des futurs différents sous la même intervention ? |
| G5 — Endogénéité | La transition vient-elle de la cinétique et de la réponse, sans table-cible ? |
| G6 — Invariants | Atomes, charge, stœchiométrie et conditions sont-ils auditables ? |
| G7 — Intervention | Peut-on perturber un maillon en conservant son amont ? |
| G8 — Données | Les traces, conditions, erreurs et provenance sont-elles accessibles ? |
| G9 — Mémoire | Une organisation produite persiste-t-elle matériellement ? |
| G10 — Évolution | Existe-t-il reproduction, hérédité et succès différentiel ? |

G1–G8 sont requises pour une référence carbonée de niveau A ou B. G9 et G10
sont requises pour la revendication évolutive forte.

## 3. Lecture comparative

Échelle : `0` absent, `1` faible, `2` partiel, `3` fort. « Maniabilité » note
la facilité relative d'une première instance bornée ; ce n'est pas une note de
valeur scientifique. Aucun total n'est calculé, car additionner
« formalisable » et « évolutif » masquerait précisément le choix à faire.

| Candidat | Collision projective | Futur causal | Données | Maniabilité | Mémoire | Évolution | Rôle retenu |
|---|---:|---:|---:|---:|---:|---:|---|
| Autocatalyse asymétrique de Soai | 3 | 3 | 3 | 2 | 2 | 0 | Référence 0 |
| Gouttelettes de formose | 2 | 3 | 2 | 1 | 2 | 3 | Cible niveau D |
| Réplicateurs combinatoires dynamiques | 2 | 3 | 3 | 1 | 3 | 3 | Alternative évolutive |
| Hydrolyse autocatalytique de bases de Schiff | 2 | 2 | 2 | 3 | 1 | 0 | Smoke-test |

Le score élevé de Soai pour la collision projective dépend d'un protocole
**achiral** délibérément fixé. Une mesure chirale distinguerait les deux états.
Cette dépendance au protocole est une propriété annoncée de `project`, pas une
indiscernabilité absolue de la matière.

## 4. Candidat S — Autocatalyse asymétrique de Soai

### 4.1 Faits établis utilisables

Les réactions étudiées alkylent des pyrimidine- ou pyridine-carbaldéhydes par
le diisopropylzinc. L'alcool chiral produit facilite sa propre production. Des
travaux expérimentaux rapportent amplification énantiomérique, profils
cinétiques sigmoïdes, suivi par HPLC chirale et analyse mécanistique par
spectrométrie de masse. Une étude récente propose un cycle passant par des
intermédiaires zinc-hémiacétal et calibre un réseau cinétique contre les
traces expérimentales.

Le point formel exploitable est net : deux mélanges de même quantité totale
d'alcool, mais d'excès énantiomériques opposés, peuvent partager une mesure
achirale et répondre différemment à un même apport de réactifs.

### 4.2 Projection vers le Core

```text
Source      = composition, conditions, temps et provenance ;
Interface   = état réactionnel enrichi par R/S et intermédiaires ;
Visible     = quantité totale d'alcool + conditions, sans lecture chirale ;
formed      = mélange enrichi en R ;
shadow      = mélange enrichi en S de même visible ;
Query       = apport commun de substrat et mesure après Δt ;
Response    = profil chiral observé ;
Repair      = transformation de composition induite par l'autocatalyse ;
history     = produit chiral catalytiquement actif restant dans le milieu.
```

### 4.3 Forces

- collision projective simple à énoncer et falsifier ;
- séparation future directement reliée à une variable moléculaire ;
- interventions naturelles sur l'excès énantiomérique initial, les
  concentrations et le temps ;
- traces expérimentales publiées et mécanisme quantitatif en développement ;
- domaine suffisamment bornable pour une première machine finie.

### 4.4 Limites critiques

- Le système chimique ne « détecte » pas nécessairement lui-même
  l'indétermination créée par notre mesure achirale. À ce stade, la détection
  du gap appartient au dispositif épistémique ou au contrôleur.
- Le mécanisme actif reste un objet de recherche ; un modèle discret ne doit
  pas être présenté comme le mécanisme chimique complet.
- L'autocatalyse et l'amplification ne fournissent pas, seules, une population
  de descendants ni une hérédité entre compartiments.
- La chimie anhydre à l'organozinc et les mesures chirales imposent une charge
  expérimentale importante.

### 4.5 Verdict

**GO provisoire pour la Référence 0 formelle et l'extraction de données.**

**NO-GO pour une revendication d'évolution carbonée.** Le système ne franchit
pas G10 et ne franchit G5 au sens incarné qu'après démonstration que chaque
maillon `gap → réponse → réparation` correspond à une causalité physique, et
non au seul protocole de l'observateur.

## 5. Candidat F — Gouttelettes de formose

### 5.1 Faits établis utilisables

Une réaction de formose autocatalytique réalisée dans des gouttelettes
aqueuses peut provoquer leur croissance par couplage de la réaction, des
échanges de réactifs et du flux de solvant. Les volumes rapportés peuvent plus
que doubler. La compétition pour le formaldéhyde commun produit des différences
de vitesse de croissance liées à la composition des gouttelettes. Après
division sélective des plus grandes gouttelettes par cisaillement, une partie
de cette variation est transmise et convertie en différences de fréquence.

### 5.2 Projection vers le Core

```text
State       = population de gouttelettes + compositions + milieu partagé ;
Visible     = taille, croissance ou lecture compositionnelle grossière ;
gap         = compositions compatibles de même taille mais de potentiels distincts ;
Query       = exposition à une ressource commune ou changement de milieu ;
Response    = flux, réaction, croissance et compétition ;
Repair      = modification compositionnelle persistante ;
history     = composition retenue après croissance et division ;
Selection   = variation de fréquence après cycles de sélection/division.
```

### 5.3 Forces

- système de petites molécules carbonées compartimenté ;
- lien expérimental entre autocatalyse interne et croissance du compartiment ;
- ressources partagées, variation entre unités, division et changement de
  fréquence ;
- meilleur candidat actuel à la cible populationnelle du niveau D.

### 5.4 Limites critiques

- la réaction produit un mélange complexe dont l'état complet est difficile à
  reconstruire ;
- la transmission rapportée est partielle ;
- la division est imposée par cisaillement et la sélection des plus grandes
  gouttelettes est un acte expérimental externe ;
- la proximité entre composition, caractère héritable et causalité de la
  croissance doit être établie par interventions appariées ;
- la complexité empêche d'en faire le premier noyau Lean sans abstraction
  excessive.

### 5.5 Verdict

**GO comme cible de niveau D et comme test de conception de la couche
populationnelle.**

**NO-GO comme Référence 0.** Avant une formalisation forte, il faut un schéma
de données par gouttelette, une définition de filiation, un bilan de matière
et un test causal du composant transmis. La division externe doit rester
explicitement typée comme intervention externe.

## 6. Candidat R — Réplicateurs combinatoires dynamiques

### 6.1 Faits établis utilisables

Dans des bibliothèques combinatoires dynamiques de macrocycles disulfure, des
macrocycles auto-réplicateurs peuvent émerger, s'assembler en fibres et être
amplifiés par fragmentation sous agitation. Des expériences ont suivi en temps
réel la diversification de familles de réplicateurs utilisant des ressources
différentes. Des systèmes plus récents montrent trois quasi-espèces issues de
deux ressources : le recouvrement des niches conduit à l'exclusion, tandis que
le partitionnement des ressources permet une coexistence stable.

### 6.2 Forces

- réplication moléculaire, compétition et écologie de ressources directement
  observables ;
- identité de lignées plus nette que dans un mélange de formose ;
- perturbations par graines, ressources, agitation et alimentation ;
- données temporelles et matériaux supplémentaires publiés.

### 6.3 Limites critiques

- synthèse, assemblage supramoléculaire et fragmentation forment un état
  multi-échelle difficile à fermer ;
- l'agitation ou le cisaillement joue un rôle causal dans la réplication ;
- les temps d'expérience peuvent atteindre plusieurs semaines ;
- une projection grossière risque de confondre nombre de fibres, longueur,
  composition et activité ;
- la première instance finie exigerait une réduction dont la fidélité doit
  être testée, non supposée.

### 6.4 Verdict

**GO comme alternative de niveau C/D**, particulièrement si la filiation et
la compétition doivent être plus explicites que dans la formose.

**NO-GO comme Référence 0**, faute d'un état minimal déjà justifié et
exhaustivement mesurable.

## 7. Candidat B — Réseau autocatalytique réversible de bases de Schiff

### 7.1 Faits établis utilisables

Un réseau associant équilibres acide-base et hydrolyse de certaines bases de
Schiff crée une rétroaction positive sur la concentration d'ions hydroxyde.
Dans un système ouvert, le modèle et les expériences associées permettent une
bistabilité dans une plage de pH proche des conditions physiologiques.

### 7.2 Forces et limites

Ce système offre une cinétique plus petite, un visible pH naturel, des bassins
de réponse distincts et un bon terrain de test pour `State`, `project`,
`Response` et `executeRepair`. En revanche, sa bistabilité ne réalise ni
réplication, ni transmission, ni sélection. Un pH commun peut aussi cacher des
compositions différentes, mais la collision précise doit être extraite des
données plutôt que postulée.

### 7.3 Verdict

**GO comme smoke-test cinétique indépendant.** Il doit servir à éprouver le
schéma de traces et le vérificateur, pas à porter la revendication phare.

## 8. Décision d'architecture

La stratégie retenue est un emboîtement, non une substitution :

```text
Référence 0 — Soai
    prouve ou réfute la collision projective et le futur différentiel ;

Smoke-test — bases de Schiff
    éprouve le pipeline cinétique sur un réseau plus petit ;

Cible D — formose compartimentée
    ajoute population, croissance, division, transmission et sélection ;

Alternative D — réplicateurs combinatoires
    fournit une voie de repli si la filiation dans la formose reste ambiguë.
```

Cette décision évite de faire porter à un seul système, dès le départ, la
preuve formelle, la reconstruction cinétique, l'incarnation du gap et toute
l'évolution chimique.

## 9. Portes immédiates GO/NO-GO

Avant tout fichier Lean ou toute expérience nouvelle, `CARBON_REFERENCE_0`
doit fournir :

1. un protocole de projection achirale exactement spécifié ;
2. deux états numériques R/S distincts ayant exactement le même visible ;
3. une intervention commune documentée ;
4. des traces publiées montrant des futurs chiraux séparés avec incertitudes ;
5. une loi de transition ou une relation bornée dérivée des données, jamais
   une table de réponses attendues dissimulée dans `next` ;
6. les bilans atomiques et les conditions de validité ;
7. un test où le vérificateur ignore la classe ou la cible attendue ;
8. un registre de provenance pour chaque valeur extraite.

Si les points 2–5 ne peuvent pas être satisfaits avec les données accessibles,
le choix Soai est révoqué au profit du smoke-test B pour le niveau A. Cela
n'affecte pas le choix F comme cible de niveau D.

## 10. Sources primaires

### Autocatalyse asymétrique

- [Mechanistic analysis and kinetic profiling of Soai’s asymmetric
  autocatalysis for pyridyl and pyrimidyl substrates, *Nature Communications*
  (2025)](https://www.nature.com/articles/s41467-025-62591-3)
- [Asymmetric autocatalysis and amplification of enantiomeric excess of a
  chiral molecule, *Nature* (1995)](https://www.nature.com/articles/378767a0)
- [Energy threshold for chiral symmetry breaking in molecular
  self-replication, *Nature Chemistry*
  (2019)](https://www.nature.com/articles/s41557-019-0321-y)

### Formose compartimentée

- [Autocatalytic growth of compartmentalized chemical reaction networks,
  *Nature Chemistry*
  (2023)](https://www.nature.com/articles/s41557-023-01276-0)

### Réplicateurs combinatoires dynamiques

- [Diversification of self-replicating molecules, *Nature Chemistry*
  (2016)](https://www.nature.com/articles/nchem.2419)
- [Spontaneous emergence of self-replicating molecules containing
  nucleobases and amino acids, *Nature Communications*
  (2015)](https://www.nature.com/articles/ncomms8427)
- [Competitive exclusion and coexistence in a self-replicating system,
  *Nature Chemistry*
  (2025)](https://www.nature.com/articles/s41557-024-01664-0)
- [Chemically fuelled self-replication, *Nature Communications*
  (2019)](https://www.nature.com/articles/s41467-019-08885-9)

### Réseau bistable simple

- [Dynamics of hydroxide-ion-driven reversible autocatalytic networks,
  *RSC Advances* (2023)](https://pubs.rsc.org/en/content/articlelanding/2023/ra/d3ra04215d)
