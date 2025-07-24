_start:
    # Teste 1: JAL - Pular sobre uma seção
    jal ra, pular_secao   # Salta para a etiqueta 'pular_secao', salva PC+1 em ra
    addi x10, x0, 99      # Esta instrução deve ser PULADA

pular_secao:
    # Teste 2: BEQ - Tomar o desvio
    addi x5, x0, 10
    addi x6, x0, 10
    beq x5, x6, desvio_tomado # Como x5 == x6, deve pular para 'desvio_tomado'
    addi x11, x0, 111     # Esta instrução deve ser PULADA

desvio_tomado:
    addi x12, x0, 222     # O PC deve chegar aqui

    # Teste 3: BNE - Não tomar o desvio
    bne x5, x6, nao_tomar # Como x5 == x6, NÃO deve pular
    addi x13, x0, 333     # Esta instrução deve ser EXECUTADA

nao_tomar:
    # Teste 4: JALR - Retornar da "chamada" inicial
    jalr x0, 0(ra)        # Pula para o endereço armazenado em ra (linha após o primeiro jal)

loop_infinito:
    j loop_infinito       # Para o processador no final