`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 10:01:27 PM
// Design Name: 
// Module Name: ExecuteStage
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


module ExecuteStage(
    input logic EX_CLK,
    input logic [31:0] J_TYPE,
    input logic [31:0] B_TYPE,
    input logic [31:0] RS_1,
    input logic [31:0] RS_2,
    input logic [31:0] ALU_IN_1,
    input logic [31:0] ALU_IN_2,
    input logic [3:0] ALU_FUN,
    output logic [31:0] JALR,
    output logic [31:0] BRANCH,
    output logic [31:0] JAL,
    output logic [1:0] PC_SOURCE,
    output logic [31:0] ALU_RESULT
    
    /* // Error stuff
    input logic ERR_PC_IN,
    output logic ERR_PC_OUT
    */
    );
endmodule
