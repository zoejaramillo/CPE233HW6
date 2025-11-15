`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 08:48:54 PM
// Design Name: 
// Module Name: CPU
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
module CPU(
  input CLK,
   input RST,
   input INTR = 0,
   input [31:0] IOBUS_IN = 0,
   output [31:0] IOBUS_OUT,
   output [31:0] IOBUS_ADDR,
   output IOBUS_WR
    );

//imms
logic [31:0] Jtype,Btype, Itype, Utype, Stype;
logic [31:0] jalr, branch, jal;

//mem
logic [31:0] IR;   
logic [31:0] MEM_DOUT2; 
logic MEM_RDEN1;     //from CU_FSM  
logic MEM_RDEN2;     //from CU_FSM  
logic MEM_WE2;       //from CU_FSM  

//ALU
logic [3:0]  ALU_FUN;         
logic [31:0] ALU_RESULT, ALU_A, ALU_B;

//Decoder ALU inputs
logic        ALU_SRC_A;         
logic [1:0]  ALU_SRC_B; 

//PC write
logic [31:0] PC;                // output of PC
logic [31:0] PC_Din;            // output of PC mux to PC input
logic        PC_WRITE;          // from CU_FSM to PC

//RegFile
logic [31:0] RF_wd, RF_rs1, RF_rs2;   //from regfile
logic [31:0] CSR_REG;
logic [4:0] RF_adr1; 
logic [4:0] RF_adr2; 
logic [4:0] RF_wa;  


assign CSR_REG = 32'b0;
assign RF_adr1 = IR[19:15];
assign RF_adr2 = IR[24:20];
assign RF_wa   = IR[11:7]; 
 
assign IOBUS_OUT  = RF_rs2;
assign IOBUS_ADDR = ALU_RESULT;

logic RF_WRITE;                 //from CU_FSM, also en
logic [1:0] RF_WR_SEL;          //from decoder

reg_file regfile (
    .CLK    (CLK),
    .RF_en  (RF_WRITE), //RF_en and RF_WRITE
    .RF_adr1(RF_adr1),
    .RF_adr2(RF_adr2),
    .RF_wa  (RF_wa),
    .RF_wd  (RF_wd),
    .RF_rs1 (RF_rs1),
    .RF_rs2 (RF_rs2)
);

//Reg_File Mux
always_comb begin
    case (RF_WR_SEL)
        2'b00: RF_wd = PC_PLUS4;           // JAL writes PC+4
        2'b01: RF_wd = CSR_REG;     
        2'b10: RF_wd = MEM_DOUT2;    
        2'b11: RF_wd = ALU_RESULT;   
        default: RF_wd = ALU_RESULT;
    endcase
end


ALU alu (.ALU_A(ALU_A), 
         .ALU_B(ALU_B), 
         .ALU_RESULT(ALU_RESULT), 
         .ALU_FUN(ALU_FUN)
         );
//ALU Source A MUX
always_comb begin
    case (ALU_SRC_A)
        1'b0: ALU_A = RF_rs1;   
        1'b1: ALU_A = Utype;   
        default: ALU_A = RF_rs1;
    endcase
end

//ALU Source B Mux
always_comb begin
    case (ALU_SRC_B)
        2'b00: ALU_B = RF_rs2;   // R-type
        2'b01: ALU_B = Itype;    // I-type  
        2'b10: ALU_B = Stype;    // S-type 
        2'b11: ALU_B = PC;        
        default: ALU_B = RF_rs2;
    endcase
end        



IMMED_GEN imm (
    .IR(IR),
    .Utype(Utype),
    .Itype(Itype),
    .Stype(Stype),
    .Jtype(Jtype),
    .Btype(Btype)
); 


//PC MUX
logic [1:0]  PC_SOURCE;         
logic [31:0] PC_PLUS4;    // PC + 4

assign PC_PLUS4 = PC + 32'd4;

PC pc (.CLK(CLK), 
       .PC_Din(PC_Din), 
       .PC_WRITE(PC_WRITE), 
       .PC_RST(RST), 
       .PC(PC)
       );


//PC Mux 
always_comb begin
    case (PC_SOURCE)
        2'b00: PC_Din = PC_PLUS4;   
        2'b01: PC_Din = jalr;       
        2'b10: PC_Din = branch;    
        2'b11: PC_Din = jal;      
        default: PC_Din = PC_PLUS4;
    endcase
end

//BAG
BAG bag(
    .Jtype(Jtype),    
    .Btype(Btype),   
    .PC(PC),      
    .Itype(Itype),   
    .rs1(RF_rs1),   
    .jal(jal),    
    .branch(branch),   
    .jalr(jalr)      
);

//BCG
logic br_eq, br_lt, br_ltu;
BCG bcg(
    .rs1(RF_rs1),  
    .rs2(RF_rs2),  
    .br_eq(br_eq),   
    .br_lt(br_lt),    
    .br_ltu(br_ltu)    
    );
   
  

Memory mem (
    .MEM_CLK   (CLK),
    .MEM_RDEN1 (MEM_RDEN1),       
   .MEM_RDEN2 (MEM_RDEN2),      
    .MEM_WE2   (MEM_WE2),          

    .MEM_ADDR1 (PC[15:2]),        
    .MEM_ADDR2 (ALU_RESULT),       
    .MEM_DIN2  (RF_rs2),          

    .MEM_SIZE  (IR[13:12]), 
    .MEM_SIGN  (IR[14]),   

    .IO_IN     (IOBUS_IN),        
    .IO_WR     (IOBUS_WR),        

    .MEM_DOUT1 (IR),     
    .MEM_DOUT2 (MEM_DOUT2)        
);

//Decoder
CU_DCDR cu_dcdr (
    .ir        (IR),       
  .br_eq     (br_eq),      
    .br_lt     (br_lt),     
    .br_ltu    (br_ltu),    

    .alu_fun   (ALU_FUN),   
    .alu_srcA  (ALU_SRC_A), 
    .alu_srcB  (ALU_SRC_B),  
    .pcSource  (PC_SOURCE), 
    .rf_wr_sel (RF_WR_SEL)   
);

//FSM
logic FSM_reset;   

CU_FSM cu_fsm (
    .CLK(CLK),
    .RST(RST),
    .INTR(INTR),
    .opcode(IR[6:0]),    
    .PCWrite(PC_WRITE),   
    .regWrite(RF_WRITE),   
    .memWE2(MEM_WE2),   
    .memRDEN1(MEM_RDEN1),  
    .memRDEN2(MEM_RDEN2),  
    .reset(FSM_reset)   
);

endmodule
