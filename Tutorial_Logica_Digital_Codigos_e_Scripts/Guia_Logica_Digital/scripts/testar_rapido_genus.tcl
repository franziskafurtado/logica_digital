# 1. Ajuste os caminhos, o nome do design e a biblioteca .lib.
read_libs fast_vdd1v0_basicCells_hvt.lib
read_hdl -sv modelos/controlador_temporizado.sv
elaborate controlador_temporizado

# 2. Se houver clock de sistema, defina o periodo e verifique unidade de tempo.
# create_clock -name clk -period 10 [get_ports clk]

# 3. Sintese generica e mapeamento para celulas.
report gates
syn_generic
syn_map
report gates
report_sequential

# 4. Sem clock definido, relatorio de caminhos nao restringidos:
report_timing -unconstrained

# 5. Exportacao da netlist mapeada e atrasos estimados.
write_netlist > controlador_temporizado_mapped.v
write_sdf > atrasos_controlador.sdf
