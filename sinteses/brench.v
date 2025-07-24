module brench (
    input wire       Branch_i,      // 1 se a instrução é um branch
    input wire [2:0] BranchType_i,  // Tipo de branch (beq, bne, blt, bge)

    // Entradas das Flags da ULA
    input wire       Zero_i,        // 1 se o resultado da ULA foi zero
    input wire       Negative_i,    // 1 se o resultado da ULA foi negativo

    // Saída para o MUX4
    output wire      BranchTaken_o
);


    localparam BEQ = 3'b000; // Branch on Equal
    localparam BNE = 3'b001; // Branch on Not Equal
    localparam BLT = 3'b100; // Branch on Less Than
    localparam BGE = 3'b101; // Branch on Greater Than or Equal

    reg condition_met;

    // Lógica combinacional para verificar a condição do branch
    always @(*) begin
        case (BranchType_i)
            BEQ: condition_met = Zero_i;          // Desvia se (rs1 - rs2) == 0
            BNE: condition_met = ~Zero_i;         // Desvia se (rs1 - rs2) != 0
            BLT: condition_met = Negative_i;      // Desvia se (rs1 - rs2) < 0
            BGE: condition_met = ~Negative_i;     // Desvia se (rs1 - rs2) >= 0
            default: condition_met = 1'b0;
        endcase
    end

    assign BranchTaken_o = Branch_i && condition_met;

endmodule