module tb_datapath;
    // Datapath control signals.
    logic clk;
    logic ld_ir;
    logic ld_reg;
    logic [2:0] dr;
    logic [2:0] sr1;
    logic [2:0] sr2;
    logic [1:0] aluk;
    logic gate_alu;
    logic a1m_sel;
    logic [1:0] a2m_sel;
    logic ld_pc;
    logic [1:0] pcmux_sel;
    logic gate_pc;
    logic marmux_sel;
    logic gate_marmux;

    datapath dp(clk, ld_ir, ld_reg, dr, sr1, sr2, aluk, gate_alu,
                a1m_sel, a2m_sel, ld_pc, pcmux_sel, gate_pc, marmux_sel,
                gate_marmux);

    // Clock
    initial begin
        clk = 0;
        forever #5
            clk = ~clk;
    end

    // Display
    always @(posedge clk) begin
        $display("t=%2t, bus=%b", $time, dp.bus);
    end

    // Initialize all signals.
    task static init_signals();
        ld_ir = 0;
        ld_reg = 0;
        dr = 0;
        sr1 = 0;
        sr2 = 0;
        aluk = 0;
        gate_alu = 0;
        a1m_sel = 0;
        a2m_sel = 0;
        ld_pc = 0;
        pcmux_sel = 0;
        gate_pc = 0;
        marmux_sel = 0;
        gate_marmux = 0;
    endtask

    // Initialize registers in regfile: Register i has value i.
    task static init_regs();
        dp.regs.regs[0].set_data(0);
        dp.regs.regs[1].set_data(1);
        dp.regs.regs[2].set_data(2);
        dp.regs.regs[3].set_data(3);
        dp.regs.regs[4].set_data(4);
        dp.regs.regs[5].set_data(5);
        dp.regs.regs[6].set_data(6);
        dp.regs.regs[7].set_data(7);
    endtask

    // Test add two registers.
    // IR: R5 <= R5 + R6
    // Effect: BUS = R5 + R6
    task static test_add();
        // Manually load IR (necessary for sr2mux).
        dp.ir.set_data(16'b0001_101_101_000_110);
        sr1 = 5;
        sr2 = 6;
        aluk = 2'b10;
        gate_alu = 1;

        @(posedge clk);
    endtask

    // Test PC increment.
    task static test_pc_inc();
        dp.pc.set_data(3000);
        pcmux_sel = 2'b10;
        ld_pc = 1;
        gate_pc = 1;

        @(posedge clk);   // PC = 3000
        @(posedge clk);   // PC = 3001
        @(posedge clk);   // PC = 3002
    endtask

    // Test two instructions in sequence.
    // R0 <= R1 + R2  (R0 = 3)
    // R7 <= NOT R0  (R7 = NOT 3)
    task static test_2ins();
        dp.ir.set_data(16'b0001_000_001_000_010);  // R0 <= R1 + R2
        ld_reg = 1;
        dr = 0;
        sr1 = 1;
        sr2 = 2;
        aluk = 2'b10;
        gate_alu = 1;
        @(posedge clk); #1;  // Wait one time unit before next instruction

        dp.ir.set_data(16'b1001_111_000_111111);  // R7 <= NOT R0
        dr = 7;
        sr1 = 0;
        aluk = 2'b00;
        @(posedge clk); #1;
    endtask

    initial begin
        init_signals();
        init_regs();

        //test_add();
        //test_pc_inc();
        test_2ins();

        $finish;
    end
endmodule
