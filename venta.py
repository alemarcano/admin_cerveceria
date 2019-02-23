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
    print("Bienvenido a la aplicacion de ventas\n")

    print("1. Hacer una nueva venta")
    print("2. Ver todas las ventas realizadas")
    print("3. Ver el inventario de cervezas disponibles")
    print("4. Ver el porcentaje de ganancia de los clientes")
    print("5. Agregar un nuevo vendedor")



    print("\nEscribe el numero de la opcion que desees realizar:")
    global cambio 
    cambio = input()
    cambio = int (cambio)
    #evaluando tipo de cambio
    if(cambio ==1):
        cerveza()
    elif(cambio==2):
        ventas()
    elif(cambio==3):
        inventariocerveza()
    elif(cambio==4):
        gana()
    elif(cambio==5):
        agregarvendedor()
    else:
        print("El tipo de cambio que seleccionaste no existe")
    print("\nDeseas hacer otro tipo de cambio regresando al menu? (Si/No)?")
    global resp
    resp = input()
    resp = resp.lower()
    otraVez()

def cerveza():
    #mostrar los querys con vistas
    query = 'SELECT * FROM vendedor'
    cursor.execute(query)
    conn.commit()
    #db_rows = cursor.fetchall()

    #impresion del query en formato tabla con pandas
    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))
    
    
    print("\nEscriba la cedula del vendedor que realiza la venta:")
    cedu = input()
    cedu = int (cedu)

    query2 = 'SELECT * FROM supermercado'
    cursor.execute(query2)
    conn.commit()

    df = pandas.read_sql(query2, conn)
    print (df.to_string(index = False))

    print("\nEscriba el id del del supermercado al cual vende:")
    superm = input()
    superm = int (superm)

    query3 = 'SELECT * FROM cerveza'
    cursor.execute(query3)
    conn.commit()

    df = pandas.read_sql(query3, conn)
    print (df.to_string(index = False))

    print("\nSeleccione el id de la cerveza que quiere vender:")
    cerve = input()
    cerve = int (cerve)
    
    while True:
        print("Seleccione la cantidad de cerveza que desea vender:")
        cant = input()
        cant = int (cant)
        sqll = "SELECT cantdisponible FROM inventariocerveza   WHERE id = %s"
        cursor.execute(sqll, (cerve,))
        conn.commit()
        dispon = cursor.fetchall()
        almacenado = int(np.random.uniform(dispon, dispon))
        if (almacenado<cant):
            print("No hay cantidad disponible en el inventario para la cantidad solicitada")
        if(almacenado > cant):
            break
	 	


    sql = "SELECT * FROM InsertarVenta( %s,%s, %s, %s); "
    parameters = (superm,cedu,cerve,cant)
    cursor.execute(sql,parameters)
    conn.commit()
    print("\nVenta realizada perfectamente, gracias por preferirnos")

    query4 = 'SELECT * FROM VentaRealizada'
    cursor.execute(query4)
    conn.commit()

    df = pandas.read_sql(query4, conn)
    print (df.to_string(index = False))



def ventas():
    #mostrar los querys con vistas
    query = 'SELECT * FROM VentaRealizada'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))

def inventariocerveza():
    #mostrar los querys con vistas
    query = 'SELECT * FROM VerInventarioCerveza'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))

def gana():
    #mostrar los querys con vistas
    query = 'SELECT * FROM VerGanaciaVendedores'
    cursor.execute(query)
    conn.commit()

    df = pandas.read_sql(query, conn)
    print (df.to_string(index = False))


def agregarvendedor():
    print("Inserte su numero de cedula")
    cedul = input()
    cedul = int (cedul)
    print("Inserte su nombre")
    nom = input()
    print("Inserte su apellido")
    ape = input()
    print("Inserte su fecha nacimiento AAAA-MM-DD")
    ano = input()
    print("Inserte su numero telefonico")
    tlf = input()
    sql3 ='INSERT INTO "vendedor"(cedula,nombre, apellido, "fecha_nacimiento", telefono) values (%s,%s ,%s,%s,%s);'
    parameters =  (cedul, nom, ape, ano, tlf)
    cursor.execute(sql3,parameters)
    conn.commit()
    print("Vendedor añadido correctamente")


    
   


def otraVez():
    while (resp!="no"):
        os.system('cls')
        conexion()
        menu()

conexion()
menu()