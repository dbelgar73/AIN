+flag (F): team(200)
  <-
  .print("[SOLDADO]: Defended la banderaaa >:@ !");  // Imprimir un mensaje indicando que están defendiendo
  .wait(3000);
  // Obtener el servicio "comandante"
  .get_service("comandante");
  .print("[SOLDADO]: Esperando ordenes!");
  .wait(1500);
  +bucle.  // Marcar la creencia "bucle" como verdadera

//######################################################ORGANIZAR DEFENSA##########################################
  // Manda un mensaje al comandante para registrarse en su lista
+comandante(C): team(200) 
  <-
  +comandante0(C);  // Se agrega el identificador del agente como comandante0
  +irAlCentro;
  .send(C, tell, registrar).  // Se envía un mensaje al comandante para registrarse

// Desplazar los agentes a "campear" la bandera
+irA(Punto)[source(S)]: team(200)
  <-
  -irAlCentro;
  .goto(Punto);  // Se mueve hacia el punto especificado
  +punto;  // Se marca que ha llegado al punto
  .print("[SOLDADO]: A sus ordenes, voy a las coordenadas ", Punto, "!").  // Se muestra un mensaje

+irAlCentro
  <-
    .goto([124,0,124]);
    +bucleComprobar.

// Agente torreta dará vueltas en su posición esperando detectar a un enemigo, antes de cambiar de modo y atacarlo
+target_reached(F): punto 
  <-
  -punto;  // Se desmarca el punto
  -+bucleComprobar.

+bucleComprobar
  <-
    +comprobar;
    -bucleComprobar.

// Método usado en la práctica para dar vueltas sobre el eje del agente en búsqueda de un enemigo, al cual se puede detectar con tiempo suficiente
+comprobar: team(200) & position([X,Y,Z])
  <-
  /*.print("Vuelta de reconocimiento");*/
  .look_at([X+1,Y,Z]);
  .wait(400);
  .look_at([X-1,Y,Z]);
  .wait(400);
  .look_at([X,Y,Z+1]);
  .wait(400);
  .look_at([X,Y,Z-1]);
  .wait(400);
  -comprobar;
  +bucleComprobar.
//###########################################################PATRULLAR#######################################################
// Los agentes que no son torreta patrullan alrededor dando vueltas aleatoriamente
+target_reached(T): team(200) & alCentro & not laTorre & not batalla
  <-
  -alCentro;  // Se desmarca alCentro
  !apatrullar.  // Se cambia al modo de patrullar comandante moverA

+!apatrullar: team(200) & flag(F) & position(P) & not batalla
  <-
  -batalla;  // Se desactiva el modo guerra
  .goto([0,0,0]);  // Se mueve hacia el centro
  .print("[SOLDADO]: Voy al centro ", D).  // Se muestra un mensaje indicando la posición de patrulla

// Cuando está en modo guerra y llega a su objetivo, da una vuelta de 360 grados con la intención de encontrar al enemigo
// y seguir disparándole, o encontrar un nuevo enemigo
+target_reached(T): team(200) & batalla
  <-
  -amenaza(_);  // Se desactiva cualquier amenaza anterior
  -eliminar;  // Se desactiva el modo eliminar
  +comprobar;  // Se marca para realizar la comprobación de enemigos
  .print("[SOLDADO]: Refuerzos en camino!").  // Se muestra un mensaje de fin


// Patrulla mientras no vea un objetivo dando vueltas de 360 grados sobre su eje mientras no vea un objetivo, en cual caso estaría en batalla
+!apatrullandoLaCiudad: team(200) & not batalla
  <-
  +comprobar;  // Se marca para realizar la comprobación de enemigos
  .wait(2100);  // Se espera un tiempo
  !apatrullandoLaCiudad.  // Se continúa en el modo de patrullar la ciudad

+!apatrullandoLaCiudad: team(200) & batalla
  <-
  .print("[SOLDADO]: Apatrullando la ciudad  F").  // Se muestra un mensaje indicando que se está patrullando la ciudad

