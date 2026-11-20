`timescale 1ns/1ps
module tb_ula_soma_sub;
    logic OP;
    logic signed [2:0] A, B;
    logic signed [3:0] Q;
    integer a_i, b_i, op_i, esperado;
    ula_soma_sub dut (.OP(OP), .A(A), .B(B), .Q(Q));

    initial begin
        // Todos os 8x8x2 casos, incluindo numeros negativos.
        for (a_i = -4; a_i <= 3; a_i = a_i + 1)
            for (b_i = -4; b_i <= 3; b_i = b_i + 1)
                for (op_i = 0; op_i < 2; op_i = op_i + 1) begin
                    A  = a_i;
                    B  = b_i;
                    OP = op_i;
                    esperado = OP ? (a_i + b_i) : (a_i - b_i);
                    #1;
                    if ($signed(Q) !== esperado)
                        $fatal(1, "ULA falhou A=%0d B=%0d OP=%b Q=%0d",
                               a_i, b_i, OP, Q);
                end
        $display("PASS: ULA (128 casos)");
        $finish;
    end
endmodule
