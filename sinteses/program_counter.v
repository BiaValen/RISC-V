
module program_counter (
    input  wire        clock,      // Sinal de clock global
    input  wire        reset,      // Sinal de reset (ativo alto)
    input  wire [31:0] pc_in,      // Próximo valor do PC (vindo do MUX4)
    output reg  [31:0] pc_out      // Valor atual do PC (para Memória de Instrução e lógica PC+4/Target)
);

    // Lógica síncrona para o registrador PC
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            pc_out <= 32'h00000000; // Endereço inicial padrão no reset 
        end else begin
            pc_out <= pc_in;        // Carrega o próximo valor do PC
        end
    end

endmodule