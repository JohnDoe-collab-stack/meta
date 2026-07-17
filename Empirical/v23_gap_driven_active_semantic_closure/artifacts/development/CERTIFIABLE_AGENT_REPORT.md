# Agent certifiable v23 - artefact de développement

Ce dossier matérialise G3 avant le gel scientifique G0. Il ne remplace ni le
bundle `timestamp+sha256`, ni la réplication indépendante exigés par
`SCIENTIFIC_PROTOCOL.md`.

## Résultat exact

```text
architecture       : 96 -> cinq têtes MLP -> patch symbolique
arithmétique       : Int8 / Int32, ties-to-even, saturation, argmax canonique
seed               : 0
première mise à jour admissible : 156
obligations        : 697
erreurs            : 0
marge entière min. : 1

gap                : 15 / 15
use                : 22 / 22
transport          : 44 / 44
query              : 88 / 88
repair             : 528 / 528
```

Chaque mise à jour `1..155` du seed `0` est quantifiée selon les puissances
figées et rejetée. La mise à jour `156` est la première qui satisfait toutes
les obligations. Le vérificateur recharge le JSON canonique, recalcule les 697
inférences entières, contrôle les classes réservées et rejoue l'entraînement.

## Commandes de développement

```text
python3 train_certifiable_agent_v23.py \
  --out artifacts/development/quantized_checkpoint_v23.json

python3 verify_quantized_inference_v23.py \
  artifacts/development/quantized_checkpoint_v23.json \
  --replay-training

python3 export_quantized_agent_v23.py \
  artifacts/development/quantized_checkpoint_v23.json \
  --out-lean ../../Meta/AI/QuantizedCertifiedAgent.lean

lake build Meta.AI.QuantizedCertifiedAgent
```

## Empreintes

```text
certifiable_agent_v23.py
82206223c28993bdadb9fcb5e56e2dc0ccc48e786a32cd64ea4469639ace0078

train_certifiable_agent_v23.py
fa10e9e909a32c7199e1fff24e1661d138a656a4c9fae87db411ed3ca0684df8

verify_quantized_inference_v23.py
61ec306772e17c202ac6021bdcad2a116e2cc1e53b32eab50b7b48f9c3babb17

export_quantized_agent_v23.py
55513cee45a3947181af7cf46d21df175056c96dfd11e8c7e8b01bf41faf6fdf

quantized_checkpoint_v23.json
16a625dc3638bda0fb24f7ed61b8c7c294c706591dccd160d74e2181f0d344c0

Meta/AI/QuantizedCertifiedAgent.lean
26ea322a39dce56c04e346f5eb9a844d332796812e6b35ba10bec21ebd375208

bundle trié des 95 modules QuantizedCertifiedAgent*.lean
2362c6948ed488c628bec498383eff808f0199ec3910001425f16eb493e40b42
```

## Portée du certificat Lean

`ValidCertifiedRun` est paramétré par l'architecture v23 exacte. Lean vérifie
les dimensions, les catalogues de classes, les bornes Int8 des paramètres et
des entrées, les bornes Int32 des accumulateurs, les 697 produits matriciels,
l'arrondi, la saturation, le masquage, l'argmax, l'égalité avec la trace
réifiée, l'absence d'erreur et la stricte positivité de chaque marge.

Les poids sont des lignes Int8 nommées, et non un blob accepté par hypothèse.
Les 697 obligations sont divisées en 88 lots de huit exemples au plus. Quatre
chaînes d'import bornent la concurrence de compilation sans dépendre d'une
option locale de Lake. Les égalités calculatoires sont prouvées par réduction
`rfl` ; `decide` ne traite que les propriétés booléennes de la trace. Le calcul
n'utilise pas `native_decide`, car ce dernier introduirait un axiome généré
incompatible avec le contrat constructif du dépôt.
