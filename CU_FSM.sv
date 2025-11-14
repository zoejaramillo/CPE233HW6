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

    typedef enum logic [1:0] {ST_init, ST_fetch, ST_exec} STATES; //all states
    STATES PS, NS;

    always_ff @(posedge CLK) begin
        if (RST) PS <= ST_init;
        else     PS <= NS;
    end

    always_comb begin //set all inputs to zero
        PCWrite  = 0;
        regWrite = 0;
        memWE2   = 0;
        memRDEN1 = 0;
        memRDEN2 = 0;
        reset    = 0;
        NS       = PS;

        case (PS)

            ST_init: begin //initial state
                reset = 1; 
                NS = ST_fetch;
            end

            ST_fetch: begin //fetch state
                memRDEN1 = 1; 
                PCWrite  = 1;
                NS = ST_exec;
            end

            ST_exec: begin //execute state
                unique case (opcode)
                    7'b0110011: regWrite = 1; // rtype
                    7'b0000011: begin         // lw
                        memRDEN2 = 1;
                        regWrite = 1;
                    end
                    7'b0010011: regWrite = 1; // addi
                    7'b0100011: memWE2   = 1; // sw
                    7'b0110111: regWrite = 1; // lui
                endcase

                NS = ST_fetch; //end
            end 
        endcase
    end
endmodule
