#!/usr/bin/env bash
# Exemplo de simulacao pos-sintese.
# Executar apos gerar a netlist; ajuste caminhos e nomes.
xrun -64bit -sv -access +rwc -gui \
    fast_vdd1v0_basicCells_hvt.v \
    controlador_temporizado_mapped.v \
    modelos/tb_controlador_temporizado.sv \
    -top tb_controlador_temporizado
# Para aplicar SDF, inclua $sdf_annotate no testbench (ver PDF).
