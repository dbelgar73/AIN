import json
import random
import math
from loguru import logger
from spade.behaviour import OneShotBehaviour
from spade.template import Template
from spade.message import Message
from pygomas.bditroop import BDITroop
from pygomas.bdisoldier import BDISoldier
from pygomas.bdifieldop import BDIFieldOp
from pygomas.bdimedic import BDIMedic
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions as asp_action
from pygomas.ontology import DESTINATION
from pygomas.agent import LONG_RECEIVE_WAIT

# Métodos para la clase capitán
class Comandante(BDITroop):
      
      def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        # Método goto modificado:
        # int d: radio del círculo sobre los que se generarán los puntos
        # double x: coordenada en el eje x del punto de referencia
        # double z: coordenada z del punto de referencia
        # int angle: ángulo que deben formar
        # return:  coordenadas del punto al qyue va
        def goto2(d, x, z, angle):
            i = d
            while 1:
                h = round(x + (i * math.cos(angle)))
                v = round(z + (i * math.sin(angle)))
                i = i - 1
                if (self.map.can_walk(h,v) or i == 0):
                    break
            return (h,0,v)
        
        # Método circleFlag(int d, int p, tuple l, out tuple)
        # param:
        # -int d: radio del círculo sobre los que se generarán los points
        # -int p: número de points a generar
        # -tuple l: tupla con las coordenadas de una posición
        # return: tupla con los points generados
        @actions.add_function(".flagCircle", (int,int,tuple, ))
        def _flagCircle(d,p,l):
            x = l[0]
            z = l[2]

            result = []

            if p==5:
                
                point = goto2(d, x, z, 0)
                result.append(point)

                point = goto2(d, x, z, 72*math.pi/180)
                result.append(point)

                point = goto2(d, x, z, 144*math.pi/180)
                result.append(point)

                point = goto2(d, x, z, 216*math.pi/180)
                result.append(point)

                point = goto2(d, x, z, 288*math.pi/180)
                result.append(point)

            elif p==4:
                
                point = goto2(d, x, z, 0)
                result.append(point)

                point = goto2(d, x, z, 90*math.pi/180)
                result.append(point)

                point = goto2(d, x, z, 180*math.pi/180)
                result.append(point)

                point = goto2(d, x, z, 270*math.pi/180)
                result.append(point)

            elif p==3:

                point = goto2(d, x, z, 0)
                result.append(point)

                point = goto2(d, x, z, 120*math.pi/180)
                result.append(point)

                point = goto2(d, x, z, 240*math.pi/180)
                result.append(point)
            
            result = tuple(result)

            return result
        
        # Método reverse:
        # tupla l: tupla de la que invertiremos elementos
        @actions.add_function(".reverse", (tuple, ))
        def _reverse(l): 
            lista = list(l)
            lista.reverse()
            return tuple(lista)

        # Método flag:
        # -True si sigue la bandera False si han robado la bandera
        @actions.add_function(".banderaRobada", ())
        def _flag():
            if not self.fov_objects:
                return False
            for tracked_object in self.fov_objects:
                if tracked_object.get_type() == 1003:
                    return True
            return False

        # Método friend:
        # tupla posAgente: tupla con las coordernadas de nuestro agente
        # tupla enemyPos: tupla con las coordenadas del enemigo
        # return:  
        # -True si hay un aliado en la línea de fuego entre nuestro agente 
        # -False en el caso contrario
        @actions.add_function(".fuegoAmigo", (tuple, tuple))
        def _fuegoAmigo(posAgente, enemyPos):
            x1 = posAgente[0]
            z1 = posAgente[2]
            x2 = enemyPos[0]
            z2 = enemyPos[2]
            if not self.fov_objects or (x2 == x1 and z2 == z1):
                return False
            for tracked_object in self.fov_objects:
                if self.team == tracked_object.get_team():
                    error = False
                    x3 = tracked_object.get_position().x
                    z3 = tracked_object.get_position().z
                    if((math.isclose(x2, x1) or math.fabs(x2-x1) < 0.000001) and isBetween(z1, z2, z3)): return True
                    if((math.isclose(z2, z1) or math.fabs(z2-z1) < 0.000001) and isBetween(x1, x2, x3)): return True
                    try:
                        Ax = (x3 - x1) / (x2 - x1)
                    except:
                        error = True
                        if isBetween(z1, z2, z3):
                            return True
                    try:
                        Ay = (z3 - z1) / (z2 - z1)
                    except:
                        error = True
                        if isBetween(x1, x2, x3):
                            return True
                    if not error and math.fabs(Ax - Ay) < 0.000001 and Ax >= 0.0 and Ax <= 1.0:
                        return True
            return False

        # Método isBetween(double a, double b, double c)
        # param:
        # -double a: coordenada del primer point
        # -double b: coordenada del segundo point
        # -double c: coordenada del tercer point
        # return: 
        # -True si la coordenada c está entre a y b
        # -False en el caso contrario
        def isBetween(a, b, c):
            larger = a if (a >= b) else b
            smaller = a if (a != larger) else b

            return c <= larger and c >= smaller

