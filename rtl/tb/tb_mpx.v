module tb_mpx;
    parameter WIDTH_DATA = 8;

    reg                   s1;
    reg [WIDTH_DATA-1:0]  pc_out;
    reg [WIDTH_DATA-1:0]  rdm_out;
    wire [WIDTH_DATA-1:0] data_out;


    mpx #(
        .WIDTH_DATA(WIDTH_DATA)
    ) dut (
        .s1(s1), .pc_out(pc_out), 
        .rdm_out(rdm_out), .data_out(data_out)
    );

    // i é uma variável auxiliar para as iterações de teste
    // erros é a quantidade de erros ocorridos durante as iterações
    integer i, erros;

    initial begin
        // Testes, erros e entradas começam com 0, 
        // roda todas as possibilidades
        // entre s1, pc_out e rdm_out
        // (2^((Nbits(s1)+Nbits(pc_out)+Nbits(rdm_out)))
        pc_out = {WIDTH_DATA{1'b0}};
        rdm_out = {WIDTH_DATA{1'b0}};
        erros = 0;
        #5;
        for (i = 0; i < 2**(2*WIDTH_DATA+1); i = i + 1) begin
            {s1, pc_out, rdm_out} = i[(2*WIDTH_DATA+1)-1:0];
            #5;
            // Teste no caso da seleção ter valor s1 = 1
            if (s1) begin
                if (data_out != rdm_out) begin
                    $display("ERRO: | s1: %b | rdm_out: %b | data_out: %b |", s1, rdm_out, data_out);
                    erros = erros + 1;
                end
            end
            // Teste no caso da seleção ter valor s1 = 0
            else begin
                if (data_out != pc_out) begin
                    $display("ERRO: | s1: %b | pc_out: %b | data_out: %b |", s1, pc_out, data_out);
                    erros = erros + 1;
                end
            end
        end

        $display("\n\n\nTestbench encerrado!");
        $display("Quantidade de erros ocorridos:%d\n\n\n", erros);

        $finish;
    end



endmodule