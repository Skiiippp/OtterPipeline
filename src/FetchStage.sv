`timescale 1ns / 1ps

module FetchStage(
    input logic IF_CLK,
    input logic [31:0] JALR,
    input logic [31:0] BRANCH,
    input logic [31:0] JAL,
    input logic [1:0] PC_SOURCE,
    input logic PC_RESET,
    input logic PC_WRITE,
    output logic [31:0] MEM_ADDR,    // not buffered - handled outside this module, with mem stuff, so combinational
    output logic [31:0] PC_COUNT,
    output logic [31:0] PC_PLUS_FOUR,
    input logic RAW_MEM_BUSY_1,
    output logic MEM_BUSY_1
);

    logic [31:0] pc_in, pc_plus_four, pc_count;
    
    assign pc_plus_four = pc_count + 4;
    assign MEM_ADDR = pc_count;

    assign PC_COUNT = pc_count; //by any god I hope this fixes that fucking timing issue

    always_ff @ (posedge IF_CLK) begin
        PC_PLUS_FOUR <= pc_plus_four;
        //PC_COUNT <= pc_count;
        MEM_BUSY_1 <= RAW_MEM_BUSY_1;
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