//##################################################################BATALLA############################################################
// Primer contacto con un enemigo:
// - Se activa el modo guerra (batalla)
// - Se manda al fieldop al centro
// - Se da una vuelta alrededor para llamar a agentes compañeros para que asistan a ayudar
+enemies_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): team(200) & not batalla & comandante0(C)
  <-
  +batalla;  // Se activa el modo guerra
  -+checking;  // Se marca para realizar comprobaciones
  .goto([X,Y,Z]);  // Se mueve hacia la posición del enemigo
  -+tg(ID);  // Se marca al enemigo como objetivo
  .look_at([X,Y,Z]);  // Se mira hacia el enemigo
  .shoot(5,[X,Y,Z]);  // Se dispara al enemigo
  +comprobar;  // Se marca para realizar la comprobación de enemigos
  .send(C, tell, veteAlCentro([X,Y,Z]));  // Se envía un mensaje al fieldop para ir al centro
  .print("[SOLDADO]: Entrando en combate!").  // Se muestra un mensaje indicando que se está entrando en combate


// Si no va al centro por munición o vida, seguirá disparándole al objetivo y equilibrando su visión al objetivo
+enemies_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): team(200) & batalla & not gallina 
  <-
  -+estadoAlerta(0);  // Se desactiva el estado de alerta
  -+objetivo([X,Y,Z]);  // Se marca el enemigo como objetivo
  .look_at([X,Y,Z]);  // Se ajusta la visión hacia el enemigo
  .goto([X,Y,Z]);  // Se mueve hacia la posición del enemigo
  .shoot(1, [X,Y,Z]).  // Se dispara al enemigo

// Se calcula la distancia con el objetivo, y en caso de que esté cerca, se le dispararán más veces.
// Este método está separado del anterior debido a posibles problemas de concurrencia al llamar la posición.
+enemies_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): team(200) & batalla & position(P)
  <-
  .distance([X,Y,Z], P, D);  // Se calcula la distancia entre el agente y el objetivo
  if(D > 30){
    /*.goto([X,Y,Z]);*/
    .look_at([X,Y,Z]);  // Se ajusta la visión hacia el enemigo
  };
  if(D < 20){
    .print("[SOLDADO]: Esta aqui!");  // Se muestra un mensaje indicando que el enemigo está cerca
    .look_at([X,Y,Z]);  // Se ajusta la visión hacia el enemigo
    .shoot(5, [X,Y,Z]);  // Se dispara varias veces al enemigo
  }.

//#########################################################COMPROBAR MUNICION Y VIDA################################################################################
// Bucle para comprobar en caso del modo guerra la vida y la munición para saber si hay que ir a por ella o no.
// Si la creencia principal "check" no se activa debido a problemas en la llamada a position, health o ammo, se utiliza la creencia auxiliar "bucle" como bucle de repetición.
+check: team(200) & batalla & ammo(A) & health(H) & not gallina & position(P) & objetivo(O)
  <-
  /*.wait(3000);*/
  -check;
  .look_at(O);  // Ajusta la visión hacia el objetivo
  .goto(O);  // Se mueve hacia el objetivo
  if(H < 40 | A < 20){  // Verifica si la vida o la munición son bajas
    +gallina;  // Se activa la creencia "gallina" para indicar que el agente está huyendo
    +reuniendose;  // Se activa la creencia "reuniendose" para indicar que el agente está buscando ayuda
    .print("[SOLDADO]: Saliendo por patas...");  // Muestra un mensaje indicando que el agente está huyendo
    ?flag(F);  // Obtiene la posición de la bandera
    .goto(F);  // Se mueve hacia la posición de la bandera
    .send(C, tell, help(P));  // Envía un mensaje al comandante moverA solicitando ayuda
  }.

+bucle
  <- 
  -+check;  // Desactiva la creencia "check"
  .wait(3000);  // Espera un tiempo
  -+bucle.  // Activa la creencia "bucle" para repetir el bucle

// Debugger utilizado para gestionar situaciones en las que no hay amenaza o el agente se queda bloqueado.
// Utiliza el contador "estadoAlerta" que se resetea cada vez que se detecta algo. Si el contador no se resetea,
// el agente se dirige al centro y luego intenta patrullar. Si tiene éxito, seguirá patrullando.
+checking: team(200) & estadoAlerta(E) & batalla
  <- 
  .wait(2000);  // Espera un tiempo antes de realizar la comprobación
  -+estadoAlerta(E + 1);  // Incrementa el contador "estadoAlerta"
  if (E > 3) {  // Si el contador supera un umbral determinado
    -+estadoAlerta(0);  // Resetea el contador "estadoAlerta"
    -amenaza;  // Desactiva la creencia de "amenaza"
    ?flag(F);  // Obtiene la posición de la bandera
    .goto(F);  // Se mueve hacia la posición de la bandera
    !apatrullar;  // Activa la creencia de "apatrullar" para iniciar la patrulla
    +comprobar;  // Activa la creencia de "comprobar" para realizar la comprobación
  } 
  -+checking.  // Desactiva la creencia "checking"

