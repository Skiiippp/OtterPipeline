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
    input logic [31:0] I_TYPE,
    input logic [31:0] IR,
    input logic [31:0] PC_COUNT,
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
    );
    
    logic [31:0] jalr, branch, jal;
    logic [1:0] pc_source;
    logic [31:0] alu_result;
    
    always_ff @ (posedge EX_CLK) begin
        JALR <= jalr;
        BRANCH <= branch;
        JAL <= jal;
        PC_SOURCE <= pc_source;
        ALU_RESULT <= alu_result;
    end
    
    //ALU
    OTTER_ALU ALU(ALU_FUN,ALU_IN_1,ALU_IN_2,alu_result);
    
    //target gen
    always_comb begin 
        jalr = I_TYPE + RS_1;
        branch = PC_COUNT + {{20{IR[31]}},IR[7],IR[30:25],IR[11:8],1'b0};
        jal = PC_COUNT + {{12{IR[31]}}, IR[19:12], IR[20],IR[30:21],1'b0};
    end
    
    //branch gen
    //works on hope and dreams (or lack of)
    logic br_lt,br_eq,br_ltu;
    logic brn_cond;
    always_comb begin 
        br_lt=0; br_eq=0; br_ltu=0;
        if($signed(RS_1) < $signed(RS_2)) br_lt=1;
        if(RS_1==RS_2) br_eq=1;
        if(RS_1<RS_2) br_ltu=1;
        
        //get true/false condition return
        case(IR[14:12])
                        3'b000: brn_cond = br_eq;     //BEQ 
                        3'b001: brn_cond = ~br_eq;    //BNE
                        3'b100: brn_cond = br_lt;     //BLT
                        3'b101: brn_cond = ~br_lt;    //BGE
                        3'b110: brn_cond = br_ltu;    //BLTU
                        3'b111: brn_cond = ~br_ltu;   //BGEU
                        default: brn_cond =0;
        endcase
        
        case(IR[6:0])
            7'b1101111: pc_source = 3'b011; //JAL
            7'b1100111: pc_source = 3'b001; //JALR
            7'b1100011: pc_source = (brn_cond)?3'b010:2'b000;
            default: pc_source = 3'b000;
        endcase
        
    end
endmodule
