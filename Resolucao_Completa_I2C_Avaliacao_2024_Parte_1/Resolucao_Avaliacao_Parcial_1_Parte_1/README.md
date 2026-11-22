# Resolução comentada — Avaliação Parcial 1, Parte 1 (2024)

Material de **estudo de uma avaliação antiga e concluída**. Não corresponde à execução do exame nem ao testbench `tb_i2c.sv` mencionado no PDF (não foi fornecido).

## Arquivos

- `respostas_questao_1.txt` — respostas à questão teórica CMOS.
- `dec_i2c.sv` — design sintetizável, sincronizado por `clk=10 ns`.
- `tb_dec_i2c.sv` — testbench autoral para exercícios de estudo.
- `COMANDOS_XCELIUM.txt` — instruções de compilação e simulação.
- `script_genus_dec_i2c.tcl` — síntese: atualizar o caminho de `fast_vdd1v0_basicCells_hvt.lib`.
- `Resolucao_Comentada_Avaliacao_Parte_1.pdf` — resolução com explicações e código copiável.

## Regra importante: saída `stop`

O PDF apresenta duas descrições diferentes: no item de interface, `stop` indica a condição física STOP; no item 2.6, ele é condicionado à escrita do endereço local. Foi adotada a segunda interpretação por padrão (`STOP_SOMENTE_ESCRITA=1`). Para pulsar em qualquer STOP de transação aceita, instancie com `STOP_SOMENTE_ESCRITA=0`. A solução não gera `stop` para um pulso STOP sem uma transação previamente iniciada/recebida.

## Premissas e limitações

- `reset` é **síncrono** e ativo alto (não especificado como assíncrono).
- `pronto` é uma autorização para começar uma transação no estado de espera.
- `escrita` pulsa na 8a borda de subida de `SCL` de uma transação de endereço local com R/W=0.
- Captura somente a fase START + 7 bits de endereço + R/W + STOP.
- Não implementa ACK/NACK, dados, sincronização de entradas assíncronas (metastabilidade), filtros de glitch ou repetição de START.
- Os sinais `scl`/`sda` devem permanecer estáveis em relação ao clock de amostragem de 10ns; simulação assume SCL com período de 100ns.
- O arquivo ainda precisa ser compilado e executado no Xcelium. Não há simulador Verilog instalado neste ambiente.
