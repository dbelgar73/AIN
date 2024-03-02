//TEAM_AXIS
+flag (F): team(200)
  <-
    .wait(2000); // Espera 2s
    +ayudaSolicitada(0); // Establece la variable 'ayudaSolicitada' a 0
    +siguiendo(0); // Establece la variable 'siguiendo' a 0
    +auxiliar(0); // Establece la variable 'auxiliar' a 0
    +enemigosVistos(0). // Establece la variable 'enemigosVistos' a 0

// Asegura de recordar al comandante que mantenga una vigilancia constante sobre la bandera.
+comandante(C)
  <-
    -comandante(C); // Elimina el evento 'comandante' con el parámetro 'C' de la agenda
    .send(C, achieve, mirar_bandera). // Envía un mensaje al comandante 'C' con el objetivo de "mirar_bandera"

//######################################### RECUPERAR LA BANDERA ######################################################
// En caso de avistar a alguien, procedemos a darle persecución.
+!recuperarBandera: enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
    .print("[SOLDADO]: Han robado la bandera! -.- Voy a seguir a:  ",ID); // Imprime un mensaje
    .look_at(Position); // Dirige la mirada hacia la posición del enemigo
    .goto(Position); // Se mueve hacia la posición del enemigo
    +persecucion(ID). // Agrega el hecho de 'persecucion' con el ID del enemigo como parámetro
  
// Si el enemigo que divisamos es nuestro objetivo de persecución, nos dirigimos hacia él.
+!persecucion(I): enemies_in_fov(ID,Type,Angle,Distance,Health,Position) & ID == I
  <-
    .print("[SOLDADO]: Lo veooo!! Esta en : ", Position); // Imprime mensaje
    .look_at(Position); // Dirige la mirada hacia la posición del enemigo
    +persecucion(ID); // Agrega el hecho de 'persecucion' con el ID del enemigo como parámetro
    .goto(Position). // Se mueve hacia la posición del enemigo

// En caso de avistar a más de 4 enemigos y ninguno de ellos sea nuestro objetivo de persecución, 
//nos concentramos en identificar a uno nuevo.
+!persecucion(I): enemies_in_fov(ID,Type,Angle,Distance,Health,Position) & not(ID == I)
  <-
    ?auxiliar(X); // Se recupera el valor actual de la variable 'auxiliar' y se almacena en X
    -+auxiliar(X+1); // Se incrementa el valor de 'auxiliar' en 1
    if (X < 5){ // Si X es menor a 5 (es decir, si aún no hemos visto a más de 4 enemigos)
      !!persecucion(I); // Se vuelve a activar la regla de 'persecucion' con el mismo ID
    };
    if (auxiliar == 5){ // Si 'auxiliar' es igual a 5 (hemos visto a más de 4 enemigos)
      .print("[SOLDADO]: Cambio de objetivo!"); // Imprime un mensaje indicando que se cambió de objetivo
      -+auxiliar(0); // Reinicia el valor de 'auxiliar' a 0
      +persecucion(ID); // Agrega el hecho de 'persecucion' con el ID del enemigo actual como parámetro
    }.

// En caso de eliminar al portador de la bandera y no avistar a nadie más, regresa al punto de origen.
+!persecucion(I): not(enemies_in_fov(ID,Type,Angle,Distance,Health,Position))
  <-
    .banderaVista(Pos); // Se recupera la posición de la bandera y se almacena en 'Pos'
    .length(Pos, L); // Se obtiene la longitud de 'Pos' y se almacena en 'L'
    if (not(L == 0)){ // Si la longitud de 'Pos' no es igual a 0 (es decir, si se ha visto la bandera)
      .goto(Pos); // El agente se mueve hacia la posición de la bandera
      +bandera; // Se agrega el hecho de 'bandera'
    };
    ?origin(Base); // Se recupera la posición de origen y se almacena en 'Base'
    .goto(Base); // El agente se mueve hacia la posición de origen ('Base')
    .print("[SOLDADO]: Recuperamos la bandera!!!! :D"); // Se imprime un mensaje indicando que se ha recuperado la bandera
    +volviendo. // Se agrega el hecho de 'volviendo'



