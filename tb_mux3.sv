// Testbench for decoder

module tb_mux3();
    logic [7:0][15:0] in;
    logic [2:0] sel;
    logic [15:0] out;

    mux3 uut(in, sel, out);

    initial begin
        // Initialize in.
        for (int i = 0; i < 8; i++) begin
            in[i] = i[15:0];
        end

        // Test all possible inputs
        for (int i = 0; i < 8; i++) begin
            sel = i[2:0];
            #10;
            $display("sel=%b, out=%b", sel, out);
        end

        $finish;
    end
endmodule
