module tb_regfile();
    logic clk;
    logic write_en;
    logic [2:0] sel_in;
    logic [2:0] sel_out1;
    logic [2:0] sel_out2;
    logic [15:0] in;
    logic [15:0] out1;
    logic [15:0] out2;

    regfile rf(clk, write_en, sel_in, sel_out1, sel_out2, in, out1, out2);

    initial begin
        clk = 0;
        forever #5
            clk = ~clk;
    end

    always @(clk) begin
        #1;  // Wait for register to store value.
        $display("time=%2t, clk=%b, write_en=%b, sel_in=%b, sel_out1=%b, sel_out2=%b, in=%b, out1=%b, out2=%b",
            $time, clk, write_en, sel_in, sel_out1, sel_out2, in, out1, out2);
    end

    initial begin
        write_en = 0;
        sel_in = 0;
        sel_out1 = 0;
        sel_out2 = 0;
        in = 0;
        @(posedge clk);  // t = 5;

        write_en = 1;
        in = -1;
        @(posedge clk);  // t = 15;
        @(posedge clk);  // t = 25;

        write_en = 0;
        in = 0;
        @(posedge clk);  // t = 35;
        @(posedge clk);  // t = 45;

        sel_in = 1;
        sel_out1 = 1;
        @(posedge clk);  // t = 55;
        @(posedge clk);  // t = 65;

        write_en = 1;
        in = 1;
        @(posedge clk);  // t = 75;
        @(posedge clk);  // t = 85;

        write_en = 0;
        sel_in = 0;
        sel_out1 = 0;
        @(posedge clk);  // t = 95;
        @(posedge clk);  // t = 105;

        $finish;
    end
endmodule
