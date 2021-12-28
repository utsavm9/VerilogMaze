`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:38:54 11/17/2021 
// Design Name: 
// Module Name:    MazeTop 
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
module MazeTop(
	input clk,
	input btnRight,
	input miso,
	input [2:0] sw,
	output ss,
	output mosi,
	output sclk, 
	output [7:0] Led,
	output [3:0] an,
	output [6:0] seg,
    
    output Hsync,
    output Vsync,
    output reg [2:0] vgaRed,
    output reg [2:0] vgaGreen,
    output reg [2:0] vgaBlue
    );
    
        
    reg [10:0] randRow = 1;
    reg [10:0] randCol = cols - 2;
    reg [10:0] nextRandRow = 1;
    reg [10:0] nextRandCol = cols - 2;


    ///////////////////////////////////////////////////// Joystick

	wire isLeft;
	wire isRight;
	wire isUp;
	wire isDown;

	Joystick joystick(
		.CLK(clk),
		.RST(btnR), 
		.MISO(miso),
		.SW(),
		.SS(ss),
		.MOSI(mosi),
		.SCLK(sclk),
		.LED(),
		.AN(),
		.SEG(),
		
		.isLeft(isLeft),
		.isRight(isRight),
		.isUp(isUp),
		.isDown(isDown)
	);
	
	assign Led[6:0] = {'b111, isLeft, isRight, isUp, isDown};

	
	//////////////////////////////////////////////////// Seven Segment Display
	
    wire oneHz;
    wire onePulse;
	wire hundredHz;
    wire clock25M;
    wire pulse05H;
	
    wire [3:0] randRowOnes;
    wire [3:0] randRowTens;
    assign randRowOnes = (randRow[3:0] % 10);
    assign randRowTens = (randRow / 10);
    
	SevenSegment sevenSegment(
		.hundredHz(hundredHz),
		.digit0({1'b0, rand[2:0]}),
		.digit1(11),
		.digit2(randRowOnes),
		.digit3(randRowTens),
		.seg(seg),
		.an(an)
	);
	
	Clocks clocks(
		.clk(clk),
		.rst(btnR),
        .oneHz(oneHz),
        .onePulse(onePulse),
		.hundredHz(hundredHz),
        .clock25M(clock25M),
        .pulse05H(pulse05H)
	);
    
        
    //////////////////////////////////////////////////// Debouncer
    
    Debouncer debouncer(
        .clk(clk),
        .hundredHz(hundredHz),
        .resetButton(btnRight),
        .btnR(btnR)
    );
     
    /////////////////////////////////////////////////// Random Number Generator
    
    wire [4:0] rand;
    RandomNumGen #(.NUM_BITS(4)) randNumGen
    (
        .i_Clk(oneHz),
        .i_Enable(1'b1),

        // Optional Seed Value
        .i_Seed_DV(1'b0),
        .i_Seed_Data(4'b0),

        .o_LFSR_Data(rand),
        .o_LFSR_Done(Led[7])
    );
    
    
    /////////////////////////////////////////////////// Display
    
    // video structure constants
    parameter hpixels = 800;// horizontal pixels per line
    parameter vlines = 521; // vertical lines per frame
    parameter hpulse = 96; 	// hsync pulse length
    parameter vpulse = 2; 	// vsync pulse length
    parameter hbp = 144; 	// end of horizontal back porch
    parameter hfp = 784; 	// beginning of horizontal front porch
    parameter vbp = 31; 		// end of vertical back porch
    parameter vfp = 511; 	// beginning of vertical front porch
    // active horizontal video is therefore: 784 - 144 = 640
    // active vertical video is therefore: 511 - 31 = 480

    // registers for storing the horizontal & vertical counters
    reg [9:0] hc;
    reg [9:0] vc;

    // Horizontal & vertical counters --
    // this is how we keep track of where we are on the screen.
    // ------------------------
    // Sequential "always block", which is a block that is
    // only triggered on signal transitions or "edges".
    // posedge = rising edge  &  negedge = falling edge
    // Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
    

    always @(posedge clock25M or posedge btnR)
    begin
        // reset condition
        if (btnR == 1)
        begin
            hc <= 0;
            vc <= 0;
        end
        else
        begin
            // keep counting until the end of the line
            if (hc < hpixels - 1)
                hc <= hc + 1;
            else
            // When we hit the end of the line, reset the horizontal
            // counter and increment the vertical counter.
            // If vertical counter is at the end of the frame, then
            // reset that one too.
            begin
                hc <= 0;
                if (vc < vlines - 1)
                    vc <= vc + 1;
                else
                    vc <= 0;
            end
            
        end
    end

    // generate sync pulses (active low)
    // ----------------
    // "assign" statements are a quick way to
    // give values to variables of type: wire
    assign Hsync = (hc < hpulse) ? 0:1;
    assign Vsync = (vc < vpulse) ? 0:1;

    // display 100% saturation colorbars
    // ------------------------
    // Combinational "always block", which is a block that is
    // triggered when anything in the "sensitivity list" changes.
    // The asterisk implies that everything that is capable of triggering the block
    // is automatically included in the sensitivty list.  In this case, it would be
    // equivalent to the following: always @(hc, vc)
    // Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
    

    /**
    * @utsav: Colors:
    * White:    rrrgggbb = 111_111_11
    * Yellow:   rrrgggbb = 111_111_00
    * Cyan:     rrrgggbb = 000_111_11
    * Magenta:  rrrgggbb = 111_000_11
    * Black:    rrrgggbb = 000_00)_00
    */
    
    parameter rows = 29;
    parameter cols = 29;
    parameter pixelInCol = (hfp - hbp) / cols;
    parameter pixelInRow = (vfp - vbp) / rows;

    reg [1:0] blocks[rows - 1:0][cols - 1:0];
    
    reg [10:0] meRow = rows - 2;
    reg [10:0] meCol = 1;
    
    reg [10:0] exitRow = 1;
    reg [10:0] exitCol = cols - 1;
    reg won = 0;
    
    // Fill in blocks
    always @(posedge clk) begin
        if (btnR) begin
            meRow <= rows - 2;
            meCol <= 1; 
            exitRow = 1;
            exitCol = cols - 1;
            
            won <= 0;
            
            randRow <= 1;
            randCol <= cols - 2;
        end
        
        if (onePulse) begin
            if (isLeft && ((meCol - 1) > 0) && blocks[meRow][meCol - 1] != 1) begin
                meCol <= meCol - 1;
            end
            if (isRight && meCol + 1 < cols && blocks[meRow][meCol + 1] != 1) begin
                meCol <= meCol + 1;
            end
            if (isUp && meRow - 1 > 0 && blocks[meRow - 1][meCol] != 1) begin
                meRow <= meRow - 1;
            end
            if (isDown && meRow + 1 < rows - 1 && blocks[meRow + 1][meCol] != 1) begin
                meRow <= meRow + 1;
            end
            
            if (meRow == exitRow && meCol == exitCol) begin
                won <= 1;
            end
        end
    
        // Random walk
        if (onePulse) begin
            if (rand[1:0] == 0) begin // Up
                if (randRow > 1 && blocks[randRow - 1][randCol] == 0)
                    nextRandRow <= randRow - 1;
            end else if (rand[1:0] == 1) begin // Down
                if (randRow + 1 < rows - 1 && blocks[randRow + 1][randCol] == 0);
                    nextRandRow <= randRow + 1;
            end else if (rand[1:0] == 2) begin // Left
                if (randCol > 1 && blocks[randRow][randCol - 1] == 0)
                    nextRandCol <= randCol - 1;
            end else if (rand[1:0] == 3) begin // Right
                if (randCol < cols - 2 && blocks[randRow][randCol + 1] == 0)
                    nextRandCol <= randCol + 1;
            end else begin
                nextRandRow <= nextRandRow;
                nextRandCol <= nextRandCol;
            end
        end else begin
            randRow <= nextRandRow;
            randCol <= nextRandCol;
        end     
        
        
        
        for (integer r = 0; r < rows; r = r + 1) begin
            for (integer c = 0; c < cols; c = c + 1) begin
                blocks[r][c] <= 0;
                
                // Me
                if (r == meRow && c == meCol) begin
                    blocks[r][c] <= 2;
                end
                // Random block
                if (r == randRow && c == randCol) begin
                    blocks[r][c] <= 1;
                end
                
                // Border
                if (r == 0 || r == rows - 1) begin
                    blocks[r][c] <= 1;
                end
                if (c == 0 || c == cols - 1) begin
                    blocks[r][c] <= 1;
                end
                if (r == exitRow && c == exitCol) begin
                    blocks[r][c] <= 3;
                end
                // Reset
                if (btnR) begin
                    blocks[r][c] <= 0;
                end
            end
        end
        
        blocks[1][6] <= 1;
        blocks[1][10] <= 1;
        blocks[1][18] <= 1;
        blocks[2][2] <= 1;
        blocks[2][4] <= 1;
        blocks[2][6] <= 1;
        blocks[2][7] <= 1;
        blocks[2][8] <= 1;
        blocks[2][10] <= 1;
        blocks[2][12] <= 1;
        blocks[2][14] <= 1;
        blocks[2][15] <= 1;
        blocks[2][16] <= 1;
        blocks[2][18] <= 1;
        blocks[2][20] <= 1;
        blocks[2][21] <= 1;
        blocks[2][22] <= 1;
        blocks[2][24] <= 1;
        blocks[2][25] <= 1;
        blocks[2][26] <= 1;
        blocks[2][27] <= 1;
        blocks[3][2] <= 1;
        blocks[3][4] <= 1;
        blocks[3][8] <= 1;
        blocks[3][12] <= 1;
        blocks[3][14] <= 1;
        blocks[3][16] <= 1;
        blocks[3][18] <= 1;
        blocks[3][20] <= 1;
        blocks[3][22] <= 1;
        blocks[4][2] <= 1;
        blocks[4][4] <= 1;
        blocks[4][5] <= 1;
        blocks[4][6] <= 1;
        blocks[4][8] <= 1;
        blocks[4][9] <= 1;
        blocks[4][10] <= 1;
        blocks[4][12] <= 1;
        blocks[4][14] <= 1;
        blocks[4][16] <= 1;
        blocks[4][18] <= 1;
        blocks[4][20] <= 1;
        blocks[4][22] <= 1;
        blocks[4][23] <= 1;
        blocks[4][24] <= 1;
        blocks[4][25] <= 1;
        blocks[4][26] <= 1;
        blocks[5][2] <= 1;
        blocks[5][4] <= 1;
        blocks[5][10] <= 1;
        blocks[5][12] <= 1;
        blocks[5][14] <= 1;
        blocks[5][18] <= 1;
        blocks[5][22] <= 1;
        blocks[6][2] <= 1;
        blocks[6][4] <= 1;
        blocks[6][5] <= 1;
        blocks[6][6] <= 1;
        blocks[6][7] <= 1;
        blocks[6][8] <= 1;
        blocks[6][10] <= 1;
        blocks[6][11] <= 1;
        blocks[6][12] <= 1;
        blocks[6][14] <= 1;
        blocks[6][16] <= 1;
        blocks[6][17] <= 1;
        blocks[6][18] <= 1;
        blocks[6][19] <= 1;
        blocks[6][20] <= 1;
        blocks[6][22] <= 1;
        blocks[6][24] <= 1;
        blocks[6][25] <= 1;
        blocks[6][26] <= 1;
        blocks[7][2] <= 1;
        blocks[7][8] <= 1;
        blocks[7][10] <= 1;
        blocks[7][14] <= 1;
        blocks[7][18] <= 1;
        blocks[7][22] <= 1;
        blocks[7][24] <= 1;
        blocks[8][2] <= 1;
        blocks[8][3] <= 1;
        blocks[8][4] <= 1;
        blocks[8][5] <= 1;
        blocks[8][6] <= 1;
        blocks[8][8] <= 1;
        blocks[8][10] <= 1;
        blocks[8][12] <= 1;
        blocks[8][13] <= 1;
        blocks[8][14] <= 1;
        blocks[8][15] <= 1;
        blocks[8][16] <= 1;
        blocks[8][18] <= 1;
        blocks[8][19] <= 1;
        blocks[8][20] <= 1;
        blocks[8][21] <= 1;
        blocks[8][22] <= 1;
        blocks[8][24] <= 1;
        blocks[8][26] <= 1;
        blocks[8][27] <= 1;
        blocks[9][4] <= 1;
        blocks[9][8] <= 1;
        blocks[9][12] <= 1;
        blocks[9][16] <= 1;
        blocks[9][18] <= 1;
        blocks[9][24] <= 1;
        blocks[10][2] <= 1;
        blocks[10][3] <= 1;
        blocks[10][4] <= 1;
        blocks[10][6] <= 1;
        blocks[10][7] <= 1;
        blocks[10][8] <= 1;
        blocks[10][10] <= 1;
        blocks[10][11] <= 1;
        blocks[10][12] <= 1;
        blocks[10][14] <= 1;
        blocks[10][16] <= 1;
        blocks[10][18] <= 1;
        blocks[10][20] <= 1;
        blocks[10][21] <= 1;
        blocks[10][22] <= 1;
        blocks[10][23] <= 1;
        blocks[10][24] <= 1;
        blocks[10][26] <= 1;
        blocks[11][2] <= 1;
        blocks[11][6] <= 1;
        blocks[11][10] <= 1;
        blocks[11][14] <= 1;
        blocks[11][16] <= 1;
        blocks[11][18] <= 1;
        blocks[11][22] <= 1;
        blocks[11][26] <= 1;
        blocks[12][2] <= 1;
        blocks[12][4] <= 1;
        blocks[12][5] <= 1;
        blocks[12][6] <= 1;
        blocks[12][8] <= 1;
        blocks[12][9] <= 1;
        blocks[12][10] <= 1;
        blocks[12][12] <= 1;
        blocks[12][13] <= 1;
        blocks[12][14] <= 1;
        blocks[12][16] <= 1;
        blocks[12][18] <= 1;
        blocks[12][19] <= 1;
        blocks[12][20] <= 1;
        blocks[12][22] <= 1;
        blocks[12][24] <= 1;
        blocks[12][26] <= 1;
        blocks[13][2] <= 1;
        blocks[13][4] <= 1;
        blocks[13][10] <= 1;
        blocks[13][14] <= 1;
        blocks[13][16] <= 1;
        blocks[13][22] <= 1;
        blocks[13][24] <= 1;
        blocks[13][26] <= 1;
        blocks[14][2] <= 1;
        blocks[14][4] <= 1;
        blocks[14][5] <= 1;
        blocks[14][6] <= 1;
        blocks[14][7] <= 1;
        blocks[14][8] <= 1;
        blocks[14][9] <= 1;
        blocks[14][10] <= 1;
        blocks[14][11] <= 1;
        blocks[14][12] <= 1;
        blocks[14][14] <= 1;
        blocks[14][16] <= 1;
        blocks[14][17] <= 1;
        blocks[14][18] <= 1;
        blocks[14][19] <= 1;
        blocks[14][20] <= 1;
        blocks[14][21] <= 1;
        blocks[14][22] <= 1;
        blocks[14][24] <= 1;
        blocks[14][26] <= 1;
        blocks[15][2] <= 1;
        blocks[15][4] <= 1;
        blocks[15][8] <= 1;
        blocks[15][12] <= 1;
        blocks[15][14] <= 1;
        blocks[15][20] <= 1;
        blocks[15][24] <= 1;
        blocks[15][26] <= 1;
        blocks[16][2] <= 1;
        blocks[16][4] <= 1;
        blocks[16][6] <= 1;
        blocks[16][8] <= 1;
        blocks[16][10] <= 1;
        blocks[16][12] <= 1;
        blocks[16][14] <= 1;
        blocks[16][15] <= 1;
        blocks[16][16] <= 1;
        blocks[16][17] <= 1;
        blocks[16][18] <= 1;
        blocks[16][20] <= 1;
        blocks[16][22] <= 1;
        blocks[16][23] <= 1;
        blocks[16][24] <= 1;
        blocks[16][26] <= 1;
        blocks[17][2] <= 1;
        blocks[17][6] <= 1;
        blocks[17][8] <= 1;
        blocks[17][10] <= 1;
        blocks[17][14] <= 1;
        blocks[17][16] <= 1;
        blocks[17][20] <= 1;
        blocks[17][22] <= 1;
        blocks[17][24] <= 1;
        blocks[18][1] <= 1;
        blocks[18][2] <= 1;
        blocks[18][3] <= 1;
        blocks[18][4] <= 1;
        blocks[18][5] <= 1;
        blocks[18][6] <= 1;
        blocks[18][8] <= 1;
        blocks[18][10] <= 1;
        blocks[18][11] <= 1;
        blocks[18][12] <= 1;
        blocks[18][13] <= 1;
        blocks[18][14] <= 1;
        blocks[18][16] <= 1;
        blocks[18][18] <= 1;
        blocks[18][19] <= 1;
        blocks[18][20] <= 1;
        blocks[18][22] <= 1;
        blocks[18][24] <= 1;
        blocks[18][26] <= 1;
        blocks[18][27] <= 1;
        blocks[19][8] <= 1;
        blocks[19][10] <= 1;
        blocks[19][16] <= 1;
        blocks[19][20] <= 1;
        blocks[19][22] <= 1;
        blocks[19][24] <= 1;
        blocks[19][26] <= 1;
        blocks[20][2] <= 1;
        blocks[20][3] <= 1;
        blocks[20][4] <= 1;
        blocks[20][5] <= 1;
        blocks[20][6] <= 1;
        blocks[20][8] <= 1;
        blocks[20][10] <= 1;
        blocks[20][11] <= 1;
        blocks[20][12] <= 1;
        blocks[20][14] <= 1;
        blocks[20][16] <= 1;
        blocks[20][17] <= 1;
        blocks[20][18] <= 1;
        blocks[20][20] <= 1;
        blocks[20][21] <= 1;
        blocks[20][22] <= 1;
        blocks[20][24] <= 1;
        blocks[20][26] <= 1;
        blocks[21][2] <= 1;
        blocks[21][6] <= 1;
        blocks[21][8] <= 1;
        blocks[21][12] <= 1;
        blocks[21][14] <= 1;
        blocks[21][18] <= 1;
        blocks[21][22] <= 1;
        blocks[21][24] <= 1;
        blocks[22][2] <= 1;
        blocks[22][3] <= 1;
        blocks[22][4] <= 1;
        blocks[22][6] <= 1;
        blocks[22][8] <= 1;
        blocks[22][9] <= 1;
        blocks[22][10] <= 1;
        blocks[22][12] <= 1;
        blocks[22][13] <= 1;
        blocks[22][14] <= 1;
        blocks[22][15] <= 1;
        blocks[22][16] <= 1;
        blocks[22][18] <= 1;
        blocks[22][19] <= 1;
        blocks[22][20] <= 1;
        blocks[22][22] <= 1;
        blocks[22][24] <= 1;
        blocks[22][25] <= 1;
        blocks[22][26] <= 1;
        blocks[23][4] <= 1;
        blocks[23][10] <= 1;
        blocks[23][12] <= 1;
        blocks[23][20] <= 1;
        blocks[24][2] <= 1;
        blocks[24][4] <= 1;
        blocks[24][5] <= 1;
        blocks[24][6] <= 1;
        blocks[24][7] <= 1;
        blocks[24][8] <= 1;
        blocks[24][9] <= 1;
        blocks[24][10] <= 1;
        blocks[24][12] <= 1;
        blocks[24][14] <= 1;
        blocks[24][15] <= 1;
        blocks[24][16] <= 1;
        blocks[24][17] <= 1;
        blocks[24][18] <= 1;
        blocks[24][19] <= 1;
        blocks[24][20] <= 1;
        blocks[24][21] <= 1;
        blocks[24][22] <= 1;
        blocks[24][23] <= 1;
        blocks[24][24] <= 1;
        blocks[24][26] <= 1;
        blocks[24][27] <= 1;
        blocks[25][2] <= 1;
        blocks[25][4] <= 1;
        blocks[25][10] <= 1;
        blocks[25][12] <= 1;
        blocks[25][24] <= 1;
        blocks[25][26] <= 1;
        blocks[26][2] <= 1;
        blocks[26][4] <= 1;
        blocks[26][6] <= 1;
        blocks[26][7] <= 1;
        blocks[26][8] <= 1;
        blocks[26][10] <= 1;
        blocks[26][12] <= 1;
        blocks[26][14] <= 1;
        blocks[26][15] <= 1;
        blocks[26][16] <= 1;
        blocks[26][17] <= 1;
        blocks[26][18] <= 1;
        blocks[26][19] <= 1;
        blocks[26][20] <= 1;
        blocks[26][22] <= 1;
        blocks[26][23] <= 1;
        blocks[26][24] <= 1;
        blocks[26][26] <= 1;
        blocks[27][2] <= 1;
        blocks[27][8] <= 1;
        blocks[27][12] <= 1;
        blocks[27][20] <= 1;


    end


    
    /*parameter yellow = 'b111_111_00;
    parameter brown = 'b101_010_01;
    parameter white = 'b111_111_11;
    parameter cyan = 'b000_111_11;*/
    
    always @(*)
    begin
    
        // Default color if none of the if-conditions match
        vgaRed = 0;
        vgaGreen = 0;
        vgaBlue = 0;
        
        // first check if we're within vertical active video range
        for (integer r = 0; r < rows; r = r + 1) begin
            if ((vc >= vbp + r*pixelInRow) && vc < (vbp + (r+1)*pixelInRow)) begin
            
                for (integer c = 0; c < cols; c = c + 1) begin
                    if (hc >= (hbp + c*pixelInCol) 
                        && hc < (hbp + (c+1)*pixelInCol)) begin

                        if (blocks[r][c] == 0) begin
                            //black
                            if (!won) begin
                                vgaRed = 3'b111;
                                vgaGreen = 3'b111;
                                vgaBlue = 3'b111;
                            end else begin
                                vgaRed = 3'b101;
                                vgaGreen = 3'b111;
                                vgaBlue = 3'b011;
                            end
                        end else if (blocks[r][c] == 1) begin
                            // brown
                            vgaRed = 3'b000;
                            vgaGreen = 3'b000;
                            vgaBlue = 3'b000;
                        end else if (blocks[r][c] == 2) begin
                            //yellow
                            vgaRed = 3'b111;
                            vgaGreen = 3'b111;
                            vgaBlue = 3'b000;
                        end else if (blocks[r][c] == 3) begin
                            // green
                            vgaRed = 3'b000;
                            vgaGreen = 3'b111;
                            vgaBlue = 3'b000;
                        end
                    end
                end
            
            end
        end
        
    end


endmodule
