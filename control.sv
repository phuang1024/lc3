// Control unit.

module control();
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
    logic ld_mar;
    logic ld_mdr;
    logic mem_en;
    logic mem_rw;
    logic gate_mdr;

    datapath dp(clk, ld_ir, ld_reg, dr, sr1, sr2, aluk, gate_alu,
                a1m_sel, a2m_sel, ld_pc, pcmux_sel, gate_pc, marmux_sel,
                gate_marmux, ld_mar, ld_mdr, mem_en, mem_rw, gate_mdr);

    function static void reset_signals();
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
        ld_mar = 0;
        ld_mdr = 0;
        mem_en = 0;
        mem_rw = 0;
        gate_mdr = 0;
    endfunction

    // Wait posedge + 1t
    task static waitclk();
        @(posedge clk);
        #1;
    endtask

    // MDR <= M[MAR]
    task static read_mem();
        reset_signals();
        ld_pc = 0;
        gate_pc = 0;
        mem_en = 1;
        ld_mdr = 1;
        waitclk();
        waitclk();
        reset_signals();
    endtask

    // IR <= M[PC]; PC += 1;
    task static load_ir();
        reset_signals();

        // MAR <= PC
        gate_pc = 1;
        ld_mar = 1;
        waitclk();

        // PC <= PC + 1
        ld_mar = 0;
        pcmux_sel = 2;
        ld_pc = 1;
        waitclk();

        read_mem();

        // IR <= MDR
        gate_mdr = 1;
        ld_ir = 1;
        waitclk();
    endtask
endmodule
