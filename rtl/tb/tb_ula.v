module tb_ula;
    parameter WIDTH_SEL  = 3;
    parameter WIDTH_DATA = 8;

    reg  [WIDTH_SEL-1:0]  sel;
    reg  [WIDTH_DATA-1:0] x;
    reg  [WIDTH_DATA-1:0] y;
    wire [WIDTH_DATA-1:0] result;
    wire                  n_flag;
    wire                  z_flag;

    localparam [WIDTH_SEL-1:0] LDA = 3'b010,
                               ADD = 3'b011,
                               OR  = 3'b100,
                               AND = 3'b101,
                               NOT = 3'b110,
                               SUB = 3'b111;

    ula #(
        .WIDTH_SEL(WIDTH_SEL),.WIDTH_DATA(WIDTH_DATA)
    ) dut (
        .sel(sel), .x(x), .y(y), .result(result),
        .n_flag(n_flag), .z_flag(z_flag)
    );

    // i é uma variável auxiliar para as iterações de teste
    // erros é a quantidade de erros ocorridos durante as iterações
    integer i, ocorreu_erro, erros;

    initial begin
        // Testes, erros e entradas começam com 0, 
        // roda todas as possibilidades
        // entre sel, x e y
        // (2^((Nbits(sel)+Nbits(x)+Nbits(y)))
        sel = {WIDTH_SEL{1'b0}};
        x =   {WIDTH_DATA{1'b0}};
        y =   {WIDTH_DATA{1'b0}};
        erros = 0;
        #5;
        for (i = 0; i < 2**(WIDTH_SEL + 2*WIDTH_DATA); i = i + 1) begin
            {sel, x, y} = i[(WIDTH_SEL + 2*WIDTH_DATA)-1:0];
            ocorreu_erro = 0;
            #5;
            // Reutilizei o case do módulo original para testar todos os casos
            // Uma variável auxiliar recebe o resultado booleano da comparação
            // Entre o valor do resultado e da operação original
            case (sel)
                LDA:     ocorreu_erro = (result != (x));
                ADD:     ocorreu_erro = (result != (x + y));
                OR:      ocorreu_erro = (result != (x | y));
                AND:     ocorreu_erro = (result != (x & y));
                NOT:     ocorreu_erro = (result != (~x));
                SUB:     ocorreu_erro = (result != (x + (~y) + 8'd1));
                default: ocorreu_erro = (result != {WIDTH_DATA{1'b0}});
            endcase

            // Comparações entre os valores atuais e os valores corretos
            // das flag Z e N
            if ((~(|result)) && (~z_flag))
                ocorreu_erro = 1;
            if ((result[WIDTH_DATA-1] == 1'b1) && (~n_flag))
                ocorreu_erro = 1;

            // Verifica se ocorreu erro nessa iteração
            // imprime as informações atuais para verificação
            if (ocorreu_erro) begin
                $display("ERRO: | sel: %b | x: %b | y: %b | result: %b |", sel, x, y, result);
                erros = erros + 1;
            end
        end

        $display("\n\n\nTestbench encerrado!");
        $display("Quantidade de erros ocorridos:%d\n\n\n", erros);

        $finish;
    end



endmodule