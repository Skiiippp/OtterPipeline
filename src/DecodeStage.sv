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
    input logic DE_CLK,
    input logic PC_COUNT,
    input logic [31:0] IR,
    input logic [31:0] WD,
    output logic REG_WRITE,
    output logic MEM_WRITE,
    output logic MEM_READ_2,
    output logic [3:0] ALU_FUN,
    output logic [31:0] RS_1,
    output logic [31:0] RS_2,
    output logic [31:0] J_TYPE,
    output logic [31:0] B_TYPE,
    output logic [31:0] ALU_IN_1,
    output logic [31:0] ALU_IN_2,
    output logic [1:0] RF_WR_SEL
    
    /* // Error stuff 
    input logic ERR_PC_IN,
    output logic ERR_PC_OUT
    */
    );
    
    logic reg_write, mem_write, mem_read_2, int_taken = 1'b0, alu_src_a; 
    logic [1:0] alu_src_b, rf_wr_sel;
    logic [3:0] alu_fun;
    logic [31:0] i_immed, s_immed, b_immed, u_immed, j_immed;
    logic [31:0] rs_1, rs_2;
    logic [31:0] alu_in_1, alu_in_2;
    
    always_ff @ (posedge DE_CLK) begin 
        REG_WRITE <= reg_write;
        MEM_WRITE <= mem_write;
        MEM_READ_2 <= mem_read_2;
        ALU_FUN <= alu_fun;
        RS_1 <= rs_1;
        RS_2 <= rs_2;
        J_TYPE <= j_immed;
        B_TYPE <= b_immed;
        ALU_IN_1 <= alu_in_1;
        ALU_IN_2 <= alu_in_2;
        RF_WR_SEL <= rf_wr_sel;
    end
    
    assign opcode = {IR[6:0]};
 
    // Reg File
    OTTER_registerFile RF(IR[19:15], IR[24:20], IR[11:7], WD, reg_write, RS_1, RS_2, DE_CLK);
    
    // Decoder
    OTTER_CU_Decoder DCDR(IR[6:0], IR[14:12], IR[31:25], int_taken, alu_src_a, alu_src_b, alu_fun, 
    rf_wr_sel, reg_write, mem_write, mem_read_2);        
    
    // Immediate Generation
    assign i_immed = { {21{IR[31]}}, IR[30:20] };
    assign s_immed = { {21{IR[31]}}, IR[30:25], IR[11:7] };
    assign b_immed = { {20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0 };
    assign u_immed = { IR[31:12], 12'b0 };
    assign j_immed = { {12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21], 1'b0 };
    
    // ALU Muxes
    always_comb begin 
        // Mux A
        if(!alu_src_a)  alu_in_1 = rs_1;
        else            alu_in_1 = u_immed;
        
        // Mux B
        case(alu_src_b) 
            2'b00: alu_in_2 = rs_2;
            2'b01: alu_in_2 = i_immed;
            2'b10: alu_in_2 = s_immed;
            2'b11: alu_in_2 = PC_COUNT;
        endcase
    end
    
    
        
    
endmodule







