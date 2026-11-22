# Rodar no terminal (apos editar o caminho da biblioteca):
# genus -no_gui -files script_genus_dec_i2c.tcl

# As linhas seguintes executam dentro do Cadence Genus.
read_libs fast_vdd1v0_basicCells_hvt.lib
read_hdl -sv dec_i2c.sv
elaborate dec_i2c
check_design -unresolved
syn_generic
syn_map
report gates
report_sequential
report_timing -unconstrained
write_netlist > dec_i2c_mapped.v
write_sdf > dec_i2c_mapped.sdf
