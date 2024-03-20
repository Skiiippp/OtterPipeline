`timescale 1ns / 1ps

module WritebackStage(
    input logic WB_CLK,
    input logic [31:0] PC_PLUS_FOUR,
    input logic [31:0] CSR_REG,
    input logic [31:0] D_OUT_2,
    input logic [31:0] ALU_RESULT,
    input logic [1:0] RF_WR_SEL,
    output logic [31:0] WD
    );

    logic muxOut;
    always_ff @ (posedge WB_CLK) begin
        WD <= muxOut;
    end
    
    always_comb begin
        case(RF_WR_SEL)
            2'b00: muxOut = PC_PLUS_FOUR;
            2'b01: muxOut = CSR_REG;
            2'b10: muxOut = D_OUT_2;
            2'b11: muxOut = ALU_RESULT;
        endcase
    end
    
endmodule