// Si alcanzamos nuestro objetivo y estábamos buscando la bandera, regresamos al punto de origen y 
//notificamos al capitán. Si solo estábamos buscando, simplemente regresamos al origen.
+target_reached(T): bandera | buscando
  <-
    if (bandera){ // Si se estaba buscando la bandera
      .print("[SOLDADO]: Tenemos la bandera! :D"); // Imprime un mensaje indicando que se ha recuperado la bandera
      .wait(1000); // Espera por 1000 unidades de tiempo
      -bandera; // Elimina el hecho de 'bandera'
      .get_service("comandante"); // Accede al servicio "comandante"
    };
    if (buscando){ // Si se estaba buscando solamente
      -buscando; // Elimina el hecho de 'buscando'
    };
    ?origin(Origen); // Recupera la posición de origen y la almacena en 'G'
    .goto(Origen); // Se mueve hacia la posición de origen
    +formacion; // Agrega el hecho de 'formacion'
    -target_reached(T). // Elimina el hecho de 'target_reached' con el parámetro 'T'
//############################################### PAQUETES #################################################
//recoge healthpack
+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): TYPE == 1001 & health(X) & X < 90 & not(aPorPaquetes)
  <-
    +aPorPaquetes; // Agrega el hecho de 'aPorPaquetes'
    .print("[SOLDADO]: Voy a curarme!"); // Imprime un mensaje indicando que el soldado va a curarse
    .goto([X,Y,Z]). // El agente se mueve hacia la posición del healthpack

//recoge ammo
+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): TYPE == 1002 & ammo(X) & X < 75 & not(aPorPaquetes)
  <-
    +aPorPaquetes; // Agrega el hecho de 'aPorPaquetes'
    .print("[SOLDADO]: Voy a por munición!"); // Imprime un mensaje indicando que el soldado va a recoger munición
    .goto([X,Y,Z]). // El agente se mueve hacia la posición del paquete de munición

// Explora en busca de los paquetes que dejan los fieldops y el médico.
+buscaPaquetes[source(A)]
  <-
    +buscando; // Agrega el hecho de 'buscando'
    ?flag(F); // Recupera el hecho de 'flag(F)' y lo almacena en 'F'
    .look_at(F). // El agente mira hacia la posición de la bandera

//############################################ SOLICITAR CURAS ##########################################
// Si tu nivel de vida es bajo y no has recibido ninguna herida previa, solicita la asistencia de un médico.
+health(X): X < 75 & not(herido)
  <-
    +herido; // Agrega el hecho de 'herido'
    .print("[SOLDADO]: Me han dado!!! Medicoooo! :=0"); // Imprime un mensaje
    .get_medics. // Solicita a los médicos para recibir asistencia

// Ha sido sanado y ya no esta herido
+health(X): X >= 75 & herido
  <-
  -herido.// Elimina el hecho de 'herido'

// Recopilamos la lista de médicos disponibles,  enviarán sus propuestas, 
//y se seleccionará al mejor candidato.
+myMedics(M): herido & not(eliminar(_))
  <-
    .print("[SOLDADO]: Medicooooooo ayudaaaaaaa!!!!!"); // Imprime un mensaje
    ?position(Pos); // Recupera la posición actual del agente y la almacena en 'Pos'
    +propuestas([]); // Agrega el hecho de 'propuestas' con una lista vacía: propuestas realizadas por los médicos
    +medicosDisponibles([]); // Agrega el hecho de 'medicosDisponibles' con una lista vacía: lista de médicos disponibles
    .send(M, tell, curacionSolicitada(Pos)); // Envía un mensaje 'tell' a un médico específico (M) con la curación solicitada y la posición del agente
    .wait(2000); // Espera 2 segundos para que los médicos envíen sus propuestas
    !!elegirMedico; // Dispara una acción 'elegirMedico' para seleccionar al mejor médico
    -myMedics(_). // Elimina el hecho de 'myMedics'

// Elaboramos un plan para solicitar ayuda nuevamente en caso de que haya algún médico que siga con vida.
+myMedics(F): eliminar(L)
  <-
    -eliminar; // Elimina el hecho de 'eliminar' ._.
    -myMedics(_); // Elimina el hecho de 'myMedics'
    .length(F, LongitudF); // Calcula la longitud de la lista 'F' y almacena el resultado en 'LongitudF'
    if (L == 0 & not(LongitudF == 0)) { // Si la variable 'L' es igual a 0 y 'Lf' no es igual a 0
      -herido; // Elimina el hecho de 'herido', indicando que el agente ya no está herido
    }.
