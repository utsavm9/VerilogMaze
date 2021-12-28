`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:54:26 11/17/2021 
// Design Name: 
// Module Name:    horizontal_counter 
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
module horizontal_counter( reset, clk, enable_v_counter, h_count );
    input            reset, clk;                     // pixel clock: 25MHz
    output reg       enable_v_counter;
    output reg [9:0] h_count;                        // default value [15:0]
     
    initial begin
        enable_v_counter <= 1'b0;
        h_count          <= 10'd0;
    end

    always @ (posedge clk or posedge reset) begin
        if( reset ) begin
            h_count <= 10'd0;
            enable_v_counter <= 1'b0;
	    end      
        else if (h_count < 10'd799) begin 
            h_count          <= h_count + 1'b1;
            enable_v_counter <= 1'b0;               // disable vertical counter 
        end
        else begin
            h_count          <= 1'b0;               // reset horizontal counter
            enable_v_counter <= 1'b1;               // trigger vertical counter
        end
    end
endmodule
