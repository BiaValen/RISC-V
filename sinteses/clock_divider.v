module clock_divider #(
    parameter DIVISOR = 50_000_000 // Para gerar 1 Hz a partir de 50 MHz
)(
    input  wire clk,    // Clock de entrada rápido (ex: 50 MHz)
    input  wire reset,
    output reg  tick    // Pulso de saída de um ciclo de clock na frequência mais baixa
);

    reg [31:0] counter = 0; // Contador grande o suficiente para o DIVISOR

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            tick <= 1'b0;
        end else begin
            if (counter == DIVISOR - 1) begin
                counter <= 0;
                tick <= 1'b1; // Gera o pulso de tick
            end else begin
                counter <= counter + 1;
                tick <= 1'b0; // Mantém o tick em 0 na maior parte do tempo
            end
        end
    end

endmodule