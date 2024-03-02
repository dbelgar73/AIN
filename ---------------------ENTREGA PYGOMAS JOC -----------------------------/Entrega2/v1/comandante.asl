// Inicialización de creencias y variables
soldiers(0).  // Número de soldados inicializado en 0
soldados([]).  // Lista de soldados vacía
i(0).  // Variable de iteración inicializada en 0

// Creencias iniciales
+flag(F): team(200)
  <-
  .register_service("comandante");  // Registro del servicio "comandante"
  .print("[COMANDANTE]: Nos atacan! Mantened posiciones! >:@ ");  // Impresión de mensaje
  .look_at(F);  // El agente mira hacia la posición de la bandera (F)
  .goto(F);  // El agente se dirige hacia la posición de la bandera (F)
  .wait(5555);  // Espera (5 segundos)
  .get_backups;  // El agente obtiene los backups disponibles
  .get_medics;  // El agente obtiene los médicos disponibles
  //.wait(4444);  // Espera (4 segundos)
  +organizarTropas.  // Activa la creencia "repartirPOS"

//###################################ORGANIZAR DEFENSA##############################################################
  // reparte 4 posiciones iniciales entre los 4 primeros agentes registrados
+organizarTropas: team(200) & flag(F) & soldados(B)
  <-
  .print("[COMANDANTE]: A sus posiciones: ", ListaSoldados);  // Impresión de mensaje
  .defencePOS(F, Po);  // Cálculo de las posiciones defensivas en base a la bandera (F) y se guarda en Po
  +vigilantes(Po);  // Se activa la creencia "vigilantes" con las posiciones defensivas (Po)
  .wait(1000);  // Espera de 1000 milisegundos (1 segundo)
  -+i(0);  // Reinicia el contador "i" a 0
  while (i(I) & I < 4) {  // Bucle mientras el contador "i" sea menor a 4
    .nth(I, Po, P1);  // Obtiene la posición P1 en la posición I del arreglo Po
    .print("[COMANDANTE]: Punto ", I, ": ", P1);  // Impresión de mensaje con el punto y la posición P1
    .nth(I, B, Sold);  // Obtiene el soldado Sold en la posición I del arreglo B
    .send(Sold, tell, irA(P1));  // Envía un mensaje al soldado Sold para que se mueva a la posición P1
    .print("Ahora", Sold, " es torre.");  // Impresión de mensaje indicando que el soldado Sold se convierte en torre
    .send(Sold, tell, laTorre);  // Envía un mensaje al soldado Sold para que actúe como una torre
    -+i(I+1);  // Aumenta el contador "i" en 1
  }
  -organizarTropas;  // Se elimina la creencia "organizarTropas"
  +dejarMuni;  // Se activa la creencia "dejarMuni"
  .print("[COMANDANTE]: Posiciones repartidas...").  // Impresión de mensaje indicando que las posiciones han sido repartidas

// Cuando un agente se conecta, este se registra en la lista de Fieldop para su posterior posible uso
+registrar[source(S)]: team(200) & soldados(SS)
  <-
  -registrar;  // Se elimina la creencia "registrar"
  .concat(SS, [S], ListaSoldados);  // Concatena el agente S al final del arreglo SS y guarda el resultado en L
  -+soldados(ListaSoldados).  // Actualiza la creencia "soldados" con el arreglo L


//########################################MUNICION################################################################
// Se obtiene la posición de cada vigilante, y si no hay amenaza, el Fieldop irá dando vueltas de uno en uno
// dejándoles la munición al lado, por si en caso de una emboscada, puedan tener munición rápidamente a su alcance
// y no perder tiempo comunicándose con otros comandante
+dejarMuni: vigilantes(V) & not batalla
  <-
  .nth(0, V, R);  // Obtiene la primera posición del arreglo de vigilantes y la guarda en R
  +repartir;  // Agrega la creencia "repartir"
  .goto(R);  // Va a la posición R
  .delF(V, W);  // Elimina la creencia de vigilantes (V) y guarda el resultado en W
  .concat(W, [R], E);  // Concatena la posición R al final del arreglo W y guarda el resultado en E
  -+vigilantes(E);  // Actualiza la creencia de vigilantes con el nuevo arreglo E
  -dejarMuni.  // Elimina la creencia "dejarMuni"

// En caso de que algo falle, irá a parar en el centro
+dejarMuni: not batalla
  <-
  .goto(F);  // Va a la posición F (centro)
  +repartir;  // Agrega la creencia "repartir"
  -dejarMuni.  // Elimina la creencia "dejarMuni"

