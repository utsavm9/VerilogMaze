`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:53:56 11/17/2021 
// Design Name: 
// Module Name:    vertical_counter 
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
module vertical_counter( reset, clk, enable_v_counter, v_count );
    input            reset, clk;                    // pixel clock: 25MHz
    input            enable_v_counter;
    output reg [8:0] v_count;                       // default value [15:0]

    initial begin
        v_count = 9'd0;
    end

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            v_count <= 9'd0;
        end		
        else if (enable_v_counter == 1'b1) begin    // keep counting until 449
            if (v_count < 9'd448) begin
                v_count <= v_count + 1'b1;
            end
            else begin
                v_count <= 1'b0;                    // reset vertical counter
            end 
        end
    end
endmodule
