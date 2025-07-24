`timescale 1ns / 1ps

module mux_pc_source (
    input  wire [31:0] in_pc_plus_4,           // Entrada 0: PC + 4
    input  wire [31:0] in_pc_target_branch_jal, // Entrada 1: Endereço de desvio/JAL (PC + Imm_B/J)
    input  wire [31:0] in_alu_result_jalr,     // Entrada 2: Endereço de JALR (rs1 + Imm_I)
    input  wire [1:0]  sel_pc_src,             // Sinal de seleção [1:0]
                                              // 00: PC+4
                                              // 01: PC_Target_Branch/JAL
                                              // 10: Alu_Result_JALR
                                              // 11: (Não usado / default para PC+4)
    output reg  [31:0] out_pc_in               // Saída selecionada para PC_In
);

    always @(*) begin
        case (sel_pc_src)
            2'b00:   out_pc_in = in_pc_plus_4;
            2'b01:   out_pc_in = in_pc_target_branch_jal;
            2'b10:   out_pc_in = in_alu_result_jalr;
            default: out_pc_in = in_pc_plus_4; // Comportamento seguro para seleção não usada
        endcase
    end

endmodule