module nz_reg (
        input wire clk,
        input wire rst,
        input wire load,
        input wire n_in,
        input wire z_in,
        output reg n_out,
        output reg z_out
    );

    //Como é um registrador, então montei com lógica sequencial
    always @(posedge clk) begin
        //Por padrão as flags de saídas recebem 0, para evitar criação de latch
        n_out <= 1'b0;
        z_out <= 1'b1;
        //Condição de maior prioridade(acionar o reset), em seguida load
        if (rst)       begin n_out <= 1'b0; z_out <= 1'b1; end
        else if (load) begin n_out <= n_in; z_out <= z_in; end
    end

endmodule