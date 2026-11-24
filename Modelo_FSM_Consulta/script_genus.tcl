# ================================================================
# TEMPLATE DE SINTESE LOGICA - Cadence Genus / GPDK045
# Execute da pasta que contem fsm_generica.sv.
# Ajuste o caminho da biblioteca .lib do seu laboratorio.
# ================================================================
set PDK_DIR "/home/tools/design_kits/cadence/GPDK045/gsclib045_all_v4.4"
set LIB_PATH "$PDK_DIR/gsclib045_hvt/timing/fast_vdd1v0_basicCells_hvt.lib"

# 1) Le a caracterizacao tecnologica das celulas (LIBERTY).
read_libs $LIB_PATH

# 2) Le RTL (NAO leia o arquivo de testbench aqui).
read_hdl -sv fsm_generica.sv

# 3) Define o topo e gera a estrutura interna do design.
elaborate fsm_generica

# 4) Exemplo opcional de restricao de clock (10 ns).
#    Adeque o periodo e confirme unidade da ferramenta.
# create_clock -name clk_ref -period 10 [get_ports clk]

# 5) Relatorio inicial e sintese/mapeamento tecnologico.
report gates > relatorio_pre_mapeamento.txt
syn_generic
syn_map

# 6) Relatorios apos mapeamento.
report gates > relatorio_portas.txt
report_sequential > relatorio_sequencial.txt
report_timing -unconstrained > relatorio_timing_sem_restricoes.txt

# Para analise de timing com clock restrito, descomente
# create_clock acima e consulte 'report_timing'.
# report_timing > relatorio_timing_com_clock.txt

# 7) Exporta netlist mapeada e atrasos estimados.
write_netlist > fsm_generica_mapped.v
write_sdf > fsm_generica.sdf

# Na GUI (nao em -no_gui), opcional:
# gui_show
