module extensor (
    input  wire [31:0] instr,   // Instrução de 32 bits
    output reg  [31:0] imm_ext  // Imediato estendido para 32 bits
);

    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // Tipo I: addi, slti, xori, ori, andi, lw, jalr
            7'b0010011,  // operações com imediato
            7'b0000011,  // lw
            7'b1100111:  // jalr
                imm_ext = {{20{instr[31]}}, instr[31:20]};

            // Tipo S: sw
            7'b0100011:
                imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // Tipo B: beq, bne, blt, bge
            7'b1100011:
                imm_ext = {{19{instr[31]}}, instr[31],instr[7], instr[30:25], instr[11:8], 1'b0};
					 //tb_instr = {1'b1, 6'b111111, 5'b00010, 5'b00001, 3'b101, 4'b0110, 1'b0, OPCODE_BRANCH};
					 //imm_ext = {{19{1}}, 1, 0, 111111, 0110, 0} = 0xFFFFFFEC = -20

            // Tipo J: jal
            7'b1101111:
                imm_ext = {{11{instr[31]}},    // Sign extend do bit mais significativo (imm[20])
				instr[31],          // imm[20]
                instr[19:12],       // imm[19:12]
                instr[20],          // imm[11]
                instr[30:21],       // imm[10:1]
                1'b0};              // imm[0], sempre 0
                
            //imm = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}
            default:
                imm_ext = 32'b0; // Imediato nulo para instruções do tipo R e outras não implementadas
        endcase
    end

endmodule