// Variable input width sign extender.

module sext#(
    parameter int WIDTH
)(
    input logic [WIDTH-1:0] in_data,
    output logic [15:0] out_data
);
    always_comb begin
        if (in_data[WIDTH-1]) begin
            // Sign extend
            out_data = {{16-WIDTH{1'b1}}, in_data};
        end else begin
            // Zero extend
            out_data = {{16-WIDTH{1'b0}}, in_data};
        end
    end
endmodule
