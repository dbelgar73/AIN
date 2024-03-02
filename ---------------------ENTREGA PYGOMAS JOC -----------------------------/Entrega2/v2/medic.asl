+flag(Pos): team(200) 
  <-
  !!recarga;
    .wait(5000);   
    .goto(Pos);
//    +objetivo(Pos).
  !masmedicina.


+position(Pos):  objetivo(Pos)
<-
  .cure;
    -objetivo(_);
    !masmedicina.

+!recarga
<-

	.wait(1000);
	!recarga.

+!masmedicina
<-
 .wait(5000);
 .cure;
   !masmedicina.