// Selecciona al médico más cercano y acepta su propuesta, mientras que envía cancelaciones al resto de los médicos.
+!elegirMedico: propuestas(Bi) & medicosDisponibles(Ai)
  <-
    .length(Ai, L1); // Calcula la longitud de la lista 'Ai' y almacena el resultado en 'L1'
    .length(Bi, L2); // Calcula la longitud de la lista 'Bi' y almacena el resultado en 'L2'
    if (L1 > 0 & L2 > 0 & L2 == L1) { // Si 'L' es mayor que 0, 'L2' es mayor que 0 y 'L2' es igual a 'L1'
      .print("[SOLDADO]: Selecciono el mejor: ", Bi, Ai); // Imprime un mensaje indicando que se selecciona al mejor médico
      .posicionCercana(Bi, Indice); // Calcula la posición más cercana en la lista 'Bi' y almacena el índice en 'Indice'
      .nth(Indice, Ai, A); // Obtiene el médico correspondiente al índice 'Indice' en la lista 'Ai' y almacena el resultado en 'A'
      .send(A, tell, aceptarPropuesta); // Envía un mensaje a 'A' para aceptar la propuesta
      .delete(Indice, Ai, Ag1); // Elimina el médico correspondiente al índice 'Indice' en la lista 'Ai' y almacena el resultado en 'Ag1'
      .send(Ag1, tell, cancelarPropuesta); // Envía un mensaje a 'Ag1' para cancelar la propuesta
    }
    -propuestas(Bi); // Elimina el hecho de 'propuestas'
    +propuestas([]); // Agrega el hecho de 'propuestas' con una lista vacía
    -medicosDisponibles(Ai); // Elimina el hecho de 'medicosDisponibles'
    +medicosDisponibles([]); // Agrega el hecho de 'medicosDisponibles' con una lista vacía
    .get_medics; // Solicita obtener la lista de médicos disponibles
    +eliminar(L1). // Agrega el hecho de 'eliminar' con el valor 'L'

// Al recibir una propuesta de un médico, se registra la distancia y su identificación (ID).
+medicBid(D)[source(A)]: herido
  <-
    ?propuestas(B); // Se verifica si existe el hecho de 'propuestas' y se almacena su valor en 'B'
    .concat(B, [D], B1); // Se concatena 'D' a la lista 'B' (propuestas) y se almacena el resultado en 'B1'
    -propuestas(B); // Se elimina el hecho de 'propuestas' con la lista original 'B'
    +propuestas(B1); // Se agrega el hecho de 'propuestas' con la lista actualizada 'B1'
    ?medicosDisponibles(Ag); // Se verifica si existe el hecho de 'medicosDisponibles' y se almacena su valor en 'Ag'
    .concat(Ag, [A], Ag1); // Se concatena 'A' a la lista 'Ag' y se almacena el resultado en 'Ag1'
    -medicosDisponibles(A); // Se elimina el hecho de 'medicosDisponibles' con la lista original 'A'
    +medicosDisponibles(Ag1); // Se agrega el hecho de 'medicosDisponibles' con la lista actualizada 'Ag1'
    -medicBid(D). // Se elimina el hecho de 'medicBid' con 'D' como argumento

// Si alcanzamos el objetivo y estábamos buscando un paquete, regresamos a la formación.
+target_reached(T): aPorPaquetes
  <- // La regla se dispara cuando se tiene el hecho de 'target_reached' con 'T' como argumento y el hecho de 'aPorPaquetes'
    -aPorPaquetes; // Se elimina el hecho de 'aPorPaquetes'
    -target_reached(T); // Se elimina el hecho de 'target_reached' con 'T' como argumento
    +formacion; // Se agrega el hecho de 'formacion'
    ?origin(Pos); // Se verifica si existe el hecho de 'origin' y se almacena su valor en 'Pos'
    .goto(Pos). // Va hacia la posición almacenada en 'Pos'