//###################################################ENTREGAS DE MUNICION##############################################################
// El Fieldop propone el punto de reunión para entregar los paquetes de munición.
// Si el agente no recibe la propuesta de reunión, se dirige al centro donde está toda la munición.
// Se activa la creencia "gallina" mientras dura el viaje a por munición para evitar desviarse a otros estímulos.
+reunion(P)[source(S)]: team(200)
  <-
  -+reuniendose;  // Desactiva la creencia "reuniendose"
  +gallina;  // Activa la creencia "gallina"
  .goto(P);  // Se mueve hacia el punto de reunión propuesto por el Fieldop
  .print("[SOLDADO]: OK, voy a la reunión!").  // Muestra un mensaje indicando que el agente se dirige a la reunión

// Una vez que el agente llega al punto de reunión, se dirige a por los paquetes y realiza una vuelta para localizarlos.
+target_reached(T):reuniendose
  <-
  -reuniendose;  // Desactiva la creencia "reuniendose"
  +paquetes;  // Activa la creencia "paquetes" indicando que hay paquetes disponibles
  +comprobar;  // Activa la creencia "comprobar" para realizar la comprobación
  .print("[SOLDADO]: Estoy aquí").  // Muestra un mensaje indicando que el agente ha llegado al punto de reunión

// Cuando el agente detecta un paquete en su campo de visión, se dirige hacia él.
+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): paquetes
  <-
  -paquetes;  // Desactiva la creencia "paquetes"
  +aporpaquete;  // Activa la creencia "aporpaquete" indicando que el agente va a por el paquete
  .goto([X,Y,Z]);  // Se mueve hacia la posición del paquete
  .wait(2000);  // Espera un tiempo para llegar al paquete
  .look_at([X,Y,Z]);  // Mira hacia la posición del paquete
  .print("[SOLDADO]: Vamos por paquete").  // Muestra un mensaje indicando que el agente se dirige hacia el paquete

// Cuando el agente llega al paquete, desactiva el modo gallina, lo que le permite volver a combatir.
// Durante su trayectoria hacia el paquete, es posible que dispare a agentes que estén delante de él
// ya que la creencia de "enemigos en vista" sigue activa.
+target_reached(T): aporpaquete
  <-
  -aporpaquete;  // Desactiva la creencia "aporpaquete"
  -gallina;  // Desactiva la creencia "gallina"
  .print("[SOLDADO]: Paquete cogido");  // Muestra un mensaje indicando que el agente ha cogido el paquete
  +comprobar.  // Activa la creencia "comprobar" para realizar la comprobación

//############################################################PEDIR AYUDA############################################################
// Cuando el agente encuentra a un amigo en su campo de visión mientras está en modo guerra, le pide ayuda.
// Se establece una comunicación entre agentes para prestar apoyo mutuo.
+friends_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]):team(200) & batalla & soldados(SS)
  <-
  .nth(ID, SS, S);  // Obtiene una referencia al agente amigo que se encuentra en el campo de visión
  .send(S, tell, ayudame([X,Y,Z]));  // Envía un mensaje al agente amigo pidiéndole ayuda
  .print("[SOLDADO]: AYUDADME!!").  // Muestra un mensaje indicando que el agente pide ayuda

// Cuando un agente amigo le pide ayuda, este agente se dirige en su ayuda siempre y cuando no esté en modo guerra.
// Si está en modo guerra, ignorará la solicitud de ayuda y dejará que el agente amigo se las arregle por sí mismo.
+ayudame([X,Y,Z])[source(S)]: team(200) & not batalla
  <-
  .look_at([X,Y,Z]);  // Mira hacia la posición del agente amigo que pide ayuda
  .goto([X,Y,Z]);  // Se dirige hacia la posición del agente amigo
  -+batalla;  // Activa el modo guerra para unirse al combate
  .print("[SOLDADO]: VOY!").  // Muestra un mensaje indicando que el agente va en ayuda del agente amigo