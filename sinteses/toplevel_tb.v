// Definição da escala de tempo para a simulação: 1ns de unidade, 1ps de precisão
`timescale 1ns / 1ps

// Declaração do módulo de testbench (não possui entradas ou saídas)
module toplevel_tb;

    // --- Sinais para conectar ao Módulo Sob Teste (MUT) ---

    // Para as entradas do 'toplevel', usamos 'reg' para que possamos controlá-las
    reg         CLOCK_50;
    reg  [17:0] SW;
    reg  [3:0]  KEY;

    // Para as saídas do 'toplevel', usamos 'wire' para que possamos observá-las
    wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
    wire [9:0]  LEDR;

    // --- Instanciação do Módulo Sob Teste (MUT) ---
    // 'dut' significa "Design Under Test"
    toplevel dut (
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .KEY(KEY),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .HEX6(HEX6),
        .HEX7(HEX7),
        .LEDR(LEDR)
    );

    // --- Geração do Clock ---
    // Gera um clock de 50MHz (período de 20ns) para sempre
    always begin
        CLOCK_50 = 1'b0; // Começa em 0
        #10;             // Espera 10ns
        CLOCK_50 = 1'b1; // Vai para 1
        #10;             // Espera 10ns
    end

    // --- Estímulo de Simulação ---
    // O bloco 'initial' executa apenas uma vez, no início da simulação.
    initial begin
        // 1. Condição Inicial e Reset
        $display("Iniciando Testbench...");
        SW  <= 18'd0;    // Switches em zero
        KEY <= 4'b0000;  // Nenhum botão pressionado (assumindo ativo-alto)
        
        #100; // Espera 100ns para o sistema estabilizar

        $display("Aplicando pulso de RESET no tempo: %t", $time);
        KEY[0] <= 1'b0; // Pressiona o botão de reset (KEY[0])
        #50;            // Segura por 50ns
        KEY[0] <= 1'b1; // Solta o botão de reset
        $display("RESET liberado no tempo: %t", $time);

        #200; // Pausa pós-reset

        // 2. Simula o usuário definindo um valor nos switches
        // Vamos calcular o Fibonacci de 8 (resultado esperado: 21)
        //SW <= 18'd8;
       // $display("Switches definidos para o valor 8 no tempo: %t", $time);

        // 3. Pausa "humana" antes de apertar Enter
        #500; // Espera 500ns

        //4. Simula o aperto do botão "Enter"
        $display("Pressionando ENTER no tempo: %t", $time);
        KEY[1] <= 1'b1; // Pressiona Enter (KEY[1])
        #100;           // Segura por 100ns (simula um dedo no botão)
        KEY[1] <= 1'b0; // Solta o Enter
        $display("ENTER liberado no tempo: %t", $time);

        // // 5. Período de Observação
        // // Deixa a simulação rodar por mais tempo para que o processador
        // // possa calcular e mostrar o resultado no display.
        // $display("Aguardando o processador concluir...");
         #2000; // Espera 2000ns (2us)

        // 6. Fim da Simulação
        $display("Simulação concluída no tempo: %t", $time);
        $stop; // Comando para terminar a simulação no ModelSim
    end

endmodule