#!/usr/bin/env bash
set -euo pipefail
# Execute nesta pasta; precisa de Xcelium instalado e configurado.
module add cdn/xcelium/xcelium2209 2>/dev/null || true
xrun -sv -access +rwc -top tb_fsm_generica \
  fsm_generica.sv tb_fsm_generica.sv
