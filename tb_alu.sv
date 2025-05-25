module tb_alu();
    logic [15:0] a, b, o;
    logic [1:0] sel;

    alu uut(a, b, sel, o);

    initial begin
        // Test NOT
        sel = 2'b00;
        a = 0;
        #10;
        a = 100;
        #10;

        // Test AND
        sel = 2'b01;
        a = 16'b1111000011110000;
        b = 16'b1111111100000000;
        #10;

        // Test ADD
        sel = 2'b10;
        a = 3;
        b = 2;
        #10;
        b = -1;
        #10;

        $finish;
    end

    initial begin
        $monitor("t=%2t, sel=%b, a=%b, b=%b, o=%b", $time, sel, a, b, o);
    end
endmodule
