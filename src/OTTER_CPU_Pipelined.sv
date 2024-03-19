//CPE333 Lab3 Pipelined Otter. James Gruber, Braydon Burkhardt - rev A

`timescale 1ns / 1ps

module OTTER_CPU_Pipelined(
    input logic CLK,
    input logic RESET,
    input logic [31:0] IOBUS_IN,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
);

    logic [31:0] ir; //IR is the reg output at DE stage

    // ### Memory ###
    //shared between IF, DE, MEM, and WB stages
    //inputs
    logic memRead1;
    logic memRead2;
    logic memWrite;
    logic [31:0] din2; 
    logic [31:0] addr1;
    logic [31:0] addr2;
    //outputs
    logic [31:0] memRaw_dout1; //'raw' wires are before the regs in the appropriate stage
    logic [31:0] memRaw_dout2;
    logic memRaw_memBusy1;
    logic memRaw_memBusy2;
    logic memBusy1; //output of reg from IF
    logic memBusy2; //output of reg from MEM
    logic memRaw_iobus_wr;
    
    OTTER_mem_byte MEMORY(
    .MEM_CLK(CLK),
    .MEM_ADDR1(addr1),
    .MEM_ADDR2(addr2),
    .MEM_DIN2(din2),
    .MEM_WRITE2(memWrite),
    .MEM_READ1(memRead1),
    .MEM_READ2(memRead2),
    .ERR(),
    .MEM_DOUT1(memRaw_dout1),
    .MEM_DOUT2(memRaw_dout2),
    .IO_IN(IOBUS_IN),
    .IO_WR(memRaw_iobus_wr),
    .MEM_SIZE(ir[14:12]),
    .MEM_SIGN(1'b0)
    );

    // ### IF: Fetch Stage ###
    // Inputs
    logic [31:0] jalr, branch, jal;  
    logic [1:0] pc_source; 
    logic pc_write = 1'b1;
    // Outputs
    logic [31:0] pc_count, pc_plus_four;
    
    FetchStage IF(CLK, jalr, branch, jal, pc_source, RESET, pc_write, addr1, pc_count, pc_plus_four, memRaw_memBusy1,   memBusy1);
    
    // ### DE: Decode Stage ###
    // Inputs
    logic [31:0] wd;    // piped from wb
    // Outputs
    logic reg_write, mem_write, mem_read_2;
    logic [3:0] alu_fun;
    logic [31:0] rs_1, rs_2, j_type, b_type, i_type, alu_in_1, alu_in_2;
    logic [1:0] rf_wr_sel;
    
    DecodeStage DE(CLK, pc_count, memRaw_dout1, wd, reg_write, mem_write, mem_read_2, alu_fun, rs_1, rs_2, j_type, b_type, i_type, alu_in_1, alu_in_2, rf_wr_sel, ir);
    
    // ### EX: Execute Stage ###
    // Inputs
    // Outputs  
    logic [31:0] alu_result;
    
    ExecuteStage EX(CLK, j_type, b_type, i_type, ir, pc_count, rs_1, rs_2, alu_in_1, alu_in_2, alu_fun, jalr, branch, jal, pc_source, alu_result);
    
    // ### MEM: Memory Stage ###
    // Inputs
    logic mem_read_1 = 1'b1;
    // Outputs
    logic [31:0] d_out_2;
    
    MemoryStage MEM(CLK, alu_result, rs_2, mem_write, mem_read_2, d_out_2, IOBUS_IN, IOBUS_OUT, IOBUS_WR, IOBUS_ADDR, pc_count, mem_read_1, ir);
    
    // ### WB: Writeback Stage ###
    // Inputs
    logic [31:0] csr_reg;
    // Outputs
    
    WritebackStage WB(CLK, reg_write, pc_plus_four, csr_reg, d_out_2, alu_result, rf_wr_sel, wd);
    

endmodule




















