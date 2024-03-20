`timescale 1ns / 1ps

module MemoryStage(
    input logic MEM_CLK,
    input logic [31:0] ALU_RESULT,
    input logic [31:0] RS_2,
    input logic MEM_RAW_MEMBUSY_2,
    input logic MEM_RAW_IOBUS_WR,
    output logic MEMBUSY_2,
    output logic IOBUS_WR,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR
    );
    
    always_ff @ (posedge MEM_CLK) begin
        MEMBUSY_2 <= MEM_RAW_MEMBUSY_2;
        IOBUS_WR <= MEM_RAW_IOBUS_WR;
        IOBUS_OUT <= RS_2;
        IOBUS_ADDR <= ALU_RESULT;
    end
    
endmodule