//######################################## SOLICITAR MUNICION #############################################
// Si nuestra munición disminuye, solicitamos la asistencia de un fieldop.
+ammo(X): X < 60 & not(sin_municion)
  <-
    +sin_municion; // Se agrega el hecho de 'sin_municion' para indicar que se está sin munición
    .print("[SOLDADO]: Sin municion!!!!!!!!!"); // Se imprime un mensaje indicando que el agente está sin munición
    .get_fieldops. // Se solicita la ayuda de un fieldop para obtener munición

// Si contamos con suficiente munición, descartamos esa creencia.
+ammo(X): X >= 60 & sin_municion
  <-
    -sin_municion.

// Si disponemos de la lista de fieldops y necesitamos munición, solicitamos ayuda y seleccionamos al fieldop más cercano.
+myFieldops(F): sin_municion & not(eliminar(_,_))
  <-
    .print("[SOLDADO]: Solicito municion!!!!!"); // Se imprime un mensaje indicando que el agente va a solicitar ayuda
    ?position(Pos); // Se verifica si existe el hecho de 'position' y se almacena su valor en 'Pos'
    +propuestaFieldops([]); // Se agrega el hecho de 'propuestaFieldops' con una lista vacía para almacenar las propuestas de los fieldops
    +fieldopsDisponibles([]); // Se agrega el hecho de 'fieldopsDisponibles' con una lista vacía para almacenar los identificadores de los fieldops
    .send(F, tell, municionplease(Pos)); // Se envía un mensaje al fieldop 'F' solicitando ayuda para obtener munición en la posición 'Pos'
    .wait(2000); // Se espera un tiempo de 2000 milisegundos para permitir que los fieldops respondan
    !!elegirField. // Se ejecuta el plan 'elegirField' para seleccionar al fieldop más cercano y aceptar su propuesta

//Plan para solicitar ayuda nuevamente en caso de que haya algún agente de campo que siga con vida.
+myFieldops(F): eliminar(L)
  <-
    -eliminar; // Se elimina el hecho de 'eliminar'
    -myFieldops(_); // Se elimina el hecho de 'myFieldops' con cualquier argumento
    .length(F,LongitudF); // Se calcula la longitud de la lista 'F' y se almacena en 'LongitudF'
    if(L == 0 & not(LongitudF == 0)){ // Si 'L' es igual a 0 y 'LongitudF' no es igual a 0
      -sin_municion; // Se elimina el hecho de 'sin_municion'
    }.

// Seleccionamos al fieldop más cercano y cancelamos las solicitudes del resto
+!elegirField: propuestaFieldops(Bi) & fieldopsDisponibles(Ai)
  <-
    .print("[SOLDADO]: El fieldops mas cercano: ", Bi, Ai);
    .length(Ai,L1); // Calcula la longitud de la lista de agentes 'Ai' y almacena el resultado en 'L1'
    .length(Bi,L2); // Calcula la longitud de la lista 'Bi' y almacena el resultado en 'L2'
    if(L1 > 0 & L2 > 0){ // Si 'L1' es mayor que 0 y 'L2' es mayor que 0
      .posicionCercana(Bi, Indice); // Calcula la posición más cercana en la lista 'Bi' y almacena el índice en 'Indice'
      .nth(Indice, Ai, A); // Obtiene el agente de campo correspondiente al índice 'Indice' en la lista 'Ai' y lo almacena en 'A'
      .send(A, tell, aceptarPropuesta); // Envía un mensaje al agente de campo seleccionado para aceptar la propuesta
      .delete(Indice, Ai, Ag1); // Elimina el agente de campo seleccionado de la lista 'Ai' y almacena la nueva lista en 'Ag1'
      .send(Ag1, tell, cancelarPropuesta); // Envía un mensaje a los agentes de campo restantes en la lista 'Ag1' para cancelar sus propuestas
    };

    -propuestaFieldops(_); // Elimina el hecho de 'propuestaFieldops' con cualquier argumento
    +propuestaFieldops([]); // Agrega el hecho de 'propuestaFieldops' con una lista vacía como argumento
    -fieldopsDisponibles([]); // Elimina el hecho de 'fieldopsDisponibles' con una lista vacía como argumento
    +fieldopsDisponibles([]); // Agrega el hecho de 'fieldopsDisponibles' con una lista vacía como argumento
    .get_fieldops; // Solicita obtener la lista de agentes de campo disponibles
    +eliminar(L1). // Agrega el hecho de 'eliminar' con 'L' como argumento para indicar que se ha eliminado un agente de campo de la lista
 
