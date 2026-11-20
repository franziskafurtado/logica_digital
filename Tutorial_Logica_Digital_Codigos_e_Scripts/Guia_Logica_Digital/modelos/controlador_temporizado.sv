// MODELO: controlador por FSM + contador (SystemVerilog sintetizavel)
// Requisitos: ao receber start em ESPERA, ativa busy por N ciclos;
// em seguida, gera done por 1 ciclo e volta a ESPERA.
// Clock: borda de subida. Reset: sincrono e ativo em 1.
module controlador_temporizado #(
    parameter integer N = 4                  // Exigir N >= 1
) (
    input  logic clk,
    input  logic reset,
    input  logic start,
    output logic busy,
    output logic done
);
    // $clog2 calcula quantos bits o contador precisa.
    localparam integer W = (N > 1) ? $clog2(N) : 1;
    logic [W-1:0] contador;

    typedef enum logic [1:0] { ESPERA, EXECUTA, FINALIZA } estado_t;
    estado_t estado, proximo_estado;

    // 1) Registradores: <= e borda de clock; reset sincrono.
    always_ff @(posedge clk) begin
        if (reset) begin
            estado   <= ESPERA;
            contador <= '0;
        end else begin
            estado <= proximo_estado;
            if (estado != EXECUTA || proximo_estado != EXECUTA)
                contador <= '0;
            else
                contador <= contador + 1'b1;
        end
    end

    // 2) Logica de transicao: valores padrao evitam latch.
    always_comb begin
        proximo_estado = estado;
        case (estado)
            ESPERA:   if (start)            proximo_estado = EXECUTA;
            EXECUTA:  if (contador == N - 1) proximo_estado = FINALIZA;
            FINALIZA:                       proximo_estado = ESPERA;
            default:                        proximo_estado = ESPERA;
        endcase
    end

    // 3) Saidas Moore: dependem somente do estado.
    always_comb begin
        busy = (estado == EXECUTA);
        done = (estado == FINALIZA);
    end
endmodule
