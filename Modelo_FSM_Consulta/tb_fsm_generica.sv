`timescale 1ns/1ps
// ================================================================
// TESTBENCH AUTOVERIFICAVEL PARA fsm_generica.sv
// Atrasos (#) e tarefas $display/$fatal sao do TESTBENCH:
// nao sao recursos para o hardware sintetizavel.
// ================================================================
module tb_fsm_generica;

    localparam int TEMPO_CICLOS = 4;

    logic clk = 1'b0;
    logic reset, start;
    logic pronto, ocupado, pulso_fim;
    int verificacoes = 0;

    // DUT = Design Under Test: instancia do circuito.
    fsm_generica #(.TEMPO_CICLOS(TEMPO_CICLOS)) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .pronto(pronto),
        .ocupado(ocupado),
        .pulso_fim(pulso_fim)
    );

    // Clock: 10 ns de periodo (5 ns baixo + 5 ns alto).
    always #5 clk = ~clk;

    // Conferir saidas. '!==': detecta tambem valores X ou Z.
    task automatic conferir(
        input logic esperado_pronto,
        input logic esperado_ocupado,
        input logic esperado_fim,
        input string etapa
    );
        begin
            if ({pronto, ocupado, pulso_fim} !==
                {esperado_pronto, esperado_ocupado, esperado_fim}) begin
                $error("FALHA [%s] obtido=%b%b%b esperado=%b%b%b",
                       etapa, pronto, ocupado, pulso_fim,
                       esperado_pronto, esperado_ocupado, esperado_fim);
                $fatal(1, "Teste interrompido por erro");
            end
            verificacoes++;
            $display("OK [%s] t=%0t", etapa, $time);
        end
    endtask

    // Exercita uma transacao completa.
    task automatic transacao(input string nome);
        begin
            // Ajustar sinais na borda de descida reduz races.
            @(negedge clk);
            start = 1'b1;
            @(posedge clk);
            #1; // permitir atualizar saidas depois do evento
            conferir(1'b0, 1'b1, 1'b0, {nome, ": entrou EXECUTA"});

            @(negedge clk);
            start = 1'b0;
            for (int i = 1; i < TEMPO_CICLOS; i++) begin
                @(posedge clk);
                #1;
                conferir(1'b0, 1'b1, 1'b0,
                         $sformatf("%s: EXECUTA %0d", nome, i));
            end

            @(posedge clk);
            #1;
            conferir(1'b0, 1'b0, 1'b1, {nome, ": fim (1 ciclo)"});

            @(posedge clk);
            #1;
            conferir(1'b1, 1'b0, 1'b0, {nome, ": retornou ESPERA"});
        end
    endtask

    initial begin
        reset = 1'b1;
        start = 1'b0;
        #1;
        conferir(1'b1, 1'b0, 1'b0, "reset inicial");

        @(negedge clk);
        reset = 1'b0;
        transacao("primeira transacao");

        // Reinicia a FSM no meio de uma segunda execucao.
        @(negedge clk);
        start = 1'b1;
        @(posedge clk);
        #1;
        conferir(1'b0, 1'b1, 1'b0, "segunda iniciou");
        @(negedge clk);
        start = 1'b0;
        #1;
        reset = 1'b1;
        #1;
        conferir(1'b1, 1'b0, 1'b0, "reset no meio");
        @(negedge clk);
        reset = 1'b0;

        transacao("apos reset");
        $display("SUCESSO: %0d verificacoes aprovadas", verificacoes);
        $finish;
    end

endmodule
