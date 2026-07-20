# CR0-G0 — Paquet de provenance

## Statut

**Audit initial exécuté le 18 juillet 2026.**

Ce dossier fige les sources utilisées pour décider si les données publiques
contiennent déjà le couple expérimental exigé par `CARBON_REFERENCE_0`.

Verdict :

```text
GO      : sources localisées, téléchargées, hashées et rendues interrogeables ;
GO      : un candidat miroir de groupe existe à ±0,10 % ee ;
NO-GO   : aucun témoin public trouvé ne satisfait simultanément
          appariement miroir exact et futurs empiriques disjoints ;
GO      : une méthode publiée donne accès aux deux énantiomères TMSPyr-OH et
          ferme la conception d'un pilote miroir transmissible ;
NO-GO   : aucune instance Lean ne doit encore être nommée comme preuve chimique.
```

Le détail du verdict se trouve dans [PAIR_SEARCH.md](./PAIR_SEARCH.md).
La prochaine expérience est cadrée, sans instructions de paillasse, dans
[CR0_PAIRED_EXPERIMENT_0.md](./CR0_PAIRED_EXPERIMENT_0.md). L'audit public
complémentaire se trouve dans
[PUBLIC_PROTOCOL_AUDIT.md](./PUBLIC_PROTOCOL_AUDIT.md), et la passation
exécutable par un laboratoire qualifié dans [LAB_HANDOFF.md](./LAB_HANDOFF.md).

## 1. Sources figées

| ID | Source primaire | Artefact local | SHA-256 |
|---|---|---|---|
| `M2025-SI` | Möhler et al., *Nature Communications* 16, 7303 (2025) | `sources/Mohler_et_al_2025_supplement.pdf` | `0d0a7f69628567fd6e4c0c412f6956d48e2b204f9102911a5ff6b128ec6339f6` |
| `HB2019-SI` | Hawbaker & Blackmond, *Nature Chemistry* 11, 957–962 (2019) | `sources/Hawbaker_Blackmond_2019_supplement.pdf` | `661d02b19463def868c9d04b90d2cbd53ded538a229254154cf23f44ca57d282` |
| `HB2018-ZIP` | Hawbaker & Blackmond, *ACS Central Science* 4, 776–780 (2018), archive Europe PMC | `sources/Hawbaker_Blackmond_2018_EuropePMC_supplementaryFiles.zip` | `f0ec48a853eca57e5c1b3ed57c74067a59dbbf186811aa60425d949526102ea3` |
| `HB2018-SI` | PDF contenu dans `HB2018-ZIP` | `sources/Hawbaker_Blackmond_2018_ACS_supplement.pdf` | `8a9a897d7bc413fa89634e7e50d4813caa1e707437e6eb0906caf204d13f6663` |

Liens canoniques :

