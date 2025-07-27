`timescale 1ns / 1ps

// MUX final que seleciona o dado a ser escrito no Banco de Registradores.
module Mux3(
    input wire [31:0] in_exec_result,      // Resultado vindo do Mux2 (ULA ou MD)
    input wire [31:0] in_mem_data,         // Dado vindo da Memória de Dados
    input wire [31:0] in_pc_plus,        // Endereço de retorno para JAL/JALR
    
    input wire [1:0]  sel,                 // Seletor de 2 bits {Inst, MemtoReg}
    
    output wire [31:0] out_data           // Saída final para a porta write_data do registrador
);

    // Lógica combinacional para o MUX
    // A seleção foi ajustada para corresponder aos sinais da Unidade de Controle
    assign out_data = (sel == 2'b00) ? in_exec_result : // Para R-Type e I-Type
                      (sel == 2'b01) ? in_pc_plus :     // Para JAL/JALR
                      (sel == 2'b11) ? in_mem_data :    // Para LW
                      32'hxxxxxxxx; // Valor indefinido para seleção inválida

endmodule
