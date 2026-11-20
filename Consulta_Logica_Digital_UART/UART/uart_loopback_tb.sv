`timescale 1ns/1ps

// Teste de ponta a ponta: TX -> fio serial -> RX.
module uart_loopback_tb;
    localparam integer CLKS_POR_BIT = 16;
    logic clk = 1'b0;
    logic reset = 1'b1;
    logic enviar = 1'b0;
    logic [7:0] dado_tx = '0;
    logic linha_serial;
    logic ocupado, concluido;
    logic [7:0] dado_rx;
    logic paridade, dv;

    always #5 clk = ~clk;

    codificador_UART #(.CLKS_POR_BIT(CLKS_POR_BIT)) tx_dut (
        .clk(clk), .reset(reset), .enviar(enviar),
        .dado_entrada(dado_tx), .tx(linha_serial),
        .ocupado(ocupado), .concluido(concluido)
    );

    decodificador_UART #(.CLKS_POR_BIT(CLKS_POR_BIT)) rx_dut (
        .clk(clk), .reset(reset), .rx(linha_serial),
        .dados(dado_rx), .paridade(paridade), .dv(dv)
    );

    task automatic transmitir_e_conferir(input logic [7:0] valor);
        begin
            @(negedge clk);
            dado_tx = valor;
            enviar = 1'b1;
            @(negedge clk);
            enviar = 1'b0;
            @(posedge dv);
            #1;
            if (dado_rx !== valor || paridade !== 1'b1)
                $fatal(1, "ERRO: enviado=%h recebido=%h paridade=%b",
                       valor, dado_rx, paridade);
            $display("[OK LOOPBACK] TX=%h RX=%h tempo=%0t", valor, dado_rx, $time);
            wait (ocupado == 1'b0);
            repeat (CLKS_POR_BIT) @(negedge clk);
        end
    endtask

    initial begin
        #100000;
        $fatal(1, "ERRO: timeout de loopback");
    end

    initial begin
        repeat (5) @(negedge clk);
        reset = 1'b0;
        repeat (5) @(negedge clk);
        transmitir_e_conferir(8'hA5);
        transmitir_e_conferir(8'h00);
        transmitir_e_conferir(8'hFF);
        transmitir_e_conferir(8'h96);
        $display("LOOPBACK CONCLUIDO.");
        $finish;
    end
endmodule
