module Unidade_de_controle(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg [3:0] ALUControl,
    output reg Branch,
    output reg Jump,
    output reg UseMD,
    output reg [1:0] MulDivOp,
    output reg Inst,
    output reg [2:0] BranchType
);


    always @(*) begin
        // Valores padrão para cada ciclo
        RegWrite   = 0;
        MemRead    = 0;
        MemWrite   = 0;
        MemtoReg   = 0;
        ALUSrc     = 0;
        ALUControl = 4'bxxxx; // Padrão indefinido para pegar erros
        Branch     = 0;
        Jump       = 0;
        UseMD      = 0;
        MulDivOp   = 2'b00;
        Inst       = 0;
        BranchType = 2'b00;

        case (opcode)
            // --- Instruções Tipo R ---
            7'b0110011: begin
                RegWrite = 1;
                ALUSrc   = 0;
                MemtoReg = 0;
                case ({funct3, funct7})
                    10'b1110000000: ALUControl = 4'b0000; // AND
                    10'b1100000000: ALUControl = 4'b0001; // OR
                    10'b0000000000: ALUControl = 4'b0010; // ADD
                    10'b0000100000: ALUControl = 4'b0011; // SUB
                    10'b1000000000: ALUControl = 4'b0100; // XOR 
                    10'b0100000000: ALUControl = 4'b0101; // SLT
                    10'b0010000000: ALUControl = 4'b0110; // SLL
                    10'b1010000000: ALUControl = 4'b0111; // SRL
                    10'b1010100000: ALUControl = 4'b1000; // SRA
                    10'b0000000001: begin // MUL
                        UseMD    = 1;
                        MulDivOp = 2'b00;
                    end
                    10'b1000000001: begin // DIV
                        UseMD    = 1;
                        MulDivOp = 2'b01;
                    end
                    10'b1100000001: begin // REM
                        UseMD    = 1;
                        MulDivOp = 2'b10;
                    end
                    default: ALUControl = 4'bxxxx; // Operação Tipo R inválida
                endcase
            end

            // --- Instruções Tipo I (Aritméticas) ---
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc   = 1;
                MemtoReg = 0;
                case (funct3)
                    3'b000: ALUControl = 4'b0010; // ADDI 
                    3'b010: ALUControl = 4'b1001; // SLTI
                    3'b100: ALUControl = 4'b0111; // XORI 
                    3'b110: ALUControl = 4'b0001; // ORI
                    3'b111: ALUControl = 4'b0000; // ANDI 
                      
                    
                   
                endcase
            end

            // --- Load ---
            7'b0000011: begin // lw
                RegWrite   = 1;
                MemRead    = 1;
                ALUSrc     = 1;
                MemtoReg   = 1;
                ALUControl = 4'b0010; // ADD para calcular endereço
                Inst       = 1;       // Para o MUX3 saber que é memória
            end

            // --- Store ---
            7'b0100011: begin // sw
                RegWrite = 0;
                MemWrite = 1;
                ALUSrc   = 1;
                ALUControl = 4'b0010; // ADD para calcular endereço
            end

            // --- Branch ---
            7'b1100011: begin
                Branch   = 1;
                ALUSrc   = 0;
                ALUControl = 4'b0011; // SUB para comparação
                case (funct3)
                    3'b000: BranchType = 2'b00; // beq
                    3'b001: BranchType = 2'b01; // bne
                    3'b100: BranchType = 2'b10; // blt
                    3'b101: BranchType = 2'b11; // bge
                endcase
            end

            // --- JAL ---
            7'b1101111: begin
                RegWrite = 1;
                Jump     = 1;
                MemtoReg = 1;
                Inst     = 0; // MUX3 pega Pc+4
            end

            // --- JALR ---
            7'b1100111: begin
                RegWrite = 1;
                Jump     = 1;
                ALUSrc   = 1;
                MemtoReg = 1;
                Inst     = 0; // MUX3 pega Pc+4
                ALUControl = 4'b0010; // ADD rs1 + imm
            end
            
            default: begin
                // Mantém os valores padrão para opcodes não reconhecidos
            end
        endcase
    end
endmodule
