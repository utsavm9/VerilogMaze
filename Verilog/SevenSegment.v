`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:11:45 10/27/2021 
// Design Name: 
// Module Name:    SevenSegment 
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
module SevenSegment(
    input hundredHz,
    input[3:0] digit0,
    input[3:0] digit1,
    input[3:0] digit2,
    input[3:0] digit3,
    output reg [7:0] seg,
    output reg [3:0] an
    );
    
    reg[1:0] counter = 0;
    reg[3:0] thisDigit;

    always @(posedge hundredHz) begin
        counter <= counter + 1;
        an <= 'b1111;
        
        case (counter)
            0: thisDigit <= digit0;
            1: thisDigit <= digit1;
            2: thisDigit <= digit2;
            3: thisDigit <= digit3;
            default: thisDigit = 11;
        endcase
        
        case (thisDigit)
            0: seg = 7'b100_0000;
            1: seg = 7'b111_1001;
            2: seg = 7'b010_0100;
            3: seg = 7'b011_0000;
            4: seg = 7'b001_1001;
            5: seg = 7'b001_0010;
            6: seg = 7'b000_0010;
            7: seg = 7'b111_1000;
            8: seg = 7'b000_0000;
            9: seg = 7'b001_0000;
            default: seg = 7'b111_1111;
        endcase
        
        case (counter)
            0: an <= 'b1110;
            1: an <= 'b0111;
            2: an <= 'b1011;
            3: an <= 'b1101;
            
        endcase
        
    end
    

endmodule
