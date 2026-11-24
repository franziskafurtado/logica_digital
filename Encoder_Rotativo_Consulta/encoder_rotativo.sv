// Encoder rotativo em quadratura: um passo por ciclo completo.
// Sentido A: ab = 00 -> 10 -> 11 -> 01 -> 00
// Sentido B: ab = 00 -> 01 -> 11 -> 10 -> 00
// Exemplo para estudo: as entradas a/b devem permanecer estaveis por
// tempo suficiente para serem amostradas no clock.
// Em hardware real, sincronizar os canais ao dominio de clk e considerar
// filtragem de ruído/bounce antes de alimentar este modulo.

module encoder_rotativo (
    input  logic clk,
    input  logic reset,       // Reset assincrono, ativo em 1
    input  logic a,
    input  logic b,
    output logic passo_a,     // 1 ciclo quando completa uma sequencia A
    output logic passo_b,     // 1 ciclo quando completa uma sequencia B
    output logic volta_a,     // 1 ciclo ao atingir 16 passos liquidos A
    output logic volta_b      // 1 ciclo ao atingir 16 passos liquidos B
);

    // Representa o par amostrado na ordem a,b.
    logic [1:0] ab;
    assign ab = {a, b};

    // Estados das 3 etapas intermediarias em cada sentido.
    // INVALIDO descarta sequencias incorretas ate voltar ao repouso 00.
    typedef enum logic [2:0] {
        REPOUSO = 3'd0,
        A1      = 3'd1,  // 10
        A2      = 3'd2,  // 11, vindo de 10
        A3      = 3'd3,  // 01, vindo de 11
        B1      = 3'd4,  // 01
        B2      = 3'd5,  // 11, vindo de 01
        B3      = 3'd6,  // 10, vindo de 11
        INVALIDO = 3'd7
    } state_t;

    state_t state, next_state;

    // Faixa util: -15 a +15. O 16o passo no mesmo sentido emite
    // 'volta' e reinicia o saldo. 6 bits com sinal sao suficientes.
    logic signed [5:0] saldo;

    // Eventos combinacionais: indicam uma sequencia completa no
    // ciclo atual; serao registrados no always_ff abaixo.
    logic fim_passo_a, fim_passo_b;

    // 1) Logica combinacional de transicao e detecao de passo.
    always_comb begin
        next_state  = state;
        fim_passo_a = 1'b0;
        fim_passo_b = 1'b0;

        case (state)
            REPOUSO: begin
                case (ab)
                    2'b00: next_state = REPOUSO;
                    2'b10: next_state = A1;
                    2'b01: next_state = B1;
                    default: next_state = INVALIDO; // 11: transicao saltada
                endcase
            end

            A1: begin
                case (ab)
                    2'b10: next_state = A1;      // Mantem o nivel
                    2'b11: next_state = A2;      // Etapa esperada
                    2'b00: next_state = REPOUSO; // Voltou sem completar
                    default: next_state = INVALIDO;
                endcase
            end

            A2: begin
                case (ab)
                    2'b11: next_state = A2;
                    2'b01: next_state = A3;
                    2'b00: next_state = REPOUSO; // Saltou etapa
                    default: next_state = INVALIDO;
                endcase
            end

            A3: begin
                case (ab)
                    2'b01: next_state = A3;
                    2'b00: begin
                        next_state  = REPOUSO;
                        fim_passo_a = 1'b1; // 00->10->11->01->00 completo
                    end
                    default: next_state = INVALIDO;
                endcase
            end

            B1: begin
                case (ab)
                    2'b01: next_state = B1;
                    2'b11: next_state = B2;
                    2'b00: next_state = REPOUSO;
                    default: next_state = INVALIDO;
                endcase
            end

            B2: begin
                case (ab)
                    2'b11: next_state = B2;
                    2'b10: next_state = B3;
                    2'b00: next_state = REPOUSO;
                    default: next_state = INVALIDO;
                endcase
            end

            B3: begin
                case (ab)
                    2'b10: next_state = B3;
                    2'b00: begin
                        next_state  = REPOUSO;
                        fim_passo_b = 1'b1; // 00->01->11->10->00 completo
                    end
                    default: next_state = INVALIDO;
                endcase
            end

            INVALIDO: begin
                // Nao recomeça no meio de um ciclo incompleto.
                if (ab == 2'b00)
                    next_state = REPOUSO;
            end

            default: next_state = REPOUSO;
        endcase
    end

    // 2) Logica sequencial: estado, pulsos e contagem liquida.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= REPOUSO;
            saldo   <= 6'sd0;
            passo_a <= 1'b0;
            passo_b <= 1'b0;
            volta_a <= 1'b0;
            volta_b <= 1'b0;
        end else begin
            state <= next_state;

            // Pulsos com duracao EXATA de um ciclo de clock.
            passo_a <= fim_passo_a;
            passo_b <= fim_passo_b;
            volta_a <= 1'b0;
            volta_b <= 1'b0;

            if (fim_passo_a) begin
                if (saldo == 6'sd15) begin
                    saldo   <= 6'sd0;
                    volta_a <= 1'b1;    // 16o passo liquido A
                end else begin
                    saldo <= saldo + 6'sd1;
                end
            end else if (fim_passo_b) begin
                if (saldo == -6'sd15) begin
                    saldo   <= 6'sd0;
                    volta_b <= 1'b1;    // 16o passo liquido B
                end else begin
                    saldo <= saldo - 6'sd1;
                end
            end
            // Sem passo: saldo mantido pelo proprio flip-flop.
        end
    end

endmodule
