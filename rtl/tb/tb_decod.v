module tb_decode;
    parameter WIDTH_OP = 4;

    reg  [WIDTH_OP-1:0]opcode;
    wire nop;
    wire sta;
    wire lda;
    wire add;
    wire orr;
    wire andd;
    wire nott;
    wire sub;
    wire jmp;
    wire jn;
    wire jz;
    wire hlt;

    integer i, ocorreu_erro, erros;

    localparam [WIDTH_OP-1:0] NOP = 4'b0000,
                              STA = 4'b0001,
                              LDA = 4'b0010,
                              ADD = 4'b0011,
                              OR  = 4'b0100,
                              AND = 4'b0101,
                              NOT = 4'b0110,
                              SUB = 4'b0111,
                              JMP = 4'b1000,
                              JN  = 4'b1001,
                              JZ  = 4'b1010,
                              HLT = 4'b1011;

    decode #(
        .WIDTH_OP(WIDTH_OP)
    ) dut (
        .opcode(opcode), .nop(nop), .sta(sta),
        .lda(lda), .add(add), .orr(orr), 
        .andd(andd), .nott(nott), .sub(sub),
        .jmp(jmp), .jn(jn), .jz(jz), .hlt(hlt)
    );

    initial begin
        erros = 0;
        for(i = 0; i < (2**(WIDTH_OP)); i = i + 1) begin
            opcode = i[WIDTH_OP-1:0];
            ocorreu_erro = 0;
            #5;
            case (opcode)
                NOP:     ocorreu_erro = (nop != 1'b1);
                STA:     ocorreu_erro = (sta != 1'b1);
                LDA:     ocorreu_erro = (lda != 1'b1);
                ADD:     ocorreu_erro = (add != 1'b1);
                OR :     ocorreu_erro = (orr != 1'b1);
                AND:     ocorreu_erro = (andd != 1'b1);
                NOT:     ocorreu_erro = (nott != 1'b1);
                SUB:     ocorreu_erro = (sub != 1'b1);
                JMP:     ocorreu_erro = (jmp != 1'b1);
                JN :     ocorreu_erro = (jn != 1'b1);
                JZ :     ocorreu_erro = (jz != 1'b1);
                HLT:     ocorreu_erro = (hlt != 1'b1);
                default: ocorreu_erro = (nop != 1'b1);
            endcase

            if (ocorreu_erro) begin
                $display("\n\n\nERRO: | opcode: %b |", opcode);
                erros = erros + 1;
            end
        end

        for(i = 0; i < (50); i = i + 1) begin
            opcode = $urandom_range(0, 15);
            ocorreu_erro = 0;
            #5;
            case (opcode)
                NOP:     ocorreu_erro = (nop != 1'b1);
                STA:     ocorreu_erro = (sta != 1'b1);
                LDA:     ocorreu_erro = (lda != 1'b1);
                ADD:     ocorreu_erro = (add != 1'b1);
                OR :     ocorreu_erro = (orr != 1'b1);
                AND:     ocorreu_erro = (andd != 1'b1);
                NOT:     ocorreu_erro = (nott != 1'b1);
                SUB:     ocorreu_erro = (sub != 1'b1);
                JMP:     ocorreu_erro = (jmp != 1'b1);
                JN :     ocorreu_erro = (jn != 1'b1);
                JZ :     ocorreu_erro = (jz != 1'b1);
                HLT:     ocorreu_erro = (hlt != 1'b1);
                default: ocorreu_erro = (nop != 1'b1);
            endcase

            if (ocorreu_erro) begin
                $display("\n\n\nERRO: | opcode: %b |", opcode);
                erros = erros + 1;
            end
        end

        $display("Tesbench finalizado, quantidade de erros: %d\n\n\n", erros);

        $finish;
    end


endmodule