// EXEMPLO COMPLEMENTAR - TRANSMISSOR UART 8E1
// Inicie um envio colocando dados em dado_entrada e pulsando enviar.
// O modulo envia START(0), D0..D7, paridade par e STOP(1).

module codificador_UART #(
    parameter integer CLKS_POR_BIT = 16
) (
    input  logic       clk,
    input  logic       reset,
    input  logic       enviar,
    input  logic [7:0] dado_entrada,
    output logic       tx,
    output logic       ocupado,
    output logic       concluido
);
    localparam integer LARGURA_CONT = (CLKS_POR_BIT <= 2) ? 1 : $clog2(CLKS_POR_BIT);

    typedef enum logic [2:0] {
        OCIOSO, START, DADOS, PARIDADE_PAR, STOP
    } estado_t;

    estado_t estado;
    logic [LARGURA_CONT-1:0] contador;
    logic [2:0] indice;
    logic [7:0] dado_reg;
    logic bit_paridade;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            estado <= OCIOSO;
            contador <= '0;
            indice <= '0;
            dado_reg <= '0;
            bit_paridade <= 1'b0;
            concluido <= 1'b0;
        end else begin
            concluido <= 1'b0;
            case (estado)
                OCIOSO: begin
                    contador <= '0;
                    if (enviar) begin
                        dado_reg <= dado_entrada;
                        bit_paridade <= ^dado_entrada;
                        indice <= '0;
                        estado <= START;
                    end
                end

                START: begin
                    if (contador == CLKS_POR_BIT - 1) begin
                        contador <= '0;
                        estado <= DADOS;
                    end else contador <= contador + 1'b1;
                end

                DADOS: begin
                    if (contador == CLKS_POR_BIT - 1) begin
                        contador <= '0;
                        if (indice == 3'd7)
                            estado <= PARIDADE_PAR;
                        else
                            indice <= indice + 1'b1;
                    end else contador <= contador + 1'b1;
                end

                PARIDADE_PAR: begin
                    if (contador == CLKS_POR_BIT - 1) begin
                        contador <= '0;
                        estado <= STOP;
                    end else contador <= contador + 1'b1;
                end

                STOP: begin
                    if (contador == CLKS_POR_BIT - 1) begin
                        contador <= '0;
                        estado <= OCIOSO;
                        concluido <= 1'b1;
                    end else contador <= contador + 1'b1;
                end

                default: estado <= OCIOSO;
            endcase
        end
    end

    always_comb begin
        tx = 1'b1; // UART fica em nivel alto quando ociosa.
        case (estado)
            START:        tx = 1'b0;
            DADOS:        tx = dado_reg[indice];
            PARIDADE_PAR: tx = bit_paridade;
            STOP:         tx = 1'b1;
            default:      tx = 1'b1;
        endcase
    end

    assign ocupado = (estado != OCIOSO);
endmodule
