module mem #(
        parameter WIDTH_DATA = 8,
        parameter WIDTH_ADDR = 8,
        parameter INIT_FILE  = "source/programa.hex"
    ) (
        input wire                  clk,
        input wire                  rd,
        input wire                  wr,
        input wire [WIDTH_ADDR-1:0] addr,
        input wire [WIDTH_DATA-1:0] din,
        output reg [WIDTH_DATA-1:0] dout
    );

    // Declaração da memória
    reg [WIDTH_DATA-1:0] memoria [0:(1<<WIDTH_ADDR)-1];

    // Inicialização de dados com arquivo
    initial $readmemh(INIT_FILE, memoria);

    // Leitura ou escrita a cada pulso de clock
    always @(posedge clk) begin
        if (wr)       memoria[addr] <= din;
        if (rd || wr) dout <= memoria[addr];
    end

endmodule