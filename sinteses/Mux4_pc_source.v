`timescale 1ns / 1ps

// Módulo MUX4, que seleciona a fonte do próximo PC (PcSource)
module Mux4_pc_source (
    // Entradas de Dados
    input  wire [31:0] in_pc_plus,            // Endereço sequencial (PC+1)
    input  wire [31:0] in_pc_target,            // Endereço de destino para Branch/JAL (PC + Imm)
    input  wire [31:0] in_alu_result,           // Endereço de destino para JALR (rs1 + Imm)

    // Entradas de Controle
    input  wire        sel_jump,                // Sinal 'Jump' da Unidade de Controle (ativo para JAL/JALR)
    input  wire        sel_branch_taken,        // Sinal 'BranchTaken' da Unidade de Branch (ativo se branch for tomado)
    input  wire [6:0]  opcode_i,                // Opcode da instrução atual para diferenciar JAL/JALR

    // Saída
    output reg [31:0]  out_pc_in                // Saída final para a entrada do registrador PC
);

    // Constantes para os opcodes relevantes
    localparam OPCODE_JALR = 7'b1100111;

    // Lógica combinacional para selecionar a fonte do próximo PC
    always @(*) begin
        if (sel_jump) begin
            // Se a instrução é um JAL ou JALR, o sinal 'Jump' da UC estará ativo.
            // Precisamos usar o opcode para diferenciar os dois.
            if (opcode_i == OPCODE_JALR) begin
                out_pc_in = in_alu_result; // Para JALR, o próximo PC vem da ULA (rs1 + imm)
            end else begin // Assume-se que é JAL, pois sel_jump está ativo
                out_pc_in = in_pc_target;  // Para JAL, o próximo PC é PC + imm
            end
        end else if (sel_branch_taken) begin
            // Se um desvio condicional for tomado (ex: BEQ e condição é verdadeira)
            out_pc_in = in_pc_target; // O próximo PC é PC + imm
        end else begin
            // Para todas as outras instruções (aritméticas, load, store, branches não tomados)
            out_pc_in = in_pc_plus; // O próximo PC é o endereço sequencial
        end
    end

endmodule