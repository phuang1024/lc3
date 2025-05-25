// Testbench for register

module tb_register();
    logic clk;
    logic write_en;
    logic [15:0] in;
    logic [15:0] out;

    register uut(clk, write_en, in, out);

    initial begin
        clk = 0;
        forever #5
            clk = ~clk;
    end

    always @(clk) begin
        $display("time=%2t, clk=%b, write_en=%b, in=%b, out=%b, latch1=%b, latch2=%b", $time, clk, write_en, in, out, uut.latch1_data, uut.latch2_data);
        //#1;
    end

    initial begin
        write_en = 0;
        in = 0;
        @(posedge clk);  // t = 5

        write_en = 0;
        in = -1;
        @(posedge clk);  // t = 15

        write_en = 1;
        @(posedge clk);  // t = 25

        write_en = 0;
        in = 0;
        @(posedge clk);  // t = 35

        write_en = 1;
        @(posedge clk);  // t = 45

        /*
        @(posedge clk);  // t = 5
        write_en = 1;
        in = -1;
        @(posedge clk);  // t = 15
        @(posedge clk);  // t = 25
        */

        $finish;
    end
endmodule
