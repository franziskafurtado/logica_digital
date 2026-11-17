`timescale 1ns/10ps

module tb();

    reg  [3:0] X;
    reg  [3:0] REF;
    wire       Q;

    integer i, j;
    integer testes;

    sistema_y dut (
        .X(X),
        .REF(REF),
        .Q(Q)
    );

    initial begin
        testes = 0;
        $display("Iniciando teste do sistema_y");

        // Testa as 256 combinacoes de X e REF.
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                X = i[3:0];
                REF = j[3:0];
                #10ns;

                if (Q !== (X == REF)) begin
                    $fatal(1, "ERRO: X=%b REF=%b Q=%b esperado=%b",
                           X, REF, Q, (X == REF));
                end

                testes = testes + 1;
            end
        end

        $display("Testes aprovados: %0d/256", testes);
        $finish;
    end

endmodule
