module tb_control();
    control ctrl();

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

    task static print();
        $display("t=%2t, IR=%b, PC=%b, R0=%b, R1=%b, R2=%b, R3=%b, R4=%b, R5=%b, R6=%b, R7=%b, cc=%b",
                 $time, ctrl.dp.ir.out_data, ctrl.dp.pc.out_data, ctrl.dp.regs.regs[0].out_data,
                 ctrl.dp.regs.regs[1].out_data, ctrl.dp.regs.regs[2].out_data, ctrl.dp.regs.regs[3].out_data,
                 ctrl.dp.regs.regs[4].out_data, ctrl.dp.regs.regs[5].out_data, ctrl.dp.regs.regs[6].out_data,
                 ctrl.dp.regs.regs[7].out_data, ctrl.dp.cc.out_data);
    endtask

    task static test_program();
        init_regs();
        ctrl.dp.pc.set_data(0);
        ctrl.dp.mem.mem[0] = 16'b0010_000_000001010;  // LD R0, #10
        ctrl.dp.mem.mem[1] = 16'b0110_000_000_000000;  // LDR R0, R0, #0
        ctrl.dp.mem.mem[2] = 16'b1010_000_000001010;  // LDI R0, #10
        ctrl.dp.mem.mem[11] = 12;
        ctrl.dp.mem.mem[12] = -1001;
        ctrl.dp.mem.mem[13] = 11;

        repeat (3) begin
            ctrl.exec_instruction();
            print();
        end
    endtask

    initial begin
        test_program();
        $finish;
    end
endmodule
