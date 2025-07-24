`timescale 1ns / 1ps

module pc_plus_4_adder (
    input  wire [31:0] current_pc,   // Saída do módulo program_counter (pc_out)
    output wire [31:0] pc_plus     // Resultado (current_pc)
);

    // Lógica combinacional para somar 1 porque é de 32bits!
    assign pc_plus = current_pc + 32'd4; //meu endereçamento é por byte

endmodule