// Cuando llegue a su objetivo para dejar la munición, generará un paquete
// y seguirá al siguiente punto de reencuentro mientras no se encuentre en amenaza
+target_reached(T): repartir & not batalla
  <-
  .print("[COMANDANTE]: Toma muni");  // Imprime un mensaje indicando que se está dejando la munición
  .reload;  // Recarga la munición
  -repartir;  // Elimina la creencia "repartir"
  +dejarMuni.  // Agrega la creencia "dejarMuni" para seguir repartiendo munición

// Crea munición cada 4 segundos, así siempre habrá paquetes por el campo
+crearMUNICION
  <-
  .wait(4000);  // Espera 4 segundos
  -+crearMUNICION.  // Vuelve a agregar la creencia "+crearMUNICION" para que se repita el proceso de creación de munición cada 4 segundos  


//###################################ORGANIZAR ANTE ATAQUE#####################################################
// Cuando se carguen los médicos, los guarda en una variable aparte para poder usarlos en caso de emergencia
+myMedics(M) <- +medico(M).
// En caso de amenaza, el fieldop se irá al centro, ya que como no podemos seguir la flag,
// nos jugamos la partida a no dejar que pase nadie al centro, y se quedará campeando
+veteAlCentro([X,Y,Z])[source(S)]: flag(F) & not batalla
  <-
  +batalla;  // Activa el modo de guerra estableciendo la creencia "+modoWAR"
  +objetivo([X,Y,Z]);  // Establece el objetivo del Fieldop como la posición [X,Y,Z]
  .goto(F);  // Va hacia la posición de la bandera (centro)
  .print("[COMANDANTE]: Voy al centro!!!").  // Imprime un mensaje indicando que el Fieldop se dirige al centro

// Cuando llega al centro, empieza a generar paquetes de munición y llama al médico
// para que venga al centro a generar también paquetes
+target_reached(T): batalla & objetivo([X,Y,Z]) & medico(M)
  <-
  .look_at([X,Y,Z]);  // Orienta la mirada hacia la posición [X,Y,Z]
  .print("[COMANDANTE]: Estoy en el centro");  // Imprime un mensaje indicando que el Fieldop está en el centro
  .send(M, tell, venAlCentro);  // Envía un mensaje al médico solicitando que venga al centro ("venAlCentro")
  .reload;  // Recarga la munición
  +crearMUNICION.  // Establece la creencia "+crearMUNICION" para empezar a generar paquetes de munición

//###################################AYUDAS#########################################################################
// Cuando llega al punto de reencuentro con un agente que lo pidió,
// resetea el uso de ayuda para que otro agente pueda llamarlo
+target_reached(T): ayudando
  <-
  -ayudando.  // Elimina la creencia "+ayudando" para indicar que el Fieldop ha terminado de ayudar a un agente

// Crea munición cada 4 segundos, así siempre habrá paquetes por el campo

// Cuando un agente pide ayuda, se decide una posición donde quedar,
// que será el punto medio entre los dos
+help(P)[source(S)]: not ayudando & position(PP)
  <-
  +ayudando;  // Agrega la creencia "+ayudando" para indicar que el Fieldop está proporcionando ayuda
  .distMedia(P, PP, D);  // Calcula la posición media entre la posición del agente que solicita ayuda (P) y la posición actual del Fieldop (PP) y guarda el resultado en D
  .send(S, tell, reunion(D));  // Envía un mensaje al agente que solicitó ayuda indicando la posición de reunión (D)
  .print("[COMANDANTE]: Apunta punto de reunión ").  // Imprime un mensaje indicando que el Fieldop está apuntando al punto de reunión

// Si esta ayudando a otro agente, no esta disponible
+help(P)[source(S)]: ayudando & flag(F)
  <-
  .send(S, tell, reunion(F));  // Envía un mensaje al agente que solicitó ayuda indicando que se reúnan en el punto de la bandera (F)
  .print("[COMANDANTE]: Ahora no puedo ayudarte").  // Imprime un mensaje indicando que el Fieldop no puede proporcionar ayuda en este momento

// Si han robado la bandera no ayuda mas
+help(P)[source(S)]: not flag(F)
  <-
  -ayudando.  // Elimina la creencia de que el Fieldop está ayudando a otro agente

//##########################################ENEMIGO DELANTE###############################################
// dispara si hay algún enemigo en su campo de visión
+enemies_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): batalla
  <-
  .look_at([X,Y,Z]);  // Dirige la mirada hacia la posición del enemigo
  .shoot(5, [X,Y,Z]).  // Dispara al enemigo con una potencia de 5 y apunta a su posición ([X,Y,Z])