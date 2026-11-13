module rem_reg #(
        parameter WIDTH_DATA = 8
    ) (
        input wire                   clk,
        input wire                   rst,
        input wire                   load,
        input wire  [WIDTH_DATA-1:0] data_in,
        output reg  [WIDTH_DATA-1:0] data_out
    );

    //Como é um registrador, então montei com lógica sequencial
    always @(posedge clk or posedge rst) begin
        //Condição de maior prioridade(acionar o reset), em seguida load
        if (rst)       data_out <= {WIDTH_DATA{1'b0}};
        else if (load) data_out <= data_in;
        //Por padrão a saída recebe o último valor
        else           data_out <= data_out;
    end

endmodule