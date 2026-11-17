module decode #(
        parameter WIDTH_OP = 4
    ) (
        input wire [WIDTH_OP-1:0] opcode,
        output reg                nop,
        output reg                sta,
        output reg                lda,
        output reg                add,
        output reg                orr,
        output reg                andd,
        output reg                nott,
        output reg                sub,
        output reg                jmp,
        output reg                jn,
        output reg                jz,
        output reg                hlt
    );

    // Ferramenta para enumeração e ficar mais legível
    // cada OPCODE
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
                              HLT = 4'b1111;

    // Decodificação do bit de saída
    // de cada instrução, de forma combinacional
    // Por padrão os OPCODE não listados
    // são considerados como NOP
    always @(*) begin
        nop  = 1'b0;
        sta  = 1'b0;
        lda  = 1'b0;
        add  = 1'b0;
        orr  = 1'b0;
        andd = 1'b0;
        nott = 1'b0;
        sub  = 1'b0;
        jmp  = 1'b0;
        jn   = 1'b0;
        jz   = 1'b0;
        hlt  = 1'b0;

        case (opcode)
            NOP:     nop  = 1'b1;
            STA:     sta  = 1'b1;
            LDA:     lda  = 1'b1;
            ADD:     add  = 1'b1;
            OR :     orr  = 1'b1;
            AND:     andd = 1'b1;
            NOT:     nott = 1'b1;
            SUB:     sub  = 1'b1;
            JMP:     jmp  = 1'b1;
            JN :     jn   = 1'b1;
            JZ :     jz   = 1'b1;
            HLT:     hlt  = 1'b1;
            default: nop  = 1'b1;
        endcase
    end

endmodule