`timescale 1ns/1ps
// Testbench acelerado: cada periodo do clk (10 ns) representa 1 s logico.
module semaforo_completo_tb;
    localparam integer T_R1_VERDE = 4;
    localparam integer T_R2_VERDE = 5;
    localparam integer T_AMARELO  = 2;
    localparam integer T_PEDESTRE = 3;

    logic clk = 1'b0;
    logic reset;
    logic pedestre;
    logic rua_1_vermelho, rua_1_amarelo, rua_1_verde;
    logic rua_2_vermelho, rua_2_amarelo, rua_2_verde;
    logic pedestre_vermelho, pedestre_2_verde;

    semaforo_completo #(
        .T_R1_VERDE(T_R1_VERDE),
        .T_R2_VERDE(T_R2_VERDE),
        .T_AMARELO(T_AMARELO),
        .T_PEDESTRE(T_PEDESTRE)
    ) dut (.*);

    always #5 clk = ~clk;

    // Formato: {R1_Verm, R1_Amar, R1_Verd, R2_Verm,
    //            R2_Amar, R2_Verd, Ped_Verm, Ped_Verd}
    localparam logic [7:0] INICIO_OUT = 8'b10010010;
    localparam logic [7:0] R1_VERDE_OUT = 8'b00110010;
    localparam logic [7:0] R1_AMARELO_OUT = 8'b01010010;
    localparam logic [7:0] R2_VERDE_OUT = 8'b10000110;
    localparam logic [7:0] R2_AMARELO_OUT = 8'b10001010;
    localparam logic [7:0] PED_VERDE_OUT = 8'b10010001;

    task automatic conferir(input logic [7:0] esperado, input string etapa);
        logic [7:0] atual;
        begin
            atual = {
                rua_1_vermelho, rua_1_amarelo, rua_1_verde,
                rua_2_vermelho, rua_2_amarelo, rua_2_verde,
                pedestre_vermelho, pedestre_2_verde
            };
            if (atual !== esperado) begin
                $display("ERRO %s t=%0t: esperado=%b obtido=%b", etapa, $time, esperado, atual);
                $fatal(1);
            end
            $display("OK   %s t=%0t: saidas=%b", etapa, $time, atual);
        end
    endtask

    task automatic passo(input logic [7:0] esperado, input string etapa);
        begin
            @(posedge clk);
            #1; // Aguarda atualizacao dos registradores.
            conferir(esperado, etapa);
        end
    endtask

    initial begin
        reset = 1'b1;
        pedestre = 1'b0;
        #1;
        conferir(INICIO_OUT, "Reset: tudo vermelho");
        reset = 1'b0;

        // Primeiro ciclo completo: pedido feito durante o verde da Rua 1.
        passo(R1_VERDE_OUT, "Rua 1 verde");
        pedestre = 1'b1;
        passo(R1_VERDE_OUT, "Pedido de pedestre capturado");
        pedestre = 1'b0; // Mesmo um pulso curto deve ficar memorizado.
        repeat (T_R1_VERDE-2) passo(R1_VERDE_OUT, "Rua 1 permanece verde");

        passo(R1_AMARELO_OUT, "Rua 1 amarelo");
        repeat (T_AMARELO-1) passo(R1_AMARELO_OUT, "Rua 1 permanece amarelo");

        passo(R2_VERDE_OUT, "Rua 2 verde");
        repeat (T_R2_VERDE-1) passo(R2_VERDE_OUT, "Rua 2 permanece verde");

        passo(R2_AMARELO_OUT, "Rua 2 amarelo");
        repeat (T_AMARELO-1) passo(R2_AMARELO_OUT, "Rua 2 permanece amarelo");

        passo(PED_VERDE_OUT, "Pedestre verde por pedido pendente");
        repeat (T_PEDESTRE-1) passo(PED_VERDE_OUT, "Pedestre permanece verde");

        // Sem novo pedido, nao deve haver etapa de pedestre no ciclo seguinte.
        passo(R1_VERDE_OUT, "Retorna a Rua 1");
        repeat (T_R1_VERDE-1) passo(R1_VERDE_OUT, "Rua 1 verde sem pedido");
        passo(R1_AMARELO_OUT, "Rua 1 amarelo sem pedido");
        repeat (T_AMARELO-1) passo(R1_AMARELO_OUT, "Rua 1 amarelo sem pedido");
        passo(R2_VERDE_OUT, "Rua 2 verde sem pedido");
        repeat (T_R2_VERDE-1) passo(R2_VERDE_OUT, "Rua 2 verde sem pedido");
        passo(R2_AMARELO_OUT, "Rua 2 amarelo sem pedido");
        repeat (T_AMARELO-1) passo(R2_AMARELO_OUT, "Rua 2 amarelo sem pedido");
        passo(R1_VERDE_OUT, "Sem pedido: pula pedestre corretamente");

        // Testa reset assincrono mesmo fora de uma borda de subida.
        #2;
        reset = 1'b1;
        #1;
        conferir(INICIO_OUT, "Reset assincrono");
        $display("TODOS OS TESTES PASSARAM");
        $finish;
    end
endmodule
