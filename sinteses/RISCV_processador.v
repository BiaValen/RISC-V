module RISCV_processador(
    input wire clk,
    input wire reset,
    input wire [31:0] external_input_i,

    output wire [31:0] display_data_o,
    output wire        display_we_o,

    // SAÍDA PARA DEPURAÇÃO
    output wire [31:0] pc_out_debug,
    output wire [31:0] next_pc_debug,
    output wire       is_reading_input_debug_o,
    input wire        data_is_ready_from_input,
	 
	 
	     // Adicione estas saídas temporárias de depuração
    output wire [31:0] debug_instruction,
    output wire        debug_MemRead,
    output wire [31:0] debug_alu_result,
    output wire        debug_select_input_device
);
	
    localparam DISPLAY_ADDR = 32'd2040; // Endereço do registrador de saída
    localparam INPUT_ADDR = 32'd2044; // Endereço do registrador de entrada
    

    // --- FIOS INTERNOS (WIRES) ---
    wire [31:0] pc_out, instruction, pc_plus, pc_target_addr, next_pc;
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [4:0]  rs1_addr, rs2_addr, rd_addr;
    wire [31:0] imm_extended;
       
    // Sinais de Controle
    wire       RegWrite_from_control, MemWrite_from_control;
    wire       RegWrite, AluSrc, MemRead, MemWrite, Branch, Jump, UseMD, Inst;
    wire [2:0] BranchType; 
    wire [1:0] MulDivOp, Mux3_sel;
    wire [3:0] AluControl;
    wire       instruction_squash;
    wire       MemtoReg; 
    
    // Barramentos de Dados e Flags
    wire [31:0] read_data1, read_data2;
    wire [31:0] alu_input2, alu_result;
    wire        alu_zero_flag, alu_negative_flag, alu_overflow_flag;
    wire [31:0] md_result, exec_result, reg_write_data;
    wire        mem_write_enable, display_write_enable, select_input_device;
    wire [31:0] data_from_mem, final_read_data;
    wire        branch_taken;

    wire display_write_internal;
    // Expandir input de 18 para 32 bits
    wire [31:0] external_input_32bit;
    assign external_input_32bit = external_input_i;
    
    assign next_pc_debug = next_pc;
    assign pc_out_debug = pc_out;

    assign debug_instruction         = instruction;
	assign debug_MemRead             = MemRead;
	assign debug_alu_result          = alu_result;
	assign debug_select_input_device = select_input_device;

    // Ativa o stall se:
    // 1. É uma instrução de leitura (MemRead)
    // 2. O endereço é o do dispositivo de entrada (INPUT_ADDR)
    // 3. E o dispositivo de entrada NÃO está pronto (!data_is_ready...)
    assign pc_stall = MemRead && (alu_result == INPUT_ADDR) && !data_is_ready_from_input;
    assign is_reading_input_debug_o = select_input_device;
    
    // Lógica de detecção de escrita no display
    assign display_write_internal = (alu_result == DISPLAY_ADDR) && MemWrite && !pc_stall;
    
    // Saídas para o display
    assign display_data_o = read_data2;
    assign display_we_o   = display_write_internal;

    // --- DECODIFICAÇÃO DE CAMPOS ---
    assign opcode = instruction[6:0];
    assign rd_addr  = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign funct7 = instruction[31:25];

    // ===================================================================
    // == INSTANCIAÇÃO DE TODOS OS MÓDULOS ==
    // ===================================================================

    // --- ETAPA 1: BUSCA DE INSTRUÇÃO (PC e Memória de Instrução) ---
    pc_plus_4_adder pc_plus_4_adder_inst ( 
        .current_pc(pc_out), 
        .pc_plus(pc_plus) 
    );
    
    pc_target_adder pc_target_adder_inst ( 
        .in_pc_out(pc_out), 
        .in_imm_extended(imm_extended), 
        .out_pc_target(pc_target_addr)
    );
    
    // MUX4 para selecionar o próximo PC
    Mux4_pc_source mux4_inst (
        .in_pc_plus(pc_plus), 
        .in_pc_target(pc_target_addr), 
        .in_alu_result(alu_result),
        .sel_jump(Jump), 
        .sel_branch_taken(branch_taken), 
        .opcode_i(opcode),
        .out_pc_in(next_pc)
    );

    program_counter program_counter_inst ( 
        .clock(clk), 
        .reset(reset), 
        .pc_in(next_pc), 
        .pc_out(pc_out),
        .enable(!pc_stall)  // <-- PC só avança se NÃO houver stall
    );
    
    instruction_memory instruction_memory_inst ( 
        .address(pc_out), 
        .instruction(instruction) 
    );

    // --- ETAPA 2: DECODIFICAÇÃO ---
    Unidade_de_controle unidade_de_controle_inst (
        .opcode(opcode), 
        .funct3(funct3), 
        .funct7(funct7), 
        .RegWrite(RegWrite_from_control), 
        .ALUSrc(AluSrc), 
        .ALUControl(AluControl), 
        .MemRead(MemRead), 
        .MemWrite(MemWrite_from_control), 
        .MemtoReg(MemtoReg), 
        .Branch(Branch), 
        .Jump(Jump), 
        .UseMD(UseMD), 
        .MulDivOp(MulDivOp), 
        .BranchType(BranchType), 
        .Inst(Inst)
    );

    extensor extensor_inst ( 
        .instr(instruction), 
        .imm_ext(imm_extended) 
    );

    // --- LÓGICA DE ANULAÇÃO (SQUASH) ---
    assign instruction_squash = branch_taken && !reset;
    assign RegWrite = RegWrite_from_control && !instruction_squash;
    assign MemWrite = MemWrite_from_control && !instruction_squash;
    
    bancoderegistradores bancoderegistradores_inst ( 
        .clock(clk), 
        .reset(reset), 
        .reg_write(RegWrite), 
        .read_addr1(rs1_addr), 
        .read_addr2(rs2_addr), 
        .write_addr(rd_addr), 
        .write_data(reg_write_data), 
        .read_data1(read_data1), 
        .read_data2(read_data2) 
    );
    
    // --- ETAPA 3: EXECUÇÃO ---
    Mux1 mux1_inst ( 
        .in_read_data2(read_data2), 
        .in_imm_extended(imm_extended), 
        .sel_alu_src(AluSrc), 
        .out_alu_operand_b(alu_input2) 
    );
    
    ula ula_inst ( 
        .operand_a(read_data1), 
        .operand_b(alu_input2), 
        .alu_control(AluControl), 
        .alu_result(alu_result), 
        .zero_flag(alu_zero_flag), 
        .negative_flag(alu_negative_flag), 
        .overflow_flag(alu_overflow_flag)  
    );
    
    div_mult div_mult_inst ( 
        .operand1(read_data1), 
        .operand2(read_data2), 
        .mul_div_op(MulDivOp), 
        .md_result(md_result) 
    );

    // Unidade de Branch
    brench branch_inst ( 
        .Branch_i(Branch), 
        .BranchType_i(BranchType), 
        .Zero_i(alu_zero_flag), 
        .Negative_i(alu_negative_flag), 
        .BranchTaken_o(branch_taken) 
    );

    // MUX2 para selecionar o resultado da execução
    Mux2 mux2_inst ( 
        .in_alu_result(alu_result), 
        .in_md_result(md_result), 
        .sel_use_md(UseMD), 
        .out_conta_final(exec_result) 
    );

    // --- ETAPA 4: ACESSO À MEMÓRIA E I/O ---
    decoder_mmio_output dec_out_inst ( 
        .MemWrite_i(MemWrite), 
        .Address_i(alu_result), 
        .Display_WriteEnable_o(display_write_enable), 
        .MemDados_WriteEnable_o(mem_write_enable) 
    );
    
    data_memory data_mem_inst ( 
        .clk_read(clk), 
        .clk_write(clk), 
        .MemWrite(mem_write_enable), 
        .MemRead(MemRead), 
        .address(alu_result), 
        .write_data(read_data2), 
        .read_data(data_from_mem) 
    );
    
    decoder_mmio_input dec_in_inst ( 
        .MemRead_i(MemRead), 
        .Address_i(alu_result), 
        .select_input_device_o(select_input_device) 
    );
    
    // MUX5 para selecionar entre memória principal e MMIO de entrada
    assign final_read_data = (select_input_device) ? external_input_32bit : data_from_mem;

    // --- ETAPA 5: WRITE-BACK ---
    assign Mux3_sel = {Inst, MemtoReg};
    Mux3 mux3_inst ( 
        .in_exec_result(exec_result), 
        .in_mem_data(final_read_data), 
        .in_pc_plus(pc_plus), 
        .sel(Mux3_sel), 
        .out_data(reg_write_data) 
    );

endmodule