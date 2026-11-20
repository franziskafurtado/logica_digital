// EXERCICIO 2 - Entrada binaria 2 bits -> saida one-hot 4 bits.
// Tabela: 00->0001, 01->0010, 10->0100, 11->1000.
module codificador_onehot (
    input  logic [1:0] A,
    output logic [3:0] X
);
    always_comb begin
        case (A)
            2'b00: X = 4'b0001;
            2'b01: X = 4'b0010;
            2'b10: X = 4'b0100;
            2'b11: X = 4'b1000;
            default: X = 4'b0000;
        endcase
    end
endmodule
