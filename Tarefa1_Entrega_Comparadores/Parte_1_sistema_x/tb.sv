`timescale 1ns/10ps

module tb();

    reg  [3:0] X;
    wire       Q;
    integer    i;
    integer    aprovados;

    sistema_x dut (
        .X(X),
        .Q(Q)
    );

    initial begin
        aprovados = 0;
        $display("Iniciando teste do sistema_x");

        for (i = 0; i < 16; i = i + 1) begin
            X = i[3:0];
            #10ns;

            $display("tempo=%0t | X=%b | Q=%b | esperado=%b",
                     $time, X, Q, (X == 4'b1001));

            if (Q !== (X == 4'b1001)) begin
                $fatal(1, "ERRO: X=%b, Q=%b", X, Q);
            end

            aprovados = aprovados + 1;
        end

        $display("Testes aprovados: %0d/16", aprovados);
        $finish;
    end

endmodule
