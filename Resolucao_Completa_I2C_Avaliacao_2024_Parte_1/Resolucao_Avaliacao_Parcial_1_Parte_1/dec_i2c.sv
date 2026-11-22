`timescale 1ns/1ps

// Avaliacao parcial 1 - parte 1 (2024), questao 2
// Receptor simplificado do inicio de uma transacao I2C.
//
// Captura 7 bits de endereco (MSB primeiro), seguidos de R/W.
// START: SDA 1->0 com SCL alto.
// STOP : SDA 0->1 com SCL alto.
// Dados sao capturados na borda de subida de SCL, detectada por clk.
//
// O enunciado diverge sobre a saida stop:
//   - item da interface: sinaliza qualquer STOP;
//   - item 2.6: STOP condicionado a endereco local e escrita.
// STOP_SOMENTE_ESCRITA=1 atende ao item 2.6 (padrao).
// STOP_SOMENTE_ESCRITA=0 sinaliza qualquer STOP aceito em transacao.
//
// Premissas de exercicio: sinais de SDA/SCL sao lentos e estaveis
// frente a clk; nao implementa sincronizacao de metastabilidade,
// filtragem de spikes, ACK/NACK ou repeated START.
module dec_i2c #(
    parameter bit STOP_SOMENTE_ESCRITA = 1'b1
) (
    input  logic       clk,
    input  logic       reset,             // sincrono, ativo alto
    input  logic       sda,
    input  logic       scl,
    input  logic       pronto,            // autoriza aceitar START
    input  logic [6:0] endereco_local,
    output logic [6:0] endereco_recebido,
    output logic       operacao,          // 0 = escrita; 1 = leitura
    output logic       escrita,           // pulso clk se endereco bate e R/W=0
    output logic       stop               // pulso clk (ver parametro)
);

    typedef enum logic [1:0] {
        ESPERA_START,
        RECEBE_ENDERECO,
        RECEBE_OPERACAO,
        ESPERA_STOP
    } estado_t;

    estado_t estado;

    logic sda_anterior, scl_anterior;
    logic start_cond, stop_cond, sobe_scl;
    logic [6:0] addr_ff;
    logic [6:0] endereco_local_ff;
    logic [2:0] bits_recebidos;  // conta 0 a 6
    logic escrita_valida;      // guarda o resultado ate STOP

    // Detector de eventos: os pulsos resultam da comparacao de
    // amostras de clk consecutivas e duram um ciclo de clk.
    assign start_cond =  scl && scl_anterior &&  sda_anterior && !sda;
    assign stop_cond  =  scl && scl_anterior && !sda_anterior &&  sda;
    assign sobe_scl   =  scl && !scl_anterior;

    assign endereco_recebido = addr_ff;

    always_ff @(posedge clk) begin
        if (reset) begin
            sda_anterior     <= 1'b1; // barramento ocioso
            scl_anterior     <= 1'b1;
            estado           <= ESPERA_START;
            addr_ff          <= 7'b0;
            endereco_local_ff<= 7'b0;
            bits_recebidos   <= 3'd0;
            operacao         <= 1'b0;
            escrita_valida   <= 1'b0;
            escrita          <= 1'b0;
            stop             <= 1'b0;
        end else begin
            // Historico dos sinais externos (amostragem por clk).
            sda_anterior <= sda;
            scl_anterior <= scl;

            // Pulsos padrao de um unico ciclo.
            escrita <= 1'b0;
            stop    <= 1'b0;

            // STOP tem prioridade para encerrar uma transacao.
            if (stop_cond) begin
                if (estado == ESPERA_STOP) begin
                    if (STOP_SOMENTE_ESCRITA)
                        stop <= escrita_valida;
                    else
                        stop <= 1'b1;
                end
                estado <= ESPERA_START;

            end else if (start_cond) begin
                // So comeca se pronto=1 e se esta aguardando START.
                if ((estado == ESPERA_START) && pronto) begin
                    estado            <= RECEBE_ENDERECO;
                    bits_recebidos    <= 3'd0;
                    addr_ff           <= 7'b0;
                    endereco_local_ff <= endereco_local;
                    operacao          <= 1'b0;
                    escrita_valida    <= 1'b0;
                end

            end else if (sobe_scl) begin
                case (estado)
                    RECEBE_ENDERECO: begin
                        // Bit 6 chega primeiro. 7 deslocamentos
                        // resultam em addr_ff = {b6,...,b0}.
                        addr_ff <= {addr_ff[5:0], sda};
                        if (bits_recebidos == 3'd6) begin
                            bits_recebidos <= 3'd0;
                            estado <= RECEBE_OPERACAO;
                        end else begin
                            bits_recebidos <= bits_recebidos + 3'd1;
                        end
                    end

                    RECEBE_OPERACAO: begin
                        operacao       <= sda;
                        escrita_valida <= (addr_ff == endereco_local_ff) && !sda;
                        if ((addr_ff == endereco_local_ff) && !sda)
                            escrita <= 1'b1;
                        estado <= ESPERA_STOP;
                    end

                    default: begin
                        // Ignora bordas fora dos 8 bits esperados.
                    end
                endcase
            end
        end
    end

endmodule
