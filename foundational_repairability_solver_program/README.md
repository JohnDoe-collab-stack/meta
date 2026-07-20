# Programme autonome du solveur constructif de réparabilité

Statut : **contrat d’implémentation, aucune revendication expérimentale**  
Version du programme : **1.0.0**  
Objet : préparer une contribution fondationnelle, réfutable, reproductible et publiable sur la réparation certifiée de représentations latentes.

## 1. Résultat visé

Le dossier prescrit la construction d’un système fini, constructif et exécutable qui, pour tout état public représentable :

1. calcule une stratégie active de réparation conduisant à une décision suffisante et certifiée ; ou
2. retourne une obstruction positive et vérifiable montrant pourquoi aucune stratégie publique du langage considéré ne peut garantir cette décision ;
3. minimise ensuite un coût déclaré parmi les stratégies sûres ;
4. accepte enfin un état latent appris uniquement au travers d’un certificat vérifié indépendamment.

Le cœur attendu n’est donc pas un nouveau scénario illustratif. C’est une procédure de décision avec deux issues certifiées :

```text
état public fini
      |
      v
solveur constructif total
      |
      +-- WIN  : arbre de réparation + correction + conservation + coût
      |
      `-- LOSE : région fermée + contre-stratégie de réponses + conflit d’action
