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

    task static init_regs();
        ctrl.dp.regs.regs[0].set_data(0);
        ctrl.dp.regs.regs[1].set_data(1);
        ctrl.dp.regs.regs[2].set_data(2);
        ctrl.dp.regs.regs[3].set_data(3);
        ctrl.dp.regs.regs[4].set_data(4);
        ctrl.dp.regs.regs[5].set_data(5);
        ctrl.dp.regs.regs[6].set_data(6);
        ctrl.dp.regs.regs[7].set_data(7);
    endtask

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

    task static test_program();
        init_regs();
        ctrl.dp.pc.set_data(0);
        ctrl.dp.mem.mem[0] = 16'b1001_000_111_111111;

        ctrl.exec_instruction();
        $display("R0=%b", ctrl.dp.regs.regs[0].out_data);
    endtask

    initial begin
        //test_load_ir();
        test_program();
        $finish;
    end
endmodule