- [article M2025](https://doi.org/10.1038/s41467-025-62591-3) ;
- [supplément M2025](https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-025-62591-3/MediaObjects/41467_2025_62591_MOESM1_ESM.pdf) ;
- [article HB2019](https://doi.org/10.1038/s41557-019-0321-y) ;
- [supplément HB2019](https://static-content.springer.com/esm/art%3A10.1038%2Fs41557-019-0321-y/MediaObjects/41557_2019_321_MOESM9_ESM.pdf) ;
- [article HB2018](https://doi.org/10.1021/acscentsci.8b00297).

Les PDF du dossier `sources/` sont des copies de travail immuables. Une
nouvelle version distante doit recevoir un nouveau nom et un nouveau hash ;
elle ne doit jamais remplacer silencieusement ces fichiers.

Les PDF, archives et extractions intégrales restent des artefacts locaux non
versionnés afin de ne pas republier des contenus tiers. Le dépôt conserve les
liens canoniques, les noms attendus, les hashes, le manifeste et les
transcriptions sélectives nécessaires à l'audit. Après récupération locale,
`sha256sum -c MANIFEST.sha256` vérifie les copies de travail.

## 2. Extraction textuelle dérivée

L'environnement ne possédait ni `pdftotext`, ni `pdfinfo`. `pypdf 5.9.0` a
été installé uniquement dans `/tmp/cr0_pypdf`. Les PDF sources n'ont pas été
modifiés.

Artefacts dérivés :

| Source | Texte dérivé | SHA-256 |
|---|---|---|
| `HB2019-SI` | `extracted/Hawbaker_Blackmond_2019_supplement_20260718_sha256-661d02b19463_pypdf-5.9.0.txt` | `542d0a54f6b50801ae46f589ef7253956401983aa10dfdbf0567cf05d5c93d70` |
| `M2025-SI` | `extracted/Mohler_et_al_2025_supplement_20260718_sha256-0d0a7f696285_pypdf-5.9.0.txt` | `1d896acc058ffd15d84502aa50c5009a3db2a66ada1d5fc5f306bb0d989302ad` |
| `HB2018-SI` | `extracted/Hawbaker_Blackmond_2018_ACS_supplement_20260718_sha256-8a9a897d7bc4_pypdf-5.9.0.txt` | `a6dbd4882a06ea4c4cb4228c191a862b7fc8d147e52bcefb943cde1aaa624677` |

Commande d'extraction exécutée depuis la racine du projet :

```text
python3 -c "import sys; sys.path.insert(0, '/tmp/cr0_pypdf'); from pypdf import PdfReader; from pathlib import Path; pairs=[('Carbone/CR0_G0/sources/Hawbaker_Blackmond_2019_supplement.pdf','Carbone/CR0_G0/extracted/Hawbaker_Blackmond_2019_supplement_20260718_sha256-661d02b19463_pypdf-5.9.0.txt'),('Carbone/CR0_G0/sources/Mohler_et_al_2025_supplement.pdf','Carbone/CR0_G0/extracted/Mohler_et_al_2025_supplement_20260718_sha256-0d0a7f696285_pypdf-5.9.0.txt')]; [(Path(dst).write_text(''.join('\n\n===== PAGE %d =====\n\n%s' % (i+1, (p.extract_text() or '')) for i,p in enumerate(PdfReader(src).pages)), encoding='utf-8')) for src,dst in pairs]"
```

Cette extraction sert à la recherche et à la transcription. Elle n'est pas
une validation visuelle des tableaux : les signes, exposants et colonnes des
rangées retenues doivent encore être contrôlés sur le PDF avant utilisation
numérique ou publication.

Le PDF `HB2018-SI` a été extrait mécaniquement de l'archive Europe PMC sans
modification. Son texte dérivé a été produit avec le même environnement
`pypdf 5.9.0`. Les hashes du PDF et du texte sont conservés dans le manifeste.

## 3. Résultats de la recherche

### M2025-SI

Le supplément contient 159 pages et de nombreux profils concentration-temps.
Les conditions expérimentales extraites emploient des alcools initiaux
`(1R)` fortement enrichis (`ee > 99,9 %`). Le texte précise, dans la section
de modélisation, que la sélectivité y est négligée parce que seuls des alcools
énantiopurs ou fortement enrichis ont été employés expérimentalement.

Les deux cycles R/S figurent dans le modèle et les deux produits apparaissent
dans les courbes, mais cela ne constitue pas deux expériences initiales
miroirs R et S. `M2025-SI` ne fournit donc pas seul le témoin CR0 recherché.

Son protocole établit cependant que les deux énantiomères du TMSPyr-OH
racémique sont séparables par HPLC préparative. Le verrou devient la
qualification des lots et l'acquisition du profil S, et non l'absence d'une
voie publiée vers la main opposée.

### HB2019-SI

Le supplément contient 21 pages et annonce les résultats de toutes les
expériences de brisure de symétrie. Sa table supplémentaire 1 fournit le signe
et la magnitude de l'ee de l'initiateur, le nombre d'injections, la quantité
d'aldéhyde ajoutée, le lot de contrôle et l'ee final du produit.

Trois groupes sont déterminants :

- groupe A : futurs directionnellement séparés, mais entrées `96 % R` et
  `85 % S`, donc non miroirs en magnitude ;
- groupe B : forte séparation, avec une exception directionnelle, mais entrées
  `52 % R` et `39 % S`, donc non miroirs ;
- groupe H : entrées exactement `0,10 % R` et `0,10 % S`, mêmes quatre
  injections, mêmes `4,1 mmol` d'aldéhyde et même lot H, mais distributions
  finales fortement recouvrantes.

La table H sélectionnée est transcrite dans
[`hb2019_batch_h_selected.csv`](./hb2019_batch_h_selected.csv).

### HB2018-SI

Le supplément de 2018 documente la préparation des produits alcool R et S du
système pyrimidine historique, ainsi que des cinétiques en double initialisées
par le produit R. Aucun jumeau S correspondant n'y a été trouvé. Ces données
renforcent la faisabilité générale d'une préparation miroir mais ne sont pas
une paire CR0 et ne sont pas fusionnées avec le système TMSPyr.

## 4. Discipline de provenance

- `sources/` contient uniquement les artefacts distants figés ;
- `extracted/` contient les transformations mécaniques identifiées par date,
  hash source et version d'outil ;
- les transcriptions sélectives portent leur page source et leur statut de
  validation ;
- une valeur OCR ne devient pas une donnée validée sans contrôle visuel ;
- aucune valeur manquante ne doit être reconstruite par symétrie chimique ;
- une simulation miroir ne doit pas être étiquetée comme réplicat expérimental.

Les hashes de référence sont également regroupés dans
[`MANIFEST.sha256`](./MANIFEST.sha256).
