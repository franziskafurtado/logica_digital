AVALIACAO PARCIAL 1 - PARTE 2 (2024) - SOLUCAO PARA ESTUDO
==========================================================
Arquivos principais pedidos no enunciado:
  sinaleira2.sv
  tb_sinaleira2.sv

ATENCAO: valores X=6 e Y=5 sao os EXEMPLOS do enunciado.
Substituir pelos dois ultimos digitos da matricula em sinaleira2.sv
ou na instancia do testbench. Se o digito for zero, vale 10.

Decisoes assumidas em pontos abertos do enunciado:
  - Reset assincrono ativo alto -> INICIO (todos vermelhos).
  - INICIO -> R1_VERDE no primeiro clock apos sair de reset.
  - As ruas sempre passam pelo AMARELO por 2 segundos.
  - Pedestre so abre depois de R2_AMARELO, se houver pedido.
  - O pedido permanece registrado durante o ciclo de veiculos.
  - Nao existem dois sinais verdes simultaneos.

Fluxo dos estados:
  INICIO -> R1_VERDE -> R1_AMARELO -> R2_VERDE -> R2_AMARELO
                                          -> PED_VERDE (se pedido)
                                          -> R1_VERDE (sem pedido)
  PED_VERDE -> R1_VERDE

No testbench, clock de 10 ns = 1 segundo LOGICO.
Nao simula 1 segundo real por bit; simula 1 ciclo por segundo.

Xcelium (na pasta dos arquivos):
  module add cdn/xcelium/xcelium2209
  xrun -64bit -sv -access +rwc -top tb_sinaleira2 \
    sinaleira2.sv tb_sinaleira2.sv
  xrun -64bit -sv -gui -access +rwc -top tb_sinaleira2 \
    sinaleira2.sv tb_sinaleira2.sv

Genus (opcional):
  genus -no_gui -files script_genus_sinaleira2.tcl
  Necessario disponibilizar a biblioteca .lib para mapeamento.

Os codigos foram revisados, mas nao executados em Xcelium neste ambiente.
O nome pedestre_verde atende a correcao tardia da pagina 3 do PDF.
