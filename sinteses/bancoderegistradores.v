module bancoderegistradores (
    input  wire        clock,
    input  wire        reset,          // Sinal de reset (ativo alto)
    input  wire        reg_write,      // Habilita escrita no registrador (da Unidade de Controle)
    input  wire [4:0]  read_addr1,     // Endereco do registrador rs1
    input  wire [4:0]  read_addr2,     // Endereco do registrador rs2
    input  wire [4:0]  write_addr,     // Endereco do registrador rd (destino)
    input  wire [31:0] write_data,     // Dado a ser escrito no registrador (do MUX3)

    output wire [31:0] read_data1,     // Dado lido de rs1
    output wire [31:0] read_data2      // Dado lido de rs2
);

    //(flip-flops)
    reg [31:0] rf_array [0:31];

    // logica de Leitura Combinacional. O registrador x0 (endereco 0) sempre retorna 0.
    assign read_data1 = (read_addr1 == 5'b0) ? 32'b0 : rf_array[read_addr1];
    assign read_data2 = (read_addr2 == 5'b0) ? 32'b0 : rf_array[read_addr2];

    //logica de escrita sincrona
    // A escrita ocorre apenas na borda de subida do clock E se reg_write estiver ativo e se o endereço de escrita nao for x0.
    integer i; 
    always @(posedge clock or posedge reset) begin
        if (reg_write && (write_addr != 5'b0)) begin
            // Condicao de escrita:
            // 1. reg_write deve ser '1' (habilitado pela Unidade de Controle).
            // 2. write_addr nao deve ser 5'b0, nao tentar escrever no registrador x0.
            rf_array[write_addr] <= write_data; // Atribuicao não bloqueante, valor eh atualizado na borda do clock.
        end
        // Se as condicoes acima nao forem atendidas, os valores nos rf_array permanecem inalterados
    end

endmodule