// Al recibir una propuesta de un fieldop, activamos un plan donde guardamos la distancia y el nombre del fieldop.
+munBid(D)[source(A)]: sin_municion
  <-
    ?propuestaFieldops(B); // Consulta el hecho 'propuestaFieldops' y almacena su valor en 'B'
    .concat(B, [D], B1); // Concatena el valor 'D' a la lista 'B' y almacena el resultado en 'B1'
    -propuestaFieldops(_); // Elimina el hecho 'propuestaFieldops' con cualquier argumento
    +propuestaFieldops(B1); // Agrega el hecho 'propuestaFieldops' con la lista actualizada 'B1' como argumento
    ?fieldopsDisponibles(Ag); // Consulta el hecho 'fieldopsDisponibles' y almacena su valor en 'Ag'
    .concat(Ag, [A], Ag1); // Concatena el valor 'A' a la lista 'Ag' y almacena el resultado en 'Ag1'
    -fieldopsDisponibles(_); // Elimina el hecho 'fieldopsDisponibles' con cualquier argumento
    +fieldopsDisponibles(Ag1); // Agrega el hecho 'fieldopsDisponibles' con la lista actualizada 'Ag1' como argumento
    -munBid(D). // Elimina el hecho '+munBid' con 'D' como argumento

//############################################# REFUERZOS #################################################
// Si avistamos a algún enemigo y aún no hemos solicitado refuerzos, pedimos refuerzos inmediatamente.
+enemies_in_fov(ID,Type,Angle,Distance,Health,Position): ayudaSolicitada(A) & (A == 0)
  <-
    ?ayudaSolicitada(K); // Consulta el hecho 'ayudaSolicitada' y almacena su valor en 'K' (1 si true 0 si false)
    -ayudaSolicitada(_); // Elimina el hecho 'ayudaSolicitada' con cualquier argumento
    +ayudaSolicitada(1); // Agrega el hecho 'ayudaSolicitada' con el valor 1 como argumento
    if (K==0){ // Si el valor anterior de 'ayudaSolicitada' era 0
      .print("[SOLDADO]: Ayuda soldados! Enemigo a la vista"); // Imprime un mensaje indicando que se necesita ayuda porque se ha avistado a un enemigo
      +posEnem(Position); // Agrega el hecho 'posEnem' con la posición del enemigo como argumento
      .get_backups; // Envía una solicitud para obtener refuerzos
    }.

// Si hemos solicitado ayuda pero no tenemos a nadie delante, permitimos realizar una nueva solicitud de ayuda.
+ayudaSolicitada(A): A == 1 & not (enemies_in_fov(ID,Type,Angle,Distance,Health,Position))
  <-
    -ayudaSolicitada(_); // Eliminamos el hecho anterior de "ayudaSolicitada"
    +ayudaSolicitada(0); // Permitimos realizar una nueva solicitud de ayuda estableciendo "ayudaSolicitada" a 0
    -myBackups(_). // Limpiamos cualquier información previa sobre los refuerzos solicitados

// Si tenemos la lista de soldados y hemos pedido ayuda, solicitamos a sus agentes que nos proporcionen su posición y elegimos al mejor candidato.
+myBackups(B): ayudaSolicitada(A) & (A == 1)
  <-
    ?position(Pos); // Obtenemos nuestra posición actual
    +ofertasSoldados([]); // Inicializamos una lista vacía para almacenar las ofertas de ayuda
    +agentesSoldados([]); // Inicializamos una lista vacía para almacenar los agentes que ofrecen ayuda
    .send(B,tell,ayudaEnPos(Pos)); // Enviamos un mensaje a los agentes de los soldados solicitando su posición actual
    .wait(2000); // Esperamos un tiempo para que los agentes respondan
    !elegirMejor; // Ejecutamos el plan "elegirMejor" para seleccionar la mejor oferta de ayuda
    -myBackups(_). // Limpiamos los hechos relacionados con los refuerzos solicitados

