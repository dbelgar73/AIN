//TEAM_ALLIED

+flag (F): team(100)
  <-
    
  .goto(F).

+flag_taken: team(100)
  <-
  ?base(B);
  +returning;
  .goto(B);
  -exploring.

+heading(H): exploring
  <-
  .wait(2000);
  .turn(0.375).

//+heading(H): returning
//  <-
//  .print("returning").

+target_reached(T): team(100)
  <-
  +exploring;
  .turn(0.375).