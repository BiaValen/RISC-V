module toplevel (
    input  wire        CLOCK_50,
    input  wire [17:0] SW,
    input  wire [3:0]  KEY,
    
    output wire [6:0]  HEX0, HEX1, HEX2, HEX3, 
    output wire [6:0]  HEX4, HEX5, HEX6, HEX7,
    output wire [9:0]  LEDR 
);
    
    wire [31:0] input_device_data;
    wire [31:0] current_pc_from_cpu;
    wire [31:0] debug_next_pc;
    wire        cpu_is_reading_input; 

    wire        reset_key_pressed = ~KEY[0]; 
    wire        enter_key_pressed = ~KEY[1]; 
    
    wire        reset_signal; 
    wire        enter_signal; 

    wire        tick_1hz;

    wire        input_data_ready_signal;

     // --- Sinais que conectam a CPU ao Display ---
    wire        we_signal_from_cpu;
    wire [31:0] data_from_cpu_for_output;
    reg  [31:0] display_value_reg;
	 
	 

    clock_divider #(
        .DIVISOR(10_000_000)//50_000_000
    ) clk_div_1hz (
        .clk(CLOCK_50),
        .reset(reset_signal),
        .tick(tick_1hz)
    );

    // Debouncers para os botões
    debouncer reset_debouncer (
        .clk(CLOCK_50),
        .button_in(reset_key_pressed),
        .button_out(reset_signal)
    );

    debouncer enter_debouncer (
        .clk(CLOCK_50),
        .button_in(enter_key_pressed),
        .button_out(enter_signal)
    );

   

    input_device input_unit (
        .clk(CLOCK_50),
        .reset(reset_signal),
        .physical_switches_i({14'b0, SW[17:0]}),
        .enter_button_i(enter_signal), //mudei aqui pra simulação
        .cpu_read_en(cpu_is_reading_input), // Informa ao controlador quando a CPU está lendo
        .data_for_cpu_o(input_device_data),
        .data_ready(input_data_ready_signal)
    );

    RISCV_processador cpu (
        .clk(tick_1hz),
        .reset(reset_signal),
        .external_input_i(input_device_data),  
        .display_data_o(data_from_cpu_for_output),
        .display_we_o(we_signal_from_cpu),
        .pc_out_debug(current_pc_from_cpu), 
        .is_reading_input_debug_o(cpu_is_reading_input),
        .data_is_ready_from_input(input_data_ready_signal),
        .next_pc_debug(debug_next_pc),
		.debug_instruction(w_debug_instruction),
		.debug_MemRead(w_debug_MemRead),
		.debug_alu_result(w_debug_alu_result),
		.debug_select_input_device(w_debug_select_input_device)		  
    );
    
    // --- LÓGICA DO DISPLAY COM REGISTRADOR DE SAÍDA DEDICADO ---
    always @(posedge CLOCK_50 or posedge reset_signal) begin
        if (reset_signal) begin
            display_value_reg <= 32'd0; // Valor inicial para teste
        end else if (we_signal_from_cpu) begin
            display_value_reg <= data_from_cpu_for_output;
        // end else if (enter_signal) begin // DEBUG: Use SW[17] para testar manualmente
        //      display_value_reg <= {15'b0, SW[16:0]}; // Mostra valor dos switches
        end
    end

    wire [31:0] bcd_result;
    binary_to_bcd bcd_converter (
        .binary_in(display_value_reg),
        .bcd_out(bcd_result)
    );
    
    // Função de conversão BCD para 7 segmentos
    function [6:0] bcd_to_7seg;
        input [3:0] digit;
        case (digit)
            4'h0: bcd_to_7seg = 7'b1000000; // 0
            4'h1: bcd_to_7seg = 7'b1111001; // 1
            4'h2: bcd_to_7seg = 7'b0100100; // 2
            4'h3: bcd_to_7seg = 7'b0110000; // 3
            4'h4: bcd_to_7seg = 7'b0011001; // 4
            4'h5: bcd_to_7seg = 7'b0010010; // 5
            4'h6: bcd_to_7seg = 7'b0000010; // 6
            4'h7: bcd_to_7seg = 7'b1111000; // 7
            4'h8: bcd_to_7seg = 7'b0000000; // 8
            4'h9: bcd_to_7seg = 7'b0010000; // 9
            default: bcd_to_7seg = 7'b1111111; // Apagado
        endcase
    endfunction

    
    assign HEX0 = bcd_to_7seg(bcd_result[3:0]);    // Unidades
    assign HEX1 = bcd_to_7seg(bcd_result[7:4]);    // Dezenas
    assign HEX2 = bcd_to_7seg(bcd_result[11:8]);   // Centenas
    assign HEX3 = bcd_to_7seg(bcd_result[15:12]);  // Milhares
    assign HEX4 = bcd_to_7seg(bcd_result[19:16]);
    assign HEX5 = bcd_to_7seg(bcd_result[23:20]);
    assign HEX6 = bcd_to_7seg(bcd_result[27:24]);
    assign HEX7 = bcd_to_7seg(bcd_result[31:28]);  // Dígito mais significativo

    // Clock de teste
    reg [24:0] clock_divider_reg;
    always @(posedge CLOCK_50 or posedge reset_signal) begin
        if (reset_signal) begin
            clock_divider_reg <= 0;
        end else begin
            clock_divider_reg <= clock_divider_reg + 1;
        end
    end

    // Debug LEDs - MAIS DETALHADOS
    assign LEDR[0] = clock_divider_reg[24]; // pisca 1 vez por segundo
    assign LEDR[1] = we_signal_from_cpu;    // CRÍTICO: deve acender quando CPU escreve
    assign LEDR[2] = |display_value_reg;    // indica se há valor no display
    assign LEDR[3] = enter_signal;          // botão enter pressionado
    assign LEDR[4] = reset_signal;          // reset ativo
    assign LEDR[5] = (current_pc_from_cpu != 32'd0); // PC não está no início
    assign LEDR[6] = |bcd_result;           // conversão BCD funcionando
    assign LEDR[7] = tick_1hz;              // clock de 1Hz
    assign LEDR[8] = |data_from_cpu_for_output; // dados vindos da CPU
    assign LEDR[9] = |input_device_data;    // dados do dispositivo de entrada

endmodule