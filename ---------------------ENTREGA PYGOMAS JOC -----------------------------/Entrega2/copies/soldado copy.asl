// TEAM_DEFENSOR
// Cuando se detecta la bandera del equipo propio, el equipo defensor realiza las acciones de defensa
+flag (F): team(200)
  <-
  .print("Defended la banderaaa >:@ !");  // Imprimir un mensaje indicando que están defendiendo
  // Obtener respaldos y médicos disponibles
  .get_backups;
  .get_medics;
  // Registrar el servicio "cruzada"
  .register_service("cruzada");
  .wait(5000);
  // Obtener el servicio "coronel"
  .get_service("coronel");
  .wait(1500);
  .print("Hola, soy cruzada!");  // Imprimir un mensaje indicando que se identifican como "cruzada"
  +alCentro;  // Marcar la creencia "alCentro" como verdadera
  +objetivo(F);  // Establecer la creencia "objetivo" con la posición de la bandera
  .goto(F);  // Moverse hacia la posición de la bandera
  +bucle;  // Marcar la creencia "bucle" como verdadera

  // Manodo un mensaje al fieldop para registrarme en su lista
+coronel(C): team(200) 
  <-
  +coronelli(C);  // Se agrega el identificador del agente como coronelli
  .send(C, tell, registrar);  // Se envía un mensaje al fieldop para registrarse

// Movimientos iniciales para agentes torreta
+moverA(Punto)[source(S)]: team(200)
  <-
  .goto(Punto);  // Se mueve hacia el punto especificado
  +punto;  // Se marca que ha llegado al punto
  .print("Entendido, moviéndome al punto ", Punto, "!");  // Se muestra un mensaje

// Agente torreta dará vueltas en su posición esperando detectar a un enemigo, antes de cambiar de modo y atacarlo
+target_reached(F): punto 
  <-
  -punto;  // Se desmarca el punto
  !apatrullandoLaCiudad;  // Se cambia al modo de patrullar la ciudad

// Los agentes que no son torreta patrullan alrededor dando vueltas aleatoriamente
+target_reached(T): team(200) & alCentro & not laTorre & not modoWAR
  <-
  -alCentro;  // Se desmarca alCentro
  !apatrullar;  // Se cambia al modo de patrullar

+!apatrullar: team(200) & flag(F) & position(P) & not modoWAR
  <-
  -modoWAR;  // Se desactiva el modo guerra
  -+seguir;  // Se activa el modo seguir
  .next(P, F, D);  // Se obtiene la siguiente posición de patrulla
  .goto(D);  // Se mueve hacia la posición de patrulla
  .print("Voy a ", D);  // Se muestra un mensaje indicando la posición de patrulla

// Cuando llega a su posición de patrulla, da una vuelta de 360 grados para ver si encuentra a alguien, 
// y si no, continúa con movimientos aleatorios
+target_reached(T): team(200) & seguir & not modoWAR
  <-
  +comprobar;  // Se marca para realizar la comprobación de enemigos
  !apatrullar;  // Se vuelve al modo de patrullar

// Cuando está en modo guerra y llega a su objetivo, da una vuelta de 360 grados con la intención de encontrar al enemigo
// y seguir disparándole, o encontrar un nuevo enemigo
+target_reached(T): team(200) & modoWAR
  <-
  -amenaza(_);  // Se desactiva cualquier amenaza anterior
  -eliminar;  // Se desactiva el modo eliminar
  +comprobar;  // Se marca para realizar la comprobación de enemigos
  .print("FIN");  // Se muestra un mensaje de fin

// Fin patrulla aleatoria

// Patrulla mientras no vea un objetivo dando vueltas de 360 grados sobre su eje mientras no vea un objetivo, en cual caso estaría en modoWAR
+!apatrullandoLaCiudad: team(200) & not modoWAR
  <-
  +comprobar;  // Se marca para realizar la comprobación de enemigos
  .wait(2100);  // Se espera un tiempo
  !apatrullandoLaCiudad;  // Se continúa en el modo de patrullar la ciudad

