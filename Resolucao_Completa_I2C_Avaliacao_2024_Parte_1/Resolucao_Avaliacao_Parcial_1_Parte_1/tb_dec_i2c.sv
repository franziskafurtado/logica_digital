`timescale 1ns/1ps

// Testbench autoral para a resolucao do enunciado de 2024.
// O anexo original tb_i2c.sv e citado no PDF, mas nao foi fornecido.
module tb_dec_i2c;
    logic clk = 1'b0;
    logic reset, sda, scl, pronto;
    logic [6:0] endereco_local;
    logic [6:0] endereco_recebido;
    logic operacao, escrita, stop;

    int pulsos_escrita = 0;
    int pulsos_stop    = 0;

    // Periodo do relogio interno: 10 ns.
    always #5 clk = ~clk;

    dec_i2c #(.STOP_SOMENTE_ESCRITA(1'b1)) dut (
        .clk(clk), .reset(reset), .sda(sda), .scl(scl),
        .pronto(pronto), .endereco_local(endereco_local),
        .endereco_recebido(endereco_recebido),
        .operacao(operacao), .escrita(escrita), .stop(stop)
    );

    // Conta os pulsos apos a atualizacao das atribuicoes nao bloqueantes.
    always @(posedge clk) begin
        #1;
        if (!reset) begin
            if (escrita) pulsos_escrita++;
            if (stop)    pulsos_stop++;
        end
    end

    // START: SDA cai enquanto SCL=1.
    task automatic inicia_i2c;
        begin
            @(negedge clk);
            scl = 1'b1;
            sda = 1'b1;
            #20;
            sda = 1'b0;
            #20;
            scl = 1'b0;
        end
    endtask

    // Um bit a cada 100 ns: SCL baixo por 50 e alto por 50.
    // SDA e modificado apenas enquanto SCL esta baixo.
    task automatic envia_bit(input logic valor);
        begin
            scl = 1'b0;
            sda = valor;
            #50;
            scl = 1'b1;
            #50;
            scl = 1'b0;
        end
    endtask

    // STOP: SDA sobe enquanto SCL=1.
    task automatic termina_i2c;
        begin
            scl = 1'b0;
            sda = 1'b0;
            #30;
            scl = 1'b1;
            #30;
            sda = 1'b1;
            #30;
        end
    endtask

    // Endereco enviado MSB primeiro; 8o bit = R/W.
    task automatic envia_quadro(
        input logic [6:0] endereco,
        input logic rw
    );
        begin
            inicia_i2c();
            for (int i = 6; i >= 0; i--)
                envia_bit(endereco[i]);
            envia_bit(rw);
            termina_i2c();
            repeat (2) @(negedge clk);
        end
    endtask

    task automatic verifica(
        input logic [6:0] endereco_esperado,
        input logic operacao_esperada,
        input int escritas_esperadas,
        input int stops_esperados
    );
        begin
            if (endereco_recebido !== endereco_esperado ||
                operacao !== operacao_esperada ||
                pulsos_escrita != escritas_esperadas ||
                pulsos_stop != stops_esperados) begin
                $display("ERRO t=%0t addr=%b R/W=%b escrita=%0d stop=%0d",
                         $time, endereco_recebido, operacao,
                         pulsos_escrita, pulsos_stop);
                $fatal(1, "Resultado diferente do esperado");
            end
            $display("OK t=%0t addr=%b R/W=%b escrita=%0d stop=%0d",
                     $time, endereco_recebido, operacao,
                     pulsos_escrita, pulsos_stop);
        end
    endtask

    initial begin
        reset          = 1'b1;
        sda            = 1'b1;
        scl            = 1'b1;
        pronto         = 1'b1;
        endereco_local = 7'b1100100;
        repeat (3) @(negedge clk);
        reset = 1'b0;
        repeat (2) @(negedge clk);

        // Caso 1: endereco local + escrita; dois pulsos esperados.
        envia_quadro(7'b1100100, 1'b0);
        verifica(7'b1100100, 1'b0, 1, 1);

        // Caso 2: endereco local + leitura; nao gera escrita nem stop
        // quando STOP_SOMENTE_ESCRITA=1.
        envia_quadro(7'b1100100, 1'b1);
        verifica(7'b1100100, 1'b1, 1, 1);

        // Caso 3: endereco diferente + escrita; sem qualificacao.
        envia_quadro(7'b1010011, 1'b0);
        verifica(7'b1010011, 1'b0, 1, 1);

        // Caso 4: nova escrita correta, sem reset entre quadros.
        envia_quadro(7'b1100100, 1'b0);
        verifica(7'b1100100, 1'b0, 2, 2);

        // Caso 5: pronto=0 impede a recepcao de novo quadro.
        pronto = 1'b0;
        envia_quadro(7'b1100100, 1'b0);
        verifica(7'b1100100, 1'b0, 2, 2);
        pronto = 1'b1;

        // Caso 6: reset durante uma transacao abandona os bits.
        inicia_i2c();
        envia_bit(1'b1);
        envia_bit(1'b0);
        @(negedge clk);
        reset = 1'b1;
        repeat (2) @(negedge clk);
        reset = 1'b0;
        termina_i2c();
        repeat (2) @(negedge clk);
        if (pulsos_escrita != 2 || pulsos_stop != 2)
            $fatal(1, "Reset nao cancelou a transacao");

        $display("TODOS OS TESTES PASSARAM");
        $finish;
    end

    initial begin
        #20000;
        $fatal(1, "Timeout do testbench");
    end
endmodule
