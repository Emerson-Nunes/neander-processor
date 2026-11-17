module ula #(
        parameter WIDTH_SEL  = 3,
                  WIDTH_DATA = 8
    ) (
        input wire  [WIDTH_SEL-1:0]  sel,
        input wire  [WIDTH_DATA-1:0] x,
        input wire  [WIDTH_DATA-1:0] y,
        output reg [WIDTH_DATA-1:0] result,
        output wire                  n_flag,
        output wire                  z_flag
    );

    // Também fiz este em lógica combinacional
    // Comecei criando parâmetros locais com
    // os OPCODE de cada operação
    localparam [WIDTH_SEL-1:0] LDA = 3'b000,
                               ADD = 3'b001,
                               OR  = 3'b010,
                               AND = 3'b011,
                               NOT = 3'b100,
                               SUB = 3'b101;
    
    // Criei a lógica para cada flag
    // Flag Z só fica alta quando todos os bits
    // São zero, então fiz a negação do operador ou redutor
    // Flag só fica alta quando o bit mais significativo é 1
    assign z_flag = ~(|result);
    assign n_flag = (result[WIDTH_DATA-1] == 1'b1);

    // Fiz um case para selecionar corretamente as operações da ULA
    // Como padrão o resultado recebe valor nulo
    always @(*) begin
        result = {WIDTH_DATA{1'b0}};
        case (sel)
            LDA:     begin result = y; end
            ADD:     begin result = x + y; end
            OR:      begin result = x | y; end
            AND:     begin result = x & y; end
            NOT:     begin result = ~x;    end
            SUB:     begin result = x + (~y) + 8'd1; end
            default: begin result = {WIDTH_DATA{1'b0}}; end
        endcase
    end

endmodule