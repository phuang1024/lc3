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
        bit [15:0] m[65536];  // For convenience.
        init_regs();
        ctrl.dp.pc.set_data(0);

        // Program counts number of negative values beginning at x2000.
        // Ends when a value 0 is reached.
        m[0] = 16'b0101_000_000_1_00000;  // AND R0, R0, #0
        m[1] = 16'b0010_001_000000111;  // LD R1, #7 (m[9])
        m[2] = 16'b0110_010_001_000000;  // LDR R2, R1, #0
        m[3] = 16'b0000_010_000000100;  // BRz #4 (m[8])
        m[4] = 16'b0000_001_000000001;  // BRp #1 (m[6])
        m[5] = 16'b0001_000_000_1_00001;  // ADD R0, R0, #1
        m[6] = 16'b0001_001_001_1_00001;  // ADD R1, R1, #1
        m[7] = 16'b0000_111_111111010;  // BRnzp #-6 (m[2])
        m[8] = 16'b1111_0000_00000000;  // TRAP
        m[9] = 16'h2000;  // x2000

        m['h2000] = 1;
        m['h2001] = 2;
        m['h2002] = -1;
        m['h2003] = 3;
        m['h2004] = -2;
        m['h2005] = -3;
        m['h2006] = 4;
        m['h2007] = 0;

        ctrl.dp.mem.mem = m;
        repeat (100) begin
            ctrl.exec_instruction();
            print();
        end
    endtask

    initial begin
        test_program();
        $finish;
    end
endmodule
