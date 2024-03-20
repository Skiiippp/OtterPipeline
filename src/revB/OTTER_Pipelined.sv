//CPE333 Lab3 Pipelined Otter. James Gruber, Braydon Burkhardt - rev B

`timescale 1ns / 1ps

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
        
typedef struct packed{
    opcode_t opcode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic rs1_used;
    logic rs2_used;
    logic rd_used;
    logic [3:0] alu_fun;
    logic memWrite;
    logic memRead2;
    logic regWrite;
    logic [1:0] rf_wr_sel;
    logic [2:0] mem_type;  //sign, size
    logic [31:0] pc;
    logic [31:0] IR;
    logic [31:0] I_immed;
} instr_t;

module OTTER_MCU(
    input CLK,
    input RESET,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR,
    output logic IOBUS_WR 
);    
       
    logic [6:0] opcode;
    logic [31:0] pc, pc_value, next_pc, jalr_pc, branch_pc, jump_pc, int_pc;
    logic [31:0] A,B,I_immed,S_immed,U_immed,aluBin,aluAin,aluResult,RF_WD,csr_reg, mem_data;
    
    logic [31:0] IR;
    logic memRead1,memRead2;
    
    logic pcWrite,regWrite,memWrite, op1_sel,mem_op,IorD,pcWriteCond,memRead;
    logic [1:0] opB_sel, rf_sel, wb_sel, mSize;
    logic [1:0] pc_sel;
    logic [3:0]alu_fun;
    logic opA_sel;
    
    logic br_lt,br_eq,br_ltu;
    
    logic [31:0] cycles=0;
 
              
// ###### IF: FETCH ######
     logic [31:0] if_de_pc;
     logic if_de_zcs=1'b0;
     
     always_ff @(posedge CLK) begin
                if_de_pc <= pc;
     end
     
     assign pcWrite = 1'b1; 	//Hardwired high, assuming no hazards
     assign memRead1 = 1'b1; 	//Fetch new instruction every cycle
     
     //pc target calculations 
    assign next_pc = pc + 4;    //PC is byte aligned, memory is word aligned
    assign jalr_pc = de_ex_inst.I_immed + de_ex_A;
    
    assign branch_pc = de_ex_inst.pc + {{20{de_ex_inst.IR[31]}},de_ex_inst.IR[7],de_ex_inst.IR[30:25],de_ex_inst.IR[11:8],1'b0};   //byte aligned addresses
    assign jump_pc = de_ex_inst.pc + {{12{de_ex_inst.IR[31]}}, de_ex_inst.IR[19:12], de_ex_inst.IR[20],de_ex_inst.IR[30:21],1'b0};
    assign int_pc = 0;
     
    ProgCount PC (.PC_CLK(CLK), .PC_RST(RESET), .PC_LD(pcWrite),
                 .PC_DIN(pc_value), .PC_COUNT(pc));   

    // Creates a 2-to-1 multiplexor used to select the source of the next PC
    Mult6to1 PCdatasrc (next_pc, jalr_pc, branch_pc, jump_pc, mtvec, mepc, {2'b00, pc_sel}, pc_value);         
                         
     OTTER_mem_byte #(14) memory  (.MEM_CLK(CLK),.MEM_ADDR1(pc),.MEM_ADDR2(ex_mem_aluRes),.MEM_DIN2(ex_mem_rs2),
                               .MEM_WRITE2(ex_mem_inst.memWrite),.MEM_READ1(memRead1),.MEM_READ2(ex_mem_inst.memRead2),
                               .ERR(),.MEM_DOUT1(IR),.MEM_DOUT2(mem_data),.IO_IN(IOBUS_IN),.IO_WR(IOBUS_WR),.MEM_SIZE(mem_wb_inst.mem_type[1:0]),.MEM_SIGN(mem_wb_inst.mem_type[2]));

     always_ff @(posedge CLK)
     begin
        cycles <= cycles + 1;
     end
     
// ###### DE: DECODE ######
    logic [31:0] de_ex_A;
    logic [31:0] de_ex_B;
    logic [31:0] de_ex_aluAin;
    logic [31:0] de_ex_aluBin;

    instr_t de_ex_inst, de_inst;
    
    opcode_t OPCODE;
    assign opcode = IR[6:0];
    assign OPCODE = opcode_t'(opcode);

    assign memRead2 = (OPCODE == LOAD);
    assign memWrite = (OPCODE == STORE);
    assign regWrite = (OPCODE != BRANCH && OPCODE !=STORE); // && OPCODE !=LOAD
    
    assign de_inst.rs1_addr=IR[19:15];
    assign de_inst.rs2_addr=IR[24:20];
    assign de_inst.rd_addr=IR[11:7];
    assign de_inst.opcode=OPCODE;
   
    assign de_inst.rs1_used=    de_inst.rs1_addr != 0
                                && de_inst.opcode != LUI
                                && de_inst.opcode != AUIPC
                                && de_inst.opcode != JAL;
    
    assign de_inst.alu_fun= alu_fun;
    assign de_inst.memWrite= memWrite;
    assign de_inst.memRead2= memRead2;
    assign de_inst.regWrite= regWrite;
    assign de_inst.rf_wr_sel= wb_sel;
    assign de_inst.mem_type= IR[14:12];
    assign de_inst.pc= if_de_pc;
    assign de_inst.IR=IR;
    assign de_inst.I_immed=I_immed;

	// Creates a RISC-V register file
    OTTER_registerFile RF (IR[19:15], IR[24:20], mem_wb_inst.rd_addr, RF_WD, mem_wb_inst.regWrite, A, B, CLK); // Register file

    // Generate immediates
    assign S_immed = {{20{IR[31]}},IR[31:25],IR[11:7]};
    assign I_immed = {{20{IR[31]}},IR[31:20]};
    assign U_immed = {IR[31:12],{12{1'b0}}};
    
    // Creates a 4-to-1 multiplexor used to select the B input of the ALU
    Mult4to1 ALUBinput (B, I_immed, S_immed, de_inst.pc, opB_sel, aluBin);
    Mult2to1 ALUAinput (A, U_immed, opA_sel, aluAin);
    
    OTTER_CU_Decoder CU_DECODER(.CU_OPCODE(opcode), .CU_FUNC3(IR[14:12]),.CU_FUNC7(IR[31:25]), 
             .CU_ALU_SRCA(opA_sel),.CU_ALU_SRCB(opB_sel),.CU_ALU_FUN(alu_fun),.CU_RF_WR_SEL(wb_sel));
            
     logic prev_INT=0;
    
    always_ff @ (posedge CLK)
    begin
         if(RESET)
            prev_INT=1'b0;
    end

	always_ff @(posedge CLK)
     begin
        de_ex_inst <= de_inst;
        de_ex_A <= A;
        de_ex_B <= B;
        de_ex_aluAin <= aluAin;
        de_ex_aluBin <= aluBin;
     end
     
// ###### EX: EXECUTE ######
     logic [31:0] ex_mem_rs2;
     logic [31:0] ex_mem_aluRes; // used to be = 0
     instr_t ex_mem_inst;
     logic [31:0] opA_forwarded;
     logic [31:0] opB_forwarded;
     
     Gen Gen(.CU_OPCODE(de_ex_inst.IR[6:0]), .CU_FUNC3(de_ex_inst.IR[14:12]),.CU_BR_EQ(br_eq),.CU_BR_LT(br_lt),
        .CU_BR_LTU(br_ltu),.CU_PCSOURCE(pc_sel));
 
     // Creates a RISC-V ALU
    OTTER_ALU ALU (de_ex_inst.alu_fun, de_ex_aluAin, de_ex_aluBin, aluResult); // the ALU
    
    //Branch Condition Generator
    always_comb
    begin
        br_lt=0; br_eq=0; br_ltu=0;
        if($signed(de_ex_A) < $signed(de_ex_B)) br_lt=1;
        if(de_ex_A==de_ex_B) br_eq=1;
        if(de_ex_A<de_ex_B) br_ltu=1;
    end
     



    always_ff @(posedge CLK)
     begin
        ex_mem_inst <= de_ex_inst;
        ex_mem_rs2 <= de_ex_B;
        ex_mem_aluRes <= aluResult;
     end
     
// ###### MEM: MEMORY ######
     instr_t mem_wb_inst;
     logic [31:0] mem_wb_aluRes;
     
    assign IOBUS_ADDR = ex_mem_aluRes;
    assign IOBUS_OUT = ex_mem_rs2;
    
 
 
 
     always_ff @(posedge CLK)
     begin
        mem_wb_inst <= ex_mem_inst;
        mem_wb_aluRes <= ex_mem_aluRes;
     end
     
// ###### WB: WRITEBACK ######
     
    //Creates 4-to-1 multiplexor used to select reg write back data
    assign mem_wb_next_pc = mem_wb_inst.pc + 4;
    //Mult4to1 regWriteback (mem_wb_next_pc,csr_reg,mem_data,mem_wb_aluRes,mem_wb_inst.rf_wr_sel,RF_WD);
    case(mem_wb_inst.rf_wr_sel) begin
        2'b00: RF_WD = mem_wb_next_pc;
        2'b01: RF_WD = csr_reg;
        2'b10: RF_WD = mem_data;
        2'b11: RF_WD = mem_wb_aluRes;
    endcase
     
endmodule