# Métodos de la clase soldado
class BDISoldier_Int(BDISoldier):

      def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        # Método mirarOpuesto
        # -tuple l: tupla con las coordenadas de una posición
        # -tuple l2: tupla con las coordenadas de otra posición
        # return: tupla con un point a la misma distancia que los otros dos points pero en sentido opuesto
        @actions.add_function(".mirarOpuesto", (tuple, tuple, ))
        def _mirarOpuesto(l, l2):
            x1 = l[0]
            z1 = l[2]
            x2 = l2[0]
            z2 = l2[2]
            lon = math.sqrt((x2-x1)*(x2-x1) + (z2-z1)*(z2-z1))
            try:
                dx = (x2-x1) / lon
                dy = (z2-z1) / lon
            except:
                dx = 0
                dy = 0
            x3 = x1 - lon * dx
            z3 = z1 - lon * dy
            return (x3,0,z3)

        # Método distance(tuple posSol, tuple posOtro, out double)
        # param:
        # -tuple posSol: tupla con las coordenadas de la posición del agente
        # -tuple posOtro: tupla con las coordenadas de una posición
        # return: distancia entre los dos points
        @actions.add_function(".distancia", (tuple, tuple, ))
        def _distancia(posSol, posOtro):
            x1 = posSol[0]
            z1 = posSol[2]
            x2 = posOtro[0]
            z2 = posOtro[2]
            lon = math.sqrt((x2-x1)*(x2-x1) + (z2-z1)*(z2-z1))
            return lon
        
        # Método minPos(tuple l, out int)
        # param:
        # -tuple l: tupla con números
        # return: índice del elemento mínimo
        @actions.add_function(".posicionCercana", (tuple, ))
        def _posicionCercana(lista):
            lista = list(lista)
            posicionCercana = lista.index(min(lista))
            return posicionCercana

        # Método distance(tuple posSol, tuple posOtro, out double)
        # param:
        # -tuple posSol: tupla con las coordenadas de la posición del agente
        # -tuple posOtro: tupla con las coordenadas de una posición
        # return: distancia entre los dos points
        def distance(posSol, posOtro):
            x1 = posSol[0]
            z1 = posSol[2]
            x2 = posOtro[0]
            z2 = posOtro[2]
            distancia = math.sqrt((x2-x1)*(x2-x1) + (z2-z1)*(z2-z1))
            return distancia
        
        # Método puntoOptimo(tuple posFlag, tuple posSol, tuple posEnem, out tuple)
        # param:
        # -tuple posFlag: tupla con las coordenadas de la posición de la bandera
        # -tuple posSol: tupla con las coordenadas de la posición del soldado
        # -tuple posEnem: tupla con las coordenadas de la posición del enemigo
        # return: tupla con las coordenas del point generado al lado de la posición del soldado
        @actions.add_function(".puntoOptimo", (tuple, tuple, tuple, ))
        def _puntoOptimo(posFlag, posSol, posEnem):
            x0 = posSol[0]
            y0 = posSol[2]
            a = posFlag[0]
            b = posFlag[2]
            if (y0 == b): y0 = y0 + 1
            ALPHA = 5
            x1 = x0+ALPHA
            x2 = x0-ALPHA
            y1 = -((x0-a)/(y0-b))*(x1-x0)+y0
            y2 = -((x0-a)/(y0-b))*(x2-x0)+y0
            p1 = (x1,0,y1)
            p2 = (x2,0,y2)
            d1 = distance(p1,posEnem)
            d2 = distance(p2,posEnem)
            if (d1<=d2): res = p1
            else: res = p2
            return res

        # Método flag(out tuple)
        # return: tupla con las coordenadas de la bandera si es avistada
        @actions.add_function(".banderaVista", ())
        def _banderaVista():
            if not self.fov_objects:
                return ()
            for tracked_object in self.fov_objects:
                if tracked_object.get_type() == 1003:
                    res = (tracked_object.get_position().x, 0, tracked_object.get_position().z)
                    return res
            return ()

        # Método friedn(tuple posAgente, tuple enemyPos, out boolean)
        # param:
        # -tuple posAgente: tupla con las coordernadas de nuestro agente
        # -tuple enemyPos: tupla con las coordenadas del enemigo
        # return:  
        # -True si hay un aliado en la línea de fuego entre nuestro agente 
        # -False en el caso contrario
        @actions.add_function(".fuegoAmigo", (tuple, tuple, ))
        def _fuegoAmigo(posAgente, enemyPos):
            x1 = posAgente[0]
            z1 = posAgente[2]
            x2 = enemyPos[0]
            z2 = enemyPos[2]
            if not self.fov_objects or (x2 == x1 and z2 == z1):
                return False
            for tracked_object in self.fov_objects:
                if self.team == tracked_object.get_team():
                    error = False
                    x3 = tracked_object.get_position().x
                    z3 = tracked_object.get_position().z
                    if((math.isclose(x2, x1) or math.fabs(x2-x1) < 0.000001) and isBetween(z1, z2, z3)): return True
                    if((math.isclose(z2, z1) or math.fabs(z2-z1) < 0.000001) and isBetween(x1, x2, x3)): return True
                    try:
                        Ax = (x3 - x1) / (x2 - x1)
                    except:
                        error = True
                        if isBetween(z1, z2, z3):
                            return True
                    try:
                        Ay = (z3 - z1) / (z2 - z1)
                    except:
                        error = True
                        if isBetween(x1, x2, x3):
                            return True
                    if not error and math.fabs(Ax - Ay) < 0.000001 and Ax >= 0.0 and Ax <= 1.0:
                        return True
            return False

        # Método isBetween(double a, double b, double c)
        # param:
        # -double a: coordenada del primer point
        # -double b: coordenada del segundo point
        # -double c: coordenada del tercer point
        # return: 
        # -True si la coordenada c está entre a y b
        # -False en el caso contrario
        def isBetween(a, b, c):
            larger = a if (a >= b) else b
            smaller = a if (a != larger) else b
            return c <= larger and c >= smaller

