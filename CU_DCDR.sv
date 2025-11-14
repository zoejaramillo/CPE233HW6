`timescale 1ns / 1ps

module CU_DCDR(
    input  [31:0] ir,      //ir pathing
    input         br_eq,
    input         br_lt,
    input         br_ltu,

    output logic [3:0] alu_fun,
    output logic       alu_srcA,
    output logic [1:0] alu_srcB,
    output logic [1:0] pcSource,
    output logic [1:0] rf_wr_sel
);

    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;

    always_comb begin
        // decode fields from ir EVERY TIME
        opcode = ir[6:0];
        func3  = ir[14:12];
        func7  = ir[31:25];

        // defaults
        alu_fun   = 4'b0000;
        alu_srcA  = 1'b0;
        alu_srcB  = 2'b00;
        rf_wr_sel = 2'b00;
        pcSource  = 2'b00;

        case (opcode)
            //rtype
            7'b0110011: begin
                alu_fun   = {func7[5], func3}; //30thbit and func3 bits
                alu_srcA  = 1'b0;
                alu_srcB  = 2'b00;
                rf_wr_sel = 2'b11;   // 3
                pcSource  = 2'b00;
            end

            //itype
            7'b0010011: begin
                if (func3 == 3'b101) //sra
                    alu_fun = {func7[5], func3}; //30th bit and func3 bits
                else
                    alu_fun = {1'b0, func3};
                alu_srcA  = 1'b0;
                alu_srcB  = 2'b01;
                rf_wr_sel = 2'b11;   // 3
                pcSource  = 2'b00;
            end

            // jalr
            7'b1100111: begin
                rf_wr_sel = 2'b00;   // pc+4
                pcSource  = 2'b01;   
            end

            // load
            7'b0000011: begin
                alu_fun   = 4'b0000;
                alu_srcA  = 1'b0;
                alu_srcB  = 2'b01;
                rf_wr_sel = 2'b10;   
                pcSource  = 2'b00;
            end

            // store
            7'b0100011: begin
                alu_fun   = 4'b0000;
                alu_srcA  = 1'b0;
                alu_srcB  = 2'b10;
                pcSource  = 2'b00;
            end

            //branching, only need beq for hw6
            7'b1100011: begin
                case (func3)
                    3'b000: if (br_eq)           pcSource = 2'b10; // beq
                    3'b001: if (~br_eq)          pcSource = 2'b10; // bne
                    3'b101: if (br_eq || ~br_lt) pcSource = 2'b10; // bge
                    3'b111: if (br_eq || ~br_ltu)pcSource = 2'b10; // bgeu
                    3'b100: if (~br_eq || br_lt) pcSource = 2'b10; // blt
                    3'b110: if (~br_eq || br_ltu)pcSource = 2'b10; // bltu
                endcase
            end

            //lui, utype
            7'b0110111: begin
                alu_fun   = 4'b1001; // only one with 1001
                alu_srcA  = 1'b1;    
                rf_wr_sel = 2'b11;   
                pcSource  = 2'b00;
            end

            //auipic, utype for fphw
            7'b0010111: begin
                alu_fun   = 4'b0000; //add
                alu_srcA  = 1'b1;    
                alu_srcB  = 2'b11;   
                rf_wr_sel = 2'b11;
                pcSource  = 2'b00;
            end

            // jal
            7'b1101111: begin
                rf_wr_sel = 2'b00;   // pc+4
                pcSource  = 2'b11;   
            end
        endcase
    end

endmodule
