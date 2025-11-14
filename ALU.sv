`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 03:52:20 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] ALU_A,
    input [31:0] ALU_B,
    input [3:0] ALU_FUN,
    output logic [31:0] ALU_RESULT
    );
    
    always_comb begin
    case(ALU_FUN)
        4'b0000 : ALU_RESULT = ALU_A + ALU_B; //add
        4'b1000 : ALU_RESULT = ALU_A - ALU_B;//sub
        4'b0110 : ALU_RESULT = ALU_A | ALU_B;//or
        4'b0111 : ALU_RESULT = ALU_A & ALU_B;//and
        4'b0100 : ALU_RESULT = ALU_A ^ ALU_B;//((ALU_A | ~(ALU_B)) & (~(ALU_A) | (ALU_B))) ; //xor gate
        4'b0101 : ALU_RESULT = ALU_A >> ALU_B[4:0];//srl
        4'b0001 : ALU_RESULT = ALU_A << ALU_B[4:0];//sll
        4'b1101 : ALU_RESULT = $signed(ALU_A) >>> ALU_B[4:0];//sra
        4'b0010 : ALU_RESULT = $signed(ALU_A) < $signed(ALU_B);//slt
        4'b0011 : ALU_RESULT = ALU_A < ALU_B;//sltu
        4'b1001 : ALU_RESULT = (ALU_A);//luicopy
        default : ALU_RESULT = 32'h00000000;
                  
    endcase
    end
endmodule
