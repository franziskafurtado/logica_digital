// Meu primeiro testbench de lógica digital
`timescale 1ns/10ps

module tb();

wire RESULTADO;  // Fios para ligar as saídas
reg  SEL_s; // Variaveis ligadas às entradas
reg  A_s;
reg  B_s;
wire saida_XOR;

initial
begin
	$display("Iniciou.");
	#3;
	$display("Estimulos.");
	SEL_s = 0;		// inicializar as variaveis de entrada
	A_s = 0;
	B_s = 0;
	#100ns;
	$display("Acabou o teste.");
	$finish();
end

// estimulos para entradas, executam "para sempre"
always	
begin :label_opcional_para_always_CI // opcional!
	#20ns;
        SEL_s = !SEL_s;
end

always
begin :estimulo_A_s // opcional!
	#5ns;
        A_s = !A_s;
end

always
begin :estimulo_B_s // opcional!
	#2.5ns;
        B_s = !B_s;
end


// Instancia do multiplexador no arquivo da LIB linha 5279
    /*  
    module MX2X1HVT (Y, A, B, S0);
	output Y;
	input A, B, S0;
    */

MX2X1HVT  minha_copia_do_MUX(
     .Y(RESULTADO),
     .S0(SEL_s),  // atribuição fora de ordem pode se citar explicitamente o nome da porta!
     .A(A_s), 
     .B(B_s)
     );
// NOVA PARTE:

/* VOU USAR A CÉLULA EXISTENTE:
module XOR2XLHVT (Y, A, B);
	output Y;
	input A, B;
*/     

XOR2XLHVT myMagiGate(.A(A_s),  .B(B_s), .Y(saida_XOR));


endmodule  // não me esquece aqui!
