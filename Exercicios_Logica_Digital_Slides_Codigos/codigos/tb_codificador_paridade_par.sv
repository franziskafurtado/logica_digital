`timescale 1ns/1ps
module tb_codificador_paridade_par;
    logic EN;
    logic [7:0] A;
    logic [8:0] Q;
    integer i, e;
    codificador_paridade_par dut (.EN(EN), .A(A), .Q(Q));

    initial begin
        for (e = 0; e < 2; e = e + 1)
            for (i = 0; i < 256; i = i + 1) begin
                EN = e;
                A = i;
                #1;
                if (!EN) begin
                    if (Q !== 9'b0) $fatal(1, "EN=0 deveria zerar Q");
                end else begin
                    if (Q[7:0] !== A || (^Q) !== 1'b0)
                        $fatal(1, "Paridade par incorreta A=%h Q=%h", A, Q);
                end
            end
        $display("PASS: gerador paridade par");
        $finish;
    end
endmodule
