`timescale 1ns/1ps
module tb_mux8x1;
    logic EN;
    logic [3:0] A;
    logic [7:0] X;
    wire Q;
    logic esperado;
    integer e, s, d;

    meu_primeiro_mux8x1 dut (.EN(EN), .A(A), .X(X), .Q(Q));

    initial begin
        // Todas as 256 palavras, 16 enderecos e 2 estados EN.
        for (e = 0; e < 2; e = e + 1)
            for (s = 0; s < 16; s = s + 1)
                for (d = 0; d < 256; d = d + 1) begin
                    EN = e;
                    A  = s;
                    X  = d;
                    #1;
                    esperado = (EN && (A < 8)) ? X[A[2:0]] : 1'b0;
                    if (Q !== esperado)
                        $fatal(1, "MUX falhou EN=%b A=%d X=%h Q=%b",
                               EN, A, X, Q);
                end
        $display("PASS: mux 8:1 (%0d testes)", 2*16*256);
        $finish;
    end
endmodule
