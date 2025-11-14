`timescale 1ns / 1ps

module CU_DCDR(
    input  [31:0] ir,       // full instruction
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
            // -------- R-TYPE --------
            7'b0110011: begin
                alu_fun   = {func7[5], func3};
                alu_srcA  = 1'b0;
                alu_srcB  = 2'b00;
                rf_wr_sel = 2'b11;   // 3
                pcSource  = 2'b00;
            end

            // -------- I-TYPE ALU --------
            7'b0010011: begin
                if (func3 == 3'b101)
                    alu_fun = {func7[5], func3};
                else
                    alu_fun = {1'b0, func3};
                alu_srcA  = 1'b0;
                alu_srcB  = 2'b01;
                rf_wr_sel = 2'b11;   // 3
                pcSource  = 2'b00;
            end

            // JALR
            7'b1100111: begin
                rf_wr_sel = 2'b00;   // PC+4
                pcSource  = 2'b01;   // JALR target
            end

            // -------- LOAD --------
            7'b0000011: begin
                alu_fun   = 4'b0000;
                alu_srcA  = 1'b0;
                alu_srcB  = 2'b01;
                rf_wr_sel = 2'b10;   // memory
                pcSource  = 2'b00;
            end

            // -------- STORE --------
            7'b0100011: begin
                alu_fun   = 4'b0000;
                alu_srcA  = 1'b0;
                alu_srcB  = 2'b10;
                pcSource  = 2'b00;
            end

            // -------- BRANCHES --------
            7'b1100011: begin
                case (func3)
                    3'b000: if (br_eq)           pcSource = 2'b10; // BEQ
                    3'b001: if (~br_eq)          pcSource = 2'b10; // BNE
                    3'b101: if (br_eq || ~br_lt) pcSource = 2'b10; // BGE
                    3'b111: if (br_eq || ~br_ltu)pcSource = 2'b10; // BGEU
                    3'b100: if (~br_eq || br_lt) pcSource = 2'b10; // BLT
                    3'b110: if (~br_eq || br_ltu)pcSource = 2'b10; // BLTU
                endcase
            end

            // -------- U-TYPE: LUI --------
            7'b0110111: begin
                alu_fun   = 4'b1001; // pass B / special
                alu_srcA  = 1'b1;    // select constant
                rf_wr_sel = 2'b11;   // ALU result
                pcSource  = 2'b00;
            end

            // -------- U-TYPE: AUIPC --------
            7'b0010111: begin
                alu_fun   = 4'b0000; // add
                alu_srcA  = 1'b1;    // PC as A
                alu_srcB  = 2'b11;   // imm as B (PC-relative)
                rf_wr_sel = 2'b11;
                pcSource  = 2'b00;
            end

            // -------- J-TYPE: JAL --------
            7'b1101111: begin
                rf_wr_sel = 2'b00;   // PC+4
                pcSource  = 2'b11;   // JAL target
            end
        endcase
    end

endmodule
