`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:03:42 12/01/2021
// Design Name:   Clocks
// Module Name:   C:/Users/152/Downloads/Project/Project/Maze/TestClock.v
// Project Name:  Maze
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Clocks
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TestClock;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire oneHz;
	wire hundredHz;
	wire onePulse;
	wire clock25M;
	wire pulse05H;

	// Instantiate the Unit Under Test (UUT)
	Clocks uut (
		.clk(clk), 
		.rst(rst), 
		.oneHz(oneHz), 
		.hundredHz(hundredHz), 
		.onePulse(onePulse), 
		.clock25M(clock25M), 
		.pulse05H(pulse05H)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;

		// Wait 100 ns for global reset to finish
		#100;
        rst = 0;
        
        #110_000_000; 
        $finish;

	end

    always #0.5 clk = ~clk;
      
endmodule

