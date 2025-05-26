module tb_datapath;
    // Datapath control signals.
    logic clk = 0;
    logic ld_ir = 0;
    logic ld_reg = 0;
    logic [2:0] dr = 0;
    logic [2:0] sr1 = 0;
    logic [2:0] sr2 = 0;
    logic [1:0] aluk = 0;
    logic gate_alu = 0;
    logic a1m_sel = 0;
    logic [1:0] a2m_sel = 0;
    logic ld_pc = 0;
    logic [1:0] pcmux_sel = 0;
    logic gate_pc = 0;
    logic marmux_sel = 0;
    logic gate_marmux = 0;
    logic ld_mar = 0;
    logic ld_mdr = 0;
    logic mem_en = 0;
    logic mem_rw = 0;
    logic gate_mdr = 0;

    datapath dp(clk, ld_ir, ld_reg, dr, sr1, sr2, aluk, gate_alu,
                a1m_sel, a2m_sel, ld_pc, pcmux_sel, gate_pc, marmux_sel,
                gate_marmux, ld_mar, ld_mdr, mem_en, mem_rw, gate_mdr);

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

    // Test memory.
    task static test_mem();
        // Manually set MAR to 0.
        dp.mar.set_data(0);

        // MDR <= NOT R7
        aluk = 2'b00;  // ALU = NOT
        sr1 = 7;
        gate_alu = 1;
        mem_en = 0;
        ld_mdr = 1;
        @(posedge clk); #1;

        // M[MAR] <= MDR
        ld_mdr = 0;
        gate_alu = 0;
        mem_en = 1;
        mem_rw = 1;
        @(posedge clk); #1;

        // MDR <= M[MAR]
        mem_en = 1;
        mem_rw = 0;
        ld_mdr = 1;
        @(posedge clk); @(posedge clk); #1;

        // Set bus to MDR.
        ld_mdr = 0;
        gate_mdr = 1;
        @(posedge clk); #1;
    endtask

    initial begin
        init_regs();

        //test_add();
        //test_pc_inc();
        //test_2ins();
        test_mem();

        $finish;
    end
endmodule
