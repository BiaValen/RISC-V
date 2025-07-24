module decoder_mmio_output (
    input wire        MemWrite_i,   // Sinal original da Unidade de Controle
    input wire [31:0] Address_i,    // Endereço vindo da ULA
    
    output wire       Display_WriteEnable_o, // Habilita a escrita no display
    output wire       MemDados_WriteEnable_o // Habilita a escrita na memória de dados
);

    // Endereço do seu display, conforme o diagrama
    localparam DISPLAY_ADDR = 32'd2040;

    // A escrita no display é habilitada se MemWrite estiver ativo E o endereço for o do display.
    assign Display_WriteEnable_o = (Address_i == DISPLAY_ADDR) && MemWrite_i;

    // A escrita na memória de dados é habilitada se MemWrite estiver ativo E o endereço NÃO for o do display.
    assign MemDados_WriteEnable_o = (Address_i != DISPLAY_ADDR) && MemWrite_i;

endmodule