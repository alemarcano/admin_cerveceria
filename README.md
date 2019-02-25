# admin_cerveceria
Proyecto de Administracion de Base de Datos sobre una base de datos transaccional en PostgreSQL, IoT con MQTT y Python.

Pasos para correr el proyecto admin_cerveceria:
Importar la base de datos:
Para comenzar importar en postgreSQL el archivo tipo custom basecerveceria en postgreSQL:
    Para eso en pgAdmin4 ingresar a Restore y tipo custom o tar
    Seleccionar en filename el archivo basecerveceria.sql y seleccionar el boton Restore

Correr los archivos en dos consolas diferentes pub.py y sub.py:
Antes de correr estos archivos cambiar la conexion de la base de datos (el usuario y contrasena a las de su equipo)
	Esta es la linea que debe cambiar en ambos arhivos el user y password
    conn = psycopg2.connect(host = 'localhost', user= 'postgres', password ='toby3030', dbname= 'cerveceria')

    en caso de no tener instalado los paquetes de python instalar
    pip install pandas
    pip install numpy
    pip install psycopg2


    En caso de no tener instalado el MQTT Mosquitto dejamos aqui un tutorial de como hacerlo:
    Windows10: https://www.youtube.com/watch?v=p1NxNYA2zkY
    Ubuntu: https://www.youtube.com/watch?v=SLEaW8qK3Rg


Correr el archivo en otra consola produccion.py

Correr el archivo en otra consola venta.py


En el archivo triggers.sql se encuentra todo el codigo documentado de los triggers y vistas ejecutadas
