# Juan Pablo Del Muro Quintero
# Luisa Ikram Zaldivar Procel


.text
main:
    lui s1, 0x10010  # se guarda la direccion en s1, la de la primera torre
    addi s0, zero, 5 # s0 es la cantidad de discos
    add s2, zero, s1 # es el puntero a la torre 2, esto se hace porque cuando se vayan aumentando discos a s1, s2 va a tener la dirección de memoria de s1 al inicio


    addi t0, zero, 1 # t0 empieza en 1 y sirve para contar los discos, se explica mas abajo

for:
    bge s0, t0, continuar_for  # Si s0 es mayor o igual a t0, continúa el bucle, si pasa al continuar for significa que quedan discos por colocar, si no se va a saltar al endfor
    jal zero, endfor           # Si no, salta a endfor
# ENDFOR Cuando t0 llega a 4, la condición bge s0, t0, continuar_for ya no se cumple (s0 es 3, y 3 no es mayor ni igual a 4), así que el bucle termina.


continuar_for:
    sw t0, 0(s1)         
    addi s1, s1, 32    # Incrementar s1 en 32 bytes simulando el siguiente espacio en la torre 
    addi t0, t0, 1     # t0 + 1 para el siguiente disco
    jal zero, for      # Regresa al inicio del bucle


#Prepara el entorno para mover los discos
endfor:

    addi s3, s1, 8    # puntero para la torre 3, empieza en s1+8 para que s3 mida lo mismo que s1 llena
    add s1, zero, s2  # reiniciamos s1 a los valores originales
    addi s2, s3, -4   # libera espacio de la pila

    addi t1, zero, 1  # Torre 1, 2 y 3 identificador
    addi t3, zero, 2  
    addi t2, zero, 3  # linea ahorrable
    jal mover_disco
    jal endCode

mover_disco:
    addi t4, zero, 1 # se registra 1 en t4 para hacer la comparacion de abajo
    bne s0, t4, varios_discos # Si s0 es diferente a 1, hay varios discos por mover, así que salta a varios_discos

    # este es el caso base
    addi sp, sp, -4 # hace espacio en la pila
    sw ra, 0(sp)    # guarda ra en la pila
    jal cargar_desde 
    jal almacenar_en_destino 
    
    lw ra, 0(sp) # recuperar ra de la pila
    addi sp, sp, 4 # liberar espacio
    jalr ra

varios_discos:
    # Guardar ra, s0, t1 , t2 y t3 en la pila (push)
    addi sp, sp, -4
    sw ra, 0(sp)
    
    addi sp, sp, -4
    sw s0, 0(sp)
    
    addi sp, sp, -4
    sw t1, 0(sp) # t1 = 1: Representa la torre de origen
    
    addi sp, sp, -4
    sw t2, 0(sp) # t2 = 3: Representa la torre de destino.
    
    addi sp, sp, -4
    sw t3, 0(sp) # t3 = 2: Representa la torre auxiliar


    # cambiar torres y reducur discos
    add t4, t3, zero # Esta línea copia el valor de t3 (que es 2, la torre auxiliar)
    add t3, t2, zero # Aquí, el valor de t2 (que es 3, la torre de destino) se copia en t3
    add t2, t4, zero # En esta línea, se copia el valor almacenado en t4 (originalmente t3, la torre auxiliar) en t2
    # Esto hace que t2 (originalmente la torre de destino) se convierta en la nueva torre auxiliar
    
    addi s0, s0, -1 # le quita 1 a s0 ( número de discos por mover )
    jal mover_disco # llamada recursiva 

    # Restaurar el estado de la pila tras la llamada recursiva (pop)
    lw t3, 0(sp)
    addi sp, sp, 4
    
    lw t2, 0(sp)
    addi sp, sp, 4
    
    lw t1, 0(sp)
    addi sp, sp, 4
    
    lw s0, 0(sp)
    addi sp, sp, 4
    
    lw ra, 0(sp)
    addi sp, sp, 4

    # Mover disco en torre de origen a torre destino
    addi sp, sp, -4 # Hacer espacio en la pila para guardar ra
    sw ra, 0(sp) # Guardar ra
    jal cargar_desde # Cargar disco de la torre de origen
    jal almacenar_en_destino # Almacenar el disco en la torre de destino
    lw ra, 0(sp) # Restaurar ra
    addi sp, sp, 4 # Liberar espacio en la pila

    # Intercambio de torres para mover discos restantes
    addi sp, sp, -4 
    sw ra, 0(sp)
    
    # Manejo temporal de valores para evitar sobrescribir los datos
    add t4, t3, zero # Guarda el valor de t3 en t4 (temporal)
    add t3, t1, zero # Copia el valor de t1 en t3			t3, que representaba la torre auxiliar, ahora apunta a la torre de origen.
    add t1, t4, zero # Copia el valor de t4 (original t3) en t1     	t1, que representaba la torre de origen, ahora apunta a la torre auxiliar.
    
    addi s0, s0, -1 #s0 -1
    jal mover_disco # recursividad
    lw ra, 0(sp) # se restaura ra y luego se libera espacio en la pila
    addi sp, sp, 4 #libera espacio en la pila

    jalr ra

cargar_desde:
    addi t6, zero, 1  # t6 guarda 1 que sirve para la comparacion
    beq t1, t6, cargar_de_1 # Si t1 == 1, cargar desde la torre 1
    addi t6, zero, 2
    beq t1, t6, cargar_de_2 # Si t1 == 2, cargar desde la torre 2

    # Cargar desde la torre 3
    lw t5, 0(s3) # Cargar el valor del disco en t5 desde s3
    sw zero, 0(s3)  # Vaciar la posición de s3
    addi s3, s3, 32 # Incrementar s3 32 bytes para la siguiente posicion
    jalr ra                

# Cargar el disco actual desde la torre de origen y prepararse para moverlo

cargar_de_1:
    lw t5, 0(s1) # saca 1 disco desde s1 y lo guarda en t5
    sw zero, 0(s1) # vacia la posicion en la que estaba el disco con un 0
    addi s1, s1, 32 # s1 cambia a la siguiente posicion preparando para esperar un sguiente disco
    jalr ra

cargar_de_2:
    lw t5, 0(s2)
    sw zero, 0(s2)
    addi s2, s2, 32
    jalr ra



# Almacenar el disco en la torre indicada por t2
almacenar_en_destino:
    addi t6, zero, 1
    beq t2, t6, almacenar_en_1 # Si t2 == 1, almacenar en la torre 1
    addi t6, zero, 2
    beq t2, t6, almacenar_en_2 # Si t2 == 2, almacenar en la torre 2

    #almacenar en la torre 3
    addi s3, s3, -32 # Mover s3 a la siguiente posición libre (hacia arriba en la pila)
    sw t5, 0(s3) # Almacenar el valor del disco en t5 en la posición actual de s3
    jalr ra


# Almacenar el disco en la torre 1 apuntar al siguiente espacio y guardar el valor del disco
almacenar_en_1:
    addi s1, s1, -32  # Mover s1 a la siguiente posición libre (hacia arriba en la pila)
    sw t5, 0(s1)
    jalr ra


# lo mismo pero ahora en torre 2
almacenar_en_2:
    addi s2, s2, -32  # Mover s2 a la siguiente posición libre (hacia arriba en la pila)
    sw t5, 0(s2)
    jalr ra
		
endCode: # FIN
