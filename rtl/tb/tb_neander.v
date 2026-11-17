`timescale 10 ns / 1 ps
module tb_neander;
    reg clk = 0, rst = 1;
    wire       halt;
    wire [7:0] ac_out;
    reg [7:0] esp [0:10];
    integer i, erros, ciclos;

    neander_top #(.INIT_FILE("mem/p5.hex")) neander_top_dut (
        .clk(clk), .rst(rst), .halt(halt), .ac_out(ac_out)
    );

    always #5 clk = ~clk;

    always @(posedge clk) if (!rst && !halt) ciclos = ciclos + 1;

    initial begin
        esp[0] = 8'h16; esp[1] = 8'h02; esp[2] = 8'h0E; esp[3] = 8'h08;
        esp[4] = 8'hF3; esp[5] = 8'h01; esp[6] = 8'h02; esp[7] = 8'h01;
        esp[8] = 8'h0A; esp[9] = 8'h0A; esp[10] = 8'h00;
        erros = 0; ciclos = 0;
        #22 rst = 0;
        wait (halt === 1'b1);
        #20;
        for (i = 0; i < 10; i = i + 1) begin
            if (neander_top_dut.mem_dut.memoria[8'h90 + i] === esp[i])
                $display("MEM[%0h] = %h  OK", 8'h90 + i, neander_top_dut.mem_dut.memoria[8'h90 + i]);
            else begin
                $display("MEM[%0h] = %h  ERRO (esperado %h)", 8'h90 + i, neander_top_dut.mem_dut.memoria[8'h90 + i], esp[i]);
                erros = erros + 1;
            end
        end
        if (neander_top_dut.mem_dut.memoria[8'h9F] === esp[10])
            $display("MEM[9f] = %h  OK", neander_top_dut.mem_dut.memoria[8'h9F]);
        else begin
            $display("MEM[9f] = %h  ERRO (esperado %h)", neander_top_dut.mem_dut.memoria[8'h9F], esp[10]);
            erros = erros + 1;
        end
        $display("Ciclos ate o HLT: %0d", ciclos);
        $display("Total: %0d erro(s)", erros);
        $finish;
    end

    initial begin
        #100000;
        $display("TIMEOUT: nao chegou no HLT");
        $finish;
    end
endmodule