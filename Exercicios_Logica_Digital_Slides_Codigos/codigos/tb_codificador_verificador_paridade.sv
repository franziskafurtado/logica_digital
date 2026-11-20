`timescale 1ns/1ps
module tb_codificador_verificador_paridade;
    logic ENP, ENV, P;
    logic [7:0] A;
    logic [8:0] Q;
    logic E, esperado_E;
    integer d, p_i, ep_i, ev_i;

    codificador_verificador_paridade dut (
        .ENP(ENP), .ENV(ENV), .A(A), .P(P), .Q(Q), .E(E)
    );

    initial begin
        for (d = 0; d < 256; d = d + 1)
            for (p_i = 0; p_i < 2; p_i = p_i + 1)
                for (ep_i = 0; ep_i < 2; ep_i = ep_i + 1)
                    for (ev_i = 0; ev_i < 2; ev_i = ev_i + 1) begin
                        A = d;
                        P = p_i;
                        ENP = ep_i;
                        ENV = ev_i;
                        esperado_E = ENV && ((^A) ^ P);
                        #1;
                        if (Q !== (ENP ? {(^A), A} : 9'b0) ||
                            E !== esperado_E)
                            $fatal(1, "Verificador falhou A=%h P=%b", A, P);
                    end
        $display("PASS: gerador/verificador paridade par");
        $finish;
    end
endmodule
