// 16 bit positive edge triggered register.
// On positive edge, input data is read into latch 1.
// On negative edge, this is transferred to latch 2.

module register(
    input logic clk,
    input logic write_en,
    input logic [15:0] in_data,
    output logic [15:0] out_data
);
    // Data for latch 1 (intermediate) and latch 2 (output).
    logic [15:0] latch1_data, latch2_data;

    always_ff @(posedge clk) begin
        if (write_en) begin
            latch1_data <= in_data;
        end
    end
    always_ff @(negedge clk) begin
        latch2_data <= latch1_data;
    end

    always_comb begin
        out_data = latch2_data;
    end

    // Helper
    function static void set_data(input logic [15:0] data);
        latch1_data = data;
        latch2_data = data;
    endfunction
endmodule
