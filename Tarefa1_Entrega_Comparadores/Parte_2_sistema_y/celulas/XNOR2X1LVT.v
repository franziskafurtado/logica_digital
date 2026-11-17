`timescale 1ns/10ps

module XNOR2X1LVT (
    output wire Y,
    input  wire A, B
);
    // Function: saida 1 quando as entradas sao iguais.
    assign Y = ~(A ^ B);

endmodule
