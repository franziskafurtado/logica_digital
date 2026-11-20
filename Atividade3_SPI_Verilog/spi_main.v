// Tarefa 3 - SPI Principal (8 bits, MSB primeiro, full-duplex)
// Convencao da atividade: envia MOSI na subida de SCLK,
// SPI Secundario amostra MOSI e apresenta MISO na descida de SCLK.
// O Principal amostra MISO na proxima subida do clock de sistema.
// SCLK fica em 0 quando ocioso; sua frequencia e clk / 2.
// Reset sincrono ativo em 1. CS ativo em 0.
// done: pulso ao copiar data_in; ready: pulso quando data_out e valido.
// Ha um buffer de 1 byte para aceitar novo load durante transmissao.
module spi_main (
    input              clk,
    input              reset,
    input      [7:0]   data_in,
    input              load,
    output reg [7:0]   data_out,
    output reg         ready,
    output reg         done,
    output reg         mosi,
    input              miso,
    output reg         sclk,
    output reg         cs
);
    localparam IDLE = 2'd0,
               SEND = 2'd1,
               LAST = 2'd2;

    reg [1:0] state;
    reg [7:0] tx_shift;
    reg [7:0] rx_shift;
    reg [7:0] next_byte;
    reg [2:0] bit_count;
    reg pending;

    always @(posedge clk) begin
        if (reset) begin
            state     <= IDLE;
            tx_shift  <= 8'b0;
            rx_shift  <= 8'b0;
            next_byte <= 8'b0;
            bit_count <= 3'd0;
            pending   <= 1'b0;
            data_out  <= 8'b0;
            ready     <= 1'b0;
            done      <= 1'b0;
            mosi      <= 1'b0;
            sclk      <= 1'b0;
            cs        <= 1'b1;
        end else begin
            ready <= 1'b0;
            done  <= 1'b0;

            case (state)
                IDLE: begin
                    cs   <= 1'b1;
                    sclk <= 1'b0;
                    if (load) begin
                        tx_shift  <= data_in;
                        rx_shift  <= 8'b0;
                        bit_count <= 3'd0;
                        cs        <= 1'b0;
                        state     <= SEND;
                        done      <= 1'b1;
                    end
                end

                SEND: begin
                    if (sclk == 1'b0) begin
                        // Gera a subida e publica o proximo bit de MOSI.
                        sclk     <= 1'b1;
                        mosi     <= tx_shift[7];
                        tx_shift <= {tx_shift[6:0], 1'b0};

                        // Na primeira subida ainda nao existe MISO recebido.
                        if (bit_count != 3'd0)
                            rx_shift <= {rx_shift[6:0], miso};
                    end else begin
                        // Gera a descida: o Secundario amostra MOSI e
                        // atualiza MISO. Leremos MISO na proxima subida.
                        sclk <= 1'b0;
                        if (bit_count == 3'd7)
                            state <= LAST;
                        else
                            bit_count <= bit_count + 3'd1;
                    end

                    // Reserva 1 byte futuro, sem interromper o byte atual.
                    if (load && !pending) begin
                        next_byte <= data_in;
                        pending   <= 1'b1;
                        done      <= 1'b1;
                    end
                end

                LAST: begin
                    // Leitura do MISO relativo ao oitavo bit transmitido.
                    data_out <= {rx_shift[6:0], miso};
                    ready    <= 1'b1;
                    bit_count <= 3'd0;

                    if (pending) begin
                        // Transmissao consecutiva sem lacuna em SCLK.
                        mosi     <= next_byte[7];
                        tx_shift <= {next_byte[6:0], 1'b0};
                        rx_shift <= 8'b0;
                        pending  <= 1'b0;
                        sclk     <= 1'b1;
                        state    <= SEND;
                    end else if (load) begin
                        // Tambem e possivel oferecer o novo byte aqui.
                        mosi     <= data_in[7];
                        tx_shift <= {data_in[6:0], 1'b0};
                        rx_shift <= 8'b0;
                        done     <= 1'b1;
                        sclk     <= 1'b1;
                        state    <= SEND;
                    end else begin
                        cs    <= 1'b1;
                        sclk  <= 1'b0;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                    cs    <= 1'b1;
                    sclk  <= 1'b0;
                end
            endcase
        end
    end
endmodule
