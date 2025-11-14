`timescale 1ns / 1ps
 

module IMMED_GEN(
    input [31:0] IR,
    output [31:0] Jtype,
    output [31:0] Btype,
    output [31:0] Utype,
    output [31:0] Itype,
    output [31:0] Stype
    );
    //used manual to assign each type
    assign Itype = {{21{IR[31]}}, IR[30:25], IR[24:20]};
    assign Stype = {{21{IR[31]}}, IR[30:25], IR[11:7]};  
    assign Btype = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
    assign Utype = {IR[31:12], 12'b0};
    assign Jtype = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0};
       
endmodule