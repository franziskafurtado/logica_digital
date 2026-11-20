// EXERCICIO 4 - Gerador de paridade par (9 bits).
// Q[7:0] = A e Q[8] = XOR de todos os bits de A.
// Se EN=0, Q=0. ^A e operador XOR de reducao.
module codificador_paridade_par (
    input  logic       EN,
    input  logic [7:0] A,
    output logic [8:0] Q
);
    assign Q = EN ? {(^A), A} : 9'b000000000;
endmodule
