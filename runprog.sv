// Load programs from file and execute.
// File format:
// 0000000000000000  # File starting address.
// 1010101010101010  # Instruction 1.
// ...

`define DP ctrl.dp
`define REGS ctrl.dp.regs.regs

module runprog();
    control ctrl();

    initial begin
        ctrl.clk = 0;
        forever #5
            ctrl.clk = ~ctrl.clk;
    end

    task static print();
        $display("t=%2t, IR=%b, PC=%b, R0=%b, R1=%b, R2=%b, R3=%b, R4=%b, R5=%b, R6=%b, R7=%b, cc=%b",
                 $time, `DP.ir.out_data, `DP.pc.out_data, `REGS[0].out_data, `REGS[1].out_data,
                 `REGS[2].out_data, `REGS[3].out_data, `REGS[4].out_data, `REGS[5].out_data,
                 `REGS[6].out_data, `REGS[7].out_data, `DP.cc.out_data);
    endtask

    task static read_file(string file);
        int fd;
        bit [15:0] i;
        bit [15:0] value;
        byte tmp;

        $display("Reading %s", file);
        fd = $fopen(file, "r");

        if ($fscanf(fd, "%b", value) == 1) begin
            i = value;
            $display("Starting address: x%h", value);
        end else begin
            $display("File does not contain address at beginning.");
            $finish;
        end

        while (!$feof(fd)) begin
            if ($fscanf(fd, "%b", value) == 1) begin
                `DP.mem.mem[i] = value;
                i++;
            end else begin
                $fscanf(fd, "%c", tmp);
            end
        end
        $fclose(fd);
        $display("Loaded %0d instructions from file.", i);
    endtask

    initial begin
        string file;
        if ($value$plusargs("file1=%s", file)) begin
            read_file(file);
        end
        if ($value$plusargs("file2=%s", file)) begin
            read_file(file);
        end

        `DP.pc.set_data(0);
        while (1) begin
            ctrl.exec_instruction();
            print();
        end

        $finish;
    end
endmodule
