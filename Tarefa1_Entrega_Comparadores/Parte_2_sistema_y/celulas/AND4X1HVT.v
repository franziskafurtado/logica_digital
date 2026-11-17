`timescale 1ns/10ps

module AND4X1HVT (
	output wire Y,
	input wire A, B, C, D
);
	// Function
	assign Y = A & B & C & D;

endmodule
