
module meusomador(
output [2:0]RESULTADO,
input  [1:0]A,
input  [1:0]B);
wire   CARRY;

ADDFHX1HVT somador0 (
                .A(A[0]),  
                .B(B[0]),  
                .S(RESULTADO[0]),  
                .CI(1'b0),  
                .CO(CARRY) );
ADDFHX1HVT somador1 (
                .A(A[1]),  
                .B(B[1]),  
                .S(RESULTADO[1]),  
                .CI(CARRY),  
                .CO(RESULTADO[2]) );
endmodule
