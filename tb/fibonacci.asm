# Programa para calcular o N-ésimo número de Fibonacci (iterativo)
# O resultado final será armazenado em x10.

# Mapeamento de Registradores:
# x5 (t0): N, o índice do número de Fibonacci a ser calculado.
# x6 (t1): n-1, o contador do loop.
# x10 (a0): fib(n), o resultado atual (e final).
# x11 (a1): fib(n-1), o valor anterior.
# x12 (a2): fib(n-2), o valor anterior ao anterior.
# x13 (t3): temporário para a soma.

_start:
    # -------------------------------------------------------------
    # Configuração Inicial: Definir N e os valores base
    # -------------------------------------------------------------
    addi x5, x0, 10      # N = 10. Queremos calcular o 10º número de Fibonacci.
                         # (Fib(10) = 55)
    
    beq  x5, x0, fim     # Se N=0, o resultado é 0. Pula para o fim.
    addi x6, x5, -1      # Contador do loop n-1 = N-1.

    # Casos base de Fibonacci:
    addi x10, x0, 1      # fib(n), começa com fib(1) = 1
    addi x11, x0, 0      # fib(n-1), começa com fib(0) = 0
    
    # Se N=1, o loop não será executado e o resultado já é 1 (correto).
    beq  x6, x0, fim     # Se N=1, o contador n-1 é 0. Pula para o fim.

loop:
    add  x13, x11, x10    # temp = fib(n-1) + fib(n)
    
    mv   x11, x10         # fib(n-1) = fib(n) (valor de x10 da iteração anterior)

    mv   x10, x13         # fib(n) = temp


    addi x6, x6, -1      # Decrementa o contador
    bne  x6, x0, loop    # Se o contador não for zero, repete
fim:

    # O resultado final está em x10.
    # Adiciona um loop infinito para parar o processador para inspeção.
loop_infinito:
    j loop_infinito