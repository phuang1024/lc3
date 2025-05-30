// Read and execute binary program from file.

module main_prog();
    control ctrl();

    initial begin
        ctrl.clk = 0;
        forever #5
            ctrl.clk = ~ctrl.clk;
    end

    task static print();
        $display("t=%2t, IR=%b, PC=%b, R0=%b, R1=%b, R2=%b, R3=%b, R4=%b, R5=%b, R6=%b, R7=%b, cc=%b",
                 $time, ctrl.dp.ir.out_data, ctrl.dp.pc.out_data, ctrl.dp.regs.regs[0].out_data,
                 ctrl.dp.regs.regs[1].out_data, ctrl.dp.regs.regs[2].out_data, ctrl.dp.regs.regs[3].out_data,
                 ctrl.dp.regs.regs[4].out_data, ctrl.dp.regs.regs[5].out_data, ctrl.dp.regs.regs[6].out_data,
                 ctrl.dp.regs.regs[7].out_data, ctrl.dp.cc.out_data);
    endtask

    initial begin
        string file, line;
        int fd, i;
        logic [15:0] data;

        if (!$value$plusargs("file=%s", file)) begin
            $display();
            $display("Usage: +file=<filename>");
            $finish;
        end

        fd = $fopen(file, "r");
        if (fd == 0) begin
            $display("Error opening file: %s", file);
            $finish;
        end

        i = 0;
        while (!$feof(fd)) begin
            line = $fgets(fd);
            data = $sscanf(line, "%16b", data);
            ctrl.dp.mem.mem[i] = data;
            i++;
        end
        $fclose(fd);
        $display("Loaded %0d instructions from %s", i, file);

        /*
        ctrl.dp.pc.set_data(0);

        while (1) begin
            ctrl.exec_instruction();
            print();
        end
        */
    end
endmodule
