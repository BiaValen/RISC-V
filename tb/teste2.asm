# Programa para testar o Write-Back
addi x1, x0, 10   # x1 <- 10
addi x2, x0, 20   # x2 <- 20
add  x3, x1, x2   # x3 <- 30. Esta é a instrução que vamos verificar primeiro.
mul  x5, x1, x2   # x5 <- 200. Esta é a segunda verificação.

loop:
  jal x0, loop