module CU_FSM(
    input CLK,
    input RST,
    input INTR,
    input [6:0] opcode,
    output logic PCWrite,
    output logic regWrite,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset
    );

    typedef enum logic [1:0] {ST_init, ST_fetch, ST_exec} STATES;
    STATES PS, NS;

    always_ff @(posedge CLK) begin
        if (RST) PS <= ST_init;
        else     PS <= NS;
    end

    always_comb begin
        PCWrite  = 0;
        regWrite = 0;
        memWE2   = 0;
        memRDEN1 = 0;
        memRDEN2 = 0;
        reset    = 0;
        NS       = PS;

        case (PS)

            ST_init: begin
                reset = 1;
                NS = ST_fetch;
            end

            ST_fetch: begin
                memRDEN1 = 1;
                PCWrite  = 1;
                NS = ST_exec;
            end

            ST_exec: begin
                unique case (opcode)
                    7'b0110011: regWrite = 1; // R-type
                    7'b0000011: begin         // LW
                        memRDEN2 = 1;
                        regWrite = 1;
                    end
                    7'b0010011: regWrite = 1; // ADDI etc
                    7'b0100011: memWE2   = 1; // SW
                    7'b0110111: regWrite = 1; // LUI
                endcase

                NS = ST_fetch;
            end
        endcase
    end
endmodule
