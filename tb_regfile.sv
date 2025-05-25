module tb_regfile();
    logic clk;
    logic write_en;
    logic [15:0] in;
    logic [2:0] sel;
    logic [15:0] out;

    regfile rf(clk, write_en, in, sel, out);

    initial begin
        clk = 0;
        forever #5
            clk = ~clk;
    end

    always @(clk) begin
        #1;  // Wait for register to store value.
        $display("time=%2t, clk=%b, write_en=%b, sel=%b, in=%b, out=%b", $time, clk, write_en, sel, in, out);
    end

    initial begin
        write_en = 0;
        sel = 0;
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

        sel = 1;
        @(posedge clk);  // t = 55;
        @(posedge clk);  // t = 65;

        write_en = 1;
        in = 1;
        @(posedge clk);  // t = 75;
        @(posedge clk);  // t = 85;

        write_en = 0;
        sel = 0;
        @(posedge clk);  // t = 95;
        @(posedge clk);  // t = 105;

        $finish;
    end
endmodule
