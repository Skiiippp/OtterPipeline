`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 09:41:00 PM
// Design Name: 
// Module Name: DecodeStage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DecodeStage(
    input DE_CLK,
    input [31:0] IR,
    output REG_WRITE,
    output MEM_WRITE,
    output MEM_READ_2,
    output [3:0] ALU_FUN,
    output [31:0] RS1,
    output [31:0] RS2,
    output [31:0] J_TYPE,
    output [31:0] B_TYPE
    );
endmodule
