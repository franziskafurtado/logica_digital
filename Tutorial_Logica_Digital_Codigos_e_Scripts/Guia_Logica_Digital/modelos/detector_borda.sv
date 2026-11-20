// Detector de borda de subida: pulso de 1 ciclo.
module detector_borda (
    input  logic clk, reset, entrada,
    output logic pulso
);
    logic entrada_anterior;
    always_ff @(posedge clk) begin
        if (reset) begin
            entrada_anterior <= 1'b0;
            pulso <= 1'b0;
        end else begin
            pulso <= entrada & ~entrada_anterior;
            entrada_anterior <= entrada;
        end
    end
endmodule
