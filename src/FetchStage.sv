`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 08:44:12 PM
// Design Name: 
// Module Name: FetchStage
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


module FetchStage(
    input IF_CLK,
    input [31:0] JALR,
    input [31:0] BRANCH,
    input [31:0] JAL,
    input PC_SOURCE,
    input PC_RESET,
    input PC_WRITE,
    output [31:0] PC_COUNT    // unclocked - handled outside this module
);



endmodule