+!apatrullandoLaCiudad: team(200) & modoWAR
  <-
  .print("Apatrullando la ciudad  F");  // Se muestra un mensaje indicando que se está patrullando la ciudad



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
  ?objetivo(O);
  .look_at(O);
  -comprobar;

//-------------------------------------------------ENEMIGOS Y ATAQUES-------------------------------------------------
// Primer contacto con un enemigo:
// - Se activa el modo guerra (modoWAR)
// - Se manda al fieldop al centro
// - Se da una vuelta alrededor para llamar a agentes compañeros para que asistan a ayudar
+enemies_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): team(200) & not modoWAR & coronelli(C)
  <-
  +modoWAR;  // Se activa el modo guerra
  -+checking;  // Se marca para realizar comprobaciones
  .goto([X,Y,Z]);  // Se mueve hacia la posición del enemigo
  -+tg(ID);  // Se marca al enemigo como objetivo
  .look_at([X,Y,Z]);  // Se mira hacia el enemigo
  .shoot(5,[X,Y,Z]);  // Se dispara al enemigo
  +comprobar;  // Se marca para realizar la comprobación de enemigos
  .send(C, tell, veteAlCentro([X,Y,Z]));  // Se envía un mensaje al fieldop para ir al centro
  .print("Entrando en combate!");  // Se muestra un mensaje indicando que se está entrando en combate

//---------------------------------------------------------------MODO GUERRA--------------------------------------------
// Si no va al centro por munición o vida, seguirá disparándole al objetivo y equilibrando su visión al objetivo
+enemies_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): team(200) & modoWAR & not gallina 
  <-
  -+estadoAlerta(0);  // Se desactiva el estado de alerta
  -+objetivo([X,Y,Z]);  // Se marca el enemigo como objetivo
  .look_at([X,Y,Z]);  // Se ajusta la visión hacia el enemigo
  .goto([X,Y,Z]);  // Se mueve hacia la posición del enemigo
  .shoot(1, [X,Y,Z]);  // Se dispara al enemigo

// Se calcula la distancia con el objetivo, y en caso de que esté cerca, se le dispararán más veces.
// Este método está separado del anterior debido a posibles problemas de concurrencia al llamar la posición.
+enemies_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): team(200) & modoWAR & position(P)
  <-
  .distance([X,Y,Z], P, D);  // Se calcula la distancia entre el agente y el objetivo
  if(D > 30){
    /*.goto([X,Y,Z]);*/
    .look_at([X,Y,Z]);  // Se ajusta la visión hacia el enemigo
  };
  if(D < 20){
    .print("Esta aqui!");  // Se muestra un mensaje indicando que el enemigo está cerca
    .look_at([X,Y,Z]);  // Se ajusta la visión hacia el enemigo
    .shoot(5, [X,Y,Z]);  // Se dispara varias veces al enemigo
  }.

// Bucle para comprobar en caso del modo guerra la vida y la munición para saber si hay que ir a por ella o no.
// Si la creencia principal "check" no se activa debido a problemas en la llamada a position, health o ammo, se utiliza la creencia auxiliar "bucle" como bucle de repetición.
+check: team(200) & modoWAR & ammo(A) & health(H) & not gallina & position(P) & objetivo(O)
  <-
  /*.wait(3000);*/
  -check;
  .look_at(O);  // Ajusta la visión hacia el objetivo
  .goto(O);  // Se mueve hacia el objetivo
  if(H < 40 | A < 20){  // Verifica si la vida o la munición son bajas
    +gallina;  // Se activa la creencia "gallina" para indicar que el agente está huyendo
    +reuniendose;  // Se activa la creencia "reuniendose" para indicar que el agente está buscando ayuda
    .print("Saliendo por patas...");  // Muestra un mensaje indicando que el agente está huyendo
    ?flag(F);  // Obtiene la posición de la bandera
    .goto(F);  // Se mueve hacia la posición de la bandera
    ?coronelli(C);  // Obtiene el identificador del coronel
    .send(C, tell, help(P));  // Envía un mensaje al coronel solicitando ayuda
  }.

+bucle
  <- 
  -+check;  // Desactiva la creencia "check"
  .wait(3000);  // Espera un tiempo
  -+bucle.  // Activa la creencia "bucle" para repetir el bucle

