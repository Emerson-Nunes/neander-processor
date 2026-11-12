`timescale 10 ns / 1ps

module tb_nz_reg;
    
    reg  clk;
    reg  rst;
    reg  load;
    reg  n_in;
    reg  z_in;
    wire n_out;
    wire z_out;

    nz_reg dut (
        .clk(clk), .rst(rst), .load(load),
        .n_in(n_in), .z_in(z_in),
        .n_out(n_out), .z_out(z_out)
    );

    //Variável de auxílio para o laço de verificação
    integer i;

    //Lógica do clock para alternar o valor e inicialização do reset em 1
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        forever #5 clk = ~clk;
    end

    //Testes, rst = 0 e roda todas as possibilidades entre load, n_in e z_in (2^(Nbits(load)+Nbits(n_in)+Nbits(z_in)))
    initial begin
        #10 rst = 1'b0;
        for (i = 0; i < 2**(3); i = i + 1) begin
            {load, n_in, z_in} = i[(3)-1:0];
            #10;
        end
        $finish;
    end

    //Mostra os valores das variáveis sempre que alguma sofre alteração
    initial begin
        $monitor("| clk: %b | rst: %b | load: %b | n_in: %d | z_in: %d | n_out: %b | z_out: %d", clk, rst, load, n_in, z_in, n_out, z_out);
    end

endmodule