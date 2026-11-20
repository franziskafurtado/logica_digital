# USO: genus -no_gui -files script_genus_exemplo.tcl
# Ajuste os caminhos da LIB e do RTL e o modulo de topo.
# GPDK045: a LIB .lib e destinada a SINTESE; a .v, a SIMULACAO.
set LIB fast_vdd1v0_basicCells_hvt.lib
set RTL ula_soma_sub.sv
set TOP ula_soma_sub

read_libs $LIB
read_hdl -sv $RTL
elaborate $TOP

# Opcional, somente em circuitos com clock e conforme a interface:
# create_clock -name clk -period 10 [get_ports clk]

report gates
syn_generic
syn_map
report gates
report_sequential
report_timing -unconstrained

write_netlist > ${TOP}_mapped.v
write_sdf > ${TOP}_atrasos.sdf
