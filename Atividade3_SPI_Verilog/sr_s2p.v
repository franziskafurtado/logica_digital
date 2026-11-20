// Tarefa 2 - Registrador de deslocamento serial -> paralelo (8 bits)
// Recebe o bit mais significativo primeiro. Reset sincrono, ativo em 1.
// ready: pulso de 1 ciclo de clk depois do oitavo bit valido.
module sr_s2p (
    input             clk,
    input             reset,
    input             data_in,
    input             enable,
    output reg [7:0]  data_out,
    output reg        ready
);
    reg [2:0] bit_count;

    always @(posedge clk) begin
        if (reset) begin
            data_out  <= 8'b0;
            bit_count <= 3'd0;
            ready     <= 1'b0;
        end else begin
            ready <= 1'b0;
            if (enable) begin
                // Depois de 8 amostras, o primeiro bit chega a data_out[7].
                data_out <= {data_out[6:0], data_in};
                if (bit_count == 3'd7) begin
                    ready     <= 1'b1;
                    bit_count <= 3'd0;
                end else begin
                    bit_count <= bit_count + 3'd1;
                end
            end else begin
                // Nova rajada de bits comeca um novo byte.
                bit_count <= 3'd0;
            end
        end
    end
endmodule
