# Revised diagram of the gap-mediated causal morphism

This document represents the morphism between the Tarskian dynamics `T` and
the theory progression `P` while strictly separating three levels:

1. the **local cycle** proper to each system;
2. the **causal transport** of states and positive occurrences;
3. the **terminal evaluations**, which remain local and are not transported.

The main clarification with respect to the initial diagram is the following:
the gaps of `T` and `P` are not related directly as sentences. Their pairing is
induced by the transport of the **new occurrences** whose labels they are.

## 1. Overview

```mermaid
flowchart TB

  subgraph T["Realization T — local Tarskian correction"]
    direction LR

    T0["State S_T"]
    TG["d_T := gap_T(S_T)<br/><b>frontier_open_T</b><br/>¬ Evaluated_T(S_T, d_T)"]
    T1["S_T⁺ := advance_T(S_T)"]
    TN["ν_T(S_T) := new_T(S_T)<br/>ν_T(S_T) : Position_T(S_T⁺)<br/>label_T(ν_T(S_T)) = d_T"]
    TC["<b>frontier_closed_T</b><br/>Evaluated_T(S_T⁺, d_T)"]
    TG1["d_T⁺ := gap_T(S_T⁺)<br/><b>frontier_open_T</b><br/>¬ Evaluated_T(S_T⁺, d_T⁺)"]

    T0 -->|"constructs gap_T"| TG
    TG -->|"is incorporated by advance_T"| T1
    T1 -->|"none branch of advancePositions_T"| TN
    TN -->|"position_evaluated_T"| TC
    T1 -->|"constructs the next frontier"| TG1
  end

  subgraph P["Realization P — local provability"]
    direction LR

    P0["State S_P := φ(S_T)"]
    PG["d_P := gap_P(S_P)<br/><b>frontier_open_P</b><br/>¬ Evaluated_P(S_P, d_P)"]
    P1["S_P⁺ := advance_P(S_P)<br/>= φ(S_T⁺)"]
    PN["ν_P(S_P) := new_P(S_P)<br/>ν_P(S_P) : Position_P(S_P⁺)<br/>label_P(ν_P(S_P)) = d_P"]
    PC["<b>frontier_closed_P</b><br/>Evaluated_P(S_P⁺, d_P)"]
    PG1["d_P⁺ := gap_P(S_P⁺)<br/><b>frontier_open_P</b><br/>¬ Evaluated_P(S_P⁺, d_P⁺)"]

    P0 -->|"constructs gap_P"| PG
    PG -->|"is incorporated by advance_P"| P1
    P1 -->|"none branch of advancePositions_P"| PN
    PN -->|"position_evaluated_P"| PC
    P1 -->|"constructs the next frontier"| PG1
  end

  T0 -.->|"φ"| P0
  T1 -.->|"φ; commutes with advance"| P1
  TN -.->|"positionMap on the successor state<br/>new_T ↦ new_P"| PN

  NS["No semantic component in the morphism<br/><b>Evaluated_T ↛ Evaluated_P</b>"]
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

### Correct reading of the central vertical relation

The diagram deliberately contains no arrow `d_T → d_P`. The two current
frontiers are paired through the following triangle of data:

```text
label_T[S_T⁺](new_T(S_T)) = gap_T(S_T)

positionMap_{S_T⁺}(new_T(S_T)) = new_P(φ(S_T))

label_P[S_P⁺](new_P(φ(S_T))) = gap_P(φ(S_T)).
```

The gaps therefore correspond as **frontier events**. They are neither equal
as sentences nor related by an already postulated global syntactic
transformation. The annotations `S_T⁺` and `S_P⁺` recall that the new
occurrences belong to the successor states, whereas the gaps they label were
constructed at the source states.

## 2. State commutation square

```mermaid
flowchart TB

  ST["S_T"] -->|"advance_T"| ST1["advance_T(S_T)"]
  SP["φ(S_T)"] -->|"advance_P"| SP1["advance_P(φ(S_T))"]

  ST -.->|"φ"| SP
  ST1 -.->|"φ"| SP1

  classDef state fill:#eef4fb,stroke:#315d80,stroke-width:1px;
  class ST,ST1,SP,SP1 state;
