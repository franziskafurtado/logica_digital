`timescale 1ns/1ps
module tb_encoder_rotativo;
    logic clk = 0, reset = 1, a = 0, b = 0;
    logic passo_a, passo_b, volta_a, volta_b;
    integer passos_a = 0, passos_b = 0, voltas_a = 0, voltas_b = 0;

    encoder_rotativo dut (.*);

    // Cada ciclo representa 100 ns conforme o enunciado.
    always #50 clk = ~clk;

    // Monitora pulsos registrados depois da atualizacao nao bloqueante.
    always @(posedge clk) begin
        #1;
        if (passo_a) passos_a = passos_a + 1;
        if (passo_b) passos_b = passos_b + 1;
        if (volta_a) voltas_a = voltas_a + 1;
        if (volta_b) voltas_b = voltas_b + 1;
        if (passo_a && passo_b) $fatal(1, "Duas direcoes simultaneas");
        if (volta_a && volta_b) $fatal(1, "Duas voltas simultaneas");
    end

    task automatic fase(input logic [1:0] valor);
        @(negedge clk);
        {a,b} = valor;
        repeat (3) @(posedge clk); // Largura de cada fase > 1 ciclo
    endtask

    task automatic ciclo_a;
        fase(2'b00);
        fase(2'b10);
        fase(2'b11);
        fase(2'b01);
        fase(2'b00);
    endtask

    task automatic ciclo_b;
        fase(2'b00);
        fase(2'b01);
        fase(2'b11);
        fase(2'b10);
        fase(2'b00);
    endtask

    initial begin
        repeat (3) @(posedge clk);
        @(negedge clk); reset = 0;

        repeat (16) ciclo_a();
        @(negedge clk);
        if (passos_a != 16 || voltas_a != 1 || dut.saldo != 0)
            $fatal(1, "Falha na volta A: passos=%0d voltas=%0d saldo=%0d", passos_a, voltas_a, dut.saldo);

        repeat (4) ciclo_b(); // saldo = -4
        repeat (2) ciclo_a(); // saldo = -2
        @(negedge clk);
        if (dut.saldo != -2)
            $fatal(1, "Falha na contagem bidirecional: saldo=%0d", dut.saldo);

        // Sequencia incompleta/invalida: nao deve gerar passo.
        fase(2'b10);
        fase(2'b01);
        fase(2'b00);
        @(negedge clk);
        if (passos_a != 18 || passos_b != 4)
            $fatal(1, "Sequencia invalida gerou pulso");

        repeat (14) ciclo_b(); // saldo = -16 => volta B e zera
        @(negedge clk);
        if (passos_b != 18 || voltas_b != 1 || dut.saldo != 0)
            $fatal(1, "Falha na volta B: passos=%0d voltas=%0d saldo=%0d", passos_b, voltas_b, dut.saldo);

        $display("PASSOU: A=%0d, B=%0d, voltas A=%0d, voltas B=%0d", passos_a, passos_b, voltas_a, voltas_b);
        $finish;
    end
endmodule
