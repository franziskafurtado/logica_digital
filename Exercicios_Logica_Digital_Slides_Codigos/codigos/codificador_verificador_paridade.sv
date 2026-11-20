// EXERCICIO 5 - Gerador + verificador de paridade par.
// ENP controla Q; ENV controla E independentemente de ENP.
// P e bit de paridade recebido; E=1 em caso de erro.
module codificador_verificador_paridade (
    input  logic       ENP,
    input  logic       ENV,
    input  logic [7:0] A,
    input  logic       P,
    output logic [8:0] Q,
    output logic       E
);
    assign Q = ENP ? {(^A), A} : 9'b0;
    assign E = ENV ? ((^A) ^ P) : 1'b0;
endmodule
