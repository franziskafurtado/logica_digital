// Montegem de um somador de 2 bits
`timescale 1ns/10ps

module tb();

wire [2:0]RESULTADO;  // Fios para ligar as saídas
reg  [1:0]A_s;
reg  [1:0]B_s;
wire CARRY; // ligado em uma saída 

initial
begin
	$display("Iniciou.");
	#3;
	$display("Estimulos.");// inicializar as variaveis de entrada
	A_s = 0;
	B_s = 0;
	#100ns;
	$display("Acabou o teste.");
	$finish();
end

// estimulos para entradas, executam "para sempre"
always
begin :estimulo_A_s 
	#5ns;
        A_s = A_s+1;
end

always
begin :estimulo_B_s 
	#20ns;
        B_s = B_s+1;
end

/* meus somadores
module ADDFHX1HVT (CO, S, A, B, CI);
	output CO, S;
	input A, B, CI;
*/     

ADDFHX1HVT somador0 (
                .A(A_s[0]),  
                .B(B_s[0]),  
                .S(RESULTADO[0]),  
                .CI(1'b0),  
                .CO(CARRY) );
ADDFHX1HVT somador1 (
                .A(A_s[1]),  
                .B(B_s[1]),  
                .S(RESULTADO[1]),  
                .CI(CARRY),  
                .CO(RESULTADO[2]) );


endmodule  // não me esquece aqui!
