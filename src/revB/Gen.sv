`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2024 04:18:39 PM
// Design Name: 
// Module Name: Gen
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


module Gen(
    input [6:0] CU_OPCODE,
    input [2:0] CU_FUNC3,
    input CU_BR_EQ,
    input CU_BR_LT,
    input CU_BR_LTU, 
    output logic [3:0] CU_PCSOURCE
    );
    
    typedef enum logic [6:0] {
               LUI      = 7'b0110111,
               AUIPC    = 7'b0010111,
               JAL      = 7'b1101111,
               JALR     = 7'b1100111,
               BRANCH   = 7'b1100011,
               LOAD     = 7'b0000011,
               STORE    = 7'b0100011,
               OP_IMM   = 7'b0010011,
               OP       = 7'b0110011,
               SYSTEM   = 7'b1110011
    } opcode_t;
    
    logic brn_cond;
    
    always_comb begin
            case(CU_OPCODE)
                JAL: CU_PCSOURCE =3'b011;
                JALR: CU_PCSOURCE=3'b001;
                BRANCH: CU_PCSOURCE=(brn_cond)?3'b010:2'b000;
                default: CU_PCSOURCE=3'b000; 
            endcase
    end
    
    always_comb begin
        case(CU_FUNC3)
                    3'b000: brn_cond = CU_BR_EQ;     //BEQ 
                    3'b001: brn_cond = ~CU_BR_EQ;    //BNE
                    3'b100: brn_cond = CU_BR_LT;     //BLT
                    3'b101: brn_cond = ~CU_BR_LT;    //BGE
                    3'b110: brn_cond = CU_BR_LTU;    //BLTU
                    3'b111: brn_cond = ~CU_BR_LTU;   //BGEU
                    default: brn_cond =0;
        endcase
    end
endmodule
