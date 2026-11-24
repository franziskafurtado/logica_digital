`timescale 1ns/1ps
// Testbench simples para inspecao de netlist sintetizada + SDF.
// Este exemplo assume que o modulo mapeado se chama fsm_generica
// e que a sua instancia no TB se chama dut.
module tb_fsm_generica_gate;
    logic clk = 1'b0;
    logic reset = 1'b1;
    logic start = 1'b0;
    wire pronto, ocupado, pulso_fim;

    // Nao parametrizar instancias de netlist sem confirmar seus parametros.
    fsm_generica dut (
        .clk(clk), .reset(reset), .start(start),
        .pronto(pronto), .ocupado(ocupado), .pulso_fim(pulso_fim)
    );

    always #5 clk = ~clk;

    initial begin
        $sdf_annotate("fsm_generica.sdf", dut, ,
                      "sdf_annotation.log", "MAXIMUM");
    end

    initial begin
        $monitor("t=%0t reset=%b start=%b pronto=%b ocupado=%b fim=%b",
                 $time, reset, start, pronto, ocupado, pulso_fim);
        #12 reset = 1'b0;
        #8  start = 1'b1;
        #10 start = 1'b0;
        #100;
        $finish;
    end
endmodule
