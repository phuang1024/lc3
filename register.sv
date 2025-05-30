// 16 bit positive edge triggered register.
// On positive edge, input data is read into latch 1.
// On negative edge, this is transferred to latch 2.

module register#(
    parameter WIDTH = 16
)(
    input logic clk,
    input logic write_en,
    input logic [WIDTH-1:0] in_data,
    output logic [WIDTH-1:0] out_data
);
    always_ff @(posedge clk) begin
        if (write_en) begin
            out_data <= in_data;
        end
    end

    // Helper function to set data.
    function static void set_data(input logic [WIDTH-1:0] data);
        out_data = data;
    endfunction
endmodule
