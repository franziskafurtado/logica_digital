module tb();

reg [2:0]A;
reg [2:0]B;
reg OP;

wire [3:0] Q;


meu_somador_subtrator inst(A,B,OP,Q);


initial
begin
  OP =0;
  A = 0;
  B = 0;
  #10;
  A = 3;
  B = 1;
  #10;
  OP =1;
  A = 3;
  B = 1;
  #10;
  A = 2;
  B = 1;
  #10;
  $finish();
end

endmodule

