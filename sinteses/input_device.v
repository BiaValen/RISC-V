module input_device(
    input  wire        clk,        // Clock rápido (50MHz)
    input  wire        reset,
    // Sinais Físicos
    input  wire [31:0] physical_switches_i,
    input  wire        enter_button_i,    
    // Interface com a CPU (MMIO)
    input  wire        cpu_read_en,     // Sinal indicando que a CPU está lendo deste dispositivo
    output wire  [31:0]data_for_cpu_o,   // Dado + Status para a CPU
    output reg         data_ready
);

    reg [31:0] captured_data; // Registra o valor dos switches

    // Lógica para capturar os dados e levantar a bandeira
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_ready <= 1'b0;
            captured_data <= 32'b0;
        end else if (enter_button_i) begin // No pulso do Enter...
            captured_data <= physical_switches_i; // ...captura o valor
            data_ready <= 1'b1;                   // ...e levanta a bandeira.
        end else if (cpu_read_en) begin // Se a CPU está lendo...
            data_ready <= 1'b0;       // ...abaixa a bandeira. NAO COMENTAR
        end
    end

    
    assign data_for_cpu_o = captured_data;


endmodule