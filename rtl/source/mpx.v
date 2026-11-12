module mpx #(
        parameter WIDTH_DATA = 8
    ) (
        input wire                   s1,
        input wire  [WIDTH_DATA-1:0] pc_out,
        input wire  [WIDTH_DATA-1:0] rdm_out,
        output wire [WIDTH_DATA-1:0] data_out
    );

    // Fiz a lógica combinacional mais simples que pensei
    // Para selecionar que entrada vai para a saída
    // Usei como referência a figura do livro sobre arquitetura de computadores
    // para escolher rdm_out no s1 = 1 e pc quando s1 = 0
    assign data_out = s1 ? rdm_out : pc_out;

endmodule