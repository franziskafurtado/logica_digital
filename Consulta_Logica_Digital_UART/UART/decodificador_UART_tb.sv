`timescale 1ns/1ps

// Testbench independente: produz sinais na linha RX sem depender do TX.
// Inclui paridade errada, stop errado, dados variados e ruido no start.
module decodificador_UART_tb;
    localparam integer CLKS_POR_BIT = 16;
    logic clk = 1'b0;
    logic reset = 1'b1;
    logic rx = 1'b1;
    logic [7:0] dados;
    logic paridade;
    logic dv;

    integer total_dv = 0;
    logic [7:0] ultimo_dado_valido = 8'h00;
    logic dv_anterior = 1'b0;

    always #5 clk = ~clk; // Periodo = 10 ns

    decodificador_UART #(.CLKS_POR_BIT(CLKS_POR_BIT)) dut (
        .clk(clk), .reset(reset), .rx(rx),
        .dados(dados), .paridade(paridade), .dv(dv)
    );

    // Contagem de pulsos validos e verificacao da largura do pulso dv.
    always @(negedge clk) begin
        if (reset) begin
            dv_anterior = 1'b0;
        end else begin
            if (dv && dv_anterior)
                $fatal(1, "ERRO: dv permaneceu alto mais de um clock");
            if (dv) begin
                total_dv = total_dv + 1;
                ultimo_dado_valido = dados;
                if (!paridade)
                    $fatal(1, "ERRO: dv=1 com paridade incorreta");
                $display("[RECEBIDO] tempo=%0t dados=%h paridade=%b dv=%b",
                         $time, dados, paridade, dv);
            end
            dv_anterior = dv;
        end
    end

    task automatic enviar_bit(input logic valor);
        begin
            rx = valor;
            repeat (CLKS_POR_BIT) @(negedge clk);
        end
    endtask

    task automatic enviar_quadro(
        input logic [7:0] valor,
        input logic inverter_paridade,
        input logic parada_valida
    );
        integer i;
        begin
            enviar_bit(1'b0);  // start
            for (i = 0; i < 8; i = i + 1)
                enviar_bit(valor[i]);  // LSB primeiro
            enviar_bit((^valor) ^ inverter_paridade); // paridade par
            enviar_bit(parada_valida); // stop = 1, salvo erro intencional
            rx = 1'b1;
            repeat (CLKS_POR_BIT + 2) @(negedge clk); // intervalo ocioso
        end
    endtask

    task automatic testar(
        input logic [7:0] valor,
        input logic paridade_errada,
        input logic parada_errada
    );
        integer antes;
        integer esperado;
        begin
            antes = total_dv;
            esperado = (!paridade_errada && !parada_errada) ? 1 : 0;
            enviar_quadro(valor, paridade_errada, !parada_errada);

            if (dados !== valor)
                $fatal(1, "ERRO: dados=%h; esperado=%h", dados, valor);
            if (paridade !== !paridade_errada)
                $fatal(1, "ERRO: paridade=%b; esperado=%b",
                       paridade, !paridade_errada);
            if (total_dv !== antes + esperado)
                $fatal(1, "ERRO: total_dv=%0d; esperado=%0d",
                       total_dv, antes + esperado);

            $display("[OK] byte=%h erro_par=%b erro_stop=%b dv_emitido=%0d",
                     valor, paridade_errada, parada_errada, esperado);
        end
    endtask

    initial begin
        // Evita que falhas no DUT deixem a simulacao interminavel.
        #100000;
        $fatal(1, "ERRO: timeout do testbench");
    end

    initial begin
        $display("--- Teste decodificador UART (8E1) ---");
        repeat (5) @(negedge clk);
        reset = 1'b0;
        repeat (CLKS_POR_BIT) @(negedge clk);

        // Pulso curto no RX nao deve ser interpretado como start valido.
        rx = 1'b0;
        repeat (3) @(negedge clk);
        rx = 1'b1;
        repeat (2 * CLKS_POR_BIT) @(negedge clk);
        if (total_dv != 0)
            $fatal(1, "ERRO: falso start gerou dv");

        testar(8'hA5, 1'b0, 1'b0); // byte valido
        testar(8'h00, 1'b0, 1'b0); // todos zeros
        testar(8'hFF, 1'b0, 1'b0); // todos uns
        testar(8'h3C, 1'b0, 1'b0); // byte valido
        testar(8'h53, 1'b1, 1'b0); // paridade incorreta -> dv=0
        testar(8'h2F, 1'b0, 1'b1); // stop incorreto -> dv=0
        testar(8'h96, 1'b0, 1'b0); // recuperacao apos erros

        if (total_dv != 5)
            $fatal(1, "ERRO: total de quadros validos deveria ser 5");
        $display("TODOS OS TESTES PASSARAM. Total dv = %0d", total_dv);
        $finish;
    end
endmodule
