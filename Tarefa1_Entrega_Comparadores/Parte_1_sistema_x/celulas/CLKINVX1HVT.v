`timescale 1ns/10ps

module CLKINVX1HVT (
	output wire Y,
	input wire A
);
	assign Y = ~A;

endmodule