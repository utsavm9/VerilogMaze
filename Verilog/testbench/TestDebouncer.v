`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:06:36 12/01/2021
// Design Name:   Debouncer
// Module Name:   C:/Users/152/Downloads/Project/Project/Maze/TestDebouncer.v
// Project Name:  Maze
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Debouncer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TestDebouncer;

	// Inputs
	reg clk;
	reg hundredHz;
	reg resetButton;

	// Outputs
	wire btnR;

	// Instantiate the Unit Under Test (UUT)
	Debouncer uut (
		.clk(clk), 
		.hundredHz(hundredHz), 
		.resetButton(resetButton), 
		.btnR(btnR)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		hundredHz = 0;
		resetButton = 0;

		// Wait 100 ns for global reset to finish
		#100;
        resetButton = 1;
        #110;
        resetButton = 0;
        
        #120;
        resetButton = 1;
        #125;
        resetButton = 0;
        
        #150;
        resetButton = 1;
        
        #10_000;

	end
    
    always #0.5 clk = ~clk;
    always #50 hundredHz = ~hundredHz;
      
endmodule

