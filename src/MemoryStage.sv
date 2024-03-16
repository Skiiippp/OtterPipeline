`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 10:12:41 PM
// Design Name: 
// Module Name: MemoryStage
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


module MemoryStage(
    input logic MEM_CLK,
    input logic [31:0] ADDR_2,
    input logic [31:0] D_IN_2,
    input logic MEM_WRITE,
    input logic MEM_READ_2,
    output logic [31:0] D_OUT_2,   // not buffered
    
    // IO
    input logic [31:0] IOBUS_IN,
    output logic [31:0] IOBUS_OUT,
    output logic IOBUS_WR,
    output logic [31:0] IOBUS_ADDR,
    
    // Fetch stage stuff - not buffered
    input logic [31:0] MEM_ADDR_1,
    input logic MEM_READ_1,
    output logic [31:0] D_OUT_1
    
    /* // Error stuff
    input logic ERR_PC_IN,
    output logic ERR_PC_OUT 
    */
    );
endmodule
