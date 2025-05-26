// Tri state buffer.

module tribuf(
    input logic [15:0] data_in,
    input logic enable,
    output logic [15:0] data_out
);
    always_comb begin
        if (enable)
            data_out = data_in;
        else
            data_out = 16'bzzzzzzzzzzzzzzzz;
    end
endmodule
