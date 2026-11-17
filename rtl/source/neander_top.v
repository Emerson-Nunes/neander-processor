module neander_top #(
        parameter INIT_FILE = "mem/programa.hex",
        parameter WIDTH_ADDR = 8,
        parameter WIDTH_DATA = 8,
        parameter WIDTH_ULA  = 3,
        parameter WIDTH_TIME = 3,
        parameter WIDTH_OP   = 4
        
    ) (
        input  wire                  clk,
        input  wire                  rst,
        output wire                  halt,
        output wire [WIDTH_DATA-1:0] ac_out
    );

    wire                  rd, wr;
    wire [WIDTH_ADDR-1:0] addr;
    wire [WIDTH_DATA-1:0] din, dout;

    neander_cpu # (
        .WIDTH_DATA(WIDTH_DATA), .WIDTH_ADDR(WIDTH_ADDR),
        .WIDTH_ULA(WIDTH_ULA), .WIDTH_TIME(WIDTH_TIME),
        .WIDTH_OP(WIDTH_OP)
    ) neander_cpu_dut (
        .clk(clk), .rst(rst),
        .mem_rd(rd), .mem_wr(wr),
        .mem_addr(addr), .mem_din(din), .mem_dout(dout),
        .halt(halt), .ac_out(ac_out)
    );

    mem #(
        .WIDTH_DATA(WIDTH_DATA), .WIDTH_ADDR(WIDTH_ADDR),
        .INIT_FILE(INIT_FILE)
    ) mem_dut (
        .clk(clk), .rd(rd), .wr(wr),
        .addr(addr), .din(din), .dout(dout)
    );

endmodule