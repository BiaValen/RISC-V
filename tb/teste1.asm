# Meu primeiro programa de teste
# Objetivo: Somar 10 + 20 e guardar em x3. Depois multiplicar e guardar em x5.

.text
.globl _start

_start:
  addi x1, x0, 10      # Carrega o valor 10 no registrador x1
  addi x2, x0, 20      # Carrega o valor 20 no registrador x2
  add  x3, x1, x2      # Soma x1 e x2, guarda o resultado (30) em x3
  mul  x5, x1, x2      # Multiplica x1 e x2, guarda o resultado (200) em x5
  
# Loop infinito para "parar" o processador no final do programa
loop:
  jal x0, loop