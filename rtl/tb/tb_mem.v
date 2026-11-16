`timescale 10 ns / 1ps

module tb_mem;
    parameter WIDTH_DATA = 8;
    parameter WIDTH_ADDR = 8;
    parameter INIT_FILE  = "source/programa.hex";
   
    reg                  clk;
    reg                  rd;
    reg                  wr;
    reg [WIDTH_ADDR-1:0] addr;
    reg [WIDTH_DATA-1:0] din;
    wire [WIDTH_DATA-1:0] dout;

    mem #(
        .WIDTH_DATA(WIDTH_DATA), .WIDTH_ADDR(WIDTH_ADDR),
        .INIT_FILE(INIT_FILE)
    ) dut (
        .clk(clk), .rd(rd), .wr(wr),
        .addr(addr), .din(din), .dout(dout)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

        integer erros = 0;

    initial begin
        // Inicialização padrão
        rd = 0; wr = 0; addr = 0; din = 0;

        // 1) Ler endereço 0 -> esperado 20
        @(negedge clk);
        addr = 8'd0; rd = 1;
        @(negedge clk);
        $display("leu end 0   : dout=%h (esperado 20)", dout);
        if (dout !== 8'h20) erros = erros + 1;

        // 2) Ler endereço 3 -> esperado F0
        addr = 8'd3;
        @(negedge clk);
        $display("leu end 3   : dout=%h (esperado F0)", dout);
        if (dout !== 8'hF0) erros = erros + 1;

        // 3) Escrever 55 no endereço 3 (dout mostra o valor antigo)
        rd = 0; wr = 1; din = 8'h55;
        @(negedge clk);
        $display("escreveu 55 : dout=%h (esperado F0, valor antigo)", dout);
        if (dout !== 8'hF0) erros = erros + 1;

        // 4) Ler endereço 3 de novo -> esperado 55
        wr = 0; rd = 1;
        @(negedge clk);
        $display("leu end 3   : dout=%h (esperado 55)", dout);
        if (dout !== 8'h55) erros = erros + 1;

        // 5) Sem rd nem wr, dout fica parado mesmo trocando o endereço
        rd = 0; addr = 8'd0;
        @(negedge clk);
        $display("sem rd/wr   : dout=%h (esperado 55, parado)", dout);
        if (dout !== 8'h55) erros = erros + 1;

        $display("Total: %0d erro(s)", erros);
        $finish;
    end


endmodule