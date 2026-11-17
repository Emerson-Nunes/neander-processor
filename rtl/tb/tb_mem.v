`timescale 10 ns / 1ps

module tb_mem;
    parameter WIDTH_DATA = 8;
    parameter WIDTH_ADDR = 8;
    parameter INIT_FILE  = "source/programa.hex";
   
    reg                   clk;
    reg                   rd;
    reg                   wr;
    reg [WIDTH_ADDR-1:0]  addr;
    reg [WIDTH_DATA-1:0]  din;
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
    integer i;
    reg [7:0] esperado [0:255];
    reg [7:0] novo;

    initial begin
        // Inicialização padrão
        rd = 0; wr = 0; addr = 0; din = 0;

        // Conteúdo esperado de programa.hex (256 posições)
        esperado[0]  = 8'h20; esperado[1]  = 8'h80; esperado[2]  = 8'h70; esperado[3]  = 8'hF0;
        esperado[4]  = 8'h05; esperado[5]  = 8'h10; esperado[6]  = 8'h81; esperado[7]  = 8'h30;
        esperado[8]  = 8'h82; esperado[9]  = 8'h40; esperado[10] = 8'h83; esperado[11] = 8'hA5;
        esperado[12] = 8'h5A; esperado[13] = 8'hFF; esperado[14] = 8'h00; esperado[15] = 8'h7E;
        // Demais posições: (i*7+3) mod 256
        for (i = 16; i < 256; i = i + 1) esperado[i] = (i*7 + 3) & 8'hFF;

        // 1) Ler todos os endereços 0..255 e comparar com o esperado
        @(negedge clk);
        rd = 1;
        for (i = 0; i < 256; i = i + 1) begin
            addr = i;
            @(negedge clk);
            if (dout !== esperado[i]) begin
                erros = erros + 1;
                $display("ERRO leu end %0d : dout=%h (esperado %h)", i, dout, esperado[i]);
            end else
                $display("OK   leu end %0d : dout=%h (esperado %h)", i, dout, esperado[i]);
        end

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

        // 6) Escrever em todos os endereços 0..255 (valor = ~esperado) e reler
        rd = 0; wr = 1;
        for (i = 0; i < 256; i = i + 1) begin
            addr = i; din = ~esperado[i];
            @(negedge clk);
        end
        wr = 0; rd = 1;
        for (i = 0; i < 256; i = i + 1) begin
            addr = i; novo = ~esperado[i];
            @(negedge clk);
            if (dout !== novo) begin
                erros = erros + 1;
                $display("ERRO releu end %0d : dout=%h (esperado %h)", i, dout, novo);
            end else
                $display("OK   releu end %0d : dout=%h (esperado %h)", i, dout, novo);
        end

        $display("Total: %0d erro(s)", erros);
        $finish;
    end


endmodule