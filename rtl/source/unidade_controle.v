module unidade_controle #(
        parameter QTD_INST = 11,
                WIDTH_ULA = 3,
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
        input wire [QTD_INST-1:0] inst_set,

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

        output reg [WIDTH_ULA-1:0] sel_ula,
        output reg [WIDTH_TIME-1:0] time_step
    );

    
endmodule