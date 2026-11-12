`timescale 10 ns / 1ps

module tb_rem_reg;
    parameter WIDTH_DATA = 8;
    
    reg                   clk;
    reg                   rst;
    reg                   load;
    reg  [WIDTH_DATA-1:0] data_in;
    wire [WIDTH_DATA-1:0] data_out;

    rdm_reg #(
        .WIDTH_DATA(WIDTH_DATA)
    ) dut (
        .clk(clk), .rst(rst), .load(load),
        .data_in(data_in), .data_out(data_out)
    );

    //Variável de auxílio para o laço de verificação
    integer i;

    //Lógica do clock para alternar o valor e inicialização do reset em 1
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        forever #5 clk = ~clk;
    end

    //Testes, rst = 0 e roda todas as possibilidades entre load e data_in (2^(Nbits(load)+Nbits(data_in)))
    initial begin
        #10 rst = 1'b0;
        for (i = 0; i < 2**(WIDTH_DATA+1); i = i + 1) begin
            {load, data_in} = i[(WIDTH_DATA+1)-1:0];
            #10;
        end
        $finish;
    end

    //Mostra os valores das variáveis sempre que alguma sofre alteração
    initial begin
        $monitor("| clk: %b | rst: %b | load: %b | data_in: %d | data_out: %d", clk, rst, load, data_in, data_out);
    end

endmodule