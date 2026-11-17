module neander_cpu #(
        parameter WIDTH_DATA = 8,
        parameter WIDTH_ADDR = 8,
        parameter WIDTH_ULA  = 3,
        parameter WIDTH_TIME = 3,
        parameter WIDTH_OP   = 4
    ) (
        input wire                   clk,
        input wire                   rst,

        output wire                  mem_rd,
        output wire                  mem_wr,
        output wire [WIDTH_ADDR-1:0] mem_addr,
        output wire [WIDTH_DATA-1:0] mem_din,
        input  wire [WIDTH_DATA-1:0] mem_dout,
        output wire                  halt,
        output wire [WIDTH_DATA-1:0] ac_out
    );
    
    // Saídas dos registradores
    wire [WIDTH_DATA-1:0] pc_out;
    wire [WIDTH_DATA-1:0] ri_out;
    wire [WIDTH_DATA-1:0] mpx_out;

    // Bits com os valores decodificados de cada instrução
    wire nop, sta, lda, add, orr, andd,
         nott, sub, jmp, jn, jz, hlt;

    // Sinais de controle
    wire load_rem, inc_pc, load_ri, 
         load_rdm, rd_mem, wr_mem,
         load_ac, load_nz, load_pc,
         halt_flag, sel_mpx;
         
    wire [WIDTH_TIME-1:0] time_step;
    wire n_out, z_out;
    wire n_ula, z_ula;
    wire [WIDTH_ULA-1:0]  sel_ula;
    wire [WIDTH_DATA-1:0] ula_result;

    // Instanciando os módulos
    pc_reg #(
        .WIDTH_DATA(WIDTH_DATA)
    ) p_reg_dut (
        .clk(clk), .rst(rst), .inc(inc_pc),
        .load(load_pc), .data_in(mem_dout),
        .data_out(pc_out)
    );

    rem_reg #(
        .WIDTH_DATA(WIDTH_DATA)
    ) rem_reg_dut (
        .clk(clk), .rst(rst), .load(load_rem),
        .data_in(mpx_out), .data_out(mem_addr)
    );

    ri_reg #(
        .WIDTH_DATA(WIDTH_DATA)
    ) ri_reg_dut (
        .clk(clk), .rst(rst), .load(load_ri),
        .data_in(mem_dout), .data_out(ri_out)
    );

    rdm_reg #(
        .WIDTH_DATA(WIDTH_DATA)
    ) rdm_reg_dut (
        .clk(clk), .rst(rst), .load(load_rdm),
        .data_in(ac_out), .data_out(mem_din)
    );

    mpx #(
        .WIDTH_DATA(WIDTH_DATA)
    ) mpx_dut (
        .s1(sel_mpx), .pc_out(pc_out), .rdm_out(mem_dout),
        .data_out(mpx_out)
    );

    decode #(
        .WIDTH_OP(WIDTH_OP)
    ) decode_dut (
        .opcode(ri_out[WIDTH_DATA-1:WIDTH_DATA-WIDTH_OP]),
        .nop(nop), .sta(sta), .lda(lda),
        .add(add), .orr(orr), .andd(andd),
        .nott(nott), .sub(sub), .jmp(jmp),
        .jn(jn), .jz(jz), .hlt(hlt)
    );

    ula #(
        .WIDTH_SEL(WIDTH_ULA), .WIDTH_DATA(WIDTH_DATA)
    ) ula_dut (
        .sel(sel_ula), .x(ac_out), .y(mem_dout),
        .result(ula_result), .n_flag(n_ula), .z_flag(z_ula)
    );

    ac_reg #(
        .WIDTH_DATA(WIDTH_DATA)
    ) ac_reg_dut (
        .clk(clk), .rst(rst), .load(load_ac),
        .data_in(ula_result), .data_out(ac_out)
    );

    nz_reg nz_reg_dut (
        .clk(clk), .rst(rst), .load(load_nz),
        .n_in(n_ula), .z_in(z_ula),
        .n_out(n_out), .z_out(z_out)
    );

    unidade_controle #(
        .WIDTH_ULA(WIDTH_ULA), .WIDTH_TIME(WIDTH_TIME)
    ) unidade_controle_dut (
        .clk(clk), .rst(rst),
        .n_in(n_out), .z_in(z_out),
        .nop(nop), .sta(sta), .lda(lda), .add(add),
        .orr(orr), .andd(andd), .nott(nott), .sub(sub),
        .jmp(jmp), .jn(jn), .jz(jz), .hlt(hlt),
        .load_rem(load_rem), .inc_pc(inc_pc), .load_ri(load_ri),
        .load_rdm(load_rdm), .rd_mem(mem_rd), .wr_mem(mem_wr),
        .load_ac(load_ac), .load_nz(load_nz), .load_pc(load_pc),
        .halt_flag(halt), .sel_mpx(sel_mpx),
        .sel_ula(sel_ula), .time_step(time_step)
    );

endmodule