```

La cible mathématique principale est :

> Dans tout jeu fini de réparation satisfaisant le contrat effectif, l’appartenance au plus petit point fixe gagnant est équivalente à l’existence d’un épisode public fini de réparation certifiée. Le calcul produit constructivement soit cet épisode, soit une contre-stratégie fermée. Sous le contrat de transfert, tout certificat accepté depuis un latent appris conserve cette garantie dans l’environnement concret.

## 2. Pourquoi ce programme dépasse le résultat actuel

Le travail antérieur prouve déjà un no-go adaptatif, des réalisations exactes et une synthèse à partir d’une hypothèse de séparateurs composables. Il ne faut ni le sous-estimer ni le rebaptiser.

Le verrou restant est précis :

- ne plus recevoir le séparateur local comme oracle positif ;
- rendre les états, requêtes, réponses et transitions effectivement énumérables ;
- calculer le domaine gagnant par point fixe fini ;
- extraire une stratégie ou une obstruction sans raisonnement classique ;
- prouver la complétude du calcul vis-à-vis de toutes les stratégies publiques finies ;
- relier le résultat à un latent appris sans faire confiance au réseau neuronal.

## 3. Revendication autorisée après chaque niveau

| Niveau achevé | Revendication maximale autorisée |
|---|---|
| Spécification seule | programme de recherche prêt à implémenter |
| Solveur exécuté sans preuves complètes | prototype de décision fini |
| Correction Lean | solveur certifié correct |
| Correction + complétude + obstruction | caractérisation constructive décidable dans la classe déclarée |
| Niveau précédent + optimalité | synthèse certifiée de coût minimal dans la classe déclarée |
| Niveau précédent + transfert appris | garantie conditionnelle pour les latents dont le certificat est accepté |
| Niveau précédent + campagne préenregistrée | résultat expérimental contrôlé sur les domaines déclarés |
| Comparaisons formelles + réplication extérieure | candidat à une contribution fondationnelle majeure |

Les mots « révolution », « game changer », « solution générale de l’IA » et « première mondiale » sont interdits dans les titres, résumés et communiqués tant que les portes de publication définies dans `NOVELTY_AND_PUBLICATION_GATES.md` ne sont pas toutes franchies ; même ensuite, « game changer » reste un jugement extérieur et rétrospectif, pas un résultat scientifique auto-attribué.

## 4. Portée exacte

### 4.1 Cœur démontré visé

- mondes, états publics, obligations, actions, requêtes et réponses finis ;
- égalités décidables et énumérations complètes ;
- réponses déterministes dans le premier théorème ;
- autorisation et transition dépendant de l’état public ;
- état public suffisamment riche pour inclure mémoire, provenance et contexte d’autorisation ;
- objectif d’action, pas nécessairement identification du monde ;
- réparations exactes ou sur-approximatives sûres, distinguées par types ;
- progression finie obtenue par calcul interne du point fixe, jamais par une hypothèse externe de rang ;
- preuves Lean strictement constructives et sans axiomes.

### 4.2 Extensions séparées

- réponses adversariales finies : jeu de sûreté/atteignabilité ;
- réponses stochastiques : garanties probabilistes, jamais confondues avec la certitude ;
- espaces continus : abstractions finies certifiées seulement ;
- latent appris : transfert conditionnel à l’acceptation d’un certificat ;
- coût optimal : après la correction et la complétude non pondérées.

### 4.3 Non-revendications

Le programme ne prétend pas :

- que toute représentation latente est réparable ;
- qu’un réseau appris satisfait spontanément le contrat ;
- que l’observation active, les belief states, les predictive states, le diagnostic actif ou les jeux d’atteignabilité sont nouveaux ;
- que la certification remplace la généralisation empirique ;
- que les résultats finis impliquent une solution universelle en espace continu ;
- que l’absence de certificat prouve l’impossibilité hors du langage public déclaré.

## 5. Documents normatifs

L’implémentation n’est recevable que si elle respecte l’ensemble de ces fichiers :

- `MATHEMATICAL_CONTRACT.md` — objets, sémantique et théorèmes obligatoires ;
- `LEAN_AND_SOLVER_ARCHITECTURE.md` — modules, interfaces et ordre des preuves ;
- `EXHAUSTIVE_VERIFICATION_PROTOCOL.md` — énumération, oracles croisés, mutations et traçabilité ;
- `LEARNED_LATENT_WORKSTATION_PROTOCOL.md` — campagne apprise réalisable sur une seule station ;
- `NOVELTY_AND_PUBLICATION_GATES.md` — comparaisons, falsification et limites de revendication ;
- `IMPLEMENTATION_ROADMAP.md` — ordre de construction et critères de sortie ;
- `TRACEABILITY_MATRIX.md` — correspondance entre exigences, preuves, tests et artefacts ;
- `DECISIONS_AND_RISKS.md` — décisions gelées, signaux d’échec et replis autorisés ;
- `SPECIFICATION_AUDIT.md` — contrôles réalisés, corrections et limites du présent dossier ;
- `schemas/program.schema.json` et `program.lock.json` — contrat machine du programme.

En cas de contradiction, la priorité est :

1. contraintes constructives du dépôt ;
2. contrat mathématique ;
3. architecture Lean ;
4. protocole de vérification ;
5. protocole expérimental ;
6. feuille de route.

## 6. Structure cible du futur artefact

```text
foundational_repairability_solver/
├── lakefile.toml
├── lean-toolchain
├── LICENSE
├── CITATION.cff
├── README.md
├── Meta/
│   └── ConstructiveRepairability/
│       ├── FiniteCarrier.lean
│       ├── PublicGame.lean
│       ├── KnowledgeState.lean
│       ├── Target.lean
│       ├── Predecessor.lean
│       ├── FixedPoint.lean
│       ├── Strategy.lean
│       ├── Obstruction.lean
│       ├── Characterization.lean
│       ├── ExactPosterior.lean
│       ├── CostOptimal.lean
│       ├── LearnedTransfer.lean
│       ├── Comparisons/
│       │   ├── AdaptiveDistinguishing.lean
│       │   ├── BeliefState.lean
│       │   └── ActiveDiagnosis.lean
│       ├── Countermodels.lean
│       └── Validation.lean
├── checker/
├── enumerator/
├── experiments/
├── schemas/
├── tests/
├── frozen_runs/
└── paper/
```

Ce futur artefact doit être autonome : aucune importation d’un module métier du dépôt actuel. Les résultats existants peuvent être cités comme antécédents, mais le build, les définitions et les preuves doivent fonctionner dans une copie isolée.

## 7. Définition de « prêt à publication »

Un dépôt n’est prêt à soumettre que si :

- le théorème de décision total compile sans axiome ;
- les branches `WIN` et `LOSE` possèdent chacune un vérificateur indépendant ;
- correction, complétude et finitude sont prouvées ;
- les affirmations de coût minimal sont prouvées ou supprimées ;
- l’énumération bornée a terminé et ses manifestes sont publiés ;
- toutes les mutations obligatoires ont été détectées ;
- le protocole appris est gelé avant les runs confirmatoires ;
- tous les runs, y compris négatifs, sont publiés ;
- le latent appris ne peut jamais contourner le vérificateur ;
- la comparaison formelle et textuelle avec les travaux voisins est exacte ;
- une réplication indépendante du build et d’au moins un corpus exhaustif existe.

## 8. État initial du dossier

À la création de ce programme :

- architecture : spécifiée ;
- code Lean : non commencé ;
- solveur : non commencé ;
- expériences : non exécutées ;
- revendication empirique : aucune ;
- priorité ou nouveauté : non établie ;
- objectif « contribution majeure » : conditionnel aux preuves et aux validations.

Cette séparation entre objectif, preuve et revendication est intentionnelle. Elle protège précisément le caractère fondationnel du travail.
