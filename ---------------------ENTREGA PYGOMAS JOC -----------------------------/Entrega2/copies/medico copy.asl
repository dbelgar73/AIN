// Guarda la posición de la bandera en una variable y localiza al coronel.
// Se espera 3 segundos antes de buscar al comandante para evitar problemas de concurrencia.
+flag(F): team(200)
  <-
  +posicionBandera(F);  // Guarda la posición de la bandera
  .wait(3500);  // Espera 3,5 segundos para evitar problemas de concurrencia
  .get_service("comandante");  // Busca al agente comandante
  .goto(F);  // Se dirige hacia la posición de la bandera

// Cuando el agente llega al centro (posición de la bandera), comienza a curar.
+target_reached(T): team(200)
  <-
  .cure;  // Comienza el proceso de curación
  .print("En posición! :D ");  // Muestra un mensaje indicando que el agente está en su posición

// Cuando aparece el comandante, se guarda su referencia en una variable más fiable.
// Esta referencia se utiliza para evitar problemas de concurrencia en el futuro.
+comandante(C)
  <-
  +comandante0(C);  // Guarda la referencia del comandante en la variable 'comandante0'
  .print("A sus ordenes comandante! o.o ");  // Muestra un mensaje indicando que se ha encontrado al comandante

// Da vueltas para comprobar si hay alguien en el entorno
+comprobar: team(200) & position([X,Y,Z])
  <-
  .look_at([X-1,Y,Z]);  // Mirar en la dirección X-1
  .wait(400);  // Esperar 400 milisegundos
  .look_at([X+1,Y,Z]);  // Mirar en la dirección X+1
  .wait(400);  // Esperar 400 milisegundos
  .look_at([X,Y,Z-1]);  // Mirar en la dirección Z-1
  .wait(400);  // Esperar 400 milisegundos
  .look_at([X,Y,Z+1]);  // Mirar en la dirección Z+1
  .wait(400);  // Esperar 400 milisegundos  
  ?objetivo(O);  // Verificar si hay un objetivo en la vista
  .look_at(O);  // Mirar hacia el objetivo encontrado
  -comprobar;  // Eliminar la creencia de comprobación

// Cuando el agente es llamado al centro, se dirige hacia allí y esta atento
+venAlCentro:posicionBandera(F)
  <-
  +batalla;  // Activar el modo batalla
  .goto(F);  // Ir hacia el punto de llamada (centro)
  .print("Entendido");  // Mostrar un mensaje indicando que ha entendido la orden
  .look_at(F);  // Mirar hacia el punto de llamada (centro)

// Cuando el agente llega al centro, comienza a generar botiquines
+target_reached(T): batalla
 <-
 .cure;  // Comenzar el proceso de generación de botiquines
 +crearPaquetes;  // Activar la creación de botiquines
 +comprobar;  // Realizar comprobaciones en el entorno

+crearPaquetes
  <-
  .cure;  // Inicia el proceso de creación de botiquines
  .wait(4000);  // Espera 4000 milisegundos (4 segundos)
  -+crearPaquetes.  // Elimina la creencia de crearPaquetes para que se pueda activar nuevamente en el siguiente ciclo