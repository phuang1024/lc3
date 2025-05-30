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
    logic ld_cc;
    logic ld_mar;
    logic ld_mdr;
    logic mem_en;
    logic mem_rw;
    logic gate_mdr;

    datapath dp(clk, ld_ir, ld_reg, dr, sr1, sr2, aluk, gate_alu,
                a1m_sel, a2m_sel, ld_pc, pcmux_sel, gate_pc, marmux_sel,
                gate_marmux, ld_cc, ld_mar, ld_mdr, mem_en, mem_rw,
                gate_mdr);

    // Control unit has access to IR register.
    wire [15:0] ir = dp.ir.out_data;

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
        @(posedge clk); #1;
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

    // NOT, AND, and ADD.
    task static exec_alu();
        reset_signals();
        sr1 = ir[8:6];
        sr2 = ir[2:0];
        dr = ir[11:9];
        case (ir[15:12])
            4'b1001: aluk = 2'b00;  // NOT
            4'b1010: aluk = 2'b01;  // AND
            4'b0001: aluk = 2'b10;  // ADD
            default: $display("Unknown ALU operation");
        endcase
        gate_alu = 1;
        ld_reg = 1;
        ld_cc = 1;
        waitclk();
    endtask

    // LD, LDI, LDR
    task static exec_ld();
        reset_signals();
        dr = ir[11:9];

        // Load MAR and memory.
        ld_mar = 1;
        marmux_sel = 1;
        gate_marmux = 1;
        case (ir[15:12])
            4'b0010, 4'b1010: begin  // LD, LDI
                a1m_sel = 1;  // Use PC
                a2m_sel = 1;  // Use offset
            end
            4'b0110: begin  // LDR
                sr1 = ir[8:6];
                a1m_sel = 0;  // Use base register
                a2m_sel = 2;  // Use offset from base register
            end
            default: begin end
        endcase
        waitclk();
        read_mem();

        // Load DR.
        gate_marmux = 0;
        gate_mdr = 1;
        ld_reg = 1;
        ld_cc = 1;
        waitclk();

        // If LDI, read memory again.
        if (ir[15:12] == 4'b1010) begin
            sr1 = dr;
            a1m_sel = 0;
            a2m_sel = 3;
            marmux_sel = 1;
            gate_marmux = 1;
            ld_mar = 1;
            waitclk();
            read_mem();

            gate_marmux = 0;
            gate_mdr = 1;
            ld_reg = 1;
            ld_cc = 1;
            waitclk();
        end
    endtask

    task static exec_lea();
        a1m_sel = 1;
        a2m_sel = 1;
        dr = ir[11:9];
        marmux_sel = 1;
        gate_marmux = 1;
        ld_reg = 1;
        waitclk();
    endtask

    // Full pipeline. Load and execute instruction at PC.
    task static exec_instruction();
        load_ir();
        waitclk();
        case (ir[15:12])
            4'b1001, 4'b0101, 4'b0001: exec_alu();  // NOT, AND, ADD
            4'b0010, 4'b0110, 4'b1010: exec_ld();  // LD, LDR, LDI
            default: $display("Unknown instruction: pc=%b, ir=%b", dp.pc.out_data, ir);
        endcase
    endtask
endmodule
