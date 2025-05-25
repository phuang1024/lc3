// Testbench for decoder

module tb_decoder();
    logic [2:0] in;
    logic [7:0] out;

    decoder uut(.in(in), .out(out));

    initial begin
        // Test all possible inputs
        for (int i = 0; i < 8; i++) begin
            in = i[2:0];
            #10;
            $display("Input: %b, Output: %b", in, out);
        end

        $finish;
    end
endmodule
