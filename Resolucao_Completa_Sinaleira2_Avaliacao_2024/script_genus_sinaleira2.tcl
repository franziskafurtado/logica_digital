# Ajustar o caminho da biblioteca conforme o laboratorio.
read_libs fast_vdd1v0_basicCells_hvt.lib
read_hdl -sv sinaleira2.sv
elaborate sinaleira2
report gates
syn_generic
syn_map
report gates
report_sequential
report_timing -unconstrained
write_netlist > sinaleira2_mapped.v
write_sdf > sinaleira2_atrasos.sdf
