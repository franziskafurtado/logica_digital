`timescale 1ns/1ps

module tb;

logic [3:0] req;
    logic [3:0] grant;
    logic       available;
    logic [1:0] grant_num;

logic [3:0] expected_grant;
    logic       expected_available;
    logic [1:0] expected_num;

arbitro dut (
        .req(req),
        .grant(grant),
        .available(available),
        .grant_num(grant_num)
    );

initial begin
        req = 4'b0000;

        for (int i = 0; i <16; i++) begin
            req = 4'(i);
            #10;

expected_grant = 4'b0000;
            expected_available = 1'b0;
            expected_num = 2'd0;

if (req[0]) begin
                expected_grant = 4'b0001;
                expected_num = 2'd0;
            end
            else if (req[1]) begin
                expected_grant = 4'b0010;
                expected_num = 2'd1;
            end
            else if (req[2]) begin
                expected_grant = 4'b0100;
                expected_num = 2'd2;
            end
            else if (req[3]) begin
                expected_grant = 4'b1000;
                expected_num = 2'd3;
            end
            else begin
                expected_available = 1'b1;
            end

$display(
                "req=%b grant=%b available=%b grant_num=%d",
                req, grant, available, grant_num
            );

if (grant !== expected_grant ||
                available !== expected_available ||
                grant_num !== expected_num) begin
                $fatal(1, "Falha para req=%b", req);
            end
        end

$display("Todos os 16 testes passaram!");
        $finish;
    end

endmodule