# Métodos de la clase agente de campo
class BDIFieldOp_Int(BDIFieldOp):
      def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        # Método distance(tuple posSol, tuple posOtro, out double)
        # param:
        # -tuple posSol: tupla con las coordenadas de la posición del agente
        # -tuple posOtro: tupla con las coordenadas de una posición
        # return: distancia entre los dos points
        @actions.add_function(".distancia", (tuple, tuple, ))
        def _distancia(posSol, posOtro):
            x1 = posSol[0]
            z1 = posSol[2]
            x2 = posOtro[0]
            z2 = posOtro[2]
            distancia = math.sqrt((x2-x1)*(x2-x1) + (z2-z1)*(z2-z1))
            return distancia

        # Método flag(out tuple)
        # return: tupla con las coordenadas de la bandera si es avistada
        @actions.add_function(".banderaVista", ())
        def _banderaVista():
            if not self.fov_objects:
                return ()
            for tracked_object in self.fov_objects:
                if tracked_object.get_type() == 1003:
                    res = (tracked_object.get_position().x, 0, tracked_object.get_position().z)
                    return res
            return ()

        # Método friedn(tuple posAgente, tuple enemyPos, out boolean)
        # param:
        # -tuple posAgente: tupla con las coordernadas de nuestro agente
        # -tuple enemyPos: tupla con las coordenadas del enemigo
        # return:  
        # -True si hay un aliado en la línea de fuego entre nuestro agente 
        # -False en el caso contrario
        @actions.add_function(".fuegoAmigo", (tuple, tuple, ))
        def _fuegoAmigo(posAgente, enemyPos):
            x1 = posAgente[0]
            z1 = posAgente[2]
            x2 = enemyPos[0]
            z2 = enemyPos[2]
            if not self.fov_objects or (x2 == x1 and z2 == z1):
                return False
            for tracked_object in self.fov_objects:
                if self.team == tracked_object.get_team():
                    error = False
                    x3 = tracked_object.get_position().x
                    z3 = tracked_object.get_position().z
                    if((math.isclose(x2, x1) or math.fabs(x2-x1) < 0.000001) and isBetween(z1, z2, z3)): return True
                    if((math.isclose(z2, z1) or math.fabs(z2-z1) < 0.000001) and isBetween(x1, x2, x3)): return True
                    try:
                        Ax = (x3 - x1) / (x2 - x1)
                    except:
                        error = True
                        if isBetween(z1, z2, z3):
                            return True
                    try:
                        Ay = (z3 - z1) / (z2 - z1)
                    except:
                        error = True
                        if isBetween(x1, x2, x3):
                            return True
                    if not error and math.fabs(Ax - Ay) < 0.000001 and Ax >= 0.0 and Ax <= 1.0:
                        return True
            return False

        # Método isBetween(double a, double b, double c)
        # param:
        # -double a: coordenada del primer point
        # -double b: coordenada del segundo point
        # -double c: coordenada del tercer point
        # return: 
        # -True si la coordenada c está entre a y b
        # -False en el caso contrario
        def isBetween(a, b, c):
            larger = a if (a >= b) else b
            smaller = a if (a != larger) else b

            return c <= larger and c >= smaller

