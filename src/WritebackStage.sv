`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 10:31:04 PM
// Design Name: 
// Module Name: WritebackStage
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


module WritebackStage(
    input logic WB_CLK,
    input logic REG_WRITE,
    input logic [31:0] PC_PLUS_FOUR,
    input logic [31:0] CSR_REG,
    input logic [31:0] D_OUT_2,
    input logic [31:0] ALU_RESULT,
    input logic [1:0] RF_WR_SEL,
    output logic [31:0] WD
    
    /* // Error stuff
    input logic ERR_PC_IN,
    output logic ERR_PC_OUT
    */
    );
endmodule
