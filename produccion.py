#Funciones sin parametros
import os #libreria para limpiar la consola
import pandas #libreria usada para imprimir las tablas
import psycopg2 #libreria que conecta Python con BD PostgreSQL
import numpy as np



def conexion():
    global conn
    global cursor
    conn = psycopg2.connect(host = 'localhost', user= 'postgres', password ='toby3030', dbname= 'cerveceria')
    cursor = conn.cursor()
    conn.autocommit=True


def menu():
    print("Bienvenido a la aplicacion del gerente de produccion\n")

    print("1. Ver lotes que han sido enviados, materia y prima y su proveedor")
    print("2. Ver el estado de todos lote")
    print("3. Ver el estado de un lote especifico")
    print("4. Ver los pagos cancelados a un proveedor")
    print("5. Ver almacen de materia prima")
    print("6. Ver almacen de produccion")
    print("7. Ver almacen de cervezas")
    print("8. Ver los tiempos de embotellado de los lotes")


    print("\nEscribe el numero de la opcion que desees realizar:")
    global cambio 
    cambio = input()
    cambio = int (cambio)
    #evaluando tipo de cambio
    if(cambio ==1):
        proveedorlote()
    elif(cambio==2):
        estadolote()
    elif(cambio==3):
        estadounlote()
    elif(cambio==4):
        pagosproveedor()
    elif(cambio==5):
        almacenMP()
    elif(cambio==6):
        almacenProduccion()
    elif(cambio==7):
        almacenembotellado()
    elif(cambio==8):
        tiempos()
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

def estadounlote():
    print("Ingrese el numero de lote que quiere buscar")
    lote = input()
    lote = int (lote)
    query = "SELECT estado FROM lote WHERE idlote=%s"
    cursor.execute(query, (lote,))
    conn.commit()
    estado = cursor.fetchall()
    print("El estado del lote ",lote, "es: ", estado)


def estadolote():
    #mostrar los querys con vistas
    query = 'SELECT * FROM estadolote'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))


def pagosproveedor():
    #mostrar los querys con vistas
    query = 'SELECT * FROM PagosProveedor'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))
    print ("\n")
    print ("\n")
    query2 = 'SELECT * FROM SumaPagosProveedor'
    cursor.execute(query2)
    conn.commit()
    df = pandas.read_sql(query2, conn)
    print (df.to_string(index = False))

def almacenMP():
    #mostrar los querys con vistas
    query = 'SELECT * FROM InventarioMP'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))


def almacenProduccion():
    #mostrar los querys con vistas
    query = 'SELECT * FROM InventarioProduccion'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))


def almacenembotellado():
    #mostrar los querys con vistas
    query = 'SELECT * FROM verinventariocerveza'
    cursor.execute(query)
    conn.commit()
    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))
   

def tiempos():
    #mostrar los querys con vistas
    query = 'SELECT * FROM tiempos'
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