`timescale 1ns / 1ps

module reg_file(
    input CLK,
    input RF_en,
    input [19:15] RF_adr1,
    input [24:20] RF_adr2,
    input [11:7] RF_wa,
    input [31:0] RF_wd,
    output [31:0] RF_rs1,
    output [31:0] RF_rs2
);
    logic [31:0] ram[0:31]; //array of vectors
    initial begin
        static int i = 0;
        for (i = 0; i < 32; i++) begin
            ram[i] = 0; //memeory @ 0
        end
    end
    
    //asynch reads using assign statements
    assign RF_rs1 = ram[RF_adr1];
    assign RF_rs2 = ram[RF_adr2];
    
    //synch write
    always_ff @ (posedge CLK) begin

        if (RF_en == 1 && RF_wa > 0) begin
            ram[RF_wa] = RF_wd;
        end
    end
endmodule
