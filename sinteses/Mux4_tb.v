`timescale 1ns / 1ps

module Mux4_tb;

    // --- Sinais para controlar o MUX ---
    reg  [31:0] tb_pc_plus;
    reg  [31:0] tb_pc_target;
    reg  [31:0] tb_alu_result;
    reg         tb_sel_jump;
    reg         tb_sel_branch_taken;
    reg  [6:0]  tb_opcode_i;

    // --- Fio para observar a saída do MUX ---
    wire [31:0] tb_out_pc_in;

    // --- Instância do Módulo sob Teste (Mux4_pc_source) ---
    Mux4_pc_source dut (
        .in_pc_plus(tb_pc_plus),
        .in_pc_target(tb_pc_target),
        .in_alu_result(tb_alu_result),
        .sel_jump(tb_sel_jump),
        .sel_branch_taken(tb_sel_branch_taken),
        .opcode_i(tb_opcode_i),
        .out_pc_in(tb_out_pc_in)
    );

    // --- Estímulo de Simulação ---
    initial begin
        $display("--- Iniciando Teste de Unidade para o MUX do PC ---");

        // Cenário 1: Instrução Sequencial (não é branch, nem jump)
        tb_pc_plus = 32'd4;
        tb_pc_target = 32'hDEADBEEF; // Valor lixo para garantir que não seja selecionado
        tb_sel_jump = 1'b0;
        tb_sel_branch_taken = 1'b0;
        #10;
        $display("Cenário 1 (Sequencial): Saída = %d (Esperado: 4)", tb_out_pc_in);
        if (tb_out_pc_in !== 32'd4) $display(">> FALHA!");

        // Cenário 2: Branch NÃO Tomado
        tb_sel_branch_taken = 1'b0; // Garantindo que seja falso
        #10;
        $display("Cenário 2 (Branch Não Tomado): Saída = %d (Esperado: 4)", tb_out_pc_in);
        if (tb_out_pc_in !== 32'd4) $display(">> FALHA!");


        // Cenário 3: Branch Tomado
        tb_pc_target = 32'd100;
        tb_sel_jump = 1'b0;
        tb_sel_branch_taken = 1'b1;
        #10;
        $display("Cenário 3 (Branch Tomado): Saída = %d (Esperado: 100)", tb_out_pc_in);
        if (tb_out_pc_in !== 32'd100) $display(">> FALHA!");

        // Cenário 4: Salto (JAL)
        tb_pc_target = 32'd200;
        tb_sel_jump = 1'b1;
        tb_sel_branch_taken = 1'b0; // Branch não deve importar quando é jump
        tb_opcode_i = 7'b1101111; // Opcode do JAL
        #10;
        $display("Cenário 4 (JAL): Saída = %d (Esperado: 200)", tb_out_pc_in);
        if (tb_out_pc_in !== 32'd200) $display(">> FALHA!");

        $display("--- Teste de Unidade Concluído ---");
        $finish;
    end
endmodule