```

The required commutation law is:

```text
φ(advance_T(S_T))
= advance_P(φ(S_T)).
```

This equality transports state succession. It does not compare the semantic
contents of the states.

## 3. Exact positive square of occurrences

The following square improves on the isolated `old` square of the initial
diagram. It expresses compatibility with both the `none` and `some` branches
in a single law.

```mermaid
flowchart TB

  TA["Position_T(advance_T(S_T))"] <-->|"advancePositions_T"| TO["Option(Position_T(S_T))"]
  PA["Position_P(advance_P(φ(S_T)))"] <-->|"advancePositions_P"| PO["Option(Position_P(φ(S_T)))"]

  TA -.->|"positionMap_advance"| PA
  TO -.->|"Option(positionMap_S)"| PO

  classDef occurrence fill:#edf8ef,stroke:#35733b,stroke-width:1px;
  class TA,TO,PA,PO occurrence;
```

The commutation law is:

```text
advancePositions_P ∘ positionMap_advance
=
Option(positionMap_S) ∘ advancePositions_T.
```

It immediately yields the two fundamental equations:

```text
positionMap_advance(new_T(S_T))
= new_P(φ(S_T))
```

and

```text
positionMap_advance(old_T(p))
= old_P(positionMap_S(p)).
```

The transport therefore preserves both the **birth** of an occurrence and its
**inheritance** in future states. It is not a bijection chosen after comparing
two cardinalities.

## 4. Local factorization through positions

```mermaid
flowchart TB

  subgraph FT["Local factorization in T"]
    direction LR
    PT["p_T : Position_T(S_T)"] -->|"label_T"| DT["d_T := label_T(p_T)"]
    DT -->|"position_evaluated_T(p_T)"| ET["Evaluated_T(S_T, d_T)"]
  end

  subgraph FP["Local factorization in P"]
    direction LR
    PP["p_P : Position_P(φ(S_T))"] -->|"label_P"| DP["d_P := label_P(p_P)"]
    DP -->|"position_evaluated_P(p_P)"| EP["Evaluated_P(φ(S_T), d_P)"]
  end

  PT -.->|"positionMap_S"| PP

  NX["No vertical arrow on sentences in general<br/>No vertical arrow between evaluations"]
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

For an occurrence `p_T`, the morphism induces only the syntactic
correspondence that depends on the state and occurrence:

```text
χ_{S_T}(p_T)
:= label_P(positionMap_{S_T}(p_T)).
```

This construction does not yet define a global function
`χ : Sentence → Sentence`, and it never transforms an `Evaluated_T`
certificate into an `Evaluated_P` certificate.

## 5. Exact memory derived from the positive structure

In each realization:

```text
Memory⁺(S, d)
:⇔ there exists p : Position(S), label(p) = d.
```

The positive equivalence

```text
Position(advance(S)) ≃ Option(Position(S))
```

together with the label laws gives:

```text
Memory⁺(advance(S), d)
↔ d = gap(S) ∨ Memory⁺(S, d).
```

Closure of the former gap is likewise derived, rather than added as a
semantic arrow between the two systems:

```text
new(S) : Position(advance(S))
label(new(S)) = gap(S)
position_evaluated(new(S))

────────────────────────────────
Evaluated(advance(S), gap(S)).
```

## 6. Formal cycle represented

```text
frontier_open
→ individuated syntactic gap
→ advance incorporating that gap
→ new positive occurrence
→ frontier_closed for the former gap
→ exact memory and preservation of occurrences
→ preservation of evaluations already acquired
→ new frontier_open in the successor state.
```

The morphism transports the causal column of this cycle:

```text
state
+ succession by advance
+ new occurrence
+ inherited former occurrences
+ new / old provenance
+ event-level pairing of frontiers.
```

It does not transport:

```text
Evaluated_T
models
CorrectAt
TheoryProvable
Evaluated_P.
```

## 7. Formal status

The diagram specifies the target theorem. Positive positions and their exact
extension by `Option` are already available on the `T` side. The positive type
`TheoryHistory.Contains` provides the intended support for `Position_P`.
Declarations making up the arithmetic `P` chain are present in the sources,
but their closure must be announced only after compilation of the terminal
target and an axiom audit in the same repository state. In the state reviewed
on 23 July 2026, that compilation still has to be restored starting from
`PrimitiveRecursiveProofCorrectness.lean`.

Independently of this certification point, the common positive interface,
packaging of both realizations, `φ`, `positionMap`, and their commutation laws
remain to be formalized. The diagram therefore does not present them as
theorems already established.
