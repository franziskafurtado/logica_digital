// EXERCICIO 3 - Soma/subtracao de operandos SIGNED de 3 bits.
// OP=1: Q=A+B. OP=0: Q=A-B.
// IMPORTANTE: logic [2:0] sem 'signed' e UNSIGNED no SV.
// A e B em complemento de 2 variam de -4 a +3.
// Q signed de 4 bits comporta resultado de -8 ate +7.
module ula_soma_sub (
    input  logic              OP,
    input  logic signed [2:0] A,
    input  logic signed [2:0] B,
    output logic signed [3:0] Q
);
    logic signed [3:0] A_ext, B_ext;

    always_comb begin
        A_ext = {A[2], A};  // Extensao do bit de sinal.
        B_ext = {B[2], B};
        if (OP)
            Q = A_ext + B_ext;
        else
            Q = A_ext - B_ext;
    end
endmodule
