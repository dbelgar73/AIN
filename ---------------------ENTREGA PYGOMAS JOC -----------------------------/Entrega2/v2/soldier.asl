//#######################################################TEAM_AXIS######################################################
+flag (F): team(200)
  <-
  .create_control_points(F,25,3,C);
  +control_points(C);
  .length(C,L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0).

+target_reached(T): patrolling & team(200)
  <-
  ?patroll_point(P);
  -+patroll_point(P+1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T
  <-
  ?control_points(C);
  .nth(P,C,A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P==T
  <-
  -patroll_point(P);
  +patroll_point(0).

//#######################################################TEAM_ALLIED###############################################
+flag (Pos): team(100)
  <-
  // Obtener el servicio "comandante"
  .get_service("comandante");
  .print("[SOLDADO]: Esperando ordenes, comandante! -.-").
  //.goto(Pos);


// Manda un mensaje al comandante para registrarse en su lista
+comandante(C): team(100) 
  <-
  +comandante0(C);  // Se agrega el identificador del agente como comandante0
  .send(C, tell, registrar).  // Se envía un mensaje al comandante para registrarse

// Desplazar los agentes a "campear" la bandera
+irA(Punto)[source(S)]: team(100)
  <-
  .goto(Punto);  // Se mueve hacia el punto especificado
  +punto;  // Se marca que ha llegado al punto
  .print("[SOLDADO]: A sus ordenes, voy a las coordenadas ", Punto, "!").  // Se muestra un mensaje

// Ha llegado al punto indicado
+target_reached(T): team(100) & punto
  <-
    -punto;
    .print("[SOLDADO]: Esperando su señal! -.-").

+atacar: team(100) & flag(F)
  <-
    .print("[SOLDADO]: A por la banderaaaa!!!");
    +aporbandera;
    .goto(F).


// Se ha cogido la bandera
+flag_taken: team(100)
  <-
  .print("[SOLDADO]: La tenemos!!!! Corred a base!!");
  ?base(A);
  +returning;
  ?base(B);
  .look_at(B);
  .goto(A);
  -exploring.

+heading(H): exploring
  <-
  .wait(2000);
  .turn(0.375).

+target_reached(T): team(100)
  <-
  .print("target_reached");
  +exploring;
  .turn(0.375).

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
  .shoot(3,Position).