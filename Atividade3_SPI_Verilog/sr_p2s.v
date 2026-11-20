// Tarefa 1 - Registrador de deslocamento paralelo -> serial (8 bits)
// Envia o bit 7 primeiro. Reset sincrono, ativo em 1.
// done: pulso quando o byte de data_in foi aceito.
// Um buffer adicional permite enfileirar 1 byte durante a transmissao.
module sr_p2s (
    input             clk,
    input             reset,
    input      [7:0]  data_in,
    input             load,
    output reg        data_out,
    output reg        done
);
    reg [7:0] shift_reg;
    reg [7:0] next_byte;
    reg [2:0] bit_count;
    reg busy;
    reg pending;

    always @(posedge clk) begin
        if (reset) begin
            shift_reg <= 8'b0;
            next_byte <= 8'b0;
            bit_count <= 3'd0;
            data_out  <= 1'b0;
            done      <= 1'b0;
            busy      <= 1'b0;
            pending   <= 1'b0;
        end else begin
            done <= 1'b0;

            if (!busy) begin
                if (load) begin
                    shift_reg <= data_in;
                    bit_count <= 3'd0;
                    busy      <= 1'b1;
                    done      <= 1'b1;
                end
            end else begin
                // Um bit por borda de subida, MSB primeiro.
                data_out  <= shift_reg[7];
                shift_reg <= {shift_reg[6:0], 1'b0};

                if (bit_count == 3'd7) begin
                    bit_count <= 3'd0;
                    if (pending) begin
                        // Proximo byte sem ciclo ocioso entre os bits.
                        shift_reg <= next_byte;
                        pending   <= 1'b0;
                    end else if (load) begin
                        shift_reg <= data_in;
                        done      <= 1'b1;
                    end else begin
                        busy <= 1'b0;
                    end
                end else begin
                    bit_count <= bit_count + 3'd1;
                    if (load && !pending) begin
                        next_byte <= data_in;
                        pending   <= 1'b1;
                        done      <= 1'b1;
                    end
                end
            end
        end
    end
endmodule
