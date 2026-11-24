// ================================================================
// TEMPLATE: FSM Moore temporizada e sintetizavel (SystemVerilog)
// Estados: ESPERA -> EXECUTA -> FINALIZA -> ESPERA
// Exemplo: start inicia trabalho por TEMPO_CICLOS ciclos.
//          pulso_fim fica em 1 por exatamente um ciclo.
// OBS: substitua os estados, tempos e saidas para seu exercicio.
// ================================================================
module fsm_generica #(
    parameter int TEMPO_CICLOS = 4  // deve ser >= 1
) (
    input  logic clk,
    input  logic reset,       // reset assincrono, ativo alto
    input  logic start,
    output logic pronto,     // 1 enquanto aguarda um novo start
    output logic ocupado,    // 1 enquanto esta em EXECUTA
    output logic pulso_fim   // 1 por um ciclo em FINALIZA
);

    // Quantidade minima de bits para contar TEMPO_CICLOS.
    // Protege o caso TEMPO_CICLOS == 1 (nao cria vetor [ -1:0 ]).
    localparam int N_BITS = (TEMPO_CICLOS <= 1)
                           ? 1 : $clog2(TEMPO_CICLOS);
    localparam logic [N_BITS-1:0] ULTIMO = TEMPO_CICLOS - 1;

    logic [N_BITS-1:0] contador;

    // BLOCO 0: declarar estados e registradores de estado.
    typedef enum logic [1:0] {
        ESPERA   = 2'b00,
        EXECUTA  = 2'b01,
        FINALIZA = 2'b10
    } estado_t;

    estado_t estado, proximo_estado;

    // BLOCO 1: registrador de estado (flip-flops D).
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            estado <= ESPERA;
        else
            estado <= proximo_estado;
    end

    // BLOCO 2: contador sequencial.
    // Zera ao entrar/sair de EXECUTA; so conta enquanto
    // EXECUTA permanece ativo. Conta de 0 ate ULTIMO.
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            contador <= '0;
        else if (estado != EXECUTA || proximo_estado != EXECUTA)
            contador <= '0;
        else
            contador <= contador + 1'b1;
    end

    // BLOCO 3: proximo estado (logica combinacional).
    // Sempre definir valor padrao para evitar latch.
    always_comb begin
        proximo_estado = estado;

        case (estado)
            ESPERA: begin
                if (start)
                    proximo_estado = EXECUTA;
            end

            EXECUTA: begin
                if (contador == ULTIMO)
                    proximo_estado = FINALIZA;
            end

            FINALIZA: begin
                proximo_estado = ESPERA;
            end

            default: proximo_estado = ESPERA;
        endcase
    end

    // BLOCO 4: saidas Moore (dependem apenas do estado).
    // Atribuir TODAS as saidas em TODOS os caminhos.
    always_comb begin
        pronto    = 1'b0;
        ocupado   = 1'b0;
        pulso_fim = 1'b0;

        case (estado)
            ESPERA:   pronto    = 1'b1;
            EXECUTA:  ocupado   = 1'b1;
            FINALIZA: pulso_fim = 1'b1;
            default: ; // mantem todos os sinais em 0
        endcase
    end

endmodule
