// 16 bit addressable word size, 16 bit address memory.
// For now, we omit "ready" and treat it like a regfile.
// Reading from memory to register takes 2 clock cycles. The first moves the data
// into out_data, and the second reads it into whatever register is connected.

module memory(
    input logic clk,
    input logic write_en,
    input logic [15:0] addr,
    input logic [15:0] in_data,
    output logic [15:0] out_data
    //output logic ready
);
    bit [15:0] mem[65536];

    always_ff @(posedge clk) begin
        if (write_en) begin
            mem[addr] <= in_data;
        end else begin
            out_data <= mem[addr];
        end
    end
endmodule
