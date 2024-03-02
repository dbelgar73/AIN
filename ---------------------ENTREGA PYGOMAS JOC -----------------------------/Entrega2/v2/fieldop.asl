//###########################################################TEAM ALLIED############################################
// Inicialización de creencias y variables
soldiers(0).  // Número de soldados inicializado en 0
soldados([]).  // Lista de soldados vacía
i(0).  // Variable de iteración inicializada en 0

+flag(Pos): team(100) 
  <-
    .register_service("comandante");  // Registro del servicio "comandante"
    .print("[COMANDANTE]: A mis ordenes! Coged la bandera! >:@ ");  // Impresión de mensaje
    .look_at(Pos);  // El agente mira hacia la posición de la bandera (F)
    .goto([40,0,40]);
    +organizarTropas.  // Se inicia la organizacion del ataque

// Cuando un agente se conecta, este se registra en la lista de Fieldop para su posterior posible uso
+registrar[source(S)]: team(100) & soldados(SS)
  <-
  -registrar;  // Se elimina la creencia "registrar"
  .print("[COMANDANTE]: Resgistrando al soldado: ", S);
  .concat(SS, [S], ListaSoldados);  // Concatena el agente S al final del arreglo SS y guarda el resultado en L
  -+soldados(ListaSoldados);  // Actualiza la creencia "soldados" con el arreglo ListaSoldados
  //.print("Lista soldados: ", soldados[1]).
  .print("Lista soldados: ", soldados(1)).
  //.print("Lista soldados: ", soldados).
  //.print("Lista soldados: ", soldados([1])).

// MODIFICAR reparte posiciones iniciales entre los agentes registrados
+organizarTropas: team(100) & flag(F) & soldados
  <-
  .get_backups;
	.wait(1000);
	?myBackups(S);
	.length(S,Ls);
  if (Ls==9) {
    .print("Contenido de B:", B);
    .print("[COMANDANTE]: A sus posiciones: ");  // Impresión de mensaje
    +i(1);  // Reinicia el contador "i" a 0
    while (i(I) & I < 9) {  // Bucle mientras el contador "i" sea menor a 4
      .print("fieldop antes.nth");
      .nth(I, B, Sold);  // Obtiene el soldado Sold en la posición I del arreglo B
      .print("fieldop despues.nth");
      .send(Sold, tell, irA([120, 0, 120]));  // Envía un mensaje al soldado Sold para que se mueva a la posición P1
      +i(I+1);  // Aumenta el contador "i" en 1
    }
    -organizarTropas;  // Se elimina la creencia "organizarTropas"
    .wait(20222);
    +coordinarAtaque;  // Se activa la creencia "dejarMuni"
    .print("[COMANDANTE]: Posiciones repartidas...");  // Impresión de mensaje indicando que las posiciones han sido repartidas
  }
  .print("[COMANDANTE]: Estais listos?").

// Se manda un mensaje a los soldados, empieza el ataque
+coordinarAtaque: team(100) & soldados(B) & flag(F)
  <-
    -coordinarAtaque;
    -+i(0);  // Reinicia el contador "i" a 0
    while (i(I) & I < 9) {  // Bucle mientras el contador "i" sea menor a 4
    .nth(I, B, Sold);  // Obtiene el soldado Sold en la posición I del arreglo B
    .send(Sold, tell, atacar);  // Envía un mensaje al soldado Sold para que se mueva a la posición P1
    -+i(I+1);  // Aumenta el contador "i" en 1
  }
  .print("[COMANDANTE]: Atacad!!!!!!!!!!!!").

//###########################################################TEAM AXIS############################################
+flag(Pos): team(200) 
  <-
   !!recarga; 
    .wait(5000);
    .goto(Pos);
    +objetivo(Pos).
  !masmunicion.

+position(Pos):  objetivo(Pos)
  <-
  .reload;
  -objetivo(_);
  !masmunicion.
 
+!recarga
  <-
	.wait(1000);
	!recarga.
 
+!masmunicion
  <-
 .wait(5000);
   .reload;
   !masmunicion.