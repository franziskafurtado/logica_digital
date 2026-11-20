// Registrador com enable e reset sincrono, ativo em 1.
module registrador_8bits (
    input  logic       clk,
    input  logic       reset,
    input  logic       enable,
    input  logic [7:0] d,
    output logic [7:0] q
);
    always_ff @(posedge clk) begin
        if (reset)       q <= 8'd0;
        else if (enable) q <= d;
        // Sem else: q conserva o ultimo valor (flip-flop).
    end
endmodule
