module binary_to_bcd (
    input  wire [31:0] binary_in,
    output reg  [31:0] bcd_out
);

    // Variáveis para os 8 dígitos BCD (4 bits cada)
    reg [3:0] digit_7, digit_6, digit_5, digit_4;
    reg [3:0] digit_3, digit_2, digit_1, digit_0;
    reg [31:0] binary_temp;
    
    integer i;

    // Algoritmo Double Dabble para conversão binário para BCD
    always @(*) begin
        // Inicialização
        digit_7 = 4'b0000;
        digit_6 = 4'b0000;
        digit_5 = 4'b0000;
        digit_4 = 4'b0000;
        digit_3 = 4'b0000;
        digit_2 = 4'b0000;
        digit_1 = 4'b0000;
        digit_0 = 4'b0000;
        binary_temp = binary_in;

        // Processa cada bit do número binário
        for (i = 0; i < 32; i = i + 1) begin
            // Adiciona 3 se o dígito for >= 5 (antes do shift)
            if (digit_7 >= 5) digit_7 = digit_7 + 3;
            if (digit_6 >= 5) digit_6 = digit_6 + 3;
            if (digit_5 >= 5) digit_5 = digit_5 + 3;
            if (digit_4 >= 5) digit_4 = digit_4 + 3;
            if (digit_3 >= 5) digit_3 = digit_3 + 3;
            if (digit_2 >= 5) digit_2 = digit_2 + 3;
            if (digit_1 >= 5) digit_1 = digit_1 + 3;
            if (digit_0 >= 5) digit_0 = digit_0 + 3;

            // Shift left: move o MSB do número binário para o LSB do primeiro dígito
            digit_7 = {digit_7[2:0], digit_6[3]};
            digit_6 = {digit_6[2:0], digit_5[3]};
            digit_5 = {digit_5[2:0], digit_4[3]};
            digit_4 = {digit_4[2:0], digit_3[3]};
            digit_3 = {digit_3[2:0], digit_2[3]};
            digit_2 = {digit_2[2:0], digit_1[3]};
            digit_1 = {digit_1[2:0], digit_0[3]};
            digit_0 = {digit_0[2:0], binary_temp[31]};
            
            // Shift do número binário
            binary_temp = binary_temp << 1;
        end
        
        // Monta a saída final
        bcd_out = {digit_7, digit_6, digit_5, digit_4, 
                   digit_3, digit_2, digit_1, digit_0};
    end

endmodule