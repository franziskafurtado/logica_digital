// Registrador de deslocamento MSB primeiro.
// Use load para carregar; depois pulse shift a cada bit transmitido.
module registrador_deslocamento (
    input  logic clk, reset, load, shift,
    input  logic [7:0] data_in,
    output logic serial_out
);
    logic [7:0] q;
    always_ff @(posedge clk) begin
        if (reset)       q <= 8'b0;
        else if (load)   q <= data_in;
        else if (shift)  q <= {q[6:0], 1'b0};
    end
    assign serial_out = q[7]; // bit mais significativo sai primeiro
endmodule