// Debugger utilizado para gestionar situaciones en las que no hay amenaza o el agente se queda bloqueado.
// Utiliza el contador "estadoAlerta" que se resetea cada vez que se detecta algo. Si el contador no se resetea,
// el agente se dirige al centro y luego intenta patrullar. Si tiene éxito, seguirá patrullando.
+checking: team(200) & estadoAlerta(E) & modoWAR
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

// El Fieldop propone el punto de reunión para entregar los paquetes de munición.
// Si el agente no recibe la propuesta de reunión, se dirige al centro donde está toda la munición.
// Se activa la creencia "gallina" mientras dura el viaje a por munición para evitar desviarse a otros estímulos.
+reunion(P)[source(S)]: team(200)
  <-
  -+reuniendose;  // Desactiva la creencia "reuniendose"
  +gallina;  // Activa la creencia "gallina"
  .goto(P);  // Se mueve hacia el punto de reunión propuesto por el Fieldop
  .print("OK, voy a la reunión!");  // Muestra un mensaje indicando que el agente se dirige a la reunión

// Una vez que el agente llega al punto de reunión, se dirige a por los paquetes y realiza una vuelta para localizarlos.
+target_reached(T):reuniendose
  <-
  -reuniendose;  // Desactiva la creencia "reuniendose"
  +paquetes;  // Activa la creencia "paquetes" indicando que hay paquetes disponibles
  +comprobar;  // Activa la creencia "comprobar" para realizar la comprobación
  .print("Estoy aquí");  // Muestra un mensaje indicando que el agente ha llegado al punto de reunión

// Cuando el agente detecta un paquete en su campo de visión, se dirige hacia él.
+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): paquetes
  <-
  -paquetes;  // Desactiva la creencia "paquetes"
  +aporpaquete;  // Activa la creencia "aporpaquete" indicando que el agente va a por el paquete
  .goto([X,Y,Z]);  // Se mueve hacia la posición del paquete
  .wait(2000);  // Espera un tiempo para llegar al paquete
  .look_at([X,Y,Z]);  // Mira hacia la posición del paquete
  .print("Vamos por paquete");  // Muestra un mensaje indicando que el agente se dirige hacia el paquete

// Cuando el agente llega al paquete, desactiva el modo gallina, lo que le permite volver a combatir.
// Durante su trayectoria hacia el paquete, es posible que dispare a agentes que estén delante de él
// ya que la creencia de "enemigos en vista" sigue activa.
+target_reached(T): aporpaquete
  <-
  -aporpaquete;  // Desactiva la creencia "aporpaquete"
  -gallina;  // Desactiva la creencia "gallina"
  .print("Paquete cogido");  // Muestra un mensaje indicando que el agente ha cogido el paquete
  +comprobar;  // Activa la creencia "comprobar" para realizar la comprobación

// Cuando el agente encuentra a un amigo en su campo de visión mientras está en modo guerra, le pide ayuda.
// Se establece una comunicación entre agentes para prestar apoyo mutuo.
+friends_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]):team(200) & modoWAR & soldados(SS)
  <-
  .nth(ID, SS, S);  // Obtiene una referencia al agente amigo que se encuentra en el campo de visión
  .send(S, tell, ayudame([X,Y,Z]));  // Envía un mensaje al agente amigo pidiéndole ayuda
  .print("AYUDADME!!");  // Muestra un mensaje indicando que el agente pide ayuda

// Cuando un agente amigo le pide ayuda, este agente se dirige en su ayuda siempre y cuando no esté en modo guerra.
// Si está en modo guerra, ignorará la solicitud de ayuda y dejará que el agente amigo se las arregle por sí mismo.
+ayudame([X,Y,Z])[source(S)]: team(200) & not modoWAR
  <-
  .look_at([X,Y,Z]);  // Mira hacia la posición del agente amigo que pide ayuda
  .goto([X,Y,Z]);  // Se dirige hacia la posición del agente amigo
  -+modoWAR;  // Activa el modo guerra para unirse al combate
  .print("VOY!");  // Muestra un mensaje indicando que el agente va en ayuda del agente amigo