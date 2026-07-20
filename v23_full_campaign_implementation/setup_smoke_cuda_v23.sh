#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
smoke_environment="${V23_SMOKE_VENV:-${script_directory}/.venv-smoke-cuda}"

python3 -m venv "${smoke_environment}"
"${smoke_environment}/bin/python" -m pip install --upgrade pip setuptools wheel
"${smoke_environment}/bin/python" -m pip install \
  --requirement "${script_directory}/requirements-smoke-cuda.txt"
"${smoke_environment}/bin/python" -m pip install --no-deps --editable "${script_directory}"

"${smoke_environment}/bin/python" -c \
  'import torch; assert torch.cuda.is_available(); print(torch.__version__, torch.version.cuda, torch.cuda.get_device_name(0))'
