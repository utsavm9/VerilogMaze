`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:15:13 11/24/2021 
// Design Name: 
// Module Name:    Debouncer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Debouncer(
    input clk,
    input hundredHz,
    input resetButton,
    output reg btnR
    );
    
    // Convert hundredHz 50% duty cycle to a very short-lived pulse with the
    // same frequency
    reg [1:0] hundredStep;
    always @(posedge clk) begin
        hundredStep[1:0] <= {hundredHz, hundredStep[1]};
    end
    assign hundredPulse = ~hundredStep[0] & hundredStep[1];
    
    // Reset
    reg btnRSampledSlowly;
    reg [1:0] rstStep;
    always @(posedge clk) begin
        if (hundredPulse) begin // Debouncer
            btnRSampledSlowly <= resetButton; // Metastability
        end
        // Posedge detector
        rstStep[1:0] <= {btnRSampledSlowly, rstStep[1]};
        btnR <= ~rstStep[0] & rstStep[1];
    end 
    

endmodule