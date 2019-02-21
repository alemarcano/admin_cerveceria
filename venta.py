#Funciones sin parametros
import os #libreria para limpiar la consola
import pandas #libreria para imprimir las tablas
import psycopg2 #libreria que conecta Python con BD PostgreSQL



def conexion():
    global conn
    global cursor
    conn = psycopg2.connect(host = 'localhost', user= 'postgres', password ='toby3030', dbname= 'cerveceria')
    cursor = conn.cursor()
    conn.autocommit=True


def menu():

    print("1. Hacer una venta")
    print("2. Ver la cerveza")
    print("3. Euro")
    print("4. Ver los clietes")
    print("5. Ver los clietes")
    print("6. Ver los clietes")
    print("7. Ver los clietes")




    print("Que tipo de cambio deseas realizar?")
    global cambio 
    cambio = input()
    cambio = int (cambio)
    #evaluando tipo de cambio
    if(cambio ==1):
        cerveza()
    elif(cambio==2):
        cerveza()
    elif(cambio==3):
        clientes()
    elif(cambio==4):
        clientes()
    else:
        print("El tipo de cambio que seleccionaste no existe")
    print("Deseas hacer otro tipo de cambio? (Si/No)?")
    global resp
    resp = input()
    resp = resp.lower()
    otraVez()

def cerveza():
    #mostrar los querys con vistas
    query = 'SELECT * FROM cerveza'
    cursor.execute(query)
    conn.commit()
    #db_rows = cursor.fetchall()

    #impresion del query en formato tabla con pandas
    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))
    
    #for row in db_rows:
    #    print(f"id {row[0]} tipo {row[2]} presentacion {row[2]}")
    
    print("Seleccione el id  de la cerveza que desea:")
    cerve = input()
    cerve = int (cerve)

def clientes():
    #mostrar los querys con vistas
    query = 'SELECT * FROM vendedor'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))
    

    print("Seleccione la cedula del de cliente que desea:")
    cliente = input()
    cliente = int (cliente)
   


def otraVez():
    while (resp!="no"):
        os.system('cls')
        conexion()
        menu()

conexion()
menu()