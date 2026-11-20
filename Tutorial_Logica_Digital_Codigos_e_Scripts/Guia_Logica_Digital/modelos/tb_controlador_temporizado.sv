`timescale 1ns/1ps
// Testbench: apenas para simulacao; NAO sintetizar.
module tb_controlador_temporizado;
    localparam integer N = 4;
    logic clk = 1'b0;
    logic reset, start;
    logic busy, done;

    // Instancia do DUT (design under test)
    controlador_temporizado #(.N(N)) dut (
        .clk(clk), .reset(reset), .start(start),
        .busy(busy), .done(done)
    );

    always #5 clk = ~clk;   // Clock de periodo 10 ns (so no TB)

    task automatic tick;
        @(posedge clk);
        #1;                  // Espera as atribuicoes nao bloqueantes
    endtask

    initial begin
        reset = 1'b1;
        start = 1'b0;
        repeat (2) tick();
        if (busy !== 1'b0 || done !== 1'b0)
            $fatal(1, "Falha no reset");

        @(negedge clk); reset = 1'b0; start = 1'b1;
        tick();             // Entra no estado EXECUTA
        if (!busy || done) $fatal(1, "Nao iniciou");
        @(negedge clk); start = 1'b0;

        repeat (N-1) begin
            tick();         // Continua ocupado nos N-1 ciclos seguintes
            if (!busy || done) $fatal(1, "Tempo insuficiente");
        end
        tick();             // Final do N-esimo ciclo: FINALIZA
        if (busy || !done) $fatal(1, "done ausente");
        tick();             // done deve durar apenas 1 ciclo
        if (busy || done) $fatal(1, "done durou mais de um ciclo");

        $display("TESTE PASSOU");
        $finish;
    end
endmodule
