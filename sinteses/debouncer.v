module debouncer (
    input  wire clk,           // Clock (50MHz)
    input  wire button_in,     // Sinal do botão físico (com bounce, ativo alto)
    output reg  button_out     // Sinal de saída limpo e estável (nível)
);

    // Precisamos de um contador para o atraso. 20ms = 1,000,000 ciclos de 50MHz.
    // 20 bits para o contador (2^20 > 1,000,000).
    localparam DEBOUNCE_DELAY = 20'd1000000;
    
    reg [19:0] counter = 0;
    reg        intermediate_state = 0;

    always @(posedge clk) begin
        if (button_in != intermediate_state) begin
            // Se a entrada mudou, reinicia o contador
            counter <= DEBOUNCE_DELAY;
        end else if (counter > 0) begin
            // Se a entrada está estável, decrementa o contador
            counter <= counter - 1;
        end

        // Se o contador chegou a zero, significa que a entrada esteve
        // estável por tempo suficiente. Atualiza o estado interno.
        if (counter == 0) begin
            intermediate_state <= button_in;
        end
    end
    
    // A saída final é registrada para evitar glitches
    always @(posedge clk) begin
        button_out <= intermediate_state;
    end

endmodule