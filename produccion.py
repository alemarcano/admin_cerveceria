#Funciones sin parametros
import os #libreria para limpiar la consola
import pandas #libreria para imprimir las tablas
import psycopg2 #libreria que conecta Python con BD PostgreSQL
import numpy as np



def conexion():
    global conn
    global cursor
    conn = psycopg2.connect(host = 'localhost', user= 'postgres', password ='toby3030', dbname= 'cerveceria')
    cursor = conn.cursor()
    conn.autocommit=True


def menu():
    print("Bienvencido a la aplicacion del gerente de produccion\n")

    print("1. Ver lotes que han sido enviados, materia y prima y su proveedor")
    print("2. Ver el estado de un lote")
    print("3. Ver los pagos cancelados a un proveedor")
    print("4. Mandar a embotellar")
    print("5. Ver almacen de materia prima")
    print("5. Ver almacen de pr")
    print("5. Ver almacen de cervezas")





    print("Que tipo de cambio deseas realizar?")
    global cambio 
    cambio = input()
    cambio = int (cambio)
    #evaluando tipo de cambio
    if(cambio ==1):
        proveedorlote()
    elif(cambio==2):
        estadolote()
    elif(cambio==3):
        proveedorlote()
    elif(cambio==4):
        proveedorlote()
    elif(cambio==5):
        proveedorlote()
    else:
        print("El tipo de cambio que seleccionaste no existe")
    print("\nDeseas hacer otro tipo de cambio regresando al menu? (Si/No)?")
    global resp
    resp = input()
    resp = resp.lower()
    otraVez()


def proveedorlote():
    #mostrar los querys con vistas
    query = 'SELECT * FROM proveedorlote'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))

def estadolote():
    #mostrar los querys con vistas
    query = 'SELECT * FROM estadolote'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))
   


def otraVez():
    while (resp!="no"):
        os.system('cls')
        conexion()
        menu()

conexion()
menu()