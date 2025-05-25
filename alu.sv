// 3 operation ALU:
// 00 = NOT a
// 01 = a AND b
// 10 = a ADD b

module alu(
    input logic [15:0] a,
    input logic [15:0] b,
    input logic [1:0] sel,
    output logic [15:0] o
);
    always_comb begin
        case (sel)
            2'b00: o = ~a;
            2'b01: o = a & b;
            2'b10: o = a + b;
            default: o = 0;
        endcase
    end
endmodule
