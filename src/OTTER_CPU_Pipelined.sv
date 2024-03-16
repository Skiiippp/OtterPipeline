`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 10:39:49 PM
// Design Name: 
// Module Name: OTTER_CPU_Pipelined
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


module OTTER_CPU_Pipelined(
    input logic CLK,
    input logic INTR,
    input logic RESET,
    input logic [31:0] IOBUS_IN,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
);

    // ### Fetch Stage ###
    // Inputs
    logic [31:0] jalr, branch, jal;  
    logic [1:0] pc_source; 
    logic pc_write = 1'b1;
    // Outpus
    logic [31:0] pc_count_unclocked, pc_count, pc_plus_four;
    
    FetchStage IF(CLK, jalr, branch, jal, pc_source, RESET, pc_write, pc_count_unclocked, pc_count, pc_plus_four);
    
    // Route memory shit
    
    // ### Decode Stage ###
    // Inputs
    logic [31:0] ir;    // piped from mem
    logic [31:0] wd;    // piped from wb
    // Outputs
    logic reg_write, mem_write, mem_read_2;
    logic [3:0] alu_fun;
    logic [31:0] rs_1, rs_2, j_type, b_type, alu_in_1, alu_in_2;
    logic [1:0] rf_wr_sel;
    
    DecodeStage DE(CLK, pc_count, ir, wd, reg_write, mem_write, mem_read_2, alu_fun, rs_1, rs_2, j_type, b_type, alu_in_1, alu_in_2, rf_wr_sel);
    
    // ### Execute Stage ###
    // Inputs
    // Outputs
    logic [31:0] alu_result;
    
    ExecuteStage EX(CLK, j_type, b_type, rs_1, rs_2, alu_in_1, alu_in_2, alu_fun, jalr, branch, jal, pc_source, alu_result);
    
    // ### Memory Stage ###
    // Inputs
    logic mem_read_1 = 1'b1;
    // Outputs
    logic [31:0] d_out_2;
    
    MemoryStage MEM(CLK, alu_result, rs_2, mem_write, mem_read_2, d_out_2, IOBUS_IN, IOBUS_OUT, IOBUS_WR, IOBUS_ADDR, pc_count, mem_read_1, ir);
    
    // ### Writeback Stage ###
    // Inputs
    logic [31:0] csr_reg;
    // Outputs
    
    WritebackStage WB(CLK, reg_write, pc_plus_four, csr_reg, d_out_2, alu_result, rf_wr_sel, wd);
    

endmodule




















