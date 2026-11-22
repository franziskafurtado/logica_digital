// ================================================================
// DELCPG010 - Logica Digital | Avaliacao parcial 1 - parte 2 (2024)
// Resolucao para ESTUDO de uma avaliacao anterior.
//
// FSM Moore: sinaleira para duas ruas + faixa de pedestres.
//
// PARAMETROS:
//   X = ultimo digito da matricula (se 0, usar 10).
//   Y = penultimo digito da matricula (se 0, usar 10).
//   Os valores 6 e 5 sao apenas o EXEMPLO do enunciado.
//
// REGRAS:
//   - Rua 1 verde: X segundos.
//   - Rua 2 verde: Y segundos.
//   - Cada amarelo: 2 segundos.
//   - Pedestre verde: 5 segundos, quando houver pedido.
//   - Um unico contador para todos os estados.
//   - Nunca dois sinais verdes simultaneamente.
//
// DECISOES DE PROJETO (permitidas pelo enunciado):
//   - Reset assincrono, ativo em nivel alto.
//   - Estado INICIO: todas as luzes vermelhas; vai para R1_VERDE
//     no proximo flanco positivo do clock apos desativar reset.
//   - Pedido de pedestre fica memorizado e e atendido ao final
//     do ciclo das duas ruas, depois de R2_AMARELO.
//   - Novo pedido durante PED_VERDE e ignorado ate a saida desse
//     estado; se pedestre ficar alto, e lido como novo pedido
//     quando o proximo ciclo comecar.
//   - Clock de 1 Hz: cada ciclo corresponde a 1 segundo.
// ================================================================

module sinaleira2 #(
    parameter integer X = 6,
    parameter integer Y = 5
) (
    input  logic clk,
    input  logic reset,
    input  logic pedestre,

    output logic rua_1_vermelho,
    output logic rua_1_amarelo,
    output logic rua_1_verde,

    output logic rua_2_vermelho,
    output logic rua_2_amarelo,
    output logic rua_2_verde,

    output logic pedestre_vermelho,
    output logic pedestre_verde
);

    // Regra do enunciado: um digito zero representa 10 segundos.
    localparam integer TEMPO_R1 = (X == 0) ? 10 : X;
    localparam integer TEMPO_R2 = (Y == 0) ? 10 : Y;
    localparam integer TEMPO_AMARELO = 2;
    localparam integer TEMPO_PEDESTRE = 5;

    // Com X e Y entre 1 e 10, 4 bits contam de 0 ate 9.
    logic [3:0] contador;
    logic pedido_pendente;

    typedef enum logic [2:0] {
        INICIO,
        R1_VERDE,
        R1_AMARELO,
        R2_VERDE,
        R2_AMARELO,
        PED_VERDE
    } estado_t;

    estado_t estado, proximo_estado;

    // 1) Logica combinacional de transicao de estados.
    //    Contador comeca em 0: N segundos terminam em N-1.
    always_comb begin
        proximo_estado = estado;

        case (estado)
            INICIO: begin
                proximo_estado = R1_VERDE;
            end

            R1_VERDE: begin
                if (contador == TEMPO_R1 - 1)
                    proximo_estado = R1_AMARELO;
            end

            R1_AMARELO: begin
                if (contador == TEMPO_AMARELO - 1)
                    proximo_estado = R2_VERDE;
            end

            R2_VERDE: begin
                if (contador == TEMPO_R2 - 1)
                    proximo_estado = R2_AMARELO;
            end

            R2_AMARELO: begin
                if (contador == TEMPO_AMARELO - 1) begin
                    if (pedido_pendente || pedestre)
                        proximo_estado = PED_VERDE;
                    else
                        proximo_estado = R1_VERDE;
                end
            end

            PED_VERDE: begin
                if (contador == TEMPO_PEDESTRE - 1)
                    proximo_estado = R1_VERDE;
            end

            default: begin
                proximo_estado = INICIO;
            end
        endcase
    end

    // 2) Estado atual, temporizador e memoria do pedido.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            estado           <= INICIO;
            contador         <= 4'd0;
            pedido_pendente  <= 1'b0;
        end else begin
            estado <= proximo_estado;

            // Contador unico: reinicia toda vez que muda de estado.
            if (estado != proximo_estado)
                contador <= 4'd0;
            else
                contador <= contador + 1'b1;

            // Memoriza pedido, mesmo se for um pulso curto.
            if (estado == PED_VERDE)
                pedido_pendente <= 1'b0;
            else if (pedestre)
                pedido_pendente <= 1'b1;
        end
    end

    // 3) Saidas Moore: dependem SOMENTE do estado atual.
    //    Padrao seguro: ambas as ruas e pedestres em vermelho.
    always_comb begin
        rua_1_vermelho   = 1'b1;
        rua_1_amarelo    = 1'b0;
        rua_1_verde      = 1'b0;

        rua_2_vermelho   = 1'b1;
        rua_2_amarelo    = 1'b0;
        rua_2_verde      = 1'b0;

        pedestre_vermelho = 1'b1;
        pedestre_verde    = 1'b0;

        case (estado)
            R1_VERDE: begin
                rua_1_vermelho = 1'b0;
                rua_1_verde    = 1'b1;
            end

            R1_AMARELO: begin
                rua_1_vermelho = 1'b0;
                rua_1_amarelo  = 1'b1;
            end

            R2_VERDE: begin
                rua_2_vermelho = 1'b0;
                rua_2_verde    = 1'b1;
            end

            R2_AMARELO: begin
                rua_2_vermelho = 1'b0;
                rua_2_amarelo  = 1'b1;
            end

            PED_VERDE: begin
                pedestre_vermelho = 1'b0;
                pedestre_verde    = 1'b1;
            end

            default: begin
                // INICIO: todas as luzes permanecem vermelhas.
            end
        endcase
    end

endmodule
