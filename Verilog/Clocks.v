`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:49:13 10/27/2021 
// Design Name: 
// Module Name:    clocks 
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
module Clocks(
    input clk,
    input rst,
    output reg oneHz,
    output reg hundredHz,
    output reg onePulse,
    output wire clock25M,
    output reg pulse05H
    );

    reg [27:0] counter05H;
    reg [1:0]  counter25M;
    reg [16:0] hundredCounter;
    reg [26:0] oneCounter;
    
    assign clock25M = counter25M[1];
    
    always @(posedge clk) begin
        if (rst) begin
            hundredCounter <= 0;
            counter25M <= 0;
            counter05H <= 0; 
            oneCounter <= 0;
            
            oneHz = 0; 
            hundredHz = 0;
            pulse05H <= 0;
            
        end else begin
			hundredCounter <= hundredCounter + 1;
            if (hundredCounter >= 'd100_000) begin
                hundredHz = ~hundredHz;
				hundredCounter <= 1;
            end
            
            oneCounter <= oneCounter + 1;
            if (oneCounter >= 'd50_000_000) begin
                oneHz = ~oneHz;
                onePulse <= 1;
				oneCounter <= 1;
            end else begin
                onePulse <= 0;
            end
            
            counter25M <= counter25M + 1;
            
            counter05H <= counter05H + 1;
            if (counter05H >= 'd2) begin
                pulse05H <= 1;
                counter05H <= 1;
            end else begin
                pulse05H <= 0;
            end
           
        end
    end 

endmodule
