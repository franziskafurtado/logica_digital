# Executar: genus -no_gui -files script_genus.tcl
# Ajuste o caminho da biblioteca Liberty e o nome do design.
read_libs fast_vdd1v0_basicCells_hvt.lib
read_hdl -sv modelos/controlador_temporizado.sv
elaborate controlador_temporizado

# Opcional: defina um clock de 10 ns quando fizer sentido.
# create_clock -name clk -period 10 [get_ports clk]

report gates
syn_generic
syn_map
report gates
report_sequential
report_timing -unconstrained
write_netlist > controlador_temporizado_mapped.v
write_sdf > atrasos_controlador.sdf
