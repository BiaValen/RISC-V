# Programa para testar as instruções SW e LW
addi x10, x0, 123  # Coloca o valor 123 no registador x10
sw   x10, 8(x0)   # Guarda o valor de x10 no endereço de memória 8
addi x11, x0, 0    # Limpa o registador x11 para garantir que o teste é válido
lw   x11, 8(x0)   # Carrega o valor do endereço 8 para o registador x11

# Fim do programa
loop:
  jal x0, loop