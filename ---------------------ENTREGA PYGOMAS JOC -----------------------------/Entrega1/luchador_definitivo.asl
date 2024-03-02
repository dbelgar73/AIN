//David Beltran Garceran 2023 AIN
//###################################################################################################################################################
+flag(F): team(200)
  <-
  .print("A POR ELLOS!! -.-");
  +vida(85);
  +ir_a;//ve a la esquina mas cercana
  .wait(10000);//espera 10 segundos
  .create_control_points(F,100,3,C);
  .length(C,L);
  +control_points(C);
  +total_control_points(L);
  +patrolling.//Patrullar en busca de enemigos
  
//Ha recogido packs
+target_reached(T): to_pack_mun
  <-
  -centro; 
  +ir_a;
  -to_pack_mun.

+target_reached(T): to_pack
  <-
  -centro;
  +ir_a;
  -to_pack.

//Si tiene poca municion y esta en la esquina, ve a reponer
+ammo(A): A <= 20 & esquina
  <-
  .wait(20000);//espera 20s
  .print("A POR MUNICION!!! (◡_◡)");
  .goto([[128,0,128]]);//ve al centro
  +centro.

//Repone Recursos
//Municion
+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): TYPE = 1002 & ammo(X) & X <= 50 & centro & not(to_pack_mun)
  <-
  +to_pack_mun;
  -to_pack;
  .goto([X,Y,Z]).

//Medicinas
+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): TYPE = 1001 & health(X) & X <= 50 & centro & not(to_pack)
  <-
  +to_pack;
  .goto([X,Y,Z]).

//Juega Defensivo si tiene poca vida
+health(X): vida(Y) & Y > X & X <= 45 
  <-
  -patrolling;
  -vida(Y);
  +vida(X);
  .print("POCA VIDA!!! HUYENDOOO! X(");
  .look_at([128, 0, 128]);//mira al centro
  +ir_a.//vuelve a la esquina

//--------------------------------IR A LA ESQUINA MAS CERCANA----------------------------------------------------------------
//Esquina DownR
+ir_a: position([X,Y,Z]) & X >= 128 & Z >= 128 & not(centro)
  <-
  -ir_a;
  +esquina;
  .print("Coordenadas! [240, 0, 240]");
  .goto([240,0,240]).//muevete a la esquina

//Esquina DownL
+ir_a: position([X,Y,Z]) & X >= 128 & Z <= 128 & not(centro)
  <-
  -ir_a;
  +esquina;
  .print("Coordenadas! [240, 0, 20]");
  .goto([240,0,20]).//muevete a la esquina

//Esquina UpR
+ir_a: position([X,Y,Z]) & X <= 128 & Z >= 128 & not(centro)
  <-
  -ir_a;
  +esquina;
  .print("Coordenadas! [20, 0, 240]");
  .goto([20,0,240]).//muevete a la esquina

//Esquina UPL
+ir_a: position([X,Y,Z]) & X <= 128 & Z <= 128 & not(centro)
  <-
  -ir_a;
  +esquina;
  .print("Coordenadas! [20, 0, 20]");
  .goto([20,0,20]).//muevete a la esquina

//Ha llegado a la esquina
+target_reached(T): esquina
  <-
  -ir_a;
  -esquina;
  .look_at([128,0,128]);//mira al centro
  .print("Campeando (-- . --)");
  .wait(60000);//espera 1min
  +patrullar.

//Patrullar en busca de enemigos
+patrullar: position([X,Y,Z]) & esquina
  <-
  .goto([128, 0, 128]);//dirigete al centro
  .print("Buscando enemigos! Al centro! (--..--)").

//Patrullar en busca de enemigos
+patrullar: position([X,Y,Z]) & not(esquina)
  <-
  .print("Buscando enemigos! (--..--)");
  +patroll_point(0);
  +patrolling.

//Si hay un enemigo a la vista dispara (se podria mejorar)
+friends_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
  .print("ENEMIGO!!! AAAAAAAAAA!!!! `-( * O*)-`");
  .shoot(100,Position).
  
//Patrulla
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