// EXERCICIO 1 - MUX 8:1 hierarquico com portas logicas.
// ATENCAO: portas primitivas Verilog nao sao instancias da biblioteca GPDK045.
// Para uma versao com CELULAS da biblioteca, substitua as primitivas
// pelas celulas reais e confira nomes de modulos e pinos no .v da lib.
// A tem 4 bits conforme slide; para enderecos 8..15, Q e forçado a 0.

// Submodulo MUX 2:1 montado apenas com portas logicas.
module mux2_portas (
    input  wire I0, I1, S,
    output wire Y
);
    wire S_barra, t0, t1;
    not inv_sel(S_barra, S);
    and and0(t0, I0, S_barra);
    and and1(t1, I1, S);
    or  or0 (Y, t0, t1);
endmodule

module meu_primeiro_mux8x1 (
    input  wire       EN,
    input  wire [3:0] A,
    input  wire [7:0] X,
    output wire       Q
);
    wire [3:0] l1;
    wire [1:0] l2;
    wire l3, endereco_valido;

    // Nivel 1: seleciona um valor de cada par.
    mux2_portas m0 (X[0], X[1], A[0], l1[0]);
    mux2_portas m1 (X[2], X[3], A[0], l1[1]);
    mux2_portas m2 (X[4], X[5], A[0], l1[2]);
    mux2_portas m3 (X[6], X[7], A[0], l1[3]);

    // Nivel 2: restam dois candidatos.
    mux2_portas m4 (l1[0], l1[1], A[1], l2[0]);
    mux2_portas m5 (l1[2], l1[3], A[1], l2[1]);

    // Nivel 3: um candidato.
    mux2_portas m6 (l2[0], l2[1], A[2], l3);

    // Habilitacao e tratamento de endereco fora de 0..7.
    not inv_a3(endereco_valido, A[3]);
    and and_saida(Q, l3, EN, endereco_valido);
endmodule
