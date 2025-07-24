`timescale 1ns/1ps

module RISCV_processor_tb;


    // Sinais do Testbench
    reg clk;
    reg reset;
    reg [17:0] external_input_i; // Para simular entrada externa

    // Saídas do Processador (conectadas aos wires)
    wire [31:0] display_data_o;
    wire        display_we_o;
    wire [31:0] pc_out_debug;
    wire [31:0] next_pc_debug;

    // Instanciação do Módulo RISCV_processador
    RISCV_processador cpu (
        .clk(clk),
        .reset(reset),
        .external_input_i(external_input_i),
        .display_data_o(display_data_o),
        .display_we_o(display_we_o),
        .pc_out_debug(pc_out_debug),
        .next_pc_debug(next_pc_debug)
    );

    // Geração do Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock de 10ns de período (100MHz)
    end

    // Sequência de Reset e Estímulos
    initial begin
        reset = 1; // Ativa reset
        external_input_i = 18'b0; // Garante entrada zerada
        #100; // Mantém reset ativo por 100ns
        reset = 0; // Libera reset
        #10; // Pequeno atraso

        // Aqui você pode adicionar estímulos para external_input_i se o seu programa Fibonacci precisar de input
        // Por exemplo, para simular o botão ENTER:
        /#500; // Espera um tempo
        external_input_i = 18'd10; // Simula um valor de switch
        #10; // Pequeno atraso
        enter_button_i = 0; // Libera o botão

        // Executa por um tempo suficiente para o programa Fibonacci rodar
        #500000; // Roda a simulação por 500us (ajuste conforme a necessidade do seu programa)

        $finish; // Termina a simulação
    end

    // Monitoramento de Sinais (para visualização no waveform viewer)
    initial begin
        $dumpfile("dump.vcd"); // Arquivo para salvar as waveforms
        $dumpvars(0, tb_riscv_processor); // Salva todos os sinais no testbench
    end

endmodule
