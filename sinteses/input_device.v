module input_device(
    input  wire        clk,        // Clock rápido (50MHz)
    input  wire        reset,

    // Sinais Físicos
    input  wire [31:0] physical_switches_i,
    input  wire        enter_button_i,     // Pulso limpo do debouncer do "Enter"

    // Interface com a CPU (MMIO)
    input  wire        cpu_read_en,     // Sinal indicando que a CPU está lendo deste dispositivo
    output wire  [31:0]data_for_cpu_o   // Dado + Status para a CPU
);

    reg [31:0] captured_data; // Registra o valor dos switches
    reg        data_ready;    // A "bandeira" que indica que novos dados foram capturados

    // Lógica para capturar os dados e levantar a bandeira
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_ready <= 1'b0;
            captured_data <= 32'b0;
        end else if (enter_button_i) begin // No pulso do Enter...
            captured_data <= physical_switches_i; // ...captura o valor
            data_ready <= 1'b1;                   // ...e levanta a bandeira.
        end else if (cpu_read_en) begin // Se a CPU está lendo...
            data_ready <= 1'b0;       // ...abaixa a bandeira.
        end
    end

    // A saída para a CPU combina o dado capturado com o bit de status
    // O bit 31 será nossa flag 'data_ready'. Os bits 30:0 serão os dados.
    assign data_for_cpu_o = {data_ready, captured_data[30:0]};


endmodule