// MUX para selecionar o segundo operando da ULA (operand_b)
module Mux1 (
    input  wire [31:0] in_read_data2, // Vindo do Banco de Registradores (rs2)
    input  wire [31:0] in_imm_extended, // Vindo do Extensor de Imediato
    input  wire        sel_alu_src,   // Sinal de controle AluSrc (0 = ReadData2, 1 = ImmExt)
    output wire [31:0] out_alu_operand_b
);

    // logica combinacional para selecao
    assign out_alu_operand_b = sel_alu_src ? in_imm_extended : in_read_data2;
    // se sel_alu_src = 0, seleciona in_read_data2
    // se sel_alu_src = 1, seleciona in_imm_extended

endmodule