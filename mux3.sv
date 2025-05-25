// 8 addr (3 bit) mux, 16 bit word
// This module can be used for lower level muxes as well (not using all addrs).

module mux3(
    input logic [7:0][15:0] in,
    input logic [2:0] sel,
    output logic [15:0] out
);
    always_comb begin
        case (sel)
            3'b000: out = in[0];
            3'b001: out = in[1];
            3'b010: out = in[2];
            3'b011: out = in[3];
            3'b100: out = in[4];
            3'b101: out = in[5];
            3'b110: out = in[6];
            3'b111: out = in[7];
            default: out = 0;
        endcase
    end
endmodule
