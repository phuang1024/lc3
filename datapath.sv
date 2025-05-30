// LC3 datapath.

module datapath(
    input logic clk,
    // ir
    input logic ld_ir,
    // regfile
    input logic ld_reg,
    input logic [2:0] dr,
    input logic [2:0] sr1,
    input logic [2:0] sr2,
    // alu
    input logic [1:0] aluk,
    input logic gate_alu,
    // addr1mux
    input logic a1m_sel,
    // addr2mux
    input logic [1:0] a2m_sel,
    // pc
    input logic ld_pc,
    input logic [1:0] pcmux_sel,
    input logic gate_pc,
    // marmux
    input logic marmux_sel,
    input logic gate_marmux,
    // cc
    input logic ld_cc,
    // memory
    input logic ld_mar,
    input logic ld_mdr,
    input logic mem_en,  // controls source of mdr
    input logic mem_rw,  // controls memory unit rw
    input logic gate_mdr
);
    // global
    wire [15:0] bus;

    // ir register
    wire [15:0] ir_out;
    register ir(
        .clk(clk),
        .write_en(ld_ir),
        .in_data(bus),
        .out_data(ir_out)
    );

    // regfile
    wire [15:0] regs_sr1_out, regs_sr2_out;
    regfile regs(
        .clk(clk),
        .write_en(ld_reg),
        .sel_in(dr),
        .sel_out1(sr1),
        .sel_out2(sr2),
        .in_data(bus),
        .out1_data(regs_sr1_out),
        .out2_data(regs_sr2_out)
    );

    // sr2mux
    wire [15:0] sr2mux_out;
    wire [15:0] sr2mux_sext_out;
    sext#(5) sr2mux_sext(
        .in_data(ir_out[4:0]),
        .out_data(sr2mux_sext_out)
    );
    mux3 sr2mux(
        .in({16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0,
             sr2mux_sext_out, regs_sr2_out}),  // only last two.
        .sel({1'b0, 1'b0, ir_out[5]}),
        .out(sr2mux_out)
    );

    // alu
    wire [15:0] alu_out;
    alu alu_(
        .a(regs_sr1_out),
        .b(sr2mux_out),
        .sel(aluk),
        .o(alu_out)
    );
    tribuf alu_tribuf(
        .data_in(alu_out),
        .enable(gate_alu),
        .data_out(bus)
    );

    // addr1mux
    wire [15:0] pc_out;  // declaring this here for a1m.
    wire [15:0] a1m_out;
    mux3 addr1mux(
        .in({16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0,
             pc_out, regs_sr1_out}),  // only last two.
        .sel({1'b0, 1'b0, a1m_sel}),
        .out(a1m_out)
    );

    // addr2mux
    wire [15:0] a2m_out;
    wire [15:0] a2m_sext6_out, a2m_sext9_out, a2m_sext11_out;
    sext#(6) a2m_sext6(
        .in_data(ir_out[5:0]),
        .out_data(a2m_sext6_out)
    );
    sext#(9) a2m_sext9(
        .in_data(ir_out[8:0]),
        .out_data(a2m_sext9_out)
    );
    sext#(11) a2m_sext11(
        .in_data(ir_out[10:0]),
        .out_data(a2m_sext11_out)
    );
    mux3 addr2mux(
        .in({16'b0, 16'b0, 16'b0, 16'b0,
             16'b0, a2m_sext6_out, a2m_sext9_out, a2m_sext11_out}),  // only last four.
        .sel({1'b0, a2m_sel}),
        .out(a2m_out)
    );

    // addr adder
    wire [15:0] addr_adder_out;
    alu addr_adder(
        .a(a1m_out),
        .b(a2m_out),
        .sel(2'b10),  // add
        .o(addr_adder_out)
    );

    // pcmux
    wire [15:0] pcmux_out;
    wire [15:0] pc_adder_out;
    mux3 pcmux(
        .in({16'b0, 16'b0, 16'b0, 16'b0, 16'b0,
            pc_adder_out, addr_adder_out, bus}),  // only last three are used.
        .sel({1'b0, pcmux_sel}),  // only two selection bits.
        .out(pcmux_out)
    );

    // pc register
    register pc(
        .clk(clk),
        .write_en(ld_pc),
        .in_data(pcmux_out),
        .out_data(pc_out)
    );
    alu pc_adder(   // increment PC by 1
        .a(pc_out),
        .b(16'b1),
        .sel(2'b10),
        .o(pc_adder_out)
    );
    tribuf pc_tribuf(
        .data_in(pc_out),
        .enable(gate_pc),
        .data_out(bus)
    );

    // marmux
    wire [15:0] marmux_out;
    wire [15:0] marmux_zext_out;
    sext#(8, 1) marmux_zext(
        .in_data(ir_out[7:0]),
        .out_data(marmux_zext_out)
    );
    mux3 marmux(
        .in({16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0,
             addr_adder_out, marmux_zext_out}),  // only last two.
        .sel({1'b0, 1'b0, marmux_sel}),
        .out(marmux_out)
    );
    tribuf marmux_tribuf(
        .data_in(marmux_out),
        .enable(gate_marmux),
        .data_out(bus)
    );

    // cc register, based on bus value.
    wire cc_n = bus[15];
    wire cc_z = (bus == 16'b0) ? 1'b1 : 1'b0;
    wire cc_p = ~cc_n & ~cc_z;
    wire [2:0] cc_in = {cc_n, cc_z, cc_p};
    wire [2:0] cc_out;  // Control can access this.
    register#(3) cc(
        .clk(clk),
        .write_en(ld_cc),
        .in_data(cc_in),
        .out_data(cc_out)
    );

    // memory
    wire [15:0] mar_out, mdr_out, mdr_mux_out, mem_out;
    mux3 mdr_mux(
        .in({16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0,
             mem_out, bus}),  // only last two.
        .sel({1'b0, 1'b0, mem_en}),
        .out(mdr_mux_out)
    );
    register mar(
        .clk(clk),
        .write_en(ld_mar),
        .in_data(bus),
        .out_data(mar_out)
    );
    register mdr(
        .clk(clk),
        .write_en(ld_mdr),
        .in_data(mdr_mux_out),
        .out_data(mdr_out)
    );
    tribuf mdr_tribuf(
        .data_in(mdr_out),
        .enable(gate_mdr),
        .data_out(bus)
    );
    memory mem(
        .clk(clk),
        .write_en(mem_rw),
        .addr(mar_out),
        .in_data(mdr_out),
        .out_data(mem_out)
    );
endmodule
