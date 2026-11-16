module unidade_controle #(
        parameter QTD_INST   = 11,
                  WIDTH_ULA  = 3,
                  WIDTH_TIME = 3
    ) (
        input wire clk, 
        input wire rst,
        
        input wire n_in,
        input wire z_in,

        input wire nop,
        input wire sta,
        input wire lda,
        input wire add,
        input wire orr,
        input wire andd,
        input wire nott,
        input wire sub,
        input wire jmp,
        input wire jn,
        input wire jz,
        input wire hlt,
        // input wire [QTD_INST-1:0] inst_set,

        output reg load_rem,
        output reg inc_pc,
        output reg load_ri,
        output reg load_rdm,
        output reg rd_mem,
        output reg wr_mem,
        output reg load_ac,
        output reg load_nz,
        output reg load_pc,
        output reg halt_flag,
        output reg sel_mpx,

        output reg [WIDTH_ULA-1:0]  sel_ula,
        output reg [WIDTH_TIME-1:0] time_step
    );

    // Auxiliares para verificar o tempo atual
    // do ciclo de instrução
    wire t0 = (time_step == 0);
    wire t1 = (time_step == 1);
    wire t2 = (time_step == 2);
    wire t3 = (time_step == 3);
    wire t4 = (time_step == 4);
    wire t5 = (time_step == 5);
    wire t6 = (time_step == 6);
    wire t7 = (time_step == 7);
    
    // Auxiliar para verificar se JN o JZ estão ativos
    // Mas as flags não estão, sinalizando um não desvio
    wire n_desv = (jn && ~n_in) || (jz && ~z_in);

    // Com o negado na frente, se torna a lista de instruções
    // que são NOP ou não estão listadas e serão interpretadas
    // como NOP
    wire inst_diff = ~(sta || lda || add || orr || andd || sub || jmp || jn || jz || nott || hlt);

    // Lista de instruções que terminam em t3
    wire inst_t3 = (nop || nott || n_desv || inst_diff);

    // Lista de instruções que terminam em t5
    wire inst_t5 = (jmp) || (jn && n_in) || (jz && z_in);

    // Lista de instruções que terminam em t7
    wire inst_t7 = (sta || lda || add || orr || andd || sub);

    // Laço principal de gerenciamento do time_step
    always @(posedge clk or posedge rst) begin
        // Caso de reset, zera o ciclo e a flag de halt
        if(rst) begin
            time_step <= {WIDTH_TIME{1'b0}};
            halt_flag <= 1'b0;
        end
        else if (!halt_flag) begin
            // Ocorrência de instrução HALT
            // Seta a flag de halt em 1
            if (t3 && hlt)
                halt_flag <= 1'b1;
            // Essas demais verificações são para
            // retornar ao estado inicial 
            // para instruções com 3, 5 e 7 tempos
            // por ciclo de instrução
            else if (t3 && inst_t3)
                time_step <= 0;
            else if (t5 && inst_t5)
                time_step <= 0;
            else if (t7 && inst_t7)
                time_step <= 0;
            // Caso contrário continua incrementado
            else
                time_step <= time_step + 1;
        end
    end

    always @(*) begin
        // Valores padrão de controle
        load_rem = 1'b0;  sel_mpx = 1'b0;  inc_pc  = 1'b0;  load_ri = 1'b0;
        load_rdm = 1'b0;  rd_mem  = 1'b0;  wr_mem  = 1'b0;  load_ac = 1'b0;
        load_nz  = 1'b0;  load_pc = 1'b0;  sel_ula = 3'b000;

        if (!halt_flag) begin
            // Equações lógicas para cada sinal de controle
            // Está similar ao que é implementado no livro de referência
            load_rem = t0 || (t3 && (inst_t7 || inst_t5)) || (t5 && inst_t7);
            inc_pc   = t1 || (t4 && inst_t7) || (t3 && n_desv);
            load_ri  = t2;
            sel_mpx  = (t5 && inst_t7);
            load_rdm = (t6 && sta);
            rd_mem   = (t1 || (t4 && (inst_t7 || inst_t5))) || (t6 && inst_t7 && ~sta);
            wr_mem   = (t7 && sta);
            load_ac  = (t7 && (inst_t7 && ~sta)) || (t3 && nott);
            load_nz  = (t7 && (inst_t7 && ~sta)) || (t3 && nott);
            load_pc  = (t5 && inst_t5);
        end

        // Seleção da operação da ULA
        // de acordo com a instrução atual
        if (lda)  sel_ula = 3'b000;
        if (add)  sel_ula = 3'b001;
        if (orr)  sel_ula = 3'b010;
        if (andd) sel_ula = 3'b011;
        if (nott) sel_ula = 3'b100;
        if (sub)  sel_ula = 3'b101;
    end

    
endmodule