// Exemplo sequencial: contador 8 bits crescente/decrescente.
module contador_updown (
    input  logic clk, reset, enable, sobe,
    output logic [7:0] q
);
    always_ff @(posedge clk) begin
        if (reset)
            q <= 8'd0;             // Reset sincrono ativo em 1
        else if (enable) begin
            if (sobe) q <= q + 1'b1;
            else      q <= q - 1'b1;
        end
        // Sem else: o flip-flop conserva q.
    end
endmodule
