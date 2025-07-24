// MUX para selecionar entre o resultado da ULA e da unidade DIV/MULT
module Mux2 (
    input  wire [31:0] in_alu_result,   // Vindo da ULA
    input  wire [31:0] in_md_result,    // Vindo da Unidade DIV/MULT
    input  wire        sel_use_md,      // Sinal de controle UseMD (0 = AluResult, 1 = MDResult)
    output wire [31:0] out_conta_final
);

    // Logica combinacional para selecao
    assign out_conta_final = sel_use_md ? in_md_result : in_alu_result;
    // Se sel_use_md = 0, seleciona in_alu_result
    // Se sel_use_md = 1, seleciona in_md_result

endmodule