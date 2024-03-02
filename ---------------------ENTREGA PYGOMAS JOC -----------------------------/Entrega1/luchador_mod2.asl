+flag(F): team(200)
  <-
  +vida(85);
  +ir_a;
  +count(4);
  +count2(10);
  .print("Hola").

+ammo(A): A <= 20 & esquina
  <-
  .goto([[128,0,128]]);
  +centro.

+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): TYPE = 1002 & ammo(X) & X <= 50 & centro & not(to_pack_mun)
  <-
  +to_pack_mun;
  -to_pack;
  .goto([X,Y,Z]).

+packs_in_fov(ID, TYPE, ANGLE, DIST, HEALTH, [X,Y,Z]): TYPE = 1001 & health(X) & X <= 50 & centro & not(to_pack)
  <-
  +to_pack;
  .goto([X,Y,Z]).

+health(X): vida(Y) & Y > X & X <= 45 
  <-
  -vida(Y);
  +vida(X);
  .print("Herido");
  +ir_a.

+health(X): vida(Y) & Y > X & X > 45
  <-
  -vida(Y);
  +vida(X);
  .stop;
  .print("Herido");
  +look_for.

+ir_a: position([X,Y,Z]) & X >= 128 & Z >= 128 & not(centro)
  <-
  -ir_a;
  +esquina;
  .goto([240,0,240]).

+ir_a: position([X,Y,Z]) & X >= 128 & Z <= 128 & not(centro)
  <-
  -ir_a;
  +esquina;
  .goto([240,0,15]).

+ir_a: position([X,Y,Z]) & X <= 128 & Z >= 128 & not(centro)
  <-
  -ir_a;
  +esquina;
  .goto([15,0,240]).

+ir_a: position([X,Y,Z]) & X <= 128 & Z <= 128 & not(centro)
  <-
  -ir_a;
  +esquina;
  .goto([15,0,15]).

+target_reached(T): centro
  <-
  .wait(1000).

+target_reached(T): esquina
  <-
  .look_at([128,0,128]).

+friends_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
  .shoot(10,Position).