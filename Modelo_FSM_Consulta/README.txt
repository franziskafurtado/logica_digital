TEMPLATE DE FSM + TB + GENUS/XCELIUM
=================================
1) fsm_generica.sv: FSM sintetizavel ESPERA -> EXECUTA -> FINALIZA.
   Alterar estados, duracoes, sinais, condicionais conforme o enunciado.
   TEMPO_CICLOS deve ser >= 1.

2) tb_fsm_generica.sv: TB autoverificavel de RTL. Para testar:
   xrun -sv -access +rwc -top tb_fsm_generica fsm_generica.sv tb_fsm_generica.sv
   E importante nao adicionar tb ao read_hdl do Genus.

3) script_genus.tcl: edite LIB_PATH para o arquivo .lib do laboratorio.
   Depois:
   genus -no_gui -files script_genus.tcl
   Gerara netlist e SDF para a versao mapeada.

4) tb_fsm_generica_gate.sv: visualizacao da netlist com atrasos SDF.
   Use a biblioteca Verilog .v das celulas padrao, NAO o .lib:
   xrun -sv -access +rwc -top tb_fsm_generica_gate \
     /CAMINHO/fast_vdd1v0_basicCells_hvt.v \
     fsm_generica_mapped.v tb_fsm_generica_gate.sv
   Veja sdf_annotation.log. Ajuste caminho, top, hierarquia e nome
   do modulo se a netlist gerada diferir.

5) Saidas em estado FINALIZA sao Moore; pulso_fim fica em 1 durante
   somente um ciclo de clk.

6) Temporizacao de 4 CICLOS nao significa 4 segundos: o tempo fisico
   depende da frequencia do clock implementado. TB usa periodo de 10 ns.

OBSERVACOES
- Os arquivos foram criados para consulta offline e nao foram simulados
  em Genus/Xcelium nesta sessao (ferramentas indisponiveis neste ambiente).
- Este modelo assume entradas ja sincronizadas ao clock. Para botoes ou
  entradas assincronas, considere sincronizadores e tratamento de ruido.
- Em simulacao com SDF, um ciclo de 10 ns pode ser curto demais para
  certos caminhos e atrasos. Ajuste a frequencia de teste se necessario.
