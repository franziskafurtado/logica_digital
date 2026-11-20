// Modelo de circuito combinacional; revise as equacoes.
module modelo_combinacional (
    input  logic       a, b, sel,
    output logic       y, z
);
    // Equacao direta: usa assign para funcoes simples.
    assign z = a ^ b;

    // MUX: toda saida recebe valor em qualquer caminho.
    always_comb begin
        y = 1'b0;   // valor padrao; evita latch
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
            default: y = 1'b0;
        endcase
    end
endmodule
