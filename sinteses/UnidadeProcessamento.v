// Modulo do Nucleo de Processamento Central
module UnidadeProcessamento (
    // Entradas de Controle
    input  wire        clk,
    input  wire        reset,
    input  wire        reg_write_en,
  //input  wire [2:0]  imm_type_sel,    // REMOVIDO - Assumindo que 'extensor.v' usa opcode
    input  wire        alu_src_sel,
    input  wire [3:0]  alu_control_op,
    input  wire [1:0]  mul_div_op_sel,
    input  wire        use_md_sel,

    // Entrada da Instrucao
    input  wire [31:0] instruction,

    // Saida principal deste nucleo
    output wire [31:0] core_result_out,

    // Saidas para outros blocos
    output wire [31:0] reg_read_data1,
    output wire [31:0] reg_read_data2,
    output wire        alu_zero_flag
);

    // Sinais internos
    wire [31:0] extended_immediate;
    wire [31:0] rf_read_data1_internal; // Renomeado para evitar conflito com a porta de saída
    wire [31:0] rf_read_data2_internal; // Renomeado
    wire [31:0] alu_operand_b_internal; // Renomeado
    wire [31:0] ula_result_internal;    // Renomeado
    wire [31:0] div_mult_result_internal; // Renomeado

    // Instanciacao do Extensor de Imediato
    extensor imm_ext_unit ( // Usa o nome do módulo definido em extensor.v
        .instr         (instruction),
      //.imm_type    (imm_type_sel), // REMOVIDO, pois seu extensor.v usa opcode
        .imm_ext       (extended_immediate)
    );

    // Instanciacao do Banco de Registradores
    bancoderegistradores reg_file_unit ( // Usa o nome do módulo definido em bancoderegistradores.v
        .clock        (clk),
        .reset        (reset),
        .reg_write    (reg_write_en),
        .read_addr1   (instruction[19:15]),
        .read_addr2   (instruction[24:20]),
        .write_addr   (instruction[11:7]),
        .write_data   (core_result_out),    // TEMPORÁRIO para teste
        .read_data1   (rf_read_data1_internal),
        .read_data2   (rf_read_data2_internal)
    );

    // Instanciacao do MUX1 (aluscr)
    // Assumindo que Mux1.v define 'module Mux1 (...)'
    Mux1 mux1_alu_op_b_inst ( // Usa o nome do módulo definido em Mux1.v
        .in_read_data2     (rf_read_data2_internal),
        .in_imm_extended   (extended_immediate),
        .sel_alu_src       (alu_src_sel),
        .out_alu_operand_b (alu_operand_b_internal)
    );

    // Instanciacao da ULA
    // Assumindo que ula.v define 'module ula (...)' ou 'module ula_riscv (...)'
    // SE o nome do módulo em ula.v for 'ula_riscv', use 'ula_riscv alu_unit_inst (...)'
    // SE for 'ula', use 'ula alu_unit_inst (...)'
    ula alu_unit_inst ( // <<< AJUSTE AQUI para o nome do módulo em ula.v
        .operand_a    (rf_read_data1_internal),
        .operand_b    (alu_operand_b_internal),
        .alu_control  (alu_control_op),
        .alu_result   (ula_result_internal),
        .zero_flag    (alu_zero_flag)
    );

    // Instanciacao da Unidade DIV/MULT
    div_mult div_mult_module_inst ( // Usa o nome do módulo definido em div_mult.v
        .operand1     (rf_read_data1_internal),
        .operand2     (rf_read_data2_internal),
        .mul_div_op   (mul_div_op_sel),
        .md_result    (div_mult_result_internal)
    );

    // Instanciacao do MUX2 (Aluresult)
    // Assumindo que Mux2.v define 'module Mux2 (...)'
    Mux2 mux2_wb_src1_inst ( // Usa o nome do módulo definido em Mux2.v
        .in_alu_result    (ula_result_internal),
        .in_md_result     (div_mult_result_internal),
        .sel_use_md       (use_md_sel),
        .out_conta_final  (core_result_out)
    );

    // Atribuindo saidas do core
    assign reg_read_data1 = rf_read_data1_internal;
    assign reg_read_data2 = rf_read_data2_internal;

endmodule