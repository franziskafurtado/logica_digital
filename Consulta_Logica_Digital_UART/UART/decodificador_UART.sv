// EXERCICIO SUGERIDO 3 - RECEPTOR UART 8E1
// 8 bits de dados, paridade PAR, 1 bit de parada, LSB primeiro.
// A entrada rx e assincrona em relacao ao clk: dois FFs a sincronizam.
// Cada bit dura CLKS_POR_BIT ciclos de clk (use >= 8).
//
// Semantica das saidas:
//   dados    = ultimo byte recebido (inclusive de quadro com erro)
//   paridade = 1 se o bit de paridade do ultimo quadro estava correto
//   dv       = pulso de UM ciclo somente se paridade e stop estiverem corretos
//
// Exemplo: clk de 16 MHz e baud rate de 1 Mbit/s => CLKS_POR_BIT = 16.

module decodificador_UART #(
    parameter integer CLKS_POR_BIT = 16
) (
    input  logic       clk,
    input  logic       reset,       // Reset assincrono, ativo alto
    input  logic       rx,          // Linha serial UART (ociosa em 1)
    output logic [7:0] dados,
    output logic       paridade,
    output logic       dv
);

    localparam integer LARGURA_CONT = (CLKS_POR_BIT <= 2) ? 1 : $clog2(CLKS_POR_BIT);
    localparam integer MEIO_BIT = CLKS_POR_BIT / 2;

    typedef enum logic [2:0] {
        ESPERA,
        INICIO,
        RECEBE_DADOS,
        VERIFICA_PARIDADE,
        VERIFICA_PARADA
    } estado_t;

    estado_t estado;
    logic [LARGURA_CONT-1:0] contador;
    logic [2:0] indice;
    logic [7:0] dados_temp;
    logic paridade_temp;
    logic rx_meta, rx_sync;

    // Sincronizador de dois estagios para a entrada serial.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            estado        <= ESPERA;
            contador      <= '0;
            indice        <= '0;
            dados_temp    <= '0;
            paridade_temp <= 1'b0;
            dados         <= '0;
            paridade      <= 1'b0;
            dv            <= 1'b0;
        end else begin
            dv <= 1'b0; // Por padrao, dv e 0. So e 1 durante um clock.

            case (estado)
                ESPERA: begin
                    contador <= '0;
                    indice <= '0;
                    if (rx_sync == 1'b0)
                        estado <= INICIO;
                end

                // Confirma o start bit no meio do seu intervalo.
                // Isso ajuda a rejeitar pulsos curtos (ruido).
                INICIO: begin
                    if (contador == MEIO_BIT - 1) begin
                        contador <= '0;
                        if (rx_sync == 1'b0)
                            estado <= RECEBE_DADOS;
                        else
                            estado <= ESPERA;
                    end else begin
                        contador <= contador + 1'b1;
                    end
                end

                // Amostra D0, D1, ..., D7, com CLKS_POR_BIT ciclos
                // entre amostragens, aproximadamente no centro do bit.
                RECEBE_DADOS: begin
                    if (contador == CLKS_POR_BIT - 1) begin
                        contador <= '0;
                        dados_temp[indice] <= rx_sync;
                        if (indice == 3'd7) begin
                            indice <= '0;
                            estado <= VERIFICA_PARIDADE;
                        end else begin
                            indice <= indice + 1'b1;
                        end
                    end else begin
                        contador <= contador + 1'b1;
                    end
                end

                // Para paridade PAR: bit de paridade = XOR dos 8 dados.
                // Ex.: dados 8'h03 (dois bits 1) -> paridade esperada 0.
                VERIFICA_PARIDADE: begin
                    if (contador == CLKS_POR_BIT - 1) begin
                        contador <= '0;
                        paridade_temp <= (rx_sync == (^dados_temp));
                        estado <= VERIFICA_PARADA;
                    end else begin
                        contador <= contador + 1'b1;
                    end
                end

                // Ultimo bit (stop) deve ser 1.
                VERIFICA_PARADA: begin
                    if (contador == CLKS_POR_BIT - 1) begin
                        contador <= '0;
                        dados <= dados_temp;
                        paridade <= paridade_temp;
                        if (rx_sync && paridade_temp)
                            dv <= 1'b1;
                        estado <= ESPERA;
                    end else begin
                        contador <= contador + 1'b1;
                    end
                end

                default: begin
                    estado <= ESPERA;
                    contador <= '0;
                end
            endcase
        end
    end
endmodule