// Elaboramos un plan para solicitar ayuda nuevamente en caso de que quede algún soldado con vida.
+myBackups(B): pidiendo_ayuda(L)
  <-
    -myBackups(_); // Limpiamos los hechos relacionados con los refuerzos solicitados
    -pidiendo_ayuda(_); // Limpiamos el hecho de estar solicitando ayuda
    .length(B,Lb); // Obtenemos la longitud de la lista de soldados disponibles
    if(L == 0 & not(Lb==0)){ // Si no hay soldados disponibles y aún quedan soldados vivos en la lista
      -ayudaSolicitada(_); // Limpiamos el hecho de haber solicitado ayuda
      +ayudaSolicitada(0); // Establecemos el hecho de no haber solicitado ayuda
    }.

// Seleccionamos al agente que se encuentre más cerca.
+!elegirMejor: ofertasSoldados(Bi) & agentesSoldados (Ag)
  <-
    .length(Ag,L1); // Obtenemos la longitud de la lista de agentes disponibles
    .length(Bi,L2); // Obtenemos la longitud de la lista de ofertas de ayuda
    if (L1 > 0 & L2 > 0 & L1 == L2){ // Si hay agentes y ofertas de ayuda disponibles y tienen la misma cantidad
      .posicionCercana(Bi,Ind); // Obtenemos el índice de la posición más cercana
      .nth(Ind,Ag,Agen); // Obtenemos el agente correspondiente a ese índice
      .print("[SOLDADO]: Ayudame, estas mas cerca! -> ", Agen); // Imprimimos un mensaje indicando al agente seleccionado
      ?posEnem(Pos); // Obtenemos la posición del enemigo
      -posEnem(_); // Limpiamos el hecho de la posición del enemigo
      .send(Agen,tell,aceptarPropuesta(Pos)); // Enviamos un mensaje al agente seleccionado aceptando su propuesta y proporcionando la posición del enemigo
      .delete(Ind,Ag,Oth); // Eliminamos al agente seleccionado de la lista de agentes y obtenemos el resto de agentes
      .send(Oth,tell,cancelarPropuesta); // Enviamos un mensaje de cancelación al resto de agentes
    };
    -ayudaSolicitada(_); // Limpiamos el hecho de haber solicitado ayuda
    +ayudaSolicitada(0); // Establecemos el hecho de no haber solicitado ayuda
    -ofertasSoldados(_); // Limpiamos las ofertas de ayuda
    +ofertasSoldados([]); // Establecemos una lista vacía de ofertas de ayuda
    -agentesSoldados(_); // Limpiamos la lista de agentes disponibles
    +agentesSoldados([]); // Establecemos una lista vacía de agentes disponibles
    .get_backups; // Obtenemos los refuerzos disponibles
    +pidiendo_ayuda(L1). // Establecemos el hecho de estar solicitando ayuda y proporcionamos la cantidad de agentes disponibles

// Si recibimos una solicitud de ayuda, solo respondemos si no avistamos a ningún enemigo y no estamos dando ayuda a alguien en ese momento.
+ayudaEnPos(Pos2)[source(A)]: not(enemies_in_fov(ID,Type,Angle,Distance,Health,Position)) & not(ayudando(X,Z))
  <-
    ?position(Pos); // Consultar la posición actual del soldado
    if (not (Pos == Pos2)){ // Comprobar si la posición actual es diferente a la posición solicitada de ayuda
      .distancia(Pos,Pos2,D); // Calcular la distancia entre las posiciones
      .send(A,tell,my_dist(D)); // Enviar un mensaje al agente solicitante con la distancia del soldado a la posición solicitada
      +ayudando(A,Pos2); // Registrar que el soldado está ayudando en esa posición
    }.

// Al recibir una propuesta de un soldado, activamos un plan en el que guardamos la distancia y el nombre del soldado.
+my_dist(D)[source(S)]
  <-
    ?agentesSoldados(A); // Obtener la lista actual de agentes soldados
    .concat(A,[S],A2); // Agregar el agente de soldado actual a la lista
    -agentesSoldados(A); // Eliminar la lista anterior de agentes soldados
    +agentesSoldados(A2); // Guardar la nueva lista de agentes soldados
    ?ofertasSoldados(B); // Obtener la lista actual de ofertas de soldados
    .concat(B,[D],B2); // Agregar la distancia actual a la lista
    -ofertasSoldados(B); // Eliminar la lista anterior de ofertas de soldados
    +ofertasSoldados(B2). // Guardar la nueva lista de ofertas de soldados

