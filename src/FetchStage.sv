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
    input logic IF_CLK,
    input logic [31:0] JALR,
    input logic [31:0] BRANCH,
    input logic [31:0] JAL,
    input logic [1:0] PC_SOURCE,
    input logic PC_RESET,
    input logic PC_WRITE,
    output logic [31:0] PC_COUNT_UNCLOCKED,    // not buffered - handled outside this module, with mem stuff, so combinational
    output logic [31:0] PC_COUNT,
    output logic [31:0] PC_PLUS_FOUR
);

    logic [31:0] pc_in, pc_plus_four, pc_count;
    
    assign pc_plus_four = pc_count + 4;
    assign PC_COUNT_UNCLOCKED = pc_count;

    always_ff @ (posedge IF_CLK) begin
        PC_PLUS_FOUR <= pc_plus_four;
        PC_COUNT <= pc_count;
    end 
    
    // PC Mux
    always_comb begin
        case (PC_SOURCE)
            2'b00: pc_in = pc_plus_four;
            2'b01: pc_in = JALR;
            2'b10: pc_in = BRANCH;
            2'b11: pc_in = JAL;
            default: pc_in = pc_plus_four;
        endcase
    end
    
    // PC
    ProgCount PC(IF_CLK, PC_RESET, PC_WRITE, pc_in, pc_count);


endmodule
