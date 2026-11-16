`timescale 10 ns / 1 ps

module tb_unidade_controle;

    parameter QTD_INST = 11;
    parameter WIDTH_ULA = 3;
    parameter WIDTH_TIME = 3;

    reg clk, rst, n_in, z_in;
    reg nop, sta, lda, add, orr, andd, nott, sub, jmp, jn, jz, hlt;

    wire load_rem, inc_pc, load_ri, load_rdm, rd_mem, wr_mem;
    wire load_ac, load_nz, load_pc, halt_flag, sel_mpx;
    wire [WIDTH_ULA-1:0]  sel_ula;
    wire [WIDTH_TIME-1:0] time_step;

    unidade_controle #(
        .QTD_INST(QTD_INST), .WIDTH_ULA(WIDTH_ULA), .WIDTH_TIME(WIDTH_TIME)
    ) dut (
        .clk(clk), .rst(rst), .n_in(n_in), .z_in(z_in),
        .nop(nop), .sta(sta), .lda(lda), .add(add),
        .orr(orr), .andd(andd), .nott(nott), .sub(sub),
        .jmp(jmp), .jn(jn), .jz(jz), .hlt(hlt),
        .load_rem(load_rem), .inc_pc(inc_pc), .load_ri(load_ri),
        .load_rdm(load_rdm), .rd_mem(rd_mem), .wr_mem(wr_mem),
        .load_ac(load_ac), .load_nz(load_nz), .load_pc(load_pc),
        .halt_flag(halt_flag), .sel_mpx(sel_mpx),
        .sel_ula(sel_ula), .time_step(time_step)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Conferência na ordem:
    // {rem, sel, inc, ri, rdm, rd, wr, ac, nz, pc}
    localparam [9:0] MASCARA   = 10'b111111111;
    localparam       CHECA_ULA = 1;
    localparam       ATE_T     = 7;

    // Um nome para cada botão
    localparam [9:0] REM = 10'b1000000000, SEL = 10'b0100000000,
                     INC = 10'b0010000000, RI  = 10'b0001000000,
                     RDM = 10'b0000100000, RD  = 10'b0000010000,
                     WR  = 10'b0000001000, AC  = 10'b0000000100,
                     NZ  = 10'b0000000010, PC  = 10'b0000000001;

    // Tipos de instrução
    localparam K_NADA = 0,   // NOP e opcode livre
               K_STA  = 1,
               K_ULA  = 2,   // LDA, ADD, OR, AND, SUB
               K_NOT  = 3,
               K_DESV = 4,   // desvio tomado
               K_NAOD = 5,   // desvio não tomado
               K_HLT  = 6;

    // Botões que devem estar ligados em cada passo (tabelas do livro)
    function [9:0] esp(input integer tipo, input integer t);
        begin
            esp = 10'b0;
            case (t)
                0: esp = REM;
                1: esp = RD | INC;
                2: esp = RI;
                3: case (tipo)
                       K_STA, K_ULA: esp = REM;
                       K_NOT:        esp = AC | NZ;
                       K_DESV:       esp = REM;
                       K_NAOD:       esp = INC;
                   endcase
                4: case (tipo)
                       K_STA, K_ULA: esp = RD | INC;
                       K_DESV:       esp = RD;
                   endcase
                5: case (tipo)
                       K_STA, K_ULA: esp = REM | SEL;
                       K_DESV:       esp = PC;
                   endcase
                6: case (tipo)
                       K_STA:        esp = RDM;
                       K_ULA:        esp = RD;
                   endcase
                7: case (tipo)
                       K_STA:        esp = WR;
                       K_ULA:        esp = AC | NZ;
                   endcase
            endcase
        end
    endfunction

    reg [8*7-1:0] caso;
    integer tipo, len, ula_esp, ciclo, erros_caso, erros_total;
    integer t_esp;
    reg ativo, halt_esp;
    reg [9:0] esperado, obtido;

    // A cada subida do relógio compara o que saiu com o que o livro manda
    always @(posedge clk) begin
        if (!rst && ativo) begin
            t_esp    = (tipo == K_HLT) ? ((ciclo < 3) ? ciclo : 3) : (ciclo % len);
            esperado = esp(tipo, t_esp);
            halt_esp = (tipo == K_HLT) && (ciclo >= 4);
            obtido   = {load_rem, sel_mpx, inc_pc, load_ri, load_rdm,
                        rd_mem, wr_mem, load_ac, load_nz, load_pc};

            if (time_step !== t_esp) begin
                $display("    ERRO %0s, ciclo %0d: time_step=%0d (esperado %0d)",
                         caso, ciclo, time_step, t_esp);
                erros_caso = erros_caso + 1;
            end
            if ((t_esp <= ATE_T) && (((obtido ^ esperado) & MASCARA) !== 10'b0)) begin
                $display("    ERRO %0s, ciclo %0d (t%0d): obtido=%b esperado=%b",
                         caso, ciclo, t_esp, obtido & MASCARA, esperado & MASCARA);
                erros_caso = erros_caso + 1;
            end
            if (CHECA_ULA && esperado[2] && (sel_ula !== ula_esp)) begin
                $display("    ERRO %0s, ciclo %0d: sel_ula=%0d (esperado %0d)",
                         caso, ciclo, sel_ula, ula_esp);
                erros_caso = erros_caso + 1;
            end
            if (halt_flag !== halt_esp) begin
                $display("    ERRO %0s, ciclo %0d: halt_flag=%b (esperado %b)",
                         caso, ciclo, halt_flag, halt_esp);
                erros_caso = erros_caso + 1;
            end
            ciclo = ciclo + 1;
        end
    end

    integer i;

    initial begin
        ativo = 0; erros_total = 0;
        rst = 1; #20;

        // Cada volta do for testa uma instrução
        for (i = 0; i < 15; i = i + 1) begin
            {nop, sta, lda, add, orr, andd, nott, sub, jmp, jn, jz, hlt} = 12'b0;
            n_in = 0; z_in = 0;

            case (i)
                0:  begin caso = "NOP    "; tipo = K_NADA; len = 4; ula_esp = 0; nop  = 1; end
                1:  begin caso = "STA    "; tipo = K_STA;  len = 8; ula_esp = 0; sta  = 1; end
                2:  begin caso = "LDA    "; tipo = K_ULA;  len = 8; ula_esp = 0; lda  = 1; end
                3:  begin caso = "ADD    "; tipo = K_ULA;  len = 8; ula_esp = 1; add  = 1; end
                4:  begin caso = "OR     "; tipo = K_ULA;  len = 8; ula_esp = 2; orr  = 1; end
                5:  begin caso = "AND    "; tipo = K_ULA;  len = 8; ula_esp = 3; andd = 1; end
                6:  begin caso = "NOT    "; tipo = K_NOT;  len = 4; ula_esp = 4; nott = 1; end
                7:  begin caso = "SUB    "; tipo = K_ULA;  len = 8; ula_esp = 5; sub  = 1; end
                8:  begin caso = "JMP    "; tipo = K_DESV; len = 6; ula_esp = 0; jmp  = 1; end
                9:  begin caso = "JN N=1 "; tipo = K_DESV; len = 6; ula_esp = 0; jn = 1; n_in = 1; end
                10: begin caso = "JN N=0 "; tipo = K_NAOD; len = 4; ula_esp = 0; jn = 1; end
                11: begin caso = "JZ Z=1 "; tipo = K_DESV; len = 6; ula_esp = 0; jz = 1; z_in = 1; end
                12: begin caso = "JZ Z=0 "; tipo = K_NAOD; len = 4; ula_esp = 0; jz = 1; end
                13: begin caso = "HLT    "; tipo = K_HLT;  len = 4; ula_esp = 0; hlt  = 1; end
                14: begin caso = "LIVRE  "; tipo = K_NADA; len = 4; ula_esp = 0; end
            endcase

            // reseta, roda umas duas voltas da instrução e diz se passou
            erros_caso = 0; ciclo = 0;
            rst = 1; #10; rst = 0;
            ativo = 1;
            #(10 * (2*len + 4));
            ativo = 0;

            if (erros_caso == 0) $display("  %0s : OK", caso);
            else                 $display("  %0s : %0d erro(s)", caso, erros_caso);
            erros_total = erros_total + erros_caso;
        end

        $display("Total: %0d erro(s)", erros_total);
        $finish;
    end

endmodule