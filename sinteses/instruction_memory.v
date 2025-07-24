
module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);
    // Memória para 256 instruções de 32 bits
    reg [31:0] mem [0:255];

    // Carrega o programa do arquivo 'program.hex' no início da simulação
    //initial begin
    //    $readmemh("tb/jumpcerto.b", mem);
    //end
 

initial begin
      // Programa Fibonacci Corrigido
        // Primeiro, inicializa os registradores e lê a entrada
        
        // Instrução 0: lw x5, 2044(x0) - Lê o valor de entrada do usuário
        mem[0] = 32'b01111111110000000010001010000011; // lw x5, 2044(x0)
        
        // Instrução 1: addi x6, x5, -1 - x6 = x5 - 1 (contador)
        mem[1] = 32'b11111111111100101000001100010011; // addi x6, x5, -1
        
        // Instrução 2: addi x10, x0, 1 - x10 = 1 (primeiro número de Fibonacci)
        mem[2] = 32'b00000000000100000000010100010011; // addi x10, x0, 1
        
        // Instrução 3: addi x11, x0, 0 - x11 = 0 (segundo número de Fibonacci)
        mem[3] = 32'b00000000000000000000010110010011; // addi x11, x0, 0
        
        // Instrução 4: beq x6, x0, 20 - Se x6 == 0, pula para a instrução de escrita (endereço 4 + 20 = 24 = instrução 6)
        mem[4] = 32'b00000000000000110000101001100011; // beq x6, x0, 20
        
        // LOOP de cálculo do Fibonacci:
        // Instrução 5: add x13, x10, x11 - x13 = x10 + x11 (próximo Fibonacci)
        mem[5] = 32'b00000000101101010000011010110011; // add x13, x10, x11
        
        // Instrução 6: addi x11, x10, 0 - x11 = x10 (move x10 para x11)
        mem[6] = 32'b00000000000001010000010110010011; // addi x11, x10, 0
        
        // Instrução 7: addi x10, x13, 0 - x10 = x13 (move x13 para x10)
        mem[7] = 32'b00000000000001101000010100010011; // addi x10, x13, 0
        
        // Instrução 8: addi x6, x6, -1 - x6 = x6 - 1 (decrementa contador)
        mem[8] = 32'b11111111111100110000001100010011; // addi x6, x6, -1
        
        // Instrução 9: bne x6, x0, -20 - Se x6 != 0, volta para o loop (endereço 9 - 20 = -11, que é instrução 5)
        mem[9] = 32'b11111110000000110001011011100011; // bne x6, x0, -20
        
        // Instrução 10: sw x10, 2040(x0) - Escreve o resultado no display
        mem[10] = 32'b01111110101000000010110000100011; // sw x10, 2040(x0)
        
        // Instrução 11: beq x0, x0, 0 - Loop infinito (sempre verdadeiro, offset 0)
        mem[11] = 32'b00000000000000000000000001100011; // beq x0, x0, 0
    

                
    end

    // A leitura é combinacional.   
    assign instruction = mem[address[9:2]]; 

endmodule