// Activamos el plan cuando un agente confirma nuestra ayuda.
+aceptarPropuesta(EP)[source(S)]
  <-
    ?ayudando(A2,Pos); // Obtener la información del agente que estamos ayudando y su posición
    .print("[SOLDADO]: Ayuda en caminooo!!!!"); // Imprimir mensaje de confirmación
    ?flag(F); // Obtener la posición de la bandera
    .puntoOptimo(F,Pos,EP,Punto); // Calcular el punto óptimo para dirigirse
    +enemyPos(EP); // Guardar la posición del enemigo
    .goto(Punto). // Ir al punto óptimo de ayuda

// Activamos el plan cuando un agente cancela nuestra ayuda.
+cancelarPropuesta[source(A)]: ayudando(A,Pos)
  <-
    -ayudando(A,Pos).

// Si hemos alcanzado el objetivo y estábamos ayudando a alguien, pero avistamos a un enemigo, nos enfocamos en él.
+target_reached(T): ayudando(A,B) & enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
  -enemyPos(_); // Eliminamos la posición del enemigo anterior
  -target_reached(T); // Eliminamos el hecho de haber llegado al objetivo
  .look_at(Position); // Miramos hacia la posición del enemigo
  .print("[SOLDADO]: Acabemos con él, camarada!!!!! -.-");
  -ayudando(_, _). // Dejamos de ayudar a alguien

// Si hemos llegado al objetivo y avistamos al enemigo, nos enfocamos en él. En caso de que no haya nadie más, regresamos a nuestro punto de origen.
+target_reached(T): ayudando(A,B)
  <-
  ?enemyPos(P); // Comprobamos si hay una posición de enemigo disponible
  -enemyPos(_); // Eliminamos la posición de enemigo anterior
  -target_reached(T); // Eliminamos el hecho de haber llegado al objetivo
  .look_at(P); // Miramos hacia la posición del enemigo
  if(not (enemies_in_fov(_,_,_,_,_,_))){
    ?origin(G); // Obtenemos nuestra posición inicial
    .goto(G); // Vamos de vuelta a nuestra posición inicial
    +formacion; // Activamos la formación
    .print("[SOLDADO]: Enemigo neutralizado! Volviendo a mi punto. ");
  };
  -ayudando(_, _). // Dejamos de ayudar a alguien
//############################################### FORMACION ########################################################
+irA(G)[source(A)]
  <-
    +origin(G); // Establecemos el objetivo de ir a la posición G
    +formacion; // Activamos la formación
    .goto(G). // Nos dirigimos hacia la posición G

//Si llegamos al objetivo y estamo haciendo la formación
+target_reached(T): formacion
  <-
    -formacion; // Desactivamos la formación
    -target_reached(T);
    ?flag(F);
    ?position(Pos);
    .mirarOpuesto(Pos,F,Punto); // Calculamos el punto opuesto a la posición actual con respecto a la bandera
    .look_at(Punto). // Giramos hacia el punto opuesto

//################################################## DISPARAR A ENEMIGOS ##################################
// Si avistamos a un enemigo que no pertenece a nuestro equipo, abrimos fuego y nos concentramos en uno de los enemigos que visualizamos.
+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <- 
  ?position(Pos);
  .fuegoAmigo(Pos,Position, X);
  if(not(X)){ // Verificamos si el enemigo no es de nuestro equipo
    ?enemigosVistos(E); // Obtenemos la cantidad de enemigos vistos anteriormente
    ?siguiendo(F); // Obtenemos el ID del enemigo al que estamos siguiendo

    if (F==0 | F==ID | E > 5){ // Si no estamos siguiendo a nadie o el ID coincide o hemos visto muchos enemigos
      -+siguiendo(ID); // Establecemos el ID del enemigo actual como el objetivo a seguir
      .look_at(Position); // Giramos hacia el enemigo
      -+enemigosVistos(0); // Reiniciamos el contador de enemigos vistos
    };

    -+enemigosVistos(E+1); // Incrementamos el contador de enemigos vistos
    .shoot(5,Position); // Disparamos al enemigo
  }.