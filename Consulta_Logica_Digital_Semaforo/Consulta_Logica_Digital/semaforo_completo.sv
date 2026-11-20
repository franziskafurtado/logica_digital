// Exercicio sugerido 2 - Semaforo completo (FSM Moore)
// Hipoteses explicitas para lacunas do enunciado:
// - A segunda duracao de VERDE (30 s) e da Rua 2, nao da Rua 1.
// - Amarelo dura 3 segundos em cada rua (ajustavel por parametro).
// - Pedestre e atendido depois da fase da Rua 2, quando houver pedido.
// - clk de 1 Hz: cada borda de subida representa um segundo.
// - Todas as duracoes parametrizadas devem ser >= 1.
module semaforo_completo #(
    parameter integer T_R1_VERDE = 20,
    parameter integer T_R2_VERDE = 30,
    parameter integer T_AMARELO  = 3,
    parameter integer T_PEDESTRE = 15
) (
    input  logic clk,
    input  logic reset,               // Assincrono, ativo em nivel alto
    input  logic pedestre,            // Pedido de travessia

    output logic rua_1_vermelho,
    output logic rua_1_amarelo,
    output logic rua_1_verde,
    output logic rua_2_vermelho,
    output logic rua_2_amarelo,
    output logic rua_2_verde,
    output logic pedestre_vermelho,
    output logic pedestre_2_verde    // Nome usado no enunciado
);

    typedef enum logic [2:0] {
        INICIO,
        R1_VERDE,
        R1_AMARELO,
        R2_VERDE,
        R2_AMARELO,
        PED_VERDE
    } estado_t;

    estado_t estado, proximo_estado;

    // Contador compartilhado entre os estados.
    localparam integer MAX_RUAS = (T_R1_VERDE > T_R2_VERDE)
                                  ? T_R1_VERDE : T_R2_VERDE;
    localparam integer MAX_OUTROS = (T_AMARELO > T_PEDESTRE)
                                    ? T_AMARELO : T_PEDESTRE;
    localparam integer MAX_TEMPO = (MAX_RUAS > MAX_OUTROS)
                                   ? MAX_RUAS : MAX_OUTROS;
    localparam integer LARGURA_CONTADOR = (MAX_TEMPO > 1)
                                         ? $clog2(MAX_TEMPO) : 1;

    logic [LARGURA_CONTADOR-1:0] contador;
    logic fim_tempo;
    logic pedido_pendente;

    // 1) Verifica se a permanencia no estado terminou.
    // O contador comeca em 0. Se T=20, os valores 0..19
    // correspondem a 20 ciclos completos nesse estado.
    always_comb begin
        fim_tempo = 1'b0;
        case (estado)
            INICIO:     fim_tempo = 1'b1;
            R1_VERDE:   fim_tempo = (contador == T_R1_VERDE - 1);
            R1_AMARELO: fim_tempo = (contador == T_AMARELO  - 1);
            R2_VERDE:   fim_tempo = (contador == T_R2_VERDE - 1);
            R2_AMARELO: fim_tempo = (contador == T_AMARELO  - 1);
            PED_VERDE:  fim_tempo = (contador == T_PEDESTRE - 1);
            default:    fim_tempo = 1'b0;
        endcase
    end

    // 2) Logica do proximo estado.
    always_comb begin
        proximo_estado = estado;

        case (estado)
            INICIO:
                proximo_estado = R1_VERDE;

            R1_VERDE:
                if (fim_tempo) proximo_estado = R1_AMARELO;

            R1_AMARELO:
                if (fim_tempo) proximo_estado = R2_VERDE;

            R2_VERDE:
                if (fim_tempo) proximo_estado = R2_AMARELO;

            R2_AMARELO:
                if (fim_tempo) begin
                    if (pedido_pendente || pedestre)
                        proximo_estado = PED_VERDE;
                    else
                        proximo_estado = R1_VERDE;
                end

            PED_VERDE:
                if (fim_tempo) proximo_estado = R1_VERDE;

            default:
                proximo_estado = INICIO;
        endcase
    end

    // 3) Registradores: estado, contador e memoria do pedido.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            estado          <= INICIO;
            contador        <= '0;
            pedido_pendente <= 1'b0;
        end else begin
            estado <= proximo_estado;

            if (estado != proximo_estado)
                contador <= '0;              // Reinicia a cada transicao
            else if (estado != INICIO)
                contador <= contador + 1'b1;
            else
                contador <= '0;

            if (estado == PED_VERDE && fim_tempo)
                pedido_pendente <= 1'b0;     // Pedido foi atendido
            else if (pedestre)
                pedido_pendente <= 1'b1;     // Memoriza pulso de pedido
        end
    end

    // 4) Saidas Moore: dependem somente do estado atual.
    // Padrao seguro: os tres sinais vermelhos ligados.
    always_comb begin
        rua_1_vermelho   = 1'b1;
        rua_1_amarelo    = 1'b0;
        rua_1_verde      = 1'b0;
        rua_2_vermelho   = 1'b1;
        rua_2_amarelo    = 1'b0;
        rua_2_verde      = 1'b0;
        pedestre_vermelho = 1'b1;
        pedestre_2_verde  = 1'b0;

        case (estado)
            R1_VERDE: begin
                rua_1_vermelho = 1'b0;
                rua_1_verde = 1'b1;
            end
            R1_AMARELO: begin
                rua_1_vermelho = 1'b0;
                rua_1_amarelo = 1'b1;
            end
            R2_VERDE: begin
                rua_2_vermelho = 1'b0;
                rua_2_verde = 1'b1;
            end
            R2_AMARELO: begin
                rua_2_vermelho = 1'b0;
                rua_2_amarelo = 1'b1;
            end
            PED_VERDE: begin
                pedestre_vermelho = 1'b0;
                pedestre_2_verde = 1'b1;
            end
            default: begin
                // INICIO: todos vermelhos, inclusive pedestres.
            end
        endcase
    end
endmodule
