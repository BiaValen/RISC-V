// Calcula PC_out + ImmExt
module pc_target_adder (
    input  wire [31:0] in_pc_out,         // Valor atual do PC (saída do program_counter)
    input  wire [31:0] in_imm_extended,   // Imediato estendido (offset para B-type ou J-type)
    output wire [31:0] out_pc_target      // Endereço de destino calculado (PC_out + ImmExt)
);

    // Lógica combinacional para a soma
    assign out_pc_target = in_pc_out + in_imm_extended;

endmodule