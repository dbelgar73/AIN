//EJEMPLO LUCHADOR Esquina Arriba Derecha
+flag(F): team(200)
  <-
  +amiesquina;
  .goto([20, 0, 20]);
  +miposicion([20, 0, 20]).
  //.wait(5000);

+target_reached(T): amiesquina
  <-
  -amiesquina;
  .print("Me quedo quieto en pos: ", T);
  ?flag(F);
  .look_at(F);
  -target_reached(T).
  
  +friends_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
  .shoot(3,Position).