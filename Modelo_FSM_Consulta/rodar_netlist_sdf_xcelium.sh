#!/usr/bin/env bash
set -euo pipefail
# Ajuste este caminho conforme o laboratorio:
PDK="/home/tools/design_kits/cadence/GPDK045/gsclib045_all_v4.4"
LIB_V="$PDK/gsclib045_hvt/verilog/fast_vdd1v0_basicCells_hvt.v"

# Requer antes: Genus ter gerado fsm_generica_mapped.v e fsm_generica.sdf.
# A -lib para sintese (.lib) nao substitui o modelo Verilog (.v).
xrun -sv -access +rwc -top tb_fsm_generica_gate \
  "$LIB_V" fsm_generica_mapped.v tb_fsm_generica_gate.sv
