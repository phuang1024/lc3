module tb_sext;
    logic [15:0] in_data, out_data1, out_data2, out_data3;

    sext#(5) sext5(in_data[4:0], out_data1);
    sext#(8) sext8(in_data[7:0], out_data2);
    sext#(8, 1) zext8(in_data[7:0], out_data3);

    initial begin
        $monitor("in_data=%b, sext5=%b, sext8=%b, zext8=%b", in_data, out_data1, out_data2, out_data3);
    end

    initial begin
        in_data = 16'b1010101010101010;
        #10;

        $finish;
    end
endmodule
