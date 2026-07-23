# Diagramme révisé du morphisme causal médiatisé par le gap

Ce document représente le morphisme entre la dynamique tarskienne `T` et la
progression de théories `P` en séparant strictement trois niveaux :

1. le **cycle local** propre à chaque système ;
2. le **transport causal** des états et des occurrences positives ;
3. les **évaluations terminales**, qui restent locales et ne sont pas
   transportées.

La correction principale par rapport au schéma initial est la suivante : les
gaps de `T` et de `P` ne sont pas reliés directement comme phrases. Leur
appariement est induit par le transport des **nouvelles occurrences** dont ils
sont les étiquettes.

## 1. Vue d’ensemble

```mermaid
flowchart TB

  subgraph T["Réalisation T — correction tarskienne locale"]
    direction LR

    T0["État S_T"]
    TG["d_T := gap_T(S_T)<br/><b>frontier_open_T</b><br/>¬ Evaluated_T(S_T, d_T)"]
    T1["S_T⁺ := advance_T(S_T)"]
    TN["ν_T(S_T) := new_T(S_T)<br/>ν_T(S_T) : Position_T(S_T⁺)<br/>label_T(ν_T(S_T)) = d_T"]
    TC["<b>frontier_closed_T</b><br/>Evaluated_T(S_T⁺, d_T)"]
    TG1["d_T⁺ := gap_T(S_T⁺)<br/><b>frontier_open_T</b><br/>¬ Evaluated_T(S_T⁺, d_T⁺)"]

    T0 -->|"construit gap_T"| TG
    TG -->|"est incorporé par advance_T"| T1
    T1 -->|"branche none de advancePositions_T"| TN
    TN -->|"position_evaluated_T"| TC
    T1 -->|"construit la frontière suivante"| TG1
  end

  subgraph P["Réalisation P — prouvabilité locale"]
    direction LR

    P0["État S_P := φ(S_T)"]
    PG["d_P := gap_P(S_P)<br/><b>frontier_open_P</b><br/>¬ Evaluated_P(S_P, d_P)"]
    P1["S_P⁺ := advance_P(S_P)<br/>= φ(S_T⁺)"]
    PN["ν_P(S_P) := new_P(S_P)<br/>ν_P(S_P) : Position_P(S_P⁺)<br/>label_P(ν_P(S_P)) = d_P"]
    PC["<b>frontier_closed_P</b><br/>Evaluated_P(S_P⁺, d_P)"]
    PG1["d_P⁺ := gap_P(S_P⁺)<br/><b>frontier_open_P</b><br/>¬ Evaluated_P(S_P⁺, d_P⁺)"]

    P0 -->|"construit gap_P"| PG
    PG -->|"est incorporé par advance_P"| P1
    P1 -->|"branche none de advancePositions_P"| PN
    PN -->|"position_evaluated_P"| PC
    P1 -->|"construit la frontière suivante"| PG1
  end

  T0 -.->|"φ"| P0
  T1 -.->|"φ ; commutation avec advance"| P1
  TN -.->|"positionMap sur l’état successeur<br/>new_T ↦ new_P"| PN

  NS["Aucune composante sémantique du morphisme<br/><b>Evaluated_T ↛ Evaluated_P</b>"]
  TC ~~~ NS
  NS ~~~ PC

  classDef state fill:#eef4fb,stroke:#315d80,stroke-width:1px;
  classDef gap fill:#fff8e6,stroke:#8a6500,stroke-width:1px;
  classDef occurrence fill:#edf8ef,stroke:#35733b,stroke-width:1px;
  classDef evaluation fill:#f5f0fb,stroke:#6a4b8a,stroke-width:1px;
  classDef excluded fill:#fff1f1,stroke:#9b3d3d,stroke-width:1px,stroke-dasharray:5 4;

  class T0,T1,P0,P1 state;
  class TG,TG1,PG,PG1 gap;
  class TN,PN occurrence;
  class TC,PC evaluation;
  class NS excluded;
```

### Lecture correcte de la verticale centrale

Le diagramme ne contient volontairement aucune flèche `d_T → d_P`. Les deux
frontières courantes sont appariées par le triangle de données suivant :

```text
label_T[S_T⁺](new_T(S_T)) = gap_T(S_T)

positionMap_{S_T⁺}(new_T(S_T)) = new_P(φ(S_T))

label_P[S_P⁺](new_P(φ(S_T))) = gap_P(φ(S_T)).
```

Ainsi, les gaps correspondent comme **événements frontières**. Ils ne sont ni
égaux comme phrases, ni reliés par une transformation syntaxique globale déjà
postulée. Les annotations `S_T⁺` et `S_P⁺` rappellent que les nouvelles
occurrences appartiennent aux états successeurs, tandis que les gaps qu'elles
étiquettent ont été construits aux états sources.

## 2. Carré de commutation des états

```mermaid
flowchart TB

  ST["S_T"] -->|"advance_T"| ST1["advance_T(S_T)"]
  SP["φ(S_T)"] -->|"advance_P"| SP1["advance_P(φ(S_T))"]

  ST -.->|"φ"| SP
  ST1 -.->|"φ"| SP1

  classDef state fill:#eef4fb,stroke:#315d80,stroke-width:1px;
  class ST,ST1,SP,SP1 state;
```

La commutation demandée est :

```text
φ(advance_T(S_T))
= advance_P(φ(S_T)).
```

Cette égalité transporte la succession des états. Elle ne compare pas leurs
contenus sémantiques.

## 3. Carré positif exact des occurrences

