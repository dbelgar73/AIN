//TEAM AXIS
+flag (F): team(200)
  <-
    .register_service("comandante");//registra el servicio comandante: ->jerarquia<-
	.print("[COMANDANTE]: A mis ordenes soldados!! >:@ ");
	.wait(2000);
	!!formad. //inicia la formacion: defensa de la bandera

// Plan que alarma al resto de tropas de que han robado la bandera
+!recuperarBandera
	<-
		.get_backups; //obtiene el numero de soldados
		.get_fieldops; //obtiene el numero de fieldops
		.get_medics; //obtiene el numero de medicos
		.wait(1000); //espera 1s
		?myBackups(S);
		?myFieldops(Am);
		?myMedics(Me);
		.send(S, achieve, recuperarBandera);//envia ordenes de recuperar la bandera
		.send(Am, achieve, recuperarBandera);//envia ordenes de recuperar la bandera
		.send(Me, achieve, recuperarBandera).//envia ordenes de recuperar la bandera

// Plan para crear la foramción de las tropas cuando estén todas disponibles
+!formad: flag(F)
	<-
		.get_backups;
		.get_fieldops;
		.get_medics;
		.wait(1000);
		?myBackups(S);
		?myFieldops(Am);
		?myMedics(Me);
		.wait(1000);
		.length(S, NumSoldados); //obtiene el numero de soldados
		.length(Am, NumFieldop);//obtiene el numero de fieldops
		.length(Me, NumMedicos);//obtiene el numero de medicos
		.wait(1000);
		if (NumSoldados==5 & NumFieldop==2 & NumMedicos==2) {
			.print("[COMANDANTE]: A sus puestos!! Defended la bandera");
			.flagCircle(12,5,F,Puntos); //obtiene los puntos para rodear la bandera
			.reverse(Puntos, Sotnup); //invierte los puntos
			//soldado1
			.nth(0,S,A1);//obtiene el siguiente soldado
			.nth(0,Puntos,G1);//obtiene el siguiente punto
			.send(A1,tell,irA(G1));//mandar posicion al soldado
			.print("[COMANDANTE]: Soldado 1 a" , G1);
			//soldado2
			.nth(1,S,A2);//obtiene el siguiente soldado
			.nth(1,Puntos,G2);//obtiene el siguiente punto
			.send(A2,tell,irA(G2));//mandar posicion al soldado
			.print("[COMANDANTE]: Soldado 2 a ", G2);
			//soldado3
			.nth(2,S,A3);//obtiene el siguiente soldado
			.nth(2,Puntos,G3);//obtiene el siguiente punto
			.send(A3,tell,irA(G3));//mandar posicion al soldado
			.print("[COMANDANTE]: Soldado 3 a ", G3);
			//soldado4
			.nth(3,S,A4);//obtiene el siguiente soldado
			.nth(3,Puntos,G4);//obtiene el siguiente punto
			.send(A4,tell,irA(G4));//mandar posicion al soldado
			.print("[COMANDANTE]: Soldado 4 a ", G4);
			//soldado5
			.nth(4,S,A5);//obtiene el siguiente soldado
			.nth(4,Puntos,G5);//obtiene el siguiente punto
			.send(A5,tell,irA(G5));//mandar posicion al soldado
			.print("[COMANDANTE]: Soldado 5 a ", G5);
			//fieldop1
			.nth(0,Am,Aam1); //obtiene el siguiente fieldop
			.send(Aam1,tell,aPatrullar(Puntos));
			.print("[COMANDANTE]: Apoyo de municion 1!");
			//fieldop2
			.nth(1,Am,Aam2); //obtiene el siguiente fieldop
			.send(Aam2,tell,aPatrullar(Sotnup));
			.print("[COMANDANTE]: Apoyo de municion 2!");
			//medico1
			.nth(0,Me,Ame1); //obtiene el siguiente medico
			.send(Ame1,tell,aPatrullar(Puntos));
			.print("[COMANDANTE]: Medico 1 en posicion");
			//medico2
			.nth(1,Me,Ame2); //obtiene el siguiente medico
			.send(Ame2,tell,aPatrullar(Sotnup));
			.print("[COMANDANTE]: Medico 2 en posicion");
			//Capitán cerca de la bandera
			?flag([X,Y,Z]);//obtiene posicion de bandera
			+formacion; //se actualiza la creencia: estan en formacion
			.goto([X-1,Y,Z-1]); //va cerca de la bandera
		};
		//repite mientras no se hayan registrado todos los agentes
		if(not(NumSoldados == 5) | not(NumFieldop == 2) | not(NumMedicos == 2)){
			!!formad;//bucle de comprobacion
		}.

// Se ha copmpletado la formacion, vigila la bandera estableciendola como objetivo
+target_reached(T): formacion
  <-
  	-formacion;// elimina la creencia
  	?flag(F);
  	.look_at(F);//mira hacia la bandera
  	.wait(3000);//espera 3s
  	!!mirar_bandera.//vigila la bandera
  
// plan para vigilar si roban la bandera
+!mirar_bandera
	<-
		.banderaRobada(X);//comprueba si la bandera sigue ahi (True) o no (False)
		if(X){//True: sigue ahí
			.print("[COMANDANTE]: Bandera Segura! :)");
			.wait(1000);//espera 1s
			!!mirar_bandera;//bucle para vigilar constantemente
		};
		if(not(X)){//False: no esta
			-mirar_bandera;
			.print("[COMANDANTE]: Han robado la bandera! :( ");
			!!recuperarBandera;//plan B que inicia la recuperación de la bandera 
		}.

// Dispara a enemigos a la vista evitando el fuego amigo
+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <- 
  	?position(Pos);//posicion del enemigo
  	.fuegoAmigo(Pos,Position, X);//comprueba: aliado entre el agente y el enemigo (True)
  	if(not(X)){//si no hay aliados en la linea de tiro
    	.shoot(3,Position);//dispara
  	}.