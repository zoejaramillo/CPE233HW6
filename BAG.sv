`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2025 12:29:35 PM
// Design Name: 
// Module Name: BAG
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


module BAG(
input [31:0] Jtype,
input [31:0] Btype,
input [31:0] PC, 
input [31:0] Itype,
input [31:0] rs1,
output [31:0] jal,
output [31:0] branch,
output [31:0] jalr
    );

assign jal = $signed(PC) + $signed(Jtype);
assign jalr = $signed(Itype) + $signed(rs1);
assign branch = $signed(PC) + $signed(Btype);

   
endmodule
