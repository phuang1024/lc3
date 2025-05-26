module tb_memory();
    logic clk, write_en;
    logic [15:0] addr, in_data, out_data;
    memory uut(clk, write_en, addr, in_data, out_data);

    initial begin
        clk = 0;
        forever #5
            clk = ~clk;
    end

    initial begin
        $monitor("time=%2t, write_en=%b, addr=%h, in_data=%h, out_data=%h", $time, write_en, addr, in_data, out_data);
    end

    initial begin
        write_en = 0;
        addr = 0;
        in_data = 0;

        // Write to address 0
        @(posedge clk);  // t = 5
        write_en = 1;
        in_data = 16'h1234;  // Write value
        addr = 16'h0000;     // Address to write
        @(posedge clk);      // t = 15

        // Read from address 0
        write_en = 0;
        @(posedge clk);      // t = 25

        // Write to address 1
        write_en = 1;
        in_data = 16'h5678;  // Write value
        addr = 16'h0001;     // Address to write
        @(posedge clk);      // t = 35

        // Read from address 1
        write_en = 0;
        @(posedge clk);      // t = 45

        $finish;
    end
endmodule
