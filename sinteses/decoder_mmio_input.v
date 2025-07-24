module decoder_mmio_input (
    input wire        MemRead_i,   // Sinal original da Unidade de Controle
    input wire [31:0] Address_i,   // Endereço vindo da ULA

    //vai para o pino de seleção do MUX 5
    output wire       select_input_device_o 
);

    // Endereço do dispositivo de entrada
    localparam INPUT_ADDR = 32'd2044; // Limitado à -2048-2047 por causa do tamanho do registrador de 32 bits

    // O MUX 5 deve selecionar o dispositivo de entrada se MemRead estiver ativo E o endereço for o do dispositivo.
    assign select_input_device_o = (Address_i == INPUT_ADDR) && MemRead_i;

endmodule