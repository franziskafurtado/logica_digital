`timescale 1ns/1ps
module tb_codificador_onehot;
    logic [1:0] A;
    logic [3:0] X;
    logic [3:0] esperado;
    integer i;
    codificador_onehot dut (.A(A), .X(X));

    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            A = i;
            esperado = 4'b0001 << i;
            #1;
            if (X !== esperado)
                $fatal(1, "One-hot falhou: A=%b X=%b", A, X);
        end
        $display("PASS: codificador one-hot");
        $finish;
    end
endmodule
