module BCG(
input logic [31:0] rs1,
input logic [31:0] rs2,
output logic br_eq,
output logic br_lt,
output logic br_ltu
);

always_comb begin
    br_eq  = 0;
    br_lt  = 0;
    br_ltu = 0;

    if (rs1 == rs2)
        br_eq = 1;

    if ($signed(rs1) < $signed(rs2))
        br_lt = 1;

    if (rs1 < rs2)
        br_ltu = 1;
end
       
endmodule