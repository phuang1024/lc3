module tb_sext;
    logic [15:0] in_data, out_data5, out_data8;

    sext#(5) sext5(in_data[4:0], out_data5);
    sext#(8) sext8(in_data[7:0], out_data8);

    initial begin
        $monitor("in_data=%b, out_data5=%b, out_data8=%b", in_data, out_data5, out_data8);
    end

    initial begin
        in_data = 16'b1010101010101010;
        #10;

        $finish;
    end
endmodule
