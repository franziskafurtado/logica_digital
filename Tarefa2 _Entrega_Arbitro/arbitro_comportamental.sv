
`timescale 1ns/1ps

module arbitro (
    input  logic [3:0] req,
    output logic [3:0] grant,
    output logic       available,
    output logic [1:0] grant_num
);

    always_comb begin
        grant     = 4'b0000;
        available = 1'b0;
        grant_num = 2'b00;

        if (req[0]) begin
            grant     = 4'b0001;
            grant_num = 2'd0;
        end
        else if (req[1]) begin
            grant     = 4'b0010;
            grant_num = 2'd1;
        end
        else if (req[2]) begin
            grant     = 4'b0100;
            grant_num = 2'd2;
        end
        else if (req[3]) begin
            grant     = 4'b1000;
            grant_num = 2'd3;
        end
        else begin
            available = 1'b1;
        end
    end

endmodule
