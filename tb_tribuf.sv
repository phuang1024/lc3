module tb_tribuf;
    logic [15:0] data_in, data_out;
    logic enable;
    tribuf uut(data_in, enable, data_out);

    initial begin
        enable = 0;
        data_in = 0;
        #10;

        enable = 1;
        #10;

        enable = 0;
        data_in = -1;
        #10;

        enable = 1;
        #10;

        $finish;
    end

    initial begin
        $monitor("en=%b, in=%b, out=%b", enable, data_in, data_out);
    end
endmodule
