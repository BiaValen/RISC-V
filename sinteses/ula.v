module ula (
    // Entradas
    input  wire [31:0] operand_a,      // entrada A (ex: ReadData1)
    input  wire [31:0] operand_b,      // entrada B (ex: saida do MUX1)
    input  wire [3:0]  alu_control,    // sinal de controle da Unidade de Controle

    // Saídas
    output reg  [31:0] alu_result,     // resultado da operação
    output reg         zero_flag,      // Flag Zero (1 se resultado for 0)
    output wire        negative_flag,  // Flag Negativa (bit de sinal do resultado)
    output reg         overflow_flag   // Flag de Overflow para operações aritméticas
);

    // Mapeamento de alu_control (Comentários para referência)
    // 4'b0000: AND
    // 4'b0001: OR
    // 4'b0010: ADD
    // 4'b0011: SUB
    // 4'b0100: XOR
    // 4'b0101: SLT
    // 4'b0110: SLL
    // 4'b0111: SRL
    // 4'b1000: SRA

    // --- LÓGICA DE SAÍDAS DERIVADAS ---
    // A flag negativa é o bit de sinal do resultado final
    assign negative_flag = alu_result[31];


    // --- LÓGICA PRINCIPAL (COMBINACIONAL) ---
    always @(*) begin
        // Valores padrão para evitar latches indesejados
        alu_result    = 32'b0;
        zero_flag     = 1'b0;
        overflow_flag = 1'b0; // Overflow não ocorre por padrão

        case (alu_control)
            4'b0000: alu_result = operand_a & operand_b;
            4'b0001: alu_result = operand_a | operand_b;
            4'b0010: begin // ADD
                alu_result = operand_a + operand_b;
                // Verificação de overflow para adição de complemento de dois
                // Ocorre se os sinais dos operandos são iguais E o sinal do resultado é diferente.
                if (operand_a[31] == operand_b[31] && alu_result[31] != operand_a[31]) begin
                    overflow_flag = 1'b1;
                end
            end
            4'b0011: begin // SUB
                alu_result = operand_a - operand_b;
                // Verificação de overflow para subtração de complemento de dois
                // Ocorre se os sinais dos operandos são diferentes E o sinal do resultado é diferente do sinal do primeiro operando.
                if (operand_a[31] != operand_b[31] && alu_result[31] != operand_a[31]) begin
                    overflow_flag = 1'b1;
                end
            end
            4'b0100: alu_result = operand_a ^ operand_b;
            4'b0101: alu_result = ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0; // SLT
            4'b0110: alu_result = operand_a << operand_b[4:0];    // SLL
            4'b0111: alu_result = operand_a >> operand_b[4:0];    // SRL
            4'b1000: alu_result = $signed(operand_a) >>> operand_b[4:0]; // SRA
            default: alu_result = 32'b0;
        endcase

        // Atribuição da ZeroFlag (baseado no resultado final)
        if (alu_result == 32'b0) begin
            zero_flag = 1'b1;
        end else begin
            zero_flag = 1'b0;
        end
    end

endmodule