class BDIMedic_Int(BDIMedic):
      def add_custom_actions(self, actions):
        super().add_custom_actions(actions)
        
        # Método distance(tuple posSol, tuple posOtro, out double)
        # param:
        # -tuple posSol: tupla con las coordenadas de la posición del agente
        # -tuple posOtro: tupla con las coordenadas de una posición
        # return: distancia entre los dos points
        @actions.add_function(".distancia", (tuple, tuple, ))
        def _distancia(posSol, posOtro):
            x1 = posSol[0]
            z1 = posSol[2]
            x2 = posOtro[0]
            z2 = posOtro[2]
            distancia = math.sqrt((x2-x1)*(x2-x1) + (z2-z1)*(z2-z1))
            return distancia
        
        # Método flag(out tuple)
        # return: tupla con las coordenadas de la bandera si es avistada
        @actions.add_function(".banderaVista", ())
        def _banderaVista():
            if not self.fov_objects:
                return ()
            for tracked_object in self.fov_objects:
                if tracked_object.get_type() == 1003:
                    res = (tracked_object.get_position().x, 0, tracked_object.get_position().z)
                    return res
            return ()

        # Método friedn(tuple posAgente, tuple enemyPos, out boolean)
        # param:
        # -tuple posAgente: tupla con las coordernadas de nuestro agente
        # -tuple enemyPos: tupla con las coordenadas del enemigo
        # return:  
        # -True si hay un aliado en la línea de fuego entre nuestro agente 
        # -False en el caso contrario
        @actions.add_function(".fuegoAmigo", (tuple, tuple, ))
        def _fuegoAmigo(posAgente, enemyPos):
            x1 = posAgente[0]
            z1 = posAgente[2]
            x2 = enemyPos[0]
            z2 = enemyPos[2]
            if not self.fov_objects or (x2 == x1 and z2 == z1):
                return False
            for tracked_object in self.fov_objects:
                if self.team == tracked_object.get_team():
                    error = False
                    x3 = tracked_object.get_position().x
                    z3 = tracked_object.get_position().z
                    if((math.isclose(x2, x1) or math.fabs(x2-x1) < 0.000001) and isBetween(z1, z2, z3)): return True
                    if((math.isclose(z2, z1) or math.fabs(z2-z1) < 0.000001) and isBetween(x1, x2, x3)): return True
                    try:
                        Ax = (x3 - x1) / (x2 - x1)
                    except:
                        error = True
                        if isBetween(z1, z2, z3):
                            return True
                    try:
                        Ay = (z3 - z1) / (z2 - z1)
                    except:
                        error = True
                        if isBetween(x1, x2, x3):
                            return True
                    if not error and math.fabs(Ax - Ay) < 0.000001 and Ax >= 0.0 and Ax <= 1.0:
                        return True
            return False

        # Método isBetween(double a, double b, double c)
        # param:
        # -double a: coordenada del primer point
        # -double b: coordenada del segundo point
        # -double c: coordenada del tercer point
        # return: 
        # -True si la coordenada c está entre a y b
        # -False en el caso contrario
        def isBetween(a, b, c):
            larger = a if (a >= b) else b
            smaller = a if (a != larger) else b
            return c <= larger and c >= smaller