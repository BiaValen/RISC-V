import re

class RiscVAssembler:
    """
    Um Assembler simples para instruções RV32I/M para gerar código de máquina.
    """
    def __init__(self):
        # Mapeamento de registradores para seus números
        self.reg_map = {f'x{i}': i for i in range(32)}
        self.reg_map.update({
            'zero': 0, 'ra': 1, 'sp': 2, 'gp': 3, 'tp': 4,
            't0': 5, 't1': 6, 't2': 7, 's0': 8, 'fp': 8, 's1': 9,
            'a0': 10, 'a1': 11, 'a2': 12, 'a3': 13, 'a4': 14, 'a5': 15,
            'a6': 16, 'a7': 17, 's2': 18, 's3': 19, 's4': 20, 's5': 21,
            's6': 22, 's7': 23, 's8': 24, 's9': 25, 's10': 26, 's11': 27,
            't3': 28, 't4': 29, 't5': 30, 't6': 31,
        })

        # Definições das instruções com base nos formatos
        self.instructions = {
            # R-Type
            'add':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x0, 'funct7': 0x00},
            'sub':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x0, 'funct7': 0x20},
            'sll':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x1, 'funct7': 0x00},
            'slt':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x2, 'funct7': 0x00},
            'xor':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x4, 'funct7': 0x00},
            'srl':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x5, 'funct7': 0x00},
            'sra':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x5, 'funct7': 0x20},
            'or':   {'type': 'R', 'opcode': 0x33, 'funct3': 0x6, 'funct7': 0x00},
            'and':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x7, 'funct7': 0x00},
            'mul':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x0, 'funct7': 0x01},
            'div':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x4, 'funct7': 0x01},
            'rem':  {'type': 'R', 'opcode': 0x33, 'funct3': 0x6, 'funct7': 0x01},

            # I-Type
            'addi': {'type': 'I', 'opcode': 0x13, 'funct3': 0x0},
            'slti': {'type': 'I', 'opcode': 0x13, 'funct3': 0x2},
            'xori': {'type': 'I', 'opcode': 0x13, 'funct3': 0x4},
            'ori':  {'type': 'I', 'opcode': 0x13, 'funct3': 0x6},
            'andi': {'type': 'I', 'opcode': 0x13, 'funct3': 0x7},
            'lw':   {'type': 'I-load', 'opcode': 0x03, 'funct3': 0x2},
            'jalr': {'type': 'I-jalr', 'opcode': 0x67, 'funct3': 0x0},

            # S-Type
            'sw':   {'type': 'S', 'opcode': 0x23, 'funct3': 0x2},

            # B-Type
            'beq':  {'type': 'B', 'opcode': 0x63, 'funct3': 0x0},
            'bne':  {'type': 'B', 'opcode': 0x63, 'funct3': 0x1},
            'blt':  {'type': 'B', 'opcode': 0x63, 'funct3': 0x4},
            'bge':  {'type': 'B', 'opcode': 0x63, 'funct3': 0x5},

            # J-Type
            'jal':  {'type': 'J', 'opcode': 0x6F},
        }

    def _parse_reg(self, reg_str):
        return self.reg_map[reg_str.lower()]

    def _to_twos_comp(self, val, bits):
        """Converte um valor para complemento de dois com 'bits' de largura."""
        if val < 0:
            val = (1 << bits) + val
        return val

    def encode(self, asm):
        """Função principal que recebe uma string em Assembly e retorna o código de máquina."""
        asm = asm.lower().replace(',', '')
        parts = asm.split()
        mnemonic = parts[0]
        operands = parts[1:]

        if mnemonic not in self.instructions:
            raise ValueError(f"Instrução desconhecida: {mnemonic}")

        instr_info = self.instructions[mnemonic]
        instr_type = instr_info['type']
        
        # --- Lógica de montagem para cada tipo de instrução ---
        
        if instr_type == 'R':
            rd, rs1, rs2 = map(self._parse_reg, operands)
            opcode = instr_info['opcode']
            funct3 = instr_info['funct3']
            funct7 = instr_info['funct7']
            return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

        elif instr_type in ['I', 'I-jalr']:
            rd = self._parse_reg(operands[0])
            rs1 = self._parse_reg(operands[1])
            imm = int(operands[2])
            imm = self._to_twos_comp(imm, 12)
            
            opcode = instr_info['opcode']
            funct3 = instr_info['funct3']
            return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

        elif instr_type == 'I-load':
            rd = self._parse_reg(operands[0])
            match = re.match(r'(-?\d+)\((.+)\)', operands[1]) # Padrão offset(base)
            imm = int(match.group(1))
            rs1 = self._parse_reg(match.group(2))
            imm = self._to_twos_comp(imm, 12)

            opcode = instr_info['opcode']
            funct3 = instr_info['funct3']
            return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

        elif instr_type == 'S':
            rs2 = self._parse_reg(operands[0])
            match = re.match(r'(-?\d+)\((.+)\)', operands[1]) # Padrão offset(base)
            imm = int(match.group(1))
            rs1 = self._parse_reg(match.group(2))
            imm = self._to_twos_comp(imm, 12)

            imm11_5 = (imm >> 5) & 0x7F # Pega os 7 bits mais significativos
            imm4_0 = imm & 0x1F         # Pega os 5 bits menos significativos
            
            opcode = instr_info['opcode']
            funct3 = instr_info['funct3']
            return (imm11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm4_0 << 7) | opcode

        elif instr_type == 'B':
            rs1 = self._parse_reg(operands[0])
            rs2 = self._parse_reg(operands[1])
            imm = int(operands[2])
            imm = self._to_twos_comp(imm, 13)

            imm12   = (imm >> 12) & 0x1
            imm10_5 = (imm >> 5) & 0x3F
            imm4_1  = (imm >> 1) & 0xF
            imm11   = (imm >> 11) & 0x1
            
            opcode = instr_info['opcode']
            funct3 = instr_info['funct3']
            
            field1 = (imm12 << 6) | imm10_5 # [12|10:5]
            field2 = (imm4_1 << 1) | imm11  # [4:1|11]
            
            return (field1 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (field2 << 7) | opcode

        elif instr_type == 'J':
            rd = self._parse_reg(operands[0])
            imm = int(operands[1])
            imm = self._to_twos_comp(imm, 21)

            imm20   = (imm >> 20) & 0x1
            imm10_1 = (imm >> 1) & 0x3FF
            imm11   = (imm >> 11) & 0x1
            imm19_12= (imm >> 12) & 0xFF
            
            imm_field = (imm20 << 19) | (imm10_1 << 9) | (imm11 << 8) | imm19_12

            opcode = instr_info['opcode']
            return (imm_field << 12) | (rd << 7) | opcode

        return None

# --- Exemplo de Uso ---
if __name__ == "__main__":
    asm = RiscVAssembler()
    
    # Suas instruções de teste
    instructions_to_test = [
        "sw x10, 2040(x0)",
        "lw x5, 2044(x0)",
        "bge x5, x0, -4",
        "beq x6, x5, 40",
        "addi x6, x5, -1",
        "addi x10, x0, 1",
        "addi x11, x0, 0",
        "beq x6, x0, 20",
        "add x13, x10, x11",
        "addi x11, x10, 0",
        "addi x6, x6, -1",
        "addi x10, x13, 0",
        "bne x6, x0, -20",
        "sw x10, 2040(x0)",
        "jal x9, -4"
    ]

    print("--- Gerador de Instruções RISC-V ---")
    
    for i, instr_str in enumerate(instructions_to_test):
        try:
            machine_code = asm.encode(instr_str)
            
            # Formata para Verilog Hexadecimal (8 dígitos)
            hex_code = f"32'h{machine_code:08X}"
            
            # Formata para Verilog Binário (32 bits)
            bin_code = f"32'b{machine_code:032b}"
            
            print(f"\nmem[{i}] = {bin_code}; // {instr_str}")
#            print(f"mem[{i}] = {hex_code}; // Binário: {bin_code}")
            
        except (ValueError, AttributeError) as e:
            print(f"\nErro ao processar '{instr_str}': {e}")