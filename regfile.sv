// LC3 register file: 8 registers.

module regfile(
    input logic clk,
    input logic write_en,
    input logic [2:0] sel_in,
    input logic [2:0] sel_out1,
    input logic [2:0] sel_out2,
    input logic [15:0] in_data,
    output logic [15:0] out1_data,
    output logic [15:0] out2_data
);
    logic [7:0] write_en_per;
    logic [7:0][15:0] out_data_per;

    register regs[7:0](clk, write_en_per, in_data, out_data_per);

    // We don't actually need decoder in Verilog.
    // logic [7:0] dec_out;
    // decoder dec(sel, dec_out);

    mux3 mux1(out_data_per, sel_out1, out1_data);
    mux3 mux2(out_data_per, sel_out2, out2_data);

    always_comb begin
        for (int i = 0; i < 8; i++)
            write_en_per[i] = 0;
        write_en_per[sel_in] = write_en;
    end
endmodule
