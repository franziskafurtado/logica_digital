// ================================================================
// Testbench para sinaleira2.sv
// Cada periodo de 10 ns do testbench representa 1 s do clock
// real de 1 Hz. Nao e necessario simular segundos reais.
// Testes: tempos, pedido, ausencia de pedido, seguranca e reset.
// ================================================================
`timescale 1ns/1ps

module tb_sinaleira2;
    localparam integer X_TB = 6; // exemplo do enunciado
    localparam integer Y_TB = 5; // exemplo do enunciado
    localparam integer TEMPO_X = (X_TB == 0) ? 10 : X_TB;
    localparam integer TEMPO_Y = (Y_TB == 0) ? 10 : Y_TB;

    logic clk = 1'b0;
    logic reset;
    logic pedestre;

    logic rua_1_vermelho, rua_1_amarelo, rua_1_verde;
    logic rua_2_vermelho, rua_2_amarelo, rua_2_verde;
    logic pedestre_vermelho, pedestre_verde;

    // Instancia do projeto sob teste (DUT).
    sinaleira2 #(.X(X_TB), .Y(Y_TB)) dut (
        .clk(clk),
        .reset(reset),
        .pedestre(pedestre),
        .rua_1_vermelho(rua_1_vermelho),
        .rua_1_amarelo(rua_1_amarelo),
        .rua_1_verde(rua_1_verde),
        .rua_2_vermelho(rua_2_vermelho),
        .rua_2_amarelo(rua_2_amarelo),
        .rua_2_verde(rua_2_verde),
        .pedestre_vermelho(pedestre_vermelho),
        .pedestre_verde(pedestre_verde)
    );

    // O clock alterna a cada 5 ns: periodo = 10 ns.
    always #5 clk = ~clk;

    // Ordem dos bits: R1(V,A,G), R2(V,A,G), ped(V,G).
    wire [7:0] leds = {
        rua_1_vermelho, rua_1_amarelo, rua_1_verde,
        rua_2_vermelho, rua_2_amarelo, rua_2_verde,
        pedestre_vermelho, pedestre_verde
    };

    localparam logic [7:0] L_INICIO     = 8'b10010010;
    localparam logic [7:0] L_R1_VERDE   = 8'b00110010;
    localparam logic [7:0] L_R1_AMARELO = 8'b01010010;
    localparam logic [7:0] L_R2_VERDE   = 8'b10000110;
    localparam logic [7:0] L_R2_AMARELO = 8'b10001010;
    localparam logic [7:0] L_PED_VERDE  = 8'b10010001;

    task automatic conferir(
        input logic [7:0] esperado,
        input string nome_fase
    );
        if (leds !== esperado) begin
            $error("Falha em %s, t=%0t: obtido=%b esperado=%b",
                   nome_fase, $time, leds, esperado);
            $fatal(1, "Saidas incorretas");
        end
    endtask

    // Avanca UM clock e confere a fase apos a atualizacao.
    task automatic passo(
        input logic [7:0] esperado,
        input string nome_fase
    );
        @(posedge clk);
        #1; // aguarda as atribuicoes nao bloqueantes
        conferir(esperado, nome_fase);
    endtask

    // Propriedades basicas de seguranca.
    always @(negedge clk) begin
        if (!reset) begin
            if ((rua_1_verde && rua_2_verde) ||
                (rua_1_verde && pedestre_verde) ||
                (rua_2_verde && pedestre_verde))
                $fatal(1, "ERRO: dois sinais verdes ao mesmo tempo!");

            if ((rua_1_vermelho + rua_1_amarelo + rua_1_verde) != 1)
                $fatal(1, "ERRO: Rua 1 com luzes inconsistentes");
            if ((rua_2_vermelho + rua_2_amarelo + rua_2_verde) != 1)
                $fatal(1, "ERRO: Rua 2 com luzes inconsistentes");
            if ((pedestre_vermelho + pedestre_verde) != 1)
                $fatal(1, "ERRO: Pedestre com luzes inconsistentes");
        end
    end

    initial begin
        reset    = 1'b1;
        pedestre = 1'b0;
        #1;
        conferir(L_INICIO, "INICIO apos reset");

        @(negedge clk);
        reset = 1'b0;

        // CICLO 1: pulso de pedido ao iniciar o ciclo de veiculos.
        // Vale inclusive para X=1 e X=0 (0 significa 10).
        pedestre = 1'b1;
        passo(L_R1_VERDE, "Rua 1 verde - pedido capturado");
        pedestre = 1'b0;
        repeat (TEMPO_X-1) passo(L_R1_VERDE, "Rua 1 verde");

        repeat (2) passo(L_R1_AMARELO, "Rua 1 amarelo");
        repeat (TEMPO_Y) passo(L_R2_VERDE, "Rua 2 verde");
        repeat (2) passo(L_R2_AMARELO, "Rua 2 amarelo");
        repeat (5) passo(L_PED_VERDE, "Pedestre verde");
        passo(L_R1_VERDE, "Retorno a Rua 1 apos pedestre");

        // CICLO 2 - sem nenhum pedido: nao libera pedestres.
        repeat (TEMPO_X-1) passo(L_R1_VERDE, "Rua 1 verde sem pedido");
        repeat (2) passo(L_R1_AMARELO, "Rua 1 amarelo sem pedido");
        repeat (TEMPO_Y) passo(L_R2_VERDE, "Rua 2 verde sem pedido");
        repeat (2) passo(L_R2_AMARELO, "Rua 2 amarelo sem pedido");
        passo(L_R1_VERDE, "Sem pedido: retorna diretamente a Rua 1");

        // Reset ASSINCRONO em meio a operacao.
        #2;
        reset = 1'b1;
        #1;
        conferir(L_INICIO, "Reset assincrono");

        $display("TESTES CONCLUIDOS: sinaleira2 OK");
        $finish;
    end

    // Protecao contra simulacao que nunca termina.
    initial begin
        #10000;
        $fatal(1, "Timeout da simulacao");
    end
endmodule
