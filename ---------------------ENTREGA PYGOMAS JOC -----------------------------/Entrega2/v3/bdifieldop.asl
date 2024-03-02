//TEAM_AXIS
// Plan inicial
+flag (F): team(200) 
  <-
    +aux(0);
    +vueltas(0);
    .print("[FIELDOP]: A sus ordenes comandante!").

//////////////////////////////////////////////////////////////////////////////////I
//HAN ROBADO LA BANDERA : NOS CENTRAMOS EN UN OBJETIVO Y LO SEGUIMOS
//Si vemos a alguien, lo perseguimos
+!recuperarBandera: enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
    -routine;
    .print("[FIELDOP]: Recuperad la banderaaaa!!!!",ID);
    .look_at(Position);
    .goto(Position);
    -+vueltas(0);
    +persecucion(ID).
  
//Si el enemigo que vemos es el que tenemos que perseguir, vamos hacia él
+!persecucion(I): enemies_in_fov(ID,Type,Angle,Distance,Health,Position) & ID == I
  <-
    .look_at(Position);
    .print("[FIELDOP]: Lo veooo, esta en las coordenadas: ", Position);
    +persecucion(ID);
    .goto(Position).



//Si estamos persiguiendo a alguien y no ve a nadie, si tiene la bandera delante, va a por ella, en caso contrario se vuelve al origen
+!persecucion(I): not(enemies_in_fov(ID,Type,Angle,Distance,Health,Position))
  <-
    .banderaVista(X);
    .length(X,L);
    if(not(L==0)){
      .goto(X);
      +banderita;
    };
    ?patroll_point(G);
    -patroll_point(G);
    +routine;
    +patroll_point(G).

//ACABAN PLANES CONTRA ROBAR RABNDERA
//////////////////////////////////////////////////////////////////////////////////I

// Plan para cuando aceptan nuestra oferta, en la que dejamos de patrullar
// y vamos a la posición del soldado
+acceptproposal[source(A)]: municion(A, Pos)
  <-
    .print("[FIELDOP]:Municion soldado: ", A, "Vamos a ", Pos);
    -routine;
    -acceptproposal;
    .goto(Pos).

// Plan para cuando rechazan nuestra oferta
+cancelproposal[source(A)]: municion(A, Pos)
  <-
    .print("[FIELDOP]: Operacion cancelada! ");
    -cancelproposal;
    -municion(_,_).

// Plan para cuando un soldado nos pide ayuda, momento
// en el que le enviamos nuestra distancia a él
+municionplease(Pos)[source(A)]
  <-
    if(not(municion(_,_))){
      ?position(MiPos);
      .distancia(Pos, MiPos, D);
      .send(A,tell,munBid(D));
      +municion(A,Pos);
      -municionplease(_);
      .print("[FIELDOP]: De acuerdo, estoy a ", D, "m");
    }.

// Plan para avisar al comandante de que sigue teniendo que vigilar la bandera
+comandante(C)
  <-
    -comandante(C);
    .send(C, achieve, mirar_bandera).

// Plan para establecer los puntos de patrulla 
+aPatrullar(G)[source(A)]
  <-
	  +control_points(G);
    .length(G,L);
    +total_points(L);
    +routine;
    +patroll_point(0).

//Si llegamos al objetivo y estamos buscando la bandera, volvemos al origen y avisamos al capitan, si estábamos buscando
//solo volvemos al origen
+target_reached(T): banderita
  <-
    if (banderita){
      -banderita;
      .wait(1000);
      .get_service("comandante");
    };
    ?origin(G);
    .goto(G);
    +formacion;
    -target_reached(T).

// Plan para cuando se llega a un punto de la patrulla.
// En ese momento se genera un paquete de munición y
// se establece cuál es el siguiente punto
+target_reached(T): routine
  <-
    .print("[FIELDOP]: PAQUETE VA!");
    .reload;
    ?patroll_point(P);
    -patroll_point(P);
    +patroll_point(P+1);
    -target_reached(T).

// Plan para cuando se llega a la posición del soldado, momento
// en que se generan tres paquetes de munción y se alarma al soldado
// en cuestión. Después se vuelve a la patrulla
+target_reached(T): municion(A,T)
  <-
    .send(A,tell,buscaPaquetes);
	  .reload;
    .reload;
    .reload;
	  .print("[FIELDOP]: Te dejo municion soldado! :)");
    -target_reached(T);
    +routine;
    ?patroll_point(P);
    -patroll_point(P);
    +patroll_point(P);
	  -municion(_,_).

// Plan para ir a los puntos de patrulla de forma circular
+patroll_point(P): total_points(T) & P<T 
  <-
    ?control_points(C);
    .nth(P,C,A);
    .goto(A).

// Plan para ir a los puntos de patrulla de forma circular
+patroll_point(P): total_points(T) & P==T
  <-
    -patroll_point(P);
    +patroll_point(0).

// Plan para disparar a los enemigos cuando no haya aliados en la línea
// de fuego
+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <- 
    ?position(Pos);
    .fuegoAmigo(Pos,Position, X);
    if(not(X)){
      .shoot(3,Position);
    }.
 