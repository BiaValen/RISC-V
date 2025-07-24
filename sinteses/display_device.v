    // --- SAIDA ---
    module display_device (
    input wire clk,
    input wire reset,
    input wire display_write_enable, // Vem do decoder_mmio_output
    input wire [31:0] data_in        // Vem de ReadData2
);

    always @(posedge clk) begin
        if (display_write_enable) begin
            $display("DISPLAY @ t=%0t ns: Recebeu valor para exibir: %d (%h)", $time, $signed(data_in), data_in);
        end
    end

    endmodule
