`timescale 10 ns / 1ps

module tb_pc_reg;
    parameter WIDTH_DATA = 8;
    
    reg                   clk;
    reg                   rst;
    reg                   inc;
    reg                   load;
    reg  [WIDTH_DATA-1:0] data_in;
    wire [WIDTH_DATA-1:0] data_out;

    pc_reg #(
        .WIDTH_DATA(WIDTH_DATA)
    ) dut (
        .clk(clk), .rst(rst), .inc(inc), .load(load),
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

    //Testes, rst = 0 e roda todas as possibilidades entre load, inc e data_in (2^(Nbits(load)+Nbits(inc)+Nbits(data_in)))
    initial begin
        #10 rst = 1'b0;
        for (i = 0; i < 2**(WIDTH_DATA+2); i = i + 1) begin
            {load, inc, data_in} = i[(WIDTH_DATA+2)-1:0];
            #10;
        end
        $finish;
    end

    //Mostra os valores das variáveis sempre que alguma sofre alteração
    initial begin
        $monitor("| clk: %b | rst: %b | inc: %b | load: %b | data_in: %d | data_out: %d", clk, rst, inc, load, data_in, data_out);
    end

endmodule