module tb_control();
    control ctrl();

    always @(posedge ctrl.clk) begin
        $display("t=%2t, pc=%b, ir=%b", $time, ctrl.dp.pc.out_data, ctrl.dp.ir.out_data);
    end

    initial begin
        ctrl.clk = 0;
        forever #5
            ctrl.clk = ~ctrl.clk;
    end

    task static test_load_ir();
        ctrl.dp.pc.set_data(0);
        ctrl.dp.mem.mem[0] = 0;
        ctrl.dp.mem.mem[1] = 1;
        ctrl.dp.mem.mem[2] = 2;
        ctrl.dp.mem.mem[3] = 3;

        ctrl.load_ir();
        $display("%t", $time);
        ctrl.load_ir();
        $display("%t", $time);
        ctrl.load_ir();
        $display("%t", $time);
        ctrl.load_ir();
        $display("%t", $time);
    endtask

    initial begin
        test_load_ir();
        $finish;
    end
endmodule
