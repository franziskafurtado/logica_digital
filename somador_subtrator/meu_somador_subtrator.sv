`timescale 1ns/10ps

module meu_somador_subtrator(
input [2:0]A,
input [2:0]B,
input OP, // alto soma, baixo subtrai
output [3:0]Q);


assign Q = OP? A-B : A+B; 


endmodule

