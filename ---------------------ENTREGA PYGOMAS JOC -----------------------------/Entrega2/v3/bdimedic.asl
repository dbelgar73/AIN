//TEAM AXIS
+flag (F): team(200)  
  <-
    .print("[MEDICO]: A sus ordenes comandante! -.- ").

// Plan para avisar al capitán de que sigue teniendo que vigilar la bandera
+comandante(C)
  <-
    -comandante(C);
    .send(C, achieve, mirar_bandera).
//####################### RECUPERAR BANDERA ###############################
//Bandera robada, si vemos a alguien, lo perseguimos
+!recuperarBandera: enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
    -patrullando;//desactiva la rutina
    .print("[MEDICO]: Que no escapen!! Soldado enemigo a la vista: ",ID);
    .look_at(Position);//mira hacia el enemigo
    .goto(Position);//perseguir al enemigo
    +perseguir(ID).//marca el enemigo para perseguirlo

//Perseguir el enemigo marcado
+!perseguir(I): enemies_in_fov(ID,Type,Angle,Distance,Health,Position) & ID == I
  <-
    .look_at(Position);//mirar hacia el enemigo
    +perseguir(ID);
    .goto(Position).//ir hacia el enemigo

//Si no ve a nadie durante la persecucion, va a por la bandera si la tiene delante
+!perseguir(I): not(enemies_in_fov(ID,Type,Angle,Distance,Health,Position))
  <-
    .banderaVista(X);//obtiene coordenadas si ve la bandera
    .length(X,L);
    if(not(L==0)){//Ha visto la bandera
      .goto(X);//va a por la bandera
      +banderaALaVista;
    }.

//Si recogemos la bandera volvemos al origen
+target_reached(T): banderaALaVista
  <-
    if (banderaALaVista){
      -banderaALaVista;
      .wait(1000);
      .get_service("comandante");
      };
    ?origin(G);
    .goto(G);
    +formacion;
    -target_reached(T).    
//############################# CURAR ###############################
// cuando llega al punto de patrulla genera paquete y va al siguiente punto
+target_reached(T): patrullando
  <-
    .print("[MEDICO]: HEALTHPACK va!");
    .cure;
    ?patroll_point(P);
    -patroll_point(P);
    +patroll_point(P+1);
    -target_reached(T).

// Plan para cuando un soldado nos pide ayuda, momento
// en el que le enviamos nuestra distancia a él
+curacionSolicitada(Pos)[source(A)]
  <-
    if(not(curando(_,_))){
      ?position(MiPos);
      .distancia(Pos, MiPos, D);
      .send(A,tell,medicBid(D));
      +curando(A,Pos);
      -curacionSolicitada(_);
      .print("[MEDICO]: En camino! Estoy a : ", D, " m");
    }.

// se llega al soldado para curarlo
+target_reached(T): curando(A,T)
  <-
    .send(A,tell,buscaPaquetes);
    .print("[MEDICO]: Coge el paquetee!!!!!");
	  .cure;
    .cure;
    .cure;
    -target_reached(T);
    +patrullando;
    ?patroll_point(P);
    -patroll_point(P);
    +patroll_point(P);
	  -curando(_,_).    

// Plan para cuando aceptan nuestra oferta, en la que dejamos de patrullar
// y vamos a la posición del soldado
+aceptarPropuesta[source(A)]: curando(A, Pos)
  <-
    .print("[MEDICO]: Ayudando a : ", A, " en la posicion: ", Pos);
    -patrullando;
    -aceptarPropuesta;
    .goto(Pos).

// Plan para cuando rechazan nuestra oferta
+cancelarPropuesta[source(A)]: curando(A, Pos)
  <-
    .print("[MEDICO]: Operacion cancelada!!! -.-");
    -cancelarPropuesta;
    -curando(_,_).    
//##############################PATRULLAR#######################################
// Plan para establecer los puntos de patrulla 
+aPatrullar(G)[source(A)]
  <-
	  +control_points(G);
    .length(G,L);
    +total_points(L);
    +patrullando;
    +patroll_point(0).

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
//##############################ATAQUES######################
// Plan para disparar a los enemigos cuando no haya aliados en la línea
// de fuego
+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <- 
    ?position(Pos);
    .fuegoAmigo(Pos,Position, X);
    if(not(X)){
      .shoot(3,Position);
    }.