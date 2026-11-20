// Tarefa 4 - SPI Secundario (8 bits, MSB primeiro, full-duplex)
// Ativo somente com CS=0. Recebe MOSI e atualiza MISO na
// borda de descida de SCLK, conforme a atividade.
// reset e sincrono a borda de descida de SCLK; CS=1 cancela
// a transacao imediatamente (desselacao assincrona).
// done: pulso quando data_in e copiado; ready: pulso ao receber 8 bits.
// Na primeira borda de descida, load=1 prepara o byte de resposta.
// Pode receber um segundo load para guardar o proximo byte.
module spi_sub (
    input              reset,
    input      [7:0]   data_in,
    input              load,
    output reg [7:0]   data_out,
    output reg         ready,
    output reg         done,
    input              mosi,
    output reg         miso,
    input              sclk,
    input              cs
);
    reg [7:0] rx_shift;
    reg [7:0] tx_shift;
    reg [7:0] next_byte;
    reg [2:0] bit_count;
    reg pending;

    always @(negedge sclk or posedge cs) begin
        if (cs) begin
            // Desselecionado: ignora o barramento e reinicia o quadro.
            rx_shift  <= 8'b0;
            tx_shift  <= 8'b0;
            next_byte <= 8'b0;
            bit_count <= 3'd0;
            pending   <= 1'b0;
            data_out  <= 8'b0;
            ready     <= 1'b0;
            done      <= 1'b0;
            miso      <= 1'b0;
        end else if (reset) begin
            rx_shift  <= 8'b0;
            tx_shift  <= 8'b0;
            next_byte <= 8'b0;
            bit_count <= 3'd0;
            pending   <= 1'b0;
            data_out  <= 8'b0;
            ready     <= 1'b0;
            done      <= 1'b0;
            miso      <= 1'b0;
        end else begin
            ready <= 1'b0;
            done  <= 1'b0;

            // Recepcao: bit 7 chega primeiro e percorre o shift register.
            rx_shift <= {rx_shift[6:0], mosi};
            if (bit_count == 3'd7) begin
                data_out  <= {rx_shift[6:0], mosi};
                bit_count <= 3'd0;
                ready     <= 1'b1;
            end else begin
                bit_count <= bit_count + 3'd1;
            end

            // Transmissao: o dado apresentado em MISO sera lido pelo
            // Principal na proxima subida de seu clock.
            if (bit_count == 3'd0 && pending) begin
                miso     <= next_byte[7];
                tx_shift <= {next_byte[6:0], 1'b0};
                pending  <= 1'b0;
            end else if (bit_count == 3'd0 && load) begin
                miso     <= data_in[7];
                tx_shift <= {data_in[6:0], 1'b0};
                done     <= 1'b1;
            end else begin
                miso     <= tx_shift[7];
                tx_shift <= {tx_shift[6:0], 1'b0};

                if (load && !pending) begin
                    next_byte <= data_in;
                    pending   <= 1'b1;
                    done      <= 1'b1;
                end
            end
        end
    end
endmodule