Le carré suivant remplace avantageusement le seul carré `old` du schéma
initial. Il exprime en une loi unique la compatibilité avec les deux branches
`none` et `some`.

```mermaid
flowchart TB

  TA["Position_T(advance_T(S_T))"] <-->|"advancePositions_T"| TO["Option(Position_T(S_T))"]
  PA["Position_P(advance_P(φ(S_T)))"] <-->|"advancePositions_P"| PO["Option(Position_P(φ(S_T)))"]

  TA -.->|"positionMap_advance"| PA
  TO -.->|"Option(positionMap_S)"| PO

  classDef occurrence fill:#edf8ef,stroke:#35733b,stroke-width:1px;
  class TA,TO,PA,PO occurrence;
```

La loi de commutation est :

```text
advancePositions_P ∘ positionMap_advance
=
Option(positionMap_S) ∘ advancePositions_T.
```

Elle produit immédiatement les deux équations fondamentales :

```text
positionMap_advance(new_T(S_T))
= new_P(φ(S_T))
```

et

```text
positionMap_advance(old_T(p))
= old_P(positionMap_S(p)).
```

Le transport préserve donc simultanément la **naissance** d’une occurrence et
son **héritage** dans les états futurs. Il ne s’agit pas d’une bijection choisie
après comparaison de deux cardinalités.

## 4. Factorisation locale par les positions

```mermaid
flowchart TB

  subgraph FT["Factorisation locale dans T"]
    direction LR
    PT["p_T : Position_T(S_T)"] -->|"label_T"| DT["d_T := label_T(p_T)"]
    DT -->|"position_evaluated_T(p_T)"| ET["Evaluated_T(S_T, d_T)"]
  end

  subgraph FP["Factorisation locale dans P"]
    direction LR
    PP["p_P : Position_P(φ(S_T))"] -->|"label_P"| DP["d_P := label_P(p_P)"]
    DP -->|"position_evaluated_P(p_P)"| EP["Evaluated_P(φ(S_T), d_P)"]
  end

  PT -.->|"positionMap_S"| PP

  NX["Pas de flèche verticale sur les phrases en général<br/>Pas de flèche verticale entre les évaluations"]
  ET ~~~ NX
  NX ~~~ EP

  classDef occurrence fill:#edf8ef,stroke:#35733b,stroke-width:1px;
  classDef gap fill:#fff8e6,stroke:#8a6500,stroke-width:1px;
  classDef evaluation fill:#f5f0fb,stroke:#6a4b8a,stroke-width:1px;
  classDef excluded fill:#fff1f1,stroke:#9b3d3d,stroke-width:1px,stroke-dasharray:5 4;

  class PT,PP occurrence;
  class DT,DP gap;
  class ET,EP evaluation;
  class NX excluded;
```

Pour une occurrence `p_T`, le morphisme induit seulement la correspondance
syntaxique dépendante de l’état et de l’occurrence :

```text
χ_{S_T}(p_T)
:= label_P(positionMap_{S_T}(p_T)).
```

Cette construction ne définit pas encore une fonction globale
`χ : Sentence → Sentence`, et elle ne transforme jamais un certificat
`Evaluated_T` en certificat `Evaluated_P`.

## 5. Mémoire exacte dérivée de la structure positive

Dans chaque réalisation :

```text
Memory⁺(S, d)
:⇔ ∃ p : Position(S), label(p) = d.
```

L’équivalence positive

```text
Position(advance(S)) ≃ Option(Position(S))
```

et les lois sur les étiquettes donnent :

```text
Memory⁺(advance(S), d)
↔ d = gap(S) ∨ Memory⁺(S, d).
```

La fermeture de l’ancien gap est elle aussi dérivée, et non ajoutée comme une
flèche sémantique entre les deux systèmes :

```text
new(S) : Position(advance(S))
label(new(S)) = gap(S)
position_evaluated(new(S))

────────────────────────────────
Evaluated(advance(S), gap(S)).
```

## 6. Cycle formel représenté

```text
frontier_open
→ gap syntaxique individué
→ advance qui incorpore ce gap
→ nouvelle occurrence positive
→ frontier_closed pour l’ancien gap
→ mémoire exacte et conservation des occurrences
→ conservation des évaluations déjà acquises
→ nouveau frontier_open dans l’état successeur.
```

Le morphisme transporte la colonne causale de ce cycle :

```text
état
+ succession par advance
+ nouvelle occurrence
+ anciennes occurrences héritées
+ provenance new / old
+ appariement événementiel des frontières.
```

Il ne transporte pas :

```text
Evaluated_T
models
CorrectAt
TheoryProvable
Evaluated_P.
```

## 7. Statut formel

Le diagramme spécifie la cible du théorème à construire. Les positions positives
et leur extension exacte par `Option` sont déjà disponibles du côté `T`. Le
type positif `TheoryHistory.Contains` fournit le support prévu de `Position_P`.
Les déclarations constituant la chaîne arithmétique `P` sont présentes dans les
sources, mais leur fermeture ne doit être annoncée qu'après compilation de la
cible terminale et audit axiomatique dans le même état du dépôt. À l'état relu
le 23 juillet 2026, cette recompilation reste à rétablir à partir de
`PrimitiveRecursiveProofCorrectness.lean`.

Indépendamment de ce point de certification, l'interface positive commune,
l'empaquetage des deux réalisations, `φ`, `positionMap` et leurs lois de
commutation restent à formaliser. Le diagramme ne les présente donc pas comme
des théorèmes déjà acquis.
