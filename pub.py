import ssl
import sys
import json
import random
import time
import paho.mqtt.client
import paho.mqtt.publish
import numpy as np
from datetime import datetime, date, timedelta
import psycopg2


def on_connect(client, userdata, flags, rc):
	print('connected')

def main():

	client = paho.mqtt.client.Client("Unimet", False)
	client.qos = 0
	client.connect(host='localhost')
	meanTonelada = 20
	precioOroKg=42900
	stdTonelada = 5
	cantTorniquetes = 20
	cantTurnos = 5
	turno =0
	conn = psycopg2.connect(host = 'localhost', user= 'postgres', password ='toby3030', dbname= 'cerveceria')
	#conn = psycopg2.connect(host = 'ec2-107-20-167-11.compute-1.amazonaws.com', user= 'inytxpqzmlwhkp', password ='167ff1fd25c60913b54178a1c3427b18b6689f5e822f09f1176788b580c2d1e7', dbname= 'd7dcs98v6bp756')
	cursor = conn.cursor()
	conn.autocommit=True
	cantidadproveedores = 'SELECT COUNT(id) FROM proveedor'
	cursor.execute(cantidadproveedores)
	conn.commit()
	fa = cursor.fetchall()
	cantidadpesos = 'SELECT COUNT(id) FROM peso_automatico'
	cursor.execute(cantidadproveedores)
	conn.commit()
	peso = cursor.fetchall()
	estado = 'materiaprima'

	
	horaBase = datetime.now().replace(minute=0, second=0)
	hoy = date.today()
	while(cantTurnos>=turno):
		turno+=1
		cantidadTonelada = int(np.random.normal(meanTonelada, stdTonelada))
		horaBase = horaBase + timedelta(hours=1)

		while(cantidadTonelada>0):
			hora = horaBase + timedelta(minutes=np.random.uniform(0,60))
			dat = hoy + timedelta(days=np.random.uniform(0,7))
			fk_proveedor = int(np.random.uniform(1, fa))
			query = "SELECT fk_mp FROM proveedor WHERE id=%s"
			cursor.execute(query, (fk_proveedor,))
			conn.commit()
			fe = cursor.fetchall()
			fk_MP = int(np.random.uniform(fe, fe))
			
			peso_aut = int(np.random.uniform(1, peso))
			precioTotal=cantidadTonelada*precioOroKg


			payload = {
				"fecha": str(dat),
				"cantidad": str(cantidadTonelada),
				"proveedor": str(fk_proveedor),
				"mp": str(fk_MP),
				"peso": str(peso_aut),
				"est": str(estado),
				"costototal": str(precioTotal)

			}
			client.publish('unimet/admin/bd',json.dumps(payload),qos=0)		
			cantidadTonelada-=1
			print(payload)
			time.sleep(2)


if __name__ == '__main__':
	main()
	sys.exit(0)
