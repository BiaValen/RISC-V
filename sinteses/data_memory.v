module data_memory (
    input  wire        clk_read,
	 input  wire       clk_write,
    input  wire        MemWrite,    // Sinal da Unidade de Controle para habilitar a escrita
    input  wire        MemRead,     // Sinal da Unidade de Controle para habilitar a leitura
    input  wire [31:0] address,     // Endereço vindo da ULA
    input  wire [31:0] write_data,  // Dado a ser escrito, vindo do ReadData2
    output reg  [31:0] read_data    // Dado lido que vai para o MUX final
);

	 reg [31:0] address_latch;

    // Memória de Dados com 256 palavras de 32 bits (1KB). -> mudar pra 2^16 (maior)
    reg [31:0] mem [0:255];


    // --- LÓGICA DE ESCRITA SÍNCRONA ---
    // A escrita acontece apenas na borda de subida do clock se MemWrite estiver ativo.
    always @(posedge clk_read) begin
		 address_latch <= address;	  
    end
	 
	 always@(posedge clk_write)begin
	  if (MemWrite) begin
            mem[address[9:2]] <= write_data; // Usando os bits do endereço que correspondem ao tamanho da memória
       end
	 end

    // Leitura Síncrona com 1 ciclo de latência
    always @(posedge clk_read) begin
        if (MemRead) begin
            read_data <= mem[address[9:2]];
        end